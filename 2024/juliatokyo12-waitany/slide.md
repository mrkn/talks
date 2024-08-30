---
marp: true
theme: rose-pine-moon
title: waitany の話
paginate: true
_paginate: skip
footer: 2024.08.31 JuliaTokyo #12
_footer: ""
---

# waitany と waitall を作った話

Kenta Murata
Xica Co., Ltd.

2024.08.31 JuliaTokyo #12

---

# Contents

1. Self introduction

2. Julia におけるタスク終了の待ち方

3. waitany と waitall

4. 今後の展開

---

# Self introduction

---

## Self introduction

* 名前: 村田 賢太

* 所属: 株式会社サイカ

* 言語: Julia, Ruby, Python, ほか多数

* コミュニティ: JuliaLangJa, JuliaTokyo, ruby-jp, vim-jp

* GitHub: @mrkn

* Twitter: @KentaMurata

* 趣味: カメラいじり、レンズいじり

---
<!--
header: Juliaにおけるタスク終了の待ち方
_header: ""
-->

# Julia におけるタスク終了の待ち方

---

## Julia におけるタスクの終了

* タスク`t`の終了を待つ関数: `wait(t)`

* `t`が終了しているとき`istaskdone(t)`は`true`

* タスクの終了は2種類: 正常終了と異常終了

  * 正常終了では`fetch(t)`でタスクの結果を取得できる
  * 異常終了では`fetch(t)`は`TaskFailedException`を投げる

---

## 2つ以上のタスクを同時に待つには?

* 2つ以上のタスクを同時に待ちたいことは時々ある

* 複数のタスクを同時に待てる組込み関数はまだない

* どういう時に必要になるのか？

---

## 複数タスクを待つ機能が必要な場合の例

* streamlit のサーバのメインループの中

* 複数タスクを待つ機能がメインループ内で2回使われている

    * サーバ起動後の一つもセッションが存在しない場合の処理

    * メインループの最後に毎回実行される処理

---

## 複数タスクを待つ機能が必要な場合の例 (streamlit より引用)

 ```py
            while not async_objs.must_stop.is_set():
                if self._state == RuntimeState.NO_SESSIONS_CONNECTED:  # type: ignore[comparison-overlap]
                    # mypy 1.4 incorrectly thinks this if-clause is unreachable,
                    # because it thinks self._state must be INITIAL | ONE_OR_MORE_SESSIONS_CONNECTED.

                    # Wait for new websocket connections (new sessions):
                    _, pending_tasks = await asyncio.wait(  # type: ignore[unreachable]
                        (
                            asyncio.create_task(async_objs.must_stop.wait()),
                            asyncio.create_task(async_objs.has_connection.wait()),
                        ),
                        return_when=asyncio.FIRST_COMPLETED,
                    )
                    # Clean up pending tasks to avoid memory leaks
                    for task in pending_tasks:
                        task.cancel()
                else:
                    # ... セッションが1つ以上ある場合の処理など ...

                # ... 次のページに続く ...
 ```

---

## 複数タスクを待つ機能が必要な場合の例のつづき (streamlit より引用)

```py
                # ... 前のページの while の中の続き ...

                # Wait for new proto messages that need to be sent out:
                _, pending_tasks = await asyncio.wait(
                    (
                        asyncio.create_task(async_objs.must_stop.wait()),
                        asyncio.create_task(async_objs.need_send_data.wait()),
                    ),
                    return_when=asyncio.FIRST_COMPLETED,
                )
                # We need to cancel the pending tasks (the `must_stop` one in most situations).
                # Otherwise, this would stack up one waiting task per loop
                # (e.g. per forward message). These tasks cannot be garbage collected
                # causing an increase in memory (-> memory leak).
                for task in pending_tasks:
                    task.cancel()
```

---

## streamlit による複数のタスクを待つ機能の使い方

* 3つの非同期イベント
    * `must_stop`: サーバを停止する必要があることを表すイベント

    * `has_connection`: クライアントからのコネクションが来たことを表すイベント

    * `need_send_data`: クライアントへ送るデータが発生したことを表すイベント

* 一つ目の `asyncio.wait`: 一つもセッションがない場合の処理
    * `must_stop` と `has_connection` のうち1つ以上がセットされるまで待つ

    * つまり、サーバを停止する必要があるか、クライアントからコネクションが来るまで待つ

---

## streamlit による複数のタスクを待つ機能の使い方

* 3つの非同期イベント
    * `must_stop`: サーバを停止する必要があることを表すイベント

    * `has_connection`: クライアントからのコネクションが来たことを表すイベント

    * `need_send_data`: クライアントへ送るデータが発生したことを表すイベント

* 二つ目の `asyncio.wait`: メインループの最後に毎回実行する処理
    * `must_stop` と `need_send_data` のうち1つ以上がセットされるまで待つ

    * つまり、サーバを停止する必要があるか、クライアントに送るべきデータが発生するまで待つ

---

## 複数タスクの待ち方は3種類ある

* 3種類の待ち方

  1. 指定したタスクのうち少なくとも1つが終了するまで待つ

  2. 指定した全てのタスクが終了するまで待つ

  3. 指定した全てのタスクが終了するまで待つが、一つ以上のタスクが異常終了した場合はすぐに待機を終える

* これらに加えて、「すべてのタスクを待つが、例外が発生した場合は待機をすぐに終了する」というパターンも考えられる

* Pythonの`asyncio.wait`は3つすべてに対応している

---
<!--
header: waitany と waitall
_header: ""
-->

# waitany と waitall

---

## waitany と waitall

* Julia で複数のタスクを待つための関数が必要になったので自分で作った

  * 「少なくとも一つが終了するまで待つ」関数が `waitany`

  * 「全てが終了するまで待つ」関数が `waitall`

* 機能的に Julia の組み込み機能として提供されているべきだと考えたので Pull Request を送ったらマージしてもらえた

* Julia v1.12 から使えるようになる予定

---

## waitany の使い方

1. 基本形

    ```julia
    waitany(tasks) -> (done_tasks, remaining_tasks)
    ```

    * 少なくとも一つのタスクが終了するまで、現在のタスクの実行をブロックする

    * 待機中のタスクが異常終了したら`TaskFailedException`を発生させる

    * 戻り値は終了したタスクの配列と、まだ終了していないタスクの配列のタプル

2. `throw` キーワード引数で`TaskFailedException`を発生させるかどうか指定する

    ```julia
    waitany(tasks; throw=true)   # 基本形と同じ
    waitany(tasks; throw=false)  # 例外を発生しない
    ```

---

## waitall の使い方

1. 基本形

    ```julia
    waitall(tasks) -> (done_tasks, remainig_tasks)
    ```

    * すべてのタスクが終了するまで待つ (戻り値は `waitany` と同じ)

    * 待機中のタスクが異常終了したらすぐに `TaskFailedException` を発生させる

2. 異常終了したタスクも含めてすべて終了するまで待つ

    ```julia
    waitall(tasks; failfast=false)
    ```

3. `TaskFailedException` を発生させない

    ```julia
    waitall(tasks; throw=false)
    ```

---

### 引数 tasks の型

* 引数 `tasks` の型は特定していない

* `Task`が出てくるイテレータとして使えるものならなんでも使える

* `AbstractVector{Task}` だけ特別扱いすると配列のコピーを減らせるので修正したい

* 可能なら「`Task`が出てくるイテレータになるコンテナ型」を指定したいが、いまの Julia ではそういう型指定はできない

---

## なぜ waitany と waitall を分けたか？

* 「少なくとも1つが終了するまで待つ」待ち方と「全てが終了するまで待つ」待ち方を引数で切り替えるより、別の関数にする方が良いと考えたので分た

* そう考えた理由

  * 関数名が違う方が可読性が高い (気がする、少なくとも私にとっては良い)

  * `waitmultiple` より名前が短くて良い

  * `wait` のメソッドを増やすのは `wait(::Any)` を定義することになってしまう

---
<!--
header: 今後の展開
_header: ""
-->

# 今後の展開

---

## いま取り組んでいること

* `waitany` と `waitall` を `Task` 以外の waitable types に対応させること

* `Task` 以外の waitable types とは

    * `Channel`

    * `Event`

    * `IO`

    * etc.

* まずは `Channel` にチャレンジしている

---

## Task 以外の waitable types に対応させるやり方

次の手順でどんどん一般化していきたい

1. `Channel` のみのコレクションに対応させる

2. `IO` のみのコレクションに対応させる

3. `Task`、`Channel`、`IO` が混在しているコレクションに対応させる

4. `Channel` と `IO` に対応できたら `select` 関数を作りたい

5. 他の waitable types に対応していく

---

## Channel に対応させる難しさ

* 複数の `Channel` を同時に待つ効率が良い実装を作ることが難しい

* `waitany` と `waitall` の第一引数の扱い方が難しい

---

## 第一引数の扱い方

* 現在の `waitany` は第一引数の型を特定せず、`iterate`で出てくるものが `Task` であることを決め打ちしている

    ```julia
    waitany(tasks; throw=true) = _wait_multiple(tasks, throw)

    function _wait_multiple(waiting_tasks, throwexc=false, all=false, failfast=false)
        tasks = Task[]

        for t in waiting_tasks
            t isa Task || error("Expected an iterator of `Task` object")
            push!(tasks, t)
        end

        # ... ここから先はタスクを待つコード ...
    end
    ```

* どうやって `Task` 以外の型に拡張するか？

---

## Task 以外の型への拡張

```julia
waitany(seq; throw::Bool=true)
```

* とりあえず、現時点では `seq` の要素はすべて同じ型であることを要請する

* `eltype(seq)` が `Any` 以外の型なら、それが waitable type かどうかをチェックして `wait_multiple` を呼べば良さそう

* `eltype(seq)` が `Any` だったら、先頭要素の型 `T` が waitable type かどうかをチェックし、残りの要素の型も `T` である事をチェックしながら `Vector{T}` に集めて `wait_multiple` を呼べば良さそう

* 上のやり方は異なる watiable types を混ぜて同時に待ちたい場合には機能しないので、そのような場合に対応させる際には別の方法を検討する必要がある

---

## この方針に従って waitany を分解する

異なる型が混在しない場合については、次のやり方で対応できそう。
```julia
waitany(seq; throw::Bool=true) = _waitany(eltype(seq), seq, throw)

_waitany(::Nothing, throw::Bool) = ([], [])

_waitany(::Type{T}, seq, throw::Bool) where {T} = waitany([x::T for x in seq]; throw=throw)

_waitany(::Type{Any}, seq, throw::Bool) = _waitany(peel(seq)..., throw)

_waitany(fst::T, rest::R, throw::Bool) where {T, R} = waitany(collectwaitables(fst, rest); throw=throw)

waitany(tasks::AbstractVector{Task}; throw::Bool=true) = _wait_multiple(tasks, throw)

function collectwaitables(fst::T, rest) where {T}
    checkwaitable(fst)  # fst の型が waitable type かチェックし、違う場合に例外を出す
    waitables = [fst]
    for x in rest
        x isa T || error("Expected an iterator of `$(T)` object")
        push!(waitables, x)
    end
    return waitables
end
```

---

## 残された課題

* 複数の `Channel` を効率よく待つ方法を作る

* ほかの waitable types に対応する

* `select` 関数を作る

---
<!-- header: "" -->

# 進展があったらまた報告します

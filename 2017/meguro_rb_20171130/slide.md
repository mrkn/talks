class: title_page, middle
# Ruby のデータサイエンス対応の<br/>現状確認
## Kenta Murata, Speee Inc. 開発部 R&D グループ
.speee_logo[
![](images/Speee_VI_yokogumi.png)]

Thu, Nov 30, 2017  Meguro.rb

---

# self.introduce

- Kenta Murata (@mrkn)
- Full-time CRuby committer at Speee Inc.
- CRuby
    - The maintainer of bigdecimal
- Other OSS
    - pycall.rb, mxnet.rb, enumerable-statistics, vim-cruby
- Hobby
    - Play with my daughter, Mathematics, Physics, Computer Science, Reading SF, etc.

---

class: middle
### 現在、Ruby のデータサイエンス対応は過渡期です。
### 本日は、どんなプロジェクトが存在し、それぞれどんな特徴があるかを紹介します。
### みなさんは、ぜひどこかのプロジェクトに参加していただき、Ruby のデータサイエンス対応を加速する当事者になっていただきたいです。

---

# Contents

- SciRuby
- Ruby Numo
- pycall.rb
- mxnet.rb
- Red Data Tools project
- GPGPU への対応状況
- RubyData organization

---

# SciRuby

- NMatrix を中心とする科学技術計算用 gem 群
- 海外で最も有名な Ruby の科学技術計算ライブラリ群
- 発起人たちは最近は全く開発しておらず、GSOC のプロジェクトで学生が色々作っているものの寄せ集め状態になっている
- 一部の基本演算が遅いバグがある

---

# Ruby Numo
- Numo::NArray を中心とする科学技術計算用 gem 群
- 元祖 NArray の作者である田中昌宏さんが発起人であり開発の中心にいる
- RubyKaigi でも発表されていて、日本ではそこそこ知られていると思う
- 海外ではあまり知られていない (?)

---

## SciRuby と Ruby Numo でできること

- データフレームライブラリ Daru が NMatrix に対応している
    - **[HELP]** 誰か Numo::NArray にも対応させてください
- 科学技術計算用の基礎関数群
    - GSL のバインディングが SciRuby と Ruby Numo のそれぞれに対して存在する
- 可視化
    - Gnuplot を使うライブラリが SciRuby と Ruby Numo のそれぞれに対して存在する
    - rbplotly が両方に対応している (はず)

---

# pycall.rb

- Ruby から Python を呼び出せる
- Ruby と同じプロセス内で Python インタープリタを初期化し呼び出す
- 次のリリースから Python を呼び出す際に GVL を解放するようになるので、puma で動く Rails アプリケーションでも使える！
- しかし、Python 側の GIL の制御をまだやってないので、Ruby 側の複数のスレッドから Python の機能を呼び出してはならない
- 欲しい機能の提案をプルリクエストの形で募集しています
- 一緒に開発してくれる、Ruby と Python の両方に詳しい人も募集してます

---

# mxnet.rb

- MXNet の Ruby バインディング
- 10月頃から本気出して RubyConf までに完成させようとしたけど無理でした！！
    - 3月の沖縄 RubyKaigi 02 までになんとかする
- Ruby と MXNet の両方に詳しい人の協力を募集しています

---

# Red Data Tools project

- Apache Arrow を中心としたデータツールエコシステムの Ruby 版
- 須藤さんが立ち上げた
- 須藤さんは Apache Arrow の PMC にもなった
- Red Chainer など、Apache Arrow とは直接関係ない派生プロダクトの開発も始まっている
- おそらく関係者は全員が日本人である
- 毎月「OSS Gate 東京ミートアップ for Red Data Tools」で開発が進められている
    - 12月のイベントの案内を後でします

---

# GPGPU への対応状況

- tensorflow.rb で GPU が使える (はず)
- pycall.rb で Python の GPGPU 対応ライブラリを使える
- 今年 2017 年の GSOC で ArrayFire のバインディングが作られた
- 今年 2017 年の Ruby Grant で GPGPU 対応プロジェクトが2件採択
    1. RbCUDA: ArrayFire のバインディングを作った人のプロジェクトで、CUDA ランタイムライブラリの Ruby バインディング
    2. cumo: sonots さんのプロジェクトで、cupy の Ruby 版を Numo::NArray に対して作る
- mxnet.rb が使えるようになると、これも GPGPU に対応する
---

# Ruby でデータサイエンスする環境を簡単に試す方法

実は Docker image を作ってある。

```
docker run --rm -it -p 8888:8888 rubydata/notebooks
```

これで、Jupyter notebbok が立ち上がるので、IRuby kernel のノートブックを作れば試せる。


---

# RubyData organization

- SciRuby、Ruby Numo、Red Data Tools、など複数のプロジェクトに人が分散している現状は、純粋な利用者が戸惑いやすい
- プロジェクトに関係なく、Ruby とデータツールを組み合わせて使おうとしている人が集まって情報交換ができる場が必要だろう
- というわけで、私が作り始めました
- http://ruby-data.org/
    - まだランディングページしかない！！

---

# RubyData needs helps!!

- 以下のような人を募集してます
    - コミュニティ運営 (人の集まりを制御すること) が得意な人 (私 mrkn が一番不得意なこと)
    - AWS に詳しい人 (discourse の立ち上げと運営を手伝って欲しい)
    - 自然言語での継続的な情報発信が得意な人 (「Ruby でデータサイエンス」的な情報発信をスケールさせたい)
    - 英語が得意な人 (僕たちの変な英語を直して欲しい)
    - docker-stacks の維持と発展を積極的にやってくれる人

---

# みなさんが今すぐできること

1. 使ってバグ報告
2. 日本に閉じてるプロダクトを海外向けに英語で紹介する
3. 利用者が増えるようなブログ記事を書く (やってみた系)
4. 開発者が増えるようなブログ記事を書く (開発環境を作る、コードを読んでみた系)
5. 既存のライブラリにプルリクを送って開発に参加する
6. RubyData の運営チームに入って得意なことをやる
7. OSS Gate for Red Data Tools に参加して開発する

---

# OSS Gate for Red Data Tools in Speee 2017.12.19

Red Data Tools プロジェクトの開発者が集まります。

- 場所: 六本木4-1-4 黒崎ビル 5F Speee Inc. セミナールーム
- 時間: 2017年12月19日
    - 19:00 開場
    - 19:30 開始
- https://speee.connpass.com/event/72926/


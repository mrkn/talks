---
marp: true
theme: uncover
title: HolidayJp.jl を作りました
backgroundColor: #eee
footer: 2024.08.31 JuliaTokyo #12
_footer: ""
paginate: true
_paginate: skip
---

# HolidayJp.jl を作りました

Kenta Murata
Xica Co., Ltd.

2024.08.31 JuliaTokyo #12

---

# HolidayJp.jl とは

---
<!-- header: HolidayJp.jl とは -->

## 日本の祝日に関する機能を<br/>提供するライブラリ

---

## 機能一覧

---

### 機能一覧

* `isholiday` 関数
* `getholiday` 関数
* `between` 関数

---
<!-- header: "" -->

### isholiday 関数

与えられた日付が祝日かどうかを判定

```julia
isholiday(y::I, m::I, d::I)::Bool where {I<:Integer}
isholiday(datelike)::Bool
```

---

<!-- header: isholiday 関数 -->

#### Usage

```julia
import HolidayJp: isholiday

isholiday(Date("2024-01-01"))  # true
isholiday(DateTime("2024-01-01", "yyyy-mm-dd"))  # true
isholiday(2024, 1, 1)  # true
```

---

<!-- header: "" -->

### getholiday 関数

与えられた日付の祝日情報または`nothing`を返す

```julia
getholiday(y::I, m::I, d::I)::Union{Nothing,Holiday} where {I<:Integer}
getholiday(datelike)::Union{Nothing,Holiday}
```

---

<!-- header: getholiday 関数 -->

#### 祝日情報の定義

```julia
Base.@kwdef struct Holiday
    date::Date
    week::String
    week_en::String
    name::String
    name_en::String
end
```

---

#### Usage

```julia
import HolidayJp: getholiday

getholiday(2024, 2, 23)
# HolidayJp.Holiday(Date("2024-02-23"), "金", "Friday", "天皇誕生日", "Emperor's Birthday")
```

---

<!-- header: "" -->

### between 関数

与えられた日付の範囲に含まれる祝日の情報を配列で返す

```julia
between(lower_limit, upper_limit)::Vector{Holiday}
```

---

<!-- header: "between 関数" -->
#### Usage

```julia
[h.date for h in between(Date("2024-01-01"), Date("2024-12-31"))]
# 21-element Vector{Date}:
#  2024-01-01
#  2024-01-08
#  ...
#  2024-11-04
#  2024-11-23
```

---
<!-- header: "" -->
## こだわりポイント

---

### こだわりポイント: datelike

* `Dates`モジュールの`year`関数、`month`関数、`day`関数に対応しているオブジェクトならなんでも日付として扱えるようにした

---
<!-- header: "こだわりポイント: datelike" -->

```julia
import Dates
import HolidayJp: isholiday

struct YMD
    year::Int
    month::Int
    day::Int
end

Dates.year(x::YMD) = x.year
Dates.month(x::YMD) = x.day
Dates.day(x::YMD) = x.day

isholiday(YMD(2024, 2, 23))  # true
```

---
<!-- header: "" -->
## 今後の展開

---

## 今後の展開

* ドキュメントをちゃんと書く
* holiday\_jp org 配下に transfer させてもらう
* holiday\_jp/holiday\_jp のデータを総務省の `syukujitsu.csv` から生成できるようにする
* 他に面白そうなアイデアがあったら教えてください！

---
<!-- header: "" -->
# 使ってみてください！

https://github.com/mrkn/HolidayJp.jl

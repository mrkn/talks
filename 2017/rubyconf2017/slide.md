class: title_page, left, middle
# Using Ruby in data science
## Kenta Murata, Speee Inc.
.speee_logo[
![](images/Speee_VI_yokogumi.png)]

Fri, Nov 17, 2017 RubyConf 2017 in New Orleans, LA, US

---
class: middle
# How many people are your work related to data science?

----
- Data scientists
- Data engineers
- Developers of applications that utlize data

---
class: middle
# We need to be familiar with the way of data utilization

---
class: middle
# But Ruby prohibit us from that because
# Ruby is hard to use for data science

---
class: middle
# But Ruby prohibit us from that because
# Ruby is hard to use for data science, recently

---
class: middle
# Now Ruby tends to be easy to use for data science, gradually

---
# self . introduction

- Kenta Murata

- @mrkn (github, twitter, etc.)

- **Full-time CRuby committer** and Researcher at Speee Inc.

- bigdecimal, enumerable-statistics, **pycall**, **mxnet.rb**, etc.

---
# Full-time CRuby committer

- My company employs me as a full-time CRuby committer.
- I'm permitted by my company to do anything for CRuby ecosystem.
- In this year, I'm totally working for building ecosystem of data science tools that are used with applications written in Ruby

---
# Topics in this talk

- Introduction to **pycall.rb**
    - How to use Python data tools from Ruby

- Introduction to **mxnet.rb**
    - Now Ruby can do deep learning not only on CPU but also on GPU

- The current best practice for using Ruby in data science

- The future perspective (Apache Arrow, R, Spark, etc.)

- RubyData organization

---
class: center, middle
# Introduction to **pycall.rb**

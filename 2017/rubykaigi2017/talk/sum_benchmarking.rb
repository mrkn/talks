# Benchmark ================================================
require 'benchmark'
N, L = 100, 1_000_000
ary = Array.new(L) { rand }
methods, times = [], []
N.times do
  methods << :inject
  times   << Benchmark.realtime { ary.inject(:+) }
  # ------------------------------------
  methods << :while
  times   << Benchmark.realtime {
    sum, i = ary[0], 1
    while i < L
      sum += ary[i]; i += 1
    end
  }
  # ------------------------------------
  methods << :sum
  times   << Benchmark.realtime { ary.sum }
end

# Make dataframe ===========================================
require 'pandas'
df = Pandas::DataFrame.new(data: { method: methods, time: times })
Pandas.options.display.width = `tput cols`.to_i
puts df.groupby(:method).describe

# Visualization ============================================
require 'matplotlib/pyplot'
plt = Matplotlib::Pyplot
sns = PyCall.import_module('seaborn')
sns.barplot(x: 'method', y: 'time', data: df)
plt.title("Array summation benchmark (#{N} trials)")
plt.savefig('bench.png', dpi: 100)

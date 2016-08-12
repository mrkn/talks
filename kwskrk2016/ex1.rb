m = 0
n = 5
10_000_000.times do
  xs = Array.new(n) { 1.0 + 1e-6 * (0.5 - rand) }
  sq_mean = xs.map {|x| x**2 }.sum / n
  mean_sq = (xs.sum / n)**2
  var = sq_mean - mean_sq
  p [m += 1, var] if var.negative?
end

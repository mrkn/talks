```ruby
require 'numpy'
np = Numpy

require 'matplotlib/iruby'
Matplotlib::IRuby.activate
plt = Matplotlib::Pyplot

mu = np.random.randn(2)
cov = np.random.randn(2, 2)
x = np.random.multivariate_normal(mu, cov, 1000)
plt.scatter(x[0..-1, 0], x[0..-1, 1])

def pca(x)
  mu = x - Numpy.mean(x, 0)
  u, s, v = *Numpy.linalg.svd(x)
  mu.dot v
end

x_pca = pca(x)

plt.scatter(x_pca[0..-1, 0], x_pca[0..-1, 1])
```



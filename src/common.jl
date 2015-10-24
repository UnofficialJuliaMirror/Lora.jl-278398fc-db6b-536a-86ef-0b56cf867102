### Logistic function in its general form

# See https://en.wikipedia.org/wiki/Logistic_function
# l scales the curve. For l>1, the curve is stretched, whereas for l<1 it is shrinked
# The curve's maximum value coincides with l
# k gives the curve's steepness. For larger k, the curve becomes more steep
# x0 is the x value of the curve's midpoint
# y0 is the y value of the curve's midpoint
# The logistic function has been defined for tuning purposes

logistic(x::Number, l::Number=1., k::Number=1., x0::Number=0., y0::Number=0.) = l/(1+exp(-k*(x-x0)))+y0

### Tune types hold the samplers' temporary output used for tuning the sampler

abstract MCTune

### MCTuner

abstract MCTuner

abstract ParameterState{S<:ValueSupport, F<:VariateForm, N<:Number} <: VariableState{F, N, Random}

type ContinuousUnivariateParameterState{N<:FloatingPoint} <: ParameterState{Continuous, Univariate, N}
  value::N
  pdf::Union(ContinuousUnivariateDistribution, Nothing)
  loglikelihood::N
  logprior::N
  logtarget::N
  gradloglikelihood::N
  gradlogprior::N
  gradlogtarget::N
  tensorlogtarget::N
  dtensorlogtarget::N
end

ContinuousUnivariateParameterState{N<:FloatingPoint}(
    value::N,
    pdf::Union(ContinuousUnivariateDistribution, Nothing)=nothing
  ) =
  ContinuousUnivariateParameterState{N}(
    value,
    pdf,
    convert(N, NaN),
    convert(N, NaN),
    convert(N, NaN),
    convert(N, NaN),
    convert(N, NaN),
    convert(N, NaN),
    convert(N, NaN),
    convert(N, NaN)
  )

ContinuousUnivariateParameterState{N<:FloatingPoint}(
    ::Type{N}=Float64,
    pdf::Union(ContinuousUnivariateDistribution, Nothing)=nothing
  ) =
  ContinuousUnivariateParameterState(
    convert(N, NaN),
    pdf,
    convert(N, NaN),
    convert(N, NaN),
    convert(N, NaN),
    convert(N, NaN),
    convert(N, NaN),
    convert(N, NaN),
    convert(N, NaN),
    convert(N, NaN)
  )

type ContinuousMultivariateParameterState{N<:FloatingPoint} <: ParameterState{Continuous, Multivariate, N}
  value::Vector{N}
  loglikelihood::N
  logprior::N
  logtarget::N
  gradloglikelihood::Vector{N}
  gradlogprior::Vector{N}
  gradlogtarget::Vector{N}
  tensorlogtarget::Matrix{N}
  dtensorlogtarget::Array{N, 3}
  size::Int
end

function ContinuousMultivariateParameterState{N<:FloatingPoint}(value::Vector{N}, monitor::Vector{Bool}=fill(false, 5))
  size::Int = length(value)

  l::Vector{Int} = Array(Int, 5)
  for i in 1:5
    l[i] = (monitor[i] == false ? zero(Int) : size)
  end

  ContinuousMultivariateParameterState{N}(
    value,
    convert(N, NaN),
    convert(N, NaN),
    convert(N, NaN),
    Array(N, l[1]),
    Array(N, l[2]),
    Array(N, l[3]),
    Array(N, l[4], l[4]),
    Array(N, l[5], l[5], l[5]),
    size
  )
end

function ContinuousMultivariateParameterState{N<:FloatingPoint}(
  ::Type{N}=Float64,
  size::Int=0,
  monitor::Vector{Bool}=[true, fill(false, 6)]
  )

  l::Vector{Int} = Array(Int, 6)
  for i in 1:6
    l[i] = (monitor[i] == false ? zero(Int) : size)
  end

  ContinuousMultivariateParameterState{N}(
    Array(N, l[1]),
    convert(N, NaN),
    convert(N, NaN),
    convert(N, NaN),
    Array(N, l[2]),
    Array(N, l[3]),
    Array(N, l[4]),
    Array(N, l[5], l[5]),
    Array(N, l[6], l[6], l[6]),
    l[1]
  )
end

typealias Parameter{S<:ValueSupport, F<:VariateForm, N<:Number} Variable{F, N, Random}

# Guidelines for usage of inner constructors of continuous parameter types:
# 1) Function fields have higher priority than implicitly derived definitions via the pdf field
# 2) Target-related fields have higher priority than implicitly derived likelihood+prior fields
# 3) Upto-related fields have higher priority than implicitly derived Function tuples

type ContinuousUnivariateParameter{N<:FloatingPoint} <: Parameter{Continuous, Univariate, N}
  index::Int
  key::Symbol
  setpdf!::Union(Function, Nothing)
  loglikelihood::Union(Function, Nothing)
  logprior::Union(Function, Nothing)
  logtarget::Union(Function, Nothing)
  gradloglikelihood::Union(Function, Nothing)
  gradlogprior::Union(Function, Nothing)
  gradlogtarget::Union(Function, Nothing)
  tensorloglikelihood::Union(Function, Nothing)
  tensorlogprior::Union(Function, Nothing)
  tensorlogtarget::Union(Function, Nothing)
  dtensorloglikelihood::Union(Function, Nothing)
  dtensorlogprior::Union(Function, Nothing)
  dtensorlogtarget::Union(Function, Nothing)
  uptogradlogtarget::Union(Function, Nothing)
  uptotensorlogtarget::Union(Function, Nothing)
  uptodtensorlogtarget::Union(Function, Nothing)
  rand::Union(Function, Nothing)
  state::ContinuousUnivariateParameterState{N}
end

function ContinuousUnivariateParameter{N<:FloatingPoint}(
  index::Int,
  key::Symbol,
  setpdf!::Union(Function, Nothing),
  ll::Union(Function, Nothing),
  lp::Union(Function, Nothing),
  lt::Union(Function, Nothing),
  gll::Union(Function, Nothing),
  glp::Union(Function, Nothing),
  glt::Union(Function, Nothing),
  tll::Union(Function, Nothing),
  tlp::Union(Function, Nothing),
  tlt::Union(Function, Nothing),
  dtll::Union(Function, Nothing),
  dtlp::Union(Function, Nothing),
  dtlt::Union(Function, Nothing),
  uptoglt::Union(Function, Nothing),
  uptotlt::Union(Function, Nothing),
  uptodtlt::Union(Function, Nothing),
  sample::Union(Function, Nothing),
  state::ContinuousUnivariateParameterState{N}
)
  fin = (setpdf!, ll, lp, lt, gll, glp, glt, tll, tlp, tlt, dtll, dtlp, dtlt, uptoglt, uptotlt, uptodtlt, sample)
  fnames = (
    "setpdf!",
    "loglikelihood",
    "logprior",
    "logtarget",
    "gradloglikelihood",
    "gradlogprior",
    "gradlogtarget",
    "tensorloglikelihood",
    "tensorlogprior",
    "tensorlogtarget",
    "dtensorloglikelihood",
    "dtensorlogprior",
    "dtensorlogtarget",
    "uptogradlogtarget",
    "uptotensorlogtarget",
    "uptodtensorlogtarget",
    "rand"
  )
  nf = 17

  # Check that all generic functions have correct signature
  for i = 1:nf
    if isa(fin[i], Function) &&
      isgeneric(fin[i]) &&
      !method_exists(fin[i], (ContinuousUnivariateParameterState{N}, Dict{Variable, VariableState}))
      error("$(fnames[i]) has wrong signature")
    end
  end

  # Initialize output vector of functions fout by copying into it contents of fin
  fout = Union(Function, Nothing)[fin[i] for i in 1:nf]

  # Define logtarget (i = 4) and gradlogtarget (i = 7)
  for (i , f) in ((4, logpdf), (7, gradlogpdf))
    if fin[i] == nothing
      if isa(fin[i-2], Function) && isa(fin[i-1], Function)
        # pstate and nstate stand for parameter state and neighbors' state respectively
        fout[i] =
          (pstate::ContinuousUnivariateParameterState{N}, nstate::Dict{Variable, VariableState}) ->
          fin[i-2](pstate, nstate)+fin[i-1](pstate, nstate)
      elseif isa(fin[1], Function)
        fout[i] =
          (pstate::ContinuousUnivariateParameterState{N}, nstate::Dict{Variable, VariableState}) ->
          f(setpdf!(pstate, nstate), pstate.value)
      elseif isa(state.pdf, ContinuousUnivariateDistribution) && method_exists(f, (typeof(state.pdf), N))
        fout[i] =
          (pstate::ContinuousUnivariateParameterState{N}, nstate::Dict{Variable, VariableState}) ->
          f(pstate.pdf, pstate.value)
      end
    end
  end

  # Define tensorlogtarget (i = 10) and dtensorlogtarget (i = 13)
  for i in (10, 13)
    if fin[i] == nothing && isa(fin[i-2], Function) && isa(fin[i-1], Function)
      fout[i] =
        (pstate::ContinuousUnivariateParameterState{N}, nstate::Dict{Variable, VariableState}) ->
        fin[i-2](pstate, nstate)+fin[i-1](pstate, nstate)
    end
  end

  # Define uptogradlogtarget
  if fin[14] == nothing && isa(fout[4], Function) && isa(fout[7], Function)
    fout[14] =
      (pstate::ContinuousUnivariateParameterState{N}, nstate::Dict{Variable, VariableState}) ->
      (fout[4](pstate, nstate), fout[7](pstate, nstate))
  end

  # Define uptotensorlogtarget
  if fin[15] == nothing && isa(fout[4], Function) && isa(fout[7], Function) && isa(fout[10], Function)
    fout[15] =
      (pstate::ContinuousUnivariateParameterState{N}, nstate::Dict{Variable, VariableState}) ->
      (fout[4](pstate, nstate), fout[7](pstate, nstate), fout[10](pstate, nstate))
  end

  # Define uptodtensorlogtarget
  if fin[16] == nothing &&
    isa(fout[4], Function) &&
    isa(fout[7], Function) &&
    isa(fout[10], Function) &&
    isa(fout[13], Function)
    fout[16] =
      (pstate::ContinuousUnivariateParameterState{N}, nstate::Dict{Variable, VariableState}) ->
      (fout[4](pstate, nstate), fout[7](pstate, nstate), fout[10](pstate, nstate), fout[13](pstate, nstate))
  end

  # Define rand
  if fin[17] == nothing
    if isa(fin[1], Function)
      fout[17] =
        (pstate::ContinuousUnivariateParameterState{N}, nstate::Dict{Variable, VariableState}) ->
        rand(setpdf!(pstate, nstate))
    elseif isa(state.pdf, ContinuousUnivariateDistribution) && method_exists(rand, (typeof(state.pdf),))
      fout[17] =
        (pstate::ContinuousUnivariateParameterState{N}, nstate::Dict{Variable, VariableState}, n::Int) ->
        rand(pstate.pdf)
    end
  end

  ContinuousUnivariateParameter{N}(
    index,
    key,
    fout[1],
    fout[2],
    fout[3],
    fout[4],
    fout[5],
    fout[6],
    fout[7],
    fout[8],
    fout[9],
    fout[10],
    fout[11],
    fout[12],
    fout[13],
    fout[14],
    fout[15],
    fout[16],
    fout[17],
    state
  )
end

function ContinuousUnivariateParameter{N<:FloatingPoint}(
  index::Int,
  key::Symbol;
  setpdf!::Union(Function, Nothing)=nothing,
  loglikelihood::Union(Function, Nothing)=nothing,
  logprior::Union(Function, Nothing)=nothing,
  logtarget::Union(Function, Nothing)=nothing,
  gradloglikelihood::Union(Function, Nothing)=nothing,
  gradlogprior::Union(Function, Nothing)=nothing,
  gradlogtarget::Union(Function, Nothing)=nothing,
  tensorloglikelihood::Union(Function, Nothing)=nothing,
  tensorlogprior::Union(Function, Nothing)=nothing,
  tensorlogtarget::Union(Function, Nothing)=nothing,
  dtensorloglikelihood::Union(Function, Nothing)=nothing,
  dtensorlogprior::Union(Function, Nothing)=nothing,
  dtensorlogtarget::Union(Function, Nothing)=nothing,
  uptogradlogtarget::Union(Function, Nothing)=nothing,
  uptotensorlogtarget::Union(Function, Nothing)=nothing,
  uptodtensorlogtarget::Union(Function, Nothing)=nothing,
  rand::Union(Function, Nothing)=nothing,
  state::ContinuousUnivariateParameterState{N}=ContinuousUnivariateParameterState(Float64)
)
  ContinuousUnivariateParameter{N}(
    index,
    key,
    setpdf!,
    loglikelihood,
    logprior,
    logtarget,
    gradloglikelihood,
    gradlogprior,
    gradlogtarget,
    tensorloglikelihood,
    tensorlogprior,
    tensorlogtarget,
    dtensorloglikelihood,
    dtensorlogprior,
    dtensorlogtarget,
    uptogradlogtarget,
    uptotensorlogtarget,
    uptodtensorlogtarget,
    rand,
    state
  )
end

type ContinuousMultivariateParameter{N<:FloatingPoint} <: Parameter{Continuous, Multivariate, N}
  index::Int
  key::Symbol
  distribution::Union(ContinuousMultivariateDistribution, Nothing)
  loglikelihood::Union(Function, Nothing)
  logprior::Union(Function, Nothing)
  logtarget::Union(Function, Nothing)
  gradloglikelihood::Union(Function, Nothing)
  gradlogprior::Union(Function, Nothing)
  gradlogtarget::Union(Function, Nothing)
  tensorloglikelihood::Union(Function, Nothing)
  tensorlogprior::Union(Function, Nothing)
  tensorlogtarget::Union(Function, Nothing)
  dtensorloglikelihood::Union(Function, Nothing)
  dtensorlogprior::Union(Function, Nothing)
  dtensorlogtarget::Union(Function, Nothing)
  uptogradlogtarget::Union(Function, Nothing)
  uptotensorlogtarget::Union(Function, Nothing)
  uptodtensorlogtarget::Union(Function, Nothing)
  state::ContinuousMultivariateParameterState{N}
end

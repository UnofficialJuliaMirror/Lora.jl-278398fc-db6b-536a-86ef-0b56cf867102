###########################################################################
#
#  Random-Walk Metropolis (RWM)
#
#  Parameters:
#    -tuner: used for scaling the jumps
#
###########################################################################

export RWM

println("Loading RMW(tuner) sampler")

#### RWM specific 'tuners'
immutable RWMTuner  <: MCMCTuner
end	

####  RWM sampler type  ####
immutable RWM <: MCMCSampler
  tuner::RWMTuner
end
RWM() = RWM(RWMTuner())

# Sampling task launcher
spinTask(model::MCMCModel, s::RWM) = MCMCTask(Task(() -> RWMTask(model, s)), model)

# RWM sampling
function RWMTask(model::MCMCModel, sampler::MCMCSampler)
	local pars, proposedPars
	local logTarget, proposedLogTarget

	#  Task reset function
	function reset(resetPars::Vector{Float64})
		proposedPars = copy(resetPars)
		proposedLogTarget = model.eval(proposedPars)
	end
	# hook inside Task to allow remote resetting
	task_local_storage(:reset, reset) 

	# initialization
	proposedPars = copy(model.init)
	proposedLogTarget = model.eval(proposedPars)
	assert(isfinite(proposedLogTarget), "Initial values out of model support, try other values")

	while true
		pars = copy(proposedPars)
		proposedPars += randn(model.size) * model.scale

 		logTarget, proposedLogTarget = proposedLogTarget, model.eval(proposedPars) 

		if rand() > exp(proposedLogTarget - logTarget) # roll back if rejected
			proposedLogTarget, proposedPars = logTarget, pars
		end

		produce(MCMCSample(proposedPars, proposedLogTarget, pars, logTarget))
	end
end

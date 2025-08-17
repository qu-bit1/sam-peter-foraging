# load packages
require(R.matlab)
require(nloptr)
require(beeswarm)

# data directory
cdir = getwd()
datadir = paste(cdir, 'data', sep = '/')
codedir = paste(cdir, 'code_analysis', 'Fig5', sep = '/')
# load externally specified functions (see according scripts)
compute_averages = dget(paste(codedir, 'compute_averages.R', sep = '/'))
fit_regressions = dget(paste(codedir, 'fit_regressions.R', sep = '/'))
write_modelresults = dget(paste(codedir, 'write_modelresults.R', sep = '/'))
write_modelpredictions = dget(paste(codedir, 'write_modelpredictions.R', sep = '/'))

# define participant information, also which ones to exclude
exclude= c(12, 33, 43, 44, 50, 54, 58, 61, 68, 70)
subjs=c(1:70)[!(c(1:70) %in% exclude)]
nsubjs=length(subjs)

# basic variables
nblocks = 4
nconds = 2
nmodels = 4

# setting for the fitting of the "outer" parameters
opts = list('algorithm'='NLOPT_GN_DIRECT_L', # NLOPT_LN_COBYLA NLOPT_GN_DIRECT_L
	'maxeval' = 250,
	'tol_rel' = 1e-1)

## starting params and bounds for initial value (s), alpha and alpha0
x0 = c(75, 0.1, 0.1)
lb = c(50, 0, 0)
ub = c(100, 0.75, 0.75)

# set up logistics model expressions that will later be passed to "fit_regressions"
models = list(NA, NA, NA, NA, NA, NA)
depvar = 'status'
# global model
cvars = c('R', 'avgR')
models[[1]] = as.formula(paste(depvar, paste(cvars, collapse = " + "), sep = " ~ "))
# global + local value model
cvars = c('R', 'avgR', 'Rmax')
models[[2]] = as.formula(paste(depvar, paste(cvars, collapse = " + "), sep = " ~ "))
# global + local RR(S) model
cvars = c('R', 'avgR', 'avgRmax')
models[[3]] = as.formula(paste(depvar, paste(cvars, collapse = " + "), sep = " ~ "))
# global + local RR(D) model
cvars = c('R', 'avgR', 'dynAvgRmax')
models[[4]] = as.formula(paste(depvar, paste(cvars, collapse = " + "), sep = " ~ "))

# additional models not reported in paper
cvars = c('R', 'avgR', 'avgRmax', 'tstop')
models[[5]] = as.formula(paste(depvar, paste(cvars, collapse = " + "), sep = " ~ "))
cvars = c('R', 'avgR', 'dynAvgRmax', 'tstop')
models[[6]] = as.formula(paste(depvar, paste(cvars, collapse = " + "), sep = " ~ "))
cvars = c('R', 'avgR', 'avgRmax','Rmax')
models[[7]] = as.formula(paste(depvar, paste(cvars, collapse = " + "), sep = " ~ "))
cvars = c('R', 'avgR', 'avgRmax', 'dynAvgRmax')
models[[8]] = as.formula(paste(depvar, paste(cvars, collapse = " + "), sep = " ~ "))
cvars = c('R', 'avgR', 'avgRmax','dynAvgRmax','Rmax')
models[[9]] = as.formula(paste(depvar, paste(cvars, collapse = " + "), sep = " ~ "))

allvars = c('(Intercept)', 'R', 'avgR', 'Rmax', 'avgRmax', 'dynAvgRmax', 'tstop')

# auxilliary function that will regression model fit with a fixed set of outer parameters
eval_fits = function(res, ccond=ccond, ccmodel=ccmodel) {
	# p stores the outer parameters
	p = NULL
	p$initval = res$solution[1]
	p$alpha = res$solution[2]
	p$alpha0 = res$solution[3]
	cmod = fit_regressions(cdat, ccond, ccmodel, p)
	return(cmod)
}

# auxilliary function that will return the neg log likelihood for a model (the logistic model), given its parameters
model_LL = function(params, ccond = ccond, ccmodel = ccmodel) {
	# p stores the outer parameters
	p = NULL
	p$initval = params[1]
	p$alpha = params[2]
	p$alpha0 = params[3]
	cmod = fit_regressions(cdat, ccond, ccmodel, p)
	LL = -logLik(cmod[[1]])[[1]]
	return(LL)
}

# initilise data frame to store results
modelresults.df = data.frame(ID = rep(NA, nsubjs*nconds*nmodels), COND = rep(NA, nsubjs*nconds*nmodels), MODEL = rep(NA, nsubjs*nconds*nmodels), LL = rep(NA, nsubjs*nconds*nmodels), R2adj = rep(NA, nsubjs*nconds*nmodels))
modelresults.df$INITVAL = modelresults.df$ALPHA = modelresults.df$ALPHA0 = modelresults.df$DF = modelresults.df$AIC = modelresults.df$BIC = NA
for (ccoef in 1:length(allvars)) {modelresults.df[allvars[ccoef]] = NA}
# initilise data frame to store model predictions
modelpredictions.df = data.frame(RNZ=NA)
cvars = c('RNZ', 'avgRNZ', 'avgR1NZ', 'avgR2NZ', 'avgRmeanNZ', 'avgRmaxNZ', 'RmeanNZ', 'RmaxNZ', 'dynAvgR1NZ','dynAvgR2NZ','dynAvgRmeanNZ','dynAvgRmaxNZ', 'REPNZ', 'tstopNZ','R', 'avgR', 'avgR1', 'avgR2', 'avgRmean', 'avgRmax', 'Rmean', 'Rmax', 'dynAvgR1','dynAvgR2','dynAvgRmean','dynAvgRmax', 'REP', 'patchevent', 'tstop', 'tstart', 'status', 'tstart2', 'likelihood', 'ID', 'COND', 'MODEL')
for (cvar in 1:length(cvars)) {modelpredictions.df[cvars[cvar]] = NA}
# initilise array of lists to store glm objects
allglms = array(list(), dim = c(nsubjs, nconds, nmodels))

# loop over subjects
cat('Start fitting procedure. Printout will show AICs for each participant separately per model/condition \n**********************************************************\n')
for (csub in 1:nsubjs) {
	cat(paste('Fitting Sub ', sprintf("%02d", subjs[csub]), ': ', sep = ''))
	# get data of current participant
  cdat = read.table(paste(datadir,  '/sub', subjs[csub], '_data.csv', sep = ''), header = TRUE, sep = ',')
	# exclude rows in data file that do not reflect choices
	cdat = subset(cdat, cdat$exploit_phase_key %in% c('s', 'space', 'N/A'))
	# loop over conditions (forced vs free)
	for (ccond in 1:nconds) {
		cat(paste('[',c('forced', 'free')[ccond], '] ', sep = ''))
		# loop over models
		for (cmodel in 1:nmodels) {
			# set counter
			ct = (csub-1)*nconds*nmodels + (ccond-1)*nmodels + cmodel
			# select model
			ccmodel = models[[cmodel]]
			# fit model
			cfit = nloptr(x0=x0, eval_f=model_LL, lb = lb, ub = ub, ccond = ccond, ccmodel = ccmodel, opts = opts)
			# evaluate fitted model
			cresults = eval_fits(cfit, ccond, ccmodel)
			# store glm object
			allglms[csub, ccond, cmodel][[1]] = cresults[[1]]
			cglm = cresults[[1]]
			# store predictions & parameters
			cpreds.df = cresults[[2]]
			modelresults.df = write_modelresults(cglm, ccond, cmodel, modelresults.df, ct)
			modelpredictions.df = write_modelpredictions(cpreds.df, cglm, ccond, cmodel, modelpredictions.df)
			cat(paste('M', cmodel, ':', sprintf("%03d", round(modelresults.df$AIC[ct])), ' - ', sep = ''))
		}
	}
	cat('Done!\n')
}

modelpredictions.df = modelpredictions.df[-1,]
save(modelresults.df, file = 'modelresults.Rdata')
save(modelpredictions.df, file = 'modelpredictions.Rdata')
save(allglms, file = 'allglms.Rdata')

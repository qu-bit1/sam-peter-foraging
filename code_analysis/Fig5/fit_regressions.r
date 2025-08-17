function(cdat, ccond, model, params) {
  # takes data cdat and computes the reward rate averages depending on the current set of parameters, params
  cdat = compute_averages(cdat, params)

  # now loop over blocks of the same condition (forced vs free)
  blkmap = tapply(cdat$blk_type, cdat$blk_number, mean)
  cblkorder = which(blkmap == ccond)
  cdf = ccdf = list(NA, NA)
  for (cblock in 1:2){
    # get data
    ccdat = subset(cdat, cdat$blk_number == cblkorder[cblock])
    # make claen data frame containing all variables the logistic regression will need, i.e. the rewards and newly calcualted reward estimates etc
    cdf[[cblock]] = data.frame(
      avgR = ccdat$avgR,
      R = ccdat$actual_rew_gain,
      avgR1 = ccdat$avgR_A1,
      avgR2 = ccdat$avgR_A2,
      avgRmean = ccdat$avgR_Amean,
      avgRmax = ccdat$avgR_Amax,
      Rmean = ccdat$R_Amean,
      Rmax = ccdat$R_Amax,
      dynAvgR1 = ccdat$dynAvgR_A1,
      dynAvgR2 = ccdat$dynAvgR_A2,
      dynAvgRmean =ccdat$dynAvgR_Amean,
      dynAvgRmax = ccdat$dynAvgR_Amax,
      REP = ccdat$replen)
    # now add variables that are specific for each patch visit: how many times in current patch since entering (tstart)?
    # the how manieth patch event in that block (patchevent)?
    # did the participant decide to leave (status)?
    cdf[[cblock]]$status = cdf[[cblock]]$tstart = cdf[[cblock]]$tstop = cdf[[cblock]]$patchevent = NA
    # get all starts of patch events
    patchevents = c(1, which(ccdat$choices == 2) + 1)
    clengths = diff(patchevents)
    # loop over patch events to do counting etc.
    for (i in 1:(length(patchevents)-1)) {
      cidx = patchevents[i]:(patchevents[i+1]-1) # time in patch
      cdf[[cblock]]$status[cidx] = c(rep(0, clengths[i]-1), 1)
      cdf[[cblock]]$tstart[cidx] = cidx - min(cidx) + 1
      cdf[[cblock]]$tstop[cidx] = cdf[[cblock]]$tstart[cidx] + 1
      cdf[[cblock]]$patchevent[cidx] = i
    }
    # because we are considering the reward (rates) on the previous time step, shift the status variable
    cdf[[cblock]]$status[1:(length(cdf[[cblock]]$R)-1)] = cdf[[cblock]]$status[2:(length(cdf[[cblock]]$R)-0)]
    # also shift the counting variable (depreciated)
    cdf[[cblock]]$tstart2 = cdf[[cblock]]$tstart
    cdf[[cblock]]$tstart2[1:(length(cdf[[cblock]]$R)-1)] = cdf[[cblock]]$tstart2[2:(length(cdf[[cblock]]$R)-0)]
    # exclude first event in patch (subj had no choice other than to sample)
    cdf[[cblock]] = subset(cdf[[cblock]], cdf[[cblock]]$tstart2 > 1)
    # exclude last patch event (i.e. last patch visited in block)
    cdf[[cblock]] = subset(cdf[[cblock]], cdf[[cblock]]$patchevent < max(cdf[[cblock]]$patchevent, na.rm = TRUE))
    # make subset with only leave choices (not needed!)
    ccdf[[cblock]] = subset(cdf[[cblock]], cdf[[cblock]]$status == 1)
  }
  # combine data across blocks from same condition
  ccdf1 = rbind(ccdf[[1]], ccdf[[2]])
  cdf1 = rbind(cdf[[1]], cdf[[2]])

  # zscore variable for logistic regression
  cdf1$avgRNZ = cdf1$avgR
  cdf1$RNZ = cdf1$R
  cdf1$avgR1NZ = cdf1$avgR1
  cdf1$avgR2NZ = cdf1$avgR2
  cdf1$avgRmeanNZ = cdf1$avgRmean
  cdf1$avgRmaxNZ = cdf1$avgRmax
  cdf1$RmeanNZ = cdf1$Rmean
  cdf1$RmaxNZ = cdf1$Rmax
  cdf1$dynAvgR1NZ = cdf1$dynAvgR1
  cdf1$dynAvgR2NZ = cdf1$dynAvgR2
  cdf1$dynAvgRmaxNZ = cdf1$dynAvgRmax
  cdf1$dynAvgRmeanNZ = cdf1$dynAvgRmean
  cdf1$REPNZ = cdf1$REP
  cdf1$tstopNZ = cdf1$tstop

  # z scoring data
  cdf1$avgR = scale(cdf1$avgR)
  cdf1$R = scale(cdf1$R)
  cdf1$avgR1 = scale(cdf1$avgR1)
  cdf1$avgR2 = scale(cdf1$avgR2)
  cdf1$avgRmean = scale(cdf1$avgRmean)
  cdf1$avgRmax = scale(cdf1$avgRmax)
  cdf1$Rmean = scale(cdf1$Rmean)
  cdf1$Rmax = scale(cdf1$Rmax)
  cdf1$dynAvgR1 = scale(cdf1$dynAvgR1)
  cdf1$dynAvgR2 = scale(cdf1$dynAvgR2)
  cdf1$dynAvgRmax = scale(cdf1$dynAvgRmax)
  cdf1$dynAvgRmean = scale(cdf1$dynAvgRmean)
  cdf1$REP = scale(cdf1$REP)
  cdf1$tstop = scale(cdf1$tstop)

  # fit model logistic regression model
  cmod = glm(model, data = cdf1, family=binomial("logit"), maxit = 200)
  return(list(cmod, cdf1))
}

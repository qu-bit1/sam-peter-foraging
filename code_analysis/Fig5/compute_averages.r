function(cdat, params) {
    # get vector of rewards
    allR = cdat$actual_rew_gain
    # get vector of choices
    allK = cdat$decisionType
    # find starts of new blocks
    blockstarts = c(0, which(diff(cdat$blk_number) == 1), length(allR))
    # initialize variables in cdat that will be filled with newly computed averages etc
    cdat$avgR = cdat$avgRLeft = cdat$avgRTop = cdat$avgRRight = cdat$arrRLeft = cdat$arrRTop = cdat$arrRRight = cdat$dynRLeft = cdat$dynRTop = cdat$dynRRight = NA
    # loop over blocks
    for (cblock in 1:4) {
        # get trial index for current block and subset rewards/actions
        cidx = (blockstarts[cblock]+1):blockstarts[cblock+1]
        cR = allR[cidx]
        cK = allK[cidx]
        # get indices when subject arrived on a new patch, grab rewards on arrival
        carrivals = which(cK[2:length(cK)] == 2 & cK[1:(length(cK)-1)] == 0) + 1
        cRivals = cR[carrivals]
        cvec = cR*0
        # compute average reward over all patches. Uses different learning rate for stay (alpha) vs leave (alpha0) decisions
        cvec[1] = params$initval
        for (i in 2:length(cidx)) {
          if (cK[i] == 2) {
            cvec[i] = cvec[i-1] + params$alpha*(cR[i] - cvec[i-1])
          } else if (cK[i] == 3 | cK[i] == 1) {
            cvec[i] = cvec[i-1] + params$alpha0*(cR[i] - cvec[i-1])
          } else if (cK[i] == 0) {
            cvec[i] = cvec[i-1]
          }
        }
        cdat$avgR[cidx] = cvec

        # compute patch specific average rewards and dynamic rewards
        for (ccond in 1:3){
          # get indices of trial in current block and patch, grab rewards and choices
          ccidx = intersect(which(cdat$currentPatchPosition == ccond),cidx)
          cR = allR[ccidx]
          cK = allK[ccidx]
          cvec = cR*0

          # first, compute dynamic reward rate that grows towards the last experienced reward upon arrival
          ccarrivals = carrivals[cidx[carrivals] %in% ccidx]
          dynR = cidx * 0
          dynR[1:ccarrivals[1]] = params$initval
          for (arrival in 1:length(ccarrivals)) {
            dynR[ccarrivals[arrival]:(c(ccarrivals, length(cidx))[arrival+1] - 1)] = cRivals[cidx[carrivals] %in% ccidx][arrival]
          }
          dynR[length(dynR)] = dynR[length(dynR)-1]

          # patch specific reward
          cvec[1] = params$initval
          for (i in 2:length(ccidx)) {
            if (cK[i] == 2) {
              cvec[i] = cvec[i-1] + params$alpha*(cR[i] - cvec[i-1])
            } else if (cK[i] == 3 | cK[i] == 1) {
              cvec[i] = cvec[i-1] + params$alpha0*(cR[i] - cvec[i-1])
            } else if (cK[i] == 0) {
              cvec[i] = cvec[i-1]
            }
          }
          # store it all in cdat
          if (ccond == 1) {
            cdat$avgRLeft[ccidx] = cvec
            cdat$arrRLeft[cidx] = dynR
          } else if (ccond == 2) {
            cdat$avgRTop[ccidx] = cvec
            cdat$arrRTop[cidx] = dynR
          } else if (ccond == 3) {
            cdat$avgRRight[ccidx] = cvec
            cdat$arrRRight[cidx] = dynR
          }
        }
    }
    # Store it all in cdat. But first:

    # fix for first value in block in patch specific reward rates
    cstarts = unique(which(cdat$actions_remaining==198))-3
    for (i in 1:4) {
      cdat$avgRLeft[cstarts[i]] = cdat$avgRTop[cstarts[i]] = cdat$avgRRight[cstarts[i]] = max(cdat$avgRLeft[cstarts[i]], cdat$avgRTop[cstarts[i]], cdat$avgRRight[cstarts[i]], na.rm = TRUE)
    }

    # fill empty values in average reward rate (before patch was ever visited) with value from beginning
    for (i in 2:length(cdat$avgRLeft)) {
      if (is.na(cdat$avgRLeft[i])) {
        cdat$avgRLeft[i] = cdat$avgRLeft[i-1]
      }
      if (is.na(cdat$avgRTop[i])) {
        cdat$avgRTop[i] = cdat$avgRTop[i-1]
      }
      if (is.na(cdat$avgRRight[i])) {
        cdat$avgRRight[i] = cdat$avgRRight[i-1]
      }
    }

    # get and store dynamic reward rates, based on arrival rewards calculated above
    for (cblock in 1:4) {
      cidx = (blockstarts[cblock]+1):blockstarts[cblock+1]
      cR = allR[cidx]
      cK = allK[cidx]
      cP = cdat$currentPatchPosition[cidx]
      cP[length(cP)-1] = cP[length(cP)-2]
      cP[length(cP)-0] = cP[length(cP)-1]
      cvec = rbind(cdat$avgRLeft[cidx], cdat$avgRTop[cidx], cdat$avgRRight[cidx])
      cvec_u = rbind(cdat$arrRLeft[cidx], cdat$arrRTop[cidx], cdat$arrRRight[cidx])

      for (i in 2:length(cidx)) {
        if (cK[i] == 2) {
          # update the avergae of the current patch normally
          cvec[cP[i], i] = cvec[cP[i], i-1] + params$alpha*(cR[i] - cvec[cP[i], i-1])
          # update the averges of the other pacthes towards their last arrival rate
          cvec[setdiff(1:3, cP[i])[1], i] = cvec[setdiff(1:3, cP[i])[1], i-1] + params$alpha*(cvec_u[setdiff(1:3, cP[i])[1], i] - cvec[setdiff(1:3, cP[i])[1], i-1])
          cvec[setdiff(1:3, cP[i])[2], i] = cvec[setdiff(1:3, cP[i])[2], i-1] + params$alpha*(cvec_u[setdiff(1:3, cP[i])[2], i] - cvec[setdiff(1:3, cP[i])[2], i-1])

        } else if (cK[i] == 3 | cK[i] == 1) {
          cvec[cP[i], i] = cvec[cP[i], i-1] + params$alpha0*(cR[i] - cvec[cP[i], i-1])
          cvec[setdiff(1:3, cP[i])[1], i] = cvec[setdiff(1:3, cP[i])[1], i-1] + params$alpha*(cvec_u[setdiff(1:3, cP[i])[1], i] - cvec[setdiff(1:3, cP[i])[1], i-1])
          cvec[setdiff(1:3, cP[i])[2], i] = cvec[setdiff(1:3, cP[i])[2], i-1] + params$alpha*(cvec_u[setdiff(1:3, cP[i])[2], i] - cvec[setdiff(1:3, cP[i])[2], i-1])
        } else if (cK[i] == 0) {
          cvec[,i] = cvec[,i-1]
        }
      }
      cdat$dynRLeft[cidx] = cvec[1,]
      cdat$dynRTop[cidx] = cvec[2,]
      cdat$dynRRight[cidx] = cvec[3,]
    }

    # final fixed to data frame
    cdat = subset(cdat, cdat$exploit_phase_key %in% c('s', 'space'))

    # choices
    cdat$choices = NA
    cdat$choices[cdat$exploit_phase_key == 's'] = 2
    cdat$choices[cdat$exploit_phase_key == 'space'] = 1
    cdat$RR = 0

    # replenishment rate of currently visited patch
    cpatch = cdat$currentPatchPosition
    cdat$replen = cbind(cdat$patchReplenishLeft, cdat$patchReplenishTop, cdat$patchReplenishRight)[cbind(1:length(cpatch), cpatch)]

    # dynamically find which are the not visited patches, and store their mean/max in variables Amax and Amean)
    cmat = cbind(cdat$patchValueLeft, cdat$patchValueTop, cdat$patchValueRight)
    cdat$R_A1 = cmat[cbind(1:length(cpatch), sapply(cpatch, function(x) setdiff(1:3, x)[1]))]
    cdat$R_A2 = cmat[cbind(1:length(cpatch), sapply(cpatch, function(x) setdiff(1:3, x)[2]))]
    cdat$R_Amax = apply(cbind(cdat$R_A1, cdat$R_A2), 1, max)
    cdat$R_Amean = apply(cbind(cdat$R_A1, cdat$R_A2), 1, mean)

    # same as above, just for reward rates (the averages)
    cmat = cbind(cdat$avgRLeft, cdat$avgRTop, cdat$avgRRight)
    cdat$avgR_A1 = cmat[cbind(1:length(cpatch), sapply(cpatch, function(x) setdiff(1:3, x)[1]))]
    cdat$avgR_A2 = cmat[cbind(1:length(cpatch), sapply(cpatch, function(x) setdiff(1:3, x)[2]))]
    cdat$avgR_Amax = apply(cbind(cdat$avgR_A1, cdat$avgR_A2), 1, max)
    cdat$avgR_Amean = apply(cbind(cdat$avgR_A1, cdat$avgR_A2), 1, mean)

    # same as above for dynamic rewards 
    cmat = cbind(cdat$dynRLeft, cdat$dynRTop, cdat$dynRRight)
    cdat$dynAvgR_A1 = cmat[cbind(1:length(cpatch), sapply(cpatch, function(x) setdiff(1:3, x)[1]))]
    cdat$dynAvgR_A2 = cmat[cbind(1:length(cpatch), sapply(cpatch, function(x) setdiff(1:3, x)[2]))]
    cdat$dynAvgR_Amax = apply(cbind(cdat$dynAvgR_A1, cdat$dynAvgR_A2), 1, max)
    cdat$dynAvgR_Amean = apply(cbind(cdat$dynAvgR_A1, cdat$dynAvgR_A2), 1, mean)

    return(cdat)
}

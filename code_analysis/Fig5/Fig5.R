# Code to plot the model results for free and forced choice conditions (Figure 5)

###### load packages ------
require(R.matlab)
require(beeswarm)
require(RColorBrewer)

# settings
Dir = getwd()
plotDir = 'figures'
nsubjs = 60

# load relevant dataframes
load('model_data/modelpredictions.Rdata')
load('model_data/modelresults.Rdata')
load('model_data/allglms.Rdata')

# to look at results from all 70 participants
#load('model_data/data_70subs/modelresults.Rdata') 
#load('model_data/data_70subs/modelpredictions.Rdata')
#load('model_data/data_70subs/allglms.Rdata')

# create a function for adding shadows
se_shadows<-function(x, y, se, ccol='#66666666', border = NA) {
	# adds se shadows to data x
	polygon(c(x, rev(x)), c(y + se, rev(y - se)), col = ccol, border = border)
}
###### set colours ------
ccols = cbind(c(rgb(0.6196, 0.0039, 0.2588), rgb(0.1974, 0.5129, 0.7403)), c(rgb(0.6196, 0.0039, 0.2588, 0.8), rgb(0.1974, 0.5129, 0.7403, 0.8)))

modelpredictions.df$PATCHTYPE = factor(c('slow', 'medium', 'fast'))
modelpredictions.df$PATCHTYPE[modelpredictions.df$REP < -0.75] = 'slow'
modelpredictions.df$PATCHTYPE[modelpredictions.df$REP > -0.75 & modelpredictions.df$REP <= 0.75] = 'medium'
modelpredictions.df$PATCHTYPE[modelpredictions.df$REP > 0.75] = 'fast'

# get AICs for each model, condition and participant
AICs = tapply(modelresults.df$AIC, list(modelresults.df$MODEL, modelresults.df$COND, modelresults.df$ID), mean)
dim(AICs)
AIC_samp_mean=tapply(modelresults.df$AIC, list(modelresults.df$MODEL, modelresults.df$COND), mean)
BIC_samp_mean=tapply(modelresults.df$BIC, list(modelresults.df$MODEL, modelresults.df$COND), mean)

# get AIC scores relative to the global model (used as a baseline)
cbase = AICs*0
for (i in 1:4) {cbase[i,,] = AICs[1,,]}
AICs_rel = cbase-AICs
AICs_rel = AICs_rel[2:4,,]
cmeans = apply(AICs_rel, c(1, 2), mean)
csds = apply(AICs_rel, c(1, 2), std.error)

# generate plot of AIC differences between each global+ model and the global model in the forced choice condition
pdf(file.path(Dir, plotDir, 'AIC_diffs_forced.pdf'), width = 4.2, height = 5.2)
k = barplot(cmeans[,1], ylim = c(-71, 71), col = hcl.colors(5, 'Oranges')[2:4], border = NA, cex.axis = 1.1, cex.lab = 1.25, ylab = '', names.arg=expression(atop('MaxValue',phantom('(Dynamic)')), atop('MaxRR'[S],'(Static)'), atop('MaxRR'[D],'(Dynamic)')))
abline(h = 0, col = 1, lwd = 2)
beeswarm(t(AICs_rel[,1,])~matrix(1:3, nsubjs, 3, byrow = TRUE), at = k, cex = 0.8, add = TRUE, pch = 21, col = 1, bg = hcl.colors(5, 'Oranges', alpha = 0.5)[2:4])
title(ylab = 'AIC (Global-Competitor Model)', line=2.5, cex.lab=1.25)
dev.off()

# generate plot of AIC differences between each global+ model and the global model in the free choice condition
pdf(file.path(Dir, plotDir, 'AIC_diffs_free.pdf'), width = 4.2, height = 5.2)
k = barplot(cmeans[,2], ylim = c(-71, 71), col = hcl.colors(5, 'Blues')[2:4], border = NA, cex.axis = 1.1, cex.lab = 1.25, ylab = '', names.arg=expression(atop('MaxValue',phantom('(Dynamic)')), atop('MaxRR'[S],'(Static)'), atop('MaxRR'[D],'(Dynamic)')))
abline(h = 0, col = 1, lwd = 2)
beeswarm(t(AICs_rel[,2,])~matrix(1:3, nsubjs, 3, byrow = TRUE), at = k, cex = 0.8, add = TRUE, pch = 21, col = 1, bg = hcl.colors(5, 'Blues', alpha = 0.5)[2:4])
title(ylab = 'AIC (Global-Competitor Model)', line=2.5, cex.lab=1.25)
dev.off()

# generate probability of leaving time course for the winning model (forced choice)
pdf(file.path(Dir, plotDir,'timecourses_forced.pdf'), width = 4.2, height = 4.2)
cmat = tapply(modelpredictions.df$likelihood, list(modelpredictions.df$patchevent, modelpredictions.df$COND, modelpredictions.df$PATCHTYPE, modelpredictions.df$ID, modelpredictions.df$MODEL), function(x) c(rev(x), rep(NA, 65-length(x))))
cmat = apply(cmat, c(1, 2, 3, 4, 5), function(x) ifelse(rep(length(unlist(x)) == 0, 65), rep(NA, 65), unlist(x)))
cmat2 = apply(cmat, c(3, 4, 5, 6), function(x) rowMeans(x, na.rm = TRUE))
cmat2 = apply(cmat2, c(1, 2, 4, 5), mean, na.rm = TRUE)[5:1,,,]
cmeans = apply(cmat2, c(1, 2, 4), mean, na.rm = TRUE)[,1,]
modelsds = apply(cmat2, c(1, 2, 4), function(x) sd(x, na.rm = TRUE)/sqrt(sum(!is.na(x))))[,1,]

plot(1:5, cmeans[,3], type = 'o', lwd = 2, bty = 'n', col = hcl.colors(5, 'Oranges')[3], lty = 1, pch = 16, cex.lab = 1.25, cex.axis = 1.25, ylab = '', xlab = 'Choice', xaxt = 'n', ylim = c(0,0.8))
for (i in 3) {
  matlines(cmat2[,1,,i], lty = 1, col = hcl.colors(5, 'Oranges', alpha = 0.5)[3], lwd = 0.25, type = 'l')
}
lines(1:5, cmeans[,3], type = 'o', lwd = 3, col = hcl.colors(5, 'Oranges')[3], lty = 1, pch = 21, bg = 'white')
axis(1, at = 1:5, labels = c('-4', '-3','-2', '-1', 'Leave'), cex.axis = 1.1)
title(ylab = expression('p(Choice | MaxRR'[S]*')'), line=2.5, cex.lab=1.25)
dev.off()

# generate probability of leaving time course for the winning model (free choice)
pdf(file.path(Dir, plotDir,'timecourses_free.pdf'), width = 4.2, height = 4.2)
cmat = tapply(modelpredictions.df$likelihood, list(modelpredictions.df$patchevent, modelpredictions.df$COND, modelpredictions.df$PATCHTYPE, modelpredictions.df$ID, modelpredictions.df$MODEL), function(x) c(rev(x), rep(NA, 65-length(x))))
cmat = apply(cmat, c(1, 2, 3, 4, 5), function(x) ifelse(rep(length(unlist(x)) == 0, 65), rep(NA, 65), unlist(x)))
cmat2 = apply(cmat, c(3, 4, 5, 6), function(x) rowMeans(x, na.rm = TRUE))
cmat2 = apply(cmat2, c(1, 2, 4, 5), mean, na.rm = TRUE)[5:1,,,]
cmeans = apply(cmat2, c(1, 2, 4), mean, na.rm = TRUE)[,2,]
modelsds = apply(cmat2, c(1, 2, 4), function(x) sd(x, na.rm = TRUE)/sqrt(sum(!is.na(x))))[,2,]
plot(1:5, cmeans[,3], type = 'o', lwd = 2, bty = 'n', col = hcl.colors(5, 'Blues')[3], lty = 1, pch = 16, cex.lab = 1.25, cex.axis = 1.25, ylab = '', xlab = 'Choice', xaxt = 'n', ylim = c(0,0.8))
for (i in 3) {
  matlines(cmat2[,1,,i], lty = 1, col = hcl.colors(5, 'Blues', alpha = 0.5)[3], lwd = 0.25, type = 'l')
}
lines(1:5, cmeans[,3], type = 'o', lwd = 3, col = hcl.colors(5, 'Blues')[3], lty = 1, pch = 21, bg = 'white')
axis(1, at = 1:5, labels = c('-4', '-3','-2', '-1', 'Leave'), cex.axis = 1.1)
title(ylab = expression('p(Choice | MaxRR'[S]*')'), line=2.5, cex.lab=1.25)
dev.off()

# generate the difference in probability of leaving time between winning model the global model (free choice)
pdf(file.path(Dir, plotDir,'timecourses_diffs_free.pdf'), width = 4.2, height = 4.2)
cmat = tapply(modelpredictions.df$likelihood, list(modelpredictions.df$patchevent, modelpredictions.df$COND, modelpredictions.df$PATCHTYPE, modelpredictions.df$ID, modelpredictions.df$MODEL), function(x) c(rev(x), rep(NA, 65-length(x))))
cmat = apply(cmat, c(1, 2, 3, 4, 5), function(x) ifelse(rep(length(unlist(x)) == 0, 65), rep(NA, 65), unlist(x)))
cmat2 = apply(cmat, c(3, 4, 5, 6), function(x) rowMeans(x, na.rm = TRUE))
cmat2 = apply(cmat2, c(1, 2, 4, 5), mean, na.rm = TRUE)[5:1,,,]
X12 = apply(cmat2[,2,,2], 2, function(x) c(1, 1, 1, 1, 0) - x*c(1, 1, 1, 1, -1)) - apply(cmat2[,2,,1], 2, function(x) c(1, 1, 1, 1, 0) - x*c(1, 1, 1, 1, -1))
X13 = apply(cmat2[,2,,3], 2, function(x) c(1, 1, 1, 1, 0) - x*c(1, 1, 1, 1, -1)) - apply(cmat2[,2,,1], 2, function(x) c(1, 1, 1, 1, 0) - x*c(1, 1, 1, 1, -1))
X14 = apply(cmat2[,2,,4], 2, function(x) c(1, 1, 1, 1, 0) - x*c(1, 1, 1, 1, -1)) - apply(cmat2[,2,,1], 2, function(x) c(1, 1, 1, 1, 0) - x*c(1, 1, 1, 1, -1))
cmeans = cbind(apply(X12, c(1),  mean, na.rm = TRUE), apply(X13, c(1),  mean, na.rm = TRUE), apply(X14, c(1),  mean, na.rm = TRUE))
csds = cbind(apply(X12, c(1), function(x) std.error(x)), apply(X13, c(1), function(x) std.error(x)),  apply(X14, c(1), function(x) std.error(x)))

matplot(1:5, cmeans[,2], type = 'o', lwd = 3, bty = 'n', col = hcl.colors(5, 'Blues')[3], lty = 1, pch = 21, bg = 'white', cex.lab = 1.25, cex.axis = 1.25, ylab = '', xlab = 'Choice', xaxt = 'n', ylim = c(-0.1,0.1))
abline(h = 0)
matlines(X13, lty = 1, col = hcl.colors(5, 'Blues', alpha = 0.5)[3], lwd = 0.25, type = 'l')
axis(1, at = 1:5, labels = c('-4', '-3','-2', '-1', 'Leave'), cex.axis = 1.25,cex.lab = 1.25)
title(ylab = expression('p(Choice | MaxRR'[S]*') - p(Choice | Global)'), line=2.5, cex.lab=1.25)
dev.off()

# generate the difference in probability of leaving time between winning model the global model (forced choice)
pdf(file.path(Dir, plotDir,'timecourses_diffs_forced.pdf'), width = 4.2, height = 4.2)
cmat = tapply(modelpredictions.df$likelihood, list(modelpredictions.df$patchevent, modelpredictions.df$COND, modelpredictions.df$PATCHTYPE, modelpredictions.df$ID, modelpredictions.df$MODEL), function(x) c(rev(x), rep(NA, 65-length(x))))
cmat = apply(cmat, c(1, 2, 3, 4, 5), function(x) ifelse(rep(length(unlist(x)) == 0, 65), rep(NA, 65), unlist(x)))
cmat2 = apply(cmat, c(3, 4, 5, 6), function(x) rowMeans(x, na.rm = TRUE))
cmat2 = apply(cmat2, c(1, 2, 4, 5), mean, na.rm = TRUE)[5:1,,,]
X12 = apply(cmat2[,1,,2], 2, function(x) c(1, 1, 1, 1, 0) - x*c(1, 1, 1, 1, -1)) - apply(cmat2[,1,,1], 2, function(x) c(1, 1, 1, 1, 0) - x*c(1, 1, 1, 1, -1))
X13 = apply(cmat2[,1,,3], 2, function(x) c(1, 1, 1, 1, 0) - x*c(1, 1, 1, 1, -1)) - apply(cmat2[,1,,1], 2, function(x) c(1, 1, 1, 1, 0) - x*c(1, 1, 1, 1, -1))
X14 = apply(cmat2[,1,,4], 2, function(x) c(1, 1, 1, 1, 0) - x*c(1, 1, 1, 1, -1)) - apply(cmat2[,1,,1], 2, function(x) c(1, 1, 1, 1, 0) - x*c(1, 1, 1, 1, -1))
cmeans = cbind(apply(X12, c(1),  mean, na.rm = TRUE), apply(X13, c(1),  mean, na.rm = TRUE), apply(X14, c(1),  mean, na.rm = TRUE))
csds = cbind(apply(X12, c(1), function(x) std.error(x)), apply(X13, c(1), function(x) std.error(x)),  apply(X14, c(1), function(x) std.error(x)))

matplot(1:5, cmeans[,2], type = 'o', lwd = 3, bty = 'n', col = hcl.colors(5, 'Oranges')[3], lty = 1, pch = 21, bg = 'white', cex.lab = 1.25, cex.axis = 1.25, ylab='', xlab = 'Choice', xaxt = 'n', ylim = c(-0.1,0.1))
abline(h = 0)
matlines(X13, lty = 1, col = hcl.colors(5, 'Oranges', alpha = 0.5)[3], lwd = 0.25, type = 'l')
axis(1, at = 1:5, labels = c('-4', '-3','-2', '-1', 'Leave'), cex.axis = 1.25,cex.lab = 1.25)
title(ylab = expression('p(Choice | MaxRR'[S]*') - p(Choice | Global)'), line=2.5, cex.lab=1.25)
dev.off()

# generate plots for leaving under the winning model as a function of time in patch and for each patch individually
cmat = tapply(modelpredictions.df$likelihood, list(modelpredictions.df$tstart, modelpredictions.df$COND, modelpredictions.df$PATCHTYPE, modelpredictions.df$ID, modelpredictions.df$MODEL), mean, na.rm = TRUE)[,,,,3]
modelmean = apply(cmat, c(1, 2, 3), mean, na.rm = TRUE)
modelsds = apply(cmat, c(1, 2, 3), function(x) sd(x, na.rm = TRUE)/sqrt(sum(!is.na(x))))

datamat = tapply(modelpredictions.df$status, list(modelpredictions.df$tstart, modelpredictions.df$COND, modelpredictions.df$PATCHTYPE, modelpredictions.df$ID), mean, na.rm = TRUE)
datamean = apply(datamat, c(1, 2, 3), mean, na.rm = TRUE)
datasds = apply(datamat, c(1, 2, 3), function(x) sd(x, na.rm = TRUE)/sqrt(sum(!is.na(x))))

pdf(file.path(Dir, plotDir,'timecourses_leave_forced.pdf'), width = 4.2, height = 4.2)
cX = matrix(c((2:7)-0.05, (2:7)+0.00, (2:7)+0.05), ncol = 3)
matplot(cX, datamean[1:6,1,], type = 'p', pch = 16, lty = 1, col = hcl.colors(5, 'viridis')[3:5], lwd = 2, ylim = c(0, 0.8), bty = 'n', cex.lab = 1.25, cex.axis = 1.25, ylab = '', xlab = 'Timestep in Patch')

for (i in 1:3) {
	se_shadows(cX[,i], modelmean[1:6,1,i], modelsds[1:6,1,i], ccol =  hcl.colors(5, 'viridis', alpha = 0.3)[i+2])
	points(cX[,i], datamean[1:6,1,i], pch = 16, col = 'white', cex = 0.5)
}
title(ylab = expression('p(Choice | MaxRR'[S]*')'), line=2.5, cex.lab=1.25)
names = c('Fast Patch', 'Medium Patch', 'Slow Patch')
legend("topleft", inset=0.01, legend=names, col=hcl.colors(5, 'viridis')[3:5],pch=19, box.col = ("white"),
       bg= ("white"), horiz=F)
dev.off()

pdf(file.path(Dir, plotDir,'timecourses_leave_free.pdf'), width = 4.2, height = 4.2)
cX = matrix(c((2:7)-0.05, (2:7)+0.00, (2:7)+0.05), ncol = 3)
matplot(cX, datamean[1:6,2,], type = 'p', pch = 16, lty = 1, col = hcl.colors(5, 'viridis')[3:5], lwd = 2, ylim = c(0, 0.8), bty = 'n', cex.lab = 1.25, cex.axis = 1.25, ylab = '', xlab = 'Timestep in Patch')

for (i in 1:3) {
	se_shadows(cX[,i], modelmean[1:6,2,i], modelsds[1:6,2,i], ccol =  hcl.colors(5, 'viridis', alpha = 0.3)[i+2])
	points(cX[,i], datamean[1:6,2,i], pch = 16, col = 'white', cex = 0.5)
}
title(ylab = expression('p(Choice | MaxRR'[S]*')'), line=2.5, cex.lab=1.25)
dev.off()

function(cglm, ccond, cmodel, modelresults.df, ct) {
  # function to store fitted parameters and model fits for each condition, modl and subject
  modelresults.df$ID[ct] = subjs[csub]
  modelresults.df$COND[ct] = c('forced', 'free')[ccond]
  modelresults.df$MODEL[ct] = cmodel
  modelresults.df$DF[ct] = unlist(summary(cglm))$df1 + 3 # plus 3 because of the three unseen outer parameters (2 learnig rates and 1 initial value)
  # fitted outer parameter
  modelresults.df$INITVAL[ct] = cfit$solution[1]
  modelresults.df$ALPHA[ct] = cfit$solution[2]
  modelresults.df$ALPHA0[ct] = cfit$solution[3]
  # neg model log likelihood
  modelresults.df$LL[ct] = -logLik(cglm)[[1]] #sum(unlist(lapply(cglm, function(x) -logLik(x)[[1]])))
  # to calculate BIC, adapt k to reflect log(n)
  cn = log(nobs(cglm))
  modelresults.df$BIC[ct] = extractAIC(cglm, k = cn)[2]
  modelresults.df$AIC[ct] = extractAIC(cglm)[2]
  # extract all beta coefficients from fitted glm and store
  ccoefs = coef(cglm)
  for (ccoef in 1:length(ccoefs)) {
    modelresults.df[names(ccoefs)[ccoef]][ct,1] = ccoefs[ccoef]
  }
  return(modelresults.df)
}

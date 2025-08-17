function(cpreds.df, cglm, ccond, cmodel, modelpredictions.df) {
  # this function takes the fitted glm object, extracts the predicted probabilities, and adds it to a data frame containing the subject choices, rewards etc.
  cps = predict(cglm, cpreds.df, type = 'response')
  cpreds.df$likelihood = cps
  cpreds.df$ID = subjs[csub]
  cpreds.df$COND = ccond
  cpreds.df$MODEL = cmodel
  modelpredictions.df = rbind(modelpredictions.df, cpreds.df)
  return(modelpredictions.df)
}

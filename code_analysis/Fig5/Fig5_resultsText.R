# Code to get the model results reported in the manuscript.

library(tidyverse)
library(psych)
library(data.table)

# load model results files
load('model_data/modelresults.Rdata')
load('model_data/modelpredictions.Rdata')
load('model_data/allglms.Rdata')

# to look at results from all 70 participants
#load('model_data/data_70subs/modelresults.Rdata') 
#load('model_data/data_70subs/modelpredictions.Rdata')
#load('model_data/data_70subs/allglms.Rdata')

# process model results to get differences between the models
model_diff <- modelresults.df %>% 
  group_by(ID, COND) %>%
  mutate(bic_2vs1 = BIC[MODEL == 1] - BIC[MODEL == 2],
         bic_3vs1 = BIC[MODEL == 1] - BIC[MODEL == 3],
         bic_4vs1 = BIC[MODEL == 1] - BIC[MODEL == 4],
         aic_2vs1 = AIC[MODEL == 1] - AIC[MODEL == 2],
         aic_3vs1 = AIC[MODEL == 1] - AIC[MODEL == 3],
         aic_4vs1 = AIC[MODEL == 1] - AIC[MODEL == 4],
         
         # which model is best based on BIC?
         best_modelBIC = ifelse((BIC[MODEL == 1] < BIC[MODEL == 2]) && (BIC[MODEL == 1] < BIC[MODEL == 3]) && (BIC[MODEL == 1] < BIC[MODEL == 4]), 1,
                             ifelse((BIC[MODEL == 2] < BIC[MODEL == 1]) && (BIC[MODEL == 2] < BIC[MODEL == 3]) && (BIC[MODEL == 2] < BIC[MODEL == 4]), 2,
                                  ifelse((BIC[MODEL == 3] < BIC[MODEL == 1]) && (BIC[MODEL == 3] < BIC[MODEL == 2]) && (BIC[MODEL == 3] < BIC[MODEL == 4]), 3, 4))),
         
         # which model is best based on AIC?
         best_modelAIC = ifelse((AIC[MODEL == 1] < AIC[MODEL == 2]) && (AIC[MODEL == 1] < AIC[MODEL == 3]) && (AIC[MODEL == 1] < AIC[MODEL == 4]), 1,
                                 ifelse((AIC[MODEL == 2] < AIC[MODEL == 1]) && (AIC[MODEL == 2] < AIC[MODEL == 3]) && (AIC[MODEL == 2] < AIC[MODEL == 4]), 2, 
                                    ifelse((AIC[MODEL == 3] < AIC[MODEL == 1]) && (AIC[MODEL == 3] < AIC[MODEL == 2]) && (AIC[MODEL == 3] < AIC[MODEL == 4]), 3, 4))),
         
         # which model is best within specific comparisons (BIC)?
         best_2vs1BIC = ifelse(BIC[MODEL == 1] < BIC[MODEL == 2], 1, 2),
         best_3vs1BIC = ifelse(BIC[MODEL == 1] < BIC[MODEL == 3], 1, 3),
         best_4vs1BIC = ifelse(BIC[MODEL == 1] < BIC[MODEL == 4], 1, 4),

         # which model is best within specific comparisons (BIC)?
         best_2vs1AIC = ifelse(AIC[MODEL == 1] < AIC[MODEL == 2], 1, 2),
         best_3vs1AIC = ifelse(AIC[MODEL == 1] < AIC[MODEL == 3], 1, 3),
         best_4vs1AIC = ifelse(AIC[MODEL == 1] < AIC[MODEL == 4], 1, 4)) %>%

          
  distinct(ID, COND, bic_2vs1, bic_3vs1, bic_4vs1, aic_2vs1, aic_3vs1, aic_4vs1, best_modelBIC, best_modelAIC, best_2vs1BIC, best_3vs1BIC,best_4vs1BIC, best_2vs1AIC, best_3vs1AIC, best_4vs1AIC)

# what was the best model over all?
n_best_modelBIC <- model_diff %>%
  group_by(COND) %>%
  count(best_modelBIC)

n_best_modelAIC <- model_diff %>%
  group_by(COND) %>%
  count(best_modelAIC)

model_diff_forced <- model_diff %>% filter(COND == "forced")
model_diff_free <- model_diff %>% filter(COND == "free")

# local current value stats vs the baseline model (model 2 vs 1)
# how many participants were better fit with model 2 compared with 1
n_best_2vs1AIC <- model_diff %>%
  group_by(COND) %>%
  count(best_2vs1AIC)

n_best_2vs1lBIC <- model_diff %>%
  group_by(COND) %>%
  count(best_2vs1BIC)

# what was the average difference in AIC and BIC scores between model 2 and model 1
mAic_2vs1=tapply(model_diff$aic_2vs1, list(model_diff$COND), mean, na.rm = TRUE)
mBic_2vs1=tapply(model_diff$bic_2vs1, list(model_diff$COND), mean, na.rm = TRUE)

# local reward rate (static) compared with the baseline model (model 3 vs 1)
# how many participants were better fit with model 3 compared with 1
n_best_3vs1AIC <- model_diff %>%
  group_by(COND) %>%
  count(best_3vs1AIC)

n_best_3vs1lBIC <- model_diff %>%
  group_by(COND) %>%
  count(best_3vs1BIC)

# what was the average difference in AIC and BIC scores between model 3 and model 1
mAic_3vs1=tapply(model_diff$aic_3vs1, list(model_diff$COND), mean, na.rm = TRUE)
mBic_3vs1=tapply(model_diff$bic_3vs1, list(model_diff$COND), mean, na.rm = TRUE)

# local reward rate (dynamic) stats compared with the baseline model (model 4 vs 1)
# how many participants were better fit with model 4 compared with 1
n_best_4vs1AIC <- model_diff %>%
  group_by(COND) %>%
  count(best_4vs1AIC)

n_best_4vs1lBIC <- model_diff %>%
  group_by(COND) %>%
  count(best_4vs1BIC)

# what was the mean difference in AIC/BIC between the models?
mAic_4vs1=tapply(model_diff$aic_4vs1, list(model_diff$COND), mean, na.rm = TRUE)
mBic_4vs1=tapply(model_diff$bic_4vs1, list(model_diff$COND), mean, na.rm = TRUE)

# now let's get a quick overview of the coefficients
interceptcoef=tapply(modelresults.df$'(Intercept)',list(modelresults.df$COND, modelresults.df$MODEL), mean)
PrevRcoef=tapply(modelresults.df$R,list(modelresults.df$COND, modelresults.df$MODEL), mean)
AvgRcoef=tapply(modelresults.df$avgR,list(modelresults.df$COND, modelresults.df$MODEL), mean)
AvgRMaxcoef=tapply(modelresults.df$avgRmax,list(modelresults.df$COND, modelresults.df$MODEL), mean)
AvgRMaxDyncoef=tapply(modelresults.df$dynAvgRmax,list(modelresults.df$COND, modelresults.df$MODEL), mean)

# let's get a quick overview of the hyper-parameters
alphacoef=tapply(modelresults.df$ALPHA,list(modelresults.df$COND, modelresults.df$MODEL), mean)
alpha0coef=tapply(modelresults.df$ALPHA0,list(modelresults.df$COND, modelresults.df$MODEL), mean)
svalcoef=tapply(modelresults.df$INITVAL,list(modelresults.df$COND, modelresults.df$MODEL), mean)

# describe the regression coefficients in terms of mean and sem (scroll to model three, the winning model)
descr_interceptcoef <- describeBy(modelresults.df$`(Intercept)`, list(modelresults.df$COND, modelresults.df$MODEL), IQR=TRUE,quant=c(.25,.75))
descr_PrevRcoef <- describeBy(modelresults.df$R, list(modelresults.df$COND, modelresults.df$MODEL), IQR=TRUE,quant=c(.25,.75))
descr_AvgRcoef <- describeBy(modelresults.df$avgR,list(modelresults.df$COND, modelresults.df$MODEL), IQR=TRUE,quant=c(.25,.75))
descr_AvgRMaxcoef <- describeBy(modelresults.df$avgRmax, list(modelresults.df$COND, modelresults.df$MODEL), IQR=TRUE,quant=c(.25,.75))

# describe the hyper parameters in terms of mean and sem (scroll to model three, the winning model)
descr_INITVALtcoef <- describeBy(modelresults.df$INITVAL, list(modelresults.df$COND, modelresults.df$MODEL), IQR=TRUE,quant=c(.25,.75))
descr_ALPHAtcoef <- describeBy(modelresults.df$ALPHA, list(modelresults.df$COND, modelresults.df$MODEL), IQR=TRUE,quant=c(.25,.75))
descr_ALPHA0tcoef <- describeBy(modelresults.df$ALPHA0, list(modelresults.df$COND, modelresults.df$MODEL), IQR=TRUE,quant=c(.25,.75))

# extra content
# get table each coefficient values for each participant and save
tvar <- modelresults.df %>%
  dplyr::filter(MODEL==3) %>%
  dplyr::select(ID,COND,`(Intercept)`, R, avgR,avgRmax) %>%
  as.data.table() %>%
  data.table::dcast(ID ~ COND, value.var=c('(Intercept)','R','avgR','avgRmax'))
write.table(tvar, file='regression_coefficients.csv', row.names=FALSE)

# what was correlation between the mean and max alternative reward rate estimated in the model fitting?
cval = cor(modelpredictions.df$avgRmean, modelpredictions.df$avgRmax)

# code for likelihood ratio test
nsubjs=60
LRTs = array(NA, dim = c(nsubjs, 2, 3))
for (ccond in 1:2) {
  for (ccomp in 2:4) {
    tmp = sapply(1:60, function(x) unlist(anova(allglms[x,ccond,1][[1]], allglms[x,ccond,ccomp][[1]], test = 'LRT'))[10])
    tmp[is.na(tmp)] = 1
    LRTs[,ccond,ccomp-1] = tmp
  }
}
apply(LRTs_3, c(2, 3), function(x) sum(x < 0.05))

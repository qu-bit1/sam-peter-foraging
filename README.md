Hall-McMaster, Dayan, & Schuck (2021)
================

Thanks for downloading the code package for our paper! The goal of this
project was see how human participants make patch-leaving decisions,
when they can choose which patches to visit.

## Organisation

The code package is divided into four distinct folders:

-   code\_analysis
-   code\_task
-   data
-   toolbox

## code\_analysis

code\_analysis has one subfolder for each figure in the paper. The file
needed to generate a figure has the structure FigXY (e.g. Fig2A), where
X is the figure number (e.g. 2) and Y is the figure panel (e.g. A).

##### Figures 2-4

The subfolders for figures 2-4 have an extra folder in them called
‘agent\_scripts’. This includes functions that add simulated agent
performance to the main figures. Fig2/csv\_output has data in a csv
format used to plot Fig2B.

##### Figure 5

The subfolder for figure 5 has three main files:

-   Fig5.R (to plot the figure)
-   Fig5\_resultsText.R (to get the AIC/BIC differences reported in the
    text from the files stored in model\_data)
-   RUN\_modelfit.r (to run the model fitting. This calls
    fit\_regressions.r, which calls compute\_average.r)

RUN\_Modelfit.r also calls write\_modelpredictions.r and
write\_modelresults.r to save the modelling results.
Fig5/csv\_output/regressioncoefficients.csv has standardised regression
coefficients for the global+maxRRs model, for each participant.
TestCoefficients.m performs statistical tests on these.

## code\_task

This folder has the PsychoPy3 files needed to run the task online, using
a hosting tool such as Pavlovia.

## data

This folder contains data for the 70 study participants.

## toolbox

The toolbox folder has four distinct subfolders:

-   preprocess (has functions for anonymising the data, detecting
    outliers and getting demographics)
-   plot (has functions for making barplots and lineplots)
-   stats (has functions for permutation testing)
-   agent (has agent\_stats.mat, which stores performance of the
    simulated agents).

It is possible to create a new agent\_stats.mat file by running
agent/agent.mat, which will load the state space files
‘forced\_101.hd5f’ and ‘free\_101.hd5f’ to simulate agents on the task.
The remaining files in the agent folder are used to support agent.m.

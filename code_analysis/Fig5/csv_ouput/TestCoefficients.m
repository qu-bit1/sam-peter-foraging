% Code to analyse standardised regression coefficients (Table 1)
% in Hall-McMaster, Dayan & Schuck: Control over patch encounters changes foraging behaviour
% Max Planck Institute for Human Development, December 2020


%To run this, ensure your current directory is the csv_output folder.
clear all
close all

%% setup

% set paths
mydir    = pwd;
if ispc
    folders   = strfind(mydir,'\');
else
    folders   = strfind(mydir,'/');
end
path = mydir(1:folders(end-2));
fs = filesep;
statpath = [path fs 'toolbox' fs 'stats'];
addpath(statpath);


%% Get data for analysis

% load csv file
t=readtable('regression_coefficients.csv');
tmat=table2array(t);

% sanity check (values should match those shown in table 1)
median(tmat)

% get difference in coefficients between local and global model for each
% condition
LocalvsGlobal_forced=tmat(:,8)-tmat(:,6);
LocalvsGlobal_free=tmat(:,9)-tmat(:,7);

%% perform permutation tests

% local vs gloabl reward rate (forced)
[h,pforced] = performPermTest(tmat(:,8),tmat(:,6),10000);
[pCheckforced, t_orig, crit_t, est_alpha, seed_state]=checkPermTest(tmat(:,8)-tmat(:,6),10000,0);

% local vs gloabl reward rate (free)
[h,pfree] = performPermTest(tmat(:,9),tmat(:,7),10000);
[pCheckfree, t_orig, crit_t, est_alpha, seed_state]=checkPermTest(tmat(:,9)-tmat(:,7),10000,0);

% local vs global reward rate (condition difference)
[h,pforcedVfree] = performPermTest(LocalvsGlobal_forced, LocalvsGlobal_free,10000);
[pCheckforcedVfree, t_orig, crit_t, est_alpha, seed_state]=checkPermTest(LocalvsGlobal_forced-LocalvsGlobal_free,10000,0);

% Code to reproduce reward before leaving for simulated agents.
% The function is used to obtain mean scores which can be overlaid on the
% participant data shown in Figure 4A.
% Hall-McMaster, Dayan & Schuck: Control over patch encounters changes foraging behaviour
% Max Planck Institute for Human Development, December 2020


%To run this, ensure your current directory is the Fig4 folder.
%clear all
%close all

function [dat_plt] = Fig4_agent()

%% setup

% set paths
mydir    = pwd;
if ispc
    folders   = strfind(mydir,'\');
else
    folders   = strfind(mydir,'/');
end
path = mydir(1:folders(end-1));
fs = filesep;
datapath = [path fs 'data'];
toolpath = [path fs 'toolbox' fs 'plot'];
savepath = pwd;
addpath(datapath);
addpath(toolpath);

% create vectors to store condition data
forced_slowPatRew=[];
forced_midPatRew=[];
forced_fastPatRew=[];
free_slowPatRew=[];
free_midPatRew=[];
free_fastPatRew=[];

for_slw_expl=[];
for_mid_expl=[];
for_fst_expl=[];
fre_slw_expl=[];
fre_mid_expl=[];
fre_fst_expl=[];


%% Get data for analysis

% load simulation data file
dat=[];
dat=load(['agent_stats.mat']);
dat_free=dat.statsc;
dat_forced=dat.statsnc;
nsubs=size(dat_free,1);

% file organisation
% statsc = choice; statsnc = no choice
% stats(.,.,1)  current patch (or future patch)
% stats(.,.,2)  0=exploit; 1=leave; -1=travel/arrive
% stats(.,.,3)  when leave, destination patch or -1
% stats(.,.,4)  reward on that trial (or 0)
% stats(.,.,5)  state of patch 1
% stats(.,.,6)  state of patch 2
% stats(.,.,7)  state of patch 3

for isub=1:nsubs
       
    for icond=1:2
        
        % get condition data
        cond_dat=[];
        if icond==1
            cond_dat=squeeze(dat_forced(isub,:,:));
        elseif icond==2
            cond_dat=squeeze(dat_free(isub,:,:));
        end
        
        sl_idx=[];  
        mid_idx=[]; 
        fst_idx=[]; 
        sl_idx=find(cond_dat(:,2)==1  & cond_dat(:,1)==0);
        mid_idx=find(cond_dat(:,2)==1 & cond_dat(:,1)==1);
        fst_idx=find(cond_dat(:,2)==1 & cond_dat(:,1)==2);
        sl_idx=sl_idx(sl_idx>1);
        mid_idx=mid_idx(mid_idx>1);
        fst_idx=fst_idx(fst_idx>1);
        
        nback=1;
        switch icond
            case 1
                forced_slowPatRew=vertcat(forced_slowPatRew,mean(cond_dat(sl_idx-nback,4))); 
                forced_midPatRew=vertcat(forced_midPatRew,mean(cond_dat(mid_idx-nback,4)));
                forced_fastPatRew=vertcat(forced_fastPatRew,mean(cond_dat(fst_idx-nback,4)));
                
            case 2
                free_slowPatRew=vertcat(free_slowPatRew,mean(cond_dat(sl_idx-nback,4))); 
                free_midPatRew=vertcat(free_midPatRew,mean(cond_dat(mid_idx-nback,4)));
                free_fastPatRew=vertcat(free_fastPatRew,mean(cond_dat(fst_idx-nback,4)));
        end
        
    end
    
end

%% Plot the data and perform statistical tests

% organise data 
dat_plt(:,1)=forced_slowPatRew; dat_plt(:,4)=free_slowPatRew;
dat_plt(:,2)=forced_midPatRew;  dat_plt(:,5)=free_midPatRew;
dat_plt(:,3)=forced_fastPatRew; dat_plt(:,6)=free_fastPatRew;

%{
% generate figure
settings.disp_subdat=1; % Do you want to plot individual participant points on the bar charts?
settings.setylim=[0 100;4 7]; % how high do you want the Y axis in each subplot?
settings.exploratory=1; % is this analysis exploratory?
settings.numtests=3;    % how many exploratory tests do you want to correct over?
[h,dat_means, dat_SDs, stat_out]=create_lineplot(dat_plt,settings,'Last Reward Before Leaving');

% store stats info in a structure
% means
stats.slw.forced.mean=dat_means(1,:); stats.slw.free.mean=dat_means(4,:);
stats.mid.forced.mean=dat_means(2,:); stats.mid.free.mean=dat_means(5,:);
stats.fst.forced.mean=dat_means(3,:); stats.fst.free.mean=dat_means(6,:);

% SDs
stats.slw.forced.SD=dat_SDs(1,:); stats.slw.free.SD=dat_SDs(4,:);
stats.mid.forced.SD=dat_SDs(2,:); stats.mid.free.SD=dat_SDs(5,:);
stats.fst.forced.SD=dat_SDs(3,:); stats.fst.free.SD=dat_SDs(6,:);

% tests
stats.slw.forcedVfree.p=stat_out.p(1); stats.slw.forcedVfree.df=stat_out.df(1); stats.slw.forcedVfree.tstat=stat_out.tstat(1);
stats.mid.forcedVfree.p=stat_out.p(2); stats.mid.forcedVfree.df=stat_out.df(2); stats.mid.forcedVfree.tstat=stat_out.tstat(2);
stats.fst.forcedVfree.p=stat_out.p(3); stats.fst.forcedVfree.df=stat_out.df(3); stats.fst.forcedVfree.tstat=stat_out.tstat(3);

% run 2x3 repeated measures anova
datatable=array2table(dat_plt);
datatable.Properties.VariableNames = {'forced_slw','forced_mid','forced_fst','free_slw','free_mid','free_fst'};
WithinStructure = table([1 1 1 2 2 2]',[1 2 3 1 2 3]','VariableNames',{'ForFre','Replen'});
WithinStructure.ForFre = categorical(WithinStructure.ForFre);
WithinStructure.Replen = categorical(WithinStructure.Replen);
rm = fitrm(datatable, 'forced_slw,forced_mid,forced_fst,free_slw,free_mid,free_fst~1','WithinDesign',WithinStructure);
ranovatable = ranova(rm,'WithinModel','ForFre*Replen');
stats.anova.table=ranovatable;

% average over factors to get descriptive stats and store in stats
gp_for=([dat_plt(:,1);dat_plt(:,2);dat_plt(:,3)]);
gp_fre=([dat_plt(:,4);dat_plt(:,5);dat_plt(:,6)]);
gp_slw=mean([dat_plt(:,1) dat_plt(:,4)],2);
gp_mid=mean([dat_plt(:,2) dat_plt(:,5)],2);
gp_fst=mean([dat_plt(:,3) dat_plt(:,6)],2);

stats.anova.descriptives.mean_free=mean(gp_fre);   stats.anova.descriptives.SD_free=std(gp_fre);
stats.anova.descriptives.mean_forced=mean(gp_for); stats.anova.descriptives.SD_forced=std(gp_for);
stats.anova.descriptives.mean_slw=mean(gp_slw);    stats.anova.descriptives.SD_slw=std(gp_slw);
stats.anova.descriptives.mean_mid=mean(gp_mid);    stats.anova.descriptives.SD_mid=std(gp_mid);
stats.anova.descriptives.mean_fst=mean(gp_fst);    stats.anova.descriptives.SD_fst=std(gp_fst);

% follow up tests for main effect of patch (collapsed over choice condition)
[h,FstMid.p,ci,stats.anova.ttests.FstMid.tstats]=ttest(gp_fst,gp_mid);
[h,FstSlw.p,ci,stats.anova.ttests.FstSlw.tstats]=ttest(gp_fst,gp_slw);
[h,MidSlw.p,ci,stats.anova.ttests.MidSlw.tstats]=ttest(gp_mid,gp_slw);

stats.anova.ttests.FstMid.p=FstMid.p*settings.numtests;
stats.anova.ttests.FstSlw.p=FstSlw.p*settings.numtests;
stats.anova.ttests.MidSlw.p=MidSlw.p*settings.numtests;
%}

% set analysis name for saving
analysisname='Fig4_rewB4Leaving_benchmark';

% save stats?
save_stats=0;
if save_stats
    statfolder = [savepath '/results/stats']; if ~exist(statfolder,'dir'); mkdir(statfolder); end
    statfname  = sprintf('%s/%s_stats',statfolder,analysisname);
    statfname  = sprintf('%s_%s',statfname,datestr(now,'yyyymmdd-HHMM'));
    save([statfname '.mat'],'stats');
end

% save figure?
do_print=0;
if do_print
    figpath =  [savepath '/figures']; if ~exist(figpath,'dir'), mkdir(figpath); end
    fname = sprintf('%s/%s',figpath,analysisname);
    fname = sprintf('%s_%s',fname,datestr(now,'yyyymmdd-HHMM'));
    print(gcf,'-dpng',fname);
    print(gcf,'-dpdf','-painters',fname);
end
end

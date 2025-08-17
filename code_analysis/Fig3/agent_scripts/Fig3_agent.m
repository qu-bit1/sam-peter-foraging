% Code to examine reward rates for each patch as a function of free or forced choice conditions (follow up on Figure 3)
% in Hall-McMaster, Dayan & Schuck: Control over patch encounters changes foraging behaviour
% Max Planck Institute for Human Development, December 2020


%To run this, ensure your current directory is the Fig3 folder.
%clear all
%close all

function [dat_plt] = Fig3_followup_benchmark()

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
datapath = [path fs 'toolbox' fs 'agent'];
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


% file organisation
% statsc = choice; statsnc = no choice
% stats(.,.,1)  current patch (or future patch)
% stats(.,.,2)  0=exploit; 1=leave; -1=travel/arrive
% stats(.,.,3)  when leave, destination patch or -1
% stats(.,.,4)  reward on that trial (or 0)
% stats(.,.,5)  state of patch 1
% stats(.,.,6)  state of patch 2
% stats(.,.,7)  state of patch 3

nsubs=size(dat_free,1);

for isub=1:nsubs
    
    for_rew=0; for_exploit=0;
    fre_rew=0; fre_exploit=0;
    for icond=1:2
        
        % get condition data
        cond_dat=[];
        if icond==1
            cond_dat=squeeze(dat_forced(isub,:,:));
        elseif icond==2
            cond_dat=squeeze(dat_free(isub,:,:));
        end
    
        % get exploit actions
        sl_idx=[]; mid_idx=[]; fst_idx=[];
        sl_idx=find(cond_dat(:,2)==0  & cond_dat(:,1)==0);
        mid_idx=find(cond_dat(:,2)==0 & cond_dat(:,1)==1);
        fst_idx=find(cond_dat(:,2)==0 & cond_dat(:,1)==2);
       
        switch icond
            case 1
                forced_slowPatRew=vertcat(forced_slowPatRew,sum(cond_dat(sl_idx,4))); 
                forced_midPatRew=vertcat(forced_midPatRew,sum(cond_dat(mid_idx,4)));
                forced_fastPatRew=vertcat(forced_fastPatRew,sum(cond_dat(fst_idx,4)));
                
                for_slw_expl=vertcat(for_slw_expl,length(sl_idx));
                for_mid_expl=vertcat(for_mid_expl,length(mid_idx));
                for_fst_expl=vertcat(for_fst_expl,length(fst_idx));
                
            case 2
                free_slowPatRew=vertcat(free_slowPatRew,sum(cond_dat(sl_idx,4))); 
                free_midPatRew=vertcat(free_midPatRew,sum(cond_dat(mid_idx,4)));
                free_fastPatRew=vertcat(free_fastPatRew,sum(cond_dat(fst_idx,4)));
                
                fre_slw_expl=vertcat(fre_slw_expl,length(sl_idx));
                fre_mid_expl=vertcat(fre_mid_expl,length(mid_idx));
                fre_fst_expl=vertcat(fre_fst_expl,length(fst_idx));
        end
    end
    
end

%% Plot the data and perform statistical tests

% generate figure
settings.disp_subdat=1; % do you want to plot individual participant points on the bar charts?
if settings.disp_subdat
    settings.setylim=[0 100;0 100; 0 100]; % how high do you want the Y axis in each subplot (with participant points)?
else
    settings.setylim=[0 80;0 80;0 80];     % how high do you want the Y axis in each subplot (without participant points)?
end
settings.exploratory=1; % is this analysis exploratory?
settings.numtests=3;    % how many exploratory tests do you want to correct over?

dat_plt(:,1)=forced_slowPatRew./for_slw_expl;
dat_plt(:,2)=forced_midPatRew./for_mid_expl;
dat_plt(:,3)=forced_fastPatRew./for_fst_expl;
dat_plt(:,4)=free_slowPatRew./fre_slw_expl;
dat_plt(:,5)=free_midPatRew./fre_mid_expl;
dat_plt(:,6)=free_fastPatRew./fre_fst_expl;

%{
%[h(1),for_slw_M,fre_slw_M,for_slw_SD,fre_slw_SD,p_slw,df_slw,tstat_slw]=create_barplot(forced_slowPatRew./for_slw_expl,free_slowPatRew./fre_slw_expl,1,settings,'Reward Rate for Slow Replenishing Option');
%[h(2),for_mid_M,fre_mid_M,for_mid_SD,fre_mid_SD,p_mid,df_mid,tstat_mid]=create_barplot(forced_midPatRew./for_mid_expl,free_midPatRew./fre_mid_expl,2,settings,'Reward Rate for Medium Replenishing Option');
%[h(3),for_fst_M,fre_fst_M,for_fst_SD,fre_fst_SD,p_fst,df_fst,tstat_fst]=create_barplot(forced_fastPatRew./for_fst_expl,free_fastPatRew./fre_fst_expl,3,settings,'Reward Rate for Fast Replenishing Option');

% store stats info in a structure
% means
stats.slw.forced.mean=for_slw_M; stats.slw.free.mean=fre_slw_M;
stats.mid.forced.mean=for_mid_M; stats.mid.free.mean=fre_mid_M;
stats.fst.forced.mean=for_fst_M; stats.fst.free.mean=fre_fst_M;

% SDs
stats.slw.forced.SD=for_slw_SD; stats.slw.free.SD=fre_slw_SD;
stats.mid.forced.SD=for_mid_SD; stats.mid.free.SD=fre_mid_SD;
stats.fst.forced.SD=for_fst_SD; stats.fst.free.SD=fre_fst_SD;

% tests (corrected)
stats.slw.forcedVfree.p=p_slw; stats.slw.forcedVfree.df=df_slw; stats.slw.forcedVfree.tstat=tstat_slw;
stats.mid.forcedVfree.p=p_mid; stats.mid.forcedVfree.df=df_mid; stats.mid.forcedVfree.tstat=tstat_mid;
stats.fst.forcedVfree.p=p_fst; stats.fst.forcedVfree.df=df_fst; stats.fst.forcedVfree.tstat=tstat_fst;

%}
% set analysis name for saving
analysisname='Fig3_RewRates_ExplActs_Exploratory_Benchmark';

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
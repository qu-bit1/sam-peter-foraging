% Code to reproduce normalised visitation rates for the simulated agents. 
% The function is used to obtain mean scores which can be overlaid on the
% participant data shown in Figure 2A.
% Hall-McMaster, Dayan & Schuck: Control over patch encounters changes foraging behaviour
% Max Planck Institute for Human Development, December 2020


%To run this, ensure your current directory is the Fig2 folder.
%clear all
%close all

function [dat_plt] = Fig2A_agent()

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
forced_slowPatVisit=[];
forced_midPatVisit=[];
forced_fastPatVisit=[];
free_slowPatVisit=[];
free_midPatVisit=[];
free_fastPatVisit=[];
forced_sel_count=[];
free_sel_count=[];

%% Get data
% load simulation data file
dat=[];
dat=load(['agent_stats.mat']);
dat_free=dat.statsc;
dat_forced=dat.statsnc;
nsubs=size(dat_free,1);

% data organisation
% statsc = choice; statsnc = no choice
% stats(.,.,1)  current patch (or future patch)
% stats(.,.,2)  0=exploit; 1=leave; -1=travel/arrive
% stats(.,.,3)  when leave, destination patch or -1
% stats(.,.,4)  reward on that trial (or 0)
% stats(.,.,5)  state of patch 1
% stats(.,.,6)  state of patch 2
% stats(.,.,7)  state of patch 3

for isub=1:nsubs
    
    % get data for the forced choice condition (cond=1) or the free choice
    % condition (cond=2)
    for cond=1:2
        cond_dat=[];

        switch cond
            case 1
                cond_dat=dat_forced;
                forced_slowPatVisit=vertcat(forced_slowPatVisit,length(find(cond_dat(isub,:,3)==0 & cond_dat(isub,:,2)==1)));
                forced_midPatVisit=vertcat(forced_midPatVisit,length(find(cond_dat(isub,:,3)==1 & cond_dat(isub,:,2)==1)));
                forced_fastPatVisit=vertcat(forced_fastPatVisit,length(find(cond_dat(isub,:,3)==2 & cond_dat(isub,:,2)==1)));
                
                idx=[];
                idx=find((cond_dat(isub,:,3)==0|cond_dat(isub,:,3)==1|cond_dat(isub,:,3)==2) & cond_dat(isub,:,2)==1);
                forced_sel_count=vertcat(forced_sel_count,length(idx));
                
            case 2
                cond_dat=dat_free;
                free_slowPatVisit=vertcat(free_slowPatVisit,length(find(cond_dat(isub,:,3)==0 & cond_dat(isub,:,2)==1)));
                free_midPatVisit=vertcat(free_midPatVisit,length(find(cond_dat(isub,:,3)==1 & cond_dat(isub,:,2)==1)));
                free_fastPatVisit=vertcat(free_fastPatVisit,length(find(cond_dat(isub,:,3)==2 & cond_dat(isub,:,2)==1)));
                
                idx=[];
                idx=find((cond_dat(isub,:,3)==0|cond_dat(isub,:,3)==1|cond_dat(isub,:,3)==2) & cond_dat(isub,:,2)==1);
                free_sel_count=vertcat(free_sel_count,length(idx));
        end
    end
    
end

%% Plot the data and perform statistical tests

% organise data 
dat_plt(:,1)=forced_slowPatVisit./forced_sel_count; dat_plt(:,4)=free_slowPatVisit./free_sel_count;
dat_plt(:,2)=forced_midPatVisit./forced_sel_count;  dat_plt(:,5)=free_midPatVisit./free_sel_count;
dat_plt(:,3)=forced_fastPatVisit./forced_sel_count; dat_plt(:,6)=free_fastPatVisit./free_sel_count;

%{
% data as csv file
%T=array2table(dat_plt);
%T.Properties.VariableNames = {'slow_patch_forced_choice','medium_patch_forced_choice','fast_patch_forced_choice', ...
%                              'slow_patch_free_choice','medium_patch_free_choice','fast_patch_free_choice'};
%writetable(T,'proportion_visits_agent.csv');

% generate figure
settings.disp_subdat=1; % do you want to plot individual participant points on the bar charts?
settings.setylim=[0.2 0.5;0.25 0.40]; % how high do you want the Y axis in each subplot?
settings.setylim=[0.1 0.6;0 1]; % how high do you want the Y axis in each subplot?
settings.exploratory=0; % is this analysis exploratory?
settings.numtests=3;    % how many exploratory tests do you want to correct over?
%[h,dat_means, dat_SDs, stat_out]=create_lineplot(dat_plt,settings,'Proportion of Patch Visits');

% store stats info in a structure
% means
stats.slw.forced.mean=dat_means(1,:); stats.slw.free.mean=dat_means(4,:);
stats.mid.forced.mean=dat_means(2,:); stats.mid.free.mean=dat_means(5,:);
stats.fst.forced.mean=dat_means(3,:); stats.fst.free.mean=dat_means(6,:);

% SDs
stats.slw.forced.SD=dat_SDs(1,:); stats.slw.free.SD=dat_SDs(4,:);
stats.mid.forced.SD=dat_SDs(2,:); stats.mid.free.SD=dat_SDs(5,:);
stats.fst.forced.SD=dat_SDs(3,:); stats.fst.free.SD=dat_SDs(6,:);
%}


% set analysis name for saving
analysisname='Fig2A_agent';

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
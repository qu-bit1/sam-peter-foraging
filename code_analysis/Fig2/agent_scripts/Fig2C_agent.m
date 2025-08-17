% Code to reproduce decisions to select best alternative patch (expected reward)
% for simulated agents.
% The function is used to obtain mean scores which can be overlaid on the
% participant data shown in Figure 2C.
% in Hall-McMaster, Dayan & Schuck: Control over patch encounters changes foraging behaviour
% Max Planck Institute for Human Development, December 2020


%To run this, ensure your current directory is the Fig2 folder.
%clear all
%close all

function [dat_plt] = Fig2B_agent()
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
sub_res=[];
forced_slowPatRew=[];
forced_midPatRew=[];
forced_fastPatRew=[];
free_slowPatRew=[];
free_midPatRew=[];
free_fastPatRew=[];

%% Get data
% load simulation data file
dat=[];
dat=load(['agent_stats.mat']);
dat_free=dat.statsc;
dat_forced=dat.statsnc;
nsubs=size(dat_forced,1);

% data file organisation
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
        idx=[];
        
        switch cond
            case 1
                cond_dat=squeeze(dat_forced(isub,:,:));
            case 2
                cond_dat=squeeze(dat_free(isub,:,:));
        end
        
        pat_vec=[0,1,2];
        for ipat=1:3
            curr_pat=pat_vec(ipat);
            idx=find(cond_dat(:,2)==1 & cond_dat(:,1)==curr_pat);
            
            pat_dat=[];
            pat_dat=cond_dat(idx,:);
            
            % get alternative patches
            alt_pat_cols=[];
            switch curr_pat
                case 0
                    alt_pats=[1,2];
                    alt_pat_cols=[6,7];
                case 1
                    alt_pats=[0,2];
                    alt_pat_cols=[5,7];
                case 2
                    alt_pats=[0,1];
                    alt_pat_cols=[5,6];
            end
                   
            temp=[];
            for k=1:size(pat_dat,1)
                if (pat_dat(k,alt_pat_cols(1))>pat_dat(k,alt_pat_cols(2)) & pat_dat(k,3)==alt_pats(1))
                    temp=vertcat(temp,1);
                elseif (pat_dat(k,alt_pat_cols(1))<pat_dat(k,alt_pat_cols(2)) & pat_dat(k,3)==alt_pats(2))
                    temp=vertcat(temp,1);
                end
            end
            
            % convert to proportion
            sub_res(isub,ipat)=sum(temp)/size(pat_dat,1);
        end
             
        switch cond
            case 1
                forced_slowPatRew=vertcat(forced_slowPatRew,sub_res(isub,1));
                forced_midPatRew=vertcat(forced_midPatRew,sub_res(isub,2));
                forced_fastPatRew=vertcat(forced_fastPatRew,sub_res(isub,3));
                
            case 2
                free_slowPatRew=vertcat(free_slowPatRew,sub_res(isub,1));
                free_midPatRew=vertcat(free_midPatRew,sub_res(isub,2));
                free_fastPatRew=vertcat(free_fastPatRew,sub_res(isub,3));
        end
    end
    
end

%% Plot the data and perform statistical tests

% organise data
dat_plt(:,1)=forced_slowPatRew; dat_plt(:,4)=free_slowPatRew;
dat_plt(:,2)=forced_midPatRew;  dat_plt(:,5)=free_midPatRew;
dat_plt(:,3)=forced_fastPatRew; dat_plt(:,6)=free_fastPatRew;

%{
%T=array2table(dat_plt);
%T.Properties.VariableNames = {'slow_patch_forced_choice','medium_patch_forced_choice','fast_patch_forced_choice', ...
%                              'slow_patch_free_choice','medium_patch_free_choice','fast_patch_free_choice'};
%writetable(T,'proportion_choices_reward_agent.csv');

% generate figure
settings.disp_subdat=1; % Do you want to plot individual participant points on the bar charts?
settings.setylim=[0 1;4 7]; % how high do you want the Y axis in each subplot?
settings.exploratory=1; % is this analysis exploratory?
settings.numtests=3;    % how many exploratory tests do you want to correct over?
settings.xaxislabel='Patch Being Left';
settings.dolegend=0;
%[h,dat_means, dat_SDs, stat_out]=create_lineplot(dat_plt,settings,'Prop. Choices to Best Alternative (Reward)');

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
analysisname='Fig2C_agent';

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
    print(gcf, '-dtiffn', fname);
    print(gcf, '-dtiffn', fname);
end
end
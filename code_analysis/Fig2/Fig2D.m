% Code to reproduce decisions to select best alternative patch (reward rate) as a function of free or forced choice conditions (Figure 2D)
% in Hall-McMaster, Dayan & Schuck: Control over patch encounters changes foraging behaviour
% Max Planck Institute for Human Development, December 2020


%To run this, ensure your current directory is the Fig2 folder.
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
path = mydir(1:folders(end-1));
fs = filesep;
datapath = [path fs 'data'];
toolpath = [path fs 'toolbox' fs 'plot'];
agentpath =[pwd fs 'agent_scripts'];
savepath = pwd;
addpath(datapath);
addpath(toolpath);
addpath(agentpath);

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

% define participants to analyse. Exclude participants rejected during
% preprocessing
sublist=[1:70];
exclude=[12 33 43 44 50 54 58 61 68 70];

sublist=setdiff(sublist,exclude);
nsubs=length(sublist);

%exclude=[33 43 44 50 61 68]; % if you want to just exclude the over-harvesters
%exclude=[12 54 58 70] % if you want to just exclude the under-harvesters

%% Get data for analysis

for isub=1:nsubs
    
    sub=sublist(isub);
    
    % load file
    dat=[];
    dat=load(['sub' num2str(sub) '_data.mat']);
    dat=dat.dat;
    
    % get data for the forced choice condition (cond=1) or the free choice
    % condition (cond=2)
    for cond=1:2
        idx=[];
        idx=find(dat.blk_type==cond & strcmp(dat.exploit_phase_key,'s'));
        
        c=0;
        t=[];
        for itrl=1:size(idx,1)
           % get current patch
           c=c+1;
           t(c,1)=dat.currentPatchReplenishRate(idx(itrl));
           
           % look for the next patch
           for m=1:20
               if (itrl+m)>size(idx,1)
                   break
               end
           if dat.currentPatchReplenishRate(idx(itrl)+m)~=t(c,1) ...
              & ismember(dat.currentPatchReplenishRate(idx(itrl)+m), [0.0500,0.1000,0.1500])==1
               
              t(c,2)=dat.currentPatchReplenishRate(idx(itrl)+m);
              break
           end
               
           end
        end
        
        if t(end,2)==0 % if final choice not recorded due to block end
            t(end,:)=[];
        end
        
        y=find(t(:,2)==0);
        t(y,:)=[];
        
        % count up proportion for each patch
        sl_prop = length(find(t(:,1)==0.05 & t(:,2)==0.15)) / length(find(t(:,1)==0.05));
        mid_prop = length(find(t(:,1)==0.10 & t(:,2)==0.15)) / length(find(t(:,1)==0.10));
        fst_prop = length(find(t(:,1)==0.15 & t(:,2)==0.10)) / length(find(t(:,1)==0.15));
        
        switch cond
            case 1
                forced_slowPatRew=vertcat(forced_slowPatRew,sl_prop);
                forced_midPatRew=vertcat(forced_midPatRew,mid_prop);
                forced_fastPatRew=vertcat(forced_fastPatRew,fst_prop);
                
            case 2
                free_slowPatRew=vertcat(free_slowPatRew,sl_prop);
                free_midPatRew=vertcat(free_midPatRew,mid_prop);
                free_fastPatRew=vertcat(free_fastPatRew,fst_prop); 
        end
    end
    
end

%% Plot the data and perform statistical tests

% organise data 
dat_plt(:,1)=forced_slowPatRew; dat_plt(:,4)=free_slowPatRew;
dat_plt(:,2)=forced_midPatRew;  dat_plt(:,5)=free_midPatRew;
dat_plt(:,3)=forced_fastPatRew; dat_plt(:,6)=free_fastPatRew;

% run permutation tests
[h,pSlw] = performPermTest(dat_plt(:,1), dat_plt(:,4),10000);
[pSlwCheck, t_orig, crit_t, est_alpha, seed_state]=checkPermTest(dat_plt(:,1)-dat_plt(:,4),10000,0);

[h,pMid] = performPermTest(dat_plt(:,2), dat_plt(:,5),10000);
[pMidCheck, t_orig, crit_t, est_alpha, seed_state]=checkPermTest(dat_plt(:,2)-dat_plt(:,5),10000,0);

[h,pFst] = performPermTest(dat_plt(:,3), dat_plt(:,6),10000);
[pFstCheck, t_orig, crit_t, est_alpha, seed_state]=checkPermTest(dat_plt(:,3)-dat_plt(:,6),10000,0);

% store results
stats.slw.forcedVfree.p=pSlw;
stats.mid.forcedVfree.p=pMid;
stats.fst.forcedVfree.p=pFst; 

T=array2table(dat_plt);
T.Properties.VariableNames = {'slow_patch_forced_choice','medium_patch_forced_choice','fast_patch_forced_choice', ...
                              'slow_patch_free_choice','medium_patch_free_choice','fast_patch_free_choice'};
if ~exist('csv_output','dir'), mkdir('csv_output'); end
writetable(T,['csv_output' fs 'proportion_choices_replenishment.csv']);

% generate figure
settings.disp_subdat=1; % Do you want to plot individual participant points on the bar charts?
settings.setylim=[0 1;4 7]; % how high do you want the Y axis in each subplot?
settings.exploratory=1; % is this analysis exploratory?
settings.numtests=3;    % how many exploratory tests do you want to correct over?
settings.xaxislabel='Patch Being Left';
settings.dolegend=0;
[h,dat_means, dat_SDs, stat_out]=create_lineplot(dat_plt,settings,'Prop. Choices to Best Alternative (Replenishment)');

% add lines from simulated means
hold on
agent_means=Fig2D_agent();
agent_means=squeeze(mean(agent_means));
agent_col=[0.4,0.4,0.4];

for add_mean=1:3
    plot([add_mean-0.09 add_mean-0.01],[agent_means(add_mean) agent_means(add_mean)], 'color',agent_col,'LineWidth',5); % prev 2.5
    plot([add_mean+0.01 add_mean+0.09],[agent_means(add_mean+3) agent_means(add_mean+3)],'color',agent_col,'LineWidth',5); 
end
%egend([h(1:2)],'Forced Choice', 'Free Choice');
%legend('boxoff')

% store stats info in a structure
% means
stats.slw.forced.mean=dat_means(1,:); stats.slw.free.mean=dat_means(4,:);
stats.mid.forced.mean=dat_means(2,:); stats.mid.free.mean=dat_means(5,:);
stats.fst.forced.mean=dat_means(3,:); stats.fst.free.mean=dat_means(6,:);

% SDs
stats.slw.forced.SD=dat_SDs(1,:); stats.slw.free.SD=dat_SDs(4,:);
stats.mid.forced.SD=dat_SDs(2,:); stats.mid.free.SD=dat_SDs(5,:);
stats.fst.forced.SD=dat_SDs(3,:); stats.fst.free.SD=dat_SDs(6,:);

% set analysis name for saving
analysisname='proportion_choose_highest_replenishment';

% save stats?
save_stats=1;
if save_stats
    statfolder = [savepath '/results/stats']; if ~exist(statfolder,'dir'); mkdir(statfolder); end
    statfname  = sprintf('%s/%s_stats',statfolder,analysisname);
    statfname  = sprintf('%s_%s',statfname,datestr(now,'yyyymmdd-HHMM'));
    save([statfname '.mat'],'stats');
end

% save figure?
do_print=1;
if do_print
    figpath =  [savepath '/figures']; if ~exist(figpath,'dir'), mkdir(figpath); end
    fname = sprintf('%s/%s',figpath,analysisname);
    fname = sprintf('%s_%s',fname,datestr(now,'yyyymmdd-HHMM'));
    print(gcf,'-dpng',fname);
    h=gcf;
    set(h, 'Units', 'Inches');
    pos = get(h,'Position');
    set(h,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3),pos(4)]);
    print(gcf,'-dpdf','-painters',fname);   
end

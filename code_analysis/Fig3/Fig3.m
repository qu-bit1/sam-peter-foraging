% Code to examine reward rates for each patch as a function of free or forced choice conditions (Figure 3)
% in Hall-McMaster, Dayan & Schuck: Control over patch encounters changes foraging behaviour
% Max Planck Institute for Human Development, December 2020


%To run this, ensure your current directory is the Fig3 folder.
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
agentpath = [pwd fs 'agent_scripts'];
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
%exclude=[33 43 44 50 61 68]; % if you want to just exclude the over-harvesters
%exclude=[12 54 58 70] % if you want to just exclude the under-harvesters

sublist=setdiff(sublist,exclude);
nsubs=length(sublist);

% give reward rate as a function of all actions (selection, exploit, leave) if set to 1 or
% just exploit actions if set to 0
do_all_actions=0;

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
        if do_all_actions
            idx=find(dat.blk_type==cond & (strcmp(dat.exploit_phase_key,'space') | (strcmp(dat.exploit_phase_key,'s') ...
                | strcmp(dat.patch_selection_key,'f') | strcmp(dat.patch_selection_key,'j') | strcmp(dat.patch_selection_key,'k'))));
        else
            idx=find(dat.blk_type==cond & strcmp(dat.exploit_phase_key,'space'));
        end
        
        idx_leave=[];
        idx_leave=find(dat.blk_type==cond & strcmp(dat.exploit_phase_key,'s'));
        dat.actual_rew_gain(idx_leave)=0; % deal with a small error in the data recording, no points were actually gained in block when leaving.
        
        sl_idx=[];  sl_idx=find(dat.currentPatchReplenishRate(idx)==0.05);
        mid_idx=[]; mid_idx=find(dat.currentPatchReplenishRate(idx)==0.10);
        fst_idx=[]; fst_idx=find(dat.currentPatchReplenishRate(idx)==0.15);
        
        switch cond
            case 1
                forced_slowPatRew=vertcat(forced_slowPatRew,sum(dat.actual_rew_gain(idx(sl_idx))));
                forced_midPatRew=vertcat(forced_midPatRew,sum(dat.actual_rew_gain(idx(mid_idx))));
                forced_fastPatRew=vertcat(forced_fastPatRew,sum(dat.actual_rew_gain(idx(fst_idx))));
                
                for_slw_expl=vertcat(for_slw_expl,length(sl_idx));
                for_mid_expl=vertcat(for_mid_expl,length(mid_idx));
                for_fst_expl=vertcat(for_fst_expl,length(fst_idx));
                
            case 2
                free_slowPatRew=vertcat(free_slowPatRew,sum(dat.actual_rew_gain(idx(sl_idx))));
                free_midPatRew=vertcat(free_midPatRew,sum(dat.actual_rew_gain(idx(mid_idx))));
                free_fastPatRew=vertcat(free_fastPatRew,sum(dat.actual_rew_gain(idx(fst_idx))));
                
                fre_slw_expl=vertcat(fre_slw_expl,length(sl_idx));
                fre_mid_expl=vertcat(fre_mid_expl,length(mid_idx));
                fre_fst_expl=vertcat(fre_fst_expl,length(fst_idx));
        end
    end
    
end

%% Plot the data and perform statistical tests

% organise data 
dat_plt(:,1)=forced_slowPatRew./for_slw_expl; dat_plt(:,4)=free_slowPatRew./fre_slw_expl;
dat_plt(:,2)=forced_midPatRew./for_mid_expl; dat_plt(:,5)=free_midPatRew./fre_mid_expl;
dat_plt(:,3)=forced_fastPatRew./for_fst_expl; dat_plt(:,6)=free_fastPatRew./fre_fst_expl;

% generate figure
settings.disp_subdat=1; % do you want to plot individual participant points on the bar charts?
if settings.disp_subdat
    settings.setylim=[30 100;30 100; 30 100]; % how high do you want the Y axis in each subplot (with participant points)?
else
    settings.setylim=[0 80;0 80;0 80];     % how high do you want the Y axis in each subplot (without participant points)?
end
settings.exploratory=1; % is this analysis exploratory?
settings.numtests=3;    % how many exploratory tests do you want to correct over?

% perform 2x3 repeated measures anova
datatable=array2table(dat_plt);
datatable.Properties.VariableNames = {'forced_slw','forced_mid','forced_fst','free_slw','free_mid','free_fst'};
WithinStructure = table([1 1 1 2 2 2]',[1 2 3 1 2 3]','VariableNames',{'ForFre','Replen'});
WithinStructure.ForFre = categorical(WithinStructure.ForFre);
WithinStructure.Replen = categorical(WithinStructure.Replen);
rm = fitrm(datatable, 'forced_slw,forced_mid,forced_fst,free_slw,free_mid,free_fst~1','WithinDesign',WithinStructure);
ranovatable = ranova(rm,'WithinModel','ForFre*Replen');
stats.anova.table=ranovatable;
% data as csv file to plot simplex in a different script
T=array2table(dat_plt);
T.Properties.VariableNames = {'slow_patch_forced_choice','medium_patch_forced_choice','fast_patch_forced_choice', ...
                              'slow_patch_free_choice','medium_patch_free_choice','fast_patch_free_choice'};
if ~exist('csv_output','dir'), mkdir('csv_output'); end
writetable(T,['csv_output' fs 'RewardRate_ExploitActions.csv']);

% add lines for simulated agent means to each subpanel
agent_means=Fig3_agent();
agent_means=squeeze(mean(agent_means));
agent_col=[0.4,0.4,0.4];

% slow patch
[h(1),for_slw_M,fre_slw_M,for_slw_SD,fre_slw_SD,p_slw,df_slw,tstat_slw]=create_barplot(forced_slowPatRew./for_slw_expl,free_slowPatRew./fre_slw_expl,1,settings,'Reward Rate for Slow Patch');
if do_all_actions==0
hold on
for add_mean=1:2
    in=1;
    if add_mean==2
        in=4;
    end
    plot([add_mean-0.25 add_mean+0.25],[agent_means(in) agent_means(in)], 'color',agent_col,'LineWidth',5);
end
end

% medium patch
[h(2),for_mid_M,fre_mid_M,for_mid_SD,fre_mid_SD,p_mid,df_mid,tstat_mid]=create_barplot(forced_midPatRew./for_mid_expl,free_midPatRew./fre_mid_expl,2,settings,'Reward Rate for Medium Patch');
if do_all_actions==0
hold on
for add_mean=1:2
    in=2;
    if add_mean==2
        in=5;
    end
    plot([add_mean-0.25 add_mean+0.25],[agent_means(in) agent_means(in)], 'color',agent_col,'LineWidth',5);
end
end

% fast patch
[h(3),for_fst_M,fre_fst_M,for_fst_SD,fre_fst_SD,p_fst,df_fst,tstat_fst]=create_barplot(forced_fastPatRew./for_fst_expl,free_fastPatRew./fre_fst_expl,3,settings,'Reward Rate for Fast Patch');
if do_all_actions==0
hold on
for add_mean=1:2
    in=3;
    if add_mean==2
        in=6;
    end
    plot([add_mean-0.25 add_mean+0.25],[agent_means(in) agent_means(in)], 'color',agent_col,'LineWidth',5);
end
end

% store the stats info in a structure
% condition means
stats.slw.forced.mean=for_slw_M; stats.slw.free.mean=fre_slw_M;
stats.mid.forced.mean=for_mid_M; stats.mid.free.mean=fre_mid_M;
stats.fst.forced.mean=for_fst_M; stats.fst.free.mean=fre_fst_M;
% mean for each choice condition
stats.forced.mean=mean(mean([dat_plt(:,1) dat_plt(:,2) dat_plt(:,3)],2),1); % mean over columns, then rows
stats.free.mean=mean(mean([dat_plt(:,4) dat_plt(:,5) dat_plt(:,6)],2),1);
% mean for each patch condition
stats.slw.mean=mean(mean([dat_plt(:,1) dat_plt(:,4)],2),1); 
stats.mid.mean=mean(mean([dat_plt(:,2) dat_plt(:,5)],2),1);
stats.fst.mean=mean(mean([dat_plt(:,3) dat_plt(:,6)],2),1);
% mean choice difference for interaction
stats.forcedVfree.slw.mean=mean([dat_plt(:,1)-dat_plt(:,4)]); 
stats.forcedVfree.mid.mean=mean([dat_plt(:,2)-dat_plt(:,5)]);
stats.forcedVfree.fst.mean=mean([dat_plt(:,3)-dat_plt(:,6)]);

% SDs
stats.slw.forced.SD=for_slw_SD; stats.slw.free.SD=fre_slw_SD;
stats.mid.forced.SD=for_mid_SD; stats.mid.free.SD=fre_mid_SD;
stats.fst.forced.SD=for_fst_SD; stats.fst.free.SD=fre_fst_SD;
% SDs for each choice condition
stats.forced.SD=std(mean([dat_plt(:,1) dat_plt(:,2) dat_plt(:,3)],2),1); % mean over columns, then SD
stats.free.SD=std(mean([dat_plt(:,4) dat_plt(:,5) dat_plt(:,6)],2),1);
% SDs for each patch condition
stats.slw.SD=std(mean([dat_plt(:,1) dat_plt(:,4)],2),1); 
stats.mid.SD=std(mean([dat_plt(:,2) dat_plt(:,5)],2),1);
stats.fst.SD=std(mean([dat_plt(:,3) dat_plt(:,6)],2),1);
% SDs for choice differences
stats.forcedVfree.slw.SD=std([dat_plt(:,1)-dat_plt(:,4)]); 
stats.forcedVfree.mid.SD=std([dat_plt(:,2)-dat_plt(:,5)]);
stats.forcedVfree.fst.SD=std([dat_plt(:,3)-dat_plt(:,6)]);

% follow up tests related to the interaction
% are the differences different between patches?
[h,pSlwMidCDiff,CI,statSlwMidCDiff]=ttest([(dat_plt(:,1)-dat_plt(:,4))-(dat_plt(:,2)-dat_plt(:,5))]); pSlwMidCDiff=pSlwMidCDiff*3; % get Bonferroni corrected p (Jafari & Ansari-Pour, 2019).
[h,pSlwFstCDiff,CI,statSlwFstCDiff]=ttest([(dat_plt(:,1)-dat_plt(:,4))-(dat_plt(:,3)-dat_plt(:,6))]); pSlwFstCDiff=pSlwFstCDiff*3;
[h,pMidFstCDiff,CI,statMidFstCDiff]=ttest([(dat_plt(:,2)-dat_plt(:,5))-(dat_plt(:,3)-dat_plt(:,6))]); pMidFstCDiff=pMidFstCDiff*3;

% are differences different from 0?
[h,pSlwCDiff,CI,statSlwCDiff]=ttest([dat_plt(:,1)-dat_plt(:,4)]); pSlwCDiff=pSlwCDiff*3; 
[h,pMidCDiff,CI,statMidCDiff]=ttest([dat_plt(:,2)-dat_plt(:,5)]); pMidCDiff=pMidCDiff*3; 
[h,pFstCDiff,CI,statFstCDiff]=ttest([dat_plt(:,3)-dat_plt(:,6)]); pFstCDiff=pFstCDiff*3; 

% store test results
stats.forcedVfree.slw.p=pSlwCDiff; stats.forcedVfree.slw.df=statSlwCDiff.df; stats.forcedVfree.slw.tstat=statSlwCDiff.tstat;
stats.forcedVfree.mid.p=pMidCDiff; stats.forcedVfree.mid.df=statMidCDiff.df; stats.forcedVfree.mid.tstat=statMidCDiff.tstat;
stats.forcedVfree.fst.p=pFstCDiff; stats.forcedVfree.fst.df=statFstCDiff;    stats.forcedVfree.fst.tstat=statFstCDiff.tstat;

stats.forcedVfree.slwVMid.p=pSlwMidCDiff; stats.forcedVfree.slwVMid.df=statSlwMidCDiff.df; stats.forcedVfree.slwVMid.tstat=statSlwMidCDiff.tstat;
stats.forcedVfree.slwVFst.p=pSlwFstCDiff; stats.forcedVfree.slwVFst.df=statSlwFstCDiff.df; stats.forcedVfree.slwVFst.tstat=statSlwFstCDiff.tstat;
stats.forcedVfree.midVFst.p=pMidFstCDiff; stats.forcedVfree.midVFst.df=statMidFstCDiff.df; stats.forcedVfree.midVFst.tstat=statMidFstCDiff.tstat;

% set analysis name for saving
if do_all_actions
    analysisname='Fig3_RewRates_AllActs_Exploratory';
else
    analysisname='Fig3_RewRates_ExplActs_Exploratory';
end

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

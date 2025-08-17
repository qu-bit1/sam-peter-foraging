% Code to reproduce number of exploit actions before leaving as a function of free or forced choice conditions (Figure 4B)
% in Hall-McMaster, Dayan & Schuck: Control over patch encounters changes foraging behaviour
% Max Planck Institute for Human Development, December 2020


%To run this, ensure your current directory is the Fig6 folder.
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
%exclude=[33 43 44 50 61 68]; % just exclude overharvesters

sublist=setdiff(sublist,exclude);
nsubs=length(sublist);

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
        
        sl_idx=[];  sl_idx=find(dat.currentPatchReplenishRate(idx)==0.05);
        mid_idx=[]; mid_idx=find(dat.currentPatchReplenishRate(idx)==0.10);
        fst_idx=[]; fst_idx=find(dat.currentPatchReplenishRate(idx)==0.15);
        
        switch cond
            case 1
                forced_slowPatRew=vertcat(forced_slowPatRew,mean(dat.num_exploit_actions(idx(sl_idx))));
                forced_midPatRew=vertcat(forced_midPatRew,mean(dat.num_exploit_actions(idx(mid_idx))));
                forced_fastPatRew=vertcat(forced_fastPatRew,mean(dat.num_exploit_actions(idx(fst_idx))));
                
            case 2
                free_slowPatRew=vertcat(free_slowPatRew,mean(dat.num_exploit_actions(idx(sl_idx))));
                free_midPatRew=vertcat(free_midPatRew,mean(dat.num_exploit_actions(idx(mid_idx))));
                free_fastPatRew=vertcat(free_fastPatRew,mean(dat.num_exploit_actions(idx(fst_idx)))); 
        end
    end
    
end

%% Plot the data and perform statistical tests

% organise data 
dat_plt(:,1)=forced_slowPatRew; dat_plt(:,4)=free_slowPatRew;
dat_plt(:,2)=forced_midPatRew;  dat_plt(:,5)=free_midPatRew;
dat_plt(:,3)=forced_fastPatRew; dat_plt(:,6)=free_fastPatRew;

% save data as csv file
T=array2table(dat_plt);
T.Properties.VariableNames = {'slow_patch_forced_choice','medium_patch_forced_choice','fast_patch_forced_choice', ...
                              'slow_patch_free_choice','medium_patch_free_choice','fast_patch_free_choice'};
if ~exist('csv_output','dir'), mkdir('csv_output'); end
writetable(T,['csv_output' fs 'actions_before_leaving.csv']);

% generate figure
settings.disp_subdat=1; % Do you want to plot individual participant points on the bar charts?
settings.setylim=[0 12;4 7]; % how high do you want the Y axis in each subplot?
settings.exploratory=1; % is this analysis exploratory?
settings.numtests=3;    % how many exploratory tests do you want to correct over?
settings.dolegend=1;
[h,dat_means, dat_SDs, stat_out]=create_lineplot(dat_plt,settings,'Exploit Actions Before Leaving');

% add lines from simulated means
hold on
agent_means=Fig4B_agent();
agent_means=squeeze(mean(agent_means));
agent_col=[0.4,0.4,0.4];

for add_mean=1:3
    plot([add_mean-0.09 add_mean-0.01],[agent_means(add_mean) agent_means(add_mean)], 'color',agent_col,'LineWidth',5);
    plot([add_mean+0.01 add_mean+0.09],[agent_means(add_mean+3) agent_means(add_mean+3)],'color',agent_col,'LineWidth',5); 
end
legend([h(1:2)],'Forced Choice', 'Free Choice');
legend('off');

% store stats info in a structure
% means
stats.slw.forced.mean=dat_means(1,:); stats.slw.free.mean=dat_means(4,:);
stats.mid.forced.mean=dat_means(2,:); stats.mid.free.mean=dat_means(5,:);
stats.fst.forced.mean=dat_means(3,:); stats.fst.free.mean=dat_means(6,:);
% mean for each choice condition
stats.forced.mean=mean(mean([dat_plt(:,1) dat_plt(:,2) dat_plt(:,3)],2),1); % mean over columns, then rows
stats.free.mean=mean(mean([dat_plt(:,4) dat_plt(:,5) dat_plt(:,6)],2),1);
% mean for each patch condition
stats.slw.mean=mean(mean([dat_plt(:,1) dat_plt(:,4)],2),1); 
stats.mid.mean=mean(mean([dat_plt(:,2) dat_plt(:,5)],2),1);
stats.fst.mean=mean(mean([dat_plt(:,3) dat_plt(:,6)],2),1);

% SDs
stats.slw.forced.SD=dat_SDs(1,:); stats.slw.free.SD=dat_SDs(4,:);
stats.mid.forced.SD=dat_SDs(2,:); stats.mid.free.SD=dat_SDs(5,:);
stats.fst.forced.SD=dat_SDs(3,:); stats.fst.free.SD=dat_SDs(6,:);
% SDs for each choice condition
stats.forced.SD=std(mean([dat_plt(:,1) dat_plt(:,2) dat_plt(:,3)],2),1); % mean over columns, then SD
stats.free.SD=std(mean([dat_plt(:,4) dat_plt(:,5) dat_plt(:,6)],2),1);
% SDs for each patch condition
stats.slw.SD=std(mean([dat_plt(:,1) dat_plt(:,4)],2),1); 
stats.mid.SD=std(mean([dat_plt(:,2) dat_plt(:,5)],2),1);
stats.fst.SD=std(mean([dat_plt(:,3) dat_plt(:,6)],2),1);

% tests for main effect of patch type
mvSlw=[dat_plt(:,1)-dat_plt(:,4)];
mvMid=[dat_plt(:,2)-dat_plt(:,5)];
mvFst=[dat_plt(:,3)-dat_plt(:,6)];
[h,pSlw,CI,statSlw]=ttest(mvSlw); pSlw=pSlw*3;  % get Bonferroni corrected p (Jafari & Ansari-Pour, 2019).
[h,pMid,CI,statMid]=ttest(mvMid); pMid=pMid*3;
[h,pFst,CI,statFst]=ttest(mvFst); pFst=pFst*3;

% store results
stats.Fst.p=pFst; stats.Fst.df=statFst.df; stats.Fst.tstat=statFst.tstat;
stats.Mid.p=pMid; stats.Mid.df=statMid.df; stats.Mid.tstat=statMid.tstat;
stats.Slw.p=pSlw; stats.Slw.df=statSlw.df; stats.Slw.tstat=statSlw.tstat;

% perform 2x3 repeated measures anova
datatable=array2table(dat_plt);
datatable.Properties.VariableNames = {'forced_slw','forced_mid','forced_fst','free_slw','free_mid','free_fst'};
WithinStructure = table([1 1 1 2 2 2]',[1 2 3 1 2 3]','VariableNames',{'ForFre','Replen'});
WithinStructure.ForFre = categorical(WithinStructure.ForFre);
WithinStructure.Replen = categorical(WithinStructure.Replen);
rm = fitrm(datatable, 'forced_slw,forced_mid,forced_fst,free_slw,free_mid,free_fst~1','WithinDesign',WithinStructure);
ranovatable = ranova(rm,'WithinModel','ForFre*Replen');
stats.anova.table=ranovatable;

% set analysis name for saving
analysisname='Fig4B_actsB4Leaving';

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

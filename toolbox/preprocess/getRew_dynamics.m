% Code to plot reward dynamics for the three patches for each action in a block.

%To run this, ensure your current directory is the preprocess folder.
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
savepath = pwd;
addpath(datapath);
addpath(toolpath);

% create vectors to store condition data
pat_rews=[];

% define participants to analyse. Exclude participants rejected during
% preprocessing
%sublist=[1:70];
%exclude=[12 33 43 44 50 54 58 61 68 70];
%sublist=setdiff(sublist,exclude);

%sublist=[12 33 43 44 50 54 58 61 68 70];
sublist=[56 65]; % randomly selected reference participants
nsubs=length(sublist);

for iblk=1:4

for isub=1:nsubs
    
    sub=sublist(isub);
    
    % load file
    dat=[];
    dat=load(['sub' num2str(sub) '_data.mat']);
    dat=dat.dat;
    
    % find trials where an action was performed
    idx=[];
    idx=find(dat.blk_number==iblk & (strcmp(dat.patch_selection_key,'f') ...
                                 | strcmp(dat.patch_selection_key,'j') ...
                                 | strcmp(dat.patch_selection_key,'k') ...
                                 | strcmp(dat.exploit_phase_key,'space') ...
                                 | strcmp(dat.exploit_phase_key,'s') ...
                                 ));
                             
    if dat.blk_type(idx(1))==1
        cond='Forced choice';
        cond_short='forced';
    elseif dat.blk_type(idx(1))==2
        cond='Free choice';
        cond_short='free';
    end
        
    pat_rews(:,1)=dat.patchValueSlow(idx);
    pat_rews(:,2)=dat.patchValueMedium(idx);
    pat_rews(:,3)=dat.patchValueFast(idx);                             
                             
    idx_leave=[];
    idx_leave=find(dat.blk_number==iblk & (strcmp(dat.exploit_phase_key,'s')));
    
    leave_vec=[];
    for k=1:size(idx_leave,1)
        t=find(idx==idx_leave(k));
        leave_vec=vertcat(leave_vec,t); 
    end
       

       
         %% plot reward dynamics
         x=[]; y=[]; max_actions=200;
         x=[1:max_actions;1:max_actions;1:max_actions]';
         y=pat_rews(:,:);

         z=figure
         plot(x,y);
         hold on
         
         for i=1:size(leave_vec,1)
             plot([leave_vec(i) leave_vec(i)], [0 100],'color','k');
         end
         
         title(['Participant: ' num2str(sub) ', Block: ' num2str(iblk) '/4, ' 'Condition: ' cond], 'FontSize', 18)
         ylabel('Current Reward', 'FontSize', 18);
         xlabel('Action in block', 'FontSize', 18);
         legend({'Slow patch','Medium patch','Fast patch'},'FontSize',15);
         legend('location','southeast');
         
         % save figure?
         do_print=1;
         analysisname=['sub' num2str(sub) '_blk' num2str(iblk) '_cond' cond_short];
         if do_print
             figpath =  [savepath '/figures/rejectedSubDynamics']; if ~exist(figpath,'dir'), mkdir(figpath); end
             fname = sprintf('%s/%s',figpath,analysisname);
             fname = sprintf('%s_%s',fname,datestr(now,'yyyymmdd-HHMM'));
             set(z, 'Units', 'Inches');
             pos = get(z,'Position');
             set(z,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[pos(3),pos(4)]);
             print(gcf,'-dpdf','-painters',fname);
         end
end
end     
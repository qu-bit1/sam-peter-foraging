% Code to do minor cleaning of data files.
% When leaving a patch, the task code saves the reward that would have been
% gained for exploiting. This reward is not shown to participants during
% the task and it does not effect the total reward counters (e.g. blk_points). 
% This code removes reward saved during leave decisions from the data file,
% to avoid errors when using the datafile for analysis.

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
datapath = [path 'data'];
addpath(datapath);

% define participant list
sublist=[1:70];
nsubs=length(sublist);

% loop over participants
for isub=1:nsubs
    sub=sublist(isub);
    
    % load file
    dat=[];
    dat=load(['sub' num2str(sub) '_data.mat']);
    dat=dat.dat;
    
    % find each leave decision
    idx=[];
    idx=find(strcmp(dat.exploit_phase_key,'s'));
    
    % find the entry after each leave decision
    idx_b=[];
    idx_b=idx+1;
    if size(idx_b,1)>size(idx,1)
       idx_b=idx_b(1:size(idx,1)); 
    end
    
    % clean up the affected columns
    dat.actual_rew_gain(idx,:)=0;
    dat.rew_fbk_displayed(idx,:)=0;
    
    dat.actual_rew_gain(idx_b,:)=0;
    dat.rew_fbk_displayed(idx_b,:)=0;
    
    % find rows where an action was taken
    %idx=[];
    %idx=find( (strcmp(dat.exploit_phase_key,'s') | strcmp(dat.exploit_phase_key,'SPACE')) ...
    %         | (strcmp(dat.patch_selection_key,'f') | strcmp(dat.patch_selection_key,'j') ...
    %         | strcmp(dat.patch_selection_key,'k')));    
    %dat=dat(idx,:);
    
    % save the data again
    do_save=1;
    if do_save
        savename=['sub' num2str(sub) '_data.mat'];
        save([datapath fs savename],'dat');

        %savename=['sub' num2str(sub) '_data.csv'];
        %writetable(dat,[datapath fs savename]);
    end

end


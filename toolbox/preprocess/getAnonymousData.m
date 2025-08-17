% Code to remove identifying information, such as Prolific
% IDs from the raw data files.

%To run this, ensure your current directory is the preprocess folder.
clear all
close all

%% setup
% set path to raw data folder
datadir='';
addpath(datadir);
files = dir(fullfile(datadir, '*.csv'));

% set path for saving cleaned up files
mydir    = pwd;
if ispc
    folders   = strfind(mydir,'\');
else
    folders   = strfind(mydir,'/');
end
savepath = mydir(1:folders(end-1));
fs = filesep;

% display the file names
%files.name

sub=0;
for i=1:size(files,1)
    
    % load file
    dat=[];
    dat=readtable(files(i,1).name);
    
    % skip if there's no Prolific ID
    if ~ismember('PROLIFIC_PID', dat.Properties.VariableNames)
        continue
    end

    % skip if the file is too small for the participant to have finished
    if size(dat,1)<30
        continue
    end
    
    sub=sub+1;
    add_vec=ones(size(dat,1),1);
    
    % if we haven't skipped, do the following:
    % replace particpant column with anonymised number
    dat.participant=add_vec*sub;
    
    % remove the Prolific ID column
    col=find(strcmp(dat.Properties.VariableNames,'PROLIFIC_PID'));
    dat(:,col)=[];
    
    % remove the session ID column
    col=find(strcmp(dat.Properties.VariableNames,'SESSION_ID'));
    dat(:,col)=[];
    
    % remove the study ID column
    col=find(strcmp(dat.Properties.VariableNames,'STUDY_ID'));
    dat(:,col)=[];
    
    % save the cleaned up file?
    savename=['sub' num2str(sub) '_data.mat'];
    do_save=0;
    if do_save
        savefolder = [savepath 'data']; if ~exist(statfolder,'dir'); mkdir(statfolder); end
        save([savefolder fs savename],'dat');
    end
    
end
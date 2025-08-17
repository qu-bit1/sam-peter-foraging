function [ifleave,patchoice]=leaver(trial,ch,pass,free,lastime,lastval,replete,taskcnt)
global testout;
% [ifleave,patchoice]=leaver(trial,ch,pass,free,lastime,lastval,replete)
% should we leave a patch; and where do we go?
% trial is trial number to index the python arrays
% ch is current patch 
% pass is the likelihoods that each patch has a replenishment rate in
%      replete
% free = 1 for free; = 0 for forced
% lasttime, lastval are to work out the current values of the patches
% replete are the replenishment rates
% ifleave is 0 or 1 for stay/go
% patchoice is chocie of where to go
% here leave(trial,ch,val(1),val(2),val(3)) is the python-produced policy
% that determines whether or not to leave on trial, occupying patch ch and
% when the values of all patches are val(1:3)
% so the code has to work out estimates of the current values - using the
% MAP values of the chances
% choose says where to go (in the case that it's forced)
global leave choose;
order=[1 2 3; 1 3 2; 2 1 3; 2 3 1; 3 1 2 ; 3 2 1];
lik=zeros(1,6);
for i=1:6
    lik(i)=prod(diag(pass(1:3,order(i,:))));
end
lik = lik/sum(lik);
[mx,ors]=max(lik); % the MAP order
mul = (1-replete(order(ors,:))).^lastime;
lastval(lastval==-1) = testout; % if have never seen a patch, then assume 80
indices = round(lastval.*mul + 100*(1-mul));
%ifleave = leave(trial,ch,indices(1),indices(2),indices(3));
ifleave = leave.Data(indices(3),indices(2),indices(1),taskcnt,ch,trial);
if ((-sum(lik.*log(lik+1e-20)) > log(3)) && (taskcnt > 3))
    ifleave=1;  % if entropy of the order is too high, then leave early for info
end
if free==1
    patchoice = choose(indices(3),indices(2),indices(1),ch,trial)+1;
else
    % forced choice
    patchoice = 1:3;
    patchoice = [patchoice(1:(ch-1)) patchoice((ch+1):end)];
    patchoice = patchoice(1 + (rand > 0.5));
end


function [stats,passes] = agent(free,samps,loader)
  % stats = agent(free,samps,loader)
  % free = 1 for free choice (choice.mat)
  % free = 0 for forced choice (nochoice.mat)
  % loader = 1 to load from free_101.hdf5 or forced_101.hdf5
  % loader = 0 to assume that global variables are filled up already
  % samp = number of 'subjects'
  % stats(samps,200,7) for 200 trials per subject
  % all reoordering for stats as replete [0.05 0.1 0.15]
  % stats(.,.,1)  current patch (or future patch)
  % stats(.,.,2)  0=exploit; 1=leave; -1=travel/arrive
  % stats(.,.,3)  when leave, destination patch or -1
  % stats(.,.,4)  reward on that trial (or 0)
  % stats(.,.,5)  state of patch 1
  % stats(.,.,6)  state of patch 2
  % stats(.,.,7)  state of patch 3
  
global choose leave testout;
if loader
  if free==1
    leave=hdf5read('free_101.hdf5','/leave'); % precalculated
    choose=hdf5read('free_101.hdf5','/choose'); % precalculated
  else
    leave=hdf5read('forced_101.hdf5','/leave'); % precalculated
  end
end

if (testout > 0) % testout to test if initialization matters
    testout = testout;
else
    testout = 95;
end

% this is assumed starting value for all patches that seems to maximise the
% mean reward gained per agent, acertained by simplying running the
% agent function with different values of testout
% starting values doesn't have much influence on free choice agents
% there's slightly more impact in forced choice but it's very marginal

sizes = size(leave.Data);
replete=[.05 .1 .15];
deplete = 0.95;
states=sizes(3);  % 101 for your patches
trials=sizes(6);  % 200 per subject

taskstate=nan(1,3);
taskrep=nan(1,3);
taskcnt=nan(1);
taskorder=nan(1,3);

stats=zeros(samps,trials,7);
passes=zeros(samps,trials,9);
for samp = 1:samps
%     fprintf('%4d: ',samp);
    [rew,taskstate,taskrep,taskcnt,taskorder]=task(-1,0,taskstate,taskrep,taskcnt,taskorder);
    % initialize
    pass = ones(3)/3; % likelihoods
    lastval = -ones(1,3);
    lastime = -1 + zeros(1,3);
    first=1;
    for trial=1:trials
        stats(samp,trial,4+taskorder)=taskstate;
        if first
            % first trial for a new subject
            ch = 1+floor(3*rand()); % random starting patch
            stats(samp,trial,1:4)=[taskorder(ch)-1 1 taskorder(ch)-1 0];
            lastime = lastime+1; % all times increment
            travel=0;            % we're on the way to patch ch
            first=0;             % no longer the first trial
            arrive=1;
            [rew,taskstate,taskrep,taskcnt,taskorder] = task(1,ch,taskstate,taskrep,taskcnt,taskorder);
                                 % replenish all the sites
        elseif travel==1
            % in transit; no reward
            stats(samp,trial,1:4)=[taskorder(ch)-1 -1 0 0];
            travel=0; % no longer in transit
            arrive=1; % about to arrive
            lastime = lastime+1;
            [rew,taskstate,taskrep,taskcnt,taskorder] = task(1,ch,taskstate,taskrep,taskcnt,taskorder);
                                 % replenish all the sites
        elseif arrive==1
            % first arrival at a new patch
            [rew,taskstate,taskrep,taskcnt,taskorder] = task(2,ch,taskstate,taskrep,taskcnt,taskorder);
                                  % get rewards; replenish other patches
            stats(samp,trial,1:4)=[taskorder(ch)-1 0 -1 rew];
            pass(ch,:)=poster(rew,lastime(ch),lastval(ch),pass(ch,:),replete);
                                  % update likelihood for new info about
                                  % rew at patch ch
            arrive=0; % now exploit
            lastime=lastime+1;
            lastime(ch)=0; % since we are exploiting ch
            lastval(ch)=stats(samp,trial,4)*deplete;
                           % if leave, then last known value at ch including the effect of depletion 
        else
            % decide whether to exploit or leave
            [ifleave,patchoice]=leaver(trial,ch,pass,free,lastime,lastval,replete,taskcnt);
                    % here's the decidion
            lastime = lastime+1;
            if ifleave==1
                % we're off, no reward, replenish
                stats(samp,trial,1:4)=[taskorder(ch)-1 1 taskorder(patchoice)-1 0];
                ch = patchoice;
                travel = 1;
                [rew,taskstate,taskrep,taskcnt,taskorder] = task(1,ch,taskstate,taskrep,taskcnt,taskorder);
            else
                % we're exploiting; reward; deplete, replenish
                [rew,taskstate,taskrep,taskcnt,taskorder] = task(2,ch,taskstate,taskrep,taskcnt,taskorder);
                stats(samp,trial,1:4)=[taskorder(ch)-1 0 -1 rew];
                lastime(ch)=0;
                lastval(ch)=stats(samp,trial,4)*(deplete^(taskcnt-1));
                            % if leave, then last known value at ch including the effect of depletion 
            end
        end
        passes(samp,trial,:)=pass(:);
    end
end


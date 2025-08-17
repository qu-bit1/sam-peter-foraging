function [rew,taskstate,taskrep,taskcnt,taskorder]=task(command,patch,taskstate,taskrep,taskcnt,taskorder)
  %  [rew,taskstate,taskrep,taskcnt]=task(command,patch,taskstate,taskrep,taskcnt)
  %  runs the task
  %  command=-1 creates random replenishment order in taskrep
  %                 and random initial states
  %  command=1  when leaving, travelling, just replenish
  %  command=2  exploit patch, and replenish others
  %  rew is the reward when it exists
  %  taskstate and taskrep are propagated as task states
  %  taskcnt counts the number of depletions
deplete = 0.95;
replete=[0.05 0.1 0.15];
order=[1 2 3; 1 3 2; 2 1 3; 2 3 1; 3 1 2 ; 3 2 1];
rew=0;
switch(command)
    case -1
        % initialize
        ord = ceil(rand()*6);
        taskorder=order(ord,:);
        taskrep = replete(taskorder);
        taskstate = floor(69 + 11*rand(1,3));
        tasktrial=1;
% 	fprintf('replenish: ');
% 	fprintf('%4.2f ',taskrep);
% 	fprintf('  state: ');
% 	fprintf('%2d ',taskstate);
% 	fprintf('\n');
    case 1
	% replenish
        taskstate = taskstate + taskrep.*(100 - taskstate);
	taskcnt = 1;
    case 2
	% exploit patch and replenish others
        rew = floor(taskstate(patch));
        sav=taskstate(patch);
        taskstate = taskstate + taskrep.*(100 - taskstate);
        taskstate(patch) = sav * (deplete^taskcnt);
        taskcnt = taskcnt + 1;
end

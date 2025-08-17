function [s,p] = performPermTest(data1,data2,nperms)

datamat=[data1 data2];
permCol=randi(2,60,nperms);
tvals=zeros(nperms,1);

% run permutations
for i=1:nperms
% for each permutation, randomly switch the data for about half the partcipants
cpermCol=permCol(:,i);
pdat=datamat;
pdat(cpermCol==2,:)=flip(pdat(cpermCol==2,:),2);
[h,p,ci,stats]=ttest(pdat(:,1),pdat(:,2));
tvals(i,1)=abs(stats.tstat);
end

% perform the true ttest
[h_tr,p_tr,ci_tr,stats_tr]=ttest(datamat(:,1),datamat(:,2));

% determine the critical t-value
critical_val = prctile(tvals,95);

% is the true test significant?
tr_t=abs(stats_tr.tstat);
s = tr_t>critical_val;

% what the p-value for the true t-stat
per = invprctile(tvals,tr_t);
if per==100 || per>=99.99
    p=1/nperms;
else
    p=(100-per)/100;
end

end
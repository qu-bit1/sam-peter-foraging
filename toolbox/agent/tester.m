global testout;

testos=90:100;
ntestos=length(testos);
nn=5000;
mvs=zeros(2,ntestos);
for i=1:ntestos
  testout=testos(i);
  stats=agent(1,nn,0);
  mvs(1,i)=mean(sum(squeeze(stats(:,:,4)),2))/200;
  mvs(2,i)=std(sum(squeeze(stats(:,:,4)),2)/200)/sqrt(nn);
  fprintf('%3d : %8.5f : %8.5f\n',testout,mvs(1,i),mvs(2,i));
end

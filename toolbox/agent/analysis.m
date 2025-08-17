trans=zeros(2,2000,3,2);
for i=1:2000
    c=squeeze(statsc(i,:,:));
    lev=find(round(c(:,2))==1);
    for k=1:length(lev)
        [tmp,imax]=max(c(lev(k),5:7));
        if ((1+round(c(lev(k),3)))==imax)
            trans(1,i,c(lev(k),1)+1,1)=trans(1,i,c(lev(k),1)+1,1)+1;
        else
            trans(1,i,c(lev(k),1)+1,2)=trans(1,i,c(lev(k),1)+1,2)+1;
        end
    end
    c=squeeze(statsnc(i,:,:));
    lev=find(round(c(:,2))==1);
    for k=1:length(lev)
        [tmp,imax]=max(c(lev(k),5:7));
        if ((1+round(c(lev(k),3)))==imax)
            trans(2,i,c(lev(k),1)+1,1)=trans(2,i,c(lev(k),1)+1,1)+1;
        else
            trans(2,i,c(lev(k),1)+1,2)=trans(2,i,c(lev(k),1)+1,2)+1;
        end
    end
end

%clf;
c=trans(:,:,:,1)./sum(trans,4);


nums=zeros(2,2000,3);
for i=1:2000
    ind=find(round(squeeze(statsc(i,:,2)))==1);
    nums(1,i,:)=hist(round(squeeze(statsc(i,ind,3))),0:2);
    nums(1,i,:)=nums(1,i,:)/sum(nums(1,i,:));
    ind=find(round(squeeze(statsnc(i,:,2)))==1);
    nums(2,i,:)=hist(round(squeeze(statsnc(i,ind,3))),0:2);
    nums(2,i,:)=nums(2,i,:)/sum(nums(2,i,:));
end

rews=zeros(2,2,2000);
for i=1:2000
    ind=find(round(squeeze(statsc(i,:,2)))==0);
    rews(1,1,i)=sum(statsc(i,ind,4));
    rews(1,2,i)=length(ind);
    ind=find(round(squeeze(statsnc(i,:,2)))==0);
    rews(2,1,i)=sum(statsnc(i,ind,4));
    rews(2,2,i)=length(ind);
end

rews=zeros(2,2000,3);
for i=1:2000
    ind=find(round(squeeze(statsc(i,2:200,2)))==1);
    tmp=squeeze(statsc(i,ind,[1 4]));
    for k=1:3
        rews(1,i,k)=mean(tmp(tmp(:,1)==(k-1),2));
    end
    ind=find(round(squeeze(statsnc(i,2:200,2)))==1);
    tmp=squeeze(statsnc(i,ind,[1 4]));
    for k=1:3
        rews(2,i,k)=mean(tmp(tmp(:,1)==(k-1),2));
    end
end


rews=zeros(2,2000);
rews(1,:)=sum(squeeze(statsc(:,:,4)),2)'/200;
rews(2,:)=sum(squeeze(statsnc(:,:,4)),2)'/200;
figure
bar(mean(rews,2));
hold on;
plot(ones(1,2000),rews(1,:),'.');
plot(2*ones(1,2000),rews(2,:),'.');







        
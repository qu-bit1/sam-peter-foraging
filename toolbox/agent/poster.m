function upd = poster(rew,lastime,lastval,pss,replete)
% upd = poster(rew,lastime,lastval,pss,replete)
% updates the likelihood for a single patch for replenishment rate
% rew is the observed reward
% lastime is a counter since the last time a patch was visited
% lastval is the last value recorded for a patch (deplete*last reward)
%         or -1 if it hasn't been visited yet
% pss is a vector of normalized likelihoods of a patch's rewards given the
%     times
% replete is the vector of possible replenishment rates
%
% the likelihood uses Gaussians to avoid worrying about rounding
    mul = (1-replete).^lastime;
    if (lastval ==  -1)
        % if the patch has never been visited
        vals=69:79; % possible starting values
        nval = mul'*vals + 100*(1-mul');
        like = normpdf(rew,nval,1);
        like = sum(like,2);
        upd = pss .* like';
        upd = upd/sum(upd);
    else
        nval = mul*lastval + 100*(1-mul);
        like = normpdf(rew,nval,1);
        upd = pss .* like;
        upd = upd/sum(upd);
    end
    
    
    
        
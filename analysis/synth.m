%% generate binary synthetic networks
sn_b = {...
    net.generate('erdosrenyi','n',2e2,'p',.13,'directed',true),...
    net.generate('erdosrenyi','n',2e2,'p',.132,'directed',true),...
    net.generate('erdosrenyi','n',2e2,'p',.134,'directed',true),...
    net.generate('hiermodsmallworld','mx_lvl',8,'e',2,'sz_cl',2),...
    net.generate('hiermodsmallworld','mx_lvl',8,'e',1.8,'sz_cl',2)...
    net.generate('hiermodsmallworld','mx_lvl',8,'e',1.7,'sz_cl',2)...
    };
%% distribute weights, delta + truncated gaussian
wd_sig = .042 : .002 : .048;
sn_w = cell(length(sn_b),length(wd_sig));
for i = 1 : length(sn_b)
    for j = 1 : length(wd_sig)
        sn_w{i,j} = net.distr_weights(sn_b{i}.A,'truncnorm','mu',0,...
            'sigma',wd_sig(j),'range',[0 2]);
    end
end; clear i j
%% check row col sums
cv_me = zeros(length(sn_b),length(wd_sig));
for i = 1 : length(sn_b)
    for j = 1 : length(wd_sig)
        cv_me(i,j) = max(eig(sn_w{i,j}.A));
    end
end; clear i j
disp([0 1:length(wd_sig); (1:length(sn_b))' cv_me])
%% set parameters
av_T = 1e3;
av_K = 3e4;
%% simulate
durs = cell(length(sn_b),length(wd_sig));
disp(repmat('-',[1 50]))
for i = 1 : length(sn_b)
    for j = 1 : length(wd_sig)
        disp(['Simulating topology ' num2str(i) '/' ...
            num2str(length(sn_b)) ' & sig=' num2str(wd_sig(j))])
        [x0,Px0] = pings_single(size(sn_w{i,j}.A,1));
        x = avl_smp_many(x0,Px0,sn_w{i,j}.A,av_T,av_K);
        durs{i,j} = avl_durations_cell(x);
    end
end; clear i j x0 Px0 x
 %% mle - power law with exponential cutoff
eq_c = @(a,l,xm) l.^(1-a) ./ igamma(1-a,l.*xm);
eq_f = @(x,a,l,xm) (x/xm).^-a .* exp(-l.*x);
eq_p = @(x,a,s) eq_c(a,1/s,1) .* eq_f(x,a,1/s,1);
pl_p = zeros(length(sn_b),2,length(wd_sig));
pl_ci = zeros(2,2,length(sn_b),length(wd_sig));
for i = 1 : length(sn_b)
    for j = 1 : length(wd_sig)
        disp(['Calculating MLE for topology ' num2str(i) '/'...
            num2str(length(sn_b)) ' & sig=' num2str(wd_sig(j))])
        [pl_p(i,:,j),pl_ci(:,:,i,j)] = mle(durs{i,j},'pdf',eq_p,...
            'start',[3 2],'LowerBound',[.1 1],'UpperBound',[20 av_T]);
    end
end; clear i j
%% plot
for i = 1 : length(sn_b)
    for j = 1 : length(wd_sig)
%         x = unique(durs{i,j});
%         e = [x av_T+1];
%         y = histcounts(durs{i,j},e) / length(durs{i,j});
        x = 10.^(0:.1:log10(av_T));
        e = [x av_T+1];
        y = histcounts(durs{i,j},e) ./ diff(e) / length(durs{i,j});
        clf
        subplot(1,3,1); imagesc(sn_w{i,j}.A); prettify; colorbar
        title(['topology: ' sn_b{i}.topology ', sig=' num2str(wd_sig(j))])
        subplot(1,3,2); histogram(sn_w{i,j}.A(sn_w{i,j}.A>0)); prettify
        title('weight distribution')
        subplot(1,3,3); loglog(x,y,'.'); hold on;
        loglog(x,eq_p(x,pl_p(i,1,j),pl_p(i,2,j)),'-'); prettify;
        title(['\alpha=' num2str(pl_p(i,1,j)) ...
            ', s=' num2str(num2str(pl_p(i,2,j)))])
        axis([0 av_T 1/av_K 1])
        pause
    end
end; clear i j x e y

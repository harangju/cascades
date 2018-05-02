




%% avalanches
iter = 1e3; dur = 6;
[Y, pat] = ping_nodes(A, B, iter, dur); beep
% [Y, pat] = ping_nodes_analytical(A, B, dur);

%% avalanche with patterns
iter = 3e2; dur = 10;
% patterns = {{n(randperm(length(n),2))},...
%     {n(randperm(length(n),2))}, ...
%     {n(randperm(length(n),2))}};
% patterns = {{randperm(size(A_conn,1),2)},...
%     {randperm(size(A_conn,1),2)}, ...
%     {randperm(size(A_conn,1),2)}};
patterns = {{n(randperm(length(n),2))},...
    {randperm(size(A_conn,1),2)}, ...
    {randperm(size(A_conn,1),2)}};
probs = ones(1,length(patterns)) / length(patterns);
[Y, pat] = trigger_many_avalanches(A_conn, ones(size(A_conn,1),1),...
    patterns, probs, dur, iter);

%% average avalanches
nodes_in = find(B)';
Y_pat = zeros(size(Y,1), size(Y,2), length(nodes_in));
for i = 1:length(nodes_in)
    Y_pat(:,:,i) = mean(Y(:,:,pat==i), 3);
end; clear i
%% distance measurement
% dist_type = 'cosine';
dist_type = 'euclidean';
dist = zeros(length(nodes_in), length(nodes_in), dur);
for t = 1 : dur
    % pdist, [observations X variables]
    % Y, [neurons X t X trials] -> [trials X neurons]
    dist(:,:,t) = squareform(pdist(squeeze(Y_pat(:,t,:))', dist_type));
end; clear t
dist(isnan(dist)) = 0;
%%
% nodes = rich_club_nodes(A,3);
% nodes = 1:length(B);
nodes = 1:length(nodes_in);
% nodes = nodes_in(mean(dist(:,:,2),1)>0);
%% plot distances
for i = 1 : dur
    subplot(3,2,i)
    imagesc(dist(nodes,nodes,i)); title(i)
    prettify; colorbar; axis square
    colormap jet; caxis([0 1])
end; clear i
%% mutual information
C = ones(size(B));
mi_info = mutual_info(Y,pat,C);
[mi_max, mi_node, mi_time] = mutual_info_max(mi_info,C,1);
%%
histogram(mi_max,30)
prettify; axis square
%%
% nodes = mi_node(mi_max<.3);
%%
code = pop_code(Y,nodes);
mi_pop = zeros(1,dur);
for i = 1 : dur
    mi_pop(i) = mi(pat',code(i,:)');
end; clear i
yyaxis left
plot(mi_pop, 'LineWidth', 2)
prettify; axis square; xlabel('t'); ylabel('MI')
axis([0 dur+1 0 ceil(max(mi_pop))])
%%
yyaxis right
plot(squeeze(mean(mean(dist(nodes,nodes,:),2),1)),'LineWidth',2)
ylabel(dist_type); ylim([0 1])
%% 


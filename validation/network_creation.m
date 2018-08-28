
%% graph 1, WRG
p = default_network_parameters;
p.N = 100;
p.frac_conn = 0.2;
A = network_create(p);
%% graph 2, RL
p = default_network_parameters;
p.N = 100;
p.graph_type = 'RL';
A = network_create(p);
%% graph 3, WRG, gaussian
p = default_network_parameters;
p.N = 100;
p.weighting = 'gaussian';
p.critical_branching = false;
A = network_create(p);

%% view graph
figure(1)
imagesc(A); prettify; colorbar
figure(2)
histogram(A(A>0),30); prettify
xlabel('weights'); ylabel('# edges')
figure(3)
histogram()

%% network verification
disp(['Fractional connectivity: ' ...
    num2str(p.frac_conn) ' (desired), ' ...
    num2str(mean(A(:)>0)) ' (actual)'])


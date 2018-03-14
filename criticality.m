

%% driven mode
% given A, B
iter = 1e4; dur = 10;
[Y, pat] = ping_nodes(A, B, iter, dur);

%% spontaneous mode
p_spont = 0.0001;
iter = 1e5;
Y_cont = spontaneous_avalanches(A, B, p_spont, iter);
Y = find_avalanches(Y_cont);
beep

%% exponential fit of avalanche size
bins = 20;
[s, e] = avalanche_size_distr_log(Y, bins);
p = avalanche_size_distr_fit_power(e(2:end), s/sum(s));
disp(['Slope: ' num2str(p(1))])
scatter(e(2:end),log10(s/sum(s)),'filled'); hold on
x = 0:1e-2:1.3;
plot(x, p(1)*x + p(2)); hold off
prettify; axis square; axis([0 1.5 -5 0])

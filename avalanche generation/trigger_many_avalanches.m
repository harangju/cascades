function [Y, pattern_order, sizes] = trigger_many_avalanches(A, B, ...
    patterns, pattern_probs, max_duration, iterations)
%trigger_many_avalanches(A,B,patterns,pattern_probs,dur,iter)Calls 
%trigger_avalanche many times
%   A:
%   B:
%   patterns: cell array of u_t, {[N X t]}
%   pattern_probs: vector of probabilities for presenting the i^(th) pattern
%       sum(u_t_prob) should equal 1
%   max_duration:
%   iterations:
%   returns
%   Y: [num_nodes X max_duration X iterations] matrix
%   pattern_order: order of pattern presentation

if abs(sum(pattern_probs) - 1) > 0.0001
    error('sum(u_t_prob) does not equal 1.')
end

N = size(A,1);
Y = zeros(size(A,1), max_duration, iterations);
prob_cumsum = cumsum(pattern_probs);
pattern_order = zeros(1, iterations);
sizes = zeros(1, iterations);

for i = 1 : iterations
    pat = sum(int8(prob_cumsum < rand)) + 1;
    pattern_order(i) = pat;
%     u_t = inputs(N, patterns{pat}, 2);
    u_t = patterns{pat};
    Y_t = trigger_avalanche3(A, B, u_t, max_duration);
    sizes(i) = avalanche_size(Y_t);
    Y(:, 1:size(Y_t,2), i) = Y_t;
end

end
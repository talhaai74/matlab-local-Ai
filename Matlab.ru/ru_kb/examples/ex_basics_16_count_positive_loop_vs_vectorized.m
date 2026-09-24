% TOPIC: basics
% TITLE: Count positive/negative/zero entries: if/elseif loop vs vectorized find
% SOURCE: Slides 01, pages 38, 40-41 (if/elseif count-positive exercise; vectorization)
% KEYWORDS: if elseif else, for loop, find function, vectorization, count positive entries, sin wave
% PROBLEM:
% Given x = sin(linspace(0,10*pi,100)), how many entries are positive? Solve
% it with an explicit for loop using if/elseif/else to also count negative
% and zero entries, then confirm the positive count with the vectorized
% one-liner count_vec = length(find(x>0)).
% CHECK: count_loop == 49 && count_vec == 49
% CHECK: count_loop == count_vec
% CHECK: pos_n + neg_n + zero_n == 100
% CODE:
x = sin(linspace(0,10*pi,100));
count_loop = 0;
pos_n = 0; neg_n = 0; zero_n = 0;
for k = 1:length(x)
    if x(k) > 0
        count_loop = count_loop + 1;
        pos_n = pos_n + 1;
    elseif x(k) < 0
        neg_n = neg_n + 1;
    else
        zero_n = zero_n + 1;
    end
end
count_vec = length(find(x > 0));
fprintf('positive (loop) = %d, positive (vectorized find) = %d\n', count_loop, count_vec);
fprintf('positive = %d, negative = %d, zero = %d, total = %d\n', pos_n, neg_n, zero_n, pos_n+neg_n+zero_n);

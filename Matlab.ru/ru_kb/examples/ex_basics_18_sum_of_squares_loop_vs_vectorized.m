% TOPIC: basics
% TITLE: Sum of squares 1^2+2^2+...+100^2: for loop versus vectorization
% SOURCE: Slides 01, pages 40-41 (avoiding loops / vectorization exercise)
% KEYWORDS: sum of squares, for loop, vectorization, sum function, efficient coding
% PROBLEM:
% Find the sum 1^2 + 2^2 + 3^2 + ... + 100^2 using an explicit for loop,
% then confirm it with the vectorized one-liner Sum_sq = sum((1:100).^2).
% CHECK: sum_loop == 338350 && sum_vec == 338350
% CHECK: sum_loop == sum_vec
% CODE:
sum_loop = 0;
for n = 1:100
    sum_loop = sum_loop + n^2;
end
sum_vec = sum((1:100).^2);
fprintf('sum 1^2+...+100^2 : loop = %d, vectorized = %d\n', sum_loop, sum_vec);

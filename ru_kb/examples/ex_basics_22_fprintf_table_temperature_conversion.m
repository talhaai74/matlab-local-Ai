% TOPIC: basics
% TITLE: fprintf table: Celsius to Fahrenheit, for loop versus vectorized
% SOURCE: Common textbook problem (not shown on the slides; standard fprintf-table variant)
% KEYWORDS: fprintf table, temperature conversion, celsius fahrenheit, for loop, vectorization, formatted printing
% PROBLEM:
% Print a table converting Celsius temperatures from 0 to 100 in steps of 10
% to Fahrenheit using F = 9/5*C + 32, with column headers, computed once with
% an explicit for loop and once vectorized, and check that both agree.
% CHECK: isequal(F_loop, F_vec)
% CHECK: abs(F_vec(1) - 32) < 1e-9 && abs(F_vec(end) - 212) < 1e-9
% CHECK: numel(C) == 11
% CODE:
C = 0:10:100;
F_loop = zeros(size(C));
for k = 1:length(C)
    F_loop(k) = 9/5*C(k) + 32;
end
F_vec = 9/5*C + 32;

fprintf('%6s %10s\n', 'C', 'F');
for k = 1:length(C)
    fprintf('%6.1f %10.2f\n', C(k), F_vec(k));
end
fprintf('for-loop and vectorized results match: %d\n', isequal(F_loop,F_vec));

% TOPIC: roots
% TITLE: Secant method, four iterations with three pairs of initial guesses
% SOURCE: CE206 slides 02 page 12 (Secant method exercise)
% KEYWORDS: secant method, two initial guesses, four iterations, first positive root, radians
% PROBLEM:
% Apply the secant method to find the first positive root of f(x) = sin x + cos(1 + x^2) - 1,
% where x is in radians. Use four iterations with initial guesses of (i) 1.0 and 3.0,
% (ii) 1.5 and 2.5, and (iii) 1.5 and 2.25.
% CHECK: abs(res(3) - 1.9446) < 0.01
% CHECK: numel(res) == 3
% CODE:
f = @(x) sin(x) + cos(1 + x.^2) - 1;
pairs = [1.0 3.0; 1.5 2.5; 1.5 2.25];
fprintf('f(x) = sin(x) + cos(1 + x^2) - 1 (radians), 4 secant iterations\n');
res = zeros(1, 3);
for k = 1:3
    [r, fr, ea, iter, tab] = root_secant(f, pairs(k,1), pairs(k,2), 0, 4);
    fprintf('\n(%s) x(-1) = %g, x(0) = %g\n', repmat('i', 1, k), pairs(k,1), pairs(k,2));
    fprintf('%5s %12s %12s %12s\n', 'iter', 'x', 'f(x)', 'ea (%)');
    fprintf('%5d %12.6f %12.6f %12.4f\n', tab(:, [1 end-2 end-1 end])');
    fprintf('After 4 iterations: x = %.6f, f(x) = %.3e\n', r, fr);
    res(k) = r;
end
fprintf('\nFirst positive root (fzero): %.6f\n', fzero(f, [1 2.2]));
fprintf('Only guesses (iii) approach this root within 4 iterations; the others move to other roots or diverge.\n');

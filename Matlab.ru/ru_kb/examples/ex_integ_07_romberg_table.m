% TOPIC: integration
% TITLE: Romberg integration to es = 0.5% with the Romberg table and true error
% SOURCE: Chapra Prob. 20.1
% KEYWORDS: romberg integration, richardson extrapolation, romberg table, es = 0.5%, true percent relative error
% PROBLEM:
% Use Romberg integration to evaluate I = integral from 1 to 2 of (x + 1/x)^2 dx to an accuracy of
% es = 0.5%. Present the results as a Romberg table. Use the analytical solution to determine the
% percent relative error of the result and check that et is less than es.
% CHECK: abs(q - 29/6) < 0.01 && ea <= 0.5
% CODE:
f = @(x) (x + 1./x).^2;
[q, ea, iter, R] = integ_romberg(f, 1, 2, 0.5);
fprintf('Romberg table (row k: trapezoid with 2^(k-1) segments, then O(h^4), O(h^6), ...):\n');
for i = 1:size(R, 1)
    fprintf('%12.6f', R(i, 1:size(R, 2) - i + 1));
    fprintf('\n');
end
Itrue = 29/6;                              % x^3/3 + 2x - 1/x from 1 to 2
et = abs((Itrue - q)/Itrue)*100;
fprintf('I = %.6f, ea = %.4f %%, true value = %.6f, et = %.5f %% (< es = 0.5 %%)\n', q, ea, Itrue, et);

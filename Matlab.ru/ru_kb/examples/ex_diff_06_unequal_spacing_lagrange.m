% TOPIC: differentiation
% TITLE: First derivatives of unequally spaced data (3-point Lagrange formula) versus the true derivative
% SOURCE: Chapra Prob. 21.9 (Eq. 21.21)
% KEYWORDS: unequally spaced data, unequal spacing, lagrange polynomial, derivative, eq. 21.21, true derivative, m-file
% PROBLEM:
% Develop an M-file to obtain first-derivative estimates for unequally spaced data and test it with
% x = 0.6 1.5 1.6 2.5 3.5 and f(x) = 0.9036 0.3734 0.3261 0.08422 0.01596, where f(x) = 5x e^(-2x).
% Compare your results with the true derivatives.
% CHECK: abs(d(2) - (-0.484611)) < 1e-5
% CODE:
x = [0.6 1.5 1.6 2.5 3.5];
f = [0.9036 0.3734 0.3261 0.08422 0.01596];
d = lagrangeDerivative(x, f);
dtrue = 5*exp(-2*x).*(1 - 2*x);           % d/dx of 5x e^(-2x)
fprintf('%6s %12s %12s %10s\n', 'x', 'estimate', 'true', 'et (%)');
fprintf('%6.2f %12.5f %12.5f %10.2f\n', [x; d; dtrue; abs((dtrue - d)./dtrue)*100]);
fprintf('Same as ru_lib diff_data: %s\n', mat2str(diff_data(x, f), 5));

function d = lagrangeDerivative(x, f)
% First derivative at every x from the 3-point Lagrange polynomial (Chapra Eq. 21.21)
n = numel(x);
d = zeros(1, n);
for i = 1:n
    if i == 1
        k = [1 2 3];
    elseif i == n
        k = [n-2 n-1 n];
    else
        k = [i-1 i i+1];
    end
    x0 = x(k(1)); x1 = x(k(2)); x2 = x(k(3));
    d(i) = f(k(1))*(2*x(i) - x1 - x2)/((x0 - x1)*(x0 - x2)) ...
         + f(k(2))*(2*x(i) - x0 - x2)/((x1 - x0)*(x1 - x2)) ...
         + f(k(3))*(2*x(i) - x0 - x1)/((x2 - x0)*(x2 - x1));
end
end

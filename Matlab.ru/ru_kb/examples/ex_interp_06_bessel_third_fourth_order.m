% TOPIC: interpolation
% TITLE: Bessel function J1(2.1) by third- and fourth-order interpolating polynomials, true error vs besselj
% SOURCE: Chapra Prob. 17.13
% KEYWORDS: bessel function, besselj, third-order, fourth-order, interpolating polynomial, true percent relative error
% PROBLEM:
% Values of the Bessel function J1: x = 1.8 2.0 2.2 2.4 2.6, J1(x) = 0.5815 0.5767 0.5560 0.5202 0.4708.
% Estimate J1(2.1) using third- and fourth-order interpolating polynomials and determine the percent
% relative error for each case based on the true value from MATLAB's besselj.
% CHECK: abs(J(1) - 0.5682875) < 1e-6 && abs(J(2) - 0.5683039) < 1e-6
% CODE:
x = [1.8 2.0 2.2 2.4 2.6];
Jd = [0.5815 0.5767 0.5560 0.5202 0.4708];
xi = 2.1;
Jtrue = besselj(1, xi);
orders = [3 4];
J = zeros(1, 2);
for k = 1:2
    n = orders(k);
    [~, o] = sort(abs(x - xi));
    idx = sort(o(1:n+1));
    J(k) = interp_newton(x(idx), Jd(idx), xi);
    fprintf('Order %d (x = %s): J1(2.1) = %.7f, et = %.4f %%\n', n, mat2str(x(idx)), J(k), abs((Jtrue - J(k))/Jtrue)*100);
end
fprintf('True value besselj(1, 2.1) = %.7f\n', Jtrue);

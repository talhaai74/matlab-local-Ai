% TOPIC: roots
% TITLE: Dissolved oxygen saturation: temperature for given Osat by bisection (absolute error 0.05 C)
% SOURCE: CE206 slides 02 pages 18-19 (Exercise 2); Chapra Prob. 5.8
% KEYWORDS: dissolved oxygen, saturation concentration, osat, temperature, bisection, absolute error, number of iterations, fill up the table, oxygen
% PROBLEM:
% The saturation concentration of dissolved oxygen in freshwater is
% ln(Osat) = -139.34411 + 1.575701e5/Ta - 6.642308e7/Ta^2 + 1.243800e10/Ta^3 - 8.621949e11/Ta^4
% where Osat is in mg/L and Ta = T + 273.15 (T in C). Fill up the table of temperature for
% Osat = 8, 10 and 12 mg/L using the bisection method with initial guesses 0 and 40 C, for an
% absolute error of 0.05 C. First determine how many iterations are needed, then compare with fzero.
% CHECK: n == 10
% CHECK: all(abs(Tb - [26.75781 15.35156 7.46094]) < 1e-4)
% CHECK: all(abs(Tx - [26.78017 15.38821 7.46519]) < 1e-3)
% CODE:
lnOsat = @(T) -139.34411 + 1.575701e5./(T + 273.15) - 6.642308e7./(T + 273.15).^2 ...
    + 1.243800e10./(T + 273.15).^3 - 8.621949e11./(T + 273.15).^4;
xl = 0; xu = 40; Ead = 0.05;
n = ceil(log2((xu - xl)/Ead));            % bisection iterations for an absolute error Ead
fprintf('Iterations needed: n = log2(%g/%g) = %.4f -> %d\n', xu - xl, Ead, log2((xu - xl)/Ead), n);

O = [8 10 12];
Tb = zeros(size(O)); Tx = zeros(size(O));
for k = 1:numel(O)
    f = @(T) lnOsat(T) - log(O(k));
    Tb(k) = root_bisection(f, xl, xu, 0, n);   % exactly n iterations
    Tx(k) = fzero(f, [xl xu]);
end
fprintf('\n%10s %16s %12s %10s\n', 'Osat(mg/L)', 'Bisection T(C)', 'fzero T(C)', 'Error');
for k = 1:numel(O)
    fprintf('%10g %16.5f %12.5f %10.4f\n', O(k), Tb(k), Tx(k), abs(Tx(k) - Tb(k)));
end
fprintf('All errors are below %.2f C.\n', Ead);

% TOPIC: roots
% TITLE: Roots of polynomials from products; factoring a transfer function with roots()
% SOURCE: Chapra Probs. 6.23 and 6.24
% KEYWORDS: polynomial, roots, poly, conv, deconv, factor, transfer function, numerator, denominator, polyval
% PROBLEM:
% (a) Use MATLAB to form the polynomial f5(x) = (x + 2)(x + 5)(x - 6)(x - 4)(x - 8) and find all its roots.
% (b) The transfer function G(s) = (s^3 + 9s^2 + 26s + 24)/(s^4 + 15s^3 + 77s^2 + 153s + 90).
% Find the roots of the numerator and denominator and write G(s) in factored form
% (s + a1)(s + a2)(s + a3)/((s + b1)(s + b2)(s + b3)(s + b4)).
% CHECK: isequal(sort(round(ra))', [-5 -2 4 6 8])
% CHECK: isequal(sort(round(-rn))', [2 3 4]) && isequal(sort(round(-rd))', [1 3 5 6])
% CODE:
%% (a)
p = conv(conv(conv(conv([1 2], [1 5]), [1 -6]), [1 -4]), [1 -8]);
fprintf('(a) f5(x) coefficients: %s\n', mat2str(p));
ra = roots(p);
fprintf('    roots: %s\n', mat2str(sort(ra)', 6));

%% (b)
num = [1 9 26 24];
den = [1 15 77 153 90];
rn = roots(num); rd = roots(den);
a = sort(-rn); b = sort(-rd);
fprintf('(b) numerator roots: %s\n    denominator roots: %s\n', mat2str(rn', 6), mat2str(rd', 6));
fprintf('    G(s) = (s + %g)(s + %g)(s + %g) / ((s + %g)(s + %g)(s + %g)(s + %g))\n', a, b);
fprintf('    Check: poly(num roots) = %s\n', mat2str(poly(rn), 6));

% TOPIC: roots
% TITLE: MATLAB fzero with optimset display, and polynomial roots with roots()
% SOURCE: CE206 slides 02 pages 13-15
% KEYWORDS: fzero, optimset, display iter, roots, polynomial roots, poly, initial guess, bracket
% PROBLEM:
% (a) Use fzero to find the root of f(x) = x^10 - 1 starting with an initial guess of x = 0.5,
% displaying each iteration. (b) Find all roots of
% f(x) = x^5 - 3.5x^4 + 2.75x^3 + 2.125x^2 - 3.875x + 1.25 with the roots function and check them.
% CHECK: abs(xa - 1) < 1e-6
% CHECK: numel(r) == 5 && max(abs(polyval(c, r))) < 1e-6
% CODE:
%% (a) fzero with an initial guess
f = @(x) x.^10 - 1;
options = optimset('Display', 'iter');
[xa, fxa] = fzero(f, 0.5, options);
fprintf('(a) root = %.6f, f(root) = %.2e\n', xa, fxa);

%% (b) roots of a polynomial (coefficients, highest power first)
c = [1 -3.5 2.75 2.125 -3.875 1.25];
r = roots(c);
fprintf('(b) roots of x^5 - 3.5x^4 + 2.75x^3 + 2.125x^2 - 3.875x + 1.25:\n');
for k = 1:numel(r)
    fprintf('    x%d = %9.5f %+9.5fi   |f(x)| = %.1e\n', k, real(r(k)), imag(r(k)), abs(polyval(c, r(k))));
end
fprintf('poly(r) gives back the coefficients: %s\n', mat2str(real(poly(r)), 5));

function [D, D1, D2] = diff_richardson(f, x, h1, h2)
%DIFF_RICHARDSON  Richardson extrapolation of centered O(h^2) first derivatives.
%   [D, D1, D2] = diff_richardson(f, x, h1, h2)
%   f      function handle @(x) ..., or text 'cos(x)'
%   x      point where f'(x) is wanted
%   h1     larger step size
%   h2     smaller step size (default h1/2)
%   D1, D2 centered O(h^2) estimates with h1 and h2
%   D      extrapolated estimate. For h2 = h1/2: D = 4/3*D2 - 1/3*D1, O(h^4);
%          in general D = D2 + (D2 - D1)/((h1/h2)^2 - 1)
%   Call without outputs to print the estimates.
%   Example: D = diff_richardson(@(x) cos(x), pi/4, pi/3, pi/6)
if nargin < 3
    error('ru_lib:diff_richardson:nargin', 'diff_richardson: need f, x and h1.');
end
if nargin < 4 || isempty(h2), h2 = h1/2; end
f = ru_tofunc(f, {'x'});
D1 = (f(x + h1) - f(x - h1))/(2*h1);
D2 = (f(x + h2) - f(x - h2))/(2*h2);
D = D2 + (D2 - D1)/((h1/h2)^2 - 1);
if nargout == 0
    fprintf('D(h1=%.6g) = %.10g\nD(h2=%.6g) = %.10g\nRichardson D = %.10g\n', h1, D1, h2, D2, D);
end
end

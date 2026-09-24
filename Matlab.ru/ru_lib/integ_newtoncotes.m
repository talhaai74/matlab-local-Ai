function I = integ_newtoncotes(f, a, b, rule, varargin)
%INTEG_NEWTONCOTES  Single application of a closed Newton-Cotes rule.
%   I = integ_newtoncotes(f, a, b, rule)
%   f      function handle @(x) ..., or text
%   a, b   integration limits
%   rule   'trap' (1 segment), 'simp13' (2), 'simp38' (3) or 'boole' (4)
%   varargin  extra parameters forwarded as f(x, varargin{:})
%   Boole: (2h/45)*(7f0 + 32f1 + 12f2 + 32f3 + 7f4), h = (b-a)/4.
%   Call without outputs to print I.
%   Example: I = integ_newtoncotes(@(x) 1 - x - 4*x.^3 + 2*x.^5, -2, 4, 'boole')
if nargin < 4 || isempty(rule), rule = 'trap'; end
f = ru_tofunc(f, {'x'});
switch lower(rule)
    case {'trap', 'trapezoid', 'trapezoidal'}
        n = 1; w = [1 1]/2;
    case {'simp13', 'simpson13', 'simpson', '1/3'}
        n = 2; w = [1 4 1]/3;
    case {'simp38', 'simpson38', '3/8'}
        n = 3; w = [1 3 3 1]*3/8;
    case {'boole', 'booles'}
        n = 4; w = [7 32 12 32 7]*2/45;
    otherwise
        error('ru_lib:integ_newtoncotes:rule', ...
            'integ_newtoncotes: rule must be trap, simp13, simp38 or boole.');
end
h = (b - a)/n;
x = a + (0:n)*h;
I = 0;
for k = 1:n+1
    I = I + w(k)*f(x(k), varargin{:});
end
I = h*I;
if nargout == 0
    fprintf('integ_newtoncotes (%s): I = %.10g\n', rule, I);
end
end

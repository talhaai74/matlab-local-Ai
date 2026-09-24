function I = integ_simp38(f, a, b, n, varargin)
%INTEG_SIMP38  Composite Simpson's 3/8 rule for the integral of f(x) from a to b.
%   I = integ_simp38(f, a, b, n)
%   f      function handle @(x) ..., or text
%   a, b   integration limits
%   n      number of equal segments, a multiple of 3 (default 3 = single
%          application: (3h/8)*(f0 + 3f1 + 3f2 + f3))
%   varargin  extra parameters forwarded as f(x, varargin{:})
%   Call without outputs to print I, n and h.
%   Example: I = integ_simp38(@(x) 1 - exp(-x), 0, 4)
if nargin < 3
    error('ru_lib:integ_simp38:nargin', 'integ_simp38: need at least f, a, b.');
end
if nargin < 4 || isempty(n), n = 3; end
if n < 3 || mod(n, 3) ~= 0
    error('ru_lib:integ_simp38:n', 'integ_simp38: n must be a multiple of 3 (got %g).', n);
end
f = ru_tofunc(f, {'x'});
x = linspace(a, b, n+1);
y = zeros(size(x));
for k = 1:numel(x)
    y(k) = f(x(k), varargin{:});
end
h = (b - a)/n;
I = 0;
for k = 1:3:n
    I = I + 3*h/8*(y(k) + 3*y(k+1) + 3*y(k+2) + y(k+3));
end
if nargout == 0
    fprintf('integ_simp38: n = %d segments, h = %.6g, I = %.10g\n', n, h, I);
end
end

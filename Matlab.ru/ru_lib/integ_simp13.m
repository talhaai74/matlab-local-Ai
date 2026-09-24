function I = integ_simp13(f, a, b, n, varargin)
%INTEG_SIMP13  Composite Simpson's 1/3 rule for the integral of f(x) from a to b.
%   I = integ_simp13(f, a, b, n)
%   f      function handle @(x) ..., or text 'exp(-x)'
%   a, b   integration limits
%   n      number of equal segments, must be EVEN (default 100); n = 2 is the
%          single application of Simpson's 1/3 rule
%   varargin  extra parameters forwarded as f(x, varargin{:})
%   I      (h/3)*(f0 + 4*sum(odd) + 2*sum(even interior) + fn)
%   For equally spaced data use integ_simpdata(x, y).
%   Call without outputs to print I, n and h.
%   Example: I = integ_simp13(@(x) 1 - exp(-x), 0, 4, 4)
if nargin < 3
    error('ru_lib:integ_simp13:nargin', 'integ_simp13: need at least f, a, b.');
end
if nargin < 4 || isempty(n), n = 100; end
if n < 2 || mod(n, 2) ~= 0
    error('ru_lib:integ_simp13:n', ...
        'integ_simp13: n must be an even number of segments (got %g). Use integ_simp38 for 3 segments.', n);
end
f = ru_tofunc(f, {'x'});
x = linspace(a, b, n+1);
y = zeros(size(x));
for k = 1:numel(x)
    y(k) = f(x(k), varargin{:});
end
h = (b - a)/n;
I = h/3*(y(1) + 4*sum(y(2:2:end-1)) + 2*sum(y(3:2:end-2)) + y(end));
if nargout == 0
    fprintf('integ_simp13: n = %d segments, h = %.6g, I = %.10g\n', n, h, I);
end
end

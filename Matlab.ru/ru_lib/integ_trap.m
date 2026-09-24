function I = integ_trap(f, a, b, n, varargin)
%INTEG_TRAP  Composite trapezoidal rule for the integral of f(x) from a to b.
%   I = integ_trap(f, a, b, n)
%   f      function handle @(x) ..., or text 'x.^2.*exp(-x)'
%   a, b   integration limits
%   n      number of equal segments (default 100); h = (b-a)/n
%   varargin  extra parameters forwarded as f(x, varargin{:})
%   I      integral estimate: h/2*(f(x0) + 2*sum(f(x1..xn-1)) + f(xn))
%   For tabulated data (x, y) use trapz(x, y) instead (unequal spacing is fine).
%   A step size h instead of n: n = round((b-a)/h).
%   Call without outputs to print I, n and h.
%   Example: I = integ_trap(@(z) 200*(z./(5+z)).*exp(-2*z/30), 0, 30, 30)
if nargin < 3
    error('ru_lib:integ_trap:nargin', 'integ_trap: need at least f, a, b.');
end
if nargin < 4 || isempty(n), n = 100; end
if n < 1 || n ~= round(n)
    error('ru_lib:integ_trap:n', 'integ_trap: n must be a positive whole number of segments.');
end
f = ru_tofunc(f, {'x'});
x = linspace(a, b, n+1);
y = zeros(size(x));
for k = 1:numel(x)
    y(k) = f(x(k), varargin{:});
end
h = (b - a)/n;
I = h/2*(y(1) + 2*sum(y(2:end-1)) + y(end));
if nargout == 0
    fprintf('integ_trap: n = %d segments, h = %.6g, I = %.10g\n', n, h, I);
end
end

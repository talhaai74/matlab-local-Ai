function [q, ea, iter, R] = integ_romberg(f, a, b, es, maxit, varargin)
%INTEG_ROMBERG  Romberg integration of f(x) from a to b (Chapra romberg.m).
%   [q, ea, iter, R] = integ_romberg(f, a, b, es, maxit)
%   f      function handle @(x) ..., or text
%   a, b   integration limits
%   es     stop when the approximate relative error (PERCENT) <= es (default 1e-6)
%   maxit  maximum number of Richardson levels (default 50)
%   varargin  extra parameters forwarded as f(x, varargin{:})
%   q      integral estimate; ea = approximate relative error (%)
%   iter   number of levels used; R = Romberg table (row k: trapezoid with
%          2^(k-1) segments in column 1, extrapolations to the right)
%   Call without outputs to print the Romberg table.
%   Example: q = integ_romberg(@(x) (x + 1./x).^2, 1, 2, 0.5)
if nargin < 3
    error('ru_lib:integ_romberg:nargin', 'integ_romberg: need at least f, a, b.');
end
if nargin < 4 || isempty(es), es = 1e-6; end
if nargin < 5 || isempty(maxit), maxit = 50; end
f = ru_tofunc(f, {'x'});
n = 1;
R = zeros(maxit+1, maxit+1);
R(1,1) = integ_romberg_trap(f, a, b, n, varargin{:});
iter = 0;
ea = 100;
while iter < maxit
    iter = iter + 1;
    n = 2^iter;
    R(iter+1,1) = integ_romberg_trap(f, a, b, n, varargin{:});
    for k = 2:iter+1
        j = 2 + iter - k;
        R(j,k) = (4^(k-1)*R(j+1,k-1) - R(j,k-1))/(4^(k-1) - 1);
    end
    if R(1,iter+1) ~= 0
        ea = abs((R(1,iter+1) - R(2,iter))/R(1,iter+1))*100;
    end
    if ea <= es
        break
    end
end
q = R(1,iter+1);
R = R(1:iter+1, 1:iter+1);
if nargout == 0
    fprintf('integ_romberg table (column 1 = trapezoid with 1,2,4,... segments):\n');
    for i = 1:size(R,1)
        fprintf('%14.8f', R(i,1:size(R,2)-i+1));
        fprintf('\n');
    end
    fprintf('I = %.10g, ea = %.4g %%, levels = %d\n', q, ea, iter);
end
end

function I = integ_romberg_trap(f, a, b, n, varargin)
x = linspace(a, b, n+1);
y = zeros(size(x));
for k = 1:numel(x)
    y(k) = f(x(k), varargin{:});
end
h = (b - a)/n;
I = h/2*(y(1) + 2*sum(y(2:end-1)) + y(end));
end

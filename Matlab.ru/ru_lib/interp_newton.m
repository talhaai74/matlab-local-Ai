function [yi, b] = interp_newton(x, y, xi)
%INTERP_NEWTON  Newton's divided-difference interpolating polynomial through n points.
%   [yi, b] = interp_newton(x, y, xi)
%   x, y   n distinct data points (x values must not repeat)
%   xi     point(s) at which to evaluate the (n-1)-degree polynomial
%   yi     interpolated value(s), same size as xi
%   b      1-by-n divided-difference coefficients: b(1)=f(x1), b(2)=f[x2,x1], ...
%   Call without outputs to print b and the interpolated value(s).
%   Example: [yi, b] = interp_newton([1 4 6],[0 1.386294 1.791759], 2)

if nargin < 3
    error('ru_lib:interp_newton:nargin', 'INTERP_NEWTON: need x, y and xi.');
end
x = x(:)'; y = y(:)';
n = length(x);
if length(y) ~= n
    error('ru_lib:interp_newton:size', ...
        'INTERP_NEWTON: x and y must have the same length (got %d and %d).', n, length(y));
end
if n < 2
    error('ru_lib:interp_newton:npts', 'INTERP_NEWTON: need at least 2 points, got %d.', n);
end
if length(unique(x)) ~= n
    error('ru_lib:interp_newton:repeated', 'INTERP_NEWTON: x values must all be distinct.');
end

fdd = zeros(n,n);
fdd(:,1) = y(:);
for j = 2:n
    for i = 1:n-j+1
        fdd(i,j) = (fdd(i+1,j-1) - fdd(i,j-1))/(x(i+j-1) - x(i));
    end
end
b = fdd(1,:);

yi = zeros(size(xi));
for k = 1:n
    term = b(k)*ones(size(xi));
    for i = 1:k-1
        term = term.*(xi - x(i));
    end
    yi = yi + term;
end

if nargout == 0
    fprintf('INTERP_NEWTON: divided-difference coefficients b:\n');
    fprintf('  %.6g\n', b);
    fprintf('  interpolated value(s):\n');
    disp(yi);
end
end

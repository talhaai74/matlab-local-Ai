function yi = interp_lagrange(x, y, xi)
%INTERP_LAGRANGE  Lagrange interpolating polynomial through n points.
%   yi = interp_lagrange(x, y, xi)
%   x, y   n distinct data points (x values must not repeat)
%   xi     point(s) at which to evaluate the (n-1)-degree polynomial
%   yi     interpolated value(s), same size as xi
%   Gives the same result as interp_newton (same unique polynomial, different
%   formula); not shown with code on the CE206 slides, supplied for completeness.
%   Call without outputs to print the interpolated value(s).
%   Example: yi = interp_lagrange([1 4 6],[0 1.386294 1.791759], 2)

if nargin < 3
    error('ru_lib:interp_lagrange:nargin', 'INTERP_LAGRANGE: need x, y and xi.');
end
x = x(:)'; y = y(:)';
n = length(x);
if length(y) ~= n
    error('ru_lib:interp_lagrange:size', ...
        'INTERP_LAGRANGE: x and y must have the same length (got %d and %d).', n, length(y));
end
if n < 2
    error('ru_lib:interp_lagrange:npts', 'INTERP_LAGRANGE: need at least 2 points, got %d.', n);
end
if length(unique(x)) ~= n
    error('ru_lib:interp_lagrange:repeated', 'INTERP_LAGRANGE: x values must all be distinct.');
end

yi = zeros(size(xi));
for i = 1:n
    L = ones(size(xi));
    for j = 1:n
        if j ~= i
            L = L.*(xi - x(j))/(x(i) - x(j));
        end
    end
    yi = yi + y(i)*L;
end

if nargout == 0
    fprintf('INTERP_LAGRANGE: interpolated value(s):\n');
    disp(yi);
end
end

function yi = interp_natspline(x, y, xi)
%INTERP_NATSPLINE  Natural cubic spline interpolation (zero curvature at the ends).
%   yi = interp_natspline(x, y, xi)
%   x      strictly increasing data points (no repeats), y the same length, n >= 3
%   xi     point(s) at which to evaluate the spline
%   yi     interpolated value(s), same size as xi (xi outside [x(1) x(end)]
%          is extrapolated with the nearest end segment's cubic)
%   For MATLAB's built-in not-a-knot spline instead, use yy = spline(x,y,xx).
%   Call without outputs to print xi and yi as a table.
%   Example: yi = interp_natspline(x, y, linspace(min(x),max(x),50))

if nargin < 3
    error('ru_lib:interp_natspline:nargin', 'INTERP_NATSPLINE: need x, y and xi.');
end
x = x(:)'; y = y(:)';
m = length(x);
if length(y) ~= m
    error('ru_lib:interp_natspline:size', ...
        'INTERP_NATSPLINE: x and y must have the same length (got %d and %d).', m, length(y));
end
if m < 3
    error('ru_lib:interp_natspline:npts', 'INTERP_NATSPLINE: need at least 3 points, got %d.', m);
end
if any(diff(x) <= 0)
    error('ru_lib:interp_natspline:sorted', ...
        'INTERP_NATSPLINE: x must be strictly increasing with no repeated values.');
end

h = diff(x);
alpha = zeros(1,m);
for i = 2:m-1
    alpha(i) = 3/h(i)*(y(i+1)-y(i)) - 3/h(i-1)*(y(i)-y(i-1));
end
l = zeros(1,m); mu = zeros(1,m); z = zeros(1,m);
l(1) = 1;
for i = 2:m-1
    l(i) = 2*(x(i+1)-x(i-1)) - h(i-1)*mu(i-1);
    mu(i) = h(i)/l(i);
    z(i) = (alpha(i) - h(i-1)*z(i-1))/l(i);
end
l(m) = 1;
c = zeros(1,m); b = zeros(1,m-1); d = zeros(1,m-1);
for j = m-1:-1:1
    c(j) = z(j) - mu(j)*c(j+1);
    b(j) = (y(j+1)-y(j))/h(j) - h(j)*(c(j+1)+2*c(j))/3;
    d(j) = (c(j+1)-c(j))/(3*h(j));
end

sz = size(xi);
xiv = xi(:)';
yiv = zeros(size(xiv));
for k = 1:length(xiv)
    xk = xiv(k);
    j = find(x(1:end-1) <= xk & xk <= x(2:end), 1, 'first');
    if isempty(j)
        if xk < x(1)
            j = 1;
        else
            j = m-1;
        end
    end
    dx = xk - x(j);
    yiv(k) = y(j) + b(j)*dx + c(j)*dx^2 + d(j)*dx^3;
end
yi = reshape(yiv, sz);

if nargout == 0
    fprintf('INTERP_NATSPLINE:\n     xi          yi\n');
    for k = 1:length(xiv)
        fprintf('  %10.5g  %10.5g\n', xiv(k), yiv(k));
    end
end
end

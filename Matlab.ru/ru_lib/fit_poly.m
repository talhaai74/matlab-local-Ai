function [p, r2, syx] = fit_poly(x, y, n)
%FIT_POLY  nth-order polynomial regression y = p(1)*x^n + ... + p(n+1) (uses polyfit).
%   [p, r2, syx] = fit_poly(x, y, n)
%   x, y   data vectors, same length m
%   n      polynomial order; n = m-1 makes it an EXACT interpolating polynomial
%   p      coefficients, HIGHEST power first (polyfit/polyval convention)
%   r2     coefficient of determination on the data, r2 = (St-Sr)/St
%   syx    standard error, syx = sqrt(Sr/(m-(n+1))); 0 when m <= n+1 (exact fit)
%   Call without outputs to print p, r2, syx and plot data + fitted curve.
%   Example: p = fit_poly(v, F, 2)

if nargin < 3
    error('ru_lib:fit_poly:nargin', 'FIT_POLY: need x, y and the order n.');
end
x = x(:); y = y(:);
m = length(x);
if length(y) ~= m
    error('ru_lib:fit_poly:size', ...
        'FIT_POLY: x and y must have the same length (got %d and %d).', m, length(y));
end
if n < 0 || n ~= round(n)
    error('ru_lib:fit_poly:order', 'FIT_POLY: order n must be a nonnegative integer (got %g).', n);
end
if m < n+1
    error('ru_lib:fit_poly:npts', ...
        'FIT_POLY: need at least n+1 = %d points for order %d, got %d.', n+1, n, m);
end

p = polyfit(x, y, n);
yhat = polyval(p, x);
St = sum((y-mean(y)).^2);
Sr = sum((y-yhat).^2);
if St == 0
    if Sr < 1e-10
        r2 = 1;
    else
        r2 = 0;
    end
else
    r2 = (St-Sr)/St;
end
dof = m - (n+1);
if dof > 0
    syx = sqrt(Sr/dof);
else
    syx = 0;
end

if nargout == 0
    fprintf('FIT_POLY: order %d polynomial, coefficients (highest power first):\n', n);
    fprintf('  %.6g\n', p);
    fprintf('  r2  = %.6g\n', r2);
    fprintf('  syx = %.6g\n', syx);
    xp = linspace(min(x),max(x),100);
    yp = polyval(p,xp);
    figure; plot(x,y,'o',xp,yp,'-'); grid on;
    xlabel('x'); ylabel('y'); title(sprintf('fit\\_poly: order %d fit',n));
    legend('data','fit','Location','best');
end
end

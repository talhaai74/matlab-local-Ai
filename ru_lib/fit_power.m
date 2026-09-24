function [alpha, beta, r2] = fit_power(x, y)
%FIT_POWER  Fit y = alpha*x^beta by linearizing log10(y)=log10(alpha)+beta*log10(x).
%   [alpha, beta, r2] = fit_power(x, y)
%   x, y   data vectors, same length n >= 2; every x and y must be > 0
%   alpha, beta  fitted coefficients of y = alpha*x^beta
%   r2     coefficient of determination computed on the ORIGINAL y (not log10(y))
%   Call without outputs to print the equation, r2 and plot data + fit curve.
%   Example: [alpha, beta, r2] = fit_power(v, F)

if nargin < 2
    error('ru_lib:fit_power:nargin', 'FIT_POWER: need x and y.');
end
x = x(:); y = y(:);
n = length(x);
if length(y) ~= n
    error('ru_lib:fit_power:size', ...
        'FIT_POWER: x and y must have the same length (got %d and %d).', n, length(y));
end
if n < 2
    error('ru_lib:fit_power:npts', 'FIT_POWER: need at least 2 points, got %d.', n);
end
if any(x <= 0) || any(y <= 0)
    error('ru_lib:fit_power:positivity', ...
        'FIT_POWER: y = alpha*x^beta needs every x > 0 and y > 0 (found a value <= 0).');
end

X = log10(x); Y = log10(y);
sx = sum(X); sy = sum(Y);
sx2 = sum(X.*X); sxy = sum(X.*Y);
denom = n*sx2 - sx^2;
if denom == 0
    error('ru_lib:fit_power:singular', 'FIT_POWER: all x values are equal; cannot fit.');
end
beta = (n*sxy - sx*sy)/denom;
logalpha = sy/n - beta*sx/n;
alpha = 10^logalpha;

yhat = alpha*x.^beta;
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

if nargout == 0
    fprintf('FIT_POWER: y = %.6g*x^%.6g\n', alpha, beta);
    fprintf('  r2 (on original y) = %.6g\n', r2);
    xp = linspace(min(x),max(x),100);
    yp = alpha*xp.^beta;
    figure; plot(x,y,'o',xp,yp,'-'); grid on;
    xlabel('x'); ylabel('y'); title('fit\_power: data and best-fit curve');
    legend('data','fit','Location','best');
end
end

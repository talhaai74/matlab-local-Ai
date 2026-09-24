function [alpha, beta, r2] = fit_exponential(x, y)
%FIT_EXPONENTIAL  Fit y = alpha*exp(beta*x) by linearizing ln(y)=ln(alpha)+beta*x.
%   [alpha, beta, r2] = fit_exponential(x, y)
%   x, y   data vectors, same length n >= 2; every y must be > 0
%   alpha, beta  fitted coefficients of y = alpha*exp(beta*x)
%   r2     coefficient of determination computed on the ORIGINAL y (not ln(y))
%   Call without outputs to print the equation, r2 and plot data + fit curve.
%   Example: [alpha, beta, r2] = fit_exponential(t, conc)

if nargin < 2
    error('ru_lib:fit_exponential:nargin', 'FIT_EXPONENTIAL: need x and y.');
end
x = x(:); y = y(:);
n = length(x);
if length(y) ~= n
    error('ru_lib:fit_exponential:size', ...
        'FIT_EXPONENTIAL: x and y must have the same length (got %d and %d).', n, length(y));
end
if n < 2
    error('ru_lib:fit_exponential:npts', 'FIT_EXPONENTIAL: need at least 2 points, got %d.', n);
end
if any(y <= 0)
    error('ru_lib:fit_exponential:positivity', ...
        'FIT_EXPONENTIAL: y = alpha*exp(beta*x) needs every y > 0 (found a value <= 0).');
end

Y = log(y);
sx = sum(x); sy = sum(Y);
sx2 = sum(x.*x); sxy = sum(x.*Y);
denom = n*sx2 - sx^2;
if denom == 0
    error('ru_lib:fit_exponential:singular', 'FIT_EXPONENTIAL: all x values are equal; cannot fit.');
end
beta = (n*sxy - sx*sy)/denom;
lnalpha = sy/n - beta*sx/n;
alpha = exp(lnalpha);

yhat = alpha*exp(beta*x);
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
    fprintf('FIT_EXPONENTIAL: y = %.6g*exp(%.6g*x)\n', alpha, beta);
    fprintf('  r2 (on original y) = %.6g\n', r2);
    xp = linspace(min(x),max(x),100);
    yp = alpha*exp(beta*xp);
    figure; plot(x,y,'o',xp,yp,'-'); grid on;
    xlabel('x'); ylabel('y'); title('fit\_exponential: data and best-fit curve');
    legend('data','fit','Location','best');
end
end

function [alpha, beta, r2] = fit_saturation(x, y)
%FIT_SATURATION  Fit y = alpha*x/(beta+x) by linearizing 1/y vs 1/x.
%   [alpha, beta, r2] = fit_saturation(x, y)
%   x, y   data vectors, same length n >= 2; every x and y must be nonzero
%   alpha  fitted saturation (maximum) level; beta = half-saturation constant
%   r2     coefficient of determination computed on the ORIGINAL y (not 1/y)
%   Linearization: 1/y = (beta/alpha)*(1/x) + 1/alpha
%   Call without outputs to print the equation, r2 and plot data + fit curve.
%   Example: [alpha, beta, r2] = fit_saturation(substrate, rate)

if nargin < 2
    error('ru_lib:fit_saturation:nargin', 'FIT_SATURATION: need x and y.');
end
x = x(:); y = y(:);
n = length(x);
if length(y) ~= n
    error('ru_lib:fit_saturation:size', ...
        'FIT_SATURATION: x and y must have the same length (got %d and %d).', n, length(y));
end
if n < 2
    error('ru_lib:fit_saturation:npts', 'FIT_SATURATION: need at least 2 points, got %d.', n);
end
if any(x == 0) || any(y == 0)
    error('ru_lib:fit_saturation:zero', ...
        'FIT_SATURATION: y = alpha*x/(beta+x) needs every x and y nonzero (division by 1/x, 1/y).');
end

X = 1./x; Y = 1./y;
sx = sum(X); sy = sum(Y);
sx2 = sum(X.*X); sxy = sum(X.*Y);
denom = n*sx2 - sx^2;
if denom == 0
    error('ru_lib:fit_saturation:singular', 'FIT_SATURATION: all x values are equal; cannot fit.');
end
slope = (n*sxy - sx*sy)/denom;
intercept = sy/n - slope*sx/n;
if intercept == 0
    error('ru_lib:fit_saturation:degenerate', ...
        'FIT_SATURATION: fitted 1/alpha = 0; the data does not saturate, try fit_power or fit_linear.');
end
alpha = 1/intercept;
beta = slope*alpha;

yhat = alpha*x./(beta+x);
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
    fprintf('FIT_SATURATION: y = %.6g*x/(%.6g+x)\n', alpha, beta);
    fprintf('  r2 (on original y) = %.6g\n', r2);
    xp = linspace(min(x),max(x),100);
    yp = alpha*xp./(beta+xp);
    figure; plot(x,y,'o',xp,yp,'-'); grid on;
    xlabel('x'); ylabel('y'); title('fit\_saturation: data and best-fit curve');
    legend('data','fit','Location','best');
end
end

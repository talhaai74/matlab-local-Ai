function [p, SSR, r2] = fit_nonlinear(model, p0, x, y)
%FIT_NONLINEAR  Nonlinear least squares: minimize SSR=sum((y-model(p,x)).^2) via fminsearch.
%   [p, SSR, r2] = fit_nonlinear(model, p0, x, y)
%   model  function handle @(p,x) ... (p = parameter vector, x = data vector)
%   p0     initial guess for p (row or column vector)
%   x, y   data vectors, same length
%   p      fitted parameter vector (same shape as p0), via fminsearch
%   SSR    sum of squared residuals at p; r2 = coefficient of determination
%   Call without outputs to print p, SSR, r2 and plot data + fit curve.
%   Example: p = fit_nonlinear(@(p,x) p(1)*x.^p(2), [1 1], v, F)

if nargin < 4
    error('ru_lib:fit_nonlinear:nargin', 'FIT_NONLINEAR: need model, p0, x and y.');
end
if ~isa(model, 'function_handle')
    error('ru_lib:fit_nonlinear:model', ...
        'FIT_NONLINEAR: model must be a function handle @(p,x) ..., e.g. @(p,x) p(1)*x.^p(2).');
end
x = x(:); y = y(:);
n = length(x);
if length(y) ~= n
    error('ru_lib:fit_nonlinear:size', ...
        'FIT_NONLINEAR: x and y must have the same length (got %d and %d).', n, length(y));
end

SSRfun = @(p) sum((y - model(p, x)).^2);
p = fminsearch(SSRfun, p0);
SSR = SSRfun(p);

yhat = model(p, x);
St = sum((y-mean(y)).^2);
if St == 0
    if SSR < 1e-10
        r2 = 1;
    else
        r2 = 0;
    end
else
    r2 = (St-SSR)/St;
end

if nargout == 0
    fprintf('FIT_NONLINEAR: fitted parameters p:\n');
    fprintf('  %.6g\n', p);
    fprintf('  SSR = %.6g\n', SSR);
    fprintf('  r2  = %.6g\n', r2);
    xp = linspace(min(x),max(x),100);
    yp = model(p, xp(:));
    figure; plot(x,y,'o',xp,yp,'-'); grid on;
    xlabel('x'); ylabel('y'); title('fit\_nonlinear: data and best-fit curve');
    legend('data','fit','Location','best');
end
end

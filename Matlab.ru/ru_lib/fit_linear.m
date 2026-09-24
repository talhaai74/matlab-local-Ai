function [a, r2, syx] = fit_linear(x, y)
%FIT_LINEAR  Least-squares straight-line fit y = a(1)*x + a(2) (Chapra linregr).
%   [a, r2, syx] = fit_linear(x, y)
%   x, y   data vectors, same length n >= 2
%   a      a(1) = slope, a(2) = intercept  (NOTE: opposite order from polyfit)
%   r2     coefficient of determination, r2 = (St-Sr)/St, a fraction in [0,1]
%   syx    standard error of the estimate, syx = sqrt(Sr/(n-2))
%   Call without outputs to print the fitted equation, r2, syx and plot
%   the data with the best-fit line.
%   Example: [a, r2, syx] = fit_linear([10 20 30 40],[25 70 380 550])

if nargin < 2
    error('ru_lib:fit_linear:nargin', 'FIT_LINEAR: need x and y.');
end
x = x(:); y = y(:);
n = length(x);
if length(y) ~= n
    error('ru_lib:fit_linear:size', ...
        'FIT_LINEAR: x and y must have the same length (got %d and %d).', n, length(y));
end
if n < 2
    error('ru_lib:fit_linear:npts', 'FIT_LINEAR: need at least 2 points, got %d.', n);
end

sx = sum(x); sy = sum(y);
sx2 = sum(x.*x); sxy = sum(x.*y);
denom = n*sx2 - sx^2;
if denom == 0
    error('ru_lib:fit_linear:singular', 'FIT_LINEAR: all x values are equal; cannot fit a line.');
end
a = zeros(1,2);
a(1) = (n*sxy - sx*sy)/denom;
a(2) = sy/n - a(1)*sx/n;

yhat = a(1)*x + a(2);
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
if n > 2
    syx = sqrt(Sr/(n-2));
else
    syx = 0;
end

if nargout == 0
    fprintf('FIT_LINEAR: y = %.6g*x + %.6g\n', a(1), a(2));
    fprintf('  r2  = %.6g\n', r2);
    fprintf('  syx = %.6g\n', syx);
    xp = linspace(min(x),max(x),2);
    yp = a(1)*xp+a(2);
    figure; plot(x,y,'o',xp,yp,'-'); grid on;
    xlabel('x'); ylabel('y'); title('fit\_linear: data and best-fit line');
    legend('data','fit','Location','best');
end
end

function [a, r2, syx] = fit_multilinear(X, y)
%FIT_MULTILINEAR  Multiple linear regression y = a0 + a1*x1 + a2*x2 + ... (least squares).
%   [a, r2, syx] = fit_multilinear(X, y)
%   X      m-by-k matrix, one column per predictor, one row per observation
%   y      m-by-1 (or 1-by-m) observed values
%   a      (k+1)-by-1 coefficients, a(1) = intercept a0, a(2) = a1, ...
%   r2     coefficient of determination, r2 = (St-Sr)/St
%   syx    standard error, syx = sqrt(Sr/(m-(k+1))); 0 when m <= k+1
%   Call without outputs to print a, r2 and syx.
%   Example: a = fit_multilinear([Rain Temp Wind], PM25)

if nargin < 2
    error('ru_lib:fit_multilinear:nargin', 'FIT_MULTILINEAR: need X and y.');
end
y = y(:);
m = size(X,1);
if length(y) ~= m
    error('ru_lib:fit_multilinear:size', ...
        'FIT_MULTILINEAR: X has %d rows but y has %d elements; they must match.', m, length(y));
end

Z = [ones(m,1) X];
p = size(Z,2);
ZtZ = Z'*Z;
if rank(ZtZ) < p
    error('ru_lib:fit_multilinear:singular', ...
        'FIT_MULTILINEAR: the predictor columns of X are linearly dependent; drop a redundant column.');
end
a = ZtZ\(Z'*y);

yhat = Z*a;
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
dof = m - p;
if dof > 0
    syx = sqrt(Sr/dof);
else
    syx = 0;
end

if nargout == 0
    fprintf('FIT_MULTILINEAR: a(1) = intercept, a(2..) = predictor coefficients:\n');
    fprintf('  %.6g\n', a);
    fprintf('  r2  = %.6g\n', r2);
    fprintf('  syx = %.6g\n', syx);
end
end

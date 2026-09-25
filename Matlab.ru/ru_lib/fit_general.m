function [a, r2, syx] = fit_general(Z, y)
%FIT_GENERAL  General linear least squares y = Z*a + e (solves the normal equations Z'*Z*a = Z'*y by QR).
%   [a, r2, syx] = fit_general(Z, y)
%   Z      m-by-p design (basis-function) matrix, one row per data point,
%          e.g. Z = [ones(size(v)) v v.^2] fits a 2nd order polynomial in v
%   y      m-by-1 (or 1-by-m) observed values
%   a      p-by-1 coefficients (least squares, a = Z\y; equals (Z'*Z)\(Z'*y)); a(1) multiplies Z(:,1), ...
%   r2     coefficient of determination, r2 = (St-Sr)/St
%   syx    standard error, syx = sqrt(Sr/(m-p)); 0 when m <= p (exact fit)
%   Call without outputs to print a, r2 and syx.
%   Example: a = fit_general([ones(8,1) v(:) v(:).^2], F)

if nargin < 2
    error('ru_lib:fit_general:nargin', 'FIT_GENERAL: need the design matrix Z and y.');
end
y = y(:);
[m, p] = size(Z);
if length(y) ~= m
    error('ru_lib:fit_general:size', ...
        'FIT_GENERAL: Z has %d rows but y has %d elements; they must match.', m, length(y));
end

if rank(Z) < p
    error('ru_lib:fit_general:singular', ...
        'FIT_GENERAL: Z''*Z is singular (columns of Z are linearly dependent); use fewer basis functions.');
end
a = Z\y;                       % least squares by QR: same a as (Z'*Z)\(Z'*y), without squaring cond(Z)

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
    fprintf('FIT_GENERAL: coefficients a (a(1) multiplies Z column 1, ...):\n');
    fprintf('  %.6g\n', a);
    fprintf('  r2  = %.6g\n', r2);
    fprintf('  syx = %.6g\n', syx);
end
end

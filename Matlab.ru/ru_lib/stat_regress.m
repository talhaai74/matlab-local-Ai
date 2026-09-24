function s = stat_regress(X, y, intercept)
%STAT_REGRESS  Ordinary least squares linear regression (like fitlm).
%   s = stat_regress(X, y, intercept)
%   X          predictor matrix, n-by-k (one column per predictor, no ones column)
%   y          response vector, n-by-1
%   intercept  true (default) adds a constant term; false fits through the origin
%   s          struct: coef, se, tstat, pvalue (intercept first if present),
%              R2, adjR2, rmse, n, dfe
%   Call without outputs to print the coefficient table.
%   Example: s = stat_regress([1;2;3;4], [2.1;3.9;6.1;7.8])

if nargin < 2
    error('ru_lib:stat_regress:nargin', 'STAT_REGRESS: need predictors X and response y.');
end
if nargin < 3 || isempty(intercept), intercept = true; end
y = y(:);
n = size(y,1);
if size(X,1) ~= n
    error('ru_lib:stat_regress:size', 'STAT_REGRESS: X has %d rows but y has %d.', size(X,1), n);
end
if intercept
    Xd = [ones(n,1), X];
else
    Xd = X;
end
p = size(Xd,2);
dfe = n - p;
if dfe < 1
    error('ru_lib:stat_regress:dfe', 'STAT_REGRESS: not enough data (n=%d) for %d coefficients.', n, p);
end
beta = Xd \ y;
resid = y - Xd*beta;
sse = sum(resid.^2);
sigma2 = sse/dfe;
XtXinv = inv(Xd'*Xd);
se = sqrt(diag(XtXinv)*sigma2);
tstat = beta./se;
pvalue = 2*(1 - stat_tcdf(abs(tstat), dfe));
if intercept
    sst = sum((y - mean(y)).^2);
else
    sst = sum(y.^2);
end
r2 = 1 - sse/sst;
dfT = n - double(intercept);
adjr2 = 1 - (sse/dfe)/(sst/dfT);
rmse = sqrt(sigma2);
s.coef = beta;
s.se = se;
s.tstat = tstat;
s.pvalue = pvalue;
s.R2 = r2;
s.adjR2 = adjr2;
s.rmse = rmse;
s.n = n;
s.dfe = dfe;
if nargout == 0
    fprintf('%-12s%12s%12s%12s%12s\n', 'Term', 'Estimate', 'SE', 'tStat', 'pValue');
    for i = 1:p
        if intercept && i == 1
            nm = 'Intercept';
        else
            nm = sprintf('x%d', i - double(intercept));
        end
        fprintf('%-12s%12.4g%12.4g%12.4g%12.4g\n', nm, beta(i), se(i), tstat(i), pvalue(i));
    end
    fprintf('n = %d, dfe = %d, RMSE = %.4g, R2 = %.4g, Adj R2 = %.4g\n', n, dfe, rmse, r2, adjr2);
end
end

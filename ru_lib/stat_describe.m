function s = stat_describe(x)
%STAT_DESCRIBE  Descriptive statistics of each column of x.
%   s = stat_describe(x)
%   x   data vector or matrix (stats computed per column; a vector is one column)
%   s   1-by-ncols struct array with fields:
%       n, mean, median, mode, min, max, range, var, std, cv, skewness,
%       kurtosis, q1, q3, iqr   (cv = std/mean*100, percent)
%   Call without outputs to print a table (one column of numbers per data column).
%   Example: s = stat_describe([12 15 11 19 14 15])

if nargin < 1
    error('ru_lib:stat_describe:nargin', 'STAT_DESCRIBE: need a data vector or matrix x.');
end
if isvector(x)
    x = x(:);
end
[n, ncols] = size(x);
if n < 1
    error('ru_lib:stat_describe:empty', 'STAT_DESCRIBE: x has no data.');
end
qq = stat_quantile(x, [0.25; 0.75]);
s = struct('n',{},'mean',{},'median',{},'mode',{},'min',{},'max',{}, ...
    'range',{},'var',{},'std',{},'cv',{},'skewness',{},'kurtosis',{}, ...
    'q1',{},'q3',{},'iqr',{});
for j = 1:ncols
    xj = x(:,j);
    xbar = mean(xj);
    sdev = std(xj);
    z = xj - xbar;
    popstd = sqrt(mean(z.^2));
    if popstd == 0
        sk = 0;
        ku = 0;
    else
        sk = mean(z.^3) / popstd^3;
        ku = mean(z.^4) / popstd^4;
    end
    s(j).n = n;
    s(j).mean = xbar;
    s(j).median = median(xj);
    s(j).mode = mode(xj);
    s(j).min = min(xj);
    s(j).max = max(xj);
    s(j).range = max(xj) - min(xj);
    s(j).var = var(xj);
    s(j).std = sdev;
    if xbar == 0
        s(j).cv = NaN;
    else
        s(j).cv = sdev/xbar*100;
    end
    s(j).skewness = sk;
    s(j).kurtosis = ku;
    s(j).q1 = qq(1,j);
    s(j).q3 = qq(2,j);
    s(j).iqr = qq(2,j) - qq(1,j);
end
if nargout == 0
    names  = {'n','mean','median','mode','min','max','range','var','std', ...
        'cv%','skewness','kurtosis','q1','q3','iqr'};
    fields = {'n','mean','median','mode','min','max','range','var','std', ...
        'cv','skewness','kurtosis','q1','q3','iqr'};
    fprintf('%-10s', 'stat');
    for j = 1:ncols
        fprintf('%14s', sprintf('col%d', j));
    end
    fprintf('\n');
    for k = 1:numel(names)
        fprintf('%-10s', names{k});
        for j = 1:ncols
            fprintf('%14.4f', s(j).(fields{k}));
        end
        fprintf('\n');
    end
end
end

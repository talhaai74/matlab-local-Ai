function results = test_stats()
%TEST_STATS  Unit tests for the ru_lib stat_* functions (topic: stats).
%   results = test_stats()  runs every test and returns a struct array with
%   fields name, pass, msg. Each test is wrapped in try/catch so a single
%   failure does not stop the rest.

results = struct('name', {}, 'pass', {}, 'msg', {});

% 1. stat_quantile: known values + clamped ends
try
    q = stat_quantile([2 4 6 8 10], [0 0.25 0.5 0.75 1]);
    expected = [2; 3.5; 6; 8.5; 10];
    ok = all(abs(q - expected) < 1e-9);
    results = addresult(results, 'stat_quantile basic + clamped ends', ok, ...
        sprintf('got [%s]', num2str(q(:)')));
catch ME
    results = addresult(results, 'stat_quantile basic + clamped ends', false, ME.message);
end

% 2. stat_quantile: matrix input is columnwise
try
    X = [1 10; 2 20; 3 30; 4 40; 5 50];
    q = stat_quantile(X, 0.5);
    ok = abs(q(1)-3) < 1e-9 && abs(q(2)-30) < 1e-9;
    results = addresult(results, 'stat_quantile matrix columnwise', ok, ...
        sprintf('got [%s]', num2str(q)));
catch ME
    results = addresult(results, 'stat_quantile matrix columnwise', false, ME.message);
end

% 3. stat_describe: hand-verified values + nargout==0 path
try
    x = [1 2 2 3 4];
    s = stat_describe(x);
    ok = abs(s.mean-2.4) < 1e-9 && abs(s.median-2) < 1e-9 && abs(s.mode-2) < 1e-9 ...
        && abs(s.var-1.3) < 1e-9 && abs(s.std-sqrt(1.3)) < 1e-9 ...
        && abs(s.q1-1.75) < 1e-6 && abs(s.q3-3.25) < 1e-6 && abs(s.iqr-1.5) < 1e-6;
    out = evalc('stat_describe(x);');
    ok = ok && ~isempty(out);
    results = addresult(results, 'stat_describe values + nargout==0', ok, ...
        sprintf('mean=%.4f median=%.4f mode=%.4f', s.mean, s.median, s.mode));
catch ME
    results = addresult(results, 'stat_describe values + nargout==0', false, ME.message);
end

% 4. stat_normpdf/stat_normcdf/stat_norminv: known values + defaults
try
    ok = abs(stat_normpdf(0) - 1/sqrt(2*pi)) < 1e-9;
    ok = ok && abs(stat_normcdf(0) - 0.5) < 1e-9;
    ok = ok && abs(stat_normcdf(1) - 0.8413447) < 1e-6;
    ok = ok && abs(stat_norminv(0.5)) < 1e-9;
    ok = ok && abs(stat_norminv(0.975) - 1.959964) < 1e-4;
    results = addresult(results, 'stat_normpdf/normcdf/norminv known values', ok, '');
catch ME
    results = addresult(results, 'stat_normpdf/normcdf/norminv known values', false, ME.message);
end

% 5. stat_tcdf/stat_tinv: known value + round trip
try
    ok = abs(stat_tcdf(0, 10) - 0.5) < 1e-9;
    t = stat_tinv(0.975, 10);
    ok = ok && abs(t - 2.228139) < 1e-4;
    p = stat_tcdf(t, 10);
    ok = ok && abs(p - 0.975) < 1e-9;
    ok = ok && abs(stat_tinv(0.5, 7)) < 1e-9;
    results = addresult(results, 'stat_tcdf/stat_tinv known value + roundtrip', ok, ...
        sprintf('t=%.6f p=%.6f', t, p));
catch ME
    results = addresult(results, 'stat_tcdf/stat_tinv known value + roundtrip', false, ME.message);
end

% 6. stat_ci_mean: manual formula cross-check + default conf + nargout==0
try
    x = [2 4 6 8 10];
    [lo, hi, margin, xbar] = stat_ci_mean(x, 0.95);
    tcrit = stat_tinv(0.975, 4);
    expectedMargin = tcrit*std(x)/sqrt(5);
    ok = abs(xbar-6) < 1e-9 && abs(margin-expectedMargin) < 1e-9 && lo < xbar && xbar < hi;
    loDefault = stat_ci_mean(x);
    ok = ok && abs(loDefault - lo) < 1e-9;
    out = evalc('stat_ci_mean(x);');
    ok = ok && ~isempty(out);
    results = addresult(results, 'stat_ci_mean formula check + default conf + nargout==0', ok, ...
        sprintf('lo=%.4f hi=%.4f', lo, hi));
catch ME
    results = addresult(results, 'stat_ci_mean formula check + default conf + nargout==0', false, ME.message);
end

% 7. stat_ttest: verified against the slide's one-sample example + defaults
try
    x1 = [141.1530 131.2526 120.8033 148.12 160.10 125.6617 161.2354];
    [h, p, ci, stats] = stat_ttest(x1, 100);   % default alpha=0.05, tail='both'
    ok = h==1 && abs(p-5.1463e-04) < 1e-6 && abs(stats.tstat-6.7521) < 1e-3 && stats.df==6;
    ok = ok && abs(ci(1)-126.2627) < 1e-2 && abs(ci(2)-156.1161) < 1e-2;
    [~, pRight] = stat_ttest(x1, 100, 0.05, 'right');
    ok = ok && pRight < p;
    results = addresult(results, 'stat_ttest verified + defaults + one-tail', ok, ...
        sprintf('p=%.6g tstat=%.4f', p, stats.tstat));
catch ME
    results = addresult(results, 'stat_ttest verified + defaults + one-tail', false, ME.message);
end

% 8. stat_ttest: zero-tstat edge case (xbar == mu0)
try
    [h, p] = stat_ttest([10 20 30], 20);
    ok = abs(p-1) < 1e-6 && h==0;
    results = addresult(results, 'stat_ttest zero-tstat edge case', ok, ...
        sprintf('p=%.6f h=%d', p, h));
catch ME
    results = addresult(results, 'stat_ttest zero-tstat edge case', false, ME.message);
end

% 9. stat_ttest2: verified against the slide's two-sample example + defaults
try
    x1 = [141.1530 131.2526 120.8033 148.12 160.10 125.6617 161.2354];
    x2 = [162.0583 155.1161 168.6048 171.0033 174.9242 157.89 145.3];
    [h, p, ci, stats] = stat_ttest2(x1, x2);   % default alpha=0.05, tail='both'
    ok = h==1 && abs(p-0.01346) < 1e-3 && abs(stats.tstat+2.8946) < 1e-2 && stats.df==12;
    ok = ok && abs(stats.sd-13.5330) < 1e-2 && abs(ci(1)+36.6995) < 1e-1 && abs(ci(2)+5.1778) < 1e-1;
    results = addresult(results, 'stat_ttest2 verified + defaults', ok, ...
        sprintf('p=%.6f tstat=%.4f', p, stats.tstat));
catch ME
    results = addresult(results, 'stat_ttest2 verified + defaults', false, ME.message);
end

% 10. stat_regress: verified simple regression, with/without intercept, default intercept + nargout==0
try
    Rain = [0 5 0 10 2 0 8 1]';
    PM25 = [150 130 160 100 140 155 110 148]';
    m1 = stat_regress(Rain, PM25);             % default intercept = true
    ok = abs(m1.coef(1)-154.2626) < 1e-2 && abs(m1.coef(2)+5.4269) < 1e-2;
    ok = ok && abs(m1.R2-0.97789) < 1e-3 && m1.dfe==6;
    m2 = stat_regress(Rain, PM25, false);
    ok = ok && abs(m2.coef(1)-15.2474) < 1e-2 && m2.dfe==7;
    out = evalc('stat_regress(Rain, PM25, true);');
    ok = ok && ~isempty(out);
    results = addresult(results, 'stat_regress verified + default intercept + nargout==0', ok, ...
        sprintf('coef1=%.4f R2=%.4f', m1.coef(1), m1.R2));
catch ME
    results = addresult(results, 'stat_regress verified + default intercept + nargout==0', false, ME.message);
end

% 11. stat_hist: known bin counts/centers + default nbins
try
    x = [1 2 2 3 3 3 4 5];
    [counts, centers] = stat_hist(x, 5);
    ok = isequal(counts, [1 2 3 1 1]) && abs(sum(counts)-8) < 1e-9;
    ok = ok && all(abs(centers - [1.4 2.2 3.0 3.8 4.6]) < 1e-9);
    c2 = stat_hist(x);   % default nbins = 10
    ok = ok && numel(c2)==10 && sum(c2)==8;
    results = addresult(results, 'stat_hist known counts + default nbins', ok, ...
        sprintf('counts=[%s]', num2str(counts)));
catch ME
    results = addresult(results, 'stat_hist known counts + default nbins', false, ME.message);
end

% 12. Error paths: bad sigma, bad tail, mismatched regression sizes
try
    errCount = 0;
    try, stat_normpdf(0, 0, -1); catch, errCount = errCount+1; end
    try, stat_ttest([1 2 3], 0, 0.05, 'bogus'); catch, errCount = errCount+1; end
    try, stat_regress([1;2;3], [1;2]); catch, errCount = errCount+1; end
    ok = errCount == 3;
    results = addresult(results, 'invalid inputs raise informative errors', ok, ...
        sprintf('%d/3 raised an error', errCount));
catch ME
    results = addresult(results, 'invalid inputs raise informative errors', false, ME.message);
end

end

function results = addresult(results, name, pass, msg)
results(end+1) = struct('name', name, 'pass', logical(pass), 'msg', msg);
end

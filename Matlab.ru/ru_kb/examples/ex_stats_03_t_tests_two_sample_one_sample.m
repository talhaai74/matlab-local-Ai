% TOPIC: stats
% TITLE: Two-sample and one-sample t-tests (ttest2 / ttest or the ru_lib versions without the toolbox)
% SOURCE: CE206 slides 09 pages 15-19
% KEYWORDS: t-test, ttest2, ttest, hypothesis testing, two-sample, one-sample, p-value, null hypothesis, confidence interval, pm2.5, h = 1
% PROBLEM:
% Compare the pollution level of the first two weeks of a month using PM2.5 concentrations (example data):
% week 1 = 141.2 131.3 120.8 150.4 135.9 128.7 145.2, week 2 = 110.5 118.2 125.1 102.6 115.8 121.3 108.9.
% (a) Test H0: mu1 = mu2 against H1: mu1 ~= mu2 (two-sample t-test, alpha = 0.05).
% (b) Test whether the week-1 mean is more than 100 (H0: mu = 100, Ha: mu > 100).
% Report h, p, the confidence interval and the t statistic.
% CHECK: h2 == 1 && abs(p2 - 7.9207e-4) < 1e-7 && abs(st2.tstat - 4.450577) < 1e-5
% CHECK: h1 == 1 && abs(st1.tstat - 9.386700) < 1e-5 && abs(p1 - 4.14984e-5) < 1e-9
% CODE:
x1 = [141.2 131.3 120.8 150.4 135.9 128.7 145.2];
x2 = [110.5 118.2 125.1 102.6 115.8 121.3 108.9];
haveStats = license('test', 'Statistics_Toolbox') && ~isempty(which('ttest2'));
%% (a) two-sample, two-tailed
if haveStats
    [h2, p2, ci2, st2] = ttest2(x1, x2);
else
    [h2, p2, ci2, st2] = stat_ttest2(x1, x2);          % same results without the toolbox
end
fprintf('(a) h = %d, p = %.4g, CI = [%.4f, %.4f], t = %.4f, df = %d\n', h2, p2, ci2, st2.tstat, st2.df);
%% (b) one-sample, right-tailed
if haveStats
    [h1, p1, ci1, st1] = ttest(x1, 100, 'Tail', 'right');
else
    [h1, p1, ci1, st1] = stat_ttest(x1, 100, 0.05, 'right');
end
fprintf('(b) h = %d, p = %.4g, CI = [%.4f, %g], t = %.4f\n', h1, p1, ci1(1), ci1(2), st1.tstat);
if h2 == 1
    fprintf('The two weekly means differ significantly at the 5 %% level; ');
end
if h1 == 1
    fprintf('the week-1 mean is significantly above 100.\n');
end

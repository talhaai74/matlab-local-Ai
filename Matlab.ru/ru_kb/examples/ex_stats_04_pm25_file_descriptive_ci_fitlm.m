% TOPIC: stats
% TITLE: PM2.5 data file: readtable, min, max, std, quartiles, IQR, 95% CI, histogram and fitlm regression
% SOURCE: CE206 slides 09 pages 7-26 / Endfiles "Spreadsheet 2.m"
% KEYWORDS: readtable, data_stat.xlsx, pm25, rain, temp, windspeed, minimum, maximum, standard deviation, quartile, iqr, confidence interval, histogram, fitlm, multiple linear regression, intercept false
% SELFTEST: skip
% PROBLEM:
% Import data_stat.xlsx (columns PM25, Rain, Temp, WindSpeed). For each variable find the minimum, maximum,
% standard deviation, 1st, 2nd and 3rd quartiles, IQR and the 95% confidence interval of the mean. Plot a
% histogram of PM2.5 with 20 bins. Then fit PM25 ~ Rain and PM25 ~ Rain + Temp + WindSpeed (with and
% without intercept).
% CODE:
T = readtable('data_stat.xlsx');                 % the file must be in the current folder
X = [T.PM25, T.Rain, T.Temp, T.WindSpeed];
names = {'PM25', 'Rain', 'Temp', 'WindSpeed'};
n = size(X, 1);
Q = stat_quantile(X, [0.25 0.5 0.75]);           % same convention as quantile/prctile
[lo, hi] = stat_ci_mean(X, 0.95);
fprintf('%-10s %9s %9s %9s %9s %9s %9s %9s %9s %9s\n', 'Variable', 'min', 'max', 'mean', 'std', 'Q1', 'Q2', 'Q3', 'IQR', 'CI95');
for j = 1:4
    fprintf('%-10s %9.3f %9.3f %9.3f %9.3f %9.3f %9.3f %9.3f %9.3f [%.3f, %.3f]\n', names{j}, min(X(:,j)), max(X(:,j)), ...
        mean(X(:,j)), std(X(:,j)), Q(1,j), Q(2,j), Q(3,j), Q(3,j) - Q(1,j), lo(j), hi(j));
end
figure; hist(T.PM25, 20); ylabel('Frequency'); xlabel('PM_{2.5} concentration (\mug/m^3)');
[counts, centers] = hist(T.PM25, 20);
if license('test', 'Statistics_Toolbox') && ~isempty(which('fitlm'))
    mdl1 = fitlm(T, 'PM25~Rain')
    mdl2 = fitlm(T, 'PM25~Rain+Temp+WindSpeed')
    mdl3 = fitlm(T, 'PM25~Rain+Temp+WindSpeed', 'Intercept', false)
else
    s1 = stat_regress(T.Rain, T.PM25)            % prints like fitlm
    s2 = stat_regress([T.Rain T.Temp T.WindSpeed], T.PM25)
    s3 = stat_regress([T.Rain T.Temp T.WindSpeed], T.PM25, false)
end

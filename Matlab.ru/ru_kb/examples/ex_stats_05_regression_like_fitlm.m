% TOPIC: stats
% TITLE: Simple and multiple linear regression with coefficient table (fitlm or stat_regress)
% SOURCE: CE206 slides 09 pages 20-26
% KEYWORDS: regression model, fitlm, simple linear regression, multiple linear regression, coefficients, standard error, tstat, pvalue, r-squared, rainfall, temperature, wind speed
% PROBLEM:
% Using the data (example) Rain = 0 2.5 10.2 0 5.1 15.3 0.8 3.3 7.9 1.2, Temp = 24.1 25.3 27.8 23.5 26.2
% 28.4 24.8 25.9 27.1 24.4, WindSpeed = 2.1 3.4 4.2 1.8 3.0 4.8 2.2 2.9 3.9 2.5 and
% PM25 = 148 121 82 156 104 70 139 118 95 133, find the association between PM2.5 and the meteorological
% parameters with (1) simple linear regression on rainfall and (2) multiple linear regression on all three.
% Report the coefficients, their standard errors, t statistics, p-values and R^2.
% CHECK: norm(s1.coef(:)' - [141.562275 -5.391420]) < 1e-5 && abs(s1.R2 - 0.918332) < 1e-5
% CHECK: norm(s2.coef(:)' - [470.370838 -0.197081 -12.918715 -6.558908]) < 1e-4 && abs(s2.R2 - 0.984653) < 1e-5
% CODE:
Rain = [0 2.5 10.2 0 5.1 15.3 0.8 3.3 7.9 1.2]';
Temp = [24.1 25.3 27.8 23.5 26.2 28.4 24.8 25.9 27.1 24.4]';
Wind = [2.1 3.4 4.2 1.8 3.0 4.8 2.2 2.9 3.9 2.5]';
PM25 = [148 121 82 156 104 70 139 118 95 133]';
s1 = stat_regress(Rain, PM25);                   % like fitlm(T, 'PM25~Rain')
s2 = stat_regress([Rain Temp Wind], PM25);       % like fitlm(T, 'PM25~Rain+Temp+WindSpeed')
fprintf('(1) PM25 = %.4f %+.4f Rain, R^2 = %.4f\n', s1.coef, s1.R2);
fprintf('%-10s %10s %10s %10s %10s\n', 'Term', 'Estimate', 'SE', 'tStat', 'pValue');
terms = {'Intercept', 'Rain', 'Temp', 'WindSpeed'};
fprintf('(2) multiple regression, R^2 = %.4f, adjusted R^2 = %.4f\n', s2.R2, s2.adjR2);
for k = 1:4
    fprintf('%-10s %10.4f %10.4f %10.4f %10.4g\n', terms{k}, s2.coef(k), s2.se(k), s2.tstat(k), s2.pvalue(k));
end
if license('test', 'Statistics_Toolbox') && ~isempty(which('fitlm'))
    T = table(Rain, Temp, Wind, PM25, 'VariableNames', {'Rain', 'Temp', 'WindSpeed', 'PM25'});
    mdl = fitlm(T, 'PM25~Rain+Temp+WindSpeed')   % toolbox output for comparison
end

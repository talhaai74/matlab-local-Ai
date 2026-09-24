% TOPIC: interpolation
% TITLE: Population: 7th-order polynomial through the first 8 points to predict the year 2000
% SOURCE: CE206 slides 04 page 19
% KEYWORDS: polyfit, polyval, polynomial interpolation, population, 7th order polynomial, predict, extrapolation, true error
% PROBLEM:
% Use polyfit and polyval to predict the population of 2000 using a 7th order polynomial fitted with
% the first 8 points: Year = 1920 1930 1940 1950 1960 1970 1980 1990 2000,
% Population (million) = 106.46 123.08 132.12 152.27 180.67 205.05 227.23 249.46 281.42.
% Compare with the true value and plot.
% CHECK: abs(P2000 - 175.08) < 0.01
% CODE:
yr = 1920:10:2000;
P = [106.46 123.08 132.12 152.27 180.67 205.05 227.23 249.46 281.42];
[p, S, mu] = polyfit(yr(1:8), P(1:8), 7);   % scaled x keeps the fit well conditioned
P2000 = polyval(p, 2000, S, mu);
et = abs((P(9) - P2000)/P(9))*100;
fprintf('Predicted 2000 population = %.2f million, true = %.2f million, et = %.1f %%\n', P2000, P(9), et);
fprintf('A high-order polynomial through all points oscillates and extrapolates very badly.\n');
yy = linspace(1920, 2000, 300);
figure; plot(yr, P, 'ko', yy, polyval(p, yy, S, mu), 'b-'); grid on;
xlabel('Year'); ylabel('Population (million)'); legend('data', '7th-order polynomial', 'Location', 'northwest');

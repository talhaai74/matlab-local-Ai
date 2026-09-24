% TOPIC: stats
% TITLE: Monte Carlo: maximum height of a ball trajectory from 10,000 random x values vs calculus
% SOURCE: Chapra Prob. 14.35
% KEYWORDS: monte carlo, random numbers, rand, uniform distribution, trajectory, maximum height, max function, analytical, calculus
% PROBLEM:
% The trajectory of a ball is y = (tan(theta0)) x - g/(2 v0^2 cos^2(theta0)) x^2 + y0. Given y0 = 1 m,
% v0 = 25 m/s and theta0 = 50 deg, determine the maximum height and the corresponding x distance
% (a) analytically with calculus and (b) numerically with a Monte Carlo simulation: generate a vector
% of 10,000 uniformly distributed x values between 0 and 60 m, compute the heights and use max.
% CHECK: abs(xmax - 31.3713) < 1e-3 && abs(ymax - 19.6934) < 1e-3 && abs(ymc - ymax) < 0.01
% CODE:
g = 9.81; y0 = 1; v0 = 25; th0 = 50;
y = @(x) tand(th0)*x - g/(2*v0^2*cosd(th0)^2)*x.^2 + y0;
%% (a) calculus: dy/dx = tan(th0) - g x/(v0^2 cos^2(th0)) = 0
xmax = v0^2*cosd(th0)^2*tand(th0)/g;
ymax = y(xmax);
fprintf('(a) analytical: x = %.4f m, maximum height = %.4f m\n', xmax, ymax);
%% (b) Monte Carlo
rng(1);                              % reproducible random numbers
x = 60*rand(1, 10000);
[ymc, k] = max(y(x));
fprintf('(b) Monte Carlo (10,000 points): x = %.4f m, maximum height = %.4f m\n', x(k), ymc);

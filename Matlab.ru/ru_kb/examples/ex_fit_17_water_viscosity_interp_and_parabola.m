% TOPIC: regression
% TITLE: Viscosity of water at 7.5 C: linear interpolation and parabola by polynomial regression
% SOURCE: Class solution sheet "Curve-fitting and Interpolation"; Chapra Prob. 15.17
% KEYWORDS: dynamic viscosity, water, temperature, linear interpolation, interp1, polynomial regression, parabola, predict, plot
% PROBLEM:
% Dynamic viscosity of water mu (10^-3 N s/m^2) is related to temperature T (C): T = 0 5 10 20 30 40,
% mu = 1.787 1.519 1.307 1.002 0.7975 0.6529. (a) Plot this data. (b) Use linear interpolation to predict mu at
% T = 7.5 C. (c) Use polynomial regression to fit a parabola to the data in order to make the same prediction.
% CHECK: abs(mu_lin - 1.413) < 1e-12 && abs(mu_par - 1.426889) < 1e-6
% CODE:
T = [0 5 10 20 30 40];
mu = [1.787 1.519 1.307 1.002 0.7975 0.6529];
mu_lin = interp1(T, mu, 7.5);
p = polyfit(T, mu, 2);
mu_par = polyval(p, 7.5);
disp('(b)')
fprintf('linear interpolation: mu(7.5) = %.4f x 10^-3 N s/m^2\n', mu_lin);
disp('(c)')
fprintf('parabola mu = %.4e T^2 %+.4e T %+.4f: mu(7.5) = %.4f x 10^-3 N s/m^2\n', p(1), p(2), p(3), mu_par);
Tp = linspace(0, 40);
figure; plot(T, mu, '*', Tp, interp1(T, mu, Tp), '-r', Tp, polyval(p, Tp), '-g'); grid on;
xlabel('T (C)'); ylabel('\mu (10^{-3} N s/m^2)'); legend('data', 'linear interpolation', 'parabola');

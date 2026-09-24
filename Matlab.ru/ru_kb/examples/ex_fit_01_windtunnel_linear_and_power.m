% TOPIC: regression
% TITLE: Wind tunnel force vs velocity: straight-line fit and log-transformed power fit (linregr)
% SOURCE: CE206 slides 04 pages 3-7 (linregr)
% KEYWORDS: linear regression, linregr, straight line, coefficient of determination, r2, log transformed, power model, wind tunnel, force, velocity
% PROBLEM:
% Experimental data for force F (N) and velocity v (m/s) from a wind tunnel:
% v = 10 20 30 40 50 60 70 80, F = 25 70 380 550 610 1220 830 1450.
% (a) Fit a straight line and give the slope, intercept and r^2.
% (b) Fit the log10-transformed data with a straight line, obtain the power model F = a v^b and r^2.
% Plot the data with both fits.
% CHECK: norm(a - [19.4702 -234.2857]) < 1e-3 && abs(r2 - 0.8805) < 1e-4
% CHECK: abs(al - 0.2741) < 1e-3 && abs(be - 1.9842) < 1e-3 && abs(r2l - 0.9481) < 1e-4
% CODE:
v = [10 20 30 40 50 60 70 80];
F = [25 70 380 550 610 1220 830 1450];
%% (a) straight line
[a, r2] = fit_linear(v, F);
fprintf('(a) F = %.4f v %+.4f,  r^2 = %.4f\n', a(1), a(2), r2);
%% (b) power model through log10 transformation
[al, be, r2orig] = fit_power(v, F);       % r2orig: r^2 of the power curve on the original F
p = polyfit(log10(v), log10(F), 1);       % same fit: slope = b, intercept = log10(a)
R = corrcoef(log10(v), log10(F));
r2l = R(1,2)^2;                           % r^2 of the straight line on the log data (slides)
fprintf('(b) log10(F) = %.4f log10(v) %+.4f -> F = %.4f v^%.4f\n', p(1), p(2), al, be);
fprintf('    r^2 of the log-log line = %.4f, r^2 of the power curve on the original data = %.4f\n', r2l, r2orig);
vv = linspace(10, 80, 200);
figure;
plot(v, F, 'ko', vv, a(1)*vv + a(2), 'b-', vv, al*vv.^be, 'r--', 'LineWidth', 1.5);
grid on; xlabel('v (m/s)'); ylabel('F (N)'); title('Wind tunnel data');
legend('data', 'linear fit', 'power fit (log transformed)', 'Location', 'northwest');

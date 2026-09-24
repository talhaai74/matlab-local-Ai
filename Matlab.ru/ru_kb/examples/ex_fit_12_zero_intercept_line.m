% TOPIC: regression
% TITLE: Straight line with and without zero intercept (tensile strength vs heat-treatment time)
% SOURCE: Chapra Prob. 14.20
% KEYWORDS: zero intercept, through the origin, straight line, predict, tensile strength, regression
% PROBLEM:
% Tensile strength increases with heat-treatment time:
% time = 10 15 20 25 40 50 55 60 75, strength = 5 20 18 40 33 54 70 60 78.
% (a) Fit a straight line and use it to determine the tensile strength at 32 min.
% (b) Repeat the analysis for a straight line with a zero intercept.
% CHECK: abs(sa - 34.70489) < 1e-4 && abs(a0 - 1.075141) < 1e-5
% CODE:
t = [10 15 20 25 40 50 55 60 75];
S = [5 20 18 40 33 54 70 60 78];
a = fit_linear(t, S);
sa = a(1)*32 + a(2);
fprintf('(a) S = %.4f t %+.4f  ->  S(32) = %.3f\n', a(1), a(2), sa);
a0 = sum(t.*S)/sum(t.^2);              % least squares through the origin
fprintf('(b) S = %.4f t (zero intercept)  ->  S(32) = %.3f\n', a0, a0*32);
tt = linspace(0, 80, 100);
figure; plot(t, S, 'ko', tt, a(1)*tt + a(2), 'b-', tt, a0*tt, 'r--'); grid on;
xlabel('time (min)'); ylabel('tensile strength'); legend('data', 'with intercept', 'zero intercept', 'Location', 'northwest');

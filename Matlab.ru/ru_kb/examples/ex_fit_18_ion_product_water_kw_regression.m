% TOPIC: regression
% TITLE: Ion product of water: -log10 Kw = a/Ta + b log10 Ta + c Ta + d by linear least squares
% SOURCE: Class solution sheet "Curve-fitting and Interpolation"; Chapra Prob. 15.19
% KEYWORDS: general linear least squares, ion product of water, Kw, acid rain, absolute temperature, log10, parameters a b c d, plot
% PROBLEM:
% The ion product of water Kw as a function of temperature is modeled as -log10 Kw = a/Ta + b log10 Ta + c Ta + d,
% where Ta = absolute temperature (K). Use the data T (C) = 0 10 20 30 40,
% Kw = 1.164e-15 2.950e-15 6.846e-15 1.467e-14 2.929e-14 and regression to estimate the parameters with MATLAB.
% Also generate a plot of predicted Kw versus the data.
% CHECK: abs(a/5180.67814 - 1) < 1e-4 && abs(b/13.4242059 - 1) < 1e-4 && abs(c/0.00562889939 - 1) < 1e-4 && abs(d/(-38.2766497) - 1) < 1e-4
% CODE:
T = (0:10:40)';
Ta = T + 273.15;
Kw = [1.164; 2.95; 6.846; 14.67; 29.29]*1e-15;
Z = [ones(size(Ta)) 1./Ta log10(Ta) Ta];
p = Z\(-log10(Kw));
d = p(1); a = p(2); b = p(3); c = p(4);
fprintf('a = %.4f, b = %.4f, c = %.6f, d = %.4f\n', a, b, c, d);
Tp = linspace(0, 40) + 273.15;
Kwp = 10.^(-(a./Tp + b*log10(Tp) + c*Tp + d));
figure; plot(Ta, Kw, '*', Tp, Kwp, '-'); grid on;
xlabel('T (K)'); ylabel('K_w'); legend('data', 'model');

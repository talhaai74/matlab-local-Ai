% TOPIC: fourier
% TITLE: Monthly solar radiation: fit a sinusoid (period one year) and predict mid-August
% SOURCE: Chapra Prob. 16.2
% KEYWORDS: sinusoid fit, solar radiation, monthly data, period, least squares, predict, 30 days per month
% PROBLEM:
% Solar radiation for Tucson (W/m^2): J 144, F 188, M 245, A 311, M 351, J 359, J 308, A 287, S 260,
% O 211, N 159, D 131. Assuming each month is 30 days long, fit a sinusoid to these data. Use the
% resulting equation to predict the radiation in mid-August.
% CHECK: abs(Raug - 299.170) < 1e-2
% CODE:
R = [144 188 245 311 351 359 308 287 260 211 159 131];
t = 15:30:345;                           % mid-month day, 30-day months
T = 360; w0 = 2*pi/T;
Z = [ones(12,1) cos(w0*t') sin(w0*t')];
a = Z\R';
Raug = a(1) + a(2)*cos(w0*225) + a(3)*sin(w0*225);   % mid-August = day 225
fprintf('R = %.3f %+.3f cos(w0 t) %+.3f sin(w0 t), w0 = 2pi/360\n', a);
fprintf('Mean %.2f, amplitude %.2f W/m^2; mid-August prediction = %.2f W/m^2\n', a(1), hypot(a(2), a(3)), Raug);
tt = 0:360;
figure; plot(t, R, 'ko', tt, a(1) + a(2)*cos(w0*tt) + a(3)*sin(w0*tt), 'b-'); grid on;
xlabel('day of year'); ylabel('radiation (W/m^2)');

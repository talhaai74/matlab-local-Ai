% TOPIC: fourier
% TITLE: Least-squares sinusoid fit of daily pH: mean, amplitude and time of maximum (24-h period)
% SOURCE: Chapra Prob. 16.1 (Eq. 16.11)
% KEYWORDS: sinusoid, least-squares fit, mean value, amplitude, phase, time of maximum, period, a0 a1 b1
% PROBLEM:
% The pH in a reactor varies sinusoidally over a day: t (hr) = 0 2 4 5 7 9 12 15 20 22 24,
% pH = 7.6 7.2 7 6.5 7.5 7.2 8.9 9.1 8.9 7.9 7. Fit y = A0 + A1 cos(w0 t) + B1 sin(w0 t) with a 24-hr
% period and determine the mean, amplitude and time of maximum pH.
% CHECK: abs(A0 - 8.02704) < 1e-4 && abs(C1 - 1.24631) < 1e-4 && abs(tmax - 16.0913) < 1e-3
% CODE:
t = [0 2 4 5 7 9 12 15 20 22 24];
pH = [7.6 7.2 7 6.5 7.5 7.2 8.9 9.1 8.9 7.9 7];
T = 24; w0 = 2*pi/T;
Z = [ones(numel(t),1) cos(w0*t(:)) sin(w0*t(:))];
a = Z\pH(:);
A0 = a(1); A1 = a(2); B1 = a(3);
C1 = sqrt(A1^2 + B1^2);
theta = atan2(-B1, A1);                 % y = A0 + C1 cos(w0 t + theta)
tmax = mod(-theta/w0, T);
fprintf('pH = %.4f %+.4f cos(w0 t) %+.4f sin(w0 t)\n', A0, A1, B1);
fprintf('Mean = %.4f, amplitude = %.4f, time of maximum pH = %.2f hr\n', A0, C1, tmax);
tt = linspace(0, 24, 200);
figure; plot(t, pH, 'ko', tt, A0 + A1*cos(w0*tt) + B1*sin(w0*tt), 'b-'); grid on; xlabel('t (hr)'); ylabel('pH');

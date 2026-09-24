function [A0, A1, B1, C1, theta] = fourier_sinefit(t, y, f0)
%FOURIER_SINEFIT  Least-squares fit y = A0 + A1*cos(w0 t) + B1*sin(w0 t).
%   [A0, A1, B1, C1, theta] = fourier_sinefit(t, y, f0)
%   t, y   data vectors of equal length
%   f0     known/assumed frequency (Hz); w0 = 2*pi*f0
%   A0     fitted offset (mean); A1, B1 fitted cosine/sine coefficients
%   C1     amplitude,  C1 = sqrt(A1^2 + B1^2)
%   theta  phase (rad): y = A0 + C1*cos(w0*t + theta), theta = atan2(-B1,A1)
%   Linear least squares via backslash on the design matrix [1 cos(w0 t) sin(w0 t)].
%   Call without outputs to print the coefficients and plot data vs the fit.
%   Example: [A0, A1, B1, C1, th] = fourier_sinefit(t, y, 12.5)

if nargin < 3 || isempty(f0)
    error('ru_lib:fourier_sinefit:input', 'FOURIER_SINEFIT: f0 (frequency, Hz) is required.');
end
t = t(:);
y = y(:);
if length(t) ~= length(y)
    error('ru_lib:fourier_sinefit:size', 'FOURIER_SINEFIT: t and y must have the same length (got %d and %d).', length(t), length(y));
end
if length(t) < 3
    error('ru_lib:fourier_sinefit:short', 'FOURIER_SINEFIT: need at least 3 data points, got %d.', length(t));
end
w0 = 2*pi*f0;
Z = [ones(size(t)), cos(w0*t), sin(w0*t)];
c = Z \ y;
A0 = c(1); A1 = c(2); B1 = c(3);
C1 = sqrt(A1^2 + B1^2);
theta = atan2(-B1, A1);
if nargout == 0
    fprintf('A0    = %.6f\n', A0);
    fprintf('A1    = %.6f\n', A1);
    fprintf('B1    = %.6f\n', B1);
    fprintf('C1    = %.6f  (amplitude)\n', C1);
    fprintf('theta = %.6f rad (phase)\n', theta);
    tt = linspace(min(t), max(t), 400);
    yfit = A0 + A1*cos(w0*tt) + B1*sin(w0*tt);
    figure; plot(t, y, 'ko', 'MarkerFaceColor', 'k'); hold on;
    plot(tt, yfit, 'r-', 'linewidth', 2); grid on;
    xlabel('t'); ylabel('y');
    legend('data', 'fit');
    title('Sinusoidal least-squares fit');
end
end

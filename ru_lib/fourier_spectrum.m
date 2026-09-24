function [f, P, A] = fourier_spectrum(y, dt)
%FOURIER_SPECTRUM  One-sided amplitude/power spectrum of sampled real data via fft.
%   [f, P, A] = fourier_spectrum(y, dt)
%   y    real signal, n equally spaced samples (row or column vector)
%   dt   sampling interval (s); fs = 1/dt, Nyquist = fs/2, fmin = 1/(n*dt)
%   f    one-sided frequency axis (Hz), f = linspace(fmin, fs/2, floor(n/2))
%   P    power spectrum, P = |Y|.^2 at those frequencies (Y = fft(y)/n, DC removed)
%   A    amplitude spectrum, A = 2*abs(Y) (true sinusoid amplitude at each f)
%   Call without outputs to plot power vs frequency and print the dominant
%   frequency and period.
%   Example: [f, P, A] = fourier_spectrum(y, 0.02)

if nargin < 1 || isempty(y)
    error('ru_lib:fourier_spectrum:input', 'FOURIER_SPECTRUM: y (data vector) is required.');
end
if nargin < 2 || isempty(dt)
    error('ru_lib:fourier_spectrum:input', 'FOURIER_SPECTRUM: dt (sampling interval, s) is required.');
end
y = y(:).';
n = length(y);
if n < 2
    error('ru_lib:fourier_spectrum:short', 'FOURIER_SPECTRUM: y needs at least 2 samples (got %d).', n);
end
fs = 1/dt;
nyq = fs/2;
fmin = 1/(n*dt);
m = floor(n/2);
Y = fft(y)/n;
Y(1) = [];
YP = Y(1:m);
f = linspace(fmin, nyq, m);
P = abs(YP).^2;
A = 2*abs(YP);
if nargout == 0
    fprintf('fs = %.4g Hz, Nyquist = %.4g Hz, fmin = %.4g Hz\n', fs, nyq, fmin);
    fprintf('    f (Hz)       P            A\n');
    for k = 1:m
        fprintf('  %8.4f   %8.4f   %8.4f\n', f(k), P(k), A(k));
    end
    [pk, idx] = max(P); %#ok<ASGLU>
    fprintf('Dominant frequency: %.4f Hz (period %.4f s)\n', f(idx), 1/f(idx));
    figure; stem(f, P, 'linewidth', 2, 'MarkerFaceColor', 'blue'); grid on;
    xlabel('Frequency (Hz)'); ylabel('Power');
    title('Power Spectrum');
end
end

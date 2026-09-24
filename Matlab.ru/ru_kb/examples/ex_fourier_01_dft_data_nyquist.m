% TOPIC: fourier
% TITLE: DFT of 8 sampled points with fft: sampling frequency, Nyquist frequency, lowest detectable frequency
% SOURCE: CE206 slides 07 pages 10-11
% KEYWORDS: dft, fft, discrete fourier transform, sampling frequency, nyquist frequency, lowest detectable frequency, period range
% PROBLEM:
% Apply MATLAB's fft function to determine the DFT of t = 0 0.02 0.04 0.06 0.08 0.1 0.12 0.14 s,
% f(t) = 6.0 5.7 3.0 5.7 6.0 4.3 5.0 4.3. Give the sampling frequency, the Nyquist frequency, the lowest
% detectable frequency and the range of periods the analysis can detect.
% CHECK: abs(Y(1) - 5) < 1e-12 && abs(Y(3) - 0.5) < 1e-12 && abs(fs - 50) < 1e-9 && abs(fmin - 6.25) < 1e-9
% CODE:
t = 0:0.02:0.14;
y = [6.0 5.7 3.0 5.7 6.0 4.3 5.0 4.3];
n = numel(y); dt = t(2) - t(1);
fs = 1/dt; nyquist = fs/2; fmin = 1/(n*dt);
Y = fft(y)/n;
fprintf('Sampling frequency = %g Hz, Nyquist = %g Hz, lowest detectable = %g Hz\n', fs, nyquist, fmin);
fprintf('Detectable periods: %g s to %g s\n', 1/nyquist, 1/fmin);
fprintf('Y = fft(y)/n:\n');
for k = 1:n
    fprintf('  Y(%d) = %8.4f %+8.4fi\n', k, real(Y(k)), imag(Y(k)));
end
fprintf('Check with the direct DFT sum (fourier_dft): max difference = %.1e\n', max(abs(fourier_dft(y)/n - Y)));

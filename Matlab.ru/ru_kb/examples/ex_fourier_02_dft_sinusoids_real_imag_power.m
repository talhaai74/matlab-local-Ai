% TOPIC: fourier
% TITLE: DFT of f(t) = 5 + cos(2 pi 12.5 t) + sin(2 pi 18.75 t): signal, real and imaginary parts, power spectrum
% SOURCE: CE206 slides 07 pages 12-16
% KEYWORDS: fft, dft, sinusoid, 8 equispaced points, real component, imaginary component, stem, subplot, power spectrum, frequency, 2pi(12.5)t
% PROBLEM:
% Apply fft to determine the DFT of f(t) = 5 + cos(2pi(12.5)t) + sin(2pi(18.75)t). Generate 8 equispaced
% points with dt = 0.02 s. Plot (a) f(t) versus time, (b) the real component and (c) the imaginary component
% of the DFT versus frequency, and plot the power spectrum.
% CHECK: abs(Yall(1) - 5) < 1e-12 && abs(real(Yall(3)) - 0.5) < 1e-12 && abs(abs(Yall(4)) - 0.5) < 1e-12
% CHECK: numel(f) == 4 && abs(f(end) - 25) < 1e-12
% CODE:
n = 8; dt = 0.02; fs = 1/dt;
t = (0:n-1)*dt;
y = 5 + cos(2*pi*12.5*t) + sin(2*pi*18.75*t);
Yall = fft(y)/n;
fprintf('Y = fft(y)/n: %s\n', mat2str(round(Yall*1e4)/1e4));
figure(1);
subplot(3,1,1); plot(t, y, '-ok', 'LineWidth', 2, 'MarkerFaceColor', 'k'); title('(a) f(t) versus time (s)');
nyquist = fs/2; fmin = 1/(n*dt);
f = linspace(fmin, nyquist, n/2);
Y = Yall; Y(1) = [];                       % remove the mean (first value)
YP = Y(1:n/2);
subplot(3,1,2); stem(f, real(YP), 'LineWidth', 2); grid on; title('(b) Real component versus frequency');
subplot(3,1,3); stem(f, imag(YP), 'LineWidth', 2); grid on; title('(c) Imaginary component versus frequency');
xlabel('frequency (Hz)');
Pyy = abs(YP).^2;
figure(2); stem(f, Pyy, 'LineWidth', 2); title('Power spectrum'); xlabel('Frequency (Hz)'); grid on;
fprintf('%10s %10s %10s %10s\n', 'f (Hz)', 'real', 'imag', 'power');
fprintf('%10.2f %10.4f %10.4f %10.4f\n', [f; real(YP); imag(YP); Pyy]);
fprintf('Mean = %.1f; the 12.5 Hz cosine shows in the real part, the 18.75 Hz sine in the imaginary part.\n', real(Yall(1)));

% TOPIC: fourier
% TITLE: FFT of 64 samples of cos(2 pi 12.5 t) + cos(2 pi 25 t) at dt = 0.01 s: find the frequencies
% SOURCE: Chapra Prob. 16.9 (Example 16.3)
% KEYWORDS: fft, 64 points, sampling rate, dt = 0.01, two cosines, spectrum, peaks, dominant frequencies
% PROBLEM:
% Duplicate Example 16.3 for 64 points sampled at dt = 0.01 s from f(t) = cos[2pi(12.5)t] + cos[2pi(25)t].
% Use fft to generate a DFT of these values and plot the results (real, imaginary and power versus
% frequency). Identify the frequencies present.
% CHECK: isequal(sort(fpk), [12.5 25])
% CODE:
n = 64; dt = 0.01; fs = 1/dt;
t = (0:n-1)*dt;
y = cos(2*pi*12.5*t) + cos(2*pi*25*t);
Y = fft(y)/n;
f = (1:n/2)*fs/n;                        % frequencies of Y(2:n/2+1)
Yp = Y(2:n/2+1);
P = abs(Yp).^2;
[~, idx] = sort(P, 'descend');
fpk = f(idx(1:2));
fprintf('Nyquist = %g Hz, resolution = %g Hz\n', fs/2, fs/n);
fprintf('Largest peaks at %g Hz and %g Hz (|Y| = %.3f, %.3f)\n', fpk(1), fpk(2), abs(Yp(idx(1))), abs(Yp(idx(2))));
figure;
subplot(3,1,1); stem(f, real(Yp)); grid on; title('Real part');
subplot(3,1,2); stem(f, imag(Yp)); grid on; title('Imaginary part');
subplot(3,1,3); stem(f, P); grid on; title('Power'); xlabel('Frequency (Hz)');

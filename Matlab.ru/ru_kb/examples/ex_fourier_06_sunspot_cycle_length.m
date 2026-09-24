% TOPIC: fourier
% TITLE: Wolf sunspot numbers: remove the linear trend, fft power spectrum and the cycle length
% SOURCE: CE206 slides 07 pages 17-18
% KEYWORDS: sunspot, sunspot.dat, load, detrend, linear trend, fft, power spectrum, cycle length, wolf, 11.1 years
% SELFTEST: skip
% PROBLEM:
% The data for year-wise sunspot numbers are in the MATLAB file sunspot.dat. Perform Fourier analysis on
% the time series and determine the cycle length. Compare it with J.R. Wolf's estimate (~11.1 years).
% CODE:
load sunspot.dat
year = sunspot(:,1);
number = sunspot(:,2);
n = length(number);
a = polyfit(year, number, 1);
ft = number - polyval(a, year);          % remove the upward linear trend
F = fft(ft);
fs = 1;                                  % one sample per year
f = (0:n/2)*fs/n;
pow = abs(F(1:n/2+1)).^2;
[~, k] = max(pow(2:end));                % skip the zero frequency
fpeak = f(k + 1);
fprintf('Dominant frequency = %.4f cycles/year -> cycle length = %.2f years (Wolf: 11.1 years)\n', fpeak, 1/fpeak);
figure; plot(f, pow); grid on; xlabel('Frequency (cycles/year)'); ylabel('power'); title('Power versus frequency');

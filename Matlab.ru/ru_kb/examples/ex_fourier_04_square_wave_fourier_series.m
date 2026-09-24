% TOPIC: fourier
% TITLE: Fourier series of a square wave: plot the first n terms individually and their sum
% SOURCE: Chapra Prob. 16.4 (FourierSquare)
% KEYWORDS: fourier series, square wave, first n terms, summation, harmonics, function file, fouriersquare
% PROBLEM:
% A square wave f(t) = A0 for 0 <= t <= T/2 and -A0 for T/2 <= t <= T has the Fourier series
% f(t) = sum_{n=1}^inf (4A0/((2n-1)pi)) sin(2pi(2n-1)t/T). Develop a function
% [t, f] = FourierSquare(A0, T, n) that plots the first n terms individually (thin dotted red lines) and
% their sum (bold black line) from t = 0 to 4T. Use A0 = 1, T = 0.25 s and n = 6.
% CHECK: abs(f(round(numel(t)/16)) - 1) < 0.15 && numel(t) == 801
% CODE:
[t, f] = FourierSquare(1, 0.25, 6);
fprintf('Sum of 6 terms at t = T/4: %.4f (square wave value 1)\n', interp1(t, f, 0.25/4));

function [t, f] = FourierSquare(A0, T, n)
% Plot the first n terms of the square-wave Fourier series and their sum.
t = linspace(0, 4*T, 801);
f = zeros(size(t));
figure; hold on;
for k = 1:n
    term = 4*A0/((2*k - 1)*pi)*sin(2*pi*(2*k - 1)*t/T);
    plot(t, term, 'r:');
    f = f + term;
end
plot(t, f, 'k-', 'LineWidth', 2);
hold off; grid on; xlabel('t (s)'); ylabel('f(t)'); title(sprintf('Square wave: first %d terms and their sum', n));
end

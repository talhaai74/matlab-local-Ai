function [a0, a, b] = fourier_series(f, T, N)
%FOURIER_SERIES  Continuous Fourier-series coefficients of a T-periodic f(t).
%   [a0, a, b] = fourier_series(f, T, N)
%   f    periodic function of t: handle @(t).., text 't.^2', or sym
%   T    period; w0 = 2*pi/T
%   N    number of harmonics to compute (default 5)
%   a0   mean value of f over one period, a0 = (1/T)*integral(f,0,T)
%   a,b  1xN cosine/sine coefficients (numerical integration over one period)
%   f(t) ~= a0 + sum_k a(k)*cos(k*w0*t) + b(k)*sin(k*w0*t), w0 = 2*pi/T
%   Call without outputs to plot f(t) against the N-term series over [0,T].
%   Example: [a0, a, b] = fourier_series(@(t) abs(t - 1), 2, 5)

if nargin < 2 || isempty(T)
    error('ru_lib:fourier_series:input', 'FOURIER_SERIES: T (period) is required.');
end
if nargin < 3 || isempty(N)
    N = 5;
end
f = ru_tofunc(f, {'t'});
w0 = 2*pi/T;
a0 = (1/T) * integral(f, 0, T, 'ArrayValued', true);
a = zeros(1, N);
b = zeros(1, N);
for k = 1:N
    a(k) = (2/T) * integral(@(t) f(t).*cos(k*w0*t), 0, T, 'ArrayValued', true);
    b(k) = (2/T) * integral(@(t) f(t).*sin(k*w0*t), 0, T, 'ArrayValued', true);
end
if nargout == 0
    fprintf('a0 = %.6f\n', a0);
    fprintf('  k      ak          bk\n');
    for k = 1:N
        fprintf('  %2d  %9.5f  %9.5f\n', k, a(k), b(k));
    end
    tt = linspace(0, T, 400);
    ft = zeros(size(tt));
    for i = 1:length(tt)
        ft(i) = f(tt(i));
    end
    s = a0*ones(size(tt));
    for k = 1:N
        s = s + a(k)*cos(k*w0*tt) + b(k)*sin(k*w0*tt);
    end
    figure; plot(tt, ft, 'k-', 'linewidth', 2); hold on;
    plot(tt, s, 'r--', 'linewidth', 2); grid on;
    xlabel('t'); ylabel('f(t)');
    legend('f(t)', sprintf('%d-term series', N));
    title('Fourier series approximation');
end
end

% TOPIC: basics
% TITLE: Semi-log (semilogx, semilogy) and log-log plots
% SOURCE: Slides 01, pages 25-26 (semilogx/semilogy; loglog)
% KEYWORDS: semilogx, semilogy, loglog, logspace, log scale plot
% PROBLEM:
% For x = 0:0.1:10, plot semilogx(10.^x, x) and separately semilogy(x, 10.^x).
% Using x = logspace(-1,2), plot loglog(x, exp(x), 's-') and turn the grid on.
% CHECK: numel(x1) == 101 && abs(x1(end) - 10) < 1e-9
% CHECK: numel(x2) == 50 && abs(x2(1) - 0.1) < 1e-9 && abs(x2(end) - 100) < 1e-9
% CODE:
x1 = 0:0.1:10;
figure;
semilogx(10.^x1, x1);
xlabel('10^x'); ylabel('x'); title('semilogx');

figure;
semilogy(x1, 10.^x1);
xlabel('x'); ylabel('10^x'); title('semilogy');

x2 = logspace(-1,2);
figure;
loglog(x2, exp(x2), 's-');
grid on;
xlabel('x'); ylabel('exp(x)'); title('loglog');
fprintf('x1 has %d points (0 to %.1f), x2 has %d points (%.2f to %.2f)\n', ...
    numel(x1), x1(end), numel(x2), x2(1), x2(end));

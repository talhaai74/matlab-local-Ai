% TOPIC: basics
% TITLE: Multi-curve plot with legend/title/labels, and hold on to overlay
% SOURCE: Slides 01, pages 22-24 (basic sine plot; multi-plot with labels; hold on/off)
% KEYWORDS: plot, legend, title, xlabel, ylabel, grid, hold on, overlay curves
% PROBLEM:
% Plot y = sin(3*pi*x) as a blue solid line and cos(3*pi*x) as a green dashed
% line on x = linspace(0,1,11), with legend, title 'Multi-plot', xlabel
% 'x axis', ylabel 'y axis' and grid on.
% Then, for x = 0:.1:2*pi, plot y = sin(x) in blue, turn grid on, use hold on
% and overlay exp(-x) as red star markers.
% CHECK: numel(x) == 11 && abs(y(1)) < 1e-12
% CHECK: abs(cos(3*pi*x(1)) - 1) < 1e-9
% CHECK: numel(xh) == 63 && abs(xh(end) - 6.2) < 1e-9
% CHECK: abs(yh(1)) < 1e-12
% CODE:
x = linspace(0,1,11);
y = sin(3*pi*x);
figure;
plot(x, y, 'b-', x, cos(3*pi*x), 'g--');
legend('Sin curve','Cos curve');
title('Multi-plot');
xlabel('x axis'); ylabel('y axis');
grid on;

xh = 0:.1:2*pi;
yh = sin(xh);
figure;
plot(xh, yh, 'b');
grid on;
hold on;
plot(xh, exp(-xh), 'r*');
hold off;
legend('sin(x)','exp(-x)');
fprintf('x has %d points, y has %d points, xh has %d points\n', numel(x), numel(y), numel(xh));

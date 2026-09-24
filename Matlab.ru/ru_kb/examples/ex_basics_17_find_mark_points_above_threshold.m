% TOPIC: basics
% TITLE: Using find() to mark points above a threshold on a curve
% SOURCE: Slides 01, page 39 (find() command example)
% KEYWORDS: find function, threshold, mark points, plot markers, exponential decay sine
% PROBLEM:
% For x = -1:.05:1 and y = sin(3*pi*x).*exp(-x.^2), find all points with
% y greater than 0.2 using k = find(y > 0.2), then plot y with a dotted line
% and mark the points x(k), y(k) with circles.
% CHECK: numel(x) == 41
% CHECK: isequal(k, [9 10 11 12 13 22 23 24 25 26 27 36 37 38 39])
% CODE:
x = -1:.05:1;
y = sin(3*pi*x).*exp(-x.^2);
k = find(y > 0.2);

figure;
plot(x, y, ':');
hold on;
plot(x(k), y(k), 'o');
hold off;
xlabel('x'); ylabel('y');
title('y = sin(3 pi x) exp(-x^2), marked where y > 0.2');

fprintf('indices where y > 0.2: ');
fprintf('%d ', k);
fprintf('\n');

% TOPIC: basics
% TITLE: 2x2 subplot grid of sin/cos at two frequencies
% SOURCE: Slides 01, pages 27-28 (subplot)
% KEYWORDS: subplot, multi-panel figure, plot grid
% PROBLEM:
% Using x = linspace(0,1,11), create a 2x2 grid of subplots showing
% sin(3*pi*x), cos(3*pi*x), sin(6*pi*x) and cos(6*pi*x), each labeled with
% xlabel('x') and an ylabel naming the curve.
% CHECK: numel(x) == 11 && abs(y1(1)) < 1e-12
% CHECK: abs(cos(6*pi*x(end)) - 1) < 1e-9
% CODE:
x = linspace(0,1,11);
y1 = sin(3*pi*x);
y2 = cos(3*pi*x);
y3 = sin(6*pi*x);
y4 = cos(6*pi*x);

figure;
subplot(2,2,1); plot(x,y1); xlabel('x'); ylabel('sin 3 pi x');
subplot(2,2,2); plot(x,y2); xlabel('x'); ylabel('cos 3 pi x');
subplot(2,2,3); plot(x,y3); xlabel('x'); ylabel('sin 6 pi x');
subplot(2,2,4); plot(x,y4); xlabel('x'); ylabel('cos 6 pi x');
fprintf('plotted 4 panels over %d points of x in [0,1]\n', numel(x));

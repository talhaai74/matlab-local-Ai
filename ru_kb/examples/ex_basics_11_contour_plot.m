% TOPIC: basics
% TITLE: Contour plot of z = sin(x)*cos(y), and mesh combined with contour
% SOURCE: Slides 01, page 33 (contour plot)
% KEYWORDS: contour plot, meshgrid, mesh with contour, sin cos surface
% PROBLEM:
% Plot the contour of z = sin(x)*cos(y) for -pi <= x <= pi and -pi <= y <= pi,
% using x = -pi:0.1:pi, y = -pi:0.1:pi. Also overlay contour lines on the
% 3-D mesh of the same surface with hold on.
% CHECK: isequal(size(Z), [63 63])
% CHECK: max(Z(:)) <= 1 + 1e-9 && min(Z(:)) >= -1 - 1e-9
% CHECK: abs(z_check - 1) < 1e-9
% CODE:
x = -pi:0.1:pi;
y = -pi:0.1:pi;
[X,Y] = meshgrid(x,y);
Z = sin(X).*cos(Y);
z_check = sin(pi/2)*cos(0);   % independent formula check away from the grid

figure;
contour(X,Y,Z,'LineWidth',2);
xlabel('x'); ylabel('y'); title('Contour of sin(x)cos(y)');

figure;
mesh(X,Y,Z);
hold on;
contour(X,Y,Z);
hold off;
fprintf('Z is %dx%d, ranges [%.4f, %.4f]\n', size(Z,1), size(Z,2), min(Z(:)), max(Z(:)));

% TOPIC: basics
% TITLE: Specialized plots: polar, bar, quiver, stairs, fill
% SOURCE: Slides 01, page 34 (polar, bar, quiver, stairs, fill)
% KEYWORDS: polar plot, bar graph, quiver plot, stairs plot, fill polygon, specialized plotting
% PROBLEM:
% Demonstrate a polar plot of r = cos(2*theta) for theta = 0:0.01:2*pi, a bar
% graph of 10 values, a quiver velocity field on a 10x10 grid, a stairstep
% plot of 10 values, and a filled triangle with vertices (0,0),(1,0),(0.5,1).
% CHECK: numel(theta) == numel(r) && abs(r(1) - 1) < 1e-9
% CHECK: numel(barvals) == 10
% CHECK: isequal(size(Xq), [10 10]) && isequal(size(Yq), [10 10])
% CHECK: numel(stairvals) == 10
% CODE:
theta = 0:0.01:2*pi;
r = cos(2*theta);
figure;
polar(theta, r);
title('polar: r = cos(2 theta)');

barvals = rand(1,10);
figure;
bar(1:10, barvals);
title('bar');

[Xq,Yq] = meshgrid(1:10,1:10);
U = rand(10);
V = rand(10);
figure;
quiver(Xq,Yq,U,V);
title('quiver');

stairvals = rand(1,10);
figure;
stairs(1:10, stairvals);
title('stairs');

figure;
fill([0 1 0.5],[0 0 1],'r');
title('fill');
fprintf('theta has %d points, bar/stairs have %d values each, quiver grid is %dx%d\n', ...
    numel(theta), numel(barvals), size(Xq,1), size(Xq,2));

% TOPIC: differentiation
% TITLE: diff and gradient: derivatives of data at unequal and equal spacing versus the exact derivative
% SOURCE: CE206 slides 05 pages 2-3
% KEYWORDS: diff, gradient, numerical derivative, unequally spaced, equally spaced, forward difference, centered difference, polynomial
% PROBLEM:
% For f(x) = 0.2 + 25x - 200x^2 + 675x^3 - 900x^4 + 400x^5:
% (a) with the unequally spaced x = 0 0.12 0.22 0.32 0.36 0.4 0.44 0.54 0.64 0.7 0.8 estimate the
% derivative with diff; (b) with x = 0:0.1:0.8 estimate the derivative with gradient(y, 0.1);
% compare both with the exact derivative on a plot.
% CHECK: abs(dxu(1) - 9.247744) < 1e-6 && abs(g(2) - 5.44) < 1e-9
% CODE:
fx = @(x) 0.2 + 25*x - 200*x.^2 + 675*x.^3 - 900*x.^4 + 400*x.^5;
dfx = @(x) 25 - 400*x + 2025*x.^2 - 3600*x.^3 + 2000*x.^4;      % exact derivative
%% (a) unequal spacing: slope between neighbouring points, located at the midpoints
xu = [0 0.12 0.22 0.32 0.36 0.4 0.44 0.54 0.64 0.7 0.8];
yu = fx(xu);
dxu = diff(yu)./diff(xu);          % (note: diff(y)./diff(x), not diff(x)./diff(y))
xm = (xu(1:end-1) + xu(2:end))/2;
fprintf('(a) x_mid  diff(y)./diff(x)  exact\n');
fprintf('%8.3f %12.4f %12.4f\n', [xm; dxu; dfx(xm)]);
%% (b) equal spacing: gradient uses centered differences inside, one-sided at the ends
xe = 0:0.1:0.8;
g = gradient(fx(xe), 0.1);
fprintf('(b) x  gradient  exact\n');
fprintf('%6.2f %10.4f %10.4f\n', [xe; g; dfx(xe)]);
xx = linspace(0, 0.8, 200);
figure; plot(xx, dfx(xx), 'k-', xm, dxu, 'bo', xe, g, 'rs'); grid on;
xlabel('x'); ylabel('f''(x)'); legend('exact', 'diff (unequal)', 'gradient (h = 0.1)');

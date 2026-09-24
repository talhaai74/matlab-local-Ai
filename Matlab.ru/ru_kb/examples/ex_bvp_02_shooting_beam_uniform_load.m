% TOPIC: bvp
% TITLE: Shooting method for the deflection of a uniformly loaded simply supported beam vs analytical
% SOURCE: CE206 slides 06 page 20 (practice problem) / Endfiles bvp.m
% KEYWORDS: shooting method, beam deflection, elastic curve, uniformly loaded beam, simply supported, EI, kip, ksi, inch, analytical solution, linear bvp, two shots
% PROBLEM:
% The elastic curve of a uniformly loaded simply supported beam is EI d2y/dx2 = wLx/2 - wx^2/2 with
% y(0) = y(L) = 0. If E = 30000 ksi, I = 800 in^4, w = 1 kip/ft and L = 10 ft, solve for the deflection
% using the shooting method and compare with the analytical solution
% y = wLx^3/(12EI) - wx^4/(24EI) - wL^3x/(24EI).
% CHECK: maxdiff < 1e-6 && abs(ymid - (-5*w*L^4/(384*E*I))) < 1e-6
% CODE:
E = 30000; I = 800;              % ksi, in^4
w = 1/12; L = 10*12;             % 1 kip/ft = 1/12 kip/in, 10 ft = 120 in
f = @(x, y) [y(2); (w*L*x/2 - w*x.^2/2)/(E*I)];
opts = odeset('RelTol', 1e-10, 'AbsTol', 1e-12);
shoot = @(z) endValue(f, L, z, opts);
% Linear ODE: two shots and linear interpolation give the exact initial slope
z1 = -0.01; z2 = 0.01;
r1 = shoot(z1); r2 = shoot(z2);
z = z1 + (z2 - z1)*(0 - r1)/(r2 - r1);
[x, Y] = ode45(f, linspace(0, L, 41), [0 z], opts);
yexact = w*L*x.^3/(12*E*I) - w*x.^4/(24*E*I) - w*L^3*x/(24*E*I);
maxdiff = max(abs(Y(:,1) - yexact));
ymid = interp1(x, Y(:,1), L/2);
fprintf('Initial slope y''(0) = %.6e rad, midspan deflection = %.5f in (exact %.5f in)\n', z, ymid, -5*w*L^4/(384*E*I));
fprintf('Maximum difference from the analytical solution = %.2e in\n', maxdiff);
figure; plot(x/12, Y(:,1), 'bo', x/12, yexact, 'k-'); grid on;
xlabel('x (ft)'); ylabel('y (in)'); legend('shooting', 'analytical', 'Location', 'south');

function yL = endValue(f, L, z, opts)
[~, y] = ode45(f, [0 L], [0 z], opts);
yL = y(end, 1);
end

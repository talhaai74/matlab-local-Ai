% TOPIC: bvp
% TITLE: Shooting method for a heated rod with convection and radiation (nonlinear BVP, fzero on the residual)
% SOURCE: CE206 slides 06 pages 17-19 (dydxn, res) / Endfiles dydxn.m, residual.m
% KEYWORDS: shooting method, boundary value problem, heated rod, radiation, convection, residual, fzero, ode45, nonlinear, T(0) = 300, T(10) = 400
% PROBLEM:
% Solve d2T/dx2 + h'(Tinf - T) + sigma'(Tinf^4 - T^4) = 0 with sigma' = 2.7e-9 K^-3 m^-2, L = 10 m,
% h' = 0.05 m^-2, Tinf = 200 K, T(0) = 300 K and T(10) = 400 K using the shooting method.
% Write it as dT/dx = z, dz/dx = -0.05(200 - T) - 2.7e-9(1.6e9 - T^4), find the initial slope z(0)
% that makes T(10) = 400 with fzero (initial guess -50), and plot T(x).
% CHECK: abs(za - (-41.744)) < 0.01
% CHECK: abs(y(end,1) - 400) < 1e-3
% CODE:
dydx = @(x, y) [y(2);
                -0.05*(200 - y(1)) - 2.7e-9*(1.6e9 - y(1)^4)];
res = @(z) shootEnd(dydx, z) - 400;            % residual at x = 10
za = fzero(res, -50);
[x, y] = ode45(dydx, [0 10], [300 za]);
fprintf('Initial slope dT/dx(0) = %.4f K/m\n', za);
fprintf('T(10) = %.4f K (target 400 K), T(5) = %.3f K\n', y(end,1), interp1(x, y(:,1), 5));
figure; plot(x, y(:,1)); grid on; xlabel('x (m)'); ylabel('T (K)'); title('Heated rod: shooting method');

function Tend = shootEnd(f, z)
[~, y] = ode45(f, [0 10], [300 z]);
Tend = y(end, 1);
end

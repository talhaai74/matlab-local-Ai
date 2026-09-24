% TOPIC: bvp
% TITLE: Unconfined aquifer water table: shooting method and finite differences (dx = 100 m)
% SOURCE: Chapra Prob. 24.18
% KEYWORDS: groundwater, aquifer, water table, infiltration, hydraulic conductivity, shooting method, finite difference, boundary value problem
% PROBLEM:
% The steady-state water table height h (m) in an unconfined aquifer satisfies K hbar d2h/dx2 + N = 0,
% where K = 1 m/d, N = 0.0001 m/d (infiltration) and hbar = average of the boundary heights. Solve from
% x = 0 to 1000 m with h(0) = 10 m and h(1000) = 5 m using (a) the shooting method and (b) the
% finite-difference method (dx = 100 m).
% CHECK: max(abs(hfd - hex(xfd))) < 1e-9 && abs(hs(end) - 5) < 1e-6
% CODE:
K = 1; N = 0.0001; h0 = 10; hL = 5; L = 1000;
hbar = (h0 + hL)/2;
hex = @(x) -N/(2*K*hbar)*x.^2 + ((hL - h0)/L + N*L/(2*K*hbar))*x + h0;   % analytical
%% (a) shooting (linear ODE: two shots)
f = @(x, y) [y(2); -N/(K*hbar)];
endh = @(z) localEnd(f, L, h0, z);
z1 = 0; z2 = -0.01;
z = z1 + (z2 - z1)*(hL - endh(z1))/(endh(z2) - endh(z1));
[xs, Y] = ode45(f, linspace(0, L, 11), [h0 z]);
hs = Y(:,1);
%% (b) finite differences
dx = 100; n = L/dx - 1;
xfd = (0:dx:L)';
A = diag(-2*ones(n,1)) + diag(ones(n-1,1), 1) + diag(ones(n-1,1), -1);
b = -N/(K*hbar)*dx^2*ones(n, 1);
b(1) = b(1) - h0; b(n) = b(n) - hL;
hfd = [h0; A\b; hL];
fprintf('%8s %10s %10s %10s\n', 'x (m)', 'shooting', 'FD', 'exact');
fprintf('%8g %10.4f %10.4f %10.4f\n', [xfd hs hfd hex(xfd)]');
figure; plot(xs, hs, 'o', xfd, hfd, 's', xfd, hex(xfd), 'k-'); grid on;
xlabel('x (m)'); ylabel('h (m)'); legend('shooting', 'finite difference', 'analytical');

function hend = localEnd(f, L, h0, z)
[~, y] = ode45(f, [0 L], [h0 z]);
hend = y(end, 1);
end

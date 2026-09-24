% TOPIC: ode
% TITLE: Predator-prey (Lotka-Volterra) system with ode45: time series and phase plane
% SOURCE: CE206 slides 06 pages 14-15 (predprey)
% KEYWORDS: predator-prey, lotka-volterra, system of odes, ode45, phase plane, time series, y1, y2
% PROBLEM:
% Solve dy1/dt = 1.2 y1 - 0.6 y1 y2, dy2/dt = -0.8 y2 + 0.3 y1 y2 with y1(0) = 2 and y2(0) = 1 for
% 20 seconds using ode45. Plot the time series (figure 1) and the phase plane y2 versus y1 (figure 2).
% CHECK: abs(y(end,1) - Y45(end,1)) < 1e-9 && size(y, 2) == 2
% CODE:
predprey = @(t, y) [1.2*y(1) - 0.6*y(1)*y(2);
                   -0.8*y(2) + 0.3*y(1)*y(2)];
tspan = [0 20];
y0 = [2; 1];
[t, y] = ode45(predprey, tspan, y0);
[~, Y45] = ode45(predprey, tspan, y0);
fprintf('ode45 used %d time points; y(20) = [%.4f, %.4f]\n', numel(t), y(end,1), y(end,2));
fprintf('Check with RK4 (h = 0.01): y(20) = %s\n', mat2str(round(1e4*localRK4(predprey, 20, y0))/1e4));
figure(1); plot(t, y(:,1), 'b-', t, y(:,2), 'r--'); grid on; xlabel('t (s)'); ylabel('population');
legend('y_1 prey', 'y_2 predator'); title('Predator-prey time series');
figure(2); plot(y(:,1), y(:,2)); grid on; xlabel('y_1'); ylabel('y_2'); title('Phase plane');

function yend = localRK4(f, tf, y0)
[~, Y] = ode_rk4(f, [0 tf], y0, 0.01);
yend = Y(end,:);
end

% TOPIC: ode
% TITLE: Damped spring-mass system for underdamped, critically damped and overdamped cases (ode45)
% SOURCE: Chapra Prob. 22.15
% KEYWORDS: damped, spring-mass, damping coefficient, underdamped, critically damped, overdamped, second-order ode, ode45, displacement
% PROBLEM:
% The motion of a damped spring-mass system is m x'' + c x' + k x = 0 with m = 20 kg and k = 20 N/m.
% The damping coefficient c takes the values 5 (underdamped), 40 (critically damped) and 200
% (overdamped). The initial velocity is zero and the initial displacement is x = 1 m. Solve over
% 0 <= t <= 15 s and plot the displacement versus time for the three cases on the same plot.
% CHECK: abs(ccrit - 40) < 1e-12 && abs(xend(2) - (1 + 15)*exp(-15)) < 1e-4
% CODE:
m = 20; k = 20; cvals = [5 40 200];
ccrit = 2*sqrt(k*m);
fprintf('Critical damping c = 2 sqrt(k m) = %g N s/m\n', ccrit);
t = linspace(0, 15, 301);
X = zeros(numel(t), 3); xend = zeros(1, 3);
for i = 1:3
    c = cvals(i);
    f = @(tt, y) [y(2); -(c*y(2) + k*y(1))/m];
    [~, Y] = ode45(f, t, [1; 0], odeset('RelTol', 1e-8, 'AbsTol', 1e-10));
    X(:,i) = Y(:,1);
    xend(i) = Y(end,1);
    fprintf('c = %3g: x(15) = %.6f m\n', c, xend(i));
end
figure; plot(t, X(:,1), 'b-', t, X(:,2), 'r--', t, X(:,3), 'k-.', 'LineWidth', 1.3); grid on;
xlabel('t (s)'); ylabel('x (m)'); legend('c = 5 (under)', 'c = 40 (critical)', 'c = 200 (over)');

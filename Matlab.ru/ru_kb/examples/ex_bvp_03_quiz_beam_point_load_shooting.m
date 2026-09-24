% TOPIC: bvp
% TITLE: Quiz: simply supported beam with a mid-span point load - shooting method up to mid-span vs analytical
% SOURCE: CE206 Final Quiz (18 batch) Set A, Q4
% KEYWORDS: shooting method, concentrated load, point load, mid span, simply supported beam, elastic curve, gpa, cm^4, student id, analytical solution, quiz
% PROBLEM:
% The elastic curve of a simply supported beam with a concentrated load P at mid span is
% EI d2y/dx2 = Px/2 (0 <= x <= L/2) with y(0) = y(L) = 0 and y(L/2) = PL^3/(48EI) (deflection taken
% positive downward, so the curvature is -Px/(2EI) in this sign convention). Solve for the deflection up
% to mid span using the shooting method and plot it with the analytical solution
% y = Px/(12EI) (3L^2/4 - x^2) using different line styles and legends.
% E = (100 + last three digits of your student ID) GPa, I = 30,000 cm^4, L = 5 m, P = 50 kN.
% CHECK: abs(za - P*L^2/(16*E*I)) < 1e-9 && maxdiff < 1e-8
% CODE:
X = 32;                          % last three digits of the student ID (change this)
E = (100 + X)*1e9;               % Pa
I = 30000e-8;                    % cm^4 -> m^4
L = 5; P = 50e3;                 % m, N
f = @(x, y) [y(2); -P*x/(2*E*I)];
target = P*L^3/(48*E*I);         % y(L/2)
opts = odeset('RelTol', 1e-10, 'AbsTol', 1e-14);
res = @(z) endValue(f, L/2, z, opts) - target;
za = fzero(res, 0);
[x, Y] = ode45(f, linspace(0, L/2, 51), [0 za], opts);
yan = P*x/(12*E*I).*(3*L^2/4 - x.^2);
maxdiff = max(abs(Y(:,1) - yan));
fprintf('E = %g GPa, slope at the support y''(0) = %.6e, y(L/2) = %.6e m (target %.6e m)\n', E/1e9, za, Y(end,1), target);
fprintf('Maximum difference from the analytical solution = %.2e m\n', maxdiff);
figure; plot(x, Y(:,1), 'r--', x, yan, 'b:', 'LineWidth', 1.5); grid on;
xlabel('Distance x (m)'); ylabel('Deflection y (m)'); legend('Numerical result (shooting)', 'Analytical solution');
title('Elastic curve for a simply supported beam');

function yend = endValue(f, xe, z, opts)
[~, y] = ode45(f, [0 xe], [0 z], opts);
yend = y(end, 1);
end

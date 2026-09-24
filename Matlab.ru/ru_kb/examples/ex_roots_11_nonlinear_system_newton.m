% TOPIC: roots
% TITLE: System of nonlinear equations by Newton-Raphson (Jacobian)
% SOURCE: Chapra Example 6.12 (Sec. 6.6)
% KEYWORDS: system of nonlinear equations, simultaneous nonlinear, newton-raphson for systems, jacobian, fsolve alternative
% PROBLEM:
% Use the multiple-equation Newton-Raphson method to determine the roots of
% u(x,y) = x^2 + xy - 10 = 0 and v(x,y) = y + 3xy^2 - 57 = 0, starting from x = 1.5, y = 3.5.
% CHECK: norm(sol - [2; 3]) < 1e-6
% CODE:
F = @(z) [z(1)^2 + z(1)*z(2) - 10;
          z(2) + 3*z(1)*z(2)^2 - 57];
J = @(z) [2*z(1) + z(2),   z(1);
          3*z(2)^2,        1 + 6*z(1)*z(2)];
fprintf('u = x^2 + xy - 10,  v = y + 3xy^2 - 57, start (1.5, 3.5)\n');
[sol, Fval, ea, iter, tab] = root_newtonsys(F, [1.5; 3.5], J, 1e-8, 50);
fprintf('%5s %14s %14s\n', 'iter', 'ea (%)', '||F||');
fprintf('%5d %14.6g %14.6g\n', tab');
fprintf('x = %.6f, y = %.6f after %d iterations, residual norm = %.2e\n', sol(1), sol(2), iter, norm(Fval));

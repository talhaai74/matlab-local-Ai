% TOPIC: linear
% TITLE: Gauss-Seidel iteration (with and without relaxation) and Jacobi
% SOURCE: Chapra Example 12.1
% KEYWORDS: gauss-seidel, iterative method, jacobi, relaxation, diagonally dominant, convergence, es
% PROBLEM:
% Use the Gauss-Seidel method to solve 3x1 - 0.1x2 - 0.2x3 = 7.85, 0.1x1 + 7x2 - 0.3x3 = -19.3,
% 0.3x1 - 0.2x2 + 10x3 = 71.4 until the approximate error is below 0.001%. Compare with Jacobi.
% CHECK: norm(x - [3; -2.5; 7]) < 1e-4
% CODE:
A = [3 -0.1 -0.2; 0.1 7 -0.3; 0.3 -0.2 10];
b = [7.85; -19.3; 71.4];
fprintf('Diagonally dominant: %d (guarantees convergence)\n', all(2*abs(diag(A)) > sum(abs(A), 2)));
[x, ea, iter] = lin_gaussseidel(A, b, 0.001, 100);
fprintf('Gauss-Seidel: x = %s after %d iterations (ea = %.2e %%)\n', mat2str(x', 7), iter, ea);
[xj, eaj, iterj] = lin_jacobi(A, b, 0.001, 100);
fprintf('Jacobi:       x = %s after %d iterations (ea = %.2e %%)\n', mat2str(xj', 7), iterj, eaj);
fprintf('Exact (A\\b): %s\n', mat2str((A\b)', 7));

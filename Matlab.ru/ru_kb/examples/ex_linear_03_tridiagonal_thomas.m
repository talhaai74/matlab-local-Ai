% TOPIC: linear
% TITLE: Tridiagonal system by the Thomas algorithm (Tridiag)
% SOURCE: CE206 slides 03 pages 5-6; Chapra Prob. 9.8
% KEYWORDS: tridiagonal, thomas algorithm, banded system, subdiagonal, superdiagonal, tridiag
% PROBLEM:
% Solve the tridiagonal system
% [0.8 -0.4 0; -0.4 0.8 -0.4; 0 -0.4 0.8] {x1; x2; x3} = {41; 25; 105}
% with the Thomas algorithm and check the result.
% CHECK: norm(x(:) - [173.75; 245; 253.75]) < 1e-8
% CODE:
e = [0 -0.4 -0.4];      % subdiagonal (e(1) unused)
f = [0.8 0.8 0.8];      % main diagonal
g = [-0.4 -0.4 0];      % superdiagonal (g(n) unused)
r = [41 25 105];        % right-hand side
x = lin_tridiag(e, f, g, r);
fprintf('x1 = %.4f, x2 = %.4f, x3 = %.4f\n', x);
A = diag(f) + diag(e(2:end), -1) + diag(g(1:end-1), 1);
fprintf('Check with backslash: %s, residual = %.2e\n', mat2str((A\r(:))', 6), norm(A*x(:) - r(:)));

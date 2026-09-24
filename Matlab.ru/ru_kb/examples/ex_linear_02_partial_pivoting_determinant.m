% TOPIC: linear
% TITLE: Gauss elimination with partial pivoting and the determinant from the diagonal
% SOURCE: CE206 slides 03 page 4; Chapra Prob. 9.7
% KEYWORDS: partial pivoting, gauss elimination with partial pivoting, row swap, determinant, diagonal elements, pivot, display matrix after each operation
% PROBLEM:
% Given 2x1 - 6x2 - x3 = -38, -3x1 - x2 + 7x3 = -34, -8x1 + x2 - 2x3 = -20,
% (a) solve by Gauss elimination with partial pivoting, displaying the matrix after each operation;
% as part of the computation use the diagonal elements to calculate the determinant.
% (b) Substitute your results into the original equations to check your answers.
% CHECK: norm(x - [4; 8; -2]) < 1e-10
% CHECK: abs(D - det(A)) < 1e-8
% CODE:
A = [2 -6 -1; -3 -1 7; -8 1 -2];
b = [-38; -34; -20];
fprintf('Solving A*x = b with partial pivoting (matrix shown after each operation):\n');
[x, D] = lin_gausspivot(A, b, true);   % prints each row swap and elimination step
fprintf('x1 = %.4f, x2 = %.4f, x3 = %.4f\n', x);
fprintf('Determinant = (-1)^(row swaps) * product of the pivots = %.4f (det(A) = %.4f)\n', D, det(A));
fprintf('Check: A*x - b = %s\n', mat2str((A*x - b)', 4));

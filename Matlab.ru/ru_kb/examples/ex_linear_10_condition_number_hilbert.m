% TOPIC: linear
% TITLE: Matrix norms and condition number of the (normalized) Hilbert matrix
% SOURCE: CE206 slides 03 pages 17-18; Chapra Example 11.2
% KEYWORDS: condition number, cond, matrix norm, row-sum norm, column-sum norm, frobenius norm, spectral norm, ill-conditioned, hilbert matrix, digits of precision
% PROBLEM:
% For A = [1 1/2 1/3; 1/2 1/3 1/4; 1/3 1/4 1/5] compute the column-sum, row-sum, Frobenius and
% spectral norms and the condition numbers. Then scale each row so its largest element is 1 and
% compute the row-sum condition number. If the coefficients are known to 7 digits, how many digits
% of the solution are reliable?
% CHECK: abs(condS - 451.2) < 0.1
% CHECK: abs(cond(A) - 524.0568) < 1e-3
% CODE:
A = [1 1/2 1/3; 1/2 1/3 1/4; 1/3 1/4 1/5];
fprintf('norm(A,1) = %.4f  norm(A,inf) = %.4f  norm(A,''fro'') = %.4f  norm(A,2) = %.4f\n', ...
    norm(A,1), norm(A,inf), norm(A,'fro'), norm(A,2));
fprintf('cond(A,1) = %.2f  cond(A,inf) = %.2f  cond(A,2) = %.2f\n', cond(A,1), cond(A,inf), cond(A));
As = A./max(abs(A), [], 2);              % each row divided by its largest element
condS = norm(As, inf)*norm(inv(As), inf);
fprintf('Scaled matrix:\n'); disp(As);
fprintf('Row-sum condition number of the scaled matrix = %.1f\n', condS);
t = 7;
fprintf('Reliable digits of the solution ~ t - log10(cond) = %d - %.2f = %.2f\n', t, log10(condS), t - log10(condS));

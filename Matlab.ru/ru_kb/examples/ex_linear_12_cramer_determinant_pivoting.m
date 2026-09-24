% TOPIC: linear
% TITLE: Determinant, Cramer's rule and Gauss elimination with partial pivoting (3x3)
% SOURCE: Chapra Prob. 9.4
% KEYWORDS: determinant, cramer's rule, cramer, gauss elimination with partial pivoting, verify the determinant, substitute back
% PROBLEM:
% Given 2x2 + 5x3 = 1, 2x1 + x2 + x3 = 1, 3x1 + x2 = 2:
% (a) compute the determinant; (b) use Cramer's rule to solve for the x's; (c) use Gauss elimination
% with partial pivoting, calculating the determinant as part of the computation to verify (a);
% (d) substitute your results back into the original equations to check your solution.
% CHECK: abs(detA - det([0 2 5; 2 1 1; 3 1 0])) < 1e-12 && norm(xc - xg) < 1e-12
% CODE:
A = [0 2 5; 2 1 1; 3 1 0];
b = [1; 1; 2];
detA = det(A);
fprintf('(a) det(A) = %.4f\n', detA);
xc = zeros(3, 1);
for k = 1:3
    Ak = A; Ak(:,k) = b;                 % replace column k by b
    xc(k) = det(Ak)/detA;
    fprintf('(b) x%d = det(A%d)/det(A) = %.4f/%.4f = %.6f\n', k, k, det(Ak), detA, xc(k));
end
[xg, D] = lin_gausspivot(A, b);
fprintf('(c) partial pivoting: x = %s, determinant from the pivots = %.4f\n', mat2str(xg', 6), D);
fprintf('(d) A*x = %s  (b = %s)\n', mat2str((A*xg)', 6), mat2str(b', 6));

% TOPIC: linear
% TITLE: Naive Gauss elimination showing every step, with back substitution and check
% SOURCE: CE206 slides 03 pages 2-3 (GaussNaive); Chapra Prob. 9.6
% KEYWORDS: naive gauss elimination, forward elimination, back substitution, augmented matrix, show all steps, gaussnaive
% PROBLEM:
% Given the equations 10x1 + 2x2 - x3 = 27, -3x1 - 5x2 + 2x3 = -61.5, x1 + x2 + 6x3 = -21.5,
% (a) solve by naive Gauss elimination, showing all steps of the computation, and
% (b) substitute your results into the original equations to check your answers.
% CHECK: norm(x - [0.152482; 10.092199; -5.290780]) < 1e-5 && norm(A*x - b) < 1e-10
% CODE:
A = [10 2 -1; -3 -5 2; 1 1 6];
b = [27; -61.5; -21.5];
n = size(A, 1);
Aug = [A b];
fprintf('Augmented matrix [A | b]:\n'); disp(Aug);
%% (a) forward elimination
for k = 1:n-1
    for i = k+1:n
        factor = Aug(i,k)/Aug(k,k);
        Aug(i,k:n+1) = Aug(i,k:n+1) - factor*Aug(k,k:n+1);
        fprintf('Row %d = Row %d - (%.4f) x Row %d:\n', i, i, factor, k);
        disp(Aug);
    end
end
% back substitution
x = zeros(n, 1);
x(n) = Aug(n,n+1)/Aug(n,n);
for i = n-1:-1:1
    x(i) = (Aug(i,n+1) - Aug(i,i+1:n)*x(i+1:n))/Aug(i,i);
end
fprintf('Solution: x1 = %.4f, x2 = %.4f, x3 = %.4f\n', x);
%% (b) check
fprintf('A*x = %s, b = %s, residual norm = %.2e\n', mat2str((A*x)', 6), mat2str(b', 6), norm(A*x - b));
fprintf('Same as lin_gaussnaive: %s and A\\b: %s\n', mat2str(lin_gaussnaive(A, b)', 6), mat2str((A\b)', 6));

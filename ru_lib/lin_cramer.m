function x = lin_cramer(A, b)
%LIN_CRAMER  Solve A*x=b by Cramer's rule (ratio of determinants).
%   x = lin_cramer(A, b)
%   A   square coefficient matrix (n by n)
%   b   right-hand side vector (n by 1, a row vector is accepted too)
%   x   solution column vector (n by 1)
%   x(i) = det(A with column i replaced by b) / det(A). Educational only:
%   cost grows like n!, so use lin_gausspivot or lin_lu when n > about 4.
%   Call without output to print the solution.
%   Example: x = lin_cramer([2 1; 5 7], [11; 13])

[n, ncol] = size(A);
if n ~= ncol
    error('ru_lib:lin_cramer:notSquare', ...
        'lin_cramer: A must be square (got %dx%d).', n, ncol);
end
if isrow(b), b = b(:); end
if numel(b) ~= n
    error('ru_lib:lin_cramer:sizeMismatch', ...
        'lin_cramer: b must have %d entries to match A (got %d).', n, numel(b));
end
detA = det(A);
if detA == 0
    error('ru_lib:lin_cramer:singular', ...
        'lin_cramer: det(A) = 0, the system has no unique solution.');
end
x = zeros(n,1);
for i = 1:n
    Ai = A;
    Ai(:,i) = b;
    x(i) = det(Ai)/detA;
end
if nargout == 0
    fprintf('lin_cramer solution:\n');
    for i = 1:n
        fprintf('  x(%d) = %.6g\n', i, x(i));
    end
end
end

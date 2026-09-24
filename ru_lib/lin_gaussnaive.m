function x = lin_gaussnaive(A, b)
%LIN_GAUSSNAIVE  Solve A*x = b by naive Gauss elimination (no pivoting).
%   x = lin_gaussnaive(A, b)
%   A   square coefficient matrix (n by n)
%   b   right-hand side vector (n by 1, a row vector is accepted too)
%   x   solution column vector (n by 1)
%   No pivoting is done: errors out if a zero pivot is met (use
%   lin_gausspivot when a pivot may be zero or small).
%   Call without output to print the solution.
%   Example: x = lin_gaussnaive([3 2; 1 -1], [7; -1])

[n, ncol] = size(A);
if n ~= ncol
    error('ru_lib:lin_gaussnaive:notSquare', ...
        'lin_gaussnaive: A must be square (got %dx%d).', n, ncol);
end
if isrow(b), b = b(:); end
if numel(b) ~= n
    error('ru_lib:lin_gaussnaive:sizeMismatch', ...
        'lin_gaussnaive: b must have %d entries to match A (got %d).', n, numel(b));
end
nb = n+1;
Aug = [A b];
for k = 1:n-1
    if Aug(k,k) == 0
        error('ru_lib:lin_gaussnaive:zeroPivot', ...
            'lin_gaussnaive: zero pivot at row %d; use lin_gausspivot instead.', k);
    end
    for i = k+1:n
        factor = Aug(i,k)/Aug(k,k);
        Aug(i,k:nb) = Aug(i,k:nb) - factor*Aug(k,k:nb);
    end
end
if Aug(n,n) == 0
    error('ru_lib:lin_gaussnaive:zeroPivot', ...
        'lin_gaussnaive: zero pivot at row %d; use lin_gausspivot instead.', n);
end
x = zeros(n,1);
x(n) = Aug(n,nb)/Aug(n,n);
for i = n-1:-1:1
    x(i) = (Aug(i,nb) - Aug(i,i+1:n)*x(i+1:n))/Aug(i,i);
end
if nargout == 0
    fprintf('lin_gaussnaive solution:\n');
    for i = 1:n
        fprintf('  x(%d) = %.6g\n', i, x(i));
    end
end
end

function x = lin_gaussjordan(A, b)
%LIN_GAUSSJORDAN  Solve A*x = b by Gauss-Jordan elimination.
%   x = lin_gaussjordan(A, b)
%   A   square coefficient matrix (n by n)
%   b   right-hand side vector (n by 1, a row vector is accepted too)
%   x   solution column vector (n by 1)
%   Reduces [A|b] all the way to [I|x] (no separate back-substitution step).
%   Uses partial pivoting internally, so a zero diagonal entry is not fatal.
%   Call without output to print the solution.
%   Example: x = lin_gaussjordan([2 1 -1; -3 -1 2; -2 1 2], [8; -11; -3])

[n, ncol] = size(A);
if n ~= ncol
    error('ru_lib:lin_gaussjordan:notSquare', ...
        'lin_gaussjordan: A must be square (got %dx%d).', n, ncol);
end
if isrow(b), b = b(:); end
if numel(b) ~= n
    error('ru_lib:lin_gaussjordan:sizeMismatch', ...
        'lin_gaussjordan: b must have %d entries to match A (got %d).', n, numel(b));
end
nb = n+1;
Aug = [A b];
for k = 1:n
    [piv, p] = max(abs(Aug(k:n,k)));
    p = p+k-1;
    if piv == 0
        error('ru_lib:lin_gaussjordan:singular', ...
            'lin_gaussjordan: matrix is singular (column %d is all zero below row %d).', k, k);
    end
    if p ~= k
        Aug([k p],:) = Aug([p k],:);
    end
    Aug(k,:) = Aug(k,:)/Aug(k,k);
    for i = 1:n
        if i ~= k
            Aug(i,:) = Aug(i,:) - Aug(i,k)*Aug(k,:);
        end
    end
end
x = Aug(:,nb);
if nargout == 0
    fprintf('lin_gaussjordan solution:\n');
    for i = 1:n
        fprintf('  x(%d) = %.6g\n', i, x(i));
    end
end
end

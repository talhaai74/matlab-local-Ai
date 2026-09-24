function [x, D] = lin_gausspivot(A, b, show)
%LIN_GAUSSPIVOT  Gauss elimination with partial pivoting to solve A*x = b.
%   [x, D] = lin_gausspivot(A, b, show)
%   A      square coefficient matrix (n by n)
%   b      right-hand side vector (n by 1, a row vector is accepted too)
%   show   true prints the augmented matrix after every row swap and every
%          elimination step (default false)
%   x      solution column vector (n by 1)
%   D      determinant of A = (-1)^(row swaps) * product of the pivots
%   At step k, swaps in the row with the largest abs(A(i,k)) as pivot, so a
%   zero or small pivot on the diagonal does not stall or blow up the method.
%   Call without output to print the solution.
%   Example: x = lin_gausspivot([0 2 1; 1 1 1; 2 -1 1], [7; 6; 3], true)

if nargin < 3 || isempty(show), show = false; end
[n, ncol] = size(A);
if n ~= ncol
    error('ru_lib:lin_gausspivot:notSquare', ...
        'lin_gausspivot: A must be square (got %dx%d).', n, ncol);
end
if isrow(b), b = b(:); end
if numel(b) ~= n
    error('ru_lib:lin_gausspivot:sizeMismatch', ...
        'lin_gausspivot: b must have %d entries to match A (got %d).', n, numel(b));
end
nb = n+1;
Aug = [A b];
nswap = 0;
for k = 1:n-1
    [piv, p] = max(abs(Aug(k:n,k)));
    p = p+k-1;
    if piv == 0
        error('ru_lib:lin_gausspivot:singular', ...
            'lin_gausspivot: matrix is singular (column %d is all zero below the diagonal).', k);
    end
    if p ~= k
        Aug([k p],:) = Aug([p k],:);
        nswap = nswap + 1;
        if show
            fprintf('Swap row %d and row %d:\n', k, p);
            disp(Aug);
        end
    end
    for i = k+1:n
        factor = Aug(i,k)/Aug(k,k);
        Aug(i,k:nb) = Aug(i,k:nb) - factor*Aug(k,k:nb);
    end
    if show
        fprintf('After elimination step %d:\n', k);
        disp(Aug);
    end
end
if Aug(n,n) == 0
    error('ru_lib:lin_gausspivot:singular', ...
        'lin_gausspivot: matrix is singular (zero pivot at row %d).', n);
end
D = (-1)^nswap * prod(diag(Aug(:,1:n)));
x = zeros(n,1);
x(n) = Aug(n,nb)/Aug(n,n);
for i = n-1:-1:1
    x(i) = (Aug(i,nb) - Aug(i,i+1:n)*x(i+1:n))/Aug(i,i);
end
if nargout == 0
    fprintf('lin_gausspivot solution:\n');
    for i = 1:n
        fprintf('  x(%d) = %.6g\n', i, x(i));
    end
    fprintf('  determinant = %.6g\n', D);
end
end

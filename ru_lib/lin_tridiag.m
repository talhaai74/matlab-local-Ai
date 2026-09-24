function x = lin_tridiag(e, f, g, r)
%LIN_TRIDIAG  Solve a tridiagonal system by the Thomas algorithm.
%   x = lin_tridiag(e, f, g, r)
%   e   subdiagonal, length n, e(1) is unused (Chapra convention)
%   f   main diagonal, length n
%   g   superdiagonal, length n, g(n) is unused
%   r   right-hand side, length n
%   x   solution column vector (n by 1)
%   Forward elimination then back substitution touching only the 3 bands;
%   far cheaper than lin_gaussnaive/lin_gausspivot for this special shape.
%   Call without output to print the solution.
%   Example: x = lin_tridiag([0 -1 -1], [2 2 2], [-1 -1 0], [1; 0; 1])

e = e(:); f = f(:); g = g(:); r = r(:);
n = length(f);
if length(e) ~= n || length(g) ~= n || length(r) ~= n
    error('ru_lib:lin_tridiag:sizeMismatch', ...
        'lin_tridiag: e, f, g and r must all have length %d (the length of f).', n);
end
for k = 2:n
    if f(k-1) == 0
        error('ru_lib:lin_tridiag:zeroPivot', ...
            'lin_tridiag: zero pivot f(%d); reorder equations or use lin_gausspivot.', k-1);
    end
    factor = e(k)/f(k-1);
    f(k) = f(k) - factor*g(k-1);
    r(k) = r(k) - factor*r(k-1);
end
if f(n) == 0
    error('ru_lib:lin_tridiag:zeroPivot', ...
        'lin_tridiag: zero pivot f(%d); reorder equations or use lin_gausspivot.', n);
end
x = zeros(n,1);
x(n) = r(n)/f(n);
for k = n-1:-1:1
    x(k) = (r(k) - g(k)*x(k+1))/f(k);
end
if nargout == 0
    fprintf('lin_tridiag solution:\n');
    for k = 1:n
        fprintf('  x(%d) = %.6g\n', k, x(k));
    end
end
end

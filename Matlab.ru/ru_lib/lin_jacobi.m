function [x, ea, iter] = lin_jacobi(A, b, es, maxit)
%LIN_JACOBI  Solve A*x=b iteratively by the Jacobi method.
%   [x, ea, iter] = lin_jacobi(A, b, es, maxit)
%   A      square coefficient matrix (n by n)
%   b      right-hand side vector (n by 1, a row vector is accepted too)
%   es     stop when the worst relative error over all x(i), PERCENT, is
%          <= es (default 1e-4); es = 0 runs exactly maxit iterations
%   maxit  maximum iterations (default 50)
%   x      solution column vector; ea = worst final error (%); iter used
%   Starts from x = zeros(n,1); unlike lin_gaussseidel, every x(i) is
%   updated from the PREVIOUS iteration's values only (no lambda option).
%   Warns if A is not diagonally dominant (convergence not guaranteed).
%   Call without output to print the iteration table.
%   Example: x = lin_jacobi([3 -0.1 -0.2; 0.1 7 -0.3; 0.3 -0.2 10], [7.85; -19.3; 71.4])

if nargin < 3 || isempty(es), es = 1e-4; end
if nargin < 4 || isempty(maxit), maxit = 50; end
[n, ncol] = size(A);
if n ~= ncol
    error('ru_lib:lin_jacobi:notSquare', ...
        'lin_jacobi: A must be square (got %dx%d).', n, ncol);
end
if isrow(b), b = b(:); end
if numel(b) ~= n
    error('ru_lib:lin_jacobi:sizeMismatch', ...
        'lin_jacobi: b must have %d entries to match A (got %d).', n, numel(b));
end
if any(diag(A) == 0)
    error('ru_lib:lin_jacobi:zeroDiag', ...
        'lin_jacobi: A has a zero on the diagonal; reorder the equations.');
end
offdiag = sum(abs(A),2) - abs(diag(A));
if any(abs(diag(A)) < offdiag)
    warning('ru_lib:lin_jacobi:notDiagDominant', ...
        'lin_jacobi: A is not diagonally dominant; iteration may not converge.');
end
x = zeros(n,1);
iter = 0;
ea = zeros(n,1);
hist = [];
while true
    xold = x;
    for i = 1:n
        s = A(i,:)*xold - A(i,i)*xold(i);
        x(i) = (b(i) - s)/A(i,i);
        if x(i) ~= 0
            ea(i) = abs((x(i)-xold(i))/x(i))*100;
        else
            ea(i) = 0;
        end
    end
    iter = iter+1;
    hist = [hist; iter x' max(ea)]; %#ok<AGROW>
    if max(ea) <= es || iter >= maxit
        break
    end
end
ea = max(ea);
if nargout == 0
    fprintf('lin_jacobi iterations (iter, x..., max ea %%):\n');
    disp(hist);
    fprintf('lin_jacobi solution (iter = %d, ea = %.6g%%):\n', iter, ea);
    for i = 1:n
        fprintf('  x(%d) = %.6g\n', i, x(i));
    end
end
end

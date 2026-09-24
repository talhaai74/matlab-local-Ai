function [x, ea, iter] = lin_gaussseidel(A, b, es, maxit, lambda)
%LIN_GAUSSSEIDEL  Solve A*x=b iteratively by Gauss-Seidel with relaxation.
%   [x, ea, iter] = lin_gaussseidel(A, b, es, maxit, lambda)
%   A       square coefficient matrix (n by n)
%   b       right-hand side vector (n by 1, a row vector is accepted too)
%   es      stop when the worst relative error over all x(i), PERCENT, is
%           <= es (default 1e-4); es = 0 runs exactly maxit iterations
%   maxit   maximum iterations (default 50)
%   lambda  relaxation factor (default 1; 1<lambda<2 = over-relaxation)
%   x       solution column vector; ea = worst final error (%); iter used
%   Starts from x = zeros(n,1). Warns (does not stop) if A is not
%   diagonally dominant, since convergence is then not guaranteed.
%   Call without output to print the iteration table.
%   Example: x = lin_gaussseidel([3 -0.1 -0.2; 0.1 7 -0.3; 0.3 -0.2 10], [7.85; -19.3; 71.4])

if nargin < 3 || isempty(es), es = 1e-4; end
if nargin < 4 || isempty(maxit), maxit = 50; end
if nargin < 5 || isempty(lambda), lambda = 1; end
[n, ncol] = size(A);
if n ~= ncol
    error('ru_lib:lin_gaussseidel:notSquare', ...
        'lin_gaussseidel: A must be square (got %dx%d).', n, ncol);
end
if isrow(b), b = b(:); end
if numel(b) ~= n
    error('ru_lib:lin_gaussseidel:sizeMismatch', ...
        'lin_gaussseidel: b must have %d entries to match A (got %d).', n, numel(b));
end
if any(diag(A) == 0)
    error('ru_lib:lin_gaussseidel:zeroDiag', ...
        'lin_gaussseidel: A has a zero on the diagonal; reorder the equations.');
end
offdiag = sum(abs(A),2) - abs(diag(A));
if any(abs(diag(A)) < offdiag)
    warning('ru_lib:lin_gaussseidel:notDiagDominant', ...
        'lin_gaussseidel: A is not diagonally dominant; iteration may not converge.');
end
x = zeros(n,1);
iter = 0;
ea = zeros(n,1);
hist = [];
while true
    xold = x;
    for i = 1:n
        s = A(i,:)*x - A(i,i)*x(i);
        xnew = (b(i) - s)/A(i,i);
        x(i) = lambda*xnew + (1-lambda)*xold(i);
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
    fprintf('lin_gaussseidel iterations (iter, x..., max ea %%):\n');
    disp(hist);
    fprintf('lin_gaussseidel solution (iter = %d, ea = %.6g%%):\n', iter, ea);
    for i = 1:n
        fprintf('  x(%d) = %.6g\n', i, x(i));
    end
end
end

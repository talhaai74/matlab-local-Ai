function U = lin_cholesky(A)
%LIN_CHOLESKY  Cholesky factorization A = U'*U (U upper triangular).
%   U = lin_cholesky(A)
%   A   symmetric positive-definite matrix (n by n)
%   U   upper-triangular factor (n by n) with A = U'*U
%   Requires A symmetric positive definite; errors out (naming the row) as
%   soon as a diagonal term would need sqrt of a non-positive number.
%   About half the cost of lin_lu because only the upper triangle is used.
%   Call without output to print U.
%   Example: U = lin_cholesky([4 -2; -2 5]);  shouldBeA = U'*U

[n, ncol] = size(A);
if n ~= ncol
    error('ru_lib:lin_cholesky:notSquare', ...
        'lin_cholesky: A must be square (got %dx%d).', n, ncol);
end
if norm(A-A','fro') > 1e-8*max(1,norm(A,'fro'))
    error('ru_lib:lin_cholesky:notSymmetric', ...
        'lin_cholesky: A must be symmetric; use lin_lu for a general matrix.');
end
U = zeros(n);
for j = 1:n
    s = A(j,j) - U(1:j-1,j)'*U(1:j-1,j);
    if s <= 0
        error('ru_lib:lin_cholesky:notPosDef', ...
            'lin_cholesky: A is not positive definite (failed at row %d).', j);
    end
    U(j,j) = sqrt(s);
    for k = j+1:n
        U(j,k) = (A(j,k) - U(1:j-1,j)'*U(1:j-1,k))/U(j,j);
    end
end
if nargout == 0
    fprintf('lin_cholesky: U =\n'); disp(U);
end
end

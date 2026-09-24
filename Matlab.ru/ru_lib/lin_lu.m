function [L, U, P] = lin_lu(A)
%LIN_LU  LU factorization with partial pivoting: P*A = L*U.
%   [L, U, P] = lin_lu(A)
%   A   square coefficient matrix (n by n)
%   L   unit-lower-triangular factor (n by n), diag(L) = 1
%   U   upper-triangular factor (n by n)
%   P   permutation matrix (n by n) so that P*A = L*U
%   Doolittle elimination with partial pivoting (largest |A(i,k)| in column
%   k becomes the pivot), so it stays stable when a diagonal entry is small.
%   Use with lin_lusolve to solve A*x = b, reusing L,U,P for several b.
%   Example: [L,U,P] = lin_lu([4 3; 6 3]);  x = lin_lusolve(L,U,P,[1;0])

[n, ncol] = size(A);
if n ~= ncol
    error('ru_lib:lin_lu:notSquare', ...
        'lin_lu: A must be square (got %dx%d).', n, ncol);
end
U = A;
L = eye(n);
P = eye(n);
for k = 1:n-1
    [piv, p] = max(abs(U(k:n,k)));
    p = p+k-1;
    if piv == 0
        error('ru_lib:lin_lu:singular', ...
            'lin_lu: matrix is singular (column %d is all zero below the diagonal).', k);
    end
    if p ~= k
        U([k p],:) = U([p k],:);
        P([k p],:) = P([p k],:);
        if k > 1
            L([k p],1:k-1) = L([p k],1:k-1);
        end
    end
    for i = k+1:n
        L(i,k) = U(i,k)/U(k,k);
        U(i,k:n) = U(i,k:n) - L(i,k)*U(k,k:n);
    end
end
if nargout == 0
    fprintf('lin_lu: L =\n'); disp(L);
    fprintf('lin_lu: U =\n'); disp(U);
    fprintf('lin_lu: P =\n'); disp(P);
end
end

% TOPIC: linear
% TITLE: LU factorization by naive Gauss elimination and the check L*U = A
% SOURCE: Chapra Prob. 10.3
% KEYWORDS: lu factorization, naive gauss elimination, lower triangular, upper triangular, factor, multiply L and U, doolittle, no pivoting
% PROBLEM:
% Use naive Gauss elimination to factor the following system:
% 10x1 + 2x2 - x3 = 27, -3x1 - 6x2 + 2x3 = -61.5, x1 + x2 + 5x3 = -21.5.
% Then, multiply the resulting [L] and [U] matrices to determine that [A] is produced.
% CHECK: norm(L*U - A) < 1e-12 && abs(U(3,3) - 5.351851851851852) < 1e-12 && abs(L(3,2) + 0.148148148148148) < 1e-12
% CODE:
A = [10 2 -1; -3 -6 2; 1 1 5];
b = [27; -61.5; -21.5];
n = size(A, 1);
L = eye(n);
U = A;
for k = 1:n-1
    for i = k+1:n
        L(i,k) = U(i,k)/U(k,k);
        U(i,:) = U(i,:) - L(i,k)*U(k,:);
    end
end
L
U
LU = L*U
x = U\(L\b)

function x = lin_lusolve(L, U, P, b)
%LIN_LUSOLVE  Solve A*x = b given [L,U,P] = lin_lu(A) (P*A = L*U).
%   x = lin_lusolve(L, U, P, b)
%   L, U, P  factors from lin_lu (P*A = L*U)
%   b        right-hand side, n by 1, or n by m for m different systems
%             with the SAME A (columns solved without re-factoring A)
%   x        solution, same shape as b
%   d = L\(P*b) (forward substitution), then x = U\d (back substitution).
%   Example: [L,U,P] = lin_lu(A); x1 = lin_lusolve(L,U,P,b1);
%            x2 = lin_lusolve(L,U,P,b2);  % same A, no re-factoring

n = size(L,1);
if isvector(b) && numel(b) == n
    b = b(:);
end
if size(b,1) ~= n
    error('ru_lib:lin_lusolve:sizeMismatch', ...
        'lin_lusolve: b must have %d rows to match L,U (got %d).', n, size(b,1));
end
Pb = P*b;
m = size(b,2);
d = zeros(n,m);
for i = 1:n
    d(i,:) = Pb(i,:) - L(i,1:i-1)*d(1:i-1,:);
end
x = zeros(n,m);
x(n,:) = d(n,:)/U(n,n);
for i = n-1:-1:1
    x(i,:) = (d(i,:) - U(i,i+1:n)*x(i+1:n,:))/U(i,i);
end
if nargout == 0
    fprintf('lin_lusolve solution:\n');
    disp(x);
end
end

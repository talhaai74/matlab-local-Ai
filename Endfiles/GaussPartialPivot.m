function x = GaussPartialPivot(A,b)
% input: A = coefficient matrix  b = right hand side vector
% output: x = solution vector
[m,n] = size(A);
if m~=n, error('Matrix A must be square'); end
nb = n+1;
Aug = [A b];

% forward elimination with partial pivoting
for k = 1:n-1

    % Find the largest absolute value below and including the pivot
    [~,p] = max(abs(Aug(k:n,k)));
    p = p + k - 1;

    % Switch rows if necessary
    if p ~= k
        temp = Aug(k,:);
        Aug(k,:) = Aug(p,:);
        Aug(p,:) = temp;
    end

    for i = k+1:n
        factor = Aug(i,k)/Aug(k,k);
        Aug(i,k:nb) = Aug(i,k:nb)-factor*Aug(k,k:nb);
    end
end

% back substitution
x = zeros(n,1);
x(n) = Aug(n,nb)/Aug(n,n);
for i = n-1:-1:1
    x(i) = (Aug(i,nb)-Aug(i,i+1:n)*x(i+1:n))/Aug(i,i);
end

function fdd = interp_divdiff(x, y)
%INTERP_DIVDIFF  Full Newton divided-difference table for data (x,y).
%   fdd = interp_divdiff(x, y)
%   x, y   n distinct data points (x values must not repeat)
%   fdd    n-by-n table; fdd(i,1) = y(i); fdd(i,j) = f[x(i),...,x(i+j-1)]
%          for j >= 2; unused lower-right entries are 0
%   The Newton polynomial coefficients used by interp_newton are b = fdd(1,:).
%   Call without outputs to print the table.
%   Example: fdd = interp_divdiff([1 4 6],[0 1.386294 1.791759])

if nargin < 2
    error('ru_lib:interp_divdiff:nargin', 'INTERP_DIVDIFF: need x and y.');
end
x = x(:)'; y = y(:)';
n = length(x);
if length(y) ~= n
    error('ru_lib:interp_divdiff:size', ...
        'INTERP_DIVDIFF: x and y must have the same length (got %d and %d).', n, length(y));
end
if n < 2
    error('ru_lib:interp_divdiff:npts', 'INTERP_DIVDIFF: need at least 2 points, got %d.', n);
end
if length(unique(x)) ~= n
    error('ru_lib:interp_divdiff:repeated', 'INTERP_DIVDIFF: x values must all be distinct.');
end

fdd = zeros(n,n);
fdd(:,1) = y(:);
for j = 2:n
    for i = 1:n-j+1
        fdd(i,j) = (fdd(i+1,j-1) - fdd(i,j-1))/(x(i+j-1) - x(i));
    end
end

if nargout == 0
    fprintf('INTERP_DIVDIFF: divided-difference table (columns = orders 0..n-1):\n');
    disp(fdd);
end
end

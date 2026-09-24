function s = util_sing(x, a, n)
%UTIL_SING  Macaulay (singularity) bracket <x-a>^n, elementwise over x.
%   s = util_sing(x, a, n)
%   x   evaluation point(s), scalar or vector/matrix
%   a   location of the discontinuity (start of the load term)
%   n   power; n = 0 gives the unit step (x>a); n >= 1 gives (x-a).^n for x>a
%   s   same size as x; s = (x-a).^n where x>a, else s = 0
%   Example: s = util_sing([0 3 6 9], 5, 1)   % s = [0 0 1 4]

if nargin < 3
    error('ru_lib:util_sing:nargin', 'util_sing: need x, a, n.');
end
s = zeros(size(x));
mask = x > a;
s(mask) = (x(mask) - a).^n;
end

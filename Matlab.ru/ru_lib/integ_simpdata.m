function I = integ_simpdata(x, y)
%INTEG_SIMPDATA  Simpson's rules for EQUALLY spaced tabulated data (x, y).
%   I = integ_simpdata(x, y)
%   x, y   data vectors of the same length with constant spacing h
%   Even number of segments: composite Simpson's 1/3 rule.
%   Odd number of segments (>= 3): Simpson's 3/8 rule on the last three
%   segments and 1/3 rule on the rest (Chapra's recommended combination).
%   One segment: trapezoidal rule. For unequal spacing use trapz(x, y).
%   Call without outputs to print I.
%   Example: I = integ_simpdata(0:0.1:0.8, exp(-(0:0.1:0.8)))
x = x(:); y = y(:);
n = numel(x) - 1;
if numel(y) ~= numel(x)
    error('ru_lib:integ_simpdata:size', 'integ_simpdata: x and y must have the same length.');
end
if n < 1
    error('ru_lib:integ_simpdata:size', 'integ_simpdata: need at least two points.');
end
h = diff(x);
if max(abs(h - h(1))) > 1e-9*max(1, abs(h(1)))
    error('ru_lib:integ_simpdata:spacing', ...
        'integ_simpdata: x must be equally spaced; use trapz(x,y) for unequal spacing.');
end
h = h(1);
if n == 1
    I = h/2*(y(1) + y(2));
elseif mod(n, 2) == 0
    I = h/3*(y(1) + 4*sum(y(2:2:n)) + 2*sum(y(3:2:n-1)) + y(n+1));
else
    I = 3*h/8*(y(n-2) + 3*y(n-1) + 3*y(n) + y(n+1));
    m = n - 3;
    if m >= 2
        I = I + h/3*(y(1) + 4*sum(y(2:2:m)) + 2*sum(y(3:2:m-1)) + y(m+1));
    end
end
if nargout == 0
    fprintf('integ_simpdata: %d segments, h = %.6g, I = %.10g\n', n, h, I);
end
end

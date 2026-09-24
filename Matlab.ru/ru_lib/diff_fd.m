function [d1, d2] = diff_fd(f, x, h, scheme, order)
%DIFF_FD  Finite-difference derivatives of a FUNCTION f at a point x.
%   [d1, d2] = diff_fd(f, x, h, scheme, order)
%   f       function handle @(x) ..., or text 'cos(x)'
%   x       point (scalar or vector of points)
%   h       step size
%   scheme  'forward', 'backward' or 'centered' (default 'centered')
%   order   error order: 1 or 2 for forward/backward, 2 or 4 for centered
%           (default 2)
%   d1      first-derivative estimate;  d2  second-derivative estimate
%   Formulas are Chapra Figs. 21.3-21.5, e.g. centered O(h^2):
%     f'  = (f(x+h) - f(x-h))/(2h),   f'' = (f(x+h) - 2f(x) + f(x-h))/h^2
%   For tabulated data use diff_data(x, y).
%   Call without outputs to print both estimates.
%   Example: [d1, d2] = diff_fd(@(x) cos(x), pi/4, pi/12, 'centered', 4)
if nargin < 3
    error('ru_lib:diff_fd:nargin', 'diff_fd: need f, x and h.');
end
if nargin < 4 || isempty(scheme), scheme = 'centered'; end
if nargin < 5 || isempty(order), order = 2; end
f = ru_tofunc(f, {'x'});
F = @(k) f(x + k*h);
switch lower(scheme(1))
    case 'f'
        if order == 1
            d1 = (F(1) - F(0))/h;
            d2 = (F(2) - 2*F(1) + F(0))/h^2;
        elseif order == 2
            d1 = (-F(2) + 4*F(1) - 3*F(0))/(2*h);
            d2 = (-F(3) + 4*F(2) - 5*F(1) + 2*F(0))/h^2;
        else
            error('ru_lib:diff_fd:order', 'diff_fd: forward differences have order 1 or 2.');
        end
    case 'b'
        if order == 1
            d1 = (F(0) - F(-1))/h;
            d2 = (F(0) - 2*F(-1) + F(-2))/h^2;
        elseif order == 2
            d1 = (3*F(0) - 4*F(-1) + F(-2))/(2*h);
            d2 = (2*F(0) - 5*F(-1) + 4*F(-2) - F(-3))/h^2;
        else
            error('ru_lib:diff_fd:order', 'diff_fd: backward differences have order 1 or 2.');
        end
    case 'c'
        if order == 2
            d1 = (F(1) - F(-1))/(2*h);
            d2 = (F(1) - 2*F(0) + F(-1))/h^2;
        elseif order == 4
            d1 = (-F(2) + 8*F(1) - 8*F(-1) + F(-2))/(12*h);
            d2 = (-F(2) + 16*F(1) - 30*F(0) + 16*F(-1) - F(-2))/(12*h^2);
        else
            error('ru_lib:diff_fd:order', 'diff_fd: centered differences have order 2 or 4.');
        end
    otherwise
        error('ru_lib:diff_fd:scheme', 'diff_fd: scheme must be forward, backward or centered.');
end
if nargout == 0
    fprintf('diff_fd (%s, O(h^%d)), h = %.6g:\n', scheme, order, h);
    for k = 1:numel(x)
        fprintf('  x = %.6g:  f''(x) = %.10g   f''''(x) = %.10g\n', x(k), d1(k), d2(k));
    end
end
end

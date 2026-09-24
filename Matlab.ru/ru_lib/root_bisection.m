function [root, fx, ea, iter, hist] = root_bisection(f, xl, xu, es, maxit)
%ROOT_BISECTION  Root of f(x) = 0 by bisection (bracketing method).
%   [root, fx, ea, iter, hist] = root_bisection(f, xl, xu, es, maxit)
%   f      function handle @(x) ..., or text 'x^3 - 10'
%   xl, xu bracket; f(xl) and f(xu) must have opposite signs
%   es     stop when approximate relative error (PERCENT) <= es (default 1e-4)
%   maxit  maximum iterations (default 50); es = 0 runs exactly maxit iterations
%   root   root estimate; fx = f(root); ea = final error (%); iter = iterations used
%   hist   one row per iteration: [iter xl xu xr f(xr) ea]
%   Call without outputs to print the iteration table.
%   Example: r = root_bisection(@(x) x.^3 - 10*x.^2 + 5, 0, 1, 1e-4)

if nargin < 3
    error('ru_lib:root_bisection:nargin', 'root_bisection: need at least f, xl, xu.');
end
if nargin < 4 || isempty(es), es = 1e-4; end
if nargin < 5 || isempty(maxit), maxit = 50; end
f = ru_tofunc(f, {'x'});
fl = f(xl);
fu = f(xu);
if fl*fu > 0
    error('ru_lib:root_bisection:nobracket', ...
        'root_bisection: f(xl) and f(xu) must have opposite signs (f(%.6g)=%.6g, f(%.6g)=%.6g).', xl, fl, xu, fu);
end
iter = 0; ea = 100; xr = xl; hist = zeros(0,6);
if fl == 0 || fu == 0
    % An end of the bracket is already an exact root.
    if fl == 0, root = xl; else, root = xu; end
    fx = 0; ea = 0;
    if nargout == 0
        fprintf('root = %.8g is an end of the bracket (f = 0 there)\n', root);
    end
    return
end
while true
    xrold = xr;
    xr = (xl + xu)/2;
    fr = f(xr);
    iter = iter + 1;
    if xr ~= 0
        ea = abs((xr - xrold)/xr)*100;
    else
        ea = 100;
    end
    if fr == 0
        ea = 0;
    end
    hist(iter,:) = [iter xl xu xr fr ea];
    if fr == 0
        break
    end
    if fl*fr < 0
        xu = xr; fu = fr;
    else
        xl = xr; fl = fr;
    end
    if iter >= maxit || (es > 0 && ea <= es)
        break
    end
end
root = xr; fx = fr;
if nargout == 0
    fprintf('iter        xl        xu        xr      f(xr)      ea(%%)\n');
    for k = 1:size(hist,1)
        fprintf('%4d %9.6g %9.6g %9.6g %10.4g %9.4g\n', hist(k,:));
    end
    fprintf('root = %.8g, f(root) = %.4g, ea = %.4g %%, iter = %d\n', root, fx, ea, iter);
end
end

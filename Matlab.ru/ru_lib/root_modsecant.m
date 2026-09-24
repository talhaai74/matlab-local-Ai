function [root, fx, ea, iter, hist] = root_modsecant(f, x0, delta, es, maxit)
%ROOT_MODSECANT  Root of f(x) = 0 by the modified secant method.
%   [root, fx, ea, iter, hist] = root_modsecant(f, x0, delta, es, maxit)
%   f      function handle @(x) ..., or text 'x^3 - 10'
%   x0     initial guess
%   delta  fractional perturbation used to estimate the derivative (default 0.01)
%   es     stop when approximate relative error (PERCENT) <= es (default 1e-4)
%   maxit  maximum iterations (default 50); es = 0 runs exactly maxit iterations
%   root   root estimate; fx = f(root); ea = final error (%); iter = iterations used
%   hist   one row per iteration: [iter x f(x) xnew f(xnew) ea]
%   Call without outputs to print the iteration table.
%   Example: r = root_modsecant(@(x) x.^3 - 10*x.^2 + 5, 0.7, 0.01, 1e-4)

if nargin < 2
    error('ru_lib:root_modsecant:nargin', 'root_modsecant: need at least f, x0.');
end
if nargin < 3 || isempty(delta), delta = 0.01; end
if nargin < 4 || isempty(es), es = 1e-4; end
if nargin < 5 || isempty(maxit), maxit = 50; end
f = ru_tofunc(f, {'x'});
x = x0; iter = 0; ea = 100; hist = zeros(0,6);
while true
    fxc = f(x);
    if fxc == 0
        ea = 0;                      % x is an exact root
        break
    end
    xpert = x + delta*x;
    if xpert == x
        xpert = x + delta;
    end
    fpert = f(xpert);
    denom = fpert - fxc;
    if denom == 0
        error('ru_lib:root_modsecant:zerodenom', ...
            'root_modsecant: f(x+delta*x) equals f(x) (= %.6g) at x = %.6g; increase delta.', fxc, x);
    end
    xnew = x - delta*x*fxc/denom;
    iter = iter + 1;
    if xnew ~= 0
        ea = abs((xnew - x)/xnew)*100;
    else
        ea = 100;
    end
    fnew = f(xnew);
    hist(iter,:) = [iter x fxc xnew fnew ea];
    x = xnew;
    if iter >= maxit || (es > 0 && ea <= es)
        break
    end
end
root = x; fx = f(root);
if nargout == 0
    fprintf('iter         x        f(x)      xnew    f(xnew)     ea(%%)\n');
    for k = 1:size(hist,1)
        fprintf('%4d %9.6g %10.4g %9.6g %10.4g %9.4g\n', hist(k,:));
    end
    fprintf('root = %.8g, f(root) = %.4g, ea = %.4g %%, iter = %d\n', root, fx, ea, iter);
end
end

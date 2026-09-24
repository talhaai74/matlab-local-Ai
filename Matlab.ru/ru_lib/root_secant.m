function [root, fx, ea, iter, hist] = root_secant(f, x0, x1, es, maxit)
%ROOT_SECANT  Root of f(x) = 0 by the secant method (two-point open method).
%   [root, fx, ea, iter, hist] = root_secant(f, x0, x1, es, maxit)
%   f      function handle @(x) ..., or text 'x^3 - 10'
%   x0, x1 two initial guesses (x0 = older point, x1 = newer point)
%   es     stop when approximate relative error (PERCENT) <= es (default 1e-4)
%   maxit  maximum iterations (default 50); es = 0 runs exactly maxit iterations
%   root   root estimate; fx = f(root); ea = final error (%); iter = iterations used
%   hist   one row per iteration: [iter xim1 xi xnew f(xnew) ea]
%   Call without outputs to print the iteration table.
%   Example: r = root_secant(@(x) x.^3 - 10*x.^2 + 5, 0.6, 0.8, 1e-4)

if nargin < 3
    error('ru_lib:root_secant:nargin', 'root_secant: need at least f, x0, x1.');
end
if nargin < 4 || isempty(es), es = 1e-4; end
if nargin < 5 || isempty(maxit), maxit = 50; end
f = ru_tofunc(f, {'x'});
xim1 = x0; xi = x1;
fim1 = f(xim1); fi = f(xi);
iter = 0; ea = 100; hist = zeros(0,6);
while true
    if fi == 0
        ea = 0;                      % xi is an exact root
        break
    end
    denom = fim1 - fi;
    if denom == 0
        error('ru_lib:root_secant:zerodenom', ...
            'root_secant: f(x0) equals f(x1) (= %.6g) at iteration %d; cannot divide by zero.', fi, iter);
    end
    xnew = xi - fi*(xim1 - xi)/denom;
    fnew = f(xnew);
    iter = iter + 1;
    if xnew ~= 0
        ea = abs((xnew - xi)/xnew)*100;
    else
        ea = 100;
    end
    hist(iter,:) = [iter xim1 xi xnew fnew ea];
    xim1 = xi; fim1 = fi;
    xi = xnew; fi = fnew;
    if iter >= maxit || (es > 0 && ea <= es)
        break
    end
end
root = xi; fx = fi;
if nargout == 0
    fprintf('iter      xi-1        xi      xnew    f(xnew)     ea(%%)\n');
    for k = 1:size(hist,1)
        fprintf('%4d %9.6g %9.6g %9.6g %10.4g %9.4g\n', hist(k,:));
    end
    fprintf('root = %.8g, f(root) = %.4g, ea = %.4g %%, iter = %d\n', root, fx, ea, iter);
end
end

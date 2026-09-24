function [root, fx, ea, iter, hist] = root_newton(f, df, x0, es, maxit)
%ROOT_NEWTON  Root of f(x) = 0 by Newton-Raphson (tangent-line open method).
%   [root, fx, ea, iter, hist] = root_newton(f, df, x0, es, maxit)
%   f      function handle @(x) ..., or text 'x^3 - 10'
%   df     derivative handle/text, or [] to use a central-difference estimate
%   x0     initial guess
%   es     stop when approximate relative error (PERCENT) <= es (default 1e-4)
%   maxit  maximum iterations (default 50); es = 0 runs exactly maxit iterations
%   root   root estimate; fx = f(root); ea = final error (%); iter = iterations used
%   hist   one row per iteration: [iter x f(x) fprime(x) ea]
%   Call without outputs to print the iteration table.
%   Example: r = root_newton(@(x) x.^3 - 10*x.^2 + 5, [], 0.7, 1e-4)

if nargin < 3
    error('ru_lib:root_newton:nargin', 'root_newton: need at least f, df, x0.');
end
if nargin < 4 || isempty(es), es = 1e-4; end
if nargin < 5 || isempty(maxit), maxit = 50; end
f = ru_tofunc(f, {'x'});
if isempty(df)
    df = @(x) (f(x + max(1e-6,1e-6*abs(x))) - f(x - max(1e-6,1e-6*abs(x)))) / (2*max(1e-6,1e-6*abs(x)));
else
    df = ru_tofunc(df, {'x'});
end
x = x0; iter = 0; ea = 100; hist = zeros(0,5);
while true
    fxc = f(x);
    if fxc == 0
        ea = 0;                      % x is an exact root (also when f'(x) = 0 there: repeated root)
        break
    end
    dfx = df(x);
    if dfx == 0
        error('ru_lib:root_newton:zeroderiv', ...
            'root_newton: derivative is zero at x = %.6g; Newton-Raphson cannot continue.', x);
    end
    xnew = x - fxc/dfx;
    iter = iter + 1;
    if xnew ~= 0
        ea = abs((xnew - x)/xnew)*100;
    else
        ea = 100;
    end
    hist(iter,:) = [iter x fxc dfx ea];
    x = xnew;
    if iter >= maxit || (es > 0 && ea <= es)
        break
    end
end
root = x; fx = f(root);
if nargout == 0
    fprintf('iter         x        f(x)     fprime(x)     ea(%%)\n');
    for k = 1:size(hist,1)
        fprintf('%4d %9.6g %10.4g %10.4g %9.4g\n', hist(k,:));
    end
    fprintf('root = %.8g, f(root) = %.4g, ea = %.4g %%, iter = %d\n', root, fx, ea, iter);
end
end

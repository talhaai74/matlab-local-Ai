function [root, fx, ea, iter, hist] = root_fixedpoint(g, x0, es, maxit)
%ROOT_FIXEDPOINT  Root of x = g(x) by simple fixed-point iteration.
%   [root, fx, ea, iter, hist] = root_fixedpoint(g, x0, es, maxit)
%   g      function handle @(x) ..., or text, giving the iteration x_new = g(x)
%   x0     initial guess
%   es     stop when approximate relative error (PERCENT) <= es (default 1e-4)
%   maxit  maximum iterations (default 50); es = 0 runs exactly maxit iterations
%   root   root estimate; fx = g(root) - root (residual, ~0 at convergence)
%   ea     final error (%); iter = iterations used
%   hist   one row per iteration: [iter x g(x) ea]
%   Call without outputs to print the iteration table.
%   Example: r = root_fixedpoint(@(x) 0.5*(10 - x.^3)./x, 3.5, 1e-4)

if nargin < 2
    error('ru_lib:root_fixedpoint:nargin', 'root_fixedpoint: need at least g, x0.');
end
if nargin < 3 || isempty(es), es = 1e-4; end
if nargin < 4 || isempty(maxit), maxit = 50; end
g = ru_tofunc(g, {'x'});
x = x0; iter = 0; ea = 100; hist = zeros(0,4);
while true
    gx = g(x);
    if ~isfinite(gx)
        error('ru_lib:root_fixedpoint:diverged', ...
            'root_fixedpoint: iteration diverged (g(x) not finite) at x = %.6g, iteration %d.', x, iter+1);
    end
    iter = iter + 1;
    if gx ~= 0
        ea = abs((gx - x)/gx)*100;
    else
        ea = 100;
    end
    hist(iter,:) = [iter x gx ea];
    x = gx;
    if iter >= maxit || (es > 0 && ea <= es)
        break
    end
end
root = x; fx = g(root) - root;
if nargout == 0
    fprintf('iter         x        g(x)      ea(%%)\n');
    for k = 1:size(hist,1)
        fprintf('%4d %9.6g %10.6g %9.4g\n', hist(k,:));
    end
    fprintf('root = %.8g, residual = %.4g, ea = %.4g %%, iter = %d\n', root, fx, ea, iter);
end
end

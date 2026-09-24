function [xopt, fopt, ea, iter] = opt_golden(f, xl, xu, es, maxit)
%OPT_GOLDEN  Minimum of f(x) on [xl, xu] by golden-section search.
%   [xopt, fopt, ea, iter] = opt_golden(f, xl, xu, es, maxit)
%   f      function handle @(x) ..., or text 'x^3 - 10' (unimodal on [xl,xu])
%   xl, xu bracket known to contain a single minimum
%   es     stop when approximate relative error (PERCENT) <= es (default 1e-4)
%   maxit  maximum iterations (default 50); es = 0 runs exactly maxit iterations
%   xopt   location of the minimum; fopt = f(xopt); ea = final error (%)
%   iter   iterations used. For a MAXIMUM, call with @(x) -f(x) and negate fopt.
%   Example: xo = opt_golden(@(x) 2*sin(x)-x.^2/10, 0, 4, 1e-4)

if nargin < 3
    error('ru_lib:opt_golden:nargin', 'opt_golden: need at least f, xl, xu.');
end
if nargin < 4 || isempty(es), es = 1e-4; end
if nargin < 5 || isempty(maxit), maxit = 50; end
f = ru_tofunc(f, {'x'});
R = (sqrt(5) - 1)/2;
d = R*(xu - xl);
x1 = xl + d; x2 = xu - d;
f1 = f(x1); f2 = f(x2);
iter = 0; ea = 100;
while true
    d = d*R;
    if f1 < f2
        xl = x2; x2 = x1; f2 = f1;
        x1 = xl + d; f1 = f(x1);
    else
        xu = x1; x1 = x2; f1 = f2;
        x2 = xu - d; f2 = f(x2);
    end
    iter = iter + 1;
    if f1 < f2
        xopt = x1; fopt = f1;
    else
        xopt = x2; fopt = f2;
    end
    if xopt ~= 0
        ea = (1 - R)*abs((xu - xl)/xopt)*100;
    else
        ea = 100;
    end
    if iter >= maxit || (es > 0 && ea <= es)
        break
    end
end
if nargout == 0
    fprintf('opt_golden: xopt = %.8g, fopt = %.6g, ea = %.4g %%, iter = %d\n', xopt, fopt, ea, iter);
end
end

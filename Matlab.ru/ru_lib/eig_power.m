function [lambda, v, ea, iter] = eig_power(A, which, es, maxit)
%EIG_POWER  Power method for the largest (or smallest) eigenvalue of A.
%   [lambda, v, ea, iter] = eig_power(A, which, es, maxit)
%   A      square matrix
%   which  'largest' (default) or 'smallest' (power method applied to inv(A))
%   es     stop when the approximate relative error (PERCENT) <= es (default 1e-6)
%   maxit  maximum iterations (default 500)
%   lambda eigenvalue; v = eigenvector scaled so its largest element is 1
%   ea     final approximate relative error (%); iter = iterations used
%   Each iteration: x = A*v, lambda = element of x with the largest
%   magnitude, v = x/lambda (Chapra Sec. 13.3). Starting vector: ones.
%   Call without outputs to print every iteration.
%   Example: [lam, v] = eig_power([40 -20 0; -20 40 -20; 0 -20 40])
if nargin < 2 || isempty(which), which = 'largest'; end
if nargin < 3 || isempty(es), es = 1e-6; end
if nargin < 4 || isempty(maxit), maxit = 500; end
[n, m] = size(A);
if n ~= m
    error('ru_lib:eig_power:notSquare', 'eig_power: A must be square.');
end
smallest = strncmpi(which, 's', 1);
if smallest
    B = inv(A);
else
    B = A;
end
show = (nargout == 0);
[lam, v, ea, iter] = eig_power_run(B, ones(n,1), es, maxit, show);
% A start vector with no component along the dominant eigenvector (e.g. ones
% for [10 -5; -5 10]) converges to the wrong eigenvalue; confirm from a
% second start vector and keep the larger magnitude.
[lam2, v2, ea2, iter2] = eig_power_run(B, (1:n)'/n + 0.1, es, maxit, false);
if abs(lam2) > abs(lam)*(1 + 1e-6)
    if show
        fprintf('The ones start vector missed the dominant mode; restarted from [1:n]/n + 0.1.\n');
    end
    lam = lam2; v = v2; ea = ea2; iter = iter2;
end
if smallest
    lambda = 1/lam;
else
    lambda = lam;
end
if show
    fprintf('%s eigenvalue = %.10g after %d iterations\n', lower(which), lambda, iter);
end
end

function [lam, v, ea, iter] = eig_power_run(B, v, es, maxit, show)
lam = 0;
ea = 100;
iter = 0;
while iter < maxit
    lamold = lam;
    x = B*v;
    [~, k] = max(abs(x));
    lam = x(k);
    if lam == 0
        error('ru_lib:eig_power:zero', 'eig_power: A*v became zero; choose another matrix.');
    end
    v = x/lam;
    iter = iter + 1;
    ea = abs((lam - lamold)/lam)*100;
    if show
        fprintf('iter %3d: eigenvalue estimate = %.8g, ea = %.4g %%, v = [%s]\n', ...
            iter, lam, ea, sprintf(' %.5f', v));
    end
    if ea <= es
        break
    end
end
end

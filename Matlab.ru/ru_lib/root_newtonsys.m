function [root, Fval, ea, iter, hist] = root_newtonsys(F, x0, J, es, maxit)
%ROOT_NEWTONSYS  Root of a nonlinear system F(x) = 0 by Newton's method.
%   [root, Fval, ea, iter, hist] = root_newtonsys(F, x0, J, es, maxit)
%   F      function handle @(x) returning a column vector, x a column vector
%   x0     initial guess, column vector (length n)
%   J      Jacobian handle @(x) -> n-by-n matrix, or [] for finite differences
%   es     stop when approximate relative error (PERCENT) <= es (default 1e-4)
%   maxit  maximum iterations (default 50); es = 0 runs exactly maxit iterations
%   root   root estimate (column vector); Fval = F(root); iter = iterations used
%   ea     final error (%) = norm(dx)/norm(root)*100; hist rows: [iter ea norm(F)]
%   Call without outputs to print the iteration table.
%   Example: F=@(x)[x(1)^2+x(2)^2-4; x(1)-x(2)]; r=root_newtonsys(F,[1;1],[])

if nargin < 2
    error('ru_lib:root_newtonsys:nargin', 'root_newtonsys: need at least F, x0.');
end
if nargin < 3
    J = [];
end
if nargin < 4 || isempty(es), es = 1e-4; end
if nargin < 5 || isempty(maxit), maxit = 50; end
F = ru_tofunc(F, {'x'});
x = x0(:);
iter = 0; ea = 100; hist = zeros(0,3);
while true
    Fx = F(x);
    if isempty(J)
        Jx = local_jacobian(F, x);
    else
        Jx = J(x);
    end
    dx = -(Jx \ Fx);
    xnew = x + dx;
    iter = iter + 1;
    nx = norm(xnew);
    if nx ~= 0
        ea = norm(xnew - x)/nx*100;
    else
        ea = 100;
    end
    hist(iter,:) = [iter ea norm(Fx)];
    x = xnew;
    if iter >= maxit || (es > 0 && ea <= es)
        break
    end
end
root = x; Fval = F(root);
if nargout == 0
    fprintf('iter        ea(%%)     norm(F)\n');
    for k = 1:size(hist,1)
        fprintf('%4d %11.4g %11.4g\n', hist(k,:));
    end
    fprintf('root ='); fprintf(' %.8g', root); fprintf('\n');
    fprintf('iter = %d, ea = %.4g %%\n', iter, ea);
end
end

function Jx = local_jacobian(F, x)
n = length(x);
Fx = F(x);
Jx = zeros(length(Fx), n);
for j = 1:n
    h = max(1e-6, 1e-6*abs(x(j)));
    xp = x; xp(j) = xp(j) + h;
    Jx(:,j) = (F(xp) - Fx)/h;
end
end

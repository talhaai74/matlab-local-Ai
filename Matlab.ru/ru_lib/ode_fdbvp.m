function [x, y] = ode_fdbvp(p, q, r, xspan, ya, yb, n)
%ODE_FDBVP  Finite-difference solution of a linear 2nd-order BVP.
%   [x, y] = ode_fdbvp(p, q, r, xspan, ya, yb, n)
%   Solves y'' + p(x)*y' + q(x)*y = r(x) on xspan=[a b], y(a)=ya, y(b)=yb
%   p, q, r  each a constant or a function handle @(x) ...
%   n        number of interior nodes; grid spacing dx = (b-a)/(n+1)
%   x        column of n+2 nodes including both boundaries
%   y        column of y at each node (y(1)=ya, y(end)=yb)
%   Builds the tridiagonal system directly and solves it with backslash.
%   Example: [x,y] = ode_fdbvp(0, -1, 0, [0 1], 1, 0, 8)  % y'' - y = 0
if nargin < 7 || isempty(n) || n < 1
    error('ru_lib:ode_fdbvp:n', 'ode_fdbvp: number of interior nodes n must be a positive integer.');
end
a = xspan(1); b = xspan(2);
dx = (b - a) / (n + 1);
x = linspace(a, b, n+2)';
pf = ode_fdbvp_tofun(p);
qf = ode_fdbvp_tofun(q);
rf = ode_fdbvp_tofun(r);
xi = x(2:end-1);
pv = zeros(n,1); qv = zeros(n,1); rv = zeros(n,1);
for i = 1:n
    pv(i) = pf(xi(i));
    qv(i) = qf(xi(i));
    rv(i) = rf(xi(i));
end
A = zeros(n,n);
B = rv .* dx^2;
for i = 1:n
    A(i,i) = -2 + qv(i)*dx^2;
    if i > 1
        A(i,i-1) = 1 - pv(i)*dx/2;
    else
        B(i) = B(i) - (1 - pv(i)*dx/2)*ya;
    end
    if i < n
        A(i,i+1) = 1 + pv(i)*dx/2;
    else
        B(i) = B(i) - (1 + pv(i)*dx/2)*yb;
    end
end
yint = A \ B;
y = [ya; yint; yb];
if nargout == 0
    fprintf('ode_fdbvp: %d interior nodes, dx = %.6f\n', n, dx);
    fprintf('%6s  %12s  %12s\n', 'i', 'x', 'y');
    for i = 1:length(x)
        fprintf('%6d  %12.6f  %12.6f\n', i, x(i), y(i));
    end
end
end

function f = ode_fdbvp_tofun(v)
if isa(v, 'function_handle')
    f = v;
else
    f = @(xx) v + zeros(size(xx));
end
end

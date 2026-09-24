function [x, y, z] = ode_shooting(dydx, xspan, ya, yb, z1, z2)
%ODE_SHOOTING  Shooting method for a linear or nonlinear 2nd-order BVP.
%   [x, y, z] = ode_shooting(dydx, xspan, ya, yb, z1, z2)
%   dydx   @(x,Y) system with Y=[y;z], z=dy/dx: returns [dy/dx; dz/dx] as a
%          column vector, e.g. @(x,Y) [Y(2); -(g/L)*sin(Y(1))]
%   xspan  [a b], the domain; ya, yb  Dirichlet BCs: y(a)=ya, y(b)=yb
%   z1, z2 two guesses for the unknown slope z(a); used to start fzero on
%          the boundary residual (a linear ODE converges in one step)
%   x      column of nodes from ode45; y = y(x); z = dy/dx(x)
%   Example: [x,y,z] = ode_shooting(@(x,Y) [Y(2); -0.05*(200-Y(1))-2.7e-9*(1.6e9-Y(1)^4)], [0 10], 300, 400, -50, -60)
dydx = ru_tofunc(dydx, {'x','y'});
res = @(za) ode_shooting_res(za, dydx, xspan, ya, yb);
r1 = res(z1);
if abs(r1) < 1e-9
    za = z1;
else
    r2 = res(z2);
    if abs(r2) < 1e-9
        za = z2;
    elseif sign(r1) ~= sign(r2)
        za = fzero(res, [min(z1,z2) max(z1,z2)]);
    else
        za = fzero(res, z1);
    end
end
[x, Y] = ode45(dydx, xspan, [ya; za]);
y = Y(:,1);
z = Y(:,2);
if nargout == 0
    fprintf('ode_shooting: converged initial slope za = %.6f\n', za);
    fprintf('%6s  %12s  %12s\n', 'i', 'x', 'y');
    for i = 1:length(x)
        fprintf('%6d  %12.6f  %12.6f\n', i, x(i), y(i));
    end
end
end

function r = ode_shooting_res(za, dydx, xspan, ya, yb)
[~, Yr] = ode45(dydx, xspan, [ya; za]);
r = Yr(end,1) - yb;
end

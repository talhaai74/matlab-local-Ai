function [t, y] = ode_midpoint(dydt, tspan, y0, h)
%ODE_MIDPOINT  Midpoint method (2nd-order Runge-Kutta) for dy/dt = f(t,y).
%   [t, y] = ode_midpoint(dydt, tspan, y0, h)
%   dydt   @(t,y) ..., or text 'y*t^3 - 1.5*y' (scalar ODE only)
%   tspan  [t0 tf] (step h; last step shortened if h does not divide tf-t0)
%          or a vector of times to step through directly
%   y0     initial value(s); scalar, or vector for a system (dydt returns a
%          column vector the same size as y0)
%   h      step size (ignored when tspan has 3+ entries)
%   t      column of times; y  one row per time (like ode45)
%   Formula: k1=f(t,y); k2=f(t+h/2, y+k1*h/2); y_new = y + k2*h
%   Example: [t,y] = ode_midpoint(@(t,y) y.*t.^3-1.5*y, [0 2], 1, 0.5)
dydt = ru_tofunc(dydt, {'t','y'});
[t, Y, n, m] = ru_odegrid(tspan, h, y0);
for i = 1:n-1
    hi = t(i+1) - t(i);
    yy = Y(i,:)';
    k1 = dydt(t(i), yy); k1 = k1(:);
    k2 = dydt(t(i) + hi/2, yy + 0.5*k1*hi); k2 = k2(:);
    Y(i+1,:) = (yy + k2*hi)';
end
y = Y;
if nargout == 0
    ru_print_ode_table('ode_midpoint', t, Y, m);
end
end

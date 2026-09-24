function [t, y] = ode_euler(dydt, tspan, y0, h, varargin)
%ODE_EULER  Euler's method (explicit, one slope per step) for dy/dt = f(t,y).
%   [t, y] = ode_euler(dydt, tspan, y0, h)
%   dydt   @(t,y) ..., or text 'y*t^3 - 1.5*y' (scalar ODE only)
%   tspan  [t0 tf] (marches with step h; last step shortened if h does not
%          divide tf-t0) or a vector of times to step through directly
%   y0     initial value(s); scalar, or a vector for a system (dydt must
%          then return a column vector the same size as y0)
%   h      step size (ignored when tspan has 3+ entries)
%   varargin  extra parameters forwarded as dydt(t,y,varargin{:})
%   t      column of times; y  one row per time (like ode45)
%   Example: [t,v] = ode_euler(@(t,v) 9.81-(0.25/68.1)*v.^2, [0 12], 0, 2)
dydt = ru_tofunc(dydt, {'t','y'});
[t, Y, n, m] = ru_odegrid(tspan, h, y0);
for i = 1:n-1
    hi = t(i+1) - t(i);
    yy = Y(i,:)';
    k1 = dydt(t(i), yy, varargin{:});
    k1 = k1(:);
    Y(i+1,:) = (yy + k1*hi)';
end
y = Y;
if nargout == 0
    ru_print_ode_table('ode_euler', t, Y, m);
end
end

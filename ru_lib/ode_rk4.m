function [t, y] = ode_rk4(dydt, tspan, y0, h, varargin)
%ODE_RK4  Classical 4th-order Runge-Kutta method for dy/dt = f(t,y).
%   [t, y] = ode_rk4(dydt, tspan, y0, h)
%   dydt   @(t,y) ..., or text 'y*t^3 - 1.5*y' (scalar ODE only)
%   tspan  [t0 tf] (step h; last step shortened if h does not divide tf-t0)
%          or a vector of times to step through directly
%   y0     initial value(s); scalar, or vector for a system (dydt must then
%          return a column vector the same size as y0)
%   h      step size (ignored when tspan has 3+ entries)
%   varargin  extra parameters forwarded as dydt(t,y,varargin{:})
%   t      column of times; y  one row per time (like ode45)
%   Example: [t,y] = ode_rk4(@(t,y) y.*t.^3-1.5*y, [0 2], 1, 0.5)
dydt = ru_tofunc(dydt, {'t','y'});
[t, Y, n, m] = ru_odegrid(tspan, h, y0);
for i = 1:n-1
    hi = t(i+1) - t(i);
    tt = t(i); yy = Y(i,:)';
    k1 = dydt(tt, yy, varargin{:}); k1 = k1(:);
    k2 = dydt(tt + hi/2, yy + 0.5*k1*hi, varargin{:}); k2 = k2(:);
    k3 = dydt(tt + hi/2, yy + 0.5*k2*hi, varargin{:}); k3 = k3(:);
    k4 = dydt(tt + hi, yy + k3*hi, varargin{:}); k4 = k4(:);
    Y(i+1,:) = (yy + hi*(k1 + 2*k2 + 2*k3 + k4)/6)';
end
y = Y;
if nargout == 0
    ru_print_ode_table('ode_rk4', t, Y, m);
end
end

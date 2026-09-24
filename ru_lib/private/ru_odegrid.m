function [t, Y, n, m] = ru_odegrid(tspan, h, y0)
%RU_ODEGRID  Build the time grid and preallocate output for fixed-step ODE
%   marching methods (private helper for ode_euler, ode_heun, ode_midpoint,
%   ode_ralston, ode_rk4).
%   [t,Y,n,m] = ru_odegrid(tspan, h, y0)
%   tspan = [t0 tf]  grid is t0:h:tf, with tf appended as a final, shorter
%                     step if h does not divide (tf-t0) evenly
%   tspan (3+ entries) used directly as the column of marching/output times
%   y0    initial value(s) (scalar or vector); only used to size Y
%   t     column of times; Y preallocated n-by-m with Y(1,:) = y0(:)'
tspan = tspan(:)';
if numel(tspan) < 2
    error('ru_lib:ru_odegrid:tspan', ...
        'ru_odegrid: tspan must be [t0 tf] or a vector of times with 2+ entries.');
end
if numel(tspan) == 2
    if isempty(h) || h <= 0
        error('ru_lib:ru_odegrid:h', 'ru_odegrid: step size h must be a positive number.');
    end
    t0 = tspan(1); tf = tspan(2);
    if tf < t0
        error('ru_lib:ru_odegrid:tspan', 'ru_odegrid: tspan(2) must be >= tspan(1).');
    end
    t = (t0:h:tf)';
    n = length(t);
    tol = 1e-9 * max(1, abs(tf));
    if (tf - t(n)) > tol
        t(n+1) = tf;
        n = n + 1;
    end
else
    t = tspan';
    n = length(t);
    if any(diff(t) <= 0)
        error('ru_lib:ru_odegrid:tspan', ...
            'ru_odegrid: tspan given as a vector of times must be strictly increasing.');
    end
end
y0 = y0(:)';
m = numel(y0);
Y = zeros(n, m);
Y(1,:) = y0;
end

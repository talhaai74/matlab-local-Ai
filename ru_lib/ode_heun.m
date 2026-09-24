function [t, y] = ode_heun(dydt, tspan, y0, h, es, maxit)
%ODE_HEUN  Heun's method (predictor-corrector) for dy/dt = f(t,y).
%   [t, y] = ode_heun(dydt, tspan, y0, h)
%   [t, y] = ode_heun(dydt, tspan, y0, h, es, maxit)
%   dydt   @(t,y) ..., or text 'y*t^3 - 1.5*y' (scalar ODE only)
%   tspan  [t0 tf] (step h; last step shortened if h does not divide tf-t0)
%          or a vector of times to step through directly
%   y0     initial value(s); scalar, or vector for a system (dydt returns a
%          column vector the same size as y0)
%   es     omit/[] -> single predictor + single corrector pass per step
%          (matches the slides). Given -> corrector is ITERATED each step
%          until approx. relative error (PERCENT) <= es (default 1e-4)
%   maxit  max corrector iterations per step when es is given (default 50)
%   t      column of times; y  one row per time (like ode45)
%   Example: [t,y] = ode_heun(@(t,y) y.*t.^3-1.5*y, [0 2], 1, 0.5)
if nargin < 5, es = []; end
if nargin < 6 || isempty(maxit), maxit = 50; end
dydt = ru_tofunc(dydt, {'t','y'});
[t, Y, n, m] = ru_odegrid(tspan, h, y0);
doIter = ~isempty(es);
for i = 1:n-1
    hi = t(i+1) - t(i);
    yy = Y(i,:)';
    f0 = dydt(t(i), yy);
    f0 = f0(:);
    yc = yy + f0*hi;
    if doIter
        iter = 0; ea = Inf;
        while ea > es && iter < maxit
            ycOld = yc;
            fc = dydt(t(i+1), ycOld);
            fc = fc(:);
            yc = yy + (f0 + fc)*hi/2;
            denom = yc; denom(denom == 0) = eps;
            ea = max(abs((yc - ycOld)./denom))*100;
            iter = iter + 1;
        end
    else
        fc = dydt(t(i+1), yc);
        fc = fc(:);
        yc = yy + (f0 + fc)*hi/2;
    end
    Y(i+1,:) = yc';
end
y = Y;
if nargout == 0
    ru_print_ode_table('ode_heun', t, Y, m);
end
end

function [tp,yp] = rk4(dydt,tspan,y0,h)
% input:    dydt = name of the M-file that evaluates the ODEs
%           tspan = [ti, tf]; initial and final times
%           y0 = initial values of dependent variables
%           h = step size
% output:   tp = vector of independent variable
%           yp = vector of solution for dependent variables

if nargin<4,error('4 input arguments required'),end
ti = tspan(1); tf = tspan(2);
tp = (ti:h:tf)'; n = length(tp);
% if necessary, add an additional value of t
% so that range goes from tp = ti to tf
if tp(n)<tf
    tp(n+1) = tf; n = n+1;
end

yp = y0*ones(n,1); %preallocate y to improve efficiency

for i = 1:n-1 %implement RK method

    tt = tp(i); yy = yp(i);

    k1 = dydt(tt,yy);
    k2 = dydt(tt + h/2, yy + 0.5*k1*h);
    k3 = dydt(tt + h/2, yy + 0.5*k2*h);
    k4 = dydt(tt + h, yy + k3*h);

    yp(i+1) = yy + h*(k1 + 2*k2 + 2*k3 + k4)/6;

end
end

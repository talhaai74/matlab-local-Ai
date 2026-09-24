function [t,y] = eulode(dydt,tspan,y0,h)
% Euler's method for a single ODE or a system of first-order ODEs
% input:
%   dydt = name of the M-file that evaluates the ODE(s)
%   tspan = [ti, tf], limits of independent variable
%   y0 = initial value/vector of dependent variable(s)
%   h = step size
% output:
%   t = independent-variable vector
%   y = solution vector/matrix

if nargin<3,error('less than 3 input arguments'),end

ti = tspan(1); tf = tspan(2);
t = (ti:h:tf)'; n = length(t);

% if necessary, add an additional value of t
% so that range goes from t = ti to tf
if t(n)<tf
    t(n+1) = tf;
    n = n+1;
end

% Preallocate for one or more dependent variables
y0 = y0(:).';
m = length(y0);
y = zeros(n,m);
y(1,:) = y0;

for i = 1:n-1
    dt = t(i+1)-t(i);
    f = dydt(t(i),y(i,:).');
    y(i+1,:) = y(i,:) + f(:).' * dt;
end

% Keep the original output format for a single ODE
if m == 1
    y = y(:,1);
end
end

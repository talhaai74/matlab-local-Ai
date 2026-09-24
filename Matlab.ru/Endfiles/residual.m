function r = residual(z)
[x,y] = ode45(@problem, [0 120], [0 z]);
r = y(length(x),1)-0;
end
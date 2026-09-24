function [root, fx,ea,iter] =newtonraphson(func, dfunc, x1, es,maxit)
if nargin<4 || isempty(es), es=0.0001; end
if nargin<5 || isempty(maxit), maxit = 50; end

iter = 0; xr =x1;
while(1)
    oldxr = xr;
    xr = xr - (func(xr)/dfunc(xr));
    iter = iter +1;
    ea = abs((xr - oldxr)/xr)*100;
    if ea<=es || iter>=maxit
        break;
    end
end
root = xr; fx = func(xr);
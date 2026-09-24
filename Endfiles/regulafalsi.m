function [root,fx,ea,iter] = regulafalsi(func,xl,xu,es,maxit)
if nargin<4 || isempty(es), es= 0.0001; end
if nargin<4 || isempty(maxit), maxit = 50; end

iter = 0; xr = xl; 

while(1)
    oldxr = xr;
    xr = xl - (func(xl)*(xu - xl)/(func(xu) - func(xl)));
    iter = iter+1; ea = abs((xr - oldxr)/xr)*100;
    numb = func(xl)*func(xr);
    if numb>0
        xl = xr;
    elseif numb<0
        xu = xr;
    else 
        ea = 0;
    end
    if ea<=es || iter>=maxit 
        break;
    end
end
root = xr;
fx = func(xr);
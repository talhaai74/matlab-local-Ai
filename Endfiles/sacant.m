function [root, fx,ea,iter] =sacant(func, x0, x1, es,maxit)
if nargin<4 || isempty(es), es=0.0001; end
if nargin<5 || isempty(maxit), maxit = 50; end
iter =0; 
while(1)
    if x0 ~=x1
        x2 = x0-(func(x0)*(x1-x0)/(func(x1)-func(x0)));
        iter = iter+1; ea = abs((x2-x1)/x2)*100;
        x0 =x1;
        x1 = x2;
    end
    if ea<=es || iter>=maxit 
        break;
    end
end
root = x1;
fx = func(x1);

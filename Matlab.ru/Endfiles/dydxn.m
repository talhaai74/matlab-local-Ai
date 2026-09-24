function dy=dydxn(x,y)
dy=[y(2);
-0.05*(200-y(1))-2.7e-9*(1.6e9-y(1)^4)];
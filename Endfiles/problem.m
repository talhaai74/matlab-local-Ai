function dydx = problem(x,y)
w = 1/12;
L = 120;
E = 30000;
I = 800;

dydx = [ y(2);
 (w/(2.*E.*I)).*(L.*x - x.^2)];

end
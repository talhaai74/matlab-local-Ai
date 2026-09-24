function yp = bvp(x,y)
yp = [y(2);
      (1/4800000)*x - (1/576000000)*x.^2];
end
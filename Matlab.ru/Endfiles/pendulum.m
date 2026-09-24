function yp = pendulum(t,y)
yp = [y(2);
      (-32.2/2)*sin(y(1))];
end
function dydt = ivp(t,y)
dydt = y.*t.^3-1.5*y;
end
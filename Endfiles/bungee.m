function dvdt = bungee(t,v)
dvdt = 9.81 - (0.25/68.1)*v.^2;
end
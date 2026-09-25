% TOPIC: differentiation
% TITLE: Newton's law of cooling: dT/dt with gradient, then k from the slope of a linear regression (class method)
% SOURCE: CE206 slides 05 page 4; Chapra Prob. 21.28; CE206 class solution (Differentiation sheet)
% KEYWORDS: newton's law of cooling, dT/dt, numerical differentiation, proportionality constant, gradient, polyfit slope, metal ball, water
% PROBLEM:
% The rate of cooling of a body is dT/dt = -k(T - Ta). A metal ball heated to 80 C is dropped into water
% held at Ta = 20 C; its temperature is t (min) = 0 5 10 15 20 25, T (C) = 80 44.5 30.0 24.1 21.7 20.7.
% (a) Determine dT/dt at each time using numerical differentiation.
% (b) Plot dT/dt versus T - Ta and use linear regression to determine k.
% CHECK: abs(k - 0.11904712) < 1e-7 && abs(dTdt(1) + 7.1) < 1e-12
% CODE:
Ta = 20;
T = [80 44.5 30 24.1 21.7 20.7];
t = 0:5:25;
dTdt = gradient(T, 5)
a = polyfit(T - Ta, dTdt, 1);
k = -a(1)
X = [min(T) max(T)] - Ta;
figure; plot(T - Ta, dTdt, '*', X, polyval(a, X), '-'); grid on;
xlabel('T - T_a (C)'); ylabel('dT/dt (C/min)'); title('dT/dt versus T - T_a'); legend('data', 'linear regression');

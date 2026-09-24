% TOPIC: differentiation
% TITLE: Newton's law of cooling: dT/dt by numerical differentiation, then k by linear regression
% SOURCE: CE206 slides 05 page 4; Chapra Prob. 21.28
% KEYWORDS: newton's law of cooling, dT/dt, numerical differentiation, proportionality constant, linear regression through the origin, metal ball, water
% PROBLEM:
% The rate of cooling of a body is dT/dt = -k(T - Ta). A metal ball heated to 80 C is dropped into water
% held at Ta = 20 C; its temperature is t (min) = 0 5 10 15 20 25, T (C) = 80 44.5 30.0 24.1 21.7 20.7.
% (a) Determine dT/dt at each time using numerical differentiation.
% (b) Plot dT/dt versus T - Ta and use linear regression to determine k.
% CHECK: abs(k - 0.161771) < 1e-5
% CODE:
t = [0 5 10 15 20 25];
T = [80 44.5 30.0 24.1 21.7 20.7];
Ta = 20;
%% (a) O(h^2) derivatives: centered inside, one-sided second-order at the ends
dTdt = diff_data(t, T);
fprintf('%6s %8s %12s\n', 't', 'T', 'dT/dt');
fprintf('%6g %8.1f %12.4f\n', [t; T; dTdt]);
%% (b) dT/dt = -k (T - Ta) is a straight line through the origin
X = T - Ta;
k = -sum(dTdt.*X)/sum(X.^2);
fprintf('k = %.4f per min\n', k);
figure; plot(X, dTdt, 'ko', [0 max(X)], -k*[0 max(X)], 'b-'); grid on;
xlabel('T - T_a (C)'); ylabel('dT/dt (C/min)'); legend('data', 'dT/dt = -k(T - T_a)');

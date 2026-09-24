% TOPIC: differentiation
% TITLE: Rocket velocity and acceleration from distance-time data (numerical differentiation)
% SOURCE: Chapra Prob. 21.11
% KEYWORDS: velocity, acceleration, distance, rocket, first derivative, second derivative, tabulated data, o(h^2)
% PROBLEM:
% Distance traveled by a rocket: t (s) = 0 25 50 75 100 125, y (km) = 0 32 58 78 92 100.
% Use numerical differentiation to estimate the rocket's velocity and acceleration at each time.
% CHECK: norm(v - [1.4 1.16 0.92 0.68 0.44 0.2]) < 1e-9 && all(abs(a + 0.0096) < 1e-12)
% CODE:
t = [0 25 50 75 100 125];
y = [0 32 58 78 92 100];
[v, a] = diff_data(t, y);          % O(h^2): centered inside, one-sided at the ends
fprintf('%6s %8s %14s %16s\n', 't (s)', 'y (km)', 'v (km/s)', 'a (km/s^2)');
fprintf('%6g %8g %14.4f %16.6f\n', [t; y; v; a]);
figure;
subplot(2,1,1); plot(t, v, 'o-'); grid on; ylabel('v (km/s)'); title('Velocity');
subplot(2,1,2); plot(t, a, 's-'); grid on; ylabel('a (km/s^2)'); xlabel('t (s)'); title('Acceleration');

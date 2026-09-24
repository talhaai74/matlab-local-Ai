% TOPIC: ode
% TITLE: Time for a spherical tank to drain through an orifice (Torricelli) - ODE and exact integral
% SOURCE: Chapra Prob. 22.16 (Fig. P22.16)
% KEYWORDS: spherical tank, draining, orifice, torricelli, outflow, dh/dt, time to empty, ode45, integral
% PROBLEM:
% A spherical tank has a circular orifice in its bottom. The outflow is Q = C A sqrt(2 g h), where
% C = 0.55, A = orifice area, g = 9.81 m/s^2 and h = depth. Determine how long it takes for the water to
% flow out of a 3-m diameter tank with an initial height of 2.75 m if the orifice diameter is 3 cm.
% The tank's surface area at depth h is pi (2 r h - h^2), so dh/dt = -Q / (pi (2 r h - h^2)).
% CHECK: abs(Tempty - 7487.67) < 0.1
% CODE:
r = 1.5; h0 = 2.75; d = 0.03; C = 0.55; g = 9.81;
A = pi*d^2/4;
Atank = @(h) pi*(2*r*h - h.^2);
dhdt = @(t, h) -C*A*sqrt(2*g*max(h, 0))./Atank(max(h, 1e-9));
% separable ODE: T = integral of Atank(h)/(C A sqrt(2 g h)) dh from 0 to h0
Tempty = integral(@(h) Atank(h)./(C*A*sqrt(2*g*h)), 0, h0);
fprintf('Time to empty = %.1f s = %.2f min\n', Tempty, Tempty/60);
[t, h] = ode45(dhdt, linspace(0, 0.999*Tempty, 200), h0);
fprintf('ode45 check: h(0.999 T) = %.4f m (close to empty)\n', h(end));
figure; plot(t/60, h); grid on; xlabel('t (min)'); ylabel('h (m)'); title('Draining spherical tank');

% TOPIC: integration
% TITLE: Flow rate in a pipe from the velocity profile v = 2(1 - r/r0)^(1/6) by the composite trapezoidal rule
% SOURCE: Class solution sheet "Numerical Integration"; Chapra Prob. 20.17
% KEYWORDS: pipe, velocity distribution, flow rate, Q = integral v 2 pi r dr, radius, composite trapezoidal rule, discuss
% PROBLEM:
% The flow rate through a pipe is Q = integral_0^r0 v (2 pi r) dr, where r is the radial distance from the
% center. The velocity distribution is v = 2(1 - r/r0)^(1/6), where r0 is the total radius (3 cm).
% Compute Q using the composite trapezoidal rule. Discuss the results.
% CHECK: abs(Q - 0.00445442) < 1e-8 && abs(Qexact - 0.00447418) < 1e-8
% CODE:
r0 = 0.03;
r = linspace(0, r0);
v = 2*(1 - r/r0).^(1/6);
Q = trapz(r, 2*pi*r.*v);
Qexact = 4*pi*r0^2*36/91;
fprintf('Q (composite trapezoidal, %d points) = %.6e m^3/s\n', numel(r), Q);
fprintf('Exact Q = %.6e m^3/s, et = %.2f %%\n', Qexact, abs(Qexact - Q)/Qexact*100);
disp('The profile has an infinite slope at the wall (r = r0), so the trapezoidal rule converges slowly there.');

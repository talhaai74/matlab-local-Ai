% TOPIC: ode
% TITLE: Bungee jumper with Heun's method (predictor-corrector), h = 2 s, compared with Euler and exact
% SOURCE: CE206 slides 06 page 7 (modify eulode for Heun) / Endfiles heanode.m
% KEYWORDS: heun's method, predictor, corrector, bungee jumper, modify eulode, compare with euler
% PROBLEM:
% Modify eulode to implement Heun's method and solve the same bungee-jumper problem
% dv/dt = 9.81 - (0.25/68.1) v^2, v(0) = 0, from t = 0 to 12 s with h = 2 s. Compare with Euler's
% method and the analytical solution.
% CHECK: abs(vh(end) - 49.99385) < 1e-4 && abs(vlib(end) - vh(end)) < 1e-10
% CODE:
g = 9.81; cd = 0.25; m = 68.1;
dvdt = @(t, v) g - cd/m*v.^2;
h = 2;
t = (0:h:12)';
vh = zeros(size(t));                   % Heun written out (predictor-corrector, no iteration)
for i = 1:numel(t) - 1
    k1 = dvdt(t(i), vh(i));
    v0 = vh(i) + k1*h;                 % predictor (Euler)
    k2 = dvdt(t(i+1), v0);
    vh(i+1) = vh(i) + (k1 + k2)/2*h;   % corrector (average slope)
end
[~, ve] = ode_euler(dvdt, [0 12], 0, h);
vt = sqrt(g*m/cd)*tanh(sqrt(g*cd/m)*t);
fprintf('%6s %10s %10s %10s\n', 't', 'Euler', 'Heun', 'exact');
fprintf('%6g %10.4f %10.4f %10.4f\n', [t ve vh vt]');
[~, vlib] = ode_heun(dvdt, [0 12], 0, h);
fprintf('ru_lib ode_heun gives the same final value: %.4f m/s\n', vlib(end));

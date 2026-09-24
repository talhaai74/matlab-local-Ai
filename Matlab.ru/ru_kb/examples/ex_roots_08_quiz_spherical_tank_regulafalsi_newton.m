% TOPIC: roots
% TITLE: Spherical tank depth for 30 m^3: regula falsi and Newton-Raphson, three iterations (quiz)
% SOURCE: CE206 Final Quiz (18 batch) Set A, Q1; Chapra Prob. 6.22
% KEYWORDS: spherical tank, volume of liquid, depth of water, tank radius, regula falsi, false position, newton raphson, three iterations, quiz
% PROBLEM:
% You are designing a spherical tank to hold water for a small village. The volume of liquid it
% can hold is V = pi*h^2*(3R - h)/3, where V = volume (m^3), h = depth of water (m) and
% R = tank radius (m). If R = 3 m, to what depth must the tank be filled so that it holds 30 m^3?
% Use the Regula-Falsi method (initial guesses 0.1 and 3) and the Newton-Raphson method
% (initial guess 3) for a maximum of three iterations.
% CHECK: abs(hf - 2.0243) < 1e-4 && abs(hn - 2.0269) < 1e-4
% CHECK: itf == 3 && itn == 3
% CODE:
R = 3; V = 30;
f  = @(h) pi*h.^2.*(3*R - h)/3 - V;       % f(h) = 0 gives the depth
df = @(h) pi*(2*R*h - h.^2);              % f'(h)
fprintf('f(h) = pi*h^2*(3R - h)/3 - V,  R = %g m, V = %g m^3\n', R, V);

[hf, fhf, eaf, itf, tf] = root_falseposition(f, 0.1, 3, 0, 3);
fprintf('\nRegula falsi (xl = 0.1, xu = 3):\n%5s %10s %10s %10s %12s %10s\n', 'iter', 'xl', 'xu', 'xr', 'f(xr)', 'ea (%)');
fprintf('%5d %10.5f %10.5f %10.5f %12.5f %10.4f\n', tf');

[hn, fhn, ean, itn, tn] = root_newton(f, df, 3, 0, 3);
fprintf('\nNewton-Raphson (x0 = 3):\n%5s %10s %12s %12s %10s\n', 'iter', 'h', 'f(h)', 'f''(h)', 'ea (%)');
fprintf('%5d %10.5f %12.5f %12.5f %10.4f\n', tn');

fprintf('\nRegula falsi after %d iterations: h = %.4f m (ea = %.4f %%)\n', itf, hf, eaf);
fprintf('Newton-Raphson after %d iterations: h = %.4f m (ea = %.4f %%)\n', itn, hn, ean);
fprintf('Check (fzero): h = %.4f m\n', fzero(f, [0.1 3]));

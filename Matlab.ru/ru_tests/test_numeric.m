function results = test_numeric()
%TEST_NUMERIC  Tests of the root, fit, integration, differentiation, ODE and
%   eigenvalue ru_lib functions against textbook (Chapra) and CE206 answers.
results = struct('name', {}, 'pass', {}, 'msg', {});

% --- roots ----------------------------------------------------------------
results = check(results, 'root_bisection_slide', ...
    @() root_bisection(@(x) x.^3 - 10*x.^2 + 5, 0.6, 0.8, 1e-4), 0.7346, 1e-4);
tank = @(h) h.^2 - h.^3/9 - 10/pi;
results = check(results, 'root_falseposition_quiz_tank_3iter', ...
    @() root_falseposition(tank, 0.1, 3, 1e-4, 3), 2.0243, 1e-4);
results = check(results, 'root_newton_quiz_tank_3iter', ...
    @() root_newton(tank, @(h) 2*h - h.^2/3, 3, 1e-4, 3), 2.0269, 1e-4);
fsc = @(x) sin(x) + cos(1 + x.^2) - 1;
results = check(results, 'root_secant_sin_cos', @() fsc(root_secant(fsc, 1.0, 3.0, 1e-10, 50)), 0, 1e-8);
osat = @(T, o) -139.34411 + 1.575701e5./(T+273.15) - 6.642308e7./(T+273.15).^2 ...
    + 1.2438e10./(T+273.15).^3 - 8.621949e11./(T+273.15).^4 - log(o);
results = check(results, 'root_fzero_oxygen_8', @() fzero(@(T) osat(T, 8), [0 40]), 26.7802, 1e-3);
results = check(results, 'root_modsecant', ...
    @() root_modsecant(@(x) exp(-x) - x, 1, 1e-6, 1e-8, 50), 0.567143290, 1e-7);

% --- regression -----------------------------------------------------------
v = 10:10:80; F = [25 70 380 550 610 1220 830 1450];
results = check(results, 'fit_linear_windtunnel', @() fit_linear(v, F), [19.4702 -234.2857], 1e-3);
results = check(results, 'fit_power_windtunnel_log10', @() fit_power(v, F), 0.2741, 1e-3);
results = check(results, 'general_LS_parabola', ...
    @() ([ones(8,1) v' v'.^2]'*[ones(8,1) v' v'.^2])\([ones(8,1) v' v'.^2]'*F'), ...
    [-178.4821; 16.1220; 0.0372], 1e-3);
results = check(results, 'fit_nonlinear_power', ...
    @() fit_nonlinear(@(p,x) p(1)*x.^p(2), [1 1], v, F), [2.5384 1.4359], 2e-3);

% --- integration ----------------------------------------------------------
g = @(x) 1 - exp(-x);
results = check(results, 'integ_trap_single', @() integ_trap(g, 0, 4, 1), 2*(1 - exp(-4)), 1e-12);
results = check(results, 'integ_simp13_single', @() integ_simp13(g, 0, 4, 2), ...
    2/3*(4*(1 - exp(-2)) + (1 - exp(-4))), 1e-12);
results = check(results, 'integ_simp13_n100', @() integ_simp13(g, 0, 4, 100), 3 + exp(-4), 1e-7);
results = check(results, 'integ_simp38_single', @() integ_simp38(g, 0, 4), ...
    3*(4/3)/8*(g(0) + 3*g(4/3) + 3*g(8/3) + g(4)), 1e-12);
p5 = @(x) 1 - x - 4*x.^3 + 2*x.^5;
results = check(results, 'integ_boole_exact_quintic', @() integ_newtoncotes(p5, -2, 4, 'boole'), 1104, 1e-9);
results = check(results, 'integ_gauss3_exact_quintic', @() integ_gauss(p5, -2, 4, 3), 1104, 1e-9);
results = check(results, 'integ_gauss_erf', @() integ_gauss(@(x) 2/sqrt(pi)*exp(-x.^2), 0, 1.5, 6), ...
    erf(1.5), 1e-6);
results = check(results, 'integ_romberg', @() integ_romberg(@(x) (x + 1./x).^2, 1, 2, 1e-8), 29/6, 1e-7);
mast = @(z) 200*(z./(5 + z)).*exp(-2*z/30);
results = check(results, 'integ_trap_mast_h15', @() integ_trap(mast, 0, 30, 2), 1001.7, 0.1);
results = check(results, 'integ_trap_mast_h1', @() integ_trap(mast, 0, 30, 30), 1477.1, 0.1);
results = check(results, 'integ_simpdata_odd_segments', ...
    @() integ_simpdata(0:0.5:2.5, (0:0.5:2.5).^3), 2.5^4/4, 1e-10);
results = check(results, 'trapz_toughness_slide', ...
    @() trapz([0.02 0.05 0.10 0.15 0.20 0.25], [40 37.5 43 52 60 55]), 11.2250, 1e-4);

% --- differentiation -----------------------------------------------------
results = check(results, 'diff_fd_centered4_cos', @() diff_fd(@(x) cos(x), pi/4, pi/12, 'centered', 4), ...
    -sin(pi/4), 1e-3);
results = check(results, 'diff_fd_forward2_cos', @() diff_fd(@(x) cos(x), pi/4, 1e-3, 'forward', 2), ...
    -sin(pi/4), 1e-5);
results = check(results, 'diff_richardson_cos', @() diff_richardson(@(x) cos(x), pi/4, pi/3, pi/6), ...
    -sin(pi/4), 2e-2);
xu = [0 0.3 0.7 1.6 2.0 3.1];
results = check(results, 'diff_data_unequal_quadratic', @() diff_data(xu, xu.^2), 2*xu, 1e-10);
[~, d2] = diff_data(xu, xu.^2);
results = addResult(results, 'diff_data_second_derivative', max(abs(d2 - 2)) < 1e-9, sprintf('max err %.2g', max(abs(d2 - 2))));

% --- ODEs -----------------------------------------------------------------
[~, y] = ode_rk4(@(t,y) y.*t.^3 - 1.5*y, [0 2], 1, 0.5);
results = addResult(results, 'ode_rk4_scalar', abs(y(end) - exp(1))/exp(1) < 0.2, sprintf('y(2)=%.5f exact %.5f', y(end), exp(1)));
[t, v] = ode_euler(@(t,v) 9.81 - 0.25/68.1*v.^2, [0 12], 0, 2);
results = addResult(results, 'ode_euler_bungee_h2', abs(v(end) - 51.6008) < 1e-3 && numel(t) == 7, sprintf('v(12)=%.4f', v(end)));
[~, Y] = ode_rk4(@(t,y) [1.2*y(1) - 0.6*y(1)*y(2); -0.8*y(2) + 0.3*y(1)*y(2)], [0 20], [2; 1], 0.0625);
[~, Y45] = ode45(@(t,y) [1.2*y(1) - 0.6*y(1)*y(2); -0.8*y(2) + 0.3*y(1)*y(2)], [0 20], [2; 1], odeset('RelTol', 1e-8, 'AbsTol', 1e-10));
results = addResult(results, 'ode_rk4_system_vs_ode45', max(abs(Y(end,:) - Y45(end,:))) < 1e-3, ...
    sprintf('rk4 %s ode45 %s', mat2str(Y(end,:), 5), mat2str(Y45(end,:), 5)));

% --- eigenvalues ----------------------------------------------------------
results = check(results, 'eig_power_largest', @() eig_power([10 -5; -5 10]), 15, 1e-6);
results = check(results, 'eig_power_smallest', @() eig_power([10 -5; -5 10], 'smallest'), 5, 1e-6);
[lamP, vP] = eig_power([2 8 10; 8 4 5; 10 5 7]);
results = addResult(results, 'eig_power_chapra_13_2', abs(lamP - max(eig([2 8 10; 8 4 5; 10 5 7]))) < 1e-6 ...
    && norm([2 8 10; 8 4 5; 10 5 7]*vP - lamP*vP) < 1e-5, sprintf('lambda=%.6f', lamP));

% --- linear systems -------------------------------------------------------
[xg, D] = lin_gausspivot([2 -6 -1; -3 -1 7; -8 1 -2], [-38; -34; -20]);
results = addResult(results, 'lin_gausspivot_det_chapra_9_7', norm(xg - [4; 8; -2]) < 1e-9 ...
    && abs(D - det([2 -6 -1; -3 -1 7; -8 1 -2])) < 1e-9, sprintf('x=%s D=%.4f', mat2str(xg', 6), D));
end

function results = check(results, name, fun, expected, tol)
try
    got = fun();
    err = max(abs(got(:) - expected(:)));
    results = addResult(results, name, numel(got) == numel(expected) && err <= tol, ...
        sprintf('got %s expected %s (err %.3g)', mat2str(got(:)', 6), mat2str(expected(:)', 6), err));
catch ME
    results = addResult(results, name, false, ME.message);
end
end

function results = addResult(results, name, pass, msg)
results(end+1).name = name;
results(end).pass = logical(pass);
results(end).msg = msg;
end

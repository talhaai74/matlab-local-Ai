% TOPIC: ode
% TITLE: World population: growth rate from data, then RK4 simulation 1950-2050 with a 5-year step
% SOURCE: Chapra Prob. 22.4
% KEYWORDS: population growth, exponential growth, growth rate, fourth-order runge-kutta, rk4, step size 5 years, simulate, data on a plot
% PROBLEM:
% The world population (millions) was t = 1950 1955 1960 1965 1970 1975 1980 1985 1990 1995 2000,
% p = 2560 2780 3040 3350 3710 4090 4450 4850 5280 5690 6080. (a) Assuming dp/dt = kg p holds, use the
% data from 1950 through 1970 to estimate kg. (b) Use the fourth-order RK method with that kg to
% simulate the world population from 1950 to 2050 with a step size of 5 years. Plot the simulation
% along with the data.
% CHECK: abs(kg - 0.0186) < 5e-4
% CODE:
t = 1950:5:2000;
p = [2560 2780 3040 3350 3710 4090 4450 4850 5280 5690 6080];
%% (a) ln p = ln p0 + kg (t - 1950): slope of ln p for 1950-1970
idx = t <= 1970;
c = polyfit(t(idx) - 1950, log(p(idx)), 1);
kg = c(1);
fprintf('(a) kg = %.5f per year\n', kg);
%% (b) RK4
[ts, ps] = ode_rk4(@(tt, pp) kg*pp, [1950 2050], 2560, 5);
fprintf('(b) simulated population: 2000 -> %.0f million (data 6080), 2050 -> %.0f million\n', ...
    ps(ts == 2000), ps(end));
figure; plot(t, p, 'ko', ts, ps, 'b-'); grid on; xlabel('year'); ylabel('population (millions)');
legend('data', 'RK4, dp/dt = k_g p', 'Location', 'northwest');

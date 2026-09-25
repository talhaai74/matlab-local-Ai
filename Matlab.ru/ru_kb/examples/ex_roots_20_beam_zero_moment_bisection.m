% TOPIC: roots
% TITLE: Position of zero moment in an overhanging beam with ramp, uniform and point loads (bisection)
% SOURCE: Chapra Prob. 5.11 (Fig. P5.11)
% KEYWORDS: beam, moment, zero moment, bisection, singularity functions, distributed load, triangular load, point load, overhang, reactions
% PROBLEM:
% A beam is loaded as shown in Fig. P5.11: a 12 ft beam with a pin support at the left end (x = 0) and a roller
% at x = 10 ft. A distributed load increases linearly from 0 at x = 0 to 100 lb/ft at x = 3 ft and stays at
% 100 lb/ft from x = 3 ft to x = 6 ft; a 100 lb point load acts at the right end (x = 12 ft).
% Use the bisection method to solve for the position inside the beam where there is no moment.
% CHECK: abs(xr - 8.918919) < 1e-4 && abs(RA - 265) < 1e-9 && abs(RB - 285) < 1e-9
% CODE:
sing = @(x, a, n) (x > a).*(x - a).^n;
RB = (0.5*3*100*2 + 3*100*4.5 + 100*12)/10;
RA = 0.5*3*100 + 3*100 + 100 - RB;
M = @(x) RA*x - (100/3)/6*sing(x, 0, 3) + (100/3)/6*sing(x, 3, 3) + 100/2*sing(x, 6, 2) + RB*sing(x, 10, 1);
[xr, fx, ea, iter] = root_bisection(M, 6, 10, 1e-4, 100);
fprintf('Reactions: RA = %.1f lb, RB = %.1f lb\n', RA, RB);
fprintf('Zero moment at x = %.4f ft (%d iterations, ea = %.2e %%)\n', xr, iter, ea);

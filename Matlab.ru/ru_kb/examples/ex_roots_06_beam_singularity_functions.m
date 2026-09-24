% TOPIC: roots
% TITLE: Simply supported beam with singularity functions: zero shear, zero moment, maximum displacement
% SOURCE: CE206 slides 02 pages 16-17 (Exercise 1); Chapra Prob. 5.9 / Endfiles V.m, M.m, O.m
% KEYWORDS: singularity function, macaulay, shear force diagram, bending moment diagram, displacement, beam, zero shear, maximum deflection, 20 kips/ft, 150 kip-ft
% PROBLEM:
% Using singularity functions, the shear, bending moment and displacement along a simply
% supported beam (20 kips/ft over the first 5 ft, 150 kip-ft moment at 7 ft, 15 kips at 8 ft,
% span 10 ft) are:
% V(x) = 20[<x-0>^1 - <x-5>^1] - 15<x-8>^0 - 57
% M(x) = -10[<x-0>^2 - <x-5>^2] + 15<x-8>^1 + 150<x-7>^0 + 57x
% u(x) = -5/6[<x-0>^4 - <x-5>^4] + 15/6<x-8>^3 + 75<x-7>^2 + 57/6 x^3 - 238.25x
% where <x-a>^n = (x-a)^n for x > a and 0 otherwise. Using any root location technique, find
% the points where shear and bending moment equal zero and where the displacement is maximum.
% Also draw the shear force, bending moment and displacement diagrams.
% CHECK: abs(xV - 2.85) < 1e-3 && abs(xM - 5.814) < 1e-3 && abs(xU - 3.9357) < 1e-3
% CODE:
sg = @(x, a, n) util_sing(x, a, n);            % singularity function <x-a>^n
V = @(x) 20*(sg(x,0,1) - sg(x,5,1)) - 15*sg(x,8,0) - 57;
M = @(x) -10*(sg(x,0,2) - sg(x,5,2)) + 15*sg(x,8,1) + 150*sg(x,7,0) + 57*x;
u = @(x) -5/6*(sg(x,0,4) - sg(x,5,4)) + 15/6*sg(x,8,3) + 75*sg(x,7,2) + 57/6*x.^3 - 238.25*x;
du = @(x) -10/3*(sg(x,0,3) - sg(x,5,3)) + 15/2*sg(x,8,2) + 150*sg(x,7,1) + 57/2*x.^2 - 238.25;  % slope u'(x)
fprintf('V, M, u of the beam written with singularity functions (x in ft)\n');

xV = fzero(V, [0 5]);          % shear changes sign between 0 and 5 ft
xM = fzero(M, [5 7]);          % moment changes sign between 5 and 7 ft
xU = fzero(du, [2 6]);         % maximum displacement where du/dx = 0
fprintf('Shear      V = 0 at x = %.4f ft\n', xV);
fprintf('Moment     M = 0 at x = %.4f ft\n', xM);
fprintf('Max displacement at x = %.4f ft, u = %.4f (units of EI*u)\n', xU, u(xU));

x = linspace(0, 10, 501);
figure;
subplot(3,1,1); plot(x, V(x), 'b', 'LineWidth', 1.5); grid on; ylabel('V (kips)'); title('Shear force diagram');
subplot(3,1,2); plot(x, M(x), 'r', 'LineWidth', 1.5); grid on; ylabel('M (kip-ft)'); title('Bending moment diagram');
subplot(3,1,3); plot(x, u(x), 'k', 'LineWidth', 1.5); grid on; ylabel('u'); xlabel('x (ft)'); title('Displacement');

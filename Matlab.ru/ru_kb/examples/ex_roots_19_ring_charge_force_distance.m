% TOPIC: roots
% TITLE: Distance from a charged ring where the force on a point charge is 1.25 N (two roots)
% SOURCE: Chapra Prob. 5.19
% KEYWORDS: charge, ring, conductor, force, coulomb, distance, e0, permittivity, two roots, fzero
% PROBLEM:
% A total charge Q is uniformly distributed around a ring-shaped conductor with radius a. A charge q is at a
% distance x from the center of the ring. The force is F = (1/(4 pi e0)) q Q x/(x^2 + a^2)^(3/2), where
% e0 = 8.9e-12 C^2/(N m^2). Find the distance x where the force is 1.25 N if q and Q are 2e-5 C for a ring
% with a radius of 0.85 m.
% CHECK: abs(x1 - 0.2410427) < 1e-6 && abs(x2 - 1.2912796) < 1e-6
% CODE:
e0 = 8.9e-12; q = 2e-5; Q = 2e-5; a = 0.85; F = 1.25;
f = @(x) q*Q*x./(4*pi*e0*(x.^2 + a^2).^(3/2)) - F;
xm = a/sqrt(2);
x1 = fzero(f, [0 xm]);
x2 = fzero(f, [xm 10]);
fprintf('The force is %.2f N at x = %.4f m and at x = %.4f m (maximum force at x = %.4f m)\n', F, x1, x2, xm);

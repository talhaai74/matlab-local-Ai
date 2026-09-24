% TOPIC: eigen
% TITLE: Buckling of a slender column: finite-difference eigenvalue problem (polynomial method, eig, power method)
% SOURCE: Chapra Prob. 13.10
% KEYWORDS: buckling, slender column, axial load, eigenvalue, finite difference, p^2 = P/(EI), polynomial method, characteristic polynomial, eig, power method, euler load
% PROBLEM:
% An axially loaded wooden column has E = 10e9 Pa, I = 1.25e-5 m^4 and L = 3 m. With d2y/dx2 + p^2 y = 0,
% p^2 = P/(EI), and a centered finite difference for five segments (four interior nodes), the system is
% [2 -1 0 0; -1 2 -1 0; 0 -1 2 -1; 0 0 -1 2] y = dx^2 p^2 y. (a) Use the polynomial method to determine
% the eigenvalues, (b) use eig to determine the eigenvalues and eigenvectors, (c) use the power method to
% determine the largest eigenvalue. Give the buckling loads P = p^2 EI and compare the first with the
% Euler load pi^2 EI/L^2.
% CHECK: abs(P(1) - 132627.09) < 0.1 && abs(Peuler - 137077.84) < 0.1
% CODE:
E = 10e9; I = 1.25e-5; L = 3; nseg = 5;
dx = L/nseg;
B = [2 -1 0 0; -1 2 -1 0; 0 -1 2 -1; 0 0 -1 2];
A = B/dx^2;                               % A*y = p^2*y
%% (a) polynomial method
c = poly(A);
p2poly = sort(roots(c));
fprintf('(a) characteristic polynomial roots p^2 = %s\n', mat2str(p2poly', 6));
%% (b) eig
[V, D] = eig(A);
[p2, idx] = sort(diag(D)); V = V(:, idx);
P = p2*E*I;
fprintf('(b) p^2 = %s\n    buckling loads P = %s kN\n', mat2str(p2', 6), mat2str(P'/1e3, 6));
%% (c) power method (largest)
lmax = eig_power(A);
fprintf('(c) power method largest p^2 = %.4f\n', lmax);
Peuler = pi^2*E*I/L^2;
fprintf('First buckling load %.2f kN vs Euler load %.2f kN (%.1f %% low with 5 segments)\n', P(1)/1e3, Peuler/1e3, (Peuler - P(1))/Peuler*100);

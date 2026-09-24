% TOPIC: bvp
% TITLE: Finite-difference method for a heated rod (tridiagonal system, dx = 2 m) vs the analytical solution
% SOURCE: CE206 slides 06 pages 21-22; Chapra Example 24.5
% KEYWORDS: finite difference method, finite-difference, boundary value problem, heated rod, convection, tridiagonal, interior nodes, dirichlet boundary conditions, delta x
% PROBLEM:
% Use the finite-difference approach with dx = 2 m to solve d2T/dx2 + h'(Tinf - T) = 0 for a 10-m rod
% with h' = 0.05 m^-2, Tinf = 200 K, T(0) = 300 K and T(10) = 400 K. Write the tridiagonal system
% -T(i-1) + (2 + h' dx^2) T(i) - T(i+1) = h' dx^2 Tinf, solve it, and compare with the analytical solution.
% CHECK: norm(T' - [283.2660 283.1853 299.7416 336.2462]) < 1e-3
% CODE:
hp = 0.05; Ta = 200; T0 = 300; TL = 400; L = 10; dx = 2;
n = L/dx - 1;                                % interior nodes
A = zeros(n); b = hp*dx^2*Ta*ones(n, 1);
for i = 1:n
    A(i,i) = 2 + hp*dx^2;
    if i > 1, A(i,i-1) = -1; end
    if i < n, A(i,i+1) = -1; end
end
b(1) = b(1) + T0; b(n) = b(n) + TL;          % known boundary temperatures go to the right-hand side
T = A\b;
x = (dx:dx:L-dx)';
lam = sqrt(hp);
c = [1 1; exp(lam*L) exp(-lam*L)]\[T0 - Ta; TL - Ta];
Tex = Ta + c(1)*exp(lam*x) + c(2)*exp(-lam*x);
fprintf('%6s %12s %12s\n', 'x (m)', 'T FD (K)', 'T exact (K)');
fprintf('%6g %12.4f %12.4f\n', [x T Tex]');
[xr, Tr] = ode_fdbvp(0, -hp, -hp*Ta, [0 L], T0, TL, n);   % same system with ru_lib
fprintf('ru_lib ode_fdbvp agrees: max difference %.1e\n', max(abs(Tr(2:end-1) - T)));
xx = linspace(0, L, 100);
figure; plot([0; x; L], [T0; T; TL], 'o', xx, Ta + c(1)*exp(lam*xx) + c(2)*exp(-lam*xx), '-'); grid on;
xlabel('x (m)'); ylabel('T (K)'); legend('finite difference', 'analytical', 'Location', 'northwest');

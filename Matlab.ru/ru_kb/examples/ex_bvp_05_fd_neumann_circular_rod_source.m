% TOPIC: bvp
% TITLE: Finite differences with a derivative (Neumann) boundary: temperature in a circular rod with a heat source
% SOURCE: CE206 slides 06 pages 23-24 (practice problem)
% KEYWORDS: finite difference, neumann boundary condition, derivative boundary condition, ghost node, circular rod, heat source, radius, dT/dr = 0, S = 1, 10, 20
% PROBLEM:
% Over 0 <= r <= 1 solve the nondimensional ODE d2T/dr2 + (1/r) dT/dr + S = 0 with T(1) = 1 and
% dT/dr = 0 at r = 0, using the finite-difference method, for the temperature distribution in a circular
% rod with internal heat source S. For S = 1, 10 and 20 plot the temperature versus radius.
% CHECK: max(abs(Tall(:,3) - (1 + 20*(1 - r.^2)/4))) < 1e-9
% CODE:
n = 20;                              % segments; nodes r0 = 0 ... rn = 1
dr = 1/n;
r = (0:n)'*dr;
Svals = [1 10 20];
Tall = zeros(n+1, 3);
for s = 1:3
    S = Svals(s);
    A = zeros(n); b = zeros(n, 1);   % unknowns T0 ... T(n-1); T(n) = 1 is known
    % node 0: (1/r) dT/dr -> d2T/dr2 as r -> 0, so 2 T'' + S = 0; ghost node T(-1) = T(1)
    A(1,1) = -4/dr^2; A(1,2) = 4/dr^2; b(1) = -S;
    for i = 2:n
        ri = r(i);
        A(i,i-1) = 1/dr^2 - 1/(2*ri*dr);
        A(i,i)   = -2/dr^2;
        if i < n
            A(i,i+1) = 1/dr^2 + 1/(2*ri*dr);
        else
            b(i) = -(1/dr^2 + 1/(2*ri*dr))*1;   % T(n) = 1 moves to the right-hand side
        end
        b(i) = b(i) - S;
    end
    Tall(:,s) = [A\b; 1];
    fprintf('S = %2g: T(0) = %.4f (analytical 1 + S/4 = %.4f)\n', S, Tall(1,s), 1 + S/4);
end
figure; plot(r, Tall, 'LineWidth', 1.3); grid on; xlabel('r'); ylabel('T');
legend('S = 1', 'S = 10', 'S = 20'); title('Circular rod with internal heat source');

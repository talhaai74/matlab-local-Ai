% TOPIC: linear
% TITLE: Four springs in series depressed by a force: displacements from equilibrium equations
% SOURCE: CE206 slides 03 page 15 (Exercise 4) / Endfiles spring.m
% KEYWORDS: springs in series, spring constants, force balance, equilibrium, displacement, stiffness matrix, k1, k2, k3, k4
% PROBLEM:
% Four springs in series (k1 at the fixed base, then k2, k3, k4) are depressed with a force of
% F = 1500 kg (weight, g = 9.81 m/s^2) applied at the top. Develop the force balance equations at
% equilibrium and solve for the displacements x1..x4 if k1 = 100, k2 = 50, k3 = 80, k4 = 200 N/m.
% CHECK: norm(x - F*cumsum(1./[100; 50; 80; 200])) < 1e-6
% CODE:
k = [100 50 80 200];            % N/m, spring 1 at the base
F = 1500*9.81;                  % N
% node i between spring i and spring i+1:  k_i (x_i - x_{i-1}) - k_{i+1} (x_{i+1} - x_i) = 0, top node carries F
K = [k(1)+k(2)  -k(2)        0         0;
     -k(2)       k(2)+k(3)  -k(3)      0;
      0         -k(3)        k(3)+k(4) -k(4);
      0          0          -k(4)      k(4)];
b = [0; 0; 0; F];
x = K\b;
fprintf('Stiffness matrix K:\n'); disp(K);
for i = 1:4
    fprintf('x%d = %10.4f m\n', i, x(i));
end
fprintf('Check: each spring carries F: %s N\n', mat2str(k(:).*diff([0; x]), 6));

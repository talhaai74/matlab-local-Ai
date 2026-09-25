% TOPIC: linear
% TITLE: Truss with 10 unknown member forces and reactions from 10 equilibrium equations
% SOURCE: Chapra Prob. 9.15 (Fig. P9.15)
% KEYWORDS: truss, member forces, reactions, equilibrium, ten unknowns, AB BC AD BD CD DE CE Ax Ay Ey, linear system
% PROBLEM:
% A truss is loaded as shown in Fig. P9.15. Using the following set of equations, solve for the 10 unknowns
% AB, BC, AD, BD, CD, DE, CE, Ax, Ay and Ey:
% Ax + AD = 0, Ay + AB = 0, 74 + BC + (3/5)BD = 0, -AB - (4/5)BD = 0, -BC + (3/5)CE = 0,
% -24 - CD - (4/5)CE = 0, -AD + DE - (3/5)BD = 0, CD + (4/5)BD = 0, -DE - (3/5)CE = 0, Ey + (4/5)CE = 0.
% CHECK: norm(A*x - b) < 1e-9 && norm(x' - [112/3 -46 74 -140/3 112/3 46 -230/3 -74 -112/3 184/3]) < 1e-9
% CODE:
%     AB    BC    AD    BD     CD    DE    CE     Ax  Ay  Ey
A = [ 0     0     1     0      0     0     0      1   0   0;
      1     0     0     0      0     0     0      0   1   0;
      0     1     0     3/5    0     0     0      0   0   0;
     -1     0     0    -4/5    0     0     0      0   0   0;
      0    -1     0     0      0     0     3/5    0   0   0;
      0     0     0     0     -1     0    -4/5    0   0   0;
      0     0    -1    -3/5    0     1     0      0   0   0;
      0     0     0     4/5    1     0     0      0   0   0;
      0     0     0     0      0    -1    -3/5    0   0   0;
      0     0     0     0      0     0     4/5    0   0   1];
b = [0; 0; -74; 0; 0; 24; 0; 0; 0; 0];
x = A\b;
names = {'AB', 'BC', 'AD', 'BD', 'CD', 'DE', 'CE', 'Ax', 'Ay', 'Ey'};
for k = 1:10
    fprintf('%-3s = %10.4f kN\n', names{k}, x(k));
end

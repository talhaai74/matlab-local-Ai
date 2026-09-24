% TOPIC: linear
% TITLE: Statically determinate truss by LU factorization, then a wind load case with the same L and U
% SOURCE: CE206 slides 03 pages 10-12 (Exercise 1); Chapra Example 8.2 / Endfiles Truss.m
% KEYWORDS: truss, bar forces, reactions, lu factorization, lu decomposition, 1000 lb, 30 degrees, 60 degrees, tension, compression, wind load, forcing vector
% PROBLEM:
% Find all the bar forces F1, F2, F3 and the external reactions H2, V2, V3 of the truss with
% nodes 1 (top), 2 (left, pin) and 3 (right, roller), angles 30 deg at node 2, 60 deg at node 3,
% 90 deg at node 1 and a 1000 lb downward load at node 1:
% Node 1: -F1 cos30 + F3 cos60 = 0,   -F1 sin30 - F3 sin60 - 1000 = 0
% Node 2: F2 + F1 cos30 + H2 = 0,     F1 sin30 + V2 = 0
% Node 3: -F2 - F3 cos60 = 0,         F3 sin60 + V3 = 0
% Use LU factorization. Then analyze the same truss with two horizontal 1000 lb wind forces
% (right-hand side [1000 0 1000 0 0 0]) reusing L and U.
% CHECK: norm(x - [-500; 433.01; -866.03; 0; 250; 750]) < 0.05
% CHECK: norm(xw - [866.03; 250; -500; -2000; -433.01; 433.01]) < 0.05
% CODE:
c30 = cosd(30); s30 = sind(30); c60 = cosd(60); s60 = sind(60);
%      F1    F2    F3    H2  V2  V3
A = [  c30,  0,  -c60,   0,  0,  0;     % node 1 horizontal (written as c30*F1 - c60*F3 = 0)
       s30,  0,   s60,   0,  0,  0;     % node 1 vertical  (s30*F1 + s60*F3 = -1000)
      -c30, -1,   0,    -1,  0,  0;     % node 2 horizontal
      -s30,  0,   0,     0, -1,  0;     % node 2 vertical
       0,    1,   c60,   0,  0,  0;     % node 3 horizontal
       0,    0,  -s60,   0,  0, -1];    % node 3 vertical
b = [0; -1000; 0; 0; 0; 0];
[L, U] = lu(A);                          % factor once
d = L\b;  x = U\d;
names = {'F1', 'F2', 'F3', 'H2', 'V2', 'V3'};
fprintf('Vertical 1000 lb load:\n');
for k = 1:6
    tc = '';
    if k <= 3
        tc = ' (tension)';
        if x(k) < 0, tc = ' (compression)'; end
    end
    fprintf('  %-3s = %10.3f lb%s\n', names{k}, x(k), tc);
end
bw = [1000; 0; 1000; 0; 0; 0];           % wind case: only the forcing vector changes
xw = U\(L\bw);
fprintf('Wind load (same L and U):\n');
for k = 1:6
    fprintf('  %-3s = %10.3f lb\n', names{k}, xw(k));
end
fprintf('Checks: norm(A*x - b) = %.1e, norm(A*xw - bw) = %.1e\n', norm(A*x - b), norm(A*xw - bw));

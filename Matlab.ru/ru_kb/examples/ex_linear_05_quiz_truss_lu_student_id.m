% TOPIC: linear
% TITLE: Quiz: 2D truss with loads X kN and X/2 kN solved by LU factorization (tension/compression table)
% SOURCE: CE206 Final Quiz (18 batch) Set A, Q3
% KEYWORDS: truss, lu factorization, fab, fbc, fcd, fda, fbd, ay, ax, cy, member forces, tension, compression, student id, last three digits, quiz, tabular format
% PROBLEM:
% Solve the 2D truss (A at (0,0) pin, D at (3,0), C at (6,0) roller, B at (3,4) m; members AB, BC,
% CD, DA, BD; horizontal load X kN to the left at B and X/2 kN downward at D) using LU factorization.
% Find FAB, FBC, FCD, FDA, FBD, Ay, Ax and Cy and mention if the member forces are in tension or
% compression. Report all values in a neat tabular format. X = last three digits of your student ID
% (for example ID = 1904032 gives X = 032 = 32).
% CHECK: norm(x' - [-36.6667 16.6667 -10 -10 16 29.3333 32 -13.3333]) < 1e-3
% CODE:
X = 32;                                   % last three digits of the student ID (change this)
c = 3/5; s = 4/5;                         % cos and sin of AB and BC (3-4-5 triangle)
%      FAB  FBC  FCD  FDA  FBD  Ay  Ax  Cy
A = [  c,   0,   0,   1,   0,   0,   1,   0;   % joint A, x
       s,   0,   0,   0,   0,   1,   0,   0;   % joint A, y
      -c,   c,   0,   0,   0,   0,   0,   0;   % joint B, x (= X)
      -s,  -s,   0,   0,  -1,   0,   0,   0;   % joint B, y
       0,  -c,  -1,   0,   0,   0,   0,   0;   % joint C, x
       0,   s,   0,   0,   0,   0,   0,   1;   % joint C, y
       0,   0,   1,  -1,   0,   0,   0,   0;   % joint D, x
       0,   0,   0,   0,   1,   0,   0,   0];  % joint D, y (= X/2)
b = [0; 0; X; 0; 0; 0; 0; X/2];
[L, U] = lu(A);
d = L\b;
x = U\d;
names = {'FAB', 'FBC', 'FCD', 'FDA', 'FBD', 'Ay', 'Ax', 'Cy'};
fprintf('X = %g kN\n%-6s %12s   %s\n', X, 'Force', 'Value (kN)', 'Nature');
for k = 1:8
    if k <= 5
        if x(k) >= 0, nat = 'Tension'; else, nat = 'Compression'; end
    else
        nat = 'Reaction';
    end
    fprintf('%-6s %12.4f   %s\n', names{k}, x(k), nat);
end
fprintf('Check: norm(A*x - b) = %.2e\n', norm(A*x - b));

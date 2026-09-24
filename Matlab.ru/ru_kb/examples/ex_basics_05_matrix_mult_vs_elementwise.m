% TOPIC: basics
% TITLE: Matrix multiplication versus elementwise (dot) operators
% SOURCE: Slides 01, pages 20-21 (standard matrix multiplication; elementwise operators)
% KEYWORDS: matrix multiplication, elementwise operator, dot operator, broadcasting, implicit expansion, dimension mismatch
% PROBLEM:
% Compute the standard matrix product [1 2 3]*[4;2;1] (1x3 times 3x1) and
% [1 1 1;2 2 2;3 3 3]*[1 2 3;1 2 3;1 2 3] (3x3 times 3x3).
% Then compare with the elementwise operator .*: what does [1 2 3].*[4;2;1]
% do on a current MATLAB (R2016b or later)? What about [1;2;3].*[4;2;1],
% [1 1 1;2 2 2;3 3 3].*[1 2 3;1 2 3;1 2 3], and [1 2;3 4].^2?
% CHECK: prodA == 11
% CHECK: isequal(prodB, [3 6 9; 6 12 18; 9 18 27])
% CHECK: isequal(broadcastC, [4 8 12; 2 4 6; 1 2 3])
% CHECK: isequal(elemD, [4;4;3])
% CHECK: isequal(elemE, [1 2 3; 2 4 6; 3 6 9])
% CHECK: isequal(elemF, [1 4; 9 16])
% CODE:
rowv = [1 2 3];
colv = [4;2;1];
prodA = rowv*colv;                 % 1x3 * 3x1 -> 1x1 (matrix multiplication)
M1 = [1 1 1; 2 2 2; 3 3 3];
M2 = [1 2 3; 1 2 3; 1 2 3];
prodB = M1*M2;                     % 3x3 * 3x3 -> 3x3
fprintf('[1 2 3]*[4;2;1] = %d\n', prodA);
disp('M1*M2 ='); disp(prodB);

% Since R2016b, elementwise operators implicitly broadcast a singleton
% dimension, so 1x3 .* 3x1 no longer errors: it expands to a 3x3 result.
broadcastC = rowv .* colv;         % 1x3 .* 3x1 -> 3x3 (implicit expansion)
elemD = [1;2;3] .* colv;           % 3x1 .* 3x1, matching sizes
elemE = M1 .* M2;                  % 3x3 .* 3x3, matching sizes
elemF = [1 2; 3 4].^2;             % elementwise power, any size
disp('rowv .* colv (broadcast, R2016b+) ='); disp(broadcastC);
disp('[1;2;3] .* colv ='); disp(elemD);
disp('M1 .* M2 ='); disp(elemE);
disp('[1 2;3 4].^2 ='); disp(elemF);

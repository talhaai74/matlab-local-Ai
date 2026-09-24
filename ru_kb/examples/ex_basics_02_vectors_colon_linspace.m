% TOPIC: basics
% TITLE: Row/column vectors, the colon operator, and linspace
% SOURCE: Slides 01, pages 12-13 (vector creation; colon operator; linspace)
% KEYWORDS: row vector, column vector, colon operator, linspace, size, length, vector creation
% PROBLEM:
% Create the row vector a = [1 2 3 4 5] and the column vector b = [2;4;6;8;10].
% Report size(a) and length(a).
% Using the colon operator a:b:c, evaluate 3:7, 0.32:0.1:0.6 and -1.4:-0.3:-2.
% Also build 11 equispaced points between 0 and 1 with linspace.
% CHECK: isequal(a, [1 2 3 4 5]) && isequal(b, [2;4;6;8;10])
% CHECK: isequal(sizeA, [1 5]) && lenA == 5
% CHECK: isequal(c1, [3 4 5 6 7])
% CHECK: numel(c2) == 3 && abs(c2(end) - 0.52) < 1e-9
% CHECK: numel(c3) == 3 && abs(c3(end) - (-2)) < 1e-9
% CHECK: numel(lv) == 11 && abs(lv(1)) < 1e-12 && abs(lv(end) - 1) < 1e-12
% CODE:
a = [1 2 3 4 5];
b = [2;4;6;8;10];
sizeA = size(a);
lenA = length(a);
fprintf('a = row vector, size(a) = [%d %d], length(a) = %d\n', sizeA(1), sizeA(2), lenA);
fprintf('b = column vector with %d rows\n', size(b,1));

c1 = 3:7;
c2 = 0.32:0.1:0.6;
c3 = -1.4:-0.3:-2;
lv = linspace(0,1,11);
disp('c1 = 3:7'); disp(c1);
disp('c2 = 0.32:0.1:0.6'); disp(c2);
disp('c3 = -1.4:-0.3:-2'); disp(c3);
fprintf('linspace(0,1,11) has %d points from %.4f to %.4f\n', numel(lv), lv(1), lv(end));

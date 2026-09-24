% TOPIC: basics
% TITLE: Elementwise relational and logical operators on a matrix
% SOURCE: Slides 01, page 37 (logical and relational operators)
% KEYWORDS: relational operator, logical operator, elementwise comparison, and or, true false
% PROBLEM:
% Given x = [-2.0000 3.1416 5.0000; -5.0000 -3.0000 -1.0000], evaluate
% x > 3 & x < 4, and x > 3 | x == -3.
% CHECK: isequal(r1, logical([0 1 0; 0 0 0]))
% CHECK: isequal(r2, logical([0 1 1; 0 1 0]))
% CODE:
x = [-2.0000 3.1416 5.0000; -5.0000 -3.0000 -1.0000];
r1 = x > 3 & x < 4;
r2 = x > 3 | x == -3;
disp('x > 3 & x < 4 ='); disp(r1);
disp('x > 3 | x == -3 ='); disp(r2);
fprintf('true is represented as 1, false as 0 in MATLAB logical arrays\n');

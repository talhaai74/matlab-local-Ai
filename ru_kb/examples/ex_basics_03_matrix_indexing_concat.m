% TOPIC: basics
% TITLE: Matrix indexing, submatrices, and block concatenation
% SOURCE: Slides 01, pages 14-15 (matrix creation/indexing; array concatenation)
% KEYWORDS: matrix indexing, submatrix, row column extraction, block matrix, concatenation
% PROBLEM:
% Enter the matrix A = [1 2 3; 4 5 6; 7 8 9]. Extract A(2,3), the submatrix
% A(2:3,1:2), rows 1 and 3 with A([1,3],:), and the first column A(:,1).
% Given a = [1 2; 3 4], build cat_a = [a 2*a; 3*a 4*a; 5*a 6*a].
% CHECK: elem23 == 6
% CHECK: isequal(sub1, [4 5; 7 8])
% CHECK: isequal(sub2, [1 2 3; 7 8 9])
% CHECK: isequal(col1, [1;4;7])
% CHECK: isequal(cat_a, [1 2 2 4; 3 4 6 8; 3 6 4 8; 9 12 12 16; 5 10 6 12; 15 20 18 24])
% CODE:
A = [1 2 3; 4 5 6; 7 8 9];
elem23 = A(2,3);
sub1 = A(2:3,1:2);
sub2 = A([1,3],:);
col1 = A(:,1);
fprintf('A(2,3) = %d\n', elem23);
disp('A(2:3,1:2) ='); disp(sub1);
disp('A([1,3],:) ='); disp(sub2);
disp('A(:,1)     ='); disp(col1);

a = [1 2; 3 4];
cat_a = [a 2*a; 3*a 4*a; 5*a 6*a];
disp('cat_a = [a 2a; 3a 4a; 5a 6a] ='); disp(cat_a);

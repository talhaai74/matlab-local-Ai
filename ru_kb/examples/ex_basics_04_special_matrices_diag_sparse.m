% TOPIC: basics
% TITLE: Special matrices: zeros/ones/eye, diag, and sparse/full
% SOURCE: Slides 01, pages 17-18 (diagonal matrices; sparse matrices)
% KEYWORDS: zeros, ones, eye, rand, diag, diagonal matrix, sparse matrix, full matrix
% PROBLEM:
% Given the vector d = [-3 4 2], construct the diagonal matrix D = diag(d), and
% recover the diagonal back into a vector with diag(D).
% Build a 5-by-4 sparse matrix S with S(1,2)=10, S(3,3)=11, S(5,4)=12 using
% i = [1,3,5], j = [2,3,4], v = [10 11 12], then convert it with T = full(S).
% CHECK: isequal(D, [-3 0 0; 0 4 0; 0 0 2])
% CHECK: isequal(dback, [-3;4;2])
% CHECK: isequal(T, [0 10 0 0; 0 0 0 0; 0 0 11 0; 0 0 0 0; 0 0 0 12])
% CHECK: nnz(S) == 3 && isequal(size(S), [5 4])
% CHECK: isequal(size(Z), [2 3]) && isequal(I3, eye(3))
% CODE:
d = [-3 4 2];
D = diag(d);
dback = diag(D);
disp('D = diag([-3 4 2]) ='); disp(D);
disp('diag(D) back to a vector ='); disp(dback');

i = [1, 3, 5];
j = [2, 3, 4];
v = [10 11 12];
S = sparse(i,j,v);
T = full(S);
fprintf('S is %dx%d with %d nonzero entries\n', size(S,1), size(S,2), nnz(S));
disp('T = full(S) ='); disp(T);

Z = zeros(2,3);
O = ones(3,1);
I3 = eye(3);
fprintf('zeros(2,3) is %dx%d, ones(3,1) is %dx%d, eye(3) is %dx%d\n', ...
    size(Z,1), size(Z,2), size(O,1), size(O,2), size(I3,1), size(I3,2));

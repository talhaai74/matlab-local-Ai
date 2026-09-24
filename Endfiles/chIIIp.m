%chapra problem 13.5 page 357

K = [4 -4 0;
    -4 8 -4;
    0 -4 8];
M = diag([1 1 1]);
A = M\K;
[v,d] = eig(A)
omega2 = diag(d)
%chapra problem 13.4 page 357

K = [50 -35 0 ;
    -35 70 -35;
    0 -35 50];
M = diag([1.5 1.5 1.5]);
A = M\K;
[v,d] = eig(A)
omega = diag(d)
% TOPIC: linear
% TITLE: Three masses and four springs: accelerations from the tridiagonal k/m matrix
% SOURCE: Chapra Prob. 8.11 (Fig. P8.11)
% KEYWORDS: mass spring system, three masses, four springs, acceleration, tridiagonal matrix, k/m matrix, equations of motion, displacement
% PROBLEM:
% Consider the three mass-four spring system. The equations of motion are
% x1'' + ((k1 + k2)/m1) x1 - (k2/m1) x2 = 0, x2'' - (k2/m2) x1 + ((k2 + k3)/m2) x2 - (k3/m2) x3 = 0,
% x3'' - (k3/m3) x2 + ((k3 + k4)/m3) x3 = 0, where k1 = k4 = 10 N/m, k2 = k3 = 30 N/m and m1 = m2 = m3 = 1 kg.
% In matrix form 0 = {acceleration vector} + [k/m matrix]{displacement vector x}. At a specific time where
% x1 = 0.05 m, x2 = 0.04 m and x3 = 0.03 m this forms a tridiagonal matrix. Use MATLAB to solve for the
% acceleration of each mass.
% CHECK: norm(acc - [-0.8; 0; 0]) < 1e-12
% CODE:
k1 = 10; k2 = 30; k3 = 30; k4 = 10;
m1 = 1; m2 = 1; m3 = 1;
K = [(k1+k2)/m1  -k2/m1       0;
     -k2/m2      (k2+k3)/m2  -k3/m2;
      0          -k3/m3      (k3+k4)/m3];
x = [0.05; 0.04; 0.03];
acc = -K*x

% TOPIC: linear
% TITLE: Five reactors linked by pipes (Fig. P8.9 flows 5, 8, 3, 1, ...): steady-state concentrations
% SOURCE: Chapra Prob. 8.9 (4th ed., Fig. P8.9)
% KEYWORDS: reactors, mass balance, flow, concentration, pipes, steady state, matrix form, five reactors
% PROBLEM:
% Five reactors are linked by pipes (Fig. P8.9). The mass flow through each pipe is flow Q times concentration c.
% At steady state the mass flow into and out of each reactor is equal, e.g. Q01 c01 + Q31 c3 = Q15 c1 + Q12 c1.
% Flows: Q01 = 5 with c01 = 10, Q03 = 8 with c03 = 20, Q12 = 3, Q15 = 3, Q23 = 1, Q24 = 1, Q25 = 1, Q31 = 1,
% Q34 = 8, Q44 = 11 (out), Q54 = 2, Q55 = 2 (out). Write mass balances for the remaining reactors, express the
% equations in matrix form and use MATLAB to solve for the concentrations in each reactor.
% CHECK: norm(A*c - b) < 1e-9 && abs(c(1) - 11.509434) < 1e-6 && abs(c(3) - 19.056604) < 1e-6 && abs(c(4) - 16.998285) < 1e-6
% CODE:
Q01 = 5; c01 = 10; Q03 = 8; c03 = 20; Q12 = 3; Q15 = 3; Q23 = 1; Q24 = 1; Q25 = 1;
Q31 = 1; Q34 = 8; Q44 = 11; Q54 = 2; Q55 = 2;
A = [ Q12+Q15   0              -Q31        0     0;
     -Q12       Q23+Q24+Q25     0          0     0;
      0        -Q23             Q31+Q34    0     0;
      0        -Q24            -Q34        Q44  -Q54;
     -Q15      -Q25             0          0     Q54+Q55];
b = [Q01*c01; 0; Q03*c03; 0; 0];
c = A\b;
for k = 1:5
    fprintf('c%d = %.4f\n', k, c(k));
end

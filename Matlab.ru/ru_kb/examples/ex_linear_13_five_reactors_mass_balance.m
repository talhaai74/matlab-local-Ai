% TOPIC: linear
% TITLE: Steady-state concentrations in five reactors linked by pipes (mass balances)
% SOURCE: Chapra Prob. 8.9 in an earlier edition (other flows than the 4th-edition Fig. P8.9)
% KEYWORDS: reactors, mass balance, flow, concentration, pipes, steady state, mixing
% PROBLEM:
% Five reactors are linked by pipes. Flows (m^3/min): Q01 = 6 (c01 = 20), Q03 = 7 (c03 = 50),
% Q12 = 4, Q15 = 5, Q23 = 2, Q24 = 1, Q25 = 1, Q31 = 3, Q34 = 6, Q44 = 9 (out), Q54 = 2, Q55 = 4 (out).
% Mass flow in each pipe = Q*c of the reactor it leaves. Write mass balances for the reactors in
% matrix form and solve for the concentrations c1..c5 (mg/m^3).
% CHECK: norm(A*c - b) < 1e-9 && norm(c' - [28.4 28.4 45.2 39.6 28.4]) < 1e-9
% CODE:
Q01 = 6; c01 = 20; Q03 = 7; c03 = 50; Q12 = 4; Q15 = 5; Q23 = 2; Q24 = 1; Q25 = 1;
Q31 = 3; Q34 = 6; Q44 = 9; Q54 = 2; Q55 = 4;
% in = out for each reactor
A = [ Q12+Q15   0              -Q31        0     0;          % reactor 1
     -Q12       Q23+Q24+Q25     0          0     0;          % reactor 2
      0        -Q23             Q31+Q34    0     0;          % reactor 3
      0        -Q24            -Q34        Q44  -Q54;        % reactor 4
     -Q15      -Q25             0          0     Q54+Q55];   % reactor 5
b = [Q01*c01; 0; Q03*c03; 0; 0];
c = A\b;
for k = 1:5
    fprintf('c%d = %9.4f mg/m^3\n', k, c(k));
end
fprintf('Check: residual = %.2e\n', norm(A*c - b));

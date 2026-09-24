% TOPIC: linear
% TITLE: Three blocks connected by a cord on a 45 degree incline: acceleration and tensions
% SOURCE: CE206 slides 03 page 13 (Exercise 2) / Endfiles Slidingbody_system_oflineareqn.m
% KEYWORDS: sliding body, inclined plane, friction factor, tension in the cable, acceleration, newton's second law, free body diagram, blocks connected by a cord
% PROBLEM:
% Three blocks (m1 = 100 kg, m2 = 50 kg, m3 = 25 kg) are connected by a weightless cord and rest on
% a plane inclined at 45 degrees. The friction factor is 0.25 for block 1 and 0.375 for blocks 2 and 3
% (g = 9.8 m/s^2). Develop the set of three simultaneous equations and solve for the acceleration
% and the tensions T1 (between blocks 1 and 2) and T2 (between blocks 2 and 3).
% CHECK: norm(x - [100 1 0; 50 -1 1; 25 0 -1]\[519.723; 216.55; 108.276]) < 0.01
% CODE:
m = [100 50 25]; mu = [0.25 0.375 0.375]; g = 9.8; th = 45;
w = m*g.*(sind(th) - mu*cosd(th));      % driving force of each block (weight component - friction)
% Newton's 2nd law down the slope:  m1 a + T1 = w1,  m2 a - T1 + T2 = w2,  m3 a - T2 = w3
A = [m(1)  1  0;
     m(2) -1  1;
     m(3)  0 -1];
b = w(:);
x = A\b;
fprintf('Equations: 100a + T1 = %.3f,  50a - T1 + T2 = %.3f,  25a - T2 = %.3f\n', b);
fprintf('Acceleration a = %.4f m/s^2\nTension T1 = %.4f N\nTension T2 = %.4f N\n', x);
fprintf('Check: residual = %.2e\n', norm(A*x - b));

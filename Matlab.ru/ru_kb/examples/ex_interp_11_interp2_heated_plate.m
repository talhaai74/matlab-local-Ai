% TOPIC: interpolation
% TITLE: Two-dimensional interpolation of plate temperatures with interp2 (bilinear and spline)
% SOURCE: Chapra Prob. 17.20
% KEYWORDS: interp2, two-dimensional interpolation, bilinear, heated plate, temperature grid, meshgrid
% PROBLEM:
% Temperatures (C) measured on a heated plate at x = 0 2 4 6 8 and y = 0 2 4 6 8:
% y=0: 100 90 80 70 60; y=2: 85 64.49 53.50 48.15 50; y=4: 70 48.90 38.43 35.03 40;
% y=6: 55 38.78 30.39 27.07 30; y=8: 40 35 30 25 20. Estimate the temperature at
% (a) x = 4, y = 3.2 and (b) x = 4.3, y = 2.7 with bilinear and spline interpolation.
% CHECK: abs(Ta(1) - 44.458) < 1e-9 && abs(Ta(2) - 47.525375) < 1e-9
% CODE:
x = 0:2:8; y = 0:2:8;
T = [100   90    80    70    60;
     85    64.49 53.50 48.15 50;
     70    48.90 38.43 35.03 40;
     55    38.78 30.39 27.07 30;
     40    35    30    25    20];              % row = y, column = x
[X, Y] = meshgrid(x, y);
pts = [4 3.2; 4.3 2.7];
Ta = zeros(2, 1); Ts = zeros(2, 1);
for k = 1:2
    Ta(k) = interp2(X, Y, T, pts(k,1), pts(k,2), 'linear');
    Ts(k) = interp2(X, Y, T, pts(k,1), pts(k,2), 'spline');
end
for k = 1:2
    fprintf('(%c) T(%.1f, %.1f): bilinear = %.4f C, spline = %.4f C\n', 'a' + k - 1, pts(k,1), pts(k,2), Ta(k), Ts(k));
end

% TOPIC: regression
% TITLE: General linear least squares: 2nd-order polynomial with the Z matrix and normal equations
% SOURCE: CE206 slides 04 pages 10-13
% KEYWORDS: general linear least squares, z matrix, normal equations, second order polynomial, parabola, polyfit, basis functions
% PROBLEM:
% Fit the wind tunnel data (v = 10:10:80 m/s, F = 25 70 380 550 610 1220 830 1450 N) to a
% second-order polynomial using the general linear least-squares approach: build the Z matrix,
% form Z'*Z and Z'*F and solve for the coefficients. Compare with polyfit and give r^2.
% CHECK: norm(a - [-178.4821; 16.1220; 0.0372]) < 1e-3
% CODE:
v = (10:10:80)';
F = [25 70 380 550 610 1220 830 1450]';
Z = [ones(size(v)) v v.^2];
fprintf('Z''*Z =\n'); disp(Z'*Z);
fprintf('Z''*F =\n'); disp(Z'*F);
a = (Z'*Z)\(Z'*F);
fprintf('F = %.4f %+.4f v %+.6f v^2\n', a);
p = polyfit(v, F, 2);
fprintf('polyfit (highest power first): %s\n', mat2str(p, 6));
Sr = sum((F - Z*a).^2); St = sum((F - mean(F)).^2);
fprintf('r^2 = %.4f, standard error syx = %.4f\n', (St - Sr)/St, sqrt(Sr/(numel(v) - 3)));

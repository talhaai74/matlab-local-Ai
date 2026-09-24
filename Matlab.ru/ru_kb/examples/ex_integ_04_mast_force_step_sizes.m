% TOPIC: integration
% TITLE: Force on a sailboat mast by the trapezoidal rule with decreasing step sizes
% SOURCE: CE206 slides 05 page 14; Chapra Prob. 19.10
% KEYWORDS: trapezoidal rule, step size, composite, convergence, sailboat mast, total force, integral of a function
% PROBLEM:
% The total force on the mast of a sailboat is F = integral from 0 to 30 of 200 (z/(5 + z)) e^(-2z/30) dz.
% Evaluate the integral using the trapezoidal rule with step sizes 15, 10, 6, 3, 1, 0.5, 0.25 and 0.1 ft.
% CHECK: norm(Fh - [1001.7 1222.3 1372.3 1450.8 1477.1 1479.7 1480.4 1480.5]) < 0.1
% CODE:
f = @(z) 200*(z./(5 + z)).*exp(-2*z/30);
h = [15 10 6 3 1 0.5 0.25 0.1];
Fh = zeros(size(h));
fprintf('%8s %8s %12s\n', 'h (ft)', 'n', 'F (lb)');
for k = 1:numel(h)
    n = round(30/h(k));
    Fh(k) = integ_trap(f, 0, 30, n);
    fprintf('%8.2f %8d %12.1f\n', h(k), n, Fh(k));
end
fprintf('integral() reference: %.4f lb\n', integral(f, 0, 30));
Fh = round(Fh*10)/10;

% TOPIC: integration
% TITLE: Work done by a force with varying magnitude and angle, W = integral of F(x) cos(theta(x)) dx
% SOURCE: CE206 slides 05 page 12; Chapra Sec. 19.9
% KEYWORDS: work done, force, angle, cos theta, trapezoidal, simpson, discrete measurements, tabulated data
% PROBLEM:
% Calculate the work done from the discrete measurements x (ft) = 0 5 10 15 20 25 30,
% F(x) (lb) = 0 9 13 14 10.5 12 5, theta (rad) = 0.50 1.40 0.75 0.90 1.30 1.48 1.50,
% where W = integral of F(x) cos(theta(x)) dx. Use the trapezoidal rule and Simpson's rule.
% CHECK: abs(Wt - 119.0892) < 1e-3 && abs(Ws - 117.1271) < 1e-3
% CODE:
x = [0 5 10 15 20 25 30];
F = [0 9 13 14 10.5 12 5];
th = [0.50 1.40 0.75 0.90 1.30 1.48 1.50];
y = F.*cos(th);                         % force component along the motion
Wt = trapz(x, y);
Ws = integ_simpdata(x, y);              % 6 equal segments -> composite Simpson 1/3
fprintf('Work (trapezoidal) = %.4f ft-lb\nWork (Simpson 1/3) = %.4f ft-lb\n', Wt, Ws);

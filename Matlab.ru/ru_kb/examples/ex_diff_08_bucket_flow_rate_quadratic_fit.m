% TOPIC: differentiation
% TITLE: Flow rate from bucket volume versus time: derivative of a fitted parabola at t = 7 s
% SOURCE: Class solution sheet "Numerical Differentiation"; Chapra Prob. 21.20
% KEYWORDS: flow rate, bucket, volume, time, derivative, unequally spaced data, polyfit, second-order polynomial
% PROBLEM:
% You have to measure the flow rate of water through a small pipe. You place a bucket at the pipe's outlet and
% measure the volume in the bucket as a function of time: Time (s) = 0 1 5 8, Volume (cm^3) = 0 1 8 16.4.
% Estimate the flow rate at t = 7 s.
% CHECK: abs(estimate - 2.95) < 1e-9
% CODE:
T = [0 1 5 8];
V = [0 1 8 16.4];
a = polyfit(T, V, 2);
t = 7;
estimate = 2*a(1)*t + a(2);
fprintf('Flow rate at t = %g s: dV/dt = %.4f cm^3/s\n', t, estimate);

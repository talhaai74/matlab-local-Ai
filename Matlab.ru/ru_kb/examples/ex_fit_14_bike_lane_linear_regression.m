% TOPIC: regression
% TITLE: Bike-lane width versus distance to passing cars: linear regression and prediction
% SOURCE: Class solution sheet "Curve-fitting and Interpolation"; Chapra Prob. 14.24
% KEYWORDS: linear regression, straight line, bike lane, lane width, distance, passing cars, least squares, predict, plot
% PROBLEM:
% A transportation engineering study was conducted to determine the proper design of bike lanes. Data from
% 9 streets: Distance (m) = 2.4 1.5 2.4 1.8 1.8 2.9 1.2 3 1.2, Lane Width (m) = 2.9 2.1 2.3 2.1 1.8 2.7 1.5 2.9 1.5.
% (a) Plot the data. (b) Fit a straight line to the data with linear regression. Add this line to the plot.
% (c) If the minimum safe average distance between bikes and passing cars is considered to be 1.8 m,
% determine the corresponding minimum lane width.
% CHECK: abs(a(1) - 0.716716) < 1e-6 && abs(a(2) - 0.733492) < 1e-6 && abs(answer - 2.037002) < 1e-6
% CODE:
D = [2.4; 1.5; 2.4; 1.8; 1.8; 2.9; 1.2; 3; 1.2];
LW = [2.9; 2.1; 2.3; 2.1; 1.8; 2.7; 1.5; 2.9; 1.5];
Z = [ones(size(D)) D];
a = Z\LW;
fprintf('Lane width = %.4f + %.4f * distance\n', a(1), a(2));
answer = a(1) + a(2)*1.8;
fprintf('Minimum lane width for 1.8 m = %.4f m\n', answer);
figure; plot(D, LW, '*', [min(D) max(D)], a(1) + a(2)*[min(D) max(D)], '-'); grid on;
xlabel('Distance (m)'); ylabel('Lane width (m)'); legend('data', 'linear regression');

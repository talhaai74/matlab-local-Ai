% TOPIC: integration
% TITLE: Number of cars through an intersection from counts per 4 minutes at unequal times
% SOURCE: Class solution sheet "Numerical Integration"; Chapra Prob. 19.14
% KEYWORDS: transportation, cars, intersection, rush hour, rate, cars per 4 min, total number, unequal spacing, units, trapz
% PROBLEM:
% A transportation engineering study requires the number of cars that pass through an intersection during
% the morning rush hour. The number of cars passing every 4 minutes is counted at
% Time (hr) = 7:30 7:45 8:00 8:15 8:45 9:15, Rate (cars per 4 min) = 18 23 14 24 20 9.
% Use the best numerical method to determine (a) the total number of cars that pass between 7:30 and 9:15,
% and (b) the rate of cars going through the intersection per minute. (Hint: be careful with units.)
% CHECK: abs(Total_Cars - 491.25) < 1e-9 && abs(Avg_Rate - 4.678571) < 1e-6
% CODE:
Time = [0 15 30 45 75 105];
Rate = [18 23 14 24 20 9]/4;
Total_Cars = trapz(Time, Rate);
Avg_Rate = Total_Cars/(Time(end) - Time(1));
fprintf('(a) total number of cars = %.2f\n', Total_Cars);
fprintf('(b) average rate = %.4f cars per minute\n', Avg_Rate);

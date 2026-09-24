% TOPIC: interpolation
% TITLE: Quiz: registered motorcycles - not-a-knot spline for 2012, interp1 spline plot, 6th-order polyfit for 2018
% SOURCE: CE206 Final Quiz (18 batch) Set A, Q2
% KEYWORDS: not-a-knot, cubic spline, spline, interp1, polyfit, polyval, 6th order polynomial, badly conditioned, centering and scaling, motorcycles, brta, dhaka, predict, quiz
% PROBLEM:
% The year-wise registered number of motorcycles in Dhaka city (BRTA):
% Year = 2005 2007 2009 2011 2013 2015 2017, Number = 13362 14520 24675 35195 28086 46758 75251.
% (a) Using not-a-knot cubic interpolation determine the number of motorcycles registered in 2012.
% (b) Plot the motorcycle growth data using interp1 with 'spline'. Show proper axis titles and legend.
% (c) Use polyfit and polyval to predict the number of motorcycles in 2018 using a 6th order polynomial.
% CHECK: abs(n2012 - 31255.85) < 0.1
% CHECK: abs(n2018 - (-971.566)) < 0.01
% CODE:
Year = [2005 2007 2009 2011 2013 2015 2017];
Number = [13362 14520 24675 35195 28086 46758 75251];
%% (a) not-a-knot cubic spline (MATLAB spline default)
n2012 = spline(Year, Number, 2012);
fprintf('(a) Motorcycles registered in 2012 = %.0f\n', n2012);
%% (b) interp1 with 'spline'
yy = 2005:0.1:2017;
nn = interp1(Year, Number, yy, 'spline');
figure;
plot(Year, Number, 'go', yy, nn, 'r-', 'LineWidth', 1.5);
legend('Given data', 'Interpolated data (spline)', 'Location', 'northwest');
xlabel('Year'); ylabel('Number of motorcycles'); title('Growth data of motorcycles'); grid on;
%% (c) 6th-order polynomial (7 points -> exact interpolating polynomial)
[p, S, mu] = polyfit(Year, Number, 6);     % centering/scaling avoids the "badly conditioned" warning
n2018 = polyval(p, 2018, S, mu);
fprintf('(c) 6th-order polynomial prediction for 2018 = %.2f\n', n2018);
fprintf(['    The exact interpolating polynomial gives %.2f (negative!): extrapolating a 6th-order\n' ...
    '    polynomial beyond the data is meaningless. polyfit(Year,Number,6) WITHOUT centering is so badly\n' ...
    '    conditioned that its result (e.g. 57344 in the quiz solution) is round-off error, not a prediction.\n'], n2018);

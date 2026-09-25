% TOPIC: regression
% TITLE: River flow versus precipitation: linear regression, prediction and fraction of precipitation lost
% SOURCE: Class solution sheet "Curve-fitting and Interpolation"; Chapra Prob. 14.25
% KEYWORDS: linear regression, precipitation, river flow, reservoir, predict, drainage area, evaporation, fraction lost, units, plot
% PROBLEM:
% Data for a river that is to be dammed: Precip. (cm/yr) = 88.9 108.5 104.1 139.7 127 94 116.8 99.1,
% Flow (m^3/s) = 14.6 16.7 15.3 23.2 19.5 16.1 18.1 16.6.
% (a) Plot the data. (b) Fit a straight line to the data with linear regression and superimpose it on the plot.
% (c) Use the best-fit line to predict the annual water flow if the precipitation is 120 cm.
% (d) If the drainage area is 1100 km^2, estimate what fraction of the precipitation is lost via processes such
% as evaporation, deep groundwater infiltration and consumptive use.
% CHECK: abs(a(1) - 0.842783) < 1e-5 && abs(a(2) - 0.151871) < 1e-6 && abs(predict - 19.067277) < 1e-5 && abs(loss - 54.446541) < 1e-4
% CODE:
P = [88.9; 108.5; 104.1; 139.7; 127; 94; 116.8; 99.1];
Q = [14.6; 16.7; 15.3; 23.2; 19.5; 16.1; 18.1; 16.6];
Z = [ones(size(P)) P];
a = Z\Q;
fprintf('(b) Flow = %.4f + %.4f * Precip\n', a(1), a(2));
predict = a(1) + a(2)*120;
fprintf('(c) predicted flow for 120 cm/yr = %.4f m^3/s\n', predict);
volume = (1100e6)*(120e-2)/(86400*365);
loss = (volume - predict)/volume*100;
fprintf('(d) precipitation flow = %.4f m^3/s, fraction lost = %.2f %%\n', volume, loss);
figure; plot(P, Q, '*', [min(P) max(P)], a(1) + a(2)*[min(P) max(P)], '-'); grid on;
xlabel('Precipitation (cm/yr)'); ylabel('Flow (m^3/s)'); legend('data', 'linear regression');

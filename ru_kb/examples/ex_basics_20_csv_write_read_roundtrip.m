% TOPIC: basics
% TITLE: csvwrite/csvread round trip: numeric matrix, then a two-column time series
% SOURCE: Slides 01, pages 44, 47 (csvread PM10/rainfall example; csvwrite example)
% KEYWORDS: csvread, csvwrite, file io, numeric csv, column extraction, plot with legend
% PROBLEM:
% Export the numeric matrix A = [2 3 4 7; 5 6 8 9; 1 2 4 5] to a CSV file
% with csvwrite, then read it back with csvread and confirm it is unchanged.
% Then, for a two-column daily PM10/rainfall style dataset (numeric only, no
% header row, since csvread cannot read text), write it with csvwrite, read
% it back with csvread, split it into pm10 and rainfall columns, and plot
% both in the same figure with a legend.
% CHECK: isequal(A, Aback)
% CHECK: isequal(loaded, data)
% CHECK: isequal(pm10_in, pm10) && numel(pm10_in) == 12
% CODE:
A = [2 3 4 7; 5 6 8 9; 1 2 4 5];
csvfile = fullfile(tempdir,'ru_basics_matA.csv');
csvwrite(csvfile, A);
Aback = csvread(csvfile);
fprintf('csvwrite/csvread round trip of A matches original: %d\n', isequal(A,Aback));

% Synthetic daily PM10 (ug/m3) and rainfall (mm) sample data (the original
% PM10_Rainfall.csv from the slides is not bundled with this folder).
day = (1:12)';
pm10 = [420 380 300 250 180 90 60 70 120 200 310 400]';
rainfall = [5 10 20 60 140 210 190 150 80 30 10 5]';
data = [pm10 rainfall];
datafile = fullfile(tempdir,'ru_basics_pm10.csv');
csvwrite(datafile, data);
loaded = csvread(datafile);
pm10_in = loaded(:,1);
rainfall_in = loaded(:,2);

figure;
plot(day, pm10_in);
hold on;
plot(day, rainfall_in);
hold off;
legend('PM10','Rainfall');
xlabel('day'); ylabel('concentration (ug/m3) / rainfall (mm)');
fprintf('read back %d days of pm10/rainfall data from csv\n', numel(pm10_in));

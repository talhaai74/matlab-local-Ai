% TOPIC: basics
% TITLE: xlswrite/xlsread round trip: mixed text+numeric cell array, and date x-tick labels
% SOURCE: Slides 01, pages 45-47 (xlsread PM10/rainfall with dates; xlswrite mixed data example)
% KEYWORDS: xlsread, xlswrite, cell array, mixed text and numeric, date labels, xtick, raw output
% PROBLEM:
% Export the cell array A = {'Time','Temperature'; 9,25; 12,27; 3,28; 6,24}
% to an Excel file with xlswrite, then read it back with xlsread and check
% the Temperature column. Then export a Date/PM10/Rainfall table (a text
% date column next to two numeric columns) and use the date strings as
% x-axis tick labels on a plot of PM10 and Rainfall.
% CHECK: isequal(numX(:,2), [25;27;28;24])
% CHECK: size(raw2,1) == 13 && size(raw2,2) == 3
% CHECK: isequal(raw2{1,1}, 'Date') && raw2{2,2} == pm10(1)
% CODE:
C = {'Time','Temperature'; 9,25; 12,27; 3,28; 6,24};
xlsfile = fullfile(tempdir,'ru_basics_time_temp.xlsx');
xlswrite(xlsfile, C);
[numX, txtX, rawX] = xlsread(xlsfile);
fprintf('Temperature column read back:'); fprintf(' %d', numX(:,2)); fprintf('\n');

% Synthetic Date/PM10/Rainfall sample (the original PM10_Rainfall.xlsx from
% the slides is not bundled with this folder).
dates = {'01/01/18';'01/08/18';'01/15/18';'01/22/18';'01/29/18';'02/05/18'; ...
         '02/12/18';'02/19/18';'02/26/18';'03/05/18';'03/12/18';'03/19/18'};
pm10 = [420 380 300 250 180 90 60 70 120 200 310 400]';
rainfall = [5 10 20 60 140 210 190 150 80 30 10 5]';
sheet = [{'Date','PM10','Rainfall'}; [dates, num2cell(pm10), num2cell(rainfall)]];
sheetfile = fullfile(tempdir,'ru_basics_pm10_dates.xlsx');
xlswrite(sheetfile, sheet);
[num2, txt2, raw2] = xlsread(sheetfile);   % raw2 mirrors every original cell, unconverted

figure;
plot(pm10);
hold on;
plot(rainfall);
hold off;
legend('PM10','Rainfall');
set(gca,'xtick',1:3:12,'xticklabel',dates(1:3:12));
fprintf('sheet has %d rows x %d cols in raw output\n', size(raw2,1), size(raw2,2));

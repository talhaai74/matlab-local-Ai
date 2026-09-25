% TOPIC: integration
% TITLE: Net wind force on a skyscraper and its line of action from tabulated force per height
% SOURCE: Class solution sheet "Numerical Integration"; Chapra Prob. 19.11
% KEYWORDS: wind force, skyscraper, distributed force, net force, line of action, height, trapz
% PROBLEM:
% A wind force distributed against the side of a skyscraper is measured as
% Height l (m) = 0 30 60 90 120 150 180 210 240,
% Force F(l) (N/m) = 0 340 1200 1550 2700 3100 3200 3500 3750.
% Compute the net force and the line of action due to this distributed wind.
% CHECK: abs(ft - 523950) < 1e-6 && abs(d - 158.700258) < 1e-5
% CODE:
l = 0:30:240;
F = [0 340 1200 1550 2700 3100 3200 3500 3750];
ft = trapz(l, F);
d = trapz(l, F.*l)/ft;
fprintf('Net force = %.1f N\n', ft);
fprintf('Line of action = %.4f m above the ground\n', d);

% TOPIC: linear
% TITLE: How much material to haul from three pits (sand, fine gravel, coarse gravel)
% SOURCE: CE206 slides 03 page 14 (Exercise 3); Chapra Prob. 9.10 / Endfiles sand_gravel.m
% KEYWORDS: pits, sand, fine gravel, coarse gravel, composition, cubic meters, hauled, percentage, material balance
% PROBLEM:
% A civil engineer requires 4800, 5800 and 5700 m^3 of sand, fine gravel and coarse gravel for a
% building project. Pit 1 is 55% sand, 30% fine gravel, 15% coarse gravel; pit 2 is 25%, 45%, 30%;
% pit 3 is 25%, 20%, 55%. How many cubic meters must be hauled from each pit to meet the needs?
% CHECK: norm(Apit*v - need) < 1e-6 && all(v > 0)
% CODE:
comp = [55 30 15;      % pit 1: sand, fine, coarse (%)
        25 45 30;      % pit 2
        25 20 55]/100; % pit 3
need = [4800; 5800; 5700];          % sand, fine gravel, coarse gravel (m^3)
Apit = comp';                       % row = material, column = pit
v = Apit\need;
for k = 1:3
    fprintf('Pit %d: %10.2f m^3\n', k, v(k));
end
fprintf('Check (sand, fine, coarse delivered): %s m^3\n', mat2str((Apit*v)', 6));

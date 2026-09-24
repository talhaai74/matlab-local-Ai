% TOPIC: linear
% TITLE: Currents in a resistor circuit from Kirchhoff's current and voltage laws
% SOURCE: CE206 slides 03 page 16 (Exercise 5); Chapra Sec. 8.3
% KEYWORDS: electrical circuit, kirchhoff, current law, voltage law, resistors, ohm, currents i12 i52 i32 i65 i54 i43, V1 = 200 V, V6 = 0 V
% PROBLEM:
% For the circuit with V1 = 200 V, V6 = 0 V and resistors R12 = 5, R52 = 10, R32 = 10, R43 = 15,
% R54 = 5, R65 = 20 ohm, the current and voltage balances give
% i12 + i52 + i32 = 0, i65 - i52 - i54 = 0, i43 - i32 = 0, i54 - i43 = 0,
% 10 i52 - 10 i32 - 15 i43 - 5 i54 = 0, 5 i12 - 10 i52 - 20 i65 = 200 (in the slide's sign convention).
% Solve for the six currents.
% CHECK: abs(x(1) - 6.1538) < 1e-3 && abs(x(2) + 4.6154) < 1e-3 && abs(x(3) + 1.5385) < 1e-3
% CODE:
%      i12 i52 i32 i65 i54 i43
A = [   1   1   1   0   0   0;
        0  -1   0   1  -1   0;
        0   0  -1   0   0   1;
        0   0   0   0   1  -1;
        0  10 -10   0 -15  -5;
        5 -10   0 -20   0   0];
b = [0; 0; 0; 0; 0; 200];
x = A\b;
names = {'i12', 'i52', 'i32', 'i65', 'i54', 'i43'};
for k = 1:6
    fprintf('%s = %9.4f A\n', names{k}, x(k));
end
fprintf('Check: residual = %.2e (negative current = flows opposite to the assumed direction)\n', norm(A*x - b));

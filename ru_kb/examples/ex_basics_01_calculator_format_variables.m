% TOPIC: basics
% TITLE: Calculator expressions, display formats, and variable assignment
% SOURCE: Slides 01, pages 8-10 (MATLAB as a calculator; number formats; variables)
% KEYWORDS: calculator, arithmetic expression, built-in functions, cos, acos, exp, format short, format long, format bank, variable assignment, semicolon suppression
% PROBLEM:
% Using MATLAB as a calculator, evaluate the following expressions:
% 1) -5/(4.8+5.32)^2
% 2) (3+4i)*(3-4i)
% 3) cos(pi/2)
% 4) exp(acos(0.3))
% Then show that pi is stored to full double precision no matter which
% display format (format short, format long, format bank) is active.
% Finally, given x = -13, compute y = 5*x and z = x^2 + y.
% CHECK: abs(calc1 - (-0.0488212595)) < 1e-6
% CHECK: abs(calc2 - 25) < 1e-9
% CHECK: calc3 ~= 0 && abs(calc3) < 1e-10
% CHECK: abs(calc4 - 3.5470053098) < 1e-6
% CHECK: abs(pi_stored - 3.14159265358979) < 1e-12
% CHECK: y == -65 && z == 104
% CODE:
calc1 = -5/(4.8+5.32)^2;
calc2 = (3+4i)*(3-4i);
calc3 = cos(pi/2);
calc4 = exp(acos(0.3));
fprintf('-5/(4.8+5.32)^2 = %.6f\n', calc1);
fprintf('(3+4i)*(3-4i)   = %.6f\n', calc2);
fprintf('cos(pi/2)       = %.6e  (round-off residue, not exactly 0)\n', calc3);
fprintf('exp(acos(0.3))  = %.6f\n', calc4);

format long
pi_stored = pi;
format short
fprintf('pi stored to full double precision = %.15f\n', pi_stored);
fprintf('pi shown under format short = %.4f\n', pi);
fprintf('pi shown under format bank  = %.2f\n', pi);

x = -13;
y = 5*x;
z = x^2 + y;
fprintf('x = %d, y = 5*x = %d, z = x^2+y = %d\n', x, y, z);

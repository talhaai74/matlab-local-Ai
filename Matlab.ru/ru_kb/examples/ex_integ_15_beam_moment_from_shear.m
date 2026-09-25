% TOPIC: integration
% TITLE: Bending moment from shear force V(x) = 5 + 0.25x^2 on an 11-m beam: analytical and trapezoidal
% SOURCE: Class solution sheet "Numerical Integration"; Chapra Prob. 19.12 (Simpson part crossed out)
% KEYWORDS: beam, shear force, bending moment, V = dM/dx, M = Mo + integral of V, analytical integration, composite trapezoidal rule, 1-m increments
% PROBLEM:
% An 11-m beam is subjected to a load, and the shear force follows V(x) = 5 + 0.25x^2. We know V = dM/dx,
% so M = Mo + integral_0^x V dx. If Mo is zero and x = 11, calculate M using (a) analytical integration and
% (b) the composite trapezoidal rule with 1-m increments.
% CHECK: abs(Ma - 165.916667) < 1e-5 && abs(Mt - 166.375) < 1e-9
% CODE:
x = 0:11;
V = 5 + 0.25*x.^2;
Ma = 5*11 + 0.25*11^3/3;
Mt = trapz(x, V);
fprintf('(a) analytical: M = %.4f\n', Ma);
fprintf('(b) composite trapezoidal (1-m increments): M = %.4f (et = %.3f %%)\n', Mt, abs(Ma - Mt)/Ma*100);

% TOPIC: integration
% TITLE: Bending moment from shear V(x) = 5 + 0.25x^2: analytical, composite trapezoidal and composite Simpson
% SOURCE: Chapra Prob. 19.12
% KEYWORDS: beam, shear force, bending moment, analytical integration, composite trapezoidal, composite simpson's rules, 1-m increments, 11 segments
% PROBLEM:
% An 11-m beam is subjected to a load, and the shear force follows V(x) = 5 + 0.25x^2. We know V = dM/dx and
% M = Mo + integral_0^x V dx. If Mo is zero and x = 11, calculate M using (a) analytical integration,
% (b) composite trapezoidal rule, and (c) composite Simpson's rules. For (b) and (c) use 1-m increments.
% CHECK: abs(Ma - 165.916667) < 1e-5 && abs(Mt - 166.375) < 1e-9 && abs(Ms - 165.916667) < 1e-5
% CODE:
x = 0:11;
V = 5 + 0.25*x.^2;
Ma = 5*11 + 0.25*11^3/3;
Mt = trapz(x, V);
Ms = integ_simpdata(x, V);
fprintf('(a) analytical: M = %.4f\n', Ma);
fprintf('(b) composite trapezoidal: M = %.4f (et = %.3f %%)\n', Mt, abs(Ma - Mt)/Ma*100);
fprintf('(c) composite Simpson (1/3 + 3/8 for 11 segments): M = %.4f (et = %.1e %%)\n', Ms, abs(Ma - Ms)/Ma*100);

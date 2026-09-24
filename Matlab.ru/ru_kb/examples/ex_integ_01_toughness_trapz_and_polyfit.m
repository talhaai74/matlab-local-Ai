% TOPIC: integration
% TITLE: Modulus of toughness from stress-strain data: trapz, and a fitted polynomial with 100 segments
% SOURCE: CE206 slides 05 pages 10-11 (and class exercise); Chapra Prob. 20.16
% KEYWORDS: modulus of toughness, stress-strain, area under the curve, trapz, trapezoidal rule, polynomial fit, 100 equal segments, rupture
% PROBLEM:
% A rod under axial load gave: strain e = 0.02 0.05 0.10 0.15 0.20 0.25, stress s (kip/in^2) =
% 40.0 37.5 43.0 52.0 60.0 55.0 up to rupture. The area under the stress-strain curve up to rupture
% is the modulus of toughness. (a) Compute it with trapz. (b) Fit a (cubic) polynomial to the data,
% show the plot, and apply the trapezoidal rule with 100 equal segments using ordinates from the
% fitted polynomial.
% CHECK: abs(Ia - 11.2250) < 1e-4
% CHECK: abs(Ib - 11.25915) < 1e-4
% CODE:
e = [0.02 0.05 0.10 0.15 0.20 0.25];
s = [40.0 37.5 43.0 52.0 60.0 55.0];
%% (a) trapezoidal rule on the data
Ia = trapz(e, s);
fprintf('(a) trapz(e, s) = %.4f kip-in/in^3\n', Ia);
%% (b) polynomial fit, then 100 equal segments
p = polyfit(e, s, 3);
Ib = integ_trap(@(x) polyval(p, x), e(1), e(end), 100);
fprintf('(b) cubic fit s = %s; trapezoid with 100 segments = %.5f kip-in/in^3\n', mat2str(p, 5), Ib);
ee = linspace(e(1), e(end), 200);
figure; plot(e, s, 'ko', ee, polyval(p, ee), 'b-'); grid on;
xlabel('strain'); ylabel('stress (ksi)'); legend('data', 'cubic fit', 'Location', 'southeast'); title('Stress-strain curve');

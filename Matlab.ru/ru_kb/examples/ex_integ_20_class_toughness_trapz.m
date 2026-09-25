% TOPIC: integration
% TITLE: Modulus of toughness: area under the stress-strain data up to rupture (class sheet, trapz)
% SOURCE: Class solution sheet "Numerical Integration"; Chapra Prob. 20.16
% KEYWORDS: modulus of toughness, stress-strain curve, rupture, area under the curve, numerical integration, trapz, unequal spacing, axial load, rod
% PROBLEM:
% A rod subject to an axial load (Fig. P20.16a) will be deformed, as shown in the stress-strain curve in
% Fig. P20.16b. The area under the curve from zero stress out to the point of rupture is called the modulus
% of toughness of the material. It provides a measure of the energy per unit volume required to cause the
% material to rupture. Use numerical integration to compute the modulus of toughness for the stress-strain
% curve: e = 0.02 0.05 0.10 0.15 0.20 0.25, s (ksi) = 40.0 37.5 43.0 52.0 60.0 55.0.
% CHECK: abs(toughness - 11.225) < 1e-9
% CODE:
e = [0.02 0.05 0.10 0.15 0.20 0.25];
s = [40.0 37.5 43.0 52.0 60.0 55.0];
toughness = trapz(e, s);
fprintf('Modulus of toughness = %.4f ksi (kip-in/in^3)\n', toughness);

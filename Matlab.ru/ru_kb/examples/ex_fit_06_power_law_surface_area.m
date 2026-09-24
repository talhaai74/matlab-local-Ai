% TOPIC: regression
% TITLE: Power law A = a W^b for human surface area; prediction for 95 kg
% SOURCE: Chapra Prob. 14.12
% KEYWORDS: power law, power model, log transformation, surface area, weight, predict
% PROBLEM:
% Measurements on individuals of height 180 cm give weight W (kg) = 70 75 77 80 82 84 87 90 and
% surface area A (m^2) = 2.10 2.12 2.15 2.20 2.22 2.23 2.26 2.30. Show that a power law A = aW^b
% fits these data reasonably well, evaluate a and b, and predict the surface area of a 95-kg person.
% CHECK: abs(A95 - 2.34041) < 1e-4 && abs(b - 0.379911) < 1e-5
% CODE:
W = [70 75 77 80 82 84 87 90];
A = [2.10 2.12 2.15 2.20 2.22 2.23 2.26 2.30];
[a, b, r2] = fit_power(W, A);
fprintf('A = %.4f W^%.4f,  r^2 = %.4f (power curve on the original A)\n', a, b, r2);
A95 = a*95^b;
fprintf('Predicted surface area for 95 kg: %.4f m^2\n', A95);
WW = linspace(65, 100, 100);
figure; loglog(W, A, 'ko', WW, a*WW.^b, 'b-'); grid on;
xlabel('W (kg)'); ylabel('A (m^2)'); title('Power law is a straight line on log-log axes');

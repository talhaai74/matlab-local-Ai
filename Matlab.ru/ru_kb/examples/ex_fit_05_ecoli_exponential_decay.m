% TOPIC: regression
% TITLE: E. coli after a storm: exponential model by linearization, c(0) and time to reach 200
% SOURCE: Chapra Prob. 14.9
% KEYWORDS: exponential model, exponential decay, linearize, natural log, e. coli, bacteria, concentration, cfu, time to reach
% PROBLEM:
% The concentration of E. coli bacteria in a swimming area after a storm is
% t (hr) = 4 8 12 16 20 24, c (CFU/100 mL) = 1600 1320 1000 890 650 560.
% Use these data to estimate (a) the concentration at the end of the storm (t = 0) and (b) the time
% at which the concentration will reach 200 CFU/100 mL. The model must be consistent with a
% concentration that is always positive and decreasing.
% CHECK: abs(alpha - 1985.437) < 0.01 && abs(beta + 0.0535063) < 1e-6
% CHECK: abs(t200 - 42.8973) < 1e-3
% CODE:
t = [4 8 12 16 20 24];
c = [1600 1320 1000 890 650 560];
[alpha, beta, r2] = fit_exponential(t, c);     % c = alpha*exp(beta*t)
fprintf('c = %.2f exp(%.5f t),  r^2 = %.4f (exponential curve on the original c)\n', alpha, beta, r2);
fprintf('(a) c(0) = %.1f CFU/100 mL\n', alpha);
t200 = log(200/alpha)/beta;
fprintf('(b) c = 200 at t = %.2f hr\n', t200);
tt = linspace(0, 45, 200);
figure;
plot(t, c, 'ko', tt, alpha*exp(beta*tt), 'b-', t200, 200, 'r*');
grid on; xlabel('t (hr)'); ylabel('c (CFU/100 mL)'); legend('data', 'exponential fit', 'c = 200');

% TOPIC: regression
% TITLE: General linear least squares with exponential basis functions (initial concentrations A, B, C)
% SOURCE: Chapra Prob. 15.10 (and 15.28)
% KEYWORDS: general linear least squares, basis functions, exponential terms, initial concentration, organisms, z matrix
% PROBLEM:
% Three disease-carrying organisms decay in seawater according to p(t) = A e^(-1.5t) + B e^(-0.3t) + C e^(-0.05t).
% Estimate the initial concentration of each organism (A, B and C) given
% t = 0.5 1 2 3 4 5 6 7 9, p(t) = 6 4.4 3.2 2.7 2 1.9 1.7 1.4 1.1.
% CHECK: norm(a' - [4.1375 2.8959 1.5349]) < 1e-3
% CODE:
t = [0.5 1 2 3 4 5 6 7 9]';
p = [6 4.4 3.2 2.7 2 1.9 1.7 1.4 1.1]';
Z = [exp(-1.5*t) exp(-0.3*t) exp(-0.05*t)];    % one column per basis function
a = (Z'*Z)\(Z'*p);
fprintf('A = %.4f, B = %.4f, C = %.4f\n', a);
Sr = sum((p - Z*a).^2); St = sum((p - mean(p)).^2);
fprintf('r^2 = %.4f\n', (St - Sr)/St);
tt = linspace(0, 10, 200)';
figure; plot(t, p, 'ko', tt, [exp(-1.5*tt) exp(-0.3*tt) exp(-0.05*tt)]*a, 'b-'); grid on;
xlabel('t'); ylabel('p(t)'); legend('data', 'fit');

% TOPIC: eigen
% TITLE: Two-mass spring system: characteristic polynomial, eig, natural frequencies, periods and mode shapes
% SOURCE: CE206 slides 08 pages 5-9 / Endfiles oscillatingmass.m
% KEYWORDS: eigenvalue, eigenvector, eig, mass-spring system, natural frequency, period, mode shape, characteristic polynomial, determinant, principal modes of vibration
% PROBLEM:
% Two masses m1 = m2 = 40 kg are connected by springs k = 200 N/m (wall-spring-mass-spring-mass-spring-wall).
% Assuming x = X sin(wt), the system becomes (10 - w^2)X1 - 5X2 = 0 and -5X1 + (10 - w^2)X2 = 0.
% Determine the eigenvalues (w^2) from the characteristic polynomial and with eig, the natural
% frequencies, the periods and the mode shapes, and plot the principal modes of vibration.
% CHECK: norm(sort(lam) - [5; 15]) < 1e-12 && norm(Tp - [2*pi/sqrt(5); 2*pi/sqrt(15)]) < 1e-12
% CODE:
m = 40; k = 200;
A = [2*k/m -k/m; -k/m 2*k/m];            % = [10 -5; -5 10]
c = poly(A);                             % characteristic polynomial of lambda = w^2
fprintf('Characteristic polynomial: lambda^2 %+g lambda %+g = 0 -> roots %s\n', c(2), c(3), mat2str(roots(c)'));
[V, D] = eig(A);
[lam, idx] = sort(diag(D));
V = V(:, idx);
w = sqrt(lam); Tp = 2*pi./w;
for i = 1:2
    fprintf('Mode %d: w^2 = %g, w = %.4f rad/s, period = %.4f s, shape = [%.4f %.4f]\n', i, lam(i), w(i), Tp(i), V(:,i));
end
t = linspace(0, 6, 300);
figure;
for i = 1:2
    subplot(1,2,i); plot([0 1 2], [0; V(:,i)], 'o-', 'LineWidth', 2); grid on;
    title(sprintf('Mode %d, T_p = %.2f s', i, Tp(i))); xlabel('mass'); ylabel('relative amplitude');
end

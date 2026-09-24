% TOPIC: eigen
% TITLE: Solving a linear ODE system with eigenvalues and eigenvectors (general solution from initial conditions)
% SOURCE: Chapra Prob. 13.11
% KEYWORDS: system of odes, eigenvalue problem, eigenvectors, general solution, initial conditions, c1 c2, exponential, stiff
% PROBLEM:
% dy1/dt = -5y1 + 3y2, y1(0) = 50; dy2/dt = 100y1 - 301y2, y2(0) = 100. Solutions have the form
% y = c1 v1 e^(lambda1 t) + c2 v2 e^(lambda2 t). (a) Convert the system into an eigenvalue problem,
% (b) use MATLAB to solve for the eigenvalues and eigenvectors, (c) use the initial conditions to find
% the general solution, and (d) plot the solution for t = 0 to 1.
% CHECK: norm(yend' - [0.94053611 0.31666809]) < 1e-6
% CODE:
A = [-5 3; 100 -301];
y0 = [50; 100];
[V, D] = eig(A);
lam = diag(D);
c = V\y0;                                  % y(0) = V*c
fprintf('Eigenvalues: %s\n', mat2str(lam', 8));
fprintf('Eigenvectors (columns):\n'); disp(V);
fprintf('Coefficients c = %s\n', mat2str(c', 6));
y = @(t) V*(c.*exp(lam*t));               % general solution
t = linspace(0, 1, 201);
Y = zeros(2, numel(t));
for i = 1:numel(t)
    Y(:,i) = y(t(i));
end
yend = y(1);
fprintf('y(1) = [%.6f, %.6f]; check with expm: %s\n', yend, mat2str((expm(A*1)*y0)', 8));
figure; plot(t, Y(1,:), 'b-', t, Y(2,:), 'r--'); grid on; xlabel('t'); legend('y_1', 'y_2');

% TOPIC: eigen
% TITLE: Three-story building: eigenvalues and eigenvectors of M\K, natural frequencies, periods and mode shapes
% SOURCE: CE206 slides 08 page 10 (assignment); Chapra Sec. 13.5 / Endfiles building.m
% KEYWORDS: three-story building, multi-storey building, two-storey, storey, story, floors, mass-spring model, stiffness matrix, mass matrix, eigenvalues, eigenvectors, natural frequency, period, modes of vibration, floors
% PROBLEM:
% A mass-spring system represents a three-story building with floor masses m1 = 12000, m2 = 10000,
% m3 = 8000 kg and story stiffnesses k1 = 3000, k2 = 2400, k3 = 1800 kN/m. Use MATLAB to determine the
% eigenvalues and eigenvectors, the natural frequencies and periods, and graphically represent the modes
% of vibration of the structure.
% CHECK: norm(w' - [7.5448 18.4249 26.4310]) < 1e-3
% CODE:
m = [12000 10000 8000];                  % floor masses, kg (one value per floor)
k = [3000 2400 1800]*1e3;                % story stiffnesses, kN/m -> N/m (k(1) = ground story)
n = numel(m);                            % number of floors: works for 2, 3, 4, ... floors
K = zeros(n);
for i = 1:n
    K(i,i) = k(i);
    if i < n
        K(i,i) = K(i,i) + k(i+1);
        K(i,i+1) = -k(i+1);
        K(i+1,i) = -k(i+1);
    end
end
M = diag(m);
[V, D] = eig(M\K);                       % eigenvalues are w^2
[lam, idx] = sort(diag(D));
V = V(:, idx);
w = sqrt(lam); Tp = 2*pi./w;
fprintf('%6s %12s %12s %10s   mode shape (normalized)\n', 'mode', 'w^2', 'w (rad/s)', 'T (s)');
for i = 1:n
    v = V(:,i)/max(abs(V(:,i)));
    fprintf('%6d %12.3f %12.4f %10.4f   [%s]\n', i, lam(i), w(i), Tp(i), sprintf(' %7.4f', v));
end
figure;
for i = 1:n
    v = V(:,i)/max(abs(V(:,i)));
    subplot(1,n,i); plot([0; v], 0:n, 'o-', 'LineWidth', 2); grid on; xlim([-1.2 1.2]);
    title(sprintf('Mode %d (T = %.3f s)', i, Tp(i))); xlabel('displacement'); ylabel('floor');
end

% TOPIC: roots
% TITLE: Fixed-point iteration for depth in a rectangular channel (Manning equation)
% SOURCE: Chapra Prob. 6.25
% KEYWORDS: fixed-point iteration, simple iteration, manning equation, rectangular channel, depth, convergence
% PROBLEM:
% The Manning equation for a rectangular open channel is Q = sqrt(S)*(B*H)^(5/3)/(n*(B + 2H)^(2/3)).
% Develop a fixed-point iteration scheme to solve for H given Q = 5, S = 0.0002, B = 20 and n = 0.03.
% Perform the computation until ea is less than es = 0.05%.
% CHECK: abs(H - 0.7023) < 1e-3
% CHECK: abs(Q(H) - 5) < 1e-3
% CODE:
Qg = 5; S = 0.0002; B = 20; n = 0.03;
Q = @(H) sqrt(S)*(B*H).^(5/3)./(n*(B + 2*H).^(2/3));
g = @(H) (Qg*n/sqrt(S))^(3/5)*(B + 2*H).^(2/5)/B;     % H = g(H) rearranged from Manning
fprintf('Manning: Q = sqrt(S)(BH)^(5/3)/(n(B+2H)^(2/3)); iteration H = (Qn/sqrt(S))^(3/5)(B+2H)^(2/5)/B\n');
[H, res, ea, iter, tab] = root_fixedpoint(g, 0, 0.05, 100);
fprintf('%5s %12s %12s %12s\n', 'iter', 'H', 'g(H)', 'ea (%)');
fprintf('%5d %12.6f %12.6f %12.4f\n', tab');
fprintf('Depth H = %.5f m after %d iterations (ea = %.4f %%); check Q(H) = %.4f m^3/s\n', H, iter, ea, Q(H));
fprintf('Converges because |g''(H)| = %.3f < 1 near the root.\n', abs((g(H + 1e-6) - g(H - 1e-6))/2e-6));

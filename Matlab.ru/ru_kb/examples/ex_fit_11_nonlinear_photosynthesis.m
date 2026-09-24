% TOPIC: regression
% TITLE: Nonlinear regression of the photosynthesis model P = Pm (I/Isat) exp(-I/Isat + 1)
% SOURCE: Chapra Prob. 15.11
% KEYWORDS: nonlinear regression, fminsearch, photosynthesis, solar radiation, pm, isat, model parameters
% PROBLEM:
% The photosynthesis rate of aquatic plants is P = Pm (I/Isat) e^(-I/Isat + 1). Use nonlinear
% regression to evaluate Pm and Isat from
% I = 50 80 130 200 250 350 450 550 700, P = 99 177 202 248 229 219 173 142 72.
% CHECK: abs(p(1) - 238.7) < 1 && abs(p(2) - 221.8) < 1.5
% CODE:
I = [50 80 130 200 250 350 450 550 700];
P = [99 177 202 248 229 219 173 142 72];
model = @(q, x) q(1)*(x/q(2)).*exp(-x/q(2) + 1);
[p, SSR, r2] = fit_nonlinear(model, [250 250], I, P);    % initial guess from the data peak
fprintf('Pm = %.3f, Isat = %.3f, SSR = %.2f, r^2 = %.4f\n', p(1), p(2), SSR, r2);
II = linspace(0, 750, 300);
figure; plot(I, P, 'ko', II, model(p, II), 'b-'); grid on; xlabel('I'); ylabel('P'); legend('data', 'fit');

% TOPIC: regression
% TITLE: Bacterial growth rate k = kmax c^2/(cs + c^2) by linearization; predict k at c = 2
% SOURCE: Chapra Prob. 14.14
% KEYWORDS: saturation growth, growth rate, linearize, transformation, 1/k versus 1/c^2, kmax, cs, predict
% PROBLEM:
% An investigator reports the growth rate of bacteria k (per d) versus oxygen concentration c (mg/L):
% c = 0.5 0.8 1.5 2.5 4, k = 1.1 2.5 5.3 7.6 8.9. The data can be modeled by k = kmax c^2/(cs + c^2).
% Use a transformation to linearize this equation, then use linear regression to estimate cs and
% kmax and predict the growth rate at c = 2 mg/L.
% CHECK: abs(kmax - 10.34493) < 1e-4 && abs(cs - 2.08973) < 1e-4 && abs(model(2) - 6.79500) < 1e-4
% CODE:
c = [0.5 0.8 1.5 2.5 4];
k = [1.1 2.5 5.3 7.6 8.9];
% 1/k = (cs/kmax)*(1/c^2) + 1/kmax  ->  straight line in X = 1/c^2, Y = 1/k
p = polyfit(1./c.^2, 1./k, 1);
kmax = 1/p(2);
cs = p(1)*kmax;
fprintf('1/k = %.5f (1/c^2) + %.5f  ->  kmax = %.4f /d, cs = %.4f (mg/L)^2\n', p(1), p(2), kmax, cs);
model = @(cc) kmax*cc.^2./(cs + cc.^2);
fprintf('Predicted k at c = 2 mg/L: %.4f /d\n', model(2));
cc = linspace(0, 4.5, 200);
figure; plot(c, k, 'ko', cc, model(cc), 'b-'); grid on;
xlabel('c (mg/L)'); ylabel('k (/d)'); legend('data', 'k = k_{max}c^2/(c_s + c^2)', 'Location', 'southeast');

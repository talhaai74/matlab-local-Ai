% TOPIC: basics
% TITLE: Formatted plot text: (1+1/n)^n converging to e, and a subscript/Greek legend
% SOURCE: Slides 01, pages 29-30 (formatted text on plots)
% KEYWORDS: subscript, superscript, greek letters, legend fontsize, markersize, linewidth, convergence to e
% PROBLEM:
% Plot the first 100 terms of x_n = (1+1/n)^n for n = 1..100 together with a
% dashed reference line at y = e, titled 'x_n = (1+1/n)^n', with a legend
% showing 'x_n' and 'y = e^1 = 2.71828...'. In a second panel, plot
% phi(x) = x^3*sin(3*pi*x)^2 for x = -2:.02:2 with linewidth 2 and a legend
% using \phi and \pi, using set(0,'Defaultaxesfontsize',16) for the labels.
% CHECK: numel(n) == 100 && abs(xseq(end) - 2.704813829422) < 1e-6
% CHECK: abs(exp(1) - 2.718281828459) < 1e-9
% CHECK: numel(xphi) == 201
% CHECK: abs(phi_at_half - 0.125) < 1e-6
% CODE:
set(0,'Defaultaxesfontsize',16);
n = 1:100;
xseq = (1+1./n).^n;
xphi = -2:.02:2;
yphi = xphi.^3 .* sin(3*pi*xphi).^2;
phi_at_half = 0.5^3 * sin(3*pi*0.5)^2;

figure;
subplot(2,1,1);
plot(n, xseq, '.', [0 max(n)], exp(1)*[1 1], '--', 'markersize', 8);
title('x_n = (1+1/n)^n','fontsize',12);
xlabel('n'); ylabel('x_n');
legend('x_n','y = e^1 = 2.71828...');

subplot(2,1,2);
plot(xphi, yphi, 'linewidth', 2);
legend('\phi(x) = x^3sin^2 3\pi x');
xlabel('x');
fprintf('x_100 = %.6f, e = %.6f, phi(0.5) = %.6f\n', xseq(end), exp(1), phi_at_half);

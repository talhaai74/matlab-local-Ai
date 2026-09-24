% TOPIC: roots
% TITLE: Newton-Raphson method with different initial guesses (convergence and divergence)
% SOURCE: Chapra Prob. 6.27; CE206 slides 02 pages 9-10 (newtraph)
% KEYWORDS: newton-raphson, newtraph, derivative, initial guess, divergence, open method
% PROBLEM:
% Use the Newton-Raphson method to find the root of f(x) = e^(-0.5x)(4 - x) - 2.
% Employ initial guesses of (a) 2, (b) 6 and (c) 8. Explain your results.
% CHECK: abs(r2 - 0.885) < 1e-3
% CHECK: abs(f(r2)) < 1e-6
% CODE:
f  = @(x) exp(-0.5*x).*(4 - x) - 2;
df = @(x) -exp(-0.5*x) - 0.5*exp(-0.5*x).*(4 - x);   % f'(x)
guesses = [2 6 8];
for k = 1:numel(guesses)
    x0 = guesses(k);
    fprintf('\n(%c) x0 = %g\n', 'a' + k - 1, x0);
    try
        [r, fr, ea, iter, tab] = root_newton(f, df, x0, 1e-6, 20);
        fprintf('%5s %14s %14s %14s %12s\n', 'iter', 'x', 'f(x)', 'f''(x)', 'ea (%)');
        fprintf('%5d %14.6g %14.6g %14.6g %12.4g\n', tab');
        if abs(fr) < 1e-6
            fprintf('Converged: root = %.6f after %d iterations\n', r, iter);
        else
            fprintf('Did NOT converge: x = %.4g, f(x) = %.4g after %d iterations\n', r, fr, iter);
        end
    catch err
        fprintf('Newton-Raphson failed: %s\n', err.message);
    end
    if k == 1
        r2 = r;
    end
end
fprintf(['\nExplanation: from x0 = 2 the tangents lead to the root x = %.4f. From x0 = 6 the slope\n' ...
    'f''(6) is zero, so the method cannot continue; from x0 = 8 the tangent points away and x\n' ...
    'grows where f(x) is almost flat (f -> -2), so the iterations diverge.\n'], r2);

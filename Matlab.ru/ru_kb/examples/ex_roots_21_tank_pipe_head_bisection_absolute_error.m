% TOPIC: roots
% TITLE: Initial head for a tank draining through a long pipe (plot f(H), bisection with absolute error Ead)
% SOURCE: Chapra Prob. 5.4 (Fig. P5.4)
% KEYWORDS: tank, pipe, velocity, initial head, tanh, bisection, LastNameBisect, absolute error, Ead, format long, plot f(H)
% PROBLEM:
% The velocity of water discharged from a cylindrical tank through a long pipe is
% v = sqrt(2gH) tanh(sqrt(2gH)/(2L) t), where g = 9.81 m/s^2, H = initial head (m), L = pipe length (m) and
% t = elapsed time (s). Develop a MATLAB script that (a) plots the function f(H) versus H for H = 0 to 4 m
% (label the plot) and (b) uses LastNameBisect with initial guesses xl = 0 and xu = 4 m to determine the
% initial head needed to achieve v = 5 m/s in 2.5 s for a 4-m long pipe. Use Ead = 0.0000001. Also set
% format long in your script so you display 15 significant digits for your results.
% CHECK: abs(H - 1.4658945885) < 2e-7
% CODE:
g = 9.81; L = 4; t = 2.5; v = 5;
f = @(H) sqrt(2*g*H).*tanh(sqrt(2*g*H)/(2*L)*t) - v;
Hp = linspace(0, 4);
figure; plot(Hp, f(Hp)); grid on; xlabel('H (m)'); ylabel('f(H) (m/s)'); title('f(H) = v(H) - 5');
format long
[H, fH, ea, iter] = LastNameBisect(f, 0, 4, 1e-7)

function [xr, fx, ea, iter] = LastNameBisect(f, xl, xu, Ead)
if f(xl)*f(xu) > 0
    error('no sign change between xl and xu');
end
xr = xl; ea = Inf; iter = 0;
while ea > Ead && iter < 200
    xrold = xr;
    xr = (xl + xu)/2;
    iter = iter + 1;
    if iter > 1
        ea = abs(xr - xrold);
    end
    if f(xl)*f(xr) < 0
        xu = xr;
    elseif f(xl)*f(xr) > 0
        xl = xr;
    else
        ea = 0;
    end
end
fx = f(xr);
end

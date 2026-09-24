%Passing a function as function argument
%Syntax 1:
%[root,fx,ea,iter]=bisect(@my_func,0.6,0.8)

%Syntax 2:
%[root,fx,ea,iter]=bisect(@(x)x^3-10*x^2+5,0.6,0.8)

%Fzero function to find roots
%[x, fx] = fzero(function, x0)
%[x, fx] = fzero(function, [x0 x1])

%Roots function for polynomials:

%Find the roots of
%f(x)=x5 - 3.5x4 + 2.75x3 + 2.125x2 - 3.875x + 1.25
%x = roots([1 -3.5 2.75 2.125 -3.875 1.25])
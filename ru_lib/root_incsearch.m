function [xb, nb] = root_incsearch(f, xmin, xmax, ns)
%ROOT_INCSEARCH  Incremental search for sign-change brackets of f(x) = 0.
%   [xb, nb] = root_incsearch(f, xmin, xmax, ns)
%   f      function handle @(x) ..., or text 'x^3 - 10'
%   xmin, xmax  interval to scan
%   ns     number of subintervals to scan (default 50)
%   xb     nb-by-2 matrix, one row [xl xu] per sign change found (a bracket)
%   nb     number of brackets found (size(xb,1)); xb is empty if nb = 0
%   Example: xb = root_incsearch(@(x) x.^3 - 10*x.^2 + 5, 0, 1, 100)

if nargin < 3
    error('ru_lib:root_incsearch:nargin', 'root_incsearch: need at least f, xmin, xmax.');
end
if nargin < 4 || isempty(ns), ns = 50; end
f = ru_tofunc(f, {'x'});
x = linspace(xmin, xmax, ns+1);
fx = zeros(size(x));
for i = 1:length(x)
    fx(i) = f(x(i));
end
xb = zeros(0,2);
nb = 0;
for i = 1:ns
    if fx(i) == 0
        nb = nb + 1;
        xb(nb,:) = [x(i) x(i)];
    elseif sign(fx(i)) ~= sign(fx(i+1))
        nb = nb + 1;
        xb(nb,:) = [x(i) x(i+1)];
    end
end
if nargout == 0
    fprintf('root_incsearch: %d bracket(s) found in [%.6g, %.6g] using ns = %d\n', nb, xmin, xmax, ns);
    for i = 1:nb
        fprintf('  bracket %d: [%.6g, %.6g]\n', i, xb(i,1), xb(i,2));
    end
end
end

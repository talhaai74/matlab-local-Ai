function r = root_findall(f, xmin, xmax, ns)
%ROOT_FINDALL  All real roots of f(x) = 0 inside [xmin, xmax].
%   r = root_findall(f, xmin, xmax, ns)
%   f      function handle @(x) ..., or text 'x^3 - 10'
%   xmin, xmax  interval to search
%   ns     number of subintervals for the incremental search (default 100)
%   r      column vector of distinct roots found, sorted ascending
%   Uses root_incsearch to bracket sign changes, then root_bisection to
%   refine each bracket; roots closer than 1e-6*max(1,|r|) are merged.
%   Example: r = root_findall(@(x) x.^3-6*x.^2+11*x-6, -1, 5, 200)

if nargin < 3
    error('ru_lib:root_findall:nargin', 'root_findall: need at least f, xmin, xmax.');
end
if nargin < 4 || isempty(ns), ns = 100; end
f = ru_tofunc(f, {'x'});
xb = root_incsearch(f, xmin, xmax, ns);
r = zeros(0,1);
for i = 1:size(xb,1)
    xl = xb(i,1); xu = xb(i,2);
    if xl == xu
        ri = xl;
    else
        ri = root_bisection(f, xl, xu, 1e-8, 100);
    end
    r(end+1,1) = ri; %#ok<AGROW>
end
r = sort(r);
keep = true(size(r));
for i = 2:length(r)
    if abs(r(i) - r(i-1)) < 1e-6*max(1, abs(r(i)))
        keep(i) = false;
    end
end
r = r(keep);
if nargout == 0
    fprintf('root_findall: %d distinct root(s) found in [%.6g, %.6g]\n', length(r), xmin, xmax);
    for i = 1:length(r)
        fprintf('  r(%d) = %.8g   f = %.4g\n', i, r(i), f(r(i)));
    end
end
end

function p = stat_tcdf(t, nu)
%STAT_TCDF  Student's t cumulative distribution function.
%   p = stat_tcdf(t, nu)
%   t    value(s) (scalar, vector or matrix)
%   nu   degrees of freedom, nu > 0 (scalar, or same size as t)
%   p    P(T <= t) for T ~ Student's t with nu dof, same size as t
%   Uses the regularized incomplete beta function (betainc); no toolbox.
%   Example: p = stat_tcdf(2.5, 10)

if nargin < 2
    error('ru_lib:stat_tcdf:nargin', 'STAT_TCDF: need t and nu (degrees of freedom).');
end
if any(nu(:) <= 0)
    error('ru_lib:stat_tcdf:nu', 'STAT_TCDF: nu (degrees of freedom) must be > 0.');
end
xx = nu ./ (nu + t.^2);
tt = zeros(size(xx)) + t;   % broadcast t to the common size
ib = betainc(xx, nu/2, 0.5);
p = zeros(size(xx));
neg = tt <= 0;
p(neg)  = 0.5*ib(neg);
p(~neg) = 1 - 0.5*ib(~neg);
end

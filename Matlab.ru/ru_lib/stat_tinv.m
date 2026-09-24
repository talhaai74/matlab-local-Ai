function t = stat_tinv(p, nu)
%STAT_TINV  Inverse Student's t cumulative distribution function.
%   t = stat_tinv(p, nu)
%   p    probability/probabilities in (0,1)
%   nu   degrees of freedom, nu > 0 (scalar, or same size as p)
%   t    value(s) such that stat_tcdf(t,nu) = p
%   Uses the inverse regularized incomplete beta function (betaincinv).
%   Example: t = stat_tinv(0.975, 10)

if nargin < 2
    error('ru_lib:stat_tinv:nargin', 'STAT_TINV: need p and nu (degrees of freedom).');
end
if any(p(:) < 0) || any(p(:) > 1)
    error('ru_lib:stat_tinv:prange', 'STAT_TINV: p must be in [0,1].');
end
if any(nu(:) <= 0)
    error('ru_lib:stat_tinv:nu', 'STAT_TINV: nu (degrees of freedom) must be > 0.');
end
pp = zeros(size(nu)) + p;    % broadcast to a common size
nn = zeros(size(pp)) + nu;
lo = pp <= 0.5;
ib = zeros(size(pp));
ib(lo)  = 2*pp(lo);
ib(~lo) = 2*(1 - pp(~lo));
x = betaincinv(ib, nn/2, 0.5);
t = sqrt(nn.*(1 - x)./x);
t(lo) = -t(lo);
end

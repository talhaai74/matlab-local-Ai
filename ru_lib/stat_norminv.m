function x = stat_norminv(p, mu, sigma)
%STAT_NORMINV  Inverse normal (Gaussian) cumulative distribution function.
%   x = stat_norminv(p, mu, sigma)
%   p       probability/probabilities in [0,1]
%   mu      mean (default 0)
%   sigma   standard deviation (default 1); must be > 0
%   x       value(s) such that stat_normcdf(x,mu,sigma) = p
%   Uses x = mu - sigma*sqrt(2)*erfcinv(2*p)
%   Example: x = stat_norminv(0.975, 0, 1)

if nargin < 1
    error('ru_lib:stat_norminv:nargin', 'STAT_NORMINV: need p.');
end
if nargin < 2 || isempty(mu), mu = 0; end
if nargin < 3 || isempty(sigma), sigma = 1; end
if sigma <= 0
    error('ru_lib:stat_norminv:sigma', 'STAT_NORMINV: sigma must be > 0 (got %g).', sigma);
end
if any(p(:) < 0) || any(p(:) > 1)
    error('ru_lib:stat_norminv:prange', 'STAT_NORMINV: p must be in [0,1].');
end
x = mu - sigma*sqrt(2).*erfcinv(2*p);
end

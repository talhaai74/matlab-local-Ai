function p = stat_normcdf(x, mu, sigma)
%STAT_NORMCDF  Normal (Gaussian) cumulative distribution function.
%   p = stat_normcdf(x, mu, sigma)
%   x       point(s) to evaluate (scalar, vector or matrix)
%   mu      mean (default 0)
%   sigma   standard deviation (default 1); must be > 0
%   p       P(X <= x), same size as x
%   Uses p = 0.5*(1 + erf((x-mu)/(sigma*sqrt(2))))
%   Example: p = stat_normcdf(1.96, 0, 1)

if nargin < 1
    error('ru_lib:stat_normcdf:nargin', 'STAT_NORMCDF: need x.');
end
if nargin < 2 || isempty(mu), mu = 0; end
if nargin < 3 || isempty(sigma), sigma = 1; end
if sigma <= 0
    error('ru_lib:stat_normcdf:sigma', 'STAT_NORMCDF: sigma must be > 0 (got %g).', sigma);
end
p = 0.5*(1 + erf((x - mu)./(sigma*sqrt(2))));
end

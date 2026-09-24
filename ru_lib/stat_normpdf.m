function y = stat_normpdf(x, mu, sigma)
%STAT_NORMPDF  Normal (Gaussian) probability density function.
%   y = stat_normpdf(x, mu, sigma)
%   x       point(s) to evaluate (scalar, vector or matrix)
%   mu      mean (default 0)
%   sigma   standard deviation (default 1); must be > 0
%   y       pdf value(s), same size as x
%   Example: y = stat_normpdf(1.5, 0, 1)

if nargin < 1
    error('ru_lib:stat_normpdf:nargin', 'STAT_NORMPDF: need x.');
end
if nargin < 2 || isempty(mu), mu = 0; end
if nargin < 3 || isempty(sigma), sigma = 1; end
if sigma <= 0
    error('ru_lib:stat_normpdf:sigma', 'STAT_NORMPDF: sigma must be > 0 (got %g).', sigma);
end
z = (x - mu) ./ sigma;
y = exp(-0.5*z.^2) ./ (sigma*sqrt(2*pi));
end

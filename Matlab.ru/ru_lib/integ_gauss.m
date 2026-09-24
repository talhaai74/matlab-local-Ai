function I = integ_gauss(f, a, b, npts, varargin)
%INTEG_GAUSS  Gauss-Legendre quadrature of f(x) from a to b (2 to 6 points).
%   I = integ_gauss(f, a, b, npts)
%   f      function handle @(x) ..., or text
%   a, b   integration limits (mapped to [-1, 1])
%   npts   number of Gauss points, 2..6 (default 2)
%   varargin  extra parameters forwarded as f(x, varargin{:})
%   x = (b+a)/2 + (b-a)/2*xd,  dx = (b-a)/2*dxd  (Chapra Sec. 20.4)
%   Call without outputs to print I.
%   Example: I = integ_gauss(@(x) 2/sqrt(pi)*exp(-x.^2), 0, 1.5, 3)
if nargin < 3
    error('ru_lib:integ_gauss:nargin', 'integ_gauss: need at least f, a, b.');
end
if nargin < 4 || isempty(npts), npts = 2; end
switch npts
    case 2
        xd = [-1 1]/sqrt(3);
        c = [1 1];
    case 3
        xd = [-sqrt(3/5) 0 sqrt(3/5)];
        c = [5 8 5]/9;
    case 4
        xd = [-0.861136311594053 -0.339981043584856 0.339981043584856 0.861136311594053];
        c = [0.347854845137454 0.652145154862546 0.652145154862546 0.347854845137454];
    case 5
        xd = [-0.906179845938664 -0.538469310105683 0 0.538469310105683 0.906179845938664];
        c = [0.236926885056189 0.478628670499366 0.568888888888889 0.478628670499366 0.236926885056189];
    case 6
        xd = [-0.932469514203152 -0.661209386466265 -0.238619186083197 ...
            0.238619186083197 0.661209386466265 0.932469514203152];
        c = [0.171324492379170 0.360761573048139 0.467913934572691 ...
            0.467913934572691 0.360761573048139 0.171324492379170];
    otherwise
        error('ru_lib:integ_gauss:npts', 'integ_gauss: npts must be 2, 3, 4, 5 or 6 (got %g).', npts);
end
f = ru_tofunc(f, {'x'});
I = 0;
for k = 1:numel(xd)
    I = I + c(k)*f((b + a)/2 + (b - a)/2*xd(k), varargin{:});
end
I = (b - a)/2*I;
if nargout == 0
    fprintf('integ_gauss: %d-point Gauss-Legendre, I = %.10g\n', npts, I);
end
end

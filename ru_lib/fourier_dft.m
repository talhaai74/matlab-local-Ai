function F = fourier_dft(y)
%FOURIER_DFT  Direct discrete Fourier transform (O(n^2) sum); F equals fft(y).
%   F = fourier_dft(y)
%   y   data vector, n samples (real or complex, row or column)
%   F   F(k+1) = sum_{j=0}^{n-1} y(j+1)*exp(-1i*2*pi*k*j/n), k = 0..n-1
%       (same values and orientation as MATLAB's built-in fft(y), unnormalized)
%   Shows the direct O(n^2) sum behind fft; use the built-in fft for real work.
%   Call without outputs to print F as a table of real/imag parts.
%   Example: F = fourier_dft([6.0 5.7 3.0 5.7 6.0 4.3 5.0 4.3])

if nargin < 1 || isempty(y)
    error('ru_lib:fourier_dft:input', 'FOURIER_DFT: y (data vector) is required and must not be empty.');
end
wasCol = iscolumn(y) && ~isscalar(y);
yv = y(:).';
n = length(yv);
j = 0:n-1;
w0 = 2*pi/n;
F = zeros(1, n);
for k = 0:n-1
    F(k+1) = sum(yv .* exp(-1i*w0*k*j));
end
if wasCol
    F = F.';
end
if nargout == 0
    fprintf('Direct DFT, F(k) for k = 0..%d (n = %d):\n', n-1, n);
    fprintf('   k        real         imag\n');
    for k = 0:n-1
        fprintf('  %3d   %10.4f   %10.4f\n', k, real(F(k+1)), imag(F(k+1)));
    end
end
end

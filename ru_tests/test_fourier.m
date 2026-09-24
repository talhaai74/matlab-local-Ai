function results = test_fourier()
%TEST_FOURIER  Tests for the fourier_* ru_lib functions (chapter: fourier).
results = struct('name', {}, 'pass', {}, 'msg', {});

% --- fourier_dft ---------------------------------------------------------
try
    y = [6.0 5.7 3.0 5.7 6.0 4.3 5.0 4.3];
    F = fourier_dft(y);
    d = max(abs(F - fft(y)));
    results = addtest(results, 'fourier_dft_matches_fft', d < 1e-8, sprintf('max diff = %.3g', d));
catch ME
    results = addtest(results, 'fourier_dft_matches_fft', false, ME.message);
end

try
    y = [1;2;3;4];
    F = fourier_dft(y);
    ok = iscolumn(F) && max(abs(F - fft(y))) < 1e-8;
    results = addtest(results, 'fourier_dft_column_orientation', ok, sprintf('size = [%d %d]', size(F,1), size(F,2)));
catch ME
    results = addtest(results, 'fourier_dft_column_orientation', false, ME.message);
end

try
    txt = evalc('fourier_dft([1 2 3 4])');
    ok = ~isempty(strfind(txt, 'DFT')); %#ok<STREMP>
    results = addtest(results, 'fourier_dft_nargout0', ok, 'printed table');
catch ME
    results = addtest(results, 'fourier_dft_nargout0', false, ME.message);
end

try
    fourier_dft([]);
    results = addtest(results, 'fourier_dft_empty_error', false, 'did not throw');
catch
    results = addtest(results, 'fourier_dft_empty_error', true, 'threw as expected');
end

% --- fourier_spectrum -----------------------------------------------------
try
    n = 8; dt = 0.02; fs = 1/dt;
    tspan = (0:n-1)/fs;
    y = 5 + cos(2*pi*12.5*tspan) + sin(2*pi*18.75*tspan);
    [f, P, A] = fourier_spectrum(y, dt);
    ok = abs(f(2)-12.5) < 1e-9 && abs(P(2)-0.25) < 1e-6 && abs(A(2)-1.0) < 1e-6 ...
        && abs(f(3)-18.75) < 1e-9 && abs(P(3)-0.25) < 1e-6;
    results = addtest(results, 'fourier_spectrum_known_sinusoid', ok, sprintf('f2=%.4f P2=%.4f', f(2), P(2)));
catch ME
    results = addtest(results, 'fourier_spectrum_known_sinusoid', false, ME.message);
end

try
    n = 8; dt = 0.02; fs = 1/dt;
    tspan = (0:n-1)/fs;
    y = 5 + cos(2*pi*12.5*tspan) + sin(2*pi*18.75*tspan); %#ok<NASGU>
    txt = evalc('fourier_spectrum(y, dt)');
    ok = ~isempty(strfind(txt, 'Dominant')); %#ok<STREMP>
    results = addtest(results, 'fourier_spectrum_nargout0', ok, 'printed dominant frequency');
catch ME
    results = addtest(results, 'fourier_spectrum_nargout0', false, ME.message);
end

try
    fourier_spectrum([1 2 3 4]);
    results = addtest(results, 'fourier_spectrum_missing_dt_error', false, 'did not throw');
catch
    results = addtest(results, 'fourier_spectrum_missing_dt_error', true, 'threw as expected');
end

% --- fourier_series ---------------------------------------------------------
try
    T = 4;
    [a0, a, b] = fourier_series('cos(2*pi*t/4)', T);
    ok = length(a) == 5 && abs(a0) < 1e-6 && abs(a(1)-1) < 1e-6 && abs(b(1)) < 1e-6 ...
        && abs(a(2)) < 1e-6 && abs(a(3)) < 1e-6;
    results = addtest(results, 'fourier_series_text_expr_default_N', ok, sprintf('a0=%.4g a1=%.4g', a0, a(1)));
catch ME
    results = addtest(results, 'fourier_series_text_expr_default_N', false, ME.message);
end

try
    T = 2; N = 3;
    f = @(t) 2*(mod(t, T) < T/2) - 1;
    [a0, a, b] = fourier_series(f, T, N);
    ok = abs(a0) < 1e-3 && all(abs(a) < 1e-3) && abs(b(1)-4/pi) < 1e-3 ...
        && abs(b(2)) < 1e-3 && abs(b(3)-4/(3*pi)) < 1e-3;
    results = addtest(results, 'fourier_series_square_wave', ok, sprintf('b1=%.5f b3=%.5f', b(1), b(3)));
catch ME
    results = addtest(results, 'fourier_series_square_wave', false, ME.message);
end

try
    txt = evalc('fourier_series(@(t) cos(2*pi*t/4), 4, 3);'); %#ok<NASGU>
    results = addtest(results, 'fourier_series_nargout0', true, 'plotted without error');
catch ME
    results = addtest(results, 'fourier_series_nargout0', false, ME.message);
end

% --- fourier_sinefit ---------------------------------------------------------
try
    t = (0:0.02:2)';
    y = 3 + 2*cos(2*pi*5*t) - 1*sin(2*pi*5*t);
    [A0, A1, B1, C1, theta] = fourier_sinefit(t, y, 5);
    ok = abs(A0-3) < 1e-6 && abs(A1-2) < 1e-6 && abs(B1+1) < 1e-6 ...
        && abs(C1-sqrt(5)) < 1e-6 && abs(theta-atan2(1,2)) < 1e-6;
    results = addtest(results, 'fourier_sinefit_exact_recovery', ok, sprintf('A0=%.4g A1=%.4g B1=%.4g', A0, A1, B1));
catch ME
    results = addtest(results, 'fourier_sinefit_exact_recovery', false, ME.message);
end

try
    t = (0:0.02:2)'; %#ok<NASGU>
    y = 3 + 2*cos(2*pi*5*t) - 1*sin(2*pi*5*t); %#ok<NASGU>
    txt = evalc('fourier_sinefit(t, y, 5)');
    ok = ~isempty(strfind(txt, 'theta')); %#ok<STREMP>
    results = addtest(results, 'fourier_sinefit_nargout0', ok, 'printed coefficients');
catch ME
    results = addtest(results, 'fourier_sinefit_nargout0', false, ME.message);
end

try
    fourier_sinefit([1 2 3], [1 2], 1);
    results = addtest(results, 'fourier_sinefit_size_mismatch_error', false, 'did not throw');
catch
    results = addtest(results, 'fourier_sinefit_size_mismatch_error', true, 'threw as expected');
end

end

function results = addtest(results, name, pass, msg)
results(end+1) = struct('name', name, 'pass', logical(pass), 'msg', msg);
end

function results = test_linear()
%TEST_LINEAR  Unit tests for the ru_lib "linear" (systems of linear equations) chapter.
results = struct('name', {}, 'pass', {}, 'msg', {});

% ---- lin_gaussnaive ----
try
    x = lin_gaussnaive([2 1; 5 7], [11; 13]);
    ok = all(abs(x - [64/9; -29/9]) < 1e-9);
    results = addresult(results, 'lin_gaussnaive: 2x2 exact', ok, mat2str(x,6));
catch ME
    results = addresult(results, 'lin_gaussnaive: 2x2 exact', false, ME.message);
end

try
    x = lin_gaussnaive([2 1; 5 7], [11 13]);  % row-vector b
    ok = all(abs(x - [64/9; -29/9]) < 1e-9);
    results = addresult(results, 'lin_gaussnaive: row-vector b', ok, mat2str(x,6));
catch ME
    results = addresult(results, 'lin_gaussnaive: row-vector b', false, ME.message);
end

try
    lin_gaussnaive([1 2 3; 4 5 6], [1;2]);
    results = addresult(results, 'lin_gaussnaive: non-square errors', false, 'did not error');
catch ME
    ok = ~isempty(strfind(ME.identifier, 'notSquare'));
    results = addresult(results, 'lin_gaussnaive: non-square errors', ok, ME.identifier);
end

try
    lin_gaussnaive([0 1; 1 1], [1; 2]);
    results = addresult(results, 'lin_gaussnaive: zero pivot errors', false, 'did not error');
catch ME
    ok = ~isempty(strfind(ME.identifier, 'zeroPivot'));
    results = addresult(results, 'lin_gaussnaive: zero pivot errors', ok, ME.identifier);
end

try
    out = evalc('lin_gaussnaive([2 1; 5 7], [11; 13]);');
    ok = ~isempty(strtrim(out));
    results = addresult(results, 'lin_gaussnaive: nargout=0 prints', ok, 'checked non-empty output');
catch ME
    results = addresult(results, 'lin_gaussnaive: nargout=0 prints', false, ME.message);
end

% ---- lin_gausspivot ----
try
    x = lin_gausspivot([0 2 1; 1 1 1; 2 -1 1], [7; 6; 3]);
    ok = all(abs(x - [1;2;3]) < 1e-9);
    results = addresult(results, 'lin_gausspivot: zero pivot handled', ok, mat2str(x,6));
catch ME
    results = addresult(results, 'lin_gausspivot: zero pivot handled', false, ME.message);
end

try
    out = evalc('x = lin_gausspivot([2 1; 5 7], [11; 13]);');
    ok = isempty(strtrim(out));
    results = addresult(results, 'lin_gausspivot: show default false is quiet', ok, out);
catch ME
    results = addresult(results, 'lin_gausspivot: show default false is quiet', false, ME.message);
end

try
    out = evalc('lin_gausspivot([0 2 1; 1 1 1; 2 -1 1], [7; 6; 3], true);');
    ok = ~isempty(strfind(out, 'Swap'));
    results = addresult(results, 'lin_gausspivot: show=true prints swap', ok, 'checked for ''Swap''');
catch ME
    results = addresult(results, 'lin_gausspivot: show=true prints swap', false, ME.message);
end

try
    lin_gausspivot([0 0; 1 1], [1; 2]);
    results = addresult(results, 'lin_gausspivot: singular errors', false, 'did not error');
catch ME
    ok = ~isempty(strfind(ME.identifier, 'singular'));
    results = addresult(results, 'lin_gausspivot: singular errors', ok, ME.identifier);
end

% ---- lin_gaussjordan ----
try
    x = lin_gaussjordan([2 1 -1; -3 -1 2; -2 1 2], [8; -11; -3]);
    ok = all(abs(x - [2;3;-1]) < 1e-9);
    results = addresult(results, 'lin_gaussjordan: 3x3 exact', ok, mat2str(x,6));
catch ME
    results = addresult(results, 'lin_gaussjordan: 3x3 exact', false, ME.message);
end

try
    x = lin_gaussjordan([0 1; 1 1], [1; 3]);   % needs internal pivoting
    ok = all(abs(x - [2;1]) < 1e-9);
    results = addresult(results, 'lin_gaussjordan: zero pivot handled', ok, mat2str(x,6));
catch ME
    results = addresult(results, 'lin_gaussjordan: zero pivot handled', false, ME.message);
end

% ---- lin_tridiag ----
try
    x = lin_tridiag([0 -1 -1], [2 2 2], [-1 -1 0], [1; 0; 1]);
    ok = all(abs(x - [1;1;1]) < 1e-9);
    results = addresult(results, 'lin_tridiag: 3x3 exact', ok, mat2str(x,6));
catch ME
    results = addresult(results, 'lin_tridiag: 3x3 exact', false, ME.message);
end

try
    e = [0 -50 -80 -200]; f = [150 130 280 200]; g = [-50 -80 -200 0]; r = [0 0 0 1500];  % row vectors
    x = lin_tridiag(e, f, g, r);
    ok = all(abs(x - [15;45;63.75;71.25]) < 1e-6);
    results = addresult(results, 'lin_tridiag: springs, row-vector args', ok, mat2str(x,6));
catch ME
    results = addresult(results, 'lin_tridiag: springs, row-vector args', false, ME.message);
end

try
    lin_tridiag([0 1], [1], [1 0], [1 1]);
    results = addresult(results, 'lin_tridiag: size mismatch errors', false, 'did not error');
catch ME
    ok = ~isempty(strfind(ME.identifier, 'sizeMismatch'));
    results = addresult(results, 'lin_tridiag: size mismatch errors', ok, ME.identifier);
end

% ---- lin_lu / lin_lusolve ----
try
    A = [0 1; 1 1];
    [L,U,P] = lin_lu(A);
    ok = max(max(abs(P*A - L*U))) < 1e-9;
    results = addresult(results, 'lin_lu: P*A = L*U', ok, sprintf('resid=%.3g', max(max(abs(P*A-L*U)))));
catch ME
    results = addresult(results, 'lin_lu: P*A = L*U', false, ME.message);
end

try
    A = [0 1; 1 1];
    [L,U,P] = lin_lu(A);
    x = lin_lusolve(L, U, P, [1; 3]);
    ok = all(abs(x - [2;1]) < 1e-9);
    results = addresult(results, 'lin_lusolve: single RHS', ok, mat2str(x,6));
catch ME
    results = addresult(results, 'lin_lusolve: single RHS', false, ME.message);
end

try
    A = [0 1; 1 1];
    [L,U,P] = lin_lu(A);
    X = lin_lusolve(L, U, P, [1 5; 3 4]);
    ok = all(all(abs(X - [2 -1; 1 5]) < 1e-9));
    results = addresult(results, 'lin_lusolve: multi-column RHS', ok, mat2str(X,6));
catch ME
    results = addresult(results, 'lin_lusolve: multi-column RHS', false, ME.message);
end

try
    lin_lu([1 2 3; 4 5 6]);
    results = addresult(results, 'lin_lu: non-square errors', false, 'did not error');
catch ME
    ok = ~isempty(strfind(ME.identifier, 'notSquare'));
    results = addresult(results, 'lin_lu: non-square errors', ok, ME.identifier);
end

% ---- lin_cholesky ----
try
    A = [4 2; 2 5];
    U = lin_cholesky(A);
    ok = max(max(abs(A - U'*U))) < 1e-9 && all(all(abs(U - [2 1; 0 2]) < 1e-9));
    results = addresult(results, 'lin_cholesky: 2x2 exact', ok, mat2str(U,6));
catch ME
    results = addresult(results, 'lin_cholesky: 2x2 exact', false, ME.message);
end

try
    lin_cholesky([1 2; 2 1]);   % symmetric but not positive definite
    results = addresult(results, 'lin_cholesky: not pos def errors', false, 'did not error');
catch ME
    ok = ~isempty(strfind(ME.identifier, 'notPosDef'));
    results = addresult(results, 'lin_cholesky: not pos def errors', ok, ME.identifier);
end

try
    lin_cholesky([1 2; 3 4]);   % not symmetric
    results = addresult(results, 'lin_cholesky: not symmetric errors', false, 'did not error');
catch ME
    ok = ~isempty(strfind(ME.identifier, 'notSymmetric'));
    results = addresult(results, 'lin_cholesky: not symmetric errors', ok, ME.identifier);
end

% ---- lin_gaussseidel ----
try
    A = [3 -0.1 -0.2; 0.1 7 -0.3; 0.3 -0.2 10];
    b = [7.85; -19.3; 71.4];
    [x, ea, iter] = lin_gaussseidel(A, b);   % default es=1e-4, maxit=50
    ok = all(abs(x - [3; -2.5; 7]) < 1e-3) && iter < 50;
    results = addresult(results, 'lin_gaussseidel: default es/maxit converge', ok, sprintf('x=%s iter=%d ea=%.3g', mat2str(x,6), iter, ea));
catch ME
    results = addresult(results, 'lin_gaussseidel: default es/maxit converge', false, ME.message);
end

try
    A = [3 -0.1 -0.2; 0.1 7 -0.3; 0.3 -0.2 10];
    b = [7.85; -19.3; 71.4];
    [~, ~, iter] = lin_gaussseidel(A, b, 0, 5);
    ok = iter == 5;
    results = addresult(results, 'lin_gaussseidel: es=0 runs exactly maxit', ok, sprintf('iter=%d', iter));
catch ME
    results = addresult(results, 'lin_gaussseidel: es=0 runs exactly maxit', false, ME.message);
end

try
    out = evalc('lin_gaussseidel([3 -0.1 -0.2; 0.1 7 -0.3; 0.3 -0.2 10], [7.85; -19.3; 71.4]);');
    ok = ~isempty(strtrim(out));
    results = addresult(results, 'lin_gaussseidel: nargout=0 prints', ok, 'checked non-empty output');
catch ME
    results = addresult(results, 'lin_gaussseidel: nargout=0 prints', false, ME.message);
end

try
    lastwarn('');
    evalc('lin_gaussseidel([1 2; 3 1], [5; 5], 1e-4, 50);');
    [~, wid] = lastwarn();
    ok = strcmp(wid, 'ru_lib:lin_gaussseidel:notDiagDominant');
    results = addresult(results, 'lin_gaussseidel: warns if not diag dominant', ok, wid);
catch ME
    results = addresult(results, 'lin_gaussseidel: warns if not diag dominant', false, ME.message);
end

try
    A = [3 -0.1 -0.2; 0.1 7 -0.3; 0.3 -0.2 10];
    b = [7.85; -19.3; 71.4];
    x1 = lin_gaussseidel(A, b, 1e-6, 100, 1);
    x2 = lin_gaussseidel(A, b, 1e-6, 100);   % default lambda = 1
    ok = all(abs(x1 - x2) < 1e-9);
    results = addresult(results, 'lin_gaussseidel: default lambda = 1', ok, mat2str(x1-x2,3));
catch ME
    results = addresult(results, 'lin_gaussseidel: default lambda = 1', false, ME.message);
end

% ---- lin_jacobi ----
try
    A = [3 -0.1 -0.2; 0.1 7 -0.3; 0.3 -0.2 10];
    b = [7.85; -19.3; 71.4];
    [x, ~, iter] = lin_jacobi(A, b, 1e-4, 100);
    ok = all(abs(x - [3; -2.5; 7]) < 1e-2) && iter < 100;
    results = addresult(results, 'lin_jacobi: converges to known solution', ok, sprintf('x=%s iter=%d', mat2str(x,6), iter));
catch ME
    results = addresult(results, 'lin_jacobi: converges to known solution', false, ME.message);
end

try
    A = [3 -0.1 -0.2; 0.1 7 -0.3; 0.3 -0.2 10];
    b = [7.85; -19.3; 71.4];
    [~, ~, iter] = lin_jacobi(A, b, 0, 7);
    ok = iter == 7;
    results = addresult(results, 'lin_jacobi: es=0 runs exactly maxit', ok, sprintf('iter=%d', iter));
catch ME
    results = addresult(results, 'lin_jacobi: es=0 runs exactly maxit', false, ME.message);
end

try
    out = evalc('lin_jacobi([3 -0.1 -0.2; 0.1 7 -0.3; 0.3 -0.2 10], [7.85; -19.3; 71.4]);');
    ok = ~isempty(strtrim(out));
    results = addresult(results, 'lin_jacobi: nargout=0 prints', ok, 'checked non-empty output');
catch ME
    results = addresult(results, 'lin_jacobi: nargout=0 prints', false, ME.message);
end

try
    lastwarn('');
    evalc('lin_jacobi([1 2; 3 1], [5; 5]);');
    [~, wid] = lastwarn();
    ok = strcmp(wid, 'ru_lib:lin_jacobi:notDiagDominant');
    results = addresult(results, 'lin_jacobi: warns if not diag dominant', ok, wid);
catch ME
    results = addresult(results, 'lin_jacobi: warns if not diag dominant', false, ME.message);
end

% ---- lin_cramer ----
try
    x = lin_cramer([1 1; 2 -1], [3; 0]);
    ok = all(abs(x - [1;2]) < 1e-9);
    results = addresult(results, 'lin_cramer: 2x2 exact', ok, mat2str(x,6));
catch ME
    results = addresult(results, 'lin_cramer: 2x2 exact', false, ME.message);
end

try
    x = lin_cramer([1 1 1; 0 2 5; 2 5 -1], [6; -4; 27]);
    ok = all(abs(x - [5;3;-2]) < 1e-9);
    results = addresult(results, 'lin_cramer: 3x3 exact', ok, mat2str(x,6));
catch ME
    results = addresult(results, 'lin_cramer: 3x3 exact', false, ME.message);
end

try
    x = lin_cramer([1 1; 2 -1], [3 0]);   % row-vector b
    ok = all(abs(x - [1;2]) < 1e-9);
    results = addresult(results, 'lin_cramer: row-vector b', ok, mat2str(x,6));
catch ME
    results = addresult(results, 'lin_cramer: row-vector b', false, ME.message);
end

try
    lin_cramer([1 2; 2 4], [1; 2]);
    results = addresult(results, 'lin_cramer: singular errors', false, 'did not error');
catch ME
    ok = ~isempty(strfind(ME.identifier, 'singular'));
    results = addresult(results, 'lin_cramer: singular errors', ok, ME.identifier);
end

try
    out = evalc('lin_cramer([1 1; 2 -1], [3; 0]);');
    ok = ~isempty(strtrim(out));
    results = addresult(results, 'lin_cramer: nargout=0 prints', ok, 'checked non-empty output');
catch ME
    results = addresult(results, 'lin_cramer: nargout=0 prints', false, ME.message);
end

end

function results = addresult(results, name, pass, msg)
results(end+1) = struct('name', name, 'pass', logical(pass), 'msg', msg);
end

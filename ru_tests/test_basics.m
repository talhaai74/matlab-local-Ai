function results = test_basics()
%TEST_BASICS  Runtime sanity tests for the "basics" (MATLAB fundamentals) chapter.
%   This chapter defines no ru_lib functions (prefix util_): its knowledge
%   base teaches base-MATLAB idioms directly. These tests instead check the
%   runtime facts that ru_kb/examples/ex_basics_*.m rely on (colon/linspace,
%   indexing, R2016b implicit expansion, sparse/diag, find/vectorization,
%   local functions in a file, and csv/xls round trips), so a version
%   mismatch surfaces here instead of as a mysterious script error later.
results = struct('name', {}, 'pass', {}, 'msg', {});

try
    c1 = 3:7;
    lv = linspace(0,1,11);
    ok = isequal(c1,[3 4 5 6 7]) && numel(lv)==11 && abs(lv(1))<1e-12 && abs(lv(end)-1)<1e-12;
    results = addResult(results, 'vector_colon_linspace', ok, ...
        sprintf('c1 has %d elems, linspace has %d elems', numel(c1), numel(lv)));
catch ME
    results = addResult(results, 'vector_colon_linspace', false, ME.message);
end

try
    A = [1 2 3; 4 5 6; 7 8 9];
    ok = A(2,3)==6 && isequal(A(2:3,1:2),[4 5;7 8]) && isequal(A(:,1),[1;4;7]);
    results = addResult(results, 'matrix_indexing', ok, 'A(2,3), A(2:3,1:2), A(:,1)');
catch ME
    results = addResult(results, 'matrix_indexing', false, ME.message);
end

try
    rowv = [1 2 3]; colv = [4;2;1];
    bc = rowv .* colv;
    ok = isequal(bc, [4 8 12; 2 4 6; 1 2 3]);
    results = addResult(results, 'elementwise_broadcast_R2016b', ok, ...
        'requires MATLAB R2016b or newer for implicit expansion of 1x3 .* 3x1');
catch ME
    results = addResult(results, 'elementwise_broadcast_R2016b', false, ...
        ['implicit expansion unsupported on this MATLAB: ' ME.message]);
end

try
    p = [1 2 3]*[4;2;1];
    ok = p==11;
    results = addResult(results, 'matrix_multiplication', ok, sprintf('[1 2 3]*[4;2;1] = %g', p));
catch ME
    results = addResult(results, 'matrix_multiplication', false, ME.message);
end

try
    D = diag([-3 4 2]);
    S = sparse([1,3,5],[2,3,4],[10 11 12]);
    T = full(S);
    ok = isequal(D,[-3 0 0;0 4 0;0 0 2]) && ...
        isequal(T,[0 10 0 0;0 0 0 0;0 0 11 0;0 0 0 0;0 0 0 12]);
    results = addResult(results, 'diag_and_sparse', ok, 'diag(v) and sparse/full round trip');
catch ME
    results = addResult(results, 'diag_and_sparse', false, ME.message);
end

try
    x = sin(linspace(0,10*pi,100));
    n_loop = 0;
    for k = 1:length(x)
        if x(k) > 0
            n_loop = n_loop + 1;
        end
    end
    n_vec = length(find(x > 0));
    ok = n_loop==49 && n_vec==49 && n_loop==n_vec;
    results = addResult(results, 'find_vectorization', ok, sprintf('loop=%d vec=%d', n_loop, n_vec));
catch ME
    results = addResult(results, 'find_vectorization', false, ME.message);
end

try
    s = sum((1:100).^2);
    ok = s==338350;
    results = addResult(results, 'sum_of_squares_vectorized', ok, sprintf('sum=%d', s));
catch ME
    results = addResult(results, 'sum_of_squares_vectorized', false, ME.message);
end

try
    Atri = heronArea(3,4,5);
    ok = abs(Atri-6) < 1e-9;
    results = addResult(results, 'function_mfile_local_function_heron', ok, sprintf('area=%g', Atri));
catch ME
    results = addResult(results, 'function_mfile_local_function_heron', false, ME.message);
end

try
    A2 = [2 3 4 7; 5 6 8 9; 1 2 4 5];
    f = fullfile(tempdir,'ru_test_basics_tmp.csv');
    csvwrite(f, A2);
    A2b = csvread(f);
    if exist(f,'file')==2
        delete(f);
    end
    ok = isequal(A2,A2b);
    results = addResult(results, 'csv_write_read_roundtrip', ok, 'csvwrite/csvread round trip');
catch ME
    results = addResult(results, 'csv_write_read_roundtrip', false, ME.message);
end

try
    C = {'Time','Temperature'; 9,25; 12,27; 3,28; 6,24};
    f = fullfile(tempdir,'ru_test_basics_tmp.xlsx');
    xlswrite(f, C);
    num = xlsread(f);
    if exist(f,'file')==2
        delete(f);
    end
    ok = isequal(num(:,2), [25;27;28;24]);
    results = addResult(results, 'xls_write_read_roundtrip', ok, 'xlswrite/xlsread round trip');
catch ME
    results = addResult(results, 'xls_write_read_roundtrip', false, ME.message);
end

end

function results = addResult(results, name, pass, msg)
results(end+1).name = name;
results(end).pass = logical(pass);
results(end).msg = msg;
end

function A = heronArea(a,b,c)
s = (a+b+c)/2;
A = sqrt(s*(s-a)*(s-b)*(s-c));
end

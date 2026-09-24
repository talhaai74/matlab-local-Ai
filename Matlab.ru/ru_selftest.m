function ok = ru_selftest(what, pattern)
%RU_SELFTEST  Offline self-test of the ru solver library and verified examples.
%   ru_selftest               run the library tests and every solved example
%   ru_selftest lib           only the library tests (ru_tests/test_*.m)
%   ru_selftest examples      only the solved examples (ru_kb/examples/*.m)
%   ru_selftest examples roots   only examples whose file name contains "roots"
%   ok = ru_selftest(...)     true when everything passed
%   Each example is run in its own workspace; its % CHECK: lines must all be
%   true. Examples marked % SELFTEST: skip (they need data files) are skipped.
%   No AI model is needed.
if nargin < 1 || isempty(what)
    what = 'all';
end
if nargin < 2
    pattern = '';
end
root = fileparts(mfilename('fullpath'));
addpath(fullfile(root, 'ru_lib'));
addpath(fullfile(root, 'ru_tests'));
isOctave = exist('OCTAVE_VERSION', 'builtin') ~= 0;
oldVis = get(0, 'DefaultFigureVisible');
set(0, 'DefaultFigureVisible', 'off');
cleanup = onCleanup(@() set(0, 'DefaultFigureVisible', oldVis));
figsBefore = findall(0, 'Type', 'figure');
nPass = 0;
nFail = 0;
nSkip = 0;
failures = {};

if any(strcmpi(what, {'all', 'lib'}))
    fprintf('\n== ru_lib tests ==\n');
    d = dir(fullfile(root, 'ru_tests', 'test_*.m'));
    for i = 1:numel(d)
        name = regexprep(d(i).name, '\.m$', '');
        try
            r = feval(name);
        catch ME
            nFail = nFail + 1;
            failures{end+1} = sprintf('%s: %s', name, ME.message); %#ok<AGROW>
            continue
        end
        for k = 1:numel(r)
            if r(k).pass
                nPass = nPass + 1;
            elseif ~isempty(regexp(r(k).msg, 'graphics toolkit|xlswrite|xlsread|io package', 'once')) && isOctave
                nSkip = nSkip + 1;
            else
                nFail = nFail + 1;
                failures{end+1} = sprintf('%s/%s: %s', name, r(k).name, r(k).msg); %#ok<AGROW>
            end
        end
        fprintf('  %-16s %d checks\n', name, numel(r));
    end
end

if any(strcmpi(what, {'all', 'examples'}))
    fprintf('\n== solved examples ==\n');
    d = dir(fullfile(root, 'ru_kb', 'examples', '*.m'));
    tmp = fullfile(tempdir, sprintf('ru_selftest_%d', round(rand*1e6)));
    mkdir(tmp);
    addpath(tmp);
    rmTmp = onCleanup(@() ru_selftest_rmdir(tmp));
    for i = 1:numel(d)
        if ~isempty(pattern) && isempty(strfind(d(i).name, pattern))
            continue
        end
        f = fullfile(root, 'ru_kb', 'examples', d(i).name);
        [code, checks, skip] = ru_selftest_parse(f);
        if isempty(code)
            nFail = nFail + 1;
            failures{end+1} = sprintf('%s: no %% CODE: section', d(i).name); %#ok<AGROW>
            continue
        end
        if skip
            nSkip = nSkip + 1;
            fprintf('  SKIP %s\n', d(i).name);
            continue
        end
        if isOctave
            code = ru_selftest_splitFunctions(code, tmp);
        end
        script = fullfile(tmp, sprintf('ru_ex_%03d.m', i));
        fid = fopen(script, 'w');
        fprintf(fid, '%s\n', code);
        fclose(fid);
        clear(sprintf('ru_ex_%03d', i));
        t0 = tic;
        [passed, msg] = ru_selftest_run(script, checks);
        if passed
            nPass = nPass + 1;
            fprintf('  ok   %-60s %5.1f s\n', d(i).name, toc(t0));
        else
            nFail = nFail + 1;
            failures{end+1} = sprintf('%s: %s', d(i).name, msg); %#ok<AGROW>
            fprintf('  FAIL %-60s %s\n', d(i).name, msg);
        end
        newFigs = setdiff(findall(0, 'Type', 'figure'), figsBefore);
        if ~isempty(newFigs)
            delete(newFigs);
        end
    end
end

fprintf('\n== ru_selftest: %d passed, %d failed, %d skipped ==\n', nPass, nFail, nSkip);
for k = 1:numel(failures)
    fprintf(2, '  FAILED %s\n', failures{k});
end
ok = nFail == 0;
if nargout == 0
    clear ok
end
end

function [code, checks, skip] = ru_selftest_parse(f)
code = '';
checks = {};
skip = false;
txt = strrep(fileread(f), char(13), '');
lines = regexp(txt, '\n', 'split');
for k = 1:numel(lines)
    tok = regexp(lines{k}, '^\s*%\s*(CHECK|SELFTEST|CODE)\s*:\s*(.*)$', 'tokens', 'once');
    if isempty(tok)
        continue
    end
    switch tok{1}
        case 'CHECK'
            checks{end+1} = strtrim(tok{2}); %#ok<AGROW>
        case 'SELFTEST'
            skip = ~isempty(strfind(lower(tok{2}), 'skip'));
        case 'CODE'
            code = strjoin(lines(k+1:end), char(10));
            return
    end
end
end

function [ru__passed, ru__msg] = ru_selftest_run(ru__script, ru__checks)
ru__passed = false;
ru__msg = '';
try
    evalc('run(ru__script)');
catch ru__err
    ru__msg = ['error: ' ru__err.message];
    return
end
for ru__k = 1:numel(ru__checks)
    try
        ru__v = eval(ru__checks{ru__k});
    catch ru__err
        ru__msg = sprintf('CHECK "%s" failed to evaluate: %s', ru__checks{ru__k}, ru__err.message);
        return
    end
    if ~(islogical(ru__v) || isnumeric(ru__v)) || isempty(ru__v) || ~all(ru__v(:))
        ru__msg = sprintf('CHECK "%s" is false', ru__checks{ru__k});
        return
    end
end
ru__passed = true;
end

function code = ru_selftest_splitFunctions(code, tmp)
% GNU Octave cannot run scripts whose local functions come after the code:
% move each local function into its own file.
lines = regexp(code, '\n', 'split');
f = find(~cellfun(@isempty, regexp(lines, '^function\>', 'once')), 1);
if isempty(f)
    return
end
funLines = lines(f:end);
starts = find(~cellfun(@isempty, regexp(funLines, '^function\>', 'once')));
starts(end+1) = numel(funLines) + 1;
for k = 1:numel(starts) - 1
    body = funLines(starts(k):starts(k+1)-1);
    name = regexp(body{1}, '^function\s+(?:\[[^\]]*\]\s*=\s*|\w+\s*=\s*)?([A-Za-z]\w*)', 'tokens', 'once');
    fid = fopen(fullfile(tmp, [name{1} '.m']), 'w');
    fprintf(fid, '%s\n', strjoin(body, char(10)));
    fclose(fid);
end
code = strjoin(lines(1:f-1), char(10));
end

function ru_selftest_rmdir(tmp)
try
    rmpath(tmp);
    rmdir(tmp, 's');
catch
end
end

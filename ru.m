function ru(varargin)
%RU  Local AI that writes and runs MATLAB code for your problems (CE206).
%   ru <problem text>   solve a problem typed on the same line
%   ru                  open a box to paste a problem (pre-filled from the clipboard)
%   ru paste            solve the problem that is on the clipboard
%   ru ai <problem>     always ask the AI (skip the stored slide solutions)
%   ru status           check MATLAB, toolboxes, AI engine and model
%   ru start            start the AI engine (Ollama) from this folder
%   ru model            show the model in use;  ru model <name> | ru model auto
%   ru list             list the solver library and your own M-files
%   ru last             show the last code ru ran
%   ru save <name>      save the last code as <name>.m in the current folder
%   ru test             run the offline self-test of the library and examples
%   ru help             show this help
%
%   Problems with quotes, brackets or several lines: type just  ru  and paste
%   the text into the box (MATLAB cannot read those after "ru " on one line).

root = fileparts(mfilename('fullpath'));
local_setup(root);

args = varargin;
for k = 1:numel(args)
    if isa(args{k}, 'string')
        args{k} = char(strjoin(args{k}(:)', ' '));
    elseif ~ischar(args{k})
        try
            args{k} = mat2str(args{k});
        catch
            args{k} = '';
        end
    end
end
nArgs = numel(args);
cmd = '';
if nArgs >= 1
    cmd = lower(strtrim(args{1}));
end

if nArgs == 1 || (nArgs == 2 && any(strcmp(cmd, {'model', 'save'})))
    switch cmd
        case '--startup'
            return
        case {'help', '-h', '--help', '?'}
            help('ru');
            return
        case {'status', 'check'}
            local_status(root);
            return
        case 'start'
            local_engine(root, true);
            return
        case 'model'
            local_modelCommand(root, args);
            return
        case 'list'
            local_list(root);
            return
        case 'last'
            local_last(root);
            return
        case 'save'
            if nArgs == 2
                local_saveLast(root, args{2});
                return
            end
        case 'test'
            local_test(root);
            return
        case {'paste', 'clip', 'clipboard'}
            prompt = local_clipboard();
            if isempty(strtrim(prompt))
                fprintf(2, '[ru] The clipboard is empty. Copy the problem text first, then run: ru paste\n');
                return
            end
            fprintf('[ru] Problem from the clipboard:\n%s\n', local_preview(prompt, 800));
            local_solve(root, prompt, false);
            return
    end
end

forceAI = false;
if nArgs == 0
    prompt = local_askProblem();
elseif strcmp(cmd, 'ai') && nArgs > 1
    forceAI = true;
    prompt = strjoin(args(2:end), ' ');
else
    prompt = strjoin(args, ' ');
end
if isempty(strtrim(prompt))
    return
end
local_solve(root, prompt, forceAI);
end

% =====================================================================
% Setup, input and small commands
% =====================================================================

function local_setup(root)
dirs = {root, fullfile(root, 'ru_lib'), fullfile(root, 'generated')};
for k = 1:numel(dirs)
    if exist(dirs{k}, 'dir') == 7 && ~local_onPath(dirs{k})
        addpath(dirs{k}, '-end');
    end
end
end

function tf = local_onPath(d)
p = strsplit(path, pathsep);
d = regexprep(d, '[\\/]+$', '');
tf = any(strcmpi(p, d));
end

function d = local_brain(root)
d = fullfile(root, 'brain');
if exist(d, 'dir') ~= 7
    mkdir(d);
end
end

function txt = local_clipboard()
txt = '';
try
    txt = clipboard('paste');
catch
end
if ~ischar(txt)
    txt = '';
end
end

function txt = local_askProblem()
txt = '';
if usejava('desktop')
    def = local_clipboard();
    if numel(def) > 8000
        def = '';
    end
    lines = regexp(strrep(def, char(13), ''), '\n', 'split');
    a = {};
    try
        a = inputdlg({'Paste or type the problem (edit it if needed), then press OK:'}, ...
            'ru', [20 120], {char(lines)});
    catch
        try
            a = inputdlg({'Paste or type the problem, then press OK:'}, 'ru', [20 120]);
        catch
            a = {};
        end
    end
    if isempty(a)
        return
    end
    v = a{1};
    if size(v, 1) > 1
        txt = strjoin(cellstr(v)', sprintf('\n'));
    else
        txt = v;
    end
else
    clip = strtrim(local_clipboard());
    if ~isempty(clip)
        fprintf('[ru] Using the problem on the clipboard:\n%s\n', local_preview(clip, 800));
        txt = clip;
    else
        txt = input('ru> Type the problem on one line: ', 's');
    end
end
end

function s = local_preview(s, n)
s = strtrim(s);
if numel(s) > n
    s = [s(1:n) ' ...'];
end
end

function local_last(root)
f = fullfile(local_brain(root), 'last_code.txt');
if exist(f, 'file') ~= 2
    fprintf('[ru] Nothing has been run yet.\n');
    return
end
fprintf('%s\n', fileread(f));
end

function local_saveLast(root, name)
f = fullfile(local_brain(root), 'last_code.txt');
if exist(f, 'file') ~= 2
    fprintf(2, '[ru] Nothing to save yet.\n');
    return
end
name = regexprep(name, '\.m$', '');
if ~isvarname(name)
    fprintf(2, '[ru] "%s" is not a valid MATLAB file name (letters, digits, _; start with a letter).\n', name);
    return
end
target = fullfile(pwd, [name '.m']);
if exist(target, 'file') == 2
    fprintf(2, '[ru] %s already exists; choose another name.\n', target);
    return
end
local_writeText(target, fileread(f));
fprintf('[ru] Saved %s\n', target);
end

function local_test(root)
if exist(fullfile(root, 'ru_selftest.m'), 'file') == 2
    ru_selftest();
else
    fprintf(2, '[ru] ru_selftest.m is missing from %s\n', root);
end
end

function local_list(root)
kb = local_kb(root);
fprintf('\n== ru solver library (%s) ==\n', fullfile(root, 'ru_lib'));
lastPrefix = '';
for k = 1:numel(kb.lib)
    L = kb.lib(k);
    if ~strcmp(L.prefix, lastPrefix)
        fprintf('\n  [%s]\n', L.prefix);
        lastPrefix = L.prefix;
    end
    fprintf('  %-22s %s\n', L.name, L.h1);
end
fprintf('\n== Solved examples: %d in %s ==\n', numel(kb.examples), fullfile(root, 'ru_kb', 'examples'));
fprintf('\n== Your own M-files ==\n');
uf = kb.userFiles;
lastFolder = '';
for k = 1:numel(uf)
    if ~strcmp(uf(k).folder, lastFolder)
        fprintf('\n  %s\n', uf(k).folder);
        lastFolder = uf(k).folder;
    end
    if uf(k).isFunction
        fprintf('    %-26s %s\n', [uf(k).name '.m'], uf(k).signature);
    else
        fprintf('    %-26s (script)\n', [uf(k).name '.m']);
    end
end
fprintf('\n');
end

% =====================================================================
% Solving a problem
% =====================================================================

function local_solve(root, prompt, forceAI)
t0 = tic;
prompt = local_tidyPrompt(local_ascii(prompt));
if isempty(prompt)
    return
end
local_log(root, sprintf('\n==== %s ====\nPROMPT:\n%s', datestr(now, 'yyyy-mm-dd HH:MM:SS'), prompt));
kb = local_kb(root);
env = local_env();
ctx = local_retrieve(kb, prompt);

% 1) A stored, verified solution of exactly this problem: run it directly.
if ~forceAI && ctx.direct > 0
    ex = kb.examples(ctx.direct);
    fprintf('[ru] This is the solved example "%s" (%s).\n', ex.title, ex.source);
    fprintf('[ru] Running its verified solution. To make the AI write new code instead type:  ru ai <problem>\n');
    [ok, info] = local_runCode(root, kb, ex.code, 'stored solution');
    if ok
        local_finish(root, ex.code, t0, 'stored solution');
        return
    end
    fprintf(2, '[ru] The stored solution failed here (%s). Asking the AI instead.\n', local_firstLine(info.message));
end

% 2) Ask the local model, run its code, feed errors back until it works.
[host, model] = local_engine(root, false);
if isempty(model)
    return
end
[baseMsgs, numCtx] = local_buildMessages(root, prompt, kb, env, ctx);
if ~isempty(ctx.topics)
    fprintf('[ru] Topic: %s', strjoin(ctx.topics, ', '));
    if ~isempty(ctx.examples)
        fprintf(' | closest solved example: %s', kb.examples(ctx.examples(1)).title);
    end
    fprintf('\n');
end

temps = [0 0.2 0.45 0.7];
maxAttempts = numel(temps);
msgs = baseMsgs;
prevCode = '';
for attempt = 1:maxAttempts
    fprintf('[ru] Asking %s (attempt %d of %d)', model, attempt, maxAttempts);
    if attempt == 1
        fprintf(' - the first call can take a minute while the model loads');
    end
    fprintf('...\n');
    [reply, cut, err] = local_chat(host, model, msgs, temps(attempt), numCtx);
    if ~isempty(err)
        fprintf(2, '[ru] AI engine error: %s\n', err);
        local_log(root, ['ENGINE ERROR: ' err]);
        local_engineHelp();
        return
    end
    code = local_sanitize(local_extractCode(reply));
    problem = local_precheck(code, kb);
    if isempty(problem)
        [ok, info] = local_runCode(root, kb, code, sprintf('AI attempt %d', attempt));
        if ok
            local_finish(root, code, t0, sprintf('AI attempt %d', attempt));
            return
        end
        feedback = local_feedback(info, kb, env, code, cut, attempt == maxAttempts - 1);
        local_log(root, sprintf('ATTEMPT %d CODE:\n%s\nERROR: %s', attempt, code, info.message));
    else
        fprintf(2, '[ru] Rejected the generated code: %s\n', local_firstLine(problem));
        feedback = [problem sprintf('\n\nRewrite the COMPLETE script in one ```matlab block.')];
        local_log(root, sprintf('ATTEMPT %d REJECTED:\n%s\nREASON: %s', attempt, code, problem));
    end
    if ~isempty(code) && strcmp(code, prevCode)
        feedback = [feedback sprintf('\nYou returned the same code as before. Use a different, simpler approach.')];
    end
    prevCode = code;
    shown = code;
    if isempty(shown)
        shown = strtrim(reply);
    end
    msgs = [baseMsgs, local_msg('assistant', ['```matlab' char(10) shown char(10) '```']), ...
        local_msg('user', feedback)];
    if attempt < maxAttempts
        fprintf('[ru] Sending the problem back to the AI to fix it...\n');
    end
end
fprintf(2, '\n[ru] Could not get working code after %d attempts.\n', maxAttempts);
fprintf(2, '[ru] Tips: paste the complete problem with all numbers and name the method (bisection, RK4, ...),\n');
fprintf(2, '[ru]       or split a long problem into parts. See the last code with: ru last\n');
local_writeText(fullfile(local_brain(root), 'last_code.txt'), prevCode);
local_log(root, 'RESULT: FAILED');
end

function m = local_msg(role, content)
m = struct('role', role, 'content', content);
end

function [ok, info] = local_runCode(root, kb, code, label)
info = local_emptyInfo();
[code, funcs, scriptEmpty] = local_arrange(code);
if scriptEmpty
    ok = local_saveFunctions(root, funcs);
    if ~ok
        info.message = 'The functions could not be saved.';
    end
    return
end
local_resolveUserFunctions(code, kb);
bar = repmat('-', 1, 64);
fprintf('\n[ru] Code (%s):\n%s\n%s\n%s\n[ru] Output:\n', label, bar, code, bar);
[ok, info] = local_execute(code);
end

function local_finish(root, code, t0, how)
fprintf('\n[ru] Done (%s, %.0f s). Variables are in the workspace. Show the code again: ru last | save it: ru save <name>\n', ...
    how, toc(t0));
local_writeText(fullfile(local_brain(root), 'last_code.txt'), code);
local_log(root, sprintf('RESULT: OK (%s)\nCODE:\n%s', how, code));
end

function fb = local_feedback(info, kb, env, code, cut, lastChance)
msg = strtrim(info.message);
fprintf(2, '\n[ru] MATLAB error: %s\n', msg);
if ~isempty(info.lineText)
    fprintf(2, '[ru] at line %d: %s\n', info.line, info.lineText);
end
fb = sprintf('Running your script in MATLAB failed.\nError message:\n%s\n', msg);
if ~isempty(info.lineText)
    fb = [fb sprintf('The failing line %d is:\n%s\n', info.line, info.lineText)];
end
if ~isempty(info.where) && isempty(strfind(info.where, 'ru_task_'))
    fb = [fb sprintf('The error happened inside the function %s.\n', info.where)];
end
h = local_hints(info, kb, env, code);
if cut
    h = [h sprintf('- Your previous reply was cut off because it was too long. Write shorter code.\n')];
end
if lastChance
    h = [h sprintf(['- Use the simplest possible approach: base MATLAB (fzero, roots, polyfit, interp1, trapz, ' ...
        'integral, ode45, backslash, eig) and anonymous functions.\n'])];
end
if ~isempty(h)
    fb = [fb sprintf('Hints:\n') h];
end
fb = [fb sprintf(['Rewrite the COMPLETE corrected script (not only the changed line) in one ```matlab block. ' ...
    'Keep all numbers from the problem; no input().'])];
end

function [msgs, numCtx] = local_buildMessages(root, prompt, kb, env, ctx)
for pass = 1:3
    sys = local_systemPrompt(env);
    for t = ctx.topicIdx
        T = kb.topics(t);
        if ~isempty(T.cheat)
            sys = [sys sprintf('\n\nNOTES FOR %s PROBLEMS:\n%s', upper(T.name), T.cheat)]; %#ok<AGROW>
        end
    end
    if ~isempty(ctx.libFull)
        sys = [sys sprintf('\n\nLIBRARY FUNCTIONS YOU CAN CALL (folder ru_lib, already on the path):')]; %#ok<AGROW>
        for k = ctx.libFull
            sys = [sys sprintf('\n\n%s', kb.lib(k).help)]; %#ok<AGROW>
        end
    end
    others = setdiff(1:numel(kb.lib), ctx.libFull);
    if ~isempty(others)
        sys = [sys sprintf('\n\nOther ru_lib functions (same conventions, call only if needed): %s', ...
            strjoin({kb.lib(others).name}, ', '))]; %#ok<AGROW>
    end
    mem = local_memory(root);
    if ~isempty(mem)
        sys = [sys sprintf('\n\nUSER RULES:\n%s', mem)]; %#ok<AGROW>
    end
    msgs = local_msg('system', sys);
    for k = ctx.examples
        ex = kb.examples(k);
        msgs(end+1) = local_msg('user', ['PROBLEM:' char(10) ex.problem]); %#ok<AGROW>
        msgs(end+1) = local_msg('assistant', ['```matlab' char(10) ex.code char(10) '```']); %#ok<AGROW>
    end
    user = ['PROBLEM:' char(10) prompt];
    if pass == 1
        extra = local_attachments(root, prompt, kb);
    end
    if ~isempty(extra)
        user = [user char(10) char(10) extra]; %#ok<AGROW>
    end
    user = [user char(10) char(10) 'Write the complete MATLAB script.']; %#ok<AGROW>
    msgs(end+1) = local_msg('user', user); %#ok<AGROW>
    total = sum(cellfun(@numel, {msgs.content}));
    if total <= 30000
        break
    end
    % Too long for a small model: drop the second example, then trim the library help.
    if numel(ctx.examples) > 1
        ctx.examples = ctx.examples(1);
    elseif numel(ctx.libFull) > 5
        ctx.libFull = ctx.libFull(1:5);
    else
        break
    end
end
numCtx = 2048 * ceil((total / 3 + 2500) / 2048);
numCtx = min(max(numCtx, 4096), 16384);
end

function s = local_systemPrompt(env)
L = {
    'You are ru, an expert MATLAB programmer and numerical-methods tutor (course CE206; textbook Chapra, Applied Numerical Methods with MATLAB).'
    'Write ONE complete MATLAB script that solves the PROBLEM and runs without errors.'
    ''
    'OUTPUT: exactly one ```matlab code block containing the whole script, and no other text.'
    ''
    'RULES'
    ['1. The script must run as-is in MATLAB ' env.release ': hard-code every number from the problem. Never use input(), keyboard, pause, clc, clear or close all.']
    '2. Write every operator explicitly: 2*x (never 2x), 3*(x+1), x.^2. Use element-wise .* ./ .^ whenever a value can be a vector.'
    '3. Define math functions as anonymous functions: f = @(x) x.^3 - 10*x.^2 + 5;  ODE systems: dydt = @(t,y) [y(2); -9.81*sin(y(1))];'
    '   Only when a multi-line function is unavoidable, put it at the END of the script and close it with end; it cannot see script variables, so pass them as arguments.'
    '4. Print every requested result with fprintf, with a label and units, e.g. fprintf(''Root = %.6f\n'', xr);  Print iteration tables when iterations are asked for.'
    '5. Plot only when a graph/plot/figure is requested: figure; plot(...); grid on; xlabel(...); ylabel(...); title(...); legend(...).'
    '6. sin/cos/tan use radians; use sind/cosd/tand for degrees. log is the natural log, log10 is base 10, e^x is exp(x).'
    '7. Approximate relative error in percent: ea = abs((xnew - xold)/xnew)*100. True percent relative error: et = abs((xtrue - xapprox)/xtrue)*100.'
    ['8. Prefer the ru_lib functions listed below and call them exactly as documented. Base MATLAB is always available: fzero, fminbnd, fminsearch, ' ...
    'roots, poly, polyfit, polyval, interp1, spline, pchip, trapz, cumtrapz, integral, diff, gradient, ode45, ode23, eig, inv, det, lu, chol, cond, norm, ' ...
    'fft, ifft, mean, median, mode, std, var, max, min, sum, sort, cumsum, linspace, meshgrid, hist, histogram.']
    ['9. ' env.toolboxLine]
    '10. Never call ru. Do not read or write files unless the problem names a file.'
    };
s = strjoin(L', char(10));
end

function env = local_env()
persistent E
if ~isempty(E)
    env = E;
    return
end
E = struct();
E.release = ['R' version('-release')];
E.sym = local_hasToolbox('Symbolic_Toolbox', 'syms');
E.stats = local_hasToolbox('Statistics_Toolbox', 'normcdf');
E.optim = local_hasToolbox('Optimization_Toolbox', 'fsolve');
E.curvefit = local_hasToolbox('Curve_Fitting_Toolbox', 'fit');
E.signal = local_hasToolbox('Signal_Toolbox', 'butter');
yn = {'no', 'yes'};
E.toolboxLine = sprintf(['Toolboxes on this computer: Symbolic Math %s, Statistics %s, Optimization %s, ' ...
    'Curve Fitting %s, Signal Processing %s. NEVER call a function from a toolbox marked no. ' ...
    'Without Statistics use the stat_ functions; without Optimization use root_newtonsys, fminsearch or fit_nonlinear; ' ...
    'without Symbolic Math use fzero, roots and anonymous functions.'], ...
    yn{E.sym + 1}, yn{E.stats + 1}, yn{E.optim + 1}, yn{E.curvefit + 1}, yn{E.signal + 1});
env = E;
end

function tf = local_hasToolbox(licenseName, probe)
tf = false;
try
    tf = license('test', licenseName) == 1 && ~isempty(which(probe));
catch
end
end

function mem = local_memory(root)
mem = '';
f = fullfile(root, 'memory.txt');
if exist(f, 'file') == 2
    mem = strtrim(local_ascii(fileread(f)));
    if numel(mem) > 3000
        mem = mem(1:3000);
    end
end
end

function extra = local_attachments(root, prompt, kb)
extra = '';
names = unique(regexp(prompt, '[A-Za-z]\w*(?=\.m\>)', 'match'));
for k = 1:numel(names)
    idx = local_findUserFile(kb, names{k});
    if idx == 0
        continue
    end
    U = kb.userFiles(idx);
    addpath(U.folder, '-begin');
    txt = local_ascii(fileread(fullfile(U.folder, [U.name '.m'])));
    if numel(txt) > 5000
        txt = [txt(1:5000) char(10) '% ... (truncated)'];
    end
    if U.isFunction
        how = sprintf('It is on the path; call it as: %s', U.signature);
    else
        how = sprintf('It is a script on the path; run it by writing its name: %s', U.name);
    end
    extra = [extra sprintf('The user''s file %s.m (folder %s). %s\nContents:\n%s\n\n', ...
        U.name, U.folder, how, txt)]; %#ok<AGROW>
    fprintf('[ru] Using your file %s\n', fullfile(U.folder, [U.name '.m']));
end
dataNames = unique(regexp(prompt, '[\w\-]+\.(xlsx|xls|csv|txt|dat|mat)\>', 'match', 'ignorecase'));
for k = 1:numel(dataNames)
    p = local_findDataFile(root, dataNames{k});
    if isempty(p)
        extra = [extra sprintf(['The data file %s is not in the current folder (%s) or the ru folder. ' ...
            'Read it by its plain name; the user must put it in the current folder.\n'], dataNames{k}, pwd)]; %#ok<AGROW>
        fprintf(2, '[ru] Note: %s was not found. Put it in the current folder (%s).\n', dataNames{k}, pwd);
    else
        extra = [extra sprintf('The data file %s is at: %s  (use this full path in quotes).\n', dataNames{k}, p)]; %#ok<AGROW>
    end
end
end

function idx = local_findUserFile(kb, name)
idx = 0;
uf = kb.userFiles;
if isempty(uf)
    return
end
hits = find(strcmpi({uf.name}, name));
if isempty(hits)
    return
end
[~, b] = max([uf(hits).datenum]);
idx = hits(b);
end

function p = local_findDataFile(root, name)
p = '';
if exist(fullfile(pwd, name), 'file') == 2
    p = fullfile(pwd, name);
    return
end
d = dir(fullfile(root, '**', name));
if ~isempty(d)
    p = fullfile(d(1).folder, d(1).name);
    return
end
w = which(name);
if ~isempty(w)
    p = w;
end
end

% =====================================================================
% Retrieval: topics, library help and solved examples for a prompt
% =====================================================================

function ctx = local_retrieve(kb, prompt)
ctx = struct('topics', {{}}, 'topicIdx', zeros(1, 0), 'examples', zeros(1, 0), ...
    'libFull', zeros(1, 0), 'direct', 0);
p = regexprep(lower(prompt), '\s+', ' ');
nT = numel(kb.topics);
ts = zeros(1, nT);
for t = 1:nT
    T = kb.topics(t);
    for k = 1:numel(T.kwRegex)
        n = numel(regexp(p, T.kwRegex{k}, 'start'));
        if n > 0
            ts(t) = ts(t) + min(n, 3) * (1 + any(T.keywords{k} == ' '));
        end
    end
end
nE = numel(kb.examples);
sims = zeros(nE, 1);
if nE > 0
    q = local_queryVector(kb, prompt);
    if nnz(q) > 0
        sims = full(kb.W * q');
    end
end
[ss, order] = sort(sims, 'descend');
for k = 1:min(3, nE)
    t = kb.examples(order(k)).topicIdx;
    if ss(k) > 0.1 && t > 0
        ts(t) = ts(t) + 4 * ss(k);
    end
end
chosen = zeros(1, 0);
if nT > 0
    [tsSorted, tOrder] = sort(ts, 'descend');
    if tsSorted(1) > 0
        chosen = tOrder(1);
        if nT > 1 && tsSorted(2) > 0 && tsSorted(2) >= 0.6 * tsSorted(1)
            chosen(end+1) = tOrder(2);
        end
    end
end
ctx.topicIdx = chosen;
ctx.topics = {kb.topics(chosen).name};

% Up to two similar solved examples (boosted when they are in a chosen topic).
score = sims;
for k = 1:nE
    if any(kb.examples(k).topicIdx == chosen)
        score(k) = score(k) * 1.3;
    end
end
[sc, ord] = sort(score, 'descend');
ex = ord(sc >= 0.12);
ex = ex(1:min(2, numel(ex)));
if isempty(ex) && ~isempty(chosen) && nE > 0
    inTopic = find([kb.examples.topicIdx] == chosen(1));
    if ~isempty(inTopic)
        [~, b] = max(sims(inTopic));
        ex = inTopic(b);
    end
end
ctx.examples = ex(:)';

% Library functions shown with full help.
names = {kb.lib.name};
isCand = false(1, numel(kb.lib));
for t = chosen
    pre = kb.topics(t).prefixes;
    for j = 1:numel(pre)
        isCand = isCand | strncmp(names, pre{j}, numel(pre{j}));
    end
end
exCode = lower(strjoin({kb.examples(ctx.examples).code}, ' '));
used = false(1, numel(kb.lib));
pri = zeros(1, numel(kb.lib));
for k = 1:numel(kb.lib)
    used(k) = ~isempty(strfind(exCode, lower(names{k})));
    parts = strsplit(names{k}, '_');
    if used(k)
        pri(k) = pri(k) + 2;
    end
    if numel(parts) > 1 && numel(parts{2}) > 3 && ~isempty(strfind(p, parts{2}))
        pri(k) = pri(k) + 1;
    end
end
cand = find(isCand | used);
[~, o] = sort(pri(cand), 'descend');
cand = cand(o);
ctx.libFull = cand(1:min(10, numel(cand)));

ctx.direct = local_directMatch(kb, prompt, sims);
end

function idx = local_directMatch(kb, prompt, sims)
idx = 0;
if isempty(sims)
    return
end
[s, b] = max(sims);
if s < 0.45
    return
end
ex = kb.examples(b);
if ex.skip || numel(ex.numbers) < 2
    return
end
U = local_numbers(prompt);
if ~all(ismember(ex.numbers, U))
    return
end
if numel(setdiff(U, ex.numbers)) > 2
    return
end
if ~isequal(local_methodSet(kb, prompt), ex.methods)
    return
end
idx = b;
end

function v = local_numbers(txt)
tok = regexp(txt, '\d+\.?\d*|\.\d+', 'match');
v = unique(str2double(tok));
v = v(~isnan(v));
v = v(:)';
end

function m = local_methodSet(kb, txt)
p = regexprep(lower(txt), '\s+', ' ');
m = zeros(1, 0);
for g = 1:numel(kb.methodRegex)
    rx = kb.methodRegex{g};
    for j = 1:numel(rx)
        if ~isempty(regexp(p, rx{j}, 'once'))
            m(end+1) = g; %#ok<AGROW>
            break
        end
    end
end
end

function q = local_queryVector(kb, txt)
V = size(kb.W, 2);
q = sparse(1, V);
t = local_tokens(txt);
if isempty(t) || V == 0
    return
end
[u, ~, j] = unique(t);
cnt = accumarray(j(:), 1)';
cols = zeros(1, 0);
vals = zeros(1, 0);
for m = 1:numel(u)
    if isKey(kb.vocab, u{m})
        c = kb.vocab(u{m});
        cols(end+1) = c; %#ok<AGROW>
        vals(end+1) = (1 + log(cnt(m))) * kb.idf(c); %#ok<AGROW>
    end
end
if isempty(cols)
    return
end
q = sparse(ones(1, numel(cols)), cols, vals, 1, V);
q = q / norm(q);
end

function t = local_tokens(txt)
t = regexp(lower(txt), '[a-z][a-z0-9]*|\d+(?:\.\d+)?', 'match');
if isempty(t)
    t = {};
    return
end
t = t(cellfun(@numel, t) > 1);
t = t(~ismember(t, local_stopwords()));
for k = 1:numel(t)
    w = t{k};
    if numel(w) > 4 && isletter(w(1))
        if strcmp(w(end-2:end), 'ies')
            w = [w(1:end-3) 'y'];
        elseif w(end) == 's' && ~any(w(end-1) == 'siu')
            w = w(1:end-1);
        end
        t{k} = w;
    end
end
end

function s = local_stopwords()
persistent S
if isempty(S)
    S = {'the', 'and', 'for', 'with', 'that', 'this', 'from', 'are', 'was', 'were', 'will', 'can', ...
        'use', 'using', 'used', 'find', 'determine', 'calculate', 'compute', 'evaluate', 'obtain', 'show', ...
        'given', 'give', 'following', 'value', 'values', 'its', 'their', 'there', 'which', 'what', 'into', ...
        'than', 'then', 'each', 'all', 'any', 'also', 'has', 'have', 'had', 'not', 'but', 'you', 'your', ...
        'our', 'how', 'why', 'when', 'where', 'who', 'one', 'two', 'three', 'such', 'these', 'those', ...
        'write', 'program', 'code', 'matlab', 'script', 'problem', 'solve', 'solution', 'answer', 'please', ...
        'let', 'shown', 'below', 'above', 'figure', 'table', 'result', 'results', 'be', 'is', 'of', 'to', ...
        'in', 'on', 'at', 'by', 'as', 'an', 'or', 'if', 'it', 'we', 'do', 'so', 'up', 'out', 'same', 'other'};
end
s = S;
end

% =====================================================================
% Knowledge base: topics, library help, solved examples, user files
% =====================================================================

function kb = local_kb(root)
persistent cache cacheKey
exDir = fullfile(root, 'ru_kb', 'examples');
tpDir = fullfile(root, 'ru_kb', 'topics');
libDir = fullfile(root, 'ru_lib');
d1 = dir(fullfile(exDir, '*.m'));
d2 = dir(fullfile(tpDir, '*.txt'));
d3 = dir(fullfile(libDir, '*.m'));
stamp = [0, [d1.datenum], [d2.datenum], [d3.datenum]];
key = sprintf('%s|%d|%d|%d|%.8f', root, numel(d1), numel(d2), numel(d3), max(stamp));
if isempty(cache) || ~strcmp(cacheKey, key)
    k = struct();
    k.topics = local_readTopics(tpDir, d2);
    k.methodRegex = {};
    for t = 1:numel(k.topics)
        k.methodRegex = [k.methodRegex, k.topics(t).methodRegex];
    end
    k.lib = local_readLib(libDir, d3);
    k.examples = local_readExamples(exDir, d1, k);
    k = local_buildIndex(k);
    cache = k;
    cacheKey = key;
end
kb = cache;
kb.userFiles = local_userFiles(root);
end

function T = local_readTopics(tpDir, d)
T = struct('name', {}, 'prefixes', {}, 'keywords', {}, 'kwRegex', {}, 'methodRegex', {}, 'cheat', {});
for i = 1:numel(d)
    try
        txt = local_ascii(fileread(fullfile(tpDir, d(i).name)));
    catch
        continue
    end
    lines = regexp(strrep(txt, char(13), ''), '\n', 'split');
    t = struct('name', lower(regexprep(d(i).name, '\.txt$', '')), 'prefixes', {{}}, 'keywords', {{}}, ...
        'kwRegex', {{}}, 'methodRegex', {{}}, 'cheat', '');
    cheat = {};
    inCheat = false;
    for k = 1:numel(lines)
        L = lines{k};
        if inCheat
            cheat{end+1} = L; %#ok<AGROW>
            continue
        end
        tok = regexp(L, '^\s*([A-Z]+)\s*:\s*(.*)$', 'tokens', 'once');
        if isempty(tok)
            continue
        end
        val = strtrim(tok{2});
        switch tok{1}
            case 'TOPIC'
                if ~isempty(val)
                    t.name = lower(val);
                end
            case 'PREFIXES'
                p = regexp(val, '[\s,]+', 'split');
                t.prefixes = p(~cellfun(@isempty, p));
            case 'KEYWORDS'
                t.keywords = local_splitList(val, ',');
            case 'METHODS'
                groups = strsplit(val, '|');
                for g = 1:numel(groups)
                    syn = local_splitList(groups{g}, ',');
                    if ~isempty(syn)
                        t.methodRegex{end+1} = cellfun(@local_wordRegex, syn, 'UniformOutput', false);
                    end
                end
            case 'CHEATSHEET'
                inCheat = true;
                if ~isempty(val)
                    cheat{end+1} = val; %#ok<AGROW>
                end
        end
    end
    t.kwRegex = cellfun(@local_wordRegex, t.keywords, 'UniformOutput', false);
    t.cheat = strtrim(strjoin(cheat, char(10)));
    T(end+1) = t; %#ok<AGROW>
end
end

function c = local_splitList(s, sep)
c = strtrim(strsplit(lower(s), sep));
c = c(~cellfun(@isempty, c));
end

function r = local_wordRegex(w)
r = ['(?<![a-z0-9])' regexptranslate('escape', w) 's?(?![a-z0-9])'];
end

function L = local_readLib(libDir, d)
L = struct('name', {}, 'prefix', {}, 'signature', {}, 'h1', {}, 'help', {});
for i = 1:numel(d)
    name = regexprep(d(i).name, '\.m$', '');
    try
        txt = local_ascii(fileread(fullfile(libDir, d(i).name)));
    catch
        continue
    end
    lines = regexp(strrep(txt, char(13), ''), '\n', 'split');
    sig = '';
    hl = {};
    for k = 1:numel(lines)
        s = strtrim(lines{k});
        if isempty(sig)
            if strncmp(s, 'function', 8)
                sig = strtrim(regexprep(s, '^function\s+', ''));
            end
            continue
        end
        if strncmp(s, '%', 1)
            hl{end+1} = regexprep(s, '^%+\s?', ''); %#ok<AGROW>
        else
            break
        end
    end
    if isempty(sig)
        continue
    end
    h1 = '';
    if ~isempty(hl)
        h1 = strtrim(regexprep(hl{1}, ['^' name '\s*'], '', 'ignorecase'));
    end
    u = strfind(name, '_');
    if isempty(u)
        prefix = name;
    else
        prefix = name(1:u(1));
    end
    L(end+1) = struct('name', name, 'prefix', prefix, 'signature', sig, 'h1', h1, ...
        'help', strjoin([{sig}, hl], char(10))); %#ok<AGROW>
end
end

function E = local_readExamples(exDir, d, kb)
E = struct('file', {}, 'title', {}, 'topic', {}, 'topicIdx', {}, 'source', {}, 'keywords', {}, ...
    'problem', {}, 'checks', {}, 'skip', {}, 'code', {}, 'numbers', {}, 'methods', {});
topicNames = {kb.topics.name};
for i = 1:numel(d)
    f = fullfile(exDir, d(i).name);
    try
        txt = strrep(local_ascii(fileread(f)), char(13), '');
    catch
        continue
    end
    lines = regexp(txt, '\n', 'split');
    e = struct('file', f, 'title', '', 'topic', '', 'topicIdx', 0, 'source', '', 'keywords', {{}}, ...
        'problem', '', 'checks', {{}}, 'skip', false, 'code', '', 'numbers', zeros(1, 0), 'methods', zeros(1, 0));
    prob = {};
    key = '';
    codeStart = 0;
    for k = 1:numel(lines)
        L = lines{k};
        tok = regexp(L, '^\s*%\s*(TOPIC|TITLE|SOURCE|KEYWORDS|PROBLEM|CHECK|SELFTEST|CODE)\s*:\s*(.*)$', 'tokens', 'once');
        if ~isempty(tok)
            key = tok{1};
            val = strtrim(tok{2});
            switch key
                case 'TOPIC'
                    e.topic = lower(val);
                case 'TITLE'
                    e.title = val;
                case 'SOURCE'
                    e.source = val;
                case 'KEYWORDS'
                    e.keywords = local_splitList(val, ',');
                case 'PROBLEM'
                    if ~isempty(val)
                        prob{end+1} = val; %#ok<AGROW>
                    end
                case 'CHECK'
                    if ~isempty(val)
                        e.checks{end+1} = val;
                    end
                case 'SELFTEST'
                    e.skip = ~isempty(strfind(lower(val), 'skip'));
                case 'CODE'
                    codeStart = k + 1;
            end
            if codeStart > 0
                break
            end
            continue
        end
        if strcmp(key, 'PROBLEM') && ~isempty(regexp(L, '^\s*%', 'once'))
            prob{end+1} = regexprep(L, '^\s*%\s?', ''); %#ok<AGROW>
        end
    end
    if codeStart == 0
        continue
    end
    e.code = strtrim(strjoin(lines(codeStart:end), char(10)));
    e.problem = strtrim(strjoin(prob, char(10)));
    if isempty(e.code) || isempty(e.problem)
        continue
    end
    if isempty(e.title)
        e.title = d(i).name;
    end
    ti = find(strcmp(topicNames, e.topic), 1);
    if ~isempty(ti)
        e.topicIdx = ti;
    end
    e.numbers = local_numbers(e.problem);
    e.methods = local_methodSet(kb, e.problem);
    E(end+1) = e; %#ok<AGROW>
end
end

function kb = local_buildIndex(kb)
N = numel(kb.examples);
kb.vocab = containers.Map('KeyType', 'char', 'ValueType', 'double');
rows = zeros(1, 0);
cols = zeros(1, 0);
vals = zeros(1, 0);
df = zeros(1, 0);
for i = 1:N
    e = kb.examples(i);
    kw = strjoin(e.keywords, ' ');
    t = [local_tokens(e.title), local_tokens(e.title), local_tokens(kw), local_tokens(kw), local_tokens(e.problem)];
    if isempty(t)
        continue
    end
    [u, ~, j] = unique(t);
    cnt = accumarray(j(:), 1)';
    for m = 1:numel(u)
        if isKey(kb.vocab, u{m})
            c = kb.vocab(u{m});
        else
            c = double(kb.vocab.Count) + 1;
            kb.vocab(u{m}) = c;
            df(c) = 0;
        end
        df(c) = df(c) + 1;
        rows(end+1) = i; %#ok<AGROW>
        cols(end+1) = c; %#ok<AGROW>
        vals(end+1) = 1 + log(cnt(m)); %#ok<AGROW>
    end
end
V = double(kb.vocab.Count);
kb.idf = log((N + 1) ./ (df + 1)) + 1;
if N == 0 || V == 0
    kb.W = sparse(N, max(V, 1));
    return
end
W = sparse(rows, cols, vals .* kb.idf(cols), N, V);
nrm = full(sqrt(sum(W.^2, 2)));
nrm(nrm == 0) = 1;
kb.W = spdiags(1 ./ nrm, 0, N, N) * W;
end

function U = local_userFiles(root)
persistent cache cacheKey
U = struct('name', {}, 'folder', {}, 'isFunction', {}, 'signature', {}, 'datenum', {});
d = dir(fullfile(root, '**', '*.m'));
if isempty(d)
    return
end
key = sprintf('%s|%d|%.8f', root, numel(d), max([d.datenum]));
if ~isempty(cache) && strcmp(cacheKey, key)
    U = cache;
    return
end
skipDirs = {'ru_lib', 'ru_kb', 'ru_tests', 'brain', 'models', 'ollama', 'generated'};
for i = 1:numel(d)
    folder = d(i).folder;
    rel = regexprep(folder(min(numel(root), numel(folder)) + 1:end), '^[\\/]+', '');
    if isempty(rel)
        continue
    end
    top = regexp(rel, '^[^\\/]+', 'match', 'once');
    if any(strcmpi(top, skipDirs))
        continue
    end
    name = regexprep(d(i).name, '\.m$', '');
    txt = '';
    try
        txt = fileread(fullfile(folder, d(i).name));
    catch
    end
    lines = regexp(strrep(txt, char(13), ''), '\n', 'split');
    isFun = false;
    sig = '';
    for k = 1:numel(lines)
        s = strtrim(lines{k});
        if isempty(s) || s(1) == '%'
            continue
        end
        if ~isempty(regexp(s, '^function\>', 'once'))
            isFun = true;
            sig = strtrim(regexprep(regexprep(s, '^function\s*', ''), '%.*$', ''));
        end
        break
    end
    U(end+1) = struct('name', name, 'folder', folder, 'isFunction', isFun, ...
        'signature', sig, 'datenum', d(i).datenum); %#ok<AGROW>
end
if ~isempty(U)
    [~, o] = sort(lower(strcat({U.folder}, '/', {U.name})));
    U = U(o);
end
cache = U;
cacheKey = key;
end

% =====================================================================
% AI engine (Ollama)
% =====================================================================

function [host, model] = local_engine(root, forceStart)
persistent cHost cModel
host = '';
model = '';
want = local_setting(root, 'model', 'auto');
if ~forceStart && ~isempty(cModel)
    names = local_tags(cHost, 3);
    if any(strcmp(names, cModel)) && (strcmpi(want, 'auto') || local_sameModel(want, cModel))
        host = cHost;
        model = cModel;
        return
    end
end
hosts = local_hosts(root);
[H, M] = local_findModels(hosts);
if (forceStart || isempty(M)) && ~local_ping('http://127.0.0.1:11435')
    fprintf('[ru] Starting the AI engine (Ollama) on port 11435 ...\n');
    if local_startEngine(root)
        [H, M] = local_findModels(hosts);
    end
end
if isempty(M)
    fprintf(2, '[ru] No AI model is available.\n');
    local_engineHelp();
    return
end
k = local_pickModel(M, want);
host = H{k};
model = M{k};
cHost = host;
cModel = model;
if forceStart
    fprintf('[ru] Engine ready: model %s at %s\n', model, host);
end
end

function hosts = local_hosts(root)
hosts = {'http://127.0.0.1:11435', 'http://127.0.0.1:11434'};
custom = strtrim(local_setting(root, 'host', ''));
if ~isempty(custom)
    if isempty(regexp(custom, '^https?://', 'once'))
        custom = ['http://' custom];
    end
    hosts = [{regexprep(custom, '/+$', '')}, hosts];
end
end

function [H, M] = local_findModels(hosts)
H = {};
M = {};
for i = 1:numel(hosts)
    names = local_tags(hosts{i}, 3);
    for k = 1:numel(names)
        if isempty(strfind(lower(names{k}), 'embed'))
            H{end+1} = hosts{i}; %#ok<AGROW>
            M{end+1} = names{k}; %#ok<AGROW>
        end
    end
end
end

function names = local_tags(host, timeout)
names = {};
try
    r = webread([host '/api/tags'], weboptions('Timeout', timeout, 'ContentType', 'json'));
catch
    return
end
if ~isstruct(r) || ~isfield(r, 'models') || isempty(r.models)
    return
end
m = r.models;
for k = 1:numel(m)
    if iscell(m)
        item = m{k};
    else
        item = m(k);
    end
    if isstruct(item) && isfield(item, 'name')
        names{end+1} = char(item.name); %#ok<AGROW>
    end
end
end

function ok = local_ping(host)
ok = false;
try
    webread([host '/api/version'], weboptions('Timeout', 2, 'ContentType', 'json'));
    ok = true;
catch
end
end

function k = local_pickModel(M, want)
k = 1;
if ~isempty(want) && ~strcmpi(want, 'auto')
    for i = 1:numel(M)
        if local_sameModel(want, M{i})
            k = i;
            return
        end
    end
    fprintf(2, '[ru] The chosen model "%s" is not installed here; choosing one automatically.\n', want);
end
best = -Inf;
for i = 1:numel(M)
    s = local_modelScore(M{i});
    if s > best
        best = s;
        k = i;
    end
end
end

function tf = local_sameModel(a, b)
tf = strcmpi(regexprep(a, ':latest$', ''), regexprep(b, ':latest$', ''));
end

function s = local_modelScore(name)
n = lower(name);
if ~isempty(strfind(n, 'qwen2.5-coder'))
    s = 300;
elseif ~isempty(strfind(n, 'qwen3-coder'))
    s = 290;
elseif ~isempty(strfind(n, 'ru_engine'))
    s = 250;
elseif ~isempty(strfind(n, 'coder')) || ~isempty(strfind(n, 'codellama'))
    s = 200;
elseif ~isempty(strfind(n, 'qwen'))
    s = 150;
elseif ~isempty(regexp(n, 'llama|mistral|gemma|phi', 'once'))
    s = 100;
else
    s = 50;
end
tok = regexp(n, '(\d+(?:\.\d+)?)b\>', 'tokens', 'once');
if isempty(tok)
    s = s + 10;
else
    b = str2double(tok{1});
    if b >= 6 && b <= 16
        s = s + 40;
    elseif b >= 2.5 && b < 6
        s = s + 20;
    elseif b > 16
        s = s - 60;
    end
end
end

function ok = local_startEngine(root)
ok = false;
exe = local_findOllama(root);
if isempty(exe)
    fprintf(2, '[ru] Ollama is not installed on this PC and there is no ollama folder in %s.\n', root);
    return
end
oldModels = getenv('OLLAMA_MODELS');
oldHost = getenv('OLLAMA_HOST');
modelsDir = fullfile(root, 'models');
if exist(fullfile(modelsDir, 'manifests'), 'dir') == 7
    setenv('OLLAMA_MODELS', modelsDir);
end
setenv('OLLAMA_HOST', '127.0.0.1:11435');
try
    if ispc
        system(sprintf('start "ru engine - keep this window open" /min "%s" serve', exe));
    else
        system(sprintf('"%s" serve > /dev/null 2>&1 &', exe));
    end
catch err
    fprintf(2, '[ru] Could not start %s: %s\n', exe, err.message);
end
setenv('OLLAMA_MODELS', oldModels);
setenv('OLLAMA_HOST', oldHost);
fprintf('[ru] Waiting for the engine');
for k = 1:60
    pause(1);
    if local_ping('http://127.0.0.1:11435')
        fprintf(' ready.\n');
        ok = true;
        return
    end
    if mod(k, 5) == 0
        fprintf('.');
    end
end
fprintf('\n');
fprintf(2, '[ru] The engine did not start within 60 s. Try double-clicking start_ru.bat.\n');
end

function exe = local_findOllama(root)
exe = '';
c = {fullfile(root, 'ollama', 'ollama.exe'), fullfile(root, 'ollama', 'ollama'), ...
    fullfile(getenv('LOCALAPPDATA'), 'Programs', 'Ollama', 'ollama.exe'), ...
    fullfile(getenv('ProgramFiles'), 'Ollama', 'ollama.exe'), ...
    '/usr/local/bin/ollama', '/usr/bin/ollama', '/opt/homebrew/bin/ollama'};
for k = 1:numel(c)
    if exist(c{k}, 'file') == 2
        exe = c{k};
        return
    end
end
try
    if ispc
        [st, out] = system('where ollama');
    else
        [st, out] = system('which ollama');
    end
    if st == 0
        first = strtrim(regexp(out, '[^\r\n]+', 'match', 'once'));
        if exist(first, 'file') == 2
            exe = first;
        end
    end
catch
end
end

function local_engineHelp()
fprintf(2, ['[ru] To fix the AI engine:\n' ...
    '[ru]   1. Install Ollama from https://ollama.com on this PC, or copy the Ollama program folder\n' ...
    '[ru]      (%%LOCALAPPDATA%%\\Programs\\Ollama) into the ru folder and rename it to "ollama".\n' ...
    '[ru]   2. Run  ru start  (or double-click start_ru.bat) and keep the engine window open.\n' ...
    '[ru]   3. Check everything with  ru status\n']);
end

function [txt, cut, err] = local_chat(host, model, msgs, temperature, numCtx)
txt = '';
cut = false;
err = '';
body = struct('model', model, 'messages', msgs, 'stream', false, 'keep_alive', '30m', ...
    'options', struct('temperature', temperature, 'num_ctx', numCtx, 'num_predict', 2048, ...
    'top_p', 0.9, 'seed', 42));
opts = weboptions('MediaType', 'application/json', 'ContentType', 'json', 'Timeout', 900, ...
    'CharacterEncoding', 'UTF-8');
try
    r = webwrite([host '/api/chat'], body, opts);
catch ME
    err = ME.message;
    if ~isempty(strfind(err, '404'))
        err = sprintf('the model "%s" was not found on %s. Run: ru status', model, host);
    elseif ~isempty(regexpi(err, 'timed? ?out|did not respond|timeout', 'once'))
        err = ['the engine did not answer in time. This PC may be slow for this model; ' ...
            'close other programs and try again, or choose a smaller model (ru model ...).'];
    elseif ~isempty(regexpi(err, 'connect|refused|resolve', 'once'))
        err = 'the engine stopped running. Run: ru start';
    end
    return
end
if isstruct(r) && isfield(r, 'message') && isstruct(r.message) && isfield(r.message, 'content')
    txt = char(r.message.content);
elseif isstruct(r) && isfield(r, 'error')
    err = char(r.error);
    return
else
    err = 'the engine returned an unexpected answer.';
    return
end
if isfield(r, 'done_reason') && strcmp(char(r.done_reason), 'length')
    cut = true;
end
end

% =====================================================================
% Status, model selection, settings
% =====================================================================

function local_status(root)
env = local_env();
kb = local_kb(root);
fprintf('\n== ru status ==\n');
fprintf('ru folder       : %s\n', root);
fprintf('MATLAB          : %s\n', version);
fprintf('%s\n', env.toolboxLine(1:find(env.toolboxLine == '.', 1)));
fprintf('Solver library  : %d functions (ru_lib)\n', numel(kb.lib));
fprintf('Knowledge base  : %d topics, %d solved examples (ru_kb)\n', numel(kb.topics), numel(kb.examples));
fprintf('Your M-files    : %d\n', numel(kb.userFiles));
exe = local_findOllama(root);
if isempty(exe)
    fprintf(2, 'Ollama program  : NOT FOUND\n');
else
    fprintf('Ollama program  : %s\n', exe);
end
man = dir(fullfile(root, 'models', 'manifests', '**', '*'));
man = man(~[man.isdir]);
pen = {};
for k = 1:numel(man)
    [~, fam] = fileparts(man(k).folder);
    pen{end+1} = [fam ':' man(k).name]; %#ok<AGROW>
end
if isempty(pen)
    fprintf('Models on stick : none\n');
else
    fprintf('Models on stick : %s\n', strjoin(pen, ', '));
end
hosts = local_hosts(root);
for k = 1:numel(hosts)
    if local_ping(hosts{k})
        names = local_tags(hosts{k}, 3);
        if isempty(names)
            names = {'(no models)'};
        end
        fprintf('Engine %-22s: running, models: %s\n', hosts{k}, strjoin(names, ', '));
    else
        fprintf('Engine %-22s: not running\n', hosts{k});
    end
end
want = local_setting(root, 'model', 'auto');
fprintf('Model setting   : %s\n', want);
[H, M] = local_findModels(hosts);
if isempty(M)
    fprintf(2, 'ru will use     : nothing yet - run  ru start\n');
else
    k = local_pickModel(M, want);
    fprintf('ru will use     : %s at %s\n', M{k}, H{k});
end
fprintf('\n');
end

function local_modelCommand(root, args)
if numel(args) == 1
    fprintf('[ru] Model setting: %s\n', local_setting(root, 'model', 'auto'));
    [~, M] = local_findModels(local_hosts(root));
    if isempty(M)
        fprintf('[ru] No engine is running. Start it with: ru start\n');
    else
        fprintf('[ru] Installed models: %s\n', strjoin(unique(M), ', '));
    end
    return
end
name = strtrim(args{2});
local_setSetting(root, 'model', name);
fprintf('[ru] Model set to %s\n', name);
end

function v = local_setting(root, key, default)
v = default;
f = fullfile(root, 'brain', 'settings.txt');
if exist(f, 'file') ~= 2
    return
end
lines = regexp(fileread(f), '[^\r\n]+', 'match');
for k = 1:numel(lines)
    tok = regexp(lines{k}, ['^\s*' key '\s*=\s*(.*?)\s*$'], 'tokens', 'once');
    if ~isempty(tok) && ~isempty(tok{1})
        v = tok{1};
    end
end
end

function local_setSetting(root, key, value)
f = fullfile(local_brain(root), 'settings.txt');
lines = {};
if exist(f, 'file') == 2
    lines = regexp(fileread(f), '[^\r\n]+', 'match');
    lines = lines(cellfun(@isempty, regexp(lines, ['^\s*' key '\s*='], 'once')));
end
lines{end+1} = sprintf('%s = %s', key, value);
local_writeText(f, [strjoin(lines, char(10)) char(10)]);
end

% @@CHUNK5@@

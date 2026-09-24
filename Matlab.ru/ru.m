function ru(varargin)
%RU  Offline AI on a pendrive that writes, runs and checks MATLAB code (CE206).
%   ru <problem>          solve a problem typed on the same line
%   ru                    open a box to paste a long problem (text + equations)
%   ru paste              solve the problem that is on the clipboard
%   ru img [file] [note]  read a problem from a screenshot/photo and solve it
%                         (no file: uses the image on the clipboard, e.g. after
%                         Win+Shift+S). Needs a vision model (qwen3.5).
%   ru ask <question>     answer a theory question in words
%   ru explain [question] explain the last code (or answer a question)
%   ru fix [note]         fix the last error from your own Command Window work
%   ru again [hint]       solve the last problem again with another approach
%   ru think <problem>    solve with step-by-step reasoning (slower; qwen3.5)
%   ru ai <problem>       skip the stored slide solutions and ask the AI
%   ru history [n]        show the conversation memory;  ru new  clears it
%   ru remember <rule>    keep a rule forever, e.g. ru remember my student ID is 2104055
%   ru rules              show the remembered rules (file memory.txt)
%   ru last               show the last code;  ru save <name>  save it as <name>.m
%   ru status             check MATLAB, toolboxes, AI engine and models
%   ru start | ru stop    start / stop the AI engine (Ollama) of this pendrive
%   ru model [name|auto]  choose the text model;  ru vision [name|auto]  image model
%   ru list | ru test | ru help
%
%   Long problems, or text with quotes, commas or several lines: type just  ru
%   and paste the text into the box, or call  ru('...')  with the text in quotes.
%   ru remembers the conversation, so follow-ups work: "now use RK4 instead",
%   "plot it", "change h to 0.1", "why is the error so large?".

root = fileparts(mfilename('fullpath'));
local_setup(root);
args = local_args(varargin);
opts = local_opts();
if isempty(args)
    prompt = local_askProblem();
    if ~isempty(strtrim(prompt))
        local_route(root, prompt, opts);
    end
    return
end
cmd = lower(strtrim(args{1}));
rest = strtrim(strjoin(args(2:end), ' '));
alone = numel(args) == 1;
switch cmd
    case '--startup'
        local_startDiary(root, true);
        return
    case {'help', '-h', '--help', '?', '-?'}
        if alone
            help('ru');
            return
        end
    case {'status', 'check'}
        if alone
            local_status(root);
            return
        end
    case 'start'
        if alone
            local_engine(root, true, 'text');
            return
        end
    case 'stop'
        if alone
            local_stopEngine(root);
            return
        end
    case {'model', 'vision', 'host'}
        if numel(args) <= 2
            local_settingCommand(root, cmd, rest);
            return
        end
    case 'list'
        if alone
            local_list(root);
            return
        end
    case 'last'
        if alone
            local_last(root);
            return
        end
    case 'save'
        if numel(args) == 2
            local_saveLast(root, args{2});
            return
        end
    case {'test', 'selftest'}
        if alone
            local_test(root);
            return
        end
    case {'paste', 'clip', 'clipboard'}
        if alone
            prompt = local_clipboard();
            if isempty(strtrim(prompt))
                fprintf(2, '[ru] The clipboard has no text. Copy the problem first, or use: ru img  for a picture.\n');
                return
            end
            fprintf('[ru] Problem from the clipboard:\n%s\n', local_preview(prompt, 1200));
            local_route(root, prompt, opts);
            return
        end
    case {'img', 'image', 'shot', 'screenshot', 'photo', 'pic', 'picture', 'scan'}
        local_imageSolve(root, args(2:end), opts);
        return
    case {'ask', 'explain', 'why', 'define', 'describe'}
        if strcmp(cmd, 'explain') && alone
            local_explainLast(root);
            return
        end
        if ~alone
            q = rest;
            if any(strcmp(cmd, {'why', 'define', 'describe'}))
                q = strjoin(args, ' ');
            end
            local_ask(root, local_tidyPrompt(local_ascii(q)), opts);
            return
        end
    case {'fix', 'debug'}
        local_fix(root, rest, opts);
        return
    case {'again', 'retry', 'redo'}
        local_again(root, rest, opts);
        return
    case {'think', 'hard'}
        if ~alone
            opts.think = true;
            opts.forceAI = true;
            local_route(root, rest, opts);
            return
        end
    case 'ai'
        if ~alone
            opts.forceAI = true;
            opts.forceSolve = true;
            local_route(root, rest, opts);
            return
        end
    case {'history', 'memory', 'conversation'}
        if numel(args) <= 2
            local_showHistory(root, rest);
            return
        end
    case {'new', 'forget', 'reset'}
        if alone
            local_convClear(root);
            fprintf('[ru] Conversation memory cleared. Your rules in memory.txt are kept.\n');
            return
        end
    case 'remember'
        if ~alone
            local_remember(root, rest);
            return
        end
    case 'rules'
        if alone
            local_showRules(root);
            return
        end
end
local_route(root, strjoin(args, ' '), opts);
end

% =====================================================================
% Setup, input and small commands
% =====================================================================

function o = local_opts()
o = struct('forceAI', false, 'forceSolve', false, 'think', false, 'again', false, ...
    'label', '', 'extraContext', '', 'turnPrompt', '');
end

function args = local_args(in)
args = cell(1, numel(in));
for k = 1:numel(in)
    a = in{k};
    if isa(a, 'string')
        a = char(strjoin(cellstr(a(:)'), ' '));
    elseif ~ischar(a)
        try
            a = mat2str(a);
        catch
            a = '';
        end
    end
    args{k} = a;
end
args = args(~cellfun(@(s) isempty(strtrim(s)), args));
end

function local_setup(root)
dirs = {root, fullfile(root, 'ru_lib')};
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

function tf = local_desktop()
tf = false;
try
    tf = usejava('desktop') && ~exist('OCTAVE_VERSION', 'builtin');
catch
end
end

function txt = local_askProblem()
txt = '';
if local_desktop()
    def = local_clipboard();
    if numel(def) > 20000
        def = '';
    end
    lines = regexp(strrep(def, char(13), ''), '\n', 'split');
    a = {};
    try
        a = inputdlg({['Paste or type the problem (text, equations, tables; several lines are fine). ' ...
            'Edit it if needed, then press OK:']}, 'ru', [22 130], {char(lines)});
    catch
        try
            a = inputdlg({'Paste or type the problem, then press OK:'}, 'ru', [22 130]);
        catch
            a = {};
        end
    end
    if isempty(a)
        return
    end
    v = a{1};
    if size(v, 1) > 1
        txt = strjoin(cellstr(v)', char(10));
    else
        txt = v;
    end
else
    clip = strtrim(local_clipboard());
    if ~isempty(clip)
        fprintf('[ru] Using the problem on the clipboard:\n%s\n', local_preview(clip, 1200));
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
fprintf('%s\n', local_readText(f));
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
if exist(name, 'builtin') || ~isempty(which(name))
    fprintf(2, '[ru] Warning: "%s" is already a MATLAB function; your file will hide it.\n', name);
end
target = fullfile(pwd, [name '.m']);
if exist(target, 'file') == 2
    fprintf(2, '[ru] %s already exists; choose another name.\n', target);
    return
end
local_writeText(target, local_readText(f));
fprintf('[ru] Saved %s  (run it by typing: %s)\n', target, name);
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
fprintf('\n== Knowledge base: %d topics, %d verified solved examples (%s) ==\n', ...
    numel(kb.topics), numel(kb.examples), fullfile(root, 'ru_kb'));
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

function local_remember(root, txt)
txt = strtrim(local_ascii(txt));
if isempty(txt)
    return
end
f = fullfile(root, 'memory.txt');
old = '';
if exist(f, 'file') == 2
    old = local_readText(f);
end
if ~isempty(old) && old(end) ~= char(10)
    old = [old char(10)];
end
local_writeText(f, [old 'Rule: ' txt char(10)]);
fprintf('[ru] Remembered: %s\n[ru] (All rules: ru rules. Edit or delete them in %s)\n', txt, f);
end

function local_showRules(root)
mem = local_memory(root);
if isempty(mem)
    fprintf('[ru] No rules yet. Add one with: ru remember <rule>\n');
else
    fprintf('[ru] Rules from %s:\n%s\n', fullfile(root, 'memory.txt'), mem);
end
end

function local_greet()
fprintf(['[ru] Hello! Give me any MATLAB / numerical-methods problem, e.g.\n' ...
    '       ru find the root of x^3 - 10*x^2 + 5 between 0.6 and 0.8 by bisection\n' ...
    '     For long problems type just  ru  and paste the text. For a screenshot: ru img\n' ...
    '     Questions in words: ru ask why does Newton-Raphson diverge?   All commands: ru help\n']);
end

% =====================================================================
% Routing: greeting, question or problem
% =====================================================================

function local_route(root, prompt, opts)
prompt = local_tidyPrompt(local_ascii(prompt));
if isempty(prompt)
    return
end
local_startDiary(root, false);
if local_isGreeting(prompt)
    local_greet();
    return
end
if ~opts.forceSolve && ~opts.think && local_isQuestion(prompt)
    local_ask(root, prompt, opts);
    return
end
local_solve(root, prompt, opts);
end

function tf = local_isGreeting(p)
q = lower(strtrim(p));
tf = ~isempty(regexp(q, ['^(hi+|hello|hey|hlw|salam|assalamu ?alaikum|thanks?|thank you|thank you so much|' ...
    'ok|okay|good (morning|afternoon|evening|night)|bye|who are you)[\s!.,?]*$'], 'once'));
end

function tf = local_isQuestion(p)
q = lower(strtrim(p));
startsQ = ~isempty(regexp(q, ['^(what|why|how|when|which|where|who|is|are|can|could|does|do|should|' ...
    'would|explain|describe|define|compare|difference|tell me|meaning|what''s|whats)\>'], 'once'));
compute = ~isempty(regexp(q, ['\<(solve|find|compute|calculate|determine|evaluate|plot|graph|draw|' ...
    'estimate|simulate|fit|integrate|differentiate|develop|generate|obtain|approximate|predict|' ...
    'write (a |the )?(matlab )?(code|script|program|function))\>'], 'once'));
nums = numel(regexp(q, '(?<![a-z_\d.])\d+(\.\d+)?', 'match'));
tf = startsQ && nums < 2 && ~(compute && nums >= 1);
if ~tf && q(end) == '?' && nums == 0 && ~compute
    tf = true;
end
end

% =====================================================================
% Solving a problem: stored solution, else AI + run + repair loop
% =====================================================================

function ok = local_solve(root, prompt, opts)
t0 = tic;
ok = false;
local_log(root, sprintf('\n==== %s ====\nMODE: solve%s\nPROMPT:\n%s', local_now(), opts.label, prompt));
kb = local_kb(root);
env = local_env();
conv = local_convLoad(root);
follow = local_isFollowUp(prompt, conv);
ctx = local_retrieve(kb, prompt);
turnPrompt = prompt;
if ~isempty(opts.turnPrompt)
    turnPrompt = opts.turnPrompt;
end

% 1) A stored, verified solution of exactly this problem: run it directly.
if ~opts.forceAI && ~follow && ctx.direct > 0
    ex = kb.examples(ctx.direct);
    fprintf('[ru] This is the verified solved example "%s" (%s).\n', ex.title, ex.source);
    fprintf('[ru] Running its checked solution. To make the AI write new code instead type:  ru again\n');
    [okRun, info] = local_runCode(root, kb, ex.code, 'verified solution');
    if okRun
        local_finish(root, turnPrompt, ex.code, info.output, t0, 'verified solution', {});
        ok = true;
        return
    end
    fprintf(2, '[ru] The stored solution failed here (%s). Asking the AI instead.\n', local_firstLine(info.message));
end

% 2) Ask the local model, run its code, feed errors back until it works.
[host, model, caps, maxCtx] = local_engine(root, false, 'text');
if isempty(model)
    local_convAdd(root, 'solve', turnPrompt, '', 'The AI engine was not available.', false);
    return
end
think = opts.think && any(strcmp(caps, 'thinking'));
if opts.think && ~think
    fprintf('[ru] %s has no thinking mode; solving normally.\n', model);
end
numPredict = 3072;
if think
    numPredict = 12000;
end
[baseMsgs, numCtx] = local_buildSolveMessages(root, prompt, kb, env, ctx, conv, follow, opts, maxCtx, numPredict);
if ~isempty(ctx.topics)
    fprintf('[ru] Topic: %s', strjoin(ctx.topics, ', '));
    if ~isempty(ctx.examples)
        fprintf(' | closest solved example: %s', kb.examples(ctx.examples(1)).title);
    end
    fprintf('\n');
end
if follow
    fprintf('[ru] Follow-up: using the previous problem and its code from the conversation memory.\n');
end

temps = [0.1 0.3 0.5 0.7];
if opts.again
    temps = [0.6 0.7 0.8 0.9];
end
maxAttempts = numel(temps);
msgs = baseMsgs;
prevCode = '';
best = struct('code', '', 'output', '', 'warnings', {{}});
askedNumbers = false;
for attempt = 1:maxAttempts
    fprintf('[ru] Asking %s (attempt %d of %d)', model, attempt, maxAttempts);
    if attempt == 1
        fprintf(' - the first call can take a minute or two while the model loads');
    end
    fprintf('...\n');
    [reply, cut, err] = local_chat(host, model, msgs, temps(attempt), numCtx, numPredict, think, caps);
    if ~isempty(err)
        fprintf(2, '[ru] AI engine error: %s\n', err);
        local_log(root, ['ENGINE ERROR: ' err]);
        local_engineHelp();
        if isempty(best.code)
            local_convAdd(root, 'solve', turnPrompt, prevCode, ['FAILED: engine error: ' err], false);
            return
        end
        break
    end
    code = local_arrange(local_sanitize(local_extractCode(reply)));
    problem = local_precheck(code, kb);
    if isempty(problem)
        [okRun, info] = local_runCode(root, kb, code, sprintf('AI attempt %d', attempt));
        if okRun
            [feedback, warnings] = local_quality(info, prompt, code, attempt, maxAttempts, askedNumbers);
            if isempty(best.code) || isempty(feedback)
                best = struct('code', code, 'output', info.output, 'warnings', {warnings});
            end
            if isempty(feedback)
                local_finish(root, turnPrompt, code, info.output, t0, sprintf('AI attempt %d', attempt), warnings);
                ok = true;
                return
            end
            if ~isempty(strfind(feedback, 'did not use'))
                askedNumbers = true;
            end
            fprintf(2, '[ru] The script ran, but: %s\n', local_firstLine(feedback));
            local_log(root, sprintf('ATTEMPT %d RAN WITH ISSUES:\n%s\nISSUE: %s', attempt, code, feedback));
        else
            feedback = local_feedback(info, kb, code, cut, attempt == maxAttempts - 1);
            local_log(root, sprintf('ATTEMPT %d CODE:\n%s\nERROR: %s', attempt, code, info.message));
        end
    else
        fprintf(2, '[ru] Rejected the generated code: %s\n', local_firstLine(problem));
        feedback = [problem sprintf('\n\nRewrite the COMPLETE script in one ```matlab block.')];
        local_log(root, sprintf('ATTEMPT %d REJECTED:\n%s\nREASON: %s', attempt, code, problem));
    end
    if ~isempty(code) && strcmp(code, prevCode)
        feedback = [feedback sprintf('\nYou returned the same code as before. Use a different, simpler approach.')]; %#ok<AGROW>
    end
    prevCode = code;
    shown = code;
    if isempty(shown)
        shown = strtrim(reply);
    end
    msgs = [baseMsgs, {local_msg('assistant', ['```matlab' char(10) shown char(10) '```']), ...
        local_msg('user', feedback)}];
    if attempt < maxAttempts
        fprintf('[ru] Sending it back to the AI to fix it...\n');
    end
end
if ~isempty(best.code)
    fprintf('\n[ru] Using the best working script (it ran without errors; read the warnings below).\n');
    [okRun, info] = local_runCode(root, kb, best.code, 'best working script');
    if okRun
        local_finish(root, turnPrompt, best.code, info.output, t0, 'best working script', ...
            [best.warnings, {'The AI could not fully satisfy every check; verify the results.'}]);
        ok = true;
        return
    end
end
fprintf(2, '\n[ru] Could not get working code after %d attempts.\n', maxAttempts);
fprintf(2, '[ru] Tips: give every number and name the method (bisection, RK4, ...); split a long problem\n');
fprintf(2, '[ru]       into parts; try  ru again  or  ru think <problem>. See the last code with: ru last\n');
local_writeText(fullfile(local_brain(root), 'last_code.txt'), prevCode);
local_convAdd(root, 'solve', turnPrompt, prevCode, 'FAILED: no working code.', false);
local_log(root, 'RESULT: FAILED');
end

function m = local_msg(role, content)
m = struct('role', role, 'content', content);
end

function [ok, info] = local_runCode(root, kb, code, label)
code = local_arrange(code);
[scriptPart, funcNames] = local_splitScript(code);
info = local_emptyInfo();
if isempty(regexp(local_stripCode(scriptPart), '\S', 'once'))
    ok = false;
    if isempty(funcNames)
        info.message = 'The reply contained no MATLAB code.';
    else
        info.message = sprintf(['The reply contained only function definitions (%s) and no script code that calls ' ...
            'them. Add script lines at the top that define the problem data, call the function(s) and print the results.'], ...
            strjoin(funcNames, ', '));
    end
    return
end
local_resolveUserFunctions(code, kb);
bar = repmat('-', 1, 64);
fprintf('\n[ru] Code (%s):\n%s\n%s\n%s\n[ru] Output:\n', label, bar, code, bar);
[ok, info] = local_execute(root, code);
end

function local_finish(root, prompt, code, output, t0, how, warnings)
for k = 1:numel(warnings)
    fprintf(2, '[ru] Check: %s\n', warnings{k});
end
fprintf(['\n[ru] Done (%s, %.0f s). Variables are in the workspace. ' ...
    'Code: ru last | save: ru save <name> | follow-up: ru <what next>\n'], how, toc(t0));
local_writeText(fullfile(local_brain(root), 'last_code.txt'), code);
local_convAdd(root, 'solve', prompt, code, output, true);
local_log(root, sprintf('RESULT: OK (%s)\nCODE:\n%s', how, code));
end

function [feedback, warnings] = local_quality(info, prompt, code, attempt, maxAttempts, askedNumbers)
% Checks on a script that ran without errors. feedback non-empty = send back.
feedback = '';
warnings = {};
out = info.output;
hasPlot = ~isempty(regexp(local_stripCode(code), ['\<(plot|plot3|surf|surfc|mesh|meshc|contour|contourf|bar|barh|' ...
    'stem|stairs|scatter|histogram|hist|fplot|fsurf|fmesh|semilogx|semilogy|loglog|polar|polarplot|area|fill|' ...
    'quiver|errorbar|pie|plotmatrix|compass|feather|image|imagesc)\s*\('], 'once'));
if isempty(strtrim(out)) && ~hasPlot
    feedback = ['The script ran but printed nothing. Print every requested result with fprintf ' ...
        '(label, value, units), and the iteration table when iterations are asked for.'];
    return
end
if ~isempty(regexp(out, '(?<![A-Za-z])(NaN|-?Inf)(?![A-Za-z])', 'once'))
    if attempt < maxAttempts - 1
        feedback = ['The printed results contain NaN or Inf, which means a division by zero, a wrong ' ...
            'formula, a diverging method or a bad initial guess/bracket. Find the cause and fix it.'];
        return
    end
    warnings{end+1} = 'Some printed results are NaN or Inf.';
end
if ~isempty(regexp(out, 'Warning: (Matrix is (close to )?singular|Rank deficient|Failure at t)', 'once'))
    warnings{end+1} = 'MATLAB printed a numerical warning (singular matrix / rank deficient / ODE failure).';
end
missing = local_missingNumbers(prompt, code);
if ~isempty(missing)
    list = strjoin(missing, ', ');
    if numel(missing) >= 2 && ~askedNumbers && attempt < maxAttempts
        feedback = sprintf(['You did not use these numbers from the problem: %s. Every given value must be used ' ...
            'exactly as given (unless it is only a problem/figure/table number). Re-read the problem and rewrite ' ...
            'the complete script.'], list);
        return
    end
    warnings{end+1} = sprintf('These numbers from your problem do not appear in the code: %s. Make sure the problem was read correctly.', list);
end
end

function fb = local_feedback(info, kb, code, cut, lastChance)
msg = strtrim(info.message);
fprintf(2, '\n[ru] MATLAB error: %s\n', msg);
if ~isempty(info.lineText)
    fprintf(2, '[ru] at line %d: %s\n', info.line, info.lineText);
end
fb = sprintf('Running your script in MATLAB failed.\nError message:\n%s\n', msg);
if ~isempty(info.lineText)
    fb = [fb sprintf('The failing line %d is:\n%s\n', info.line, info.lineText)];
end
if ~isempty(info.where)
    fb = [fb sprintf('The error happened inside %s.\n', info.where)];
end
if ~isempty(strtrim(info.output))
    fb = [fb sprintf('Output printed before the error:\n%s\n', local_preview(info.output, 1500))];
end
h = local_hints(info, kb, code);
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

function h = local_hints(info, kb, code)
m = info.message;
h = '';
name = regexp(m, '(?:function or variable|Undefined function|Undefined variable|Unrecognized function or variable)\s+''([^'']+)''', 'tokens', 'once');
if ~isempty(name)
    n = name{1};
    if strcmp(n, 'e')
        h = [h sprintf('- MATLAB has no constant e: write exp(x) for e^x and exp(1) for e.\n')];
    elseif any(strcmp(n, {kb.lib.name}))
        h = [h sprintf('- %s is in ru_lib; call it exactly as documented.\n', n)];
    else
        h = [h sprintf(['- ''%s'' is not defined. Define the variable before using it, or if it is a function, ' ...
            'it does not exist on this computer: use base MATLAB or the ru_lib functions instead. ' ...
            'Local functions must be at the END of the script.\n'], n)];
    end
end
if ~isempty(regexp(m, 'Matrix dimensions must agree|Arrays have incompatible sizes|Incorrect dimensions', 'once'))
    h = [h sprintf(['- Use element-wise operators .* ./ .^ between vectors; make vectors the same size ' ...
        'and orientation (x(:) makes a column).\n'])];
end
if ~isempty(regexp(m, 'Index exceeds|Index in position|out of bound', 'once'))
    h = [h sprintf('- An index is larger than the array. Check loop limits and preallocate arrays with zeros(n,1).\n')];
end
if ~isempty(regexp(m, 'must be positive integers|must be real positive integers|Subscript indices', 'once'))
    h = [h sprintf(['- MATLAB indices start at 1 and must be whole numbers: never write y(0) or y(t) with a ' ...
        'real t; keep a separate index i and use y(i).\n'])];
end
if ~isempty(regexp(m, 'Parse error|Invalid expression|Unbalanced or unexpected|Invalid use of operator|unexpected MATLAB', 'once'))
    h = [h sprintf(['- Syntax error: check parentheses and brackets, write 2*x (never 2x), ' ...
        'use ~= (not !=) and %% for comments (not #).\n'])];
end
if ~isempty(regexp(m, 'Function definitions|must appear at the end|must be terminated|function definition', 'once'))
    h = [h sprintf('- Put all functions at the END of the script and close every function with end.\n')];
end
if ~isempty(regexp(m, 'Not enough input arguments', 'once'))
    h = [h sprintf(['- A function was called with too few inputs. Pass function handles with @ (fzero(@f,x0) ' ...
        'or fzero(f,x0) for an anonymous f) and give every argument.\n'])];
end
if ~isempty(regexp(m, 'Too many (input|output) arguments', 'once'))
    h = [h sprintf('- Wrong number of inputs/outputs for a function; check its signature.\n')];
end
if ~isempty(regexp(m, 'fzero|endpoints|change sign|sign change', 'once'))
    h = [h sprintf(['- fzero needs f(a) and f(b) of opposite signs for a bracket [a b]; plot f first or ' ...
        'use a single initial guess fzero(f, x0).\n'])];
end
if ~isempty(regexp(m, 'must return a column vector|column vector', 'once'))
    h = [h sprintf('- ODE functions must return a COLUMN vector: [dy1; dy2] with semicolons.\n')];
end
if ~isempty(regexp(m, 'concatenat', 'once'))
    h = [h sprintf('- Rows in [ ] must have the same number of columns; use ; between rows.\n')];
end
if ~isempty(regexp(m, 'Vectors must be the same length', 'once'))
    h = [h sprintf('- plot(x, y) needs x and y of the same length.\n')];
end
if ~isempty(regexp(m, 'sym|Symbolic', 'once'))
    h = [h sprintf(['- Avoid symbolic math: use anonymous functions, fzero, integral, ' ...
        'polyfit and numeric derivatives.\n'])];
end
lib = regexp(m, 'ru_lib:(\w+):', 'tokens', 'once');
where = regexp(info.where, '^(\w+)', 'tokens', 'once');
cand = {};
if ~isempty(lib)
    cand{end+1} = lib{1};
end
if ~isempty(where)
    cand{end+1} = where{1};
end
for k = 1:numel(cand)
    idx = find(strcmp({kb.lib.name}, cand{k}), 1);
    if ~isempty(idx)
        h = [h sprintf('- How to call %s:\n%s\n', kb.lib(idx).name, kb.lib(idx).help)]; %#ok<AGROW>
        break
    end
end
if isempty(h) && ~isempty(code)
    h = sprintf('- Read the error message carefully and fix the cause, not the symptom.\n');
end
end

function missing = local_missingNumbers(prompt, code)
% Significant numbers in the problem that the code never uses.
missing = {};
p = regexprep(prompt, ['(?i)\<(problem|prob\.?|example|ex\.?|exercise|fig\.?|figure|table|eq\.?|' ...
    'equation|section|sec\.?|chapter|ch\.?|page|pp?\.|slide|question|q\.?|set|batch|id|roll)\s*[A-Z]?\d+(\.\d+)*[a-z]?'], ' ');
p = regexprep(p, '(?m)^\s*\(?[A-Z]?\d+(\.\d+)+\)?\s+(?=[A-Za-z])', ' ');
p = regexprep(p, '(?<=[A-Za-z_])\d+', ' ');
tok = regexp(p, '(?<![\d.])\d+(?:,\d{3})*(?:\.\d+)?(?:[eE][-+]?\d+)?', 'match');
if isempty(tok)
    return
end
c = local_stripStrings(code);
ctok = regexp(c, '(?<![A-Za-z_\d.])\d*\.?\d+(?:[eE][-+]?\d+)?', 'match');
cval = str2double(ctok);
cval = cval(~isnan(cval));
for k = 1:numel(tok)
    s = strrep(tok{k}, ',', '');
    v = str2double(s);
    if isnan(v)
        continue
    end
    digits = numel(regexprep(regexprep(s, '[eE].*$', ''), '[^\d]', ''));
    significant = ~isempty(strfind(s, '.')) || digits >= 3 || v > 10;
    if ~significant || v == 0
        continue
    end
    found = any(abs(cval - v) <= 1e-9*max(1, abs(v)));
    if ~found
        % Also accept scaled forms (68.1 -> 0.0681e3, 2.54e9 written as 2.54*10^9, percent -> fraction).
        found = any(abs(cval*100 - v) <= 1e-9*max(1, abs(v))) || any(abs(cval/100 - v) <= 1e-9*max(1, abs(v))) ...
            || any(abs(cval*1000 - v) <= 1e-9*max(1, abs(v))) || any(abs(cval/1000 - v) <= 1e-9*max(1, abs(v)));
    end
    if ~found
        mant = regexp(s, '^(\d+(?:\.\d+)?)', 'tokens', 'once');
        if ~isempty(mant) && ~isempty(strfind(c, mant{1}))
            found = true;
        end
    end
    if ~found && ~any(strcmp(missing, s))
        missing{end+1} = s; %#ok<AGROW>
    end
end
if numel(missing) > 8
    missing = missing(1:8);
end
end

% =====================================================================
% Building the messages for the model
% =====================================================================

function [msgs, numCtx] = local_buildSolveMessages(root, prompt, kb, env, ctx, conv, follow, opts, maxCtx, numPredict)
extra = local_attachments(root, prompt, kb);
wsInfo = local_workspaceContext(prompt, follow);
cmdInfo = '';
if local_refersToCommands(prompt)
    cmdInfo = local_commandContext(12);
end
budget = 42000;
for pass = 1:5
    sys = local_systemPrompt(env);
    for t = ctx.topicIdx
        T = kb.topics(t);
        if ~isempty(T.cheat)
            sys = [sys sprintf('\n\nNOTES FOR %s PROBLEMS:\n%s', upper(T.name), T.cheat)]; %#ok<AGROW>
        end
    end
    if ~isempty(ctx.libFull)
        sys = [sys sprintf('\n\nRU_LIB FUNCTIONS YOU CAN CALL (already on the path):')]; %#ok<AGROW>
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
        sys = [sys sprintf('\n\nUSER RULES (always follow):\n%s', mem)]; %#ok<AGROW>
    end
    msgs = {local_msg('system', sys)};
    for k = ctx.examples
        ex = kb.examples(k);
        msgs{end+1} = local_msg('user', ['PROBLEM:' char(10) ex.problem]); %#ok<AGROW>
        msgs{end+1} = local_msg('assistant', ['```matlab' char(10) ex.code char(10) '```']); %#ok<AGROW>
    end
    user = '';
    if follow
        [prev, older] = local_convContext(conv, pass);
        msgs = [msgs, prev]; %#ok<AGROW>
        if ~isempty(older)
            user = [user older char(10)]; %#ok<AGROW>
        end
    end
    blocks = {opts.extraContext, extra, wsInfo, cmdInfo};
    for b = 1:numel(blocks)
        if ~isempty(blocks{b})
            user = [user blocks{b} char(10)]; %#ok<AGROW>
        end
    end
    if follow
        user = [user 'NEW REQUEST (it continues the conversation above; reuse its data, functions and ' ...
            'variables where they apply):' char(10) prompt]; %#ok<AGROW>
    else
        user = [user 'PROBLEM:' char(10) prompt]; %#ok<AGROW>
    end
    user = [user char(10) char(10) 'Write the complete MATLAB script.']; %#ok<AGROW>
    msgs{end+1} = local_msg('user', user); %#ok<AGROW>
    total = sum(cellfun(@(m) numel(m.content), msgs));
    if total <= budget
        break
    end
    % Too long: drop the second example, trim the library help, then the first example.
    if numel(ctx.examples) > 1
        ctx.examples = ctx.examples(1);
    elseif numel(ctx.libFull) > 4
        ctx.libFull = ctx.libFull(1:4);
    elseif ~isempty(ctx.examples)
        ctx.examples = zeros(1, 0);
    elseif numel(ctx.topicIdx) > 1
        ctx.topicIdx = ctx.topicIdx(1);
    end
end
numCtx = local_numCtx(total, numPredict, maxCtx);
end

function numCtx = local_numCtx(totalChars, numPredict, maxCtx)
numCtx = 2048 * ceil((totalChars / 3 + numPredict + 512) / 2048);
numCtx = max(numCtx, 4096);
numCtx = min(numCtx, min(maxCtx, 32768));
end

function s = local_systemPrompt(env)
L = {
    'You are ru, an expert MATLAB engineer and numerical-methods tutor for the BUET course CE206 (textbook: Chapra, Applied Numerical Methods with MATLAB).'
    ['Write ONE complete MATLAB script that solves the PROBLEM exactly as asked and runs without errors in MATLAB ' env.release '.']
    'Reply with exactly one ```matlab code block and nothing else.'
    ''
    'READING THE PROBLEM'
    '- Text copied from PDFs loses symbols: "x2" after a letter usually means x^2, "e-x" means exp(-x), "2pi(12.5)t" means 2*pi*12.5*t, "10-5" in "2x10-5" means 10^-5. Decide the intended math from context.'
    '- Solve every part (a), (b), (c)... in order, each in its own section starting with %% (a) ...'
    '- Use exactly the method, initial guesses, interval, tolerance, number of iterations and step size that the problem gives. If no method is named, use the most reliable built-in (fzero, roots, backslash, polyfit, interp1, spline, integral, ode45, eig).'
    '- Values that depend on the student ID (e.g. X = last three digits) come from USER RULES; if unknown, use the example value given and print a note.'
    ''
    'CODE RULES'
    '1. Hard-code every number from the problem. Never use input(), keyboard, pause, clc, clear, close all or cd.'
    '2. Write every operator: 2*x (never 2x), 3*(x+1); use element-wise .* ./ .^ whenever a value can be a vector.'
    '3. Define math functions as anonymous functions: f = @(x) x.^3 - 10*x.^2 + 5;  ODE systems: dydt = @(t,y) [y(2); -9.81*sin(y(1))];'
    '4. If a multi-line function is needed, put it at the END of the script and close it with end; it cannot see script variables, so pass them as arguments.'
    '5. sin/cos/tan use radians; sind/cosd/tand use degrees. log is ln, log10 is base 10, e^x is exp(x). There is no variable e.'
    '6. Every while loop must have an iteration limit. Arrays are indexed from 1 with whole numbers.'
    '7. Approximate relative error (%): ea = abs((xnew - xold)/xnew)*100. True relative error (%): et = abs((xtrue - xapprox)/xtrue)*100.'
    ''
    'OUTPUT RULES'
    '8. First print the equations/data you are using, e.g. fprintf(''f(x) = x^3 - 10x^2 + 5\n''), so the reader can confirm the problem was read correctly.'
    '9. Print every requested result with fprintf with a label and units, e.g. fprintf(''Root = %.6f m\n'', xr). Print an iteration table when iterations are asked for.'
    '10. Check the answer independently and print the check: f(root) near 0, norm(A*x - b), a built-in method (fzero, integral, ode45, eig, polyfit) or the analytical solution.'
    '11. Plot only when a graph/plot/figure/diagram is requested: figure; plot(...); grid on; xlabel(...); ylabel(...); title(...); legend(...).'
    ['12. ' env.toolboxLine]
    '13. Prefer the ru_lib functions listed below (already on the path) and call them exactly as documented. Never invent functions. Never call ru.'
    };
s = strjoin(L', char(10));
end

function s = local_askSystemPrompt(env)
L = {
    'You are ru, a precise MATLAB and numerical-methods tutor for the BUET course CE206 (textbook: Chapra, Applied Numerical Methods with MATLAB).'
    'Answer the question correctly and clearly in plain English: short paragraphs or bullet points, formulas in plain text (x^2, sqrt(), exp()).'
    'Rules:'
    '- Never invent MATLAB functions, options or results. If you are not sure, say so.'
    '- Do not guess numbers. If the question needs a calculation, say that it should be solved with ru and show the MATLAB code in a ```matlab block.'
    '- Keep code examples short and correct for MATLAB (not Octave).'
    ['- ' env.toolboxLine]
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
try
    E.release = ['R' version('-release')];
catch
    E.release = version;
end
if strcmp(E.release, 'R')
    E.release = version;
end
E.sym = local_hasToolbox('Symbolic_Toolbox', 'syms');
E.stats = local_hasToolbox('Statistics_Toolbox', 'normcdf');
E.optim = local_hasToolbox('Optimization_Toolbox', 'fsolve');
E.curvefit = local_hasToolbox('Curve_Fitting_Toolbox', 'fit');
E.signal = local_hasToolbox('Signal_Toolbox', 'butter');
E.vision = local_hasToolbox('Video_and_Image_Blockset', 'ocr');
yn = {'no', 'yes'};
E.toolboxLine = sprintf(['Toolboxes on this computer: Symbolic Math %s, Statistics %s, Optimization %s, ' ...
    'Curve Fitting %s, Signal Processing %s. NEVER call a function from a toolbox marked no. ' ...
    'Without Statistics use the stat_ functions of ru_lib; without Optimization use root_newtonsys, fminsearch or ' ...
    'fit_nonlinear; without Symbolic Math use fzero, roots, integral and anonymous functions.'], ...
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
    mem = strtrim(local_ascii(local_readText(f)));
    if numel(mem) > 4000
        mem = mem(end-3999:end);
    end
end
end

function extra = local_attachments(root, prompt, kb)
extra = '';
names = unique(regexp(prompt, '[A-Za-z]\w*(?=\.m\>)', 'match'));
uf = kb.userFiles;
for k = 1:numel(uf)
    n = uf(k).name;
    if numel(n) >= 4 && isvarname(n) && ~isempty(regexpi(prompt, ...
            ['\<my\s+' n '\>|\<' n '\s+(function|file|script|code)\>|\<(function|file|script)\s+' n '\>'], 'once'))
        names{end+1} = n; %#ok<AGROW>
    end
end
names = unique(names);
for k = 1:numel(names)
    idx = local_findUserFile(kb, names{k});
    if idx == 0
        continue
    end
    U = kb.userFiles(idx);
    addpath(U.folder, '-begin');
    txt = local_ascii(local_readText(fullfile(U.folder, [U.name '.m'])));
    if numel(txt) > 6000
        txt = [txt(1:6000) char(10) '% ... (truncated)'];
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
        peek = local_peekData(p);
        if ~isempty(peek)
            extra = [extra peek]; %#ok<AGROW>
        end
    end
end
end

function s = local_peekData(p)
% Column names / first rows of a data file so the model uses the right names.
s = '';
try
    [~, ~, ext] = fileparts(p);
    switch lower(ext)
        case {'.xlsx', '.xls', '.csv'}
            T = readtable(p);
            s = sprintf('Its columns (readtable names): %s; %d rows.\n', strjoin(T.Properties.VariableNames, ', '), height(T));
        case {'.txt', '.dat'}
            L = regexp(local_readText(p), '[^\r\n]+', 'match');
            s = sprintf('Its first lines:\n%s\n', strjoin(L(1:min(3, numel(L))), char(10)));
    end
catch
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
d = local_findFiles(root, name, local_skipDirs());
if ~isempty(d)
    p = d{1};
    return
end
w = which(name);
if ~isempty(w)
    p = w;
end
end

function local_resolveUserFunctions(code, kb)
uf = kb.userFiles;
if isempty(uf)
    return
end
c = local_stripCode(code);
calls = regexp(c, '(?<![\w.@])([A-Za-z]\w*)\s*\(', 'tokens');
names = cellfun(@(t) t{1}, calls, 'UniformOutput', false);
names = unique([names, regexp(c, '(?<=@)[A-Za-z]\w*', 'match')]);
for k = 1:numel(names)
    n = names{k};
    if exist(n, 'builtin') || ~isempty(which(n))
        continue
    end
    idx = local_findUserFile(kb, n);
    if idx > 0
        addpath(kb.userFiles(idx).folder, '-end');
    end
end
end

% =====================================================================
% Asking questions, explaining, fixing, repeating
% =====================================================================

function local_ask(root, question, opts)
t0 = tic;
local_log(root, sprintf('\n==== %s ====\nMODE: ask\nQUESTION:\n%s', local_now(), question));
kb = local_kb(root);
env = local_env();
conv = local_convLoad(root);
follow = local_isFollowUp(question, conv);
ctx = local_retrieve(kb, question);
[host, model, caps, maxCtx] = local_engine(root, false, 'text');
if isempty(model)
    return
end
sys = local_askSystemPrompt(env);
for t = ctx.topicIdx
    T = kb.topics(t);
    if ~isempty(T.cheat)
        sys = [sys sprintf('\n\nNOTES FOR %s:\n%s', upper(T.name), T.cheat)]; %#ok<AGROW>
    end
end
mem = local_memory(root);
if ~isempty(mem)
    sys = [sys sprintf('\n\nUSER RULES:\n%s', mem)];
end
msgs = {local_msg('system', sys)};
if follow
    prev = local_convContext(conv, 1);
    msgs = [msgs, prev];
end
user = question;
if ~isempty(opts.extraContext)
    user = [opts.extraContext char(10) user];
end
if local_refersToCommands(question)
    user = [local_commandContext(12) char(10) user];
end
msgs{end+1} = local_msg('user', user);
total = sum(cellfun(@(m) numel(m.content), msgs));
think = opts.think && any(strcmp(caps, 'thinking'));
fprintf('[ru] Asking %s...\n', model);
[reply, ~, err] = local_chat(host, model, msgs, 0.3, local_numCtx(total, 1500, maxCtx), 1500, think, caps);
if ~isempty(err)
    fprintf(2, '[ru] AI engine error: %s\n', err);
    local_engineHelp();
    return
end
reply = strtrim(reply);
fprintf('\n%s\n', reply);
bad = local_unknownFunctionsInText(reply);
if ~isempty(bad)
    fprintf(2, ['\n[ru] Check: these names in the answer are not functions on this MATLAB (maybe a toolbox you do not ' ...
        'have, or a mistake): %s\n'], strjoin(bad, ', '));
end
fprintf('\n[ru] (%.0f s) This answer is from a small offline model: verify important facts. To compute something, ask: ru <problem>\n', toc(t0));
turnQ = question;
if ~isempty(opts.turnPrompt)
    turnQ = opts.turnPrompt;
end
local_convAdd(root, 'ask', turnQ, '', reply, true);
local_log(root, sprintf('ANSWER:\n%s', reply));
end

function local_explainLast(root)
f = fullfile(local_brain(root), 'last_code.txt');
if exist(f, 'file') ~= 2
    fprintf('[ru] Nothing has been run yet. Ask a question instead: ru ask <question>\n');
    return
end
code = local_readText(f);
opts = local_opts();
opts.extraContext = ['THE LAST MATLAB CODE:' char(10) '```matlab' char(10) code char(10) '```'];
opts.turnPrompt = 'ru explain (the last code)';
local_ask(root, ['Explain this code step by step for a student: what each part does, which numerical method ' ...
    'it uses and why, and how to read the printed results.'], opts);
end

function local_again(root, hint, opts)
conv = local_convLoad(root);
k = numel(conv);
while k >= 1 && ~strcmp(conv{k}.mode, 'solve')
    k = k - 1;
end
if k < 1
    fprintf('[ru] There is no earlier problem to solve again. Type: ru <problem>\n');
    return
end
T = conv{k};
opts.forceAI = true;
opts.forceSolve = true;
opts.again = true;
opts.turnPrompt = T.prompt;
opts.label = ' (again)';
ctxt = 'The user was NOT satisfied with the previous solution of this problem. Solve it again carefully with a different, correct approach.';
if ~isempty(T.code)
    ctxt = [ctxt char(10) 'The previous code was:' char(10) '```matlab' char(10) T.code char(10) '```'];
end
if ~isempty(strtrim(hint))
    ctxt = [ctxt char(10) 'The user says: ' local_ascii(hint)];
end
opts.extraContext = ctxt;
fprintf('[ru] Solving again: %s\n', local_preview(T.prompt, 300));
local_solve(root, T.prompt, opts);
end

function local_fix(root, note, opts)
[errText, cmds, files] = local_lastErrorContext();
if isempty(errText)
    conv = local_convLoad(root);
    if ~isempty(conv) && ~conv{end}.ok && strcmp(conv{end}.mode, 'solve')
        fprintf('[ru] No new error in your Command Window; the last ru problem failed, so trying it again.\n');
        local_again(root, note, opts);
        return
    end
    fprintf(['[ru] I could not find an error. Run your code first (so MATLAB shows the error), then type: ru fix\n' ...
        '[ru] Or describe it: ru fix <what is wrong>\n']);
    if isempty(strtrim(note))
        return
    end
end
fprintf('[ru] Error found:\n%s\n', local_preview(errText, 1500));
ctxt = '';
if ~isempty(cmds)
    ctxt = [ctxt 'COMMANDS THE USER RAN IN THE COMMAND WINDOW (oldest first):' char(10) strjoin(cmds, char(10)) char(10)];
end
for k = 1:numel(files)
    ctxt = [ctxt sprintf('\nTHE USER''S FILE %s:\n```matlab\n%s\n```\n', files{k}, ...
        local_preview(local_ascii(local_readText(files{k})), 6000))]; %#ok<AGROW>
end
problem = ['Fix this MATLAB error. Explain the cause in 1-3 comment lines at the top of the script, then write ' ...
    'a corrected complete script that does what the user intended and prints the results.' char(10) ...
    'ERROR:' char(10) errText];
if ~isempty(strtrim(note))
    problem = [problem char(10) 'The user adds: ' local_ascii(note)];
end
opts.forceAI = true;
opts.forceSolve = true;
opts.extraContext = ctxt;
opts.turnPrompt = ['ru fix: ' local_firstLine(errText)];
opts.label = ' (fix)';
local_solve(root, problem, opts);
end

function [errText, cmds, files] = local_lastErrorContext()
errText = '';
files = {};
cmds = local_recentCommands(15);
tail = local_diaryTail(120);
if ~isempty(tail)
    lines = regexp(tail, '\n', 'split');
    last = 0;
    for k = numel(lines):-1:1
        if ~isempty(regexp(lines{k}, ['^\s*(Error|Error using|Error in|Undefined|Unrecognized|Index exceeds|' ...
                'Arrays have|Incorrect|Invalid|Not enough|Too many|Unable|Dimensions|Caused by)'], 'once'))
            last = k;
            break
        end
    end
    if last > 0
        first = last;
        while first > 1 && last - first < 12 && ~isempty(strtrim(lines{first-1})) ...
                && isempty(regexp(lines{first-1}, '^\s*\[ru\]', 'once'))
            first = first - 1;
        end
        if isempty(regexp(strjoin(lines(first:last), ' '), '\[ru\]', 'once'))
            errText = strtrim(strjoin(lines(first:min(numel(lines), last + 3)), char(10)));
        end
    end
end
if isempty(errText)
    try
        le = lasterr; %#ok<LERR>
        if ~isempty(strtrim(le)) && isempty(strfind(le, 'ru_task_'))
            errText = strtrim(le);
        end
    catch
    end
end
if isempty(errText)
    return
end
refs = regexp(errText, '(?:Error in|Error using)\s+([A-Za-z]\w*)|File:\s*([^\s]+\.m)|(\w+)\s+\(line\s+\d+\)', 'tokens');
seen = {};
for k = 1:numel(refs)
    parts = refs{k};
    for j = 1:numel(parts)
        n = regexprep(strtrim(parts{j}), '\.m$', '');
        if isempty(n) || any(strcmp(seen, n)) || ~isvarname(n)
            continue
        end
        seen{end+1} = n; %#ok<AGROW>
        w = which(n);
        if ~isempty(w) && exist(w, 'file') == 2 && isempty(strfind(w, matlabroot)) ...
                && isempty(regexp(w, '[\\/]ru_lib[\\/]|[\\/]brain[\\/]', 'once')) && ~strcmpi(n, 'ru')
            files{end+1} = w; %#ok<AGROW>
        end
    end
end
files = unique(files);
end

% =====================================================================
% Images: read a problem from a screenshot / photo
% =====================================================================

function local_imageSolve(root, args, opts)
file = '';
note = '';
if ~isempty(args)
    cand = strtrim(args{1});
    cand = regexprep(cand, '^["'']|["'']$', '');
    if exist(cand, 'file') == 2
        file = cand;
        note = strjoin(args(2:end), ' ');
    elseif numel(args) >= 1 && ~isempty(regexp(strjoin(args, ' '), '\.(png|jpe?g|bmp|gif|tiff?|webp)\>', 'once', 'ignorecase'))
        full = strtrim(regexprep(strjoin(args, ' '), '^["'']|["'']$', ''));
        m = regexp(full, '^(.*?\.(png|jpe?g|bmp|gif|tiff?|webp))\s*(.*)$', 'tokens', 'once', 'ignorecase');
        if ~isempty(m) && exist(strtrim(m{1}), 'file') == 2
            file = strtrim(m{1});
            note = m{3};
        else
            fprintf(2, '[ru] Image file not found: %s\n', full);
            return
        end
    else
        note = strjoin(args, ' ');
    end
end
if isempty(file)
    file = local_clipboardImage(root);
    if ~isempty(file)
        fprintf('[ru] Using the image on the clipboard.\n');
    end
end
if isempty(file) && local_desktop()
    [fn, fp] = uigetfile({'*.png;*.jpg;*.jpeg;*.bmp;*.gif;*.tif;*.tiff;*.webp', 'Images'}, ...
        'ru: choose a picture of the problem');
    if ischar(fn)
        file = fullfile(fp, fn);
    end
end
if isempty(file)
    fprintf(2, ['[ru] No image. Take a screenshot (Win+Shift+S) so it is on the clipboard and type  ru img,\n' ...
        '[ru] or give the file:  ru img C:\\path\\problem.png\n']);
    return
end
text = local_transcribe(root, file);
if isempty(strtrim(text))
    return
end
fprintf('\n[ru] Text read from the image:\n%s\n', text);
if local_desktop()
    lines = regexp(text, '\n', 'split');
    a = {};
    try
        a = inputdlg({['Check the text read from the image. Fix any wrong number or symbol, add anything missing ' ...
            '(e.g. values shown only in the figure), then press OK:']}, 'ru: check the problem', [24 130], {char(lines)});
    catch
    end
    if isempty(a)
        fprintf('[ru] Cancelled. (The text is in the conversation memory; ru again will not use it.)\n');
        return
    end
    v = a{1};
    if size(v, 1) > 1
        text = strjoin(cellstr(v)', char(10));
    else
        text = v;
    end
else
    fprintf(['[ru] Solving this text. If a number was read wrongly, copy the text above, correct it and use  ' ...
        'ru  (paste box) instead.\n']);
end
prompt = text;
if ~isempty(strtrim(note))
    prompt = [local_ascii(note) char(10) char(10) text];
end
local_route(root, prompt, opts);
end

function f = local_clipboardImage(root)
% Save an image on the system clipboard (e.g. a Win+Shift+S screenshot) as PNG.
f = '';
try
    if exist('OCTAVE_VERSION', 'builtin') || ~usejava('awt')
        return
    end
    cb = java.awt.Toolkit.getDefaultToolkit().getSystemClipboard();
    flavor = java.awt.datatransfer.DataFlavor.imageFlavor;
    if ~cb.isDataFlavorAvailable(flavor)
        return
    end
    img = cb.getData(flavor);
    w = img.getWidth([]);
    h = img.getHeight([]);
    if w <= 0 || h <= 0
        return
    end
    bi = java.awt.image.BufferedImage(w, h, java.awt.image.BufferedImage.TYPE_INT_RGB);
    g = bi.createGraphics();
    g.setColor(java.awt.Color.WHITE);
    g.fillRect(0, 0, w, h);
    g.drawImage(img, 0, 0, []);
    g.dispose();
    f = fullfile(local_brain(root), 'clipboard_image.png');
    javax.imageio.ImageIO.write(bi, 'png', java.io.File(f));
catch
    f = '';
end
end

function text = local_transcribe(root, file)
text = '';
[host, model, caps] = local_engine(root, false, 'vision');
if isempty(model)
    env = local_env();
    if env.vision
        fprintf('[ru] No vision model; reading the text with MATLAB''s ocr (equations and tables may be lost).\n');
        try
            r = ocr(imread(file));
            text = strtrim(r.Text);
        catch ME
            fprintf(2, '[ru] ocr failed: %s\n', ME.message);
        end
        return
    end
    fprintf(2, ['[ru] Reading pictures needs a vision model such as qwen3.5:4b on the pendrive.\n' ...
        '[ru] On a PC with internet run setup_ru.bat (it downloads qwen3.5:4b), or type the problem: ru\n']);
    return
end
b64 = local_imageBase64(file);
if isempty(b64)
    fprintf(2, '[ru] Could not read the image file %s\n', file);
    return
end
prompt = ['Transcribe the problem in this image exactly as plain text. Keep every number, unit, variable name, ' ...
    'table (one row per line, columns separated by spaces) and equation (write math in plain text: x^2, sqrt(), ' ...
    'exp(), pi, integral from a to b of ... dx, d2y/dx2). If there is a figure, describe it in words with all ' ...
    'dimensions, loads, angles, supports and labels. Do NOT solve the problem and do not add anything else.'];
msg = struct('role', 'user', 'content', prompt, 'images', {{b64}});
fprintf('[ru] Reading the image with %s (this can take a minute)...\n', model);
[text, ~, err] = local_chat(host, model, {msg}, 0, 8192, 2500, false, caps);
if ~isempty(err)
    fprintf(2, '[ru] Vision model error: %s\n', err);
    text = '';
    return
end
text = strtrim(local_ascii(regexprep(text, '^```\w*\s*|\s*```$', '')));
end

function b64 = local_imageBase64(file)
b64 = '';
try
    [~, ~, ext] = fileparts(file);
    src = file;
    if any(strcmpi(ext, {'.bmp', '.gif', '.tif', '.tiff', '.webp'})) || local_fileBytes(file) > 4e6
        img = imread(file);
        if size(img, 3) == 1
            img = repmat(img, [1 1 3]);
        end
        step = max(1, ceil(max(size(img, 1), size(img, 2)) / 2000));
        img = img(1:step:end, 1:step:end, 1:3);
        src = [tempname '.png'];
        imwrite(img, src);
    end
    fid = fopen(src, 'r');
    bytes = fread(fid, inf, '*uint8');
    fclose(fid);
    b64 = matlab.net.base64encode(bytes');
catch
    b64 = '';
end
end

function n = local_fileBytes(f)
d = dir(f);
n = 0;
if ~isempty(d)
    n = d(1).bytes;
end
end

% =====================================================================
% Memory: conversation, MATLAB command history, workspace
% =====================================================================

function f = local_convFile(root)
f = fullfile(local_brain(root), 'conversation.json');
end

function conv = local_convLoad(root)
conv = {};
f = local_convFile(root);
if exist(f, 'file') ~= 2
    return
end
try
    d = jsondecode(local_readText(f));
    if isstruct(d)
        conv = num2cell(d(:)');
    elseif iscell(d)
        conv = d(:)';
    end
    keep = true(1, numel(conv));
    for k = 1:numel(conv)
        keep(k) = isstruct(conv{k}) && all(isfield(conv{k}, {'time', 'mode', 'prompt', 'code', 'output', 'ok'}));
    end
    conv = conv(keep);
catch
    conv = {};
end
end

function local_convAdd(root, mode, prompt, code, output, ok)
conv = local_convLoad(root);
t = struct('time', local_now(), 'stamp', now, 'mode', mode, 'prompt', local_preview(prompt, 8000), ...
    'code', local_preview(code, 8000), 'output', local_preview(output, 2000), 'ok', logical(ok));
conv{end+1} = t;
if numel(conv) > 40
    conv = conv(end-39:end);
end
try
    local_writeText(local_convFile(root), jsonencode(conv));
catch
end
end

function local_convClear(root)
f = local_convFile(root);
if exist(f, 'file') == 2
    delete(f);
end
end

function local_showHistory(root, nText)
conv = local_convLoad(root);
if isempty(conv)
    fprintf('[ru] The conversation memory is empty.\n');
    return
end
n = str2double(nText);
if isnan(n) || n < 1
    n = 5;
end
first = max(1, numel(conv) - n + 1);
for k = first:numel(conv)
    T = conv{k};
    status = 'ok';
    if ~T.ok
        status = 'FAILED';
    end
    fprintf('\n---- %d. %s  [%s, %s] ----\n%s\n', k, T.time, T.mode, status, local_preview(T.prompt, 600));
    if ~isempty(T.output)
        fprintf('  -> %s\n', strrep(local_preview(T.output, 400), char(10), [char(10) '     ']));
    end
end
fprintf('\n[ru] %d turns remembered (brain\\conversation.json). Clear them with: ru new\n', numel(conv));
end

function tf = local_isFollowUp(prompt, conv)
tf = false;
if isempty(conv)
    return
end
T = conv{end};
if isfield(T, 'stamp') && isnumeric(T.stamp) && now - T.stamp > 0.25
    return
end
q = lower(prompt);
strong = ~isempty(regexp(q, ['\<(previous|above|earlier|last (problem|question|answer|code|result|one|graph|plot)|' ...
    'same (data|problem|function|values|equation|equations|matrix|system|question)|' ...
    'that (problem|code|result|answer|plot|graph|function)|the code|your code|this code|redo|rerun|re-run|instead)\>'], 'once'));
weak = ~isempty(regexp(q, ['^\s*(and|also|now|then|next|but|so|what about|how about|ok|okay)\>|\<(it|them|again|' ...
    'change|modify|update|continue|increase|decrease|more|less|smaller|bigger|larger|explain|why)\>'], 'once'));
tf = strong || (numel(prompt) < 220 && weak);
end

function [msgs, older] = local_convContext(conv, pass)
% The last turn as a chat exchange (+ earlier problems as short text).
msgs = {};
older = '';
if isempty(conv)
    return
end
T = conv{end};
if strcmp(T.mode, 'ask')
    msgs = {local_msg('user', T.prompt), local_msg('assistant', local_preview(T.output, 3000))};
else
    msgs = {local_msg('user', ['PROBLEM:' char(10) T.prompt])};
    if ~isempty(T.code)
        msgs{end+1} = local_msg('assistant', ['```matlab' char(10) T.code char(10) '```']);
        if pass <= 3 && ~isempty(strtrim(T.output))
            msgs{end+1} = local_msg('user', ['That script ran in MATLAB and printed:' char(10) local_preview(T.output, 1500)]);
            msgs{end+1} = local_msg('assistant', 'OK.');
        end
    else
        msgs{end+1} = local_msg('assistant', 'I could not solve it.');
    end
end
n = numel(conv);
if pass <= 2 && n >= 2
    parts = {};
    for k = max(1, n - 3):n - 1
        parts{end+1} = sprintf('- %s', local_preview(regexprep(conv{k}.prompt, '\s+', ' '), 200)); %#ok<AGROW>
    end
    older = ['EARLIER PROBLEMS IN THIS CONVERSATION (for reference only):' char(10) strjoin(parts, char(10))];
end
end

function tf = local_refersToCommands(prompt)
tf = ~isempty(regexpi(prompt, ['\<(my|above|previous|earlier|last)\s+(code|command|commands|result|results|output|' ...
    'script|variable|variables|data|matrix|vector|function|error)\>|\<workspace\>|\<command window\>|\<ans\>'], 'once'));
end

function s = local_commandContext(n)
s = '';
cmds = local_recentCommands(n);
if ~isempty(cmds)
    s = ['RECENT COMMANDS THE USER TYPED IN MATLAB (oldest first):' char(10) strjoin(cmds, char(10)) char(10)];
end
tail = local_diaryTail(40);
if ~isempty(strtrim(tail))
    s = [s 'END OF THE COMMAND WINDOW LOG:' char(10) tail char(10)];
end
end

function cmds = local_recentCommands(n)
cmds = {};
try
    h = com.mathworks.mlservices.MLCommandHistoryServices.getSessionHistory;
    cmds = cell(h)';
catch
end
if isempty(cmds)
    try
        f = fullfile(prefdir, 'History.xml');
        if exist(f, 'file') == 2
            txt = local_readText(f);
            tok = regexp(txt, '<command[^>]*>(.*?)</command>', 'tokens');
            cmds = cellfun(@(c) local_xmlUnescape(c{1}), tok, 'UniformOutput', false);
        else
            f = fullfile(prefdir, 'history.m');
            if exist(f, 'file') == 2
                cmds = regexp(local_readText(f), '[^\r\n]+', 'match');
            end
        end
    catch
    end
end
if isempty(cmds)
    return
end
cmds = cmds(~cellfun(@isempty, regexp(cmds, '\S', 'once')));
cmds = cmds(cellfun(@isempty, regexp(cmds, '^\s*(ru\>|%%|%-- )', 'once')));
if numel(cmds) > n
    cmds = cmds(end-n+1:end);
end
end

function s = local_xmlUnescape(s)
s = strrep(s, '&lt;', '<');
s = strrep(s, '&gt;', '>');
s = strrep(s, '&quot;', '"');
s = strrep(s, '&apos;', '''');
s = strrep(s, '&#10;', char(10));
s = strrep(s, '&amp;', '&');
end

function local_startDiary(root, verbose)
try
    if strcmp(get(0, 'Diary'), 'on')
        return
    end
    f = fullfile(local_brain(root), 'session_log.txt');
    if local_fileBytes(f) > 2e6
        movefile(f, fullfile(local_brain(root), 'session_log_old.txt'), 'f');
    end
    diary(f);
    diary('on');
    if verbose
        fprintf('[ru] Ready. Session log: %s (lets "ru fix" see your errors). Type  ru help\n', f);
    end
catch
end
end

function tail = local_diaryTail(nLines)
tail = '';
try
    if ~strcmp(get(0, 'Diary'), 'on')
        return
    end
    f = get(0, 'DiaryFile');
    diary('off');
    diary('on');
    if exist(f, 'file') ~= 2
        f = fullfile(pwd, f);
    end
    if exist(f, 'file') ~= 2
        return
    end
    txt = local_readText(f);
    if numel(txt) > 40000
        txt = txt(end-39999:end);
    end
    lines = regexp(strrep(txt, char(13), ''), '\n', 'split');
    lines = lines(cellfun(@isempty, regexp(lines, '^\s*ru(\s|$|\()', 'once')));
    tail = strjoin(lines(max(1, numel(lines) - nLines + 1):end), char(10));
catch
end
end

function s = local_workspaceContext(prompt, follow)
% Variables already in the base workspace that the prompt refers to.
s = '';
try
    W = evalin('base', 'whos');
catch
    return
end
if isempty(W)
    return
end
cue = local_refersToCommands(prompt) || follow;
use = false(1, numel(W));
for k = 1:numel(W)
    n = W(k).name;
    if strncmp(n, 'ru__', 4) || strcmp(n, 'ans')
        continue
    end
    mentioned = ~isempty(regexp(prompt, ['(?<![\w.])' regexptranslate('escape', n) '(?![\w])'], 'once'));
    use(k) = (mentioned && (numel(n) >= 3 || cue)) || (cue && numel(W) <= 25);
end
W = W(use);
if isempty(W)
    return
end
lines = {};
for k = 1:min(numel(W), 25)
    n = W(k).name;
    d = sprintf('%s: %s %s', n, strjoin(arrayfun(@num2str, W(k).size, 'UniformOutput', false), 'x'), W(k).class);
    try
        v = evalin('base', n);
        if (isnumeric(v) || islogical(v)) && numel(v) <= 30
            d = [d ' = ' mat2str(v, 6)]; %#ok<AGROW>
        elseif ischar(v) && numel(v) <= 80
            d = [d ' = ''' v '''']; %#ok<AGROW>
        elseif isa(v, 'function_handle')
            d = [d ' = ' func2str(v)]; %#ok<AGROW>
        elseif istable(v)
            d = [d ' with columns ' strjoin(v.Properties.VariableNames, ', ')]; %#ok<AGROW>
        end
    catch
    end
    lines{end+1} = ['  ' d]; %#ok<AGROW>
end
s = ['VARIABLES ALREADY IN THE MATLAB WORKSPACE (you may use them directly):' char(10) strjoin(lines, char(10)) char(10)];
end

% =====================================================================
% Code handling: extract, sanitize, arrange, check, run
% =====================================================================

function code = local_extractCode(reply)
code = '';
if isempty(reply)
    return
end
r = strrep(reply, char(13), '');
r = regexprep(r, '<think>.*?</think>', '');
blocks = regexp(r, '```[ \t]*([A-Za-z0-9_+-]*)[ \t]*\n(.*?)```', 'tokens');
if isempty(blocks)
    open = regexp(r, '```[ \t]*[A-Za-z0-9_+-]*[ \t]*\n(.*)$', 'tokens', 'once');
    if ~isempty(open)
        code = strtrim(open{1});
        return
    end
    lines = regexp(r, '\n', 'split');
    keep = false(size(lines));
    for k = 1:numel(lines)
        L = strtrim(lines{k});
        keep(k) = isempty(L) || L(1) == '%' || ~isempty(regexp(L, ['[;=(){}\[\]]|^(end|else|elseif|otherwise|' ...
            'function|for|while|if|switch|case|try|catch|hold|grid|figure|axis|format|legend|disp|fprintf)\>'], 'once'));
        if keep(k) && ~isempty(regexp(L, '^[A-Z][a-z]+( [a-z]+){3,}[^;]*[.:]$', 'once'))
            keep(k) = false;
        end
    end
    code = strtrim(strjoin(lines(keep), char(10)));
    return
end
parts = {};
for k = 1:numel(blocks)
    lang = lower(blocks{k}{1});
    if isempty(lang) || any(strcmp(lang, {'matlab', 'm', 'octave', 'mat', 'mlx'}))
        parts{end+1} = strtrim(blocks{k}{2}); %#ok<AGROW>
    end
end
if isempty(parts)
    parts = {strtrim(blocks{1}{2})};
end
% Output-only blocks ("ans = ...") are not code.
isOut = cellfun(@(p) ~isempty(regexp(p, '^\s*(ans|\w+)\s*=\s*\n', 'once')) && isempty(regexp(p, '[;(]', 'once')), parts);
if any(~isOut)
    parts = parts(~isOut);
end
code = strjoin(parts, [char(10) char(10)]);
end

function code = local_sanitize(code)
if isempty(code)
    return
end
code = local_ascii(strrep(code, char(13), ''));
code = strrep(code, char(9), '    ');
% Octave-isms and other dialects -> MATLAB.
code = regexprep(code, '\<(endfunction|endif|endfor|endwhile|endswitch|end_try_catch|end_unwind_protect|endparfor)\>', 'end');
code = regexprep(code, '(?m)^(\s*)#(?![{}])', '$1%');
code = regexprep(code, '(?m)^(\s*)printf\s*\(', '$1fprintf(');
code = regexprep(code, '(?m)^(\s*)([A-Za-z_]\w*)\s*\+\+\s*;?\s*$', '$1$2 = $2 + 1;');
code = regexprep(code, '(?m)^(\s*)([A-Za-z_]\w*(?:\([^=\n]*\))?)\s*([-+*/])=\s*([^;\n]+);?\s*$', '$1$2 = $2 $3 ($4);');
lines = regexp(code, '\n', 'split');
keep = true(size(lines));
for k = 1:numel(lines)
    L = lines{k};
    s = local_stripCode(L);
    if isempty(regexp(s, '\S', 'once'))
        continue
    end
    % Remove workspace-destroying or blocking statements.
    s2 = regexprep(s, ['(?<![\w.])(clc|clear\s+all|clear\s+variables|clearvars[^;,]*|clear(?!\s*\w)|' ...
        'close\s+all|close\(\s*''all''\s*\)|pause(\s*\([^)]*\))?|commandwindow|home)(?![\w(])\s*[;,]?'], '');
    if isempty(regexp(s2, '\S', 'once'))
        keep(k) = false;
    elseif ~strcmp(s2, s)
        idx = regexp(s, '\S', 'once');
        lines{k} = [L(1:idx-1) strtrim(s2) L(numel(s)+1:end)];
    end
    % "clear x y" keeps the listed variables' removal only; drop it (it can erase results).
    if ~isempty(regexp(s, '^\s*clear\s+\w', 'once'))
        keep(k) = false;
    end
end
code = strjoin(lines(keep), char(10));
% Implicit multiplication outside strings/comments: 2x -> 2*x, 2(x) -> 2*(x), )( -> )*(
code = local_fixImplicitMult(code);
code = regexprep(code, '\n{3,}', sprintf('\n\n'));
code = strtrim(code);
end

function code = local_fixImplicitMult(code)
lines = regexp(code, '\n', 'split');
for k = 1:numel(lines)
    L = lines{k};
    s = local_stripCode(L);
    if isempty(regexp(s, '\S', 'once'))
        continue
    end
    [st, en] = regexp(s, '(?<![\w.])(\d+\.?\d*|\.\d+)(?=[A-Za-z_(])', 'start', 'end');
    for j = numel(st):-1:1
        nxt = s(en(j)+1:end);
        if ~isempty(regexp(nxt, '^([eEdD][-+]?\d|[ij](?![\w(])|x[0-9A-Fa-f]+\>|b[01]+\>|(end|if|for|while|else|elseif)\>)', 'once'))
            continue
        end
        L = [L(1:en(j)) '*' L(en(j)+1:end)];
        s = [s(1:en(j)) '*' s(en(j)+1:end)];
    end
    lines{k} = L;
end
code = strjoin(lines, char(10));
end

function code = local_arrange(code)
% Put local functions at the end of the script and make sure each ends with end.
if isempty(code)
    return
end
lines = regexp(code, '\n', 'split');
stripped = regexp(local_stripCode(code), '\n', 'split');
if numel(stripped) ~= numel(lines)
    return
end
isFun = ~cellfun(@isempty, regexp(stripped, '^\s*function\>', 'once'));
if ~any(isFun)
    return
end
[depthAfter, ok] = local_blockDepth(stripped, true);
funStarts = find(isFun);
blocks = {};
inFun = false(size(lines));
if ok && depthAfter(end) == 0
    % Functions closed with end: each block runs to the line where depth returns to its start level.
    for f = funStarts
        if f > 1
            startDepth = depthAfter(f-1);
        else
            startDepth = 0;
        end
        if startDepth ~= 0 || inFun(f)
            continue
        end
        e = find(depthAfter(f:end) == 0, 1) + f - 1;
        if isempty(e)
            return
        end
        blocks{end+1} = strjoin(lines(f:e), char(10)); %#ok<AGROW>
        inFun(f:e) = true;
    end
else
    % Functions without end: a function runs until the next top-level function or the end.
    [d2, ok2] = local_blockDepth(stripped, false);
    if ~ok2
        return
    end
    for i = 1:numel(funStarts)
        f = funStarts(i);
        if f > 1 && d2(f-1) ~= 0
            continue
        end
        if i < numel(funStarts)
            e = funStarts(i+1) - 1;
        else
            e = numel(lines);
        end
        body = lines(f:e);
        bodyStripped = stripped(f:e);
        dd = local_blockDepth(bodyStripped, false);
        if ~isempty(dd) && dd(end) < 0
            % The function already has a closing end.
            blocks{end+1} = strjoin(body, char(10)); %#ok<AGROW>
        else
            while ~isempty(body) && isempty(strtrim(body{end}))
                body(end) = [];
            end
            blocks{end+1} = [strjoin(body, char(10)) char(10) 'end']; %#ok<AGROW>
        end
        inFun(f:e) = true;
    end
end
script = lines(~inFun);
while ~isempty(script) && isempty(strtrim(script{end}))
    script(end) = [];
end
code = strtrim([strjoin(script, char(10)) char(10) char(10) strjoin(blocks, [char(10) char(10)])]);
end

function [depthAfter, ok] = local_blockDepth(stripped, functionOpens)
% Block nesting depth after each line (strings and comments already blanked).
n = numel(stripped);
depthAfter = zeros(1, n);
d = 0;
br = 0;
ok = true;
openers = {'if', 'for', 'parfor', 'while', 'switch', 'try', 'spmd'};
if functionOpens
    openers{end+1} = 'function';
end
for i = 1:n
    s = stripped{i};
    [words, pos] = regexp(s, '(?<![\w.])[A-Za-z_]\w*', 'match', 'start');
    k = 1;
    wi = 1;
    for c = 1:numel(s)
        ch = s(c);
        while wi <= numel(pos) && pos(wi) == c
            w = words{wi};
            if br == 0
                if any(strcmp(w, openers))
                    d = d + 1;
                elseif strcmp(w, 'end')
                    d = d - 1;
                end
            end
            wi = wi + 1;
        end
        if any(ch == '([{')
            br = br + 1;
        elseif any(ch == ')]}')
            br = max(0, br - 1);
        end
        k = k + 1; %#ok<NASGU>
    end
    if br > 0 && isempty(regexp(s, '(\.\.\.|[\[{,;]\s*)$', 'once')) && isempty(regexp(s, '\[', 'once'))
        % Unclosed ( on a line without continuation: stop carrying it.
        br = 0;
    end
    if d < 0
        ok = false;
    end
    depthAfter(i) = d;
end
end

function [script, names] = local_splitScript(code)
lines = regexp(code, '\n', 'split');
stripped = regexp(local_stripCode(code), '\n', 'split');
names = {};
script = code;
if numel(stripped) ~= numel(lines)
    return
end
f = find(~cellfun(@isempty, regexp(stripped, '^\s*function\>', 'once')), 1);
if isempty(f)
    return
end
script = strjoin(lines(1:f-1), char(10));
for k = f:numel(stripped)
    t = regexp(stripped{k}, '^\s*function\s+(?:\[[^\]]*\]\s*=\s*|\w+\s*=\s*)?([A-Za-z]\w*)', 'tokens', 'once');
    if ~isempty(t)
        names{end+1} = t{1}; %#ok<AGROW>
    end
end
end

function problem = local_precheck(code, kb)
problem = '';
if isempty(strtrim(code))
    problem = 'Your reply did not contain MATLAB code in a ```matlab block.';
    return
end
c = local_stripCode(code);
if isempty(regexp(c, '\S', 'once'))
    problem = 'Your reply contained only comments; write the MATLAB code.';
    return
end
if ~isempty(regexp(c, '(?<![\w.])(input|keyboard|inputdlg|questdlg|listdlg|uigetfile|uiputfile|ginput|waitforbuttonpress|uiwait)\s*\(|(?<![\w.])keyboard(?![\w(])', 'once'))
    problem = 'The script must not wait for the user (no input, keyboard, dialogs): hard-code the values from the problem.';
    return
end
if ~isempty(regexp(c, '(?<![\w.])(system|dos|unix|winopen|web|exit|quit|rmdir|movefile|copyfile|recycle|restoredefaultpath|rmpath)\s*[\(;,\n]|(?m)^\s*!', 'once')) ...
        || ~isempty(regexp(c, '(?<![\w.])delete\s*\(\s*[''"*]|(?<![\w.])delete\s+[\w*]', 'once')) ...
        || ~isempty(regexp(c, '(?<![\w.])(exit|quit)(?![\w(])', 'once'))
    problem = 'The script must not run system commands, delete/move files or quit MATLAB. Only compute, print and plot.';
    return
end
if ~isempty(regexp(c, '(?<![\w.])ru\s*(\(|\s+\w)', 'once'))
    problem = 'Do not call ru from the script.';
    return
end
if ~isempty(regexp(c, '(?<![\w.])cd(\s+\S|\s*\()', 'once'))
    problem = 'Do not change the current folder (no cd).';
    return
end
if ~isempty(regexp(c, '(?<![\w.])while\s*\(?\s*(true|1)\s*\)?\s*(\n|,|;|$)', 'once')) && isempty(regexp(c, '(?<![\w.])(break|return|error)(?![\w])', 'once'))
    problem = 'The while loop never stops: add an iteration limit and a break.';
    return
end
if ~isempty(regexp(c, '(?<![\w.])e\s*\.?\^', 'once')) && isempty(regexp(c, '(?<![\w.])e\s*=[^=]', 'once'))
    problem = 'MATLAB has no constant e: write exp(x) instead of e^x (and exp(1) for e).';
    return
end
bad = local_unknownFunctions(code, kb);
if ~isempty(bad)
    problem = sprintf(['These are not functions available on this computer (not installed, not defined in the script, ' ...
        'or they do not exist in MATLAB): %s. Use base MATLAB or the ru_lib functions instead, or define them as ' ...
        'local functions at the end of the script.'], strjoin(bad, ', '));
end
end

function bad = local_unknownFunctions(code, kb)
% Names called like functions that are neither defined in the script nor on the path.
bad = {};
c = local_stripCode(code);
known = local_definedNames(c);
try
    W = evalin('base', 'who');
    known = [known; W(:)];
catch
end
known = [known; {kb.lib.name}'];
tok = regexp(c, '(?<![\w.@''"])([A-Za-z]\w*)\s*\(', 'tokens');
cmdTok = regexp(c, '(?m)^\s*([A-Za-z]\w*)(?=\s*(;|,|$|\s+[A-Za-z''-]))', 'tokens');
handles = regexp(c, '@\s*([A-Za-z]\w*)(?!\s*\()', 'tokens');
names = [cellfun(@(t) t{1}, tok, 'UniformOutput', false), cellfun(@(t) t{1}, cmdTok, 'UniformOutput', false), ...
    cellfun(@(t) t{1}, handles, 'UniformOutput', false)];
names = unique(names);
keywords = iskeyword();
for k = 1:numel(names)
    n = names{k};
    if any(strcmp(n, keywords)) || any(strcmp(n, known))
        continue
    end
    try
        e = exist(n); %#ok<EXIST>
    catch
        e = 1;
    end
    if e ~= 0
        continue
    end
    try
        if ~isempty(which(n))
            continue
        end
    catch
    end
    bad{end+1} = n; %#ok<AGROW>
end
end

function known = local_definedNames(c)
% Variables and functions the script itself defines (strings/comments removed).
known = {};
% name = ..., name(...) = ..., name{...} = ..., name.field = ...
t = regexp(c, '(?<![\w.])([A-Za-z]\w*)\s*(\([^=\n]*\)|\{[^=\n]*\}|\.[\w.]+)?\s*=(?!=)', 'tokens');
known = [known, cellfun(@(x) x{1}, t, 'UniformOutput', false)];
% [a, b, ~] = ...
t = regexp(c, '\[([^\]=\n]*)\]\s*=(?!=)', 'tokens');
for k = 1:numel(t)
    known = [known, regexp(t{k}{1}, '[A-Za-z]\w*', 'match')]; %#ok<AGROW>
end
% for k = ..., function outputs/inputs/names, anonymous function arguments, global/persistent, syms
t = regexp(c, '(?<![\w.])(?:for|parfor)\s*\(?\s*([A-Za-z]\w*)', 'tokens');
known = [known, cellfun(@(x) x{1}, t, 'UniformOutput', false)];
t = regexp(c, '(?m)^\s*function\s+([^\n]*)', 'tokens');
for k = 1:numel(t)
    known = [known, regexp(t{k}{1}, '[A-Za-z]\w*', 'match')]; %#ok<AGROW>
end
t = regexp(c, '@\s*\(([^)]*)\)', 'tokens');
for k = 1:numel(t)
    known = [known, regexp(t{k}{1}, '[A-Za-z]\w*', 'match')]; %#ok<AGROW>
end
t = regexp(c, '(?m)^\s*(?:global|persistent|syms)\s+([^\n;%]*)', 'tokens');
for k = 1:numel(t)
    known = [known, regexp(t{k}{1}, '[A-Za-z]\w*', 'match')]; %#ok<AGROW>
end
% load file.ext / load('file.ext') creates a variable named after the file
t = regexp(c, '(?<![\w.])load\s*\(?\s*[''"]?([A-Za-z]\w*)\.\w+', 'tokens');
known = [known, cellfun(@(x) x{1}, t, 'UniformOutput', false)];
known = unique(known(:));
end

function bad = local_unknownFunctionsInText(txt)
bad = {};
blocks = regexp(txt, '```[A-Za-z]*\s*\n(.*?)```', 'tokens');
inline = regexp(txt, '`([A-Za-z]\w*)\s*\(', 'tokens');
names = {};
for k = 1:numel(blocks)
    c = local_stripCode(blocks{k}{1});
    known = local_definedNames(c);
    t = regexp(c, '(?<![\w.@''"])([A-Za-z]\w*)\s*\(', 'tokens');
    for j = 1:numel(t)
        if ~any(strcmp(t{j}{1}, known))
            names{end+1} = t{j}{1}; %#ok<AGROW>
        end
    end
end
for k = 1:numel(inline)
    names{end+1} = inline{k}{1}; %#ok<AGROW>
end
names = unique(names);
kw = iskeyword();
for k = 1:numel(names)
    n = names{k};
    if numel(n) < 3 || any(strcmp(n, kw))
        continue
    end
    try
        if exist(n) == 0 && isempty(which(n)) %#ok<EXIST>
            bad{end+1} = n; %#ok<AGROW>
        end
    catch
    end
end
end

function s = local_stripCode(code)
% Replace comments and string literals by spaces (keeps line breaks and positions).
s = code;
n = numel(s);
i = 1;
inBlock = false;
lineStart = 1;
while i <= n
    ch = s(i);
    if ch == char(10)
        lineStart = i + 1;
        i = i + 1;
        continue
    end
    if inBlock
        e = find(s(i:end) == char(10), 1);
        if isempty(e)
            e = n - i + 2;
        end
        lineTxt = strtrim(code(i:i+e-2));
        s(i:i+e-2) = ' ';
        if strcmp(lineTxt, '%}')
            inBlock = false;
        end
        i = i + e - 1;
        continue
    end
    if ch == '%'
        e = find(s(i:end) == char(10), 1);
        if isempty(e)
            e = n - i + 2;
        end
        if i == lineStart + numel(regexp(code(lineStart:i-1), '^\s*', 'match', 'once')) && strcmp(strtrim(code(i:i+e-2)), '%{')
            inBlock = true;
        end
        s(i:i+e-2) = ' ';
        i = i + e - 1;
        continue
    end
    if ch == '.' && i + 2 <= n && strcmp(s(i:i+2), '...')
        e = find(s(i:end) == char(10), 1);
        if isempty(e)
            e = n - i + 2;
        end
        s(i+3:i+e-2) = ' ';
        i = i + e - 1;
        continue
    end
    if ch == '"' || (ch == '''' && ~local_isTranspose(s, i, lineStart))
        q = ch;
        j = i + 1;
        while j <= n && s(j) ~= char(10)
            if s(j) == q
                if j < n && s(j+1) == q
                    j = j + 2;
                    continue
                end
                break
            end
            j = j + 1;
        end
        if j <= n && s(j) == q
            s(i+1:j-1) = ' ';
            i = j + 1;
        else
            s(i+1:j-1) = ' ';
            i = j;
        end
        continue
    end
    i = i + 1;
end
end

function tf = local_isTranspose(s, i, lineStart)
tf = false;
if i <= lineStart
    return
end
p = s(i-1);
tf = isletter(p) || (p >= '0' && p <= '9') || any(p == ')]}_.''');
end

function s = local_stripStrings(code)
% Remove comments, but keep numbers inside strings out of the way too.
s = local_stripCode(code);
end

function [ok, info] = local_execute(root, code)
info = local_emptyInfo();
runDir = fullfile(local_brain(root), 'run');
if exist(runDir, 'dir') ~= 7
    mkdir(runDir);
end
if ~local_onPath(runDir)
    addpath(runDir, '-end');
end
old = dir(fullfile(runDir, 'ru_task_*.m'));
if numel(old) > 6
    [~, o] = sort([old.datenum]);
    for k = o(1:end-6)
        try
            delete(fullfile(runDir, old(k).name));
        catch
        end
    end
end
name = sprintf('ru_task_%s_%03d', datestr(now, 'yyyymmdd_HHMMSS'), randi(999));
file = fullfile(runDir, [name '.m']);
local_writeText(file, [code char(10)]);
try
    rehash;
catch
end
cmd = sprintf('ru__out__ = evalc(''try, %s; ru__err__ = []; catch ru__err__, end'');', name);
out = '';
err = [];
try
    evalin('base', cmd);
    out = evalin('base', 'ru__out__');
    err = evalin('base', 'ru__err__');
catch ME
    err = ME;
end
try
    evalin('base', 'clear ru__out__ ru__err__');
catch
end
if ~ischar(out)
    out = '';
end
fprintf('%s', out);
if ~isempty(out) && out(end) ~= char(10)
    fprintf('\n');
end
info.output = out;
if isempty(err)
    ok = true;
    return
end
ok = false;
info = local_errorInfo(err, file, name, code, out);
end

function info = local_errorInfo(ME, file, name, code, out)
info = local_emptyInfo();
info.output = out;
msg = ME.message;
msg = regexprep(msg, '<a href[^>]*>|</a>', '');
msg = strrep(msg, name, 'your script');
info.message = msg;
info.identifier = ME.identifier;
lines = regexp(code, '\n', 'split');
for k = 1:numel(ME.stack)
    S = ME.stack(k);
    if strcmpi(S.file, file) || strncmp(S.name, name, numel(name))
        info.line = S.line;
        break
    elseif isempty(info.where)
        info.where = sprintf('%s (line %d)', S.name, S.line);
    end
end
if info.line == 0
    t = regexp(ME.message, '[Ll]ine:?\s*(\d+)', 'tokens', 'once');
    if ~isempty(t)
        info.line = str2double(t{1});
    end
end
if info.line > 0 && info.line <= numel(lines)
    info.lineText = strtrim(lines{info.line});
end
end

function info = local_emptyInfo()
info = struct('message', '', 'identifier', '', 'line', 0, 'lineText', '', 'where', '', 'output', '');
end

function s = local_firstLine(s)
s = strtrim(s);
k = find(s == char(10), 1);
if ~isempty(k)
    s = strtrim(s(1:k-1));
end
end

% =====================================================================
% Text helpers
% =====================================================================

function s = local_ascii(s)
% Math symbols (from PDFs, Word, the web) -> MATLAB-friendly ASCII. Other
% letters (e.g. Bangla) are kept.
if isempty(s) || ~ischar(s)
    if ~ischar(s)
        s = '';
    end
    return
end
s = strrep(s, char(13), '');
if all(double(s) < 128)
    return
end
% Superscripts: 10^-5, x^2, ...
supFrom = [8304 185 178 179 8308:8313 8315 8314 8319 739 8317 8318];
supTo = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '-', '+', 'n', 'x', '(', ')'};
d = double(s);
isSup = ismember(d, supFrom);
if any(isSup)
    out = '';
    k = 1;
    while k <= numel(s)
        if isSup(k)
            j = k;
            while j <= numel(s) && isSup(j)
                j = j + 1;
            end
            run = '';
            for m = k:j-1
                run = [run supTo{supFrom == d(m)}]; %#ok<AGROW>
            end
            if numel(run) > 1
                out = [out '^(' run ')']; %#ok<AGROW>
            else
                out = [out '^' run]; %#ok<AGROW>
            end
            k = j;
        else
            out = [out s(k)]; %#ok<AGROW>
            k = k + 1;
        end
    end
    s = out;
end
map = {
    [8320:8329], {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9'}
    };
for k = 1:numel(map{1, 1})
    s = strrep(s, char(map{1, 1}(k)), map{1, 2}{k});
end
pairs = {
    160, ' '; 8201, ' '; 8202, ' '; 8203, ''; 8239, ' '; 65279, ''
    8216, ''''; 8217, ''''; 8242, ''''; 8243, ''''''; 8220, '"'; 8221, '"'
    8211, '-'; 8212, '-'; 8722, '-'; 8208, '-'; 8209, '-'
    215, '*'; 183, '*'; 8729, '*'; 8901, '*'; 247, '/'; 8260, '/'; 8725, '/'
    8804, '<='; 8805, '>='; 8800, '~='; 8776, '~'; 177, '+/-'; 8734, 'Inf'
    8730, 'sqrt'; 8747, 'integral '; 8721, 'sum '; 8706, 'd'; 8710, 'Delta'; 8711, 'grad'
    916, 'Delta'; 948, 'delta'; 960, 'pi'; 928, 'Pi'; 952, 'theta'; 977, 'theta'; 920, 'Theta'
    945, 'alpha'; 946, 'beta'; 947, 'gamma'; 915, 'Gamma'; 949, 'epsilon'; 1013, 'epsilon'
    950, 'zeta'; 951, 'eta'; 955, 'lambda'; 923, 'Lambda'; 181, 'mu'; 956, 'mu'; 957, 'nu'
    958, 'xi'; 961, 'rho'; 963, 'sigma'; 962, 'sigma'; 931, 'Sigma'; 964, 'tau'; 966, 'phi'
    981, 'phi'; 934, 'Phi'; 967, 'chi'; 968, 'psi'; 969, 'omega'; 937, 'Omega'; 8486, 'ohm'
    8451, ' degC'; 8457, ' degF'; 186, ' deg'; 189, '1/2'; 188, '1/4'; 190, '3/4'
    8230, '...'; 8594, '->'; 8592, '<-'; 8658, '=>'; 8596, '<->'; 8226, '-'; 9679, '-'
    8712, ' in '; 8745, ' and '; 8746, ' or '; 8704, 'for all '; 8707, 'exists '
    };
s = regexprep(s, [char(176) '\s*C(?![a-z])'], ' degC');
s = regexprep(s, [char(176) '\s*F(?![a-z])'], ' degF');
s = strrep(s, char(176), ' deg');
for k = 1:size(pairs, 1)
    s = strrep(s, char(pairs{k, 1}), pairs{k, 2});
end
end

function p = local_tidyPrompt(p)
p = strrep(p, char(13), '');
p = regexprep(p, '[ \t]+\n', char(10));
p = regexprep(p, '\n{3,}', sprintf('\n\n'));
p = strtrim(p);
p = regexprep(p, '^(ru\s+)+', '');
end

function t = local_now()
t = datestr(now, 'yyyy-mm-dd HH:MM:SS');
end

function local_log(root, txt)
try
    f = fullfile(local_brain(root), 'ru_log.txt');
    if local_fileBytes(f) > 5e6
        movefile(f, fullfile(local_brain(root), 'ru_log_old.txt'), 'f');
    end
    fid = fopen(f, 'a', 'n', 'UTF-8');
    if fid > 0
        fprintf(fid, '%s\n', txt);
        fclose(fid);
    end
catch
end
end

function txt = local_readText(f)
txt = '';
fid = fopen(f, 'r', 'n', 'UTF-8');
if fid < 0
    return
end
c = onCleanup(@() fclose(fid));
txt = fread(fid, [1 Inf], '*char');
if ~isempty(txt) && double(txt(1)) == 65279
    txt = txt(2:end);
end
end

function local_writeText(f, txt)
fid = fopen(f, 'w', 'n', 'UTF-8');
if fid < 0
    error('ru:write', 'Cannot write %s (is the pendrive write-protected or full?)', f);
end
fprintf(fid, '%s', txt);
fclose(fid);
end

function files = local_findFiles(root, pattern, skip)
% Recursive file search that skips the given folder names.
files = {};
d = dir(fullfile(root, pattern));
for k = 1:numel(d)
    if ~d(k).isdir
        files{end+1} = fullfile(root, d(k).name); %#ok<AGROW>
    end
end
sub = dir(root);
for k = 1:numel(sub)
    n = sub(k).name;
    if sub(k).isdir && ~any(strcmp(n, {'.', '..'})) && ~any(strcmpi(n, skip)) && n(1) ~= '.'
        files = [files, local_findFiles(fullfile(root, n), pattern, skip)]; %#ok<AGROW>
    end
end
end

function s = local_skipDirs()
s = {'ru_lib', 'ru_kb', 'ru_tests', 'brain', 'model', 'models', 'ollama', 'generated', 'Slides', 'private', ...
    'backup', '$RECYCLE.BIN', 'System Volume Information'};
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
if isempty(kb.lib)
    return
end
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
ctx.libFull = cand(1:min(8, numel(cand)));

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
    txt = local_ascii(local_readText(fullfile(tpDir, d(i).name)));
    if isempty(txt)
        continue
    end
    lines = regexp(txt, '\n', 'split');
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
    txt = local_ascii(local_readText(fullfile(libDir, d(i).name)));
    if isempty(txt)
        continue
    end
    lines = regexp(txt, '\n', 'split');
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
    txt = local_ascii(local_readText(f));
    if isempty(txt)
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
files = local_findFiles(root, '*.m', local_skipDirs());
dirs = {root};
if ~strcmpi(regexprep(pwd, '[\\/]+$', ''), regexprep(root, '[\\/]+$', ''))
    d = dir(fullfile(pwd, '*.m'));
    for k = 1:numel(d)
        files{end+1} = fullfile(pwd, d(k).name); %#ok<AGROW>
    end
    dirs{end+1} = pwd;
end
if isempty(files)
    return
end
dn = zeros(1, numel(files));
for k = 1:numel(files)
    di = dir(files{k});
    dn(k) = di(1).datenum;
end
key = sprintf('%s|%d|%.8f', strjoin(dirs, ';'), numel(files), max(dn));
if ~isempty(cache) && strcmp(cacheKey, key)
    U = cache;
    return
end
for i = 1:numel(files)
    [folder, name] = fileparts(files{i});
    if strcmpi(folder, root) && any(strcmpi(name, {'ru', 'startup', 'ru_selftest'}))
        continue
    end
    lines = regexp(strrep(local_readText(files{i}), char(13), ''), '\n', 'split');
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
        'signature', sig, 'datenum', dn(i)); %#ok<AGROW>
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

function [host, model, caps, maxCtx] = local_engine(root, forceStart, purpose)
persistent C
host = '';
model = '';
caps = {};
maxCtx = 8192;
if isempty(C)
    C = struct('text', [], 'vision', []);
end
key = 'model';
if strcmp(purpose, 'vision')
    key = 'vision';
end
want = local_setting(root, key, 'auto');
cached = C.(purpose);
if ~forceStart && ~isempty(cached)
    names = local_tags(cached.host, 3);
    if any(strcmp(names, cached.model)) && (strcmpi(want, 'auto') || local_sameModel(want, cached.model))
        host = cached.host;
        model = cached.model;
        caps = cached.caps;
        maxCtx = cached.maxCtx;
        return
    end
end
hosts = local_hosts(root);
[H, M] = local_findModels(hosts);
if (forceStart || isempty(M) || ~local_ping('http://127.0.0.1:11435')) && ~local_ping('http://127.0.0.1:11435') ...
        && (forceStart || isempty(M) || ~isempty(local_pendriveModels(root)))
    fprintf('[ru] Starting the AI engine (Ollama) of this pendrive on port 11435 ...\n');
    if local_startEngine(root)
        [H, M] = local_findModels(hosts);
    end
end
if isempty(M)
    fprintf(2, '[ru] No AI model is available.\n');
    local_engineHelp();
    return
end
infos = cell(1, numel(M));
for k = 1:numel(M)
    infos{k} = local_modelInfo(H{k}, M{k});
end
k = local_pickModel(M, infos, want, purpose);
if k == 0
    if strcmp(purpose, 'vision')
        return
    end
    k = 1;
end
host = H{k};
model = M{k};
caps = infos{k}.caps;
maxCtx = infos{k}.ctx;
C.(purpose) = struct('host', host, 'model', model, 'caps', {caps}, 'maxCtx', maxCtx);
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
        if isempty(regexp(lower(names{k}), 'embed|bge|minilm|nomic', 'once'))
            H{end+1} = hosts{i}; %#ok<AGROW>
            M{end+1} = names{k}; %#ok<AGROW>
        end
    end
end
end

function names = local_tags(host, timeout)
names = {};
r = local_getJSON([host '/api/tags'], timeout);
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

function r = local_getJSON(url, timeout)
r = [];
try
    if exist('OCTAVE_VERSION', 'builtin')
        raw = local_curl(url, '', timeout);
    else
        raw = webread(url, weboptions('Timeout', timeout, 'ContentType', 'text'));
    end
    if ~ischar(raw)
        raw = char(raw);
    end
    r = jsondecode(raw);
catch
end
end

function r = local_postJSON(url, body, timeout)
if exist('OCTAVE_VERSION', 'builtin')
    raw = local_curl(url, jsonencode(body), timeout);
else
    raw = webwrite(url, jsonencode(body), weboptions('MediaType', 'application/json', 'ContentType', 'text', ...
        'Timeout', timeout, 'CharacterEncoding', 'UTF-8'));
end
if ~ischar(raw)
    raw = char(raw);
end
r = jsondecode(raw);
end

function raw = local_curl(url, json, timeout)
% GNU Octave has no JSON web client; use curl there (MATLAB uses webread/webwrite).
out = [tempname '.json'];
if isempty(json)
    cmd = sprintf('curl -s -S --max-time %d -o "%s" "%s" 2>&1', ceil(timeout), out, url);
else
    in = [tempname '.json'];
    local_writeText(in, json);
    cmd = sprintf('curl -s -S --max-time %d -H "Content-Type: application/json" --data-binary "@%s" -o "%s" "%s" 2>&1', ...
        ceil(timeout), in, out, url);
end
[st, msg] = system(cmd);
raw = local_readText(out);
if exist(out, 'file') == 2
    delete(out);
end
if ~isempty(json) && exist(in, 'file') == 2
    delete(in);
end
if st ~= 0
    error('ru:curl', 'connection failed: %s', strtrim(msg));
end
end

function ok = local_ping(host)
ok = ~isempty(local_getJSON([host '/api/version'], 2));
end

function info = local_modelInfo(host, model)
% Capabilities (completion, vision, thinking, ...) and context length of a model.
persistent CACHE
if isempty(CACHE)
    CACHE = containers.Map('KeyType', 'char', 'ValueType', 'any');
end
key = [host '|' model];
if isKey(CACHE, key)
    info = CACHE(key);
    return
end
info = struct('caps', {{}}, 'ctx', 8192);
n = lower(model);
try
    r = local_postJSON([host '/api/show'], struct('model', model), 10);
    if isfield(r, 'capabilities')
        c = r.capabilities;
        if ischar(c)
            c = {c};
        end
        info.caps = c(:)';
    end
    if isfield(r, 'model_info') && isstruct(r.model_info)
        f = fieldnames(r.model_info);
        hit = f(~cellfun(@isempty, regexp(f, 'context_length$', 'once')));
        if ~isempty(hit)
            v = r.model_info.(hit{1});
            if isnumeric(v) && v > 0
                info.ctx = double(v);
            end
        end
    end
catch
end
if isempty(info.caps)
    info.caps = {'completion'};
    if ~isempty(regexp(n, 'qwen3\.5|qwen3-vl|qwen2\.5vl|llava|gemma3|minicpm-v|vision|moondream|granite3\.2-vision|mistral-small3', 'once'))
        info.caps{end+1} = 'vision';
    end
    if ~isempty(regexp(n, 'qwen3|deepseek-r1|qwq|gpt-oss|magistral', 'once'))
        info.caps{end+1} = 'thinking';
    end
end
CACHE(key) = info;
end

function k = local_pickModel(M, infos, want, purpose)
k = 0;
needVision = strcmp(purpose, 'vision');
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
    hasVision = any(strcmp(infos{i}.caps, 'vision'));
    if needVision && ~hasVision
        continue
    end
    s = local_modelScore(M{i}, purpose);
    if s > best
        best = s;
        k = i;
    end
end
end

function tf = local_sameModel(a, b)
tf = strcmpi(regexprep(a, ':latest$', ''), regexprep(b, ':latest$', ''));
end

function s = local_modelScore(name, purpose)
n = lower(name);
if strcmp(purpose, 'vision')
    pats = {'qwen3\.5', 400; 'qwen3-vl', 380; 'qwen2\.5vl', 350; 'gemma3', 300; 'minicpm-v', 280; ...
        'llama3\.2-vision', 260; 'mistral-small3', 250; 'granite3\.2-vision', 220; 'llava', 200};
else
    pats = {'qwen3\.5', 330; 'qwen2\.5-coder', 300; 'qwen3-coder', 290; 'qwen3', 270; 'ru_engine', 250; ...
        'deepseek-coder', 220; 'codellama|codegemma|starcoder|coder', 200; 'qwen', 150; ...
        'llama|mistral|gemma|phi|granite', 100};
end
s = 50;
for i = 1:size(pats, 1)
    if ~isempty(regexp(n, pats{i, 1}, 'once'))
        s = pats{i, 2};
        break
    end
end
tok = regexp(n, '(\d+(?:\.\d+)?)b(?![a-z])', 'tokens', 'once');
if isempty(tok)
    s = s + 10;
else
    b = str2double(tok{1});
    if b >= 6 && b <= 16
        s = s + 40;
    elseif b >= 3.5 && b < 6
        s = s + 30;
    elseif b >= 2.5 && b < 3.5
        s = s + 20;
    elseif b > 16
        s = s - 60;
    elseif b < 1.5
        s = s - 60;
    end
end
end

function d = local_modelsDir(root)
d = '';
cand = {fullfile(root, 'model'), fullfile(root, 'models')};
custom = local_setting(root, 'modelsdir', '');
if ~isempty(custom)
    cand = [{custom}, cand];
end
for k = 1:numel(cand)
    if exist(fullfile(cand{k}, 'manifests'), 'dir') == 7
        d = cand{k};
        return
    end
end
end

function P = local_pendriveModels(root)
% Models whose manifest is on the pendrive, and whether all their files are present.
P = struct('name', {}, 'complete', {}, 'missing', {}, 'bytes', {});
md = local_modelsDir(root);
if isempty(md)
    return
end
manDir = fullfile(md, 'manifests');
files = local_findFiles(manDir, '*', {});
for k = 1:numel(files)
    rel = files{k}(numel(manDir)+2:end);
    parts = regexp(rel, '[\\/]', 'split');
    if numel(parts) < 3
        continue
    end
    name = [parts{end-1} ':' parts{end}];
    if ~strcmp(parts{end-2}, 'library')
        name = [parts{end-2} '/' name];
    end
    e = struct('name', name, 'complete', true, 'missing', {{}}, 'bytes', 0);
    try
        man = jsondecode(local_readText(files{k}));
        layers = man.layers;
        if isstruct(layers)
            layers = num2cell(layers);
        end
        for j = 1:numel(layers)
            L = layers{j};
            blob = fullfile(md, 'blobs', strrep(L.digest, ':', '-'));
            e.bytes = e.bytes + double(L.size);
            if local_fileBytes(blob) ~= double(L.size)
                e.complete = false;
                e.missing{end+1} = sprintf('%s (%.2f GB)', strrep(L.digest, ':', '-'), double(L.size)/1e9);
            end
        end
    catch
        e.complete = false;
        e.missing{end+1} = 'unreadable manifest';
    end
    P(end+1) = e; %#ok<AGROW>
end
end

function ok = local_startEngine(root)
ok = false;
exe = local_findOllama(root);
if isempty(exe)
    fprintf(2, '[ru] Ollama is not installed on this PC and there is no ollama folder in %s.\n', root);
    return
end
names = {'OLLAMA_MODELS', 'OLLAMA_HOST', 'OLLAMA_NOPRUNE', 'OLLAMA_KEEP_ALIVE', ...
    'OLLAMA_MAX_LOADED_MODELS', 'OLLAMA_NUM_PARALLEL'};
old = cellfun(@getenv, names, 'UniformOutput', false);
md = local_modelsDir(root);
if ~isempty(md)
    setenv('OLLAMA_MODELS', md);
end
setenv('OLLAMA_HOST', '127.0.0.1:11435');
setenv('OLLAMA_NOPRUNE', '1');
setenv('OLLAMA_KEEP_ALIVE', '30m');
setenv('OLLAMA_MAX_LOADED_MODELS', '1');
setenv('OLLAMA_NUM_PARALLEL', '1');
try
    if ispc
        system(sprintf('start "ru engine - keep this window open" /min "%s" serve', exe));
    else
        system(sprintf('"%s" serve > /dev/null 2>&1 &', exe));
    end
catch err
    fprintf(2, '[ru] Could not start %s: %s\n', exe, err.message);
end
for k = 1:numel(names)
    setenv(names{k}, old{k});
end
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

function local_stopEngine(root) %#ok<INUSD>
if ~local_ping('http://127.0.0.1:11435')
    fprintf('[ru] The pendrive engine (port 11435) is not running.\n');
    return
end
if ispc
    cmd = ['powershell -NoProfile -Command "Get-NetTCPConnection -LocalPort 11435 -State Listen ' ...
        '-ErrorAction SilentlyContinue | ForEach-Object { Stop-Process -Id $_.OwningProcess -Force }"'];
else
    cmd = 'fuser -k 11435/tcp > /dev/null 2>&1 || (lsof -ti tcp:11435 | xargs kill) > /dev/null 2>&1';
end
system(cmd);
pause(1);
if local_ping('http://127.0.0.1:11435')
    fprintf(2, '[ru] Could not stop it; close the "ru engine" window instead.\n');
else
    fprintf('[ru] Engine stopped (memory freed). It starts again automatically when needed.\n');
end
end

function exe = local_findOllama(root)
exe = '';
c = {fullfile(root, 'ollama', 'ollama.exe'), fullfile(root, 'ollama', 'ollama'), ...
    fullfile(root, 'ollama', 'bin', 'ollama'), ...
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
    '[ru]   1. Put Ollama on the pendrive: run setup_ru.bat once on a PC with internet (it downloads the\n' ...
    '[ru]      portable Ollama into the "ollama" folder and the models into the "model" folder).\n' ...
    '[ru]      Or install Ollama from https://ollama.com on this PC.\n' ...
    '[ru]   2. Run  ru start  (or double-click start_ru.bat) and keep the engine window open.\n' ...
    '[ru]   3. Check everything with  ru status\n']);
end

function [txt, cut, err] = local_chat(host, model, msgs, temperature, numCtx, numPredict, think, caps)
txt = '';
cut = false;
err = '';
body = struct('model', model, 'stream', false, 'keep_alive', '30m');
body.messages = msgs;
body.options = struct('temperature', temperature, 'num_ctx', numCtx, 'num_predict', numPredict, ...
    'top_p', 0.9, 'top_k', 40, 'seed', 42);
if any(strcmp(caps, 'thinking'))
    body.think = logical(think);
end
timeout = 900;
if think
    timeout = 2400;
end
r = [];
for tries = 1:2
    try
        r = local_postJSON([host '/api/chat'], body, timeout);
        err = '';
        break
    catch ME
        err = ME.message;
        if ~isempty(regexpi(err, 'think', 'once')) && isfield(body, 'think')
            body = rmfield(body, 'think');
            continue
        end
        if isempty(regexpi(err, 'reset|closed|refused|connect', 'once'))
            break
        end
        pause(2);
    end
end
if ~isempty(err)
    if ~isempty(strfind(err, '404'))
        err = sprintf('the model "%s" was not found on %s. Run: ru status', model, host);
    elseif ~isempty(regexpi(err, 'timed? ?out|did not respond|timeout', 'once'))
        err = ['the engine did not answer in time. This PC may be slow for this model; ' ...
            'close other programs and try again, or choose a smaller model (ru model ...).'];
    elseif ~isempty(regexpi(err, 'memory|500', 'once'))
        err = [err ' (maybe not enough RAM for this model: close programs or choose a smaller model with ru model ...)'];
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
fprintf('Knowledge base  : %d topics, %d verified solved examples (ru_kb)\n', numel(kb.topics), numel(kb.examples));
fprintf('Your M-files    : %d\n', numel(kb.userFiles));
fprintf('Conversation    : %d turns remembered (ru history / ru new)\n', numel(local_convLoad(root)));
try
    [~, sys] = memory;
    ram = sys.PhysicalMemory.Total / 2^30;
    fprintf('RAM             : %.1f GB (%.1f GB free)', ram, sys.PhysicalMemory.Available / 2^30);
    if ram < 7.5
        fprintf(' - small: prefer qwen2.5-coder:3b or qwen3.5:2b');
    end
    fprintf('\n');
catch
end
exe = local_findOllama(root);
if isempty(exe)
    fprintf(2, 'Ollama program  : NOT FOUND (run setup_ru.bat on a PC with internet)\n');
else
    fprintf('Ollama program  : %s\n', exe);
end
md = local_modelsDir(root);
if isempty(md)
    fprintf(2, 'Models folder   : NOT FOUND (expected %s)\n', fullfile(root, 'model'));
else
    fprintf('Models folder   : %s\n', md);
end
P = local_pendriveModels(root);
for k = 1:numel(P)
    if P(k).complete
        fprintf('  model %-24s OK (%.1f GB)\n', P(k).name, P(k).bytes / 1e9);
    else
        fprintf(2, '  model %-24s INCOMPLETE - missing file(s): %s\n', P(k).name, strjoin(P(k).missing, ', '));
    end
end
hosts = local_hosts(root);
for k = 1:numel(hosts)
    if local_ping(hosts{k})
        names = local_tags(hosts{k}, 3);
        if isempty(names)
            names = {'(no models)'};
        end
        fprintf('Engine %-24s: running, models: %s\n', hosts{k}, strjoin(names, ', '));
    else
        fprintf('Engine %-24s: not running\n', hosts{k});
    end
end
fprintf('Model setting   : text %s, vision %s\n', local_setting(root, 'model', 'auto'), local_setting(root, 'vision', 'auto'));
[H, M] = local_findModels(hosts);
if isempty(M)
    fprintf(2, 'ru will use     : nothing yet - run  ru start\n');
else
    infos = cell(1, numel(M));
    for k = 1:numel(M)
        infos{k} = local_modelInfo(H{k}, M{k});
    end
    k = local_pickModel(M, infos, local_setting(root, 'model', 'auto'), 'text');
    if k == 0
        k = 1;
    end
    fprintf('Text model      : %s at %s (context %d, %s)\n', M{k}, H{k}, infos{k}.ctx, strjoin(infos{k}.caps, ', '));
    k = local_pickModel(M, infos, local_setting(root, 'vision', 'auto'), 'vision');
    if k == 0
        fprintf('Image model     : none (ru img needs e.g. qwen3.5:4b)\n');
    else
        fprintf('Image model     : %s\n', M{k});
    end
end
fprintf('\n');
end

function local_settingCommand(root, key, value)
settingKey = key;
if strcmp(key, 'host')
    settingKey = 'host';
end
if isempty(strtrim(value))
    fprintf('[ru] %s setting: %s\n', key, local_setting(root, settingKey, 'auto'));
    [~, M] = local_findModels(local_hosts(root));
    if isempty(M)
        fprintf('[ru] No engine is running. Start it with: ru start\n');
    else
        fprintf('[ru] Installed models: %s\n', strjoin(unique(M), ', '));
    end
    return
end
local_setSetting(root, settingKey, strtrim(value));
fprintf('[ru] %s set to %s\n', key, strtrim(value));
end

function v = local_setting(root, key, default)
v = default;
f = fullfile(root, 'brain', 'settings.txt');
if exist(f, 'file') ~= 2
    return
end
lines = regexp(local_readText(f), '[^\r\n]+', 'match');
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
    lines = regexp(local_readText(f), '[^\r\n]+', 'match');
    lines = lines(cellfun(@isempty, regexp(lines, ['^\s*' key '\s*='], 'once')));
end
lines{end+1} = sprintf('%s = %s', key, value);
local_writeText(f, [strjoin(lines, char(10)) char(10)]);
end

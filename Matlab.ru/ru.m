function varargout = ru(varargin)
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
%   ru status             this PC (processor, memory, graphics), AI engine, models, speed
%   ru start | ru stop    start / stop the AI engine (Ollama) of this pendrive
%   ru model [name|auto]  choose the model for THIS PC, e.g. ru model qwen3.5:9b (or ru model 9b);
%                         auto (default) = the best small model that fits; ru vision: for ru img
%   ru gpu [auto|on|off]  graphics card use (auto: dedicated cards yes, integrated no)
%   ru verbose [on|off]   off (default): only the code and MATLAB's output are shown
%   ru prep               free memory: close your browsers, chat and music programs
%                         (runs ru_prep.bat; asks nothing, keeps the ru engine)
%   ru list | ru test | ru help
%
%   ru adapts to each PC by itself: it measures the free memory, uses the strongest
%   model that fits, puts the model on the graphics card and the processor together
%   when there is a usable card, and falls back to the processor when a graphics
%   driver fails.
%
%   Long problems, or text with quotes, commas or several lines: type just  ru
%   and paste the text into the box, or call  ru('...')  with the text in quotes.
%   ru remembers the conversation, so follow-ups work: "now use RK4 instead",
%   "plot it", "change h to 0.1", "why is the error so large?".

% The user's last error, captured before ru's own internal try/catch blocks can overwrite it.
userLastErr = '';
try
    userLastErr = lasterr; %#ok<LERR>
catch
end
restoreErr = onCleanup(@() local_restoreLastErr(userLastErr));
local_userError(userLastErr);
root = fileparts(mfilename('fullpath'));
local_setup(root);
args = local_args(varargin);
if numel(args) == 1
    % ru('remember my ID is ...') behaves like the command form  ru remember my ID is ...
    tok = regexp(args{1}, '^\s*(\S+)\s+(.+)$', 'tokens', 'once');
    if ~isempty(tok) && any(strcmpi(tok{1}, {'remember', 'ask', 'explain', 'fix', 'again', 'retry', 'think', ...
            'ai', 'img', 'image', 'shot', 'screenshot', 'history', 'model', 'vision', 'host', 'save', '--retrieve'}))
        args = {tok{1}, tok{2}};
    end
end
opts = local_opts();
if isempty(args)
    % While the user pastes the problem, the model loads in the background.
    local_prepare(root);
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
    case '--retrieve'
        local_showRetrieval(root, rest);
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
            E = local_engine(root, true, 'text');
            local_busy('');
            if isempty(E.model)
                local_engineHelp();
            elseif local_isLoaded(E)
                fprintf('[ru] Engine ready: %s (%s), already in memory.\n', E.model, E.why);
            else
                local_warmup(root, E, local_systemStatic(root, local_env(), local_kb(root)));
                fprintf('[ru] Engine ready: %s (%s). It is loading into memory in the background.\n', E.model, E.why);
            end
            return
        end
    case 'stop'
        if alone
            local_stopEngine(root);
            return
        end
    case {'model', 'vision', 'host', 'verbose', 'gpu'}
        if numel(args) <= 2
            local_settingCommand(root, cmd, rest);
            return
        end
    case '--compact'
        % ru('--compact', code, problem): the code as ru shows and runs it (used by ru_selftest).
        if nargin >= 3
            varargout{1} = local_compactCode(varargin{2}, varargin{3});
            return
        end
    case 'list'
        if alone
            local_list(root);
            return
        end
    case {'prep', 'free', 'clean'}
        if alone
            local_prep(root);
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
            local_say(root, '[ru] Problem from the clipboard:\n%s\n', local_preview(prompt, 1200));
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

function e = local_userError(set)
% Remembers the user's last error message for "ru fix".
persistent E
if nargin == 1
    E = set;
end
if isempty(E)
    E = '';
end
e = E;
end

function local_restoreLastErr(msg)
try
    lasterr(msg); %#ok<LERR>
catch
end
end

function o = local_opts()
o = struct('forceAI', false, 'forceSolve', false, 'think', false, 'again', false, ...
    'label', '', 'extraContext', '', 'turnPrompt', '', 'keepAll', false);
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

function local_showRetrieval(root, prompt)
% Diagnostic: what ru would use for this prompt (no AI call).
prompt = local_tidyPrompt(local_ascii(prompt));
kb = local_kb(root);
ctx = local_retrieve(kb, prompt);
fprintf('[ru] question mode: %d, greeting: %d\n', local_isQuestion(prompt), local_isGreeting(prompt));
fprintf('[ru] topics: %s\n', strjoin(ctx.topics, ', '));
for k = ctx.examples
    fprintf('[ru] example: %s\n', kb.examples(k).title);
end
fprintf('[ru] library help: %s\n', strjoin({kb.lib(ctx.libFull).name}, ', '));
if ctx.direct > 0
    fprintf('[ru] verified solution that would run directly: %s\n', kb.examples(ctx.direct).title);
else
    fprintf('[ru] no verified solution matches exactly; the AI would write the code\n');
end
msgs = local_buildSolveMessages(root, prompt, kb, local_env(), ctx, {}, false, local_opts(), 16384, 2048);
sys = numel(msgs{1}.content);
total = sum(cellfun(@(m) numel(m.content), msgs));
fprintf('[ru] prompt: %d characters (~%d tokens), of which the fixed system part is %d characters\n', ...
    total, round(total / 3.2), sys);
end

function local_prep(root)
% Close the user's own heavy programs (browsers, chat, music, game launchers) to free memory.
bat = fullfile(root, 'ru_prep.bat');
if ~ispc || exist(bat, 'file') ~= 2
    fprintf(2, '[ru] ru prep needs Windows and %s\n', bat);
    return
end
fprintf('[ru] Closing your browsers, chat and music programs to free memory ...\n');
[st, out] = system(['"' bat '" /y /keep']);
fprintf('%s\n', strtrim(out));
if st ~= 0 && isempty(strtrim(out))
    fprintf(2, '[ru] This PC did not let ru_prep.bat run (lab policy).\n');
end
end

function local_prepare(root)
% Before the paste box opens: start the engine and load the model in the background, so the
% model is (partly) in memory by the time the problem has been pasted.
if ~local_desktop()
    return
end
try
    E = local_engine(root, false, 'text');
    local_busy('');
    if ~isempty(E.model)
        local_warmup(root, E, local_systemStatic(root, local_env(), local_kb(root)));
    end
catch
    local_busy('');
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
verbose = local_verbose(root);
local_log(root, sprintf('\n==== %s ====\nMODE: solve%s\nPROMPT:\n%s', local_now(), opts.label, prompt));
kb = local_kb(root);
env = local_env();
conv = local_convLoad(root);
follow = local_isFollowUp(prompt, conv);
if follow
    ctx = local_retrieve(kb, [conv{end}.prompt char(10) prompt]);
    ctx.direct = 0;
else
    ctx = local_retrieve(kb, prompt);
end
turnPrompt = prompt;
if ~isempty(opts.turnPrompt)
    turnPrompt = opts.turnPrompt;
end
% What the problem asks to see decides what stays in the code (plots, check prints).
shape = prompt;
if follow
    shape = [conv{end}.prompt char(10) prompt];
end
if opts.keepAll
    shape = [shape ' plot check'];
end

% 1) A stored, verified solution of exactly this problem: run it directly.
if ~opts.forceAI && ~follow && ctx.direct > 0
    ex = kb.examples(ctx.direct);
    local_say(root, '[ru] Verified solved example "%s" (%s). For AI-written code instead: ru again\n', ex.title, ex.source);
    [okRun, info, code] = local_runCode(root, kb, local_compactCode(ex.code, shape), 'verified solution', verbose);
    if okRun
        local_finish(root, turnPrompt, code, info.output, t0, 'verified solution', {});
        ok = true;
        return
    end
    local_say(root, '[ru] The stored solution failed here (%s). Asking the AI instead.\n', local_firstLine(info.message));
end

% 2) Ask the local model, run its code, check it, feed problems back until it is right.
E = local_engine(root, false, 'text');
if isempty(E.model)
    local_offline(root, kb, ctx);
    local_convAdd(root, 'solve', turnPrompt, '', 'The AI engine was not available.', false);
    return
end
think = opts.think && any(strcmp(E.caps, 'thinking'));
if opts.think && ~think
    local_say(root, '[ru] %s has no thinking mode; solving normally.\n', E.model);
end
numPredict = 2048;
numCtx = E.ctx;
if think
    numCtx = local_thinkCtx(root, E);
    numPredict = min(12000, floor(numCtx / 2));
end
baseMsgs = local_buildSolveMessages(root, prompt, kb, env, ctx, conv, follow, opts, numCtx, numPredict);
ctxNoEx = ctx;
ctxNoEx.examples = zeros(1, 0);
baseNoEx = local_buildSolveMessages(root, prompt, kb, env, ctxNoEx, conv, follow, opts, numCtx, numPredict);
if ~isempty(ctx.topics)
    local_say(root, '[ru] Topic: %s', strjoin(ctx.topics, ', '));
    if ~isempty(ctx.examples)
        local_say(root, ' | closest solved example: %s', kb.examples(ctx.examples(1)).title);
    end
    local_say(root, '\n');
end
if follow
    local_say(root, '[ru] Follow-up: using the previous problem and its code from the conversation memory.\n');
end

temps = [0.1 0.3 0.5 0.7];
if opts.again
    temps = [0.6 0.7 0.8 0.9];
end
maxAttempts = numel(temps);
msgs = baseMsgs;
prevCode = '';
lastError = '';
lastIssue = '';
best = struct('code', '', 'output', '', 'warnings', {{}});
askedNumbers = false;
requirements = '';
loaded = local_isLoaded(E);
for attempt = 1:maxAttempts
    if attempt == 1 && ~loaded
        local_busy(sprintf('ru: loading %s into memory (first use), then writing code ...', E.model));
    elseif attempt == 1
        local_busy(sprintf('ru: writing code (%s) ...', E.model));
    else
        local_busy(sprintf('ru: correcting it (attempt %d of %d) ...', attempt, maxAttempts));
    end
    local_say(root, '[ru] Asking %s (attempt %d of %d)...\n', E.model, attempt, maxAttempts);
    [reply, cut, err, E] = local_llm(root, E, msgs, temps(attempt), numPredict, think, numCtx);
    if ~isempty(err)
        local_log(root, ['ENGINE ERROR: ' err]);
        if isempty(best.code)
            local_err('[ru] AI engine error: %s\n', err);
            local_convAdd(root, 'solve', turnPrompt, prevCode, ['FAILED: engine error: ' err], false);
            return
        end
        break
    end
    local_busy('ru: running and checking it ...');
    code = local_compactCode(local_arrange(local_sanitize(local_extractCode(reply))), shape);
    problem = local_precheck(code, kb);
    figs = local_figures();
    if isempty(problem)
        [okRun, info, code] = local_runCode(root, kb, code, sprintf('AI attempt %d', attempt), verbose);
        if okRun
            [feedback, warnings] = local_quality(info, prompt, code, attempt, maxAttempts, askedNumbers, ctx.topics);
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
            local_say(root, '[ru] The script ran, but: %s\n', local_firstLine(feedback));
            local_log(root, sprintf('ATTEMPT %d RAN WITH ISSUES:\n%s\nISSUE: %s', attempt, code, feedback));
            lastIssue = local_firstLine(feedback);
            local_closeNewFigures(figs);
            if ~isempty(strfind(feedback, 'but your script does not use it'))
                % Small models copy their previous reply; restart from the problem with the requirement up front.
                requirements = [requirements char(10) '- ' regexprep(feedback, '\s*and rewrite the complete script\.$', '.')]; %#ok<AGROW>
                msgs = local_withRequirements(baseMsgs, requirements);
                prevCode = code;
                continue
            end
        else
            local_closeNewFigures(figs);
            if verbose
                local_err('\n[ru] MATLAB error: %s\n', strtrim(info.message));
                if ~isempty(info.lineText)
                    local_err('[ru] at line %d: %s\n', info.line, info.lineText);
                end
            end
            feedback = local_feedback(info, kb, code, cut, attempt == maxAttempts - 1);
            local_log(root, sprintf('ATTEMPT %d CODE:\n%s\nERROR: %s', attempt, code, info.message));
            lastIssue = local_firstLine(info.message);
            if strcmp(info.message, lastError) && attempt < maxAttempts
                % Stuck on the same error (usually a structure copied from an example):
                % start again without the examples and with the lesson as a requirement.
                requirements = [requirements char(10) '- An earlier attempt failed with "' local_firstLine(info.message) ...
                    '" at: ' info.lineText '. Do not copy sizes or structures from other problems; use exactly ' ...
                    'the data of THIS problem (count its values).']; %#ok<AGROW>
                msgs = local_withRequirements(baseNoEx, requirements);
                prevCode = code;
                lastError = info.message;
                local_say(root, '[ru] Same error again: starting over with a clean prompt...\n');
                continue
            end
            lastError = info.message;
        end
    else
        local_say(root, '[ru] Rejected the generated code: %s\n', local_firstLine(problem));
        feedback = [problem sprintf('\n\nRewrite the COMPLETE script in one ```matlab block.')];
        local_log(root, sprintf('ATTEMPT %d REJECTED:\n%s\nREASON: %s', attempt, code, problem));
        lastIssue = local_firstLine(problem);
    end
    if ~isempty(code) && strcmp(code, prevCode)
        feedback = [feedback sprintf('\nYou returned the same code as before. Use a different, simpler approach.')]; %#ok<AGROW>
    end
    prevCode = code;
    shown = code;
    if isempty(shown)
        shown = strtrim(reply);
    end
    msgs = [local_withRequirements(baseMsgs, requirements), {local_msg('assistant', ['```matlab' char(10) shown char(10) '```']), ...
        local_msg('user', feedback)}];
    if attempt < maxAttempts
        local_say(root, '[ru] Sending it back to the AI to fix it...\n');
    end
end
if ~isempty(best.code)
    local_say(root, '\n[ru] Using the best working script (it ran without errors; read the warnings below).\n');
    [okRun, info, code] = local_runCode(root, kb, best.code, 'best working script', verbose);
    if okRun
        local_finish(root, turnPrompt, code, info.output, t0, 'best working script', ...
            [best.warnings, {'Not every check passed; verify the result (ru again tries another approach).'}]);
        ok = true;
        return
    end
end
local_err('[ru] No working code after %d attempts. Last problem: %s\n', maxAttempts, lastIssue);
local_err('[ru] Try: ru again | ru think <problem> | name the method and give every number. Last code: ru last\n');
local_writeText(fullfile(local_brain(root), 'last_code.txt'), prevCode);
local_convAdd(root, 'solve', turnPrompt, prevCode, 'FAILED: no working code.', false);
local_log(root, 'RESULT: FAILED');
end

function numCtx = local_thinkCtx(root, E)
% Thinking needs room for a long answer: a 32k context when the memory allows it.
numCtx = E.ctx;
if E.maxCtx < 32768
    return
end
mem = local_memBudget(root, {E.host});
need = local_memNeed(E.model, E.bytes, 32768);
if ~local_isLocalHost(E.host) || isnan(mem.avail) || need <= mem.avail + local_memNeed(E.model, E.bytes, E.ctx)
    numCtx = 32768;
end
end

function tf = local_isLoaded(E)
tf = true;
if isempty(E.model) || ~local_isLocalHost(E.host)
    return
end
L = local_loaded(E.host);
tf = any(strcmp({L.name}, E.model));
end

function f = local_figures()
f = [];
try
    f = findall(0, 'Type', 'figure');
catch
end
end

function local_closeNewFigures(before)
% Figures drawn by an attempt that was not accepted are closed again.
try
    cur = findall(0, 'Type', 'figure');
    for k = 1:numel(cur)
        isOld = false;
        for j = 1:numel(before)
            if cur(k) == before(j)
                isOld = true;
                break
            end
        end
        if ~isOld
            delete(cur(k));
        end
    end
catch
end
end

function local_offline(root, kb, ctx)
% No AI engine on this PC: say why and show the closest verified solution as a template.
why = local_engineProblem();
if isempty(why)
    why = 'no AI model is available';
end
local_err('[ru] The AI cannot run here: %s.\n', why);
if ~isempty(ctx.examples)
    ex = kb.examples(ctx.examples(1));
    local_err('[ru] Closest verified solution ("%s"); change its numbers for your problem:\n', ex.title);
    fprintf('%s\n', local_compactCode(ex.code, ex.problem));
end
local_err('[ru] Details: ru status\n');
end

function msgs = local_withRequirements(msgs, requirements)
% Put extra requirements into the final problem message (before and after the problem text).
if isempty(strtrim(requirements))
    return
end
last = msgs{end};
req = ['REQUIREMENTS (must follow):' requirements];
last.content = [req char(10) char(10) last.content char(10) char(10) req];
msgs{end} = last;
end

function m = local_msg(role, content)
m = struct('role', role, 'content', content);
end

function [ok, info, code] = local_runCode(root, kb, code, label, show)
% Run a script in the base workspace. show = true (verbose) prints the code and output as it runs.
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
if show
    local_busy('');
    bar = repmat('-', 1, 64);
    fprintf('\n[ru] Code (%s):\n%s\n%s\n%s\n[ru] Output:\n', label, bar, code, bar);
end
[ok, info] = local_execute(root, code, show);
end

function local_finish(root, prompt, code, output, t0, how, warnings)
if local_verbose(root)
    local_busy('');
else
    local_show(root, code, output);
end
for k = 1:numel(warnings)
    local_err('[ru] Check: %s\n', warnings{k});
end
if local_verbose(root)
    fprintf(['\n[ru] Done (%s, %.0f s). Variables are in the workspace. ' ...
        'Code: ru last | save: ru save <name> | follow-up: ru <what next>\n'], how, toc(t0));
end
local_writeText(fullfile(local_brain(root), 'last_code.txt'), code);
local_convAdd(root, 'solve', prompt, code, output, true);
local_log(root, sprintf('RESULT: OK (%s, %.0f s)\nCODE:\n%s', how, toc(t0), code));
end

function [feedback, warnings] = local_quality(info, prompt, code, attempt, maxAttempts, askedNumbers, topics)
% Silent checks on a script that ran without errors. feedback non-empty = send it back to the AI;
% warnings are shown as one line each under the result.
if nargin < 7
    topics = {};
end
feedback = '';
warnings = {};
out = info.output;
hasPlot = ~isempty(regexp(local_stripCode(code), ['\<(plot|plot3|surf|surfc|mesh|meshc|contour|contourf|bar|barh|' ...
    'stem|stairs|scatter|histogram|hist|fplot|fsurf|fmesh|semilogx|semilogy|loglog|polar|polarplot|area|fill|' ...
    'quiver|errorbar|pie|plotmatrix|compass|feather|image|imagesc)\s*\('], 'once'));
if isempty(strtrim(out)) && ~hasPlot
    feedback = ['The script ran but showed nothing. Display every requested result: leave the semicolon off its ' ...
        'assignment or print it with fprintf (value and unit), and print the iteration table when iterations are asked for.'];
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
absent = local_missingMethods(prompt, code);
if ~isempty(absent) && attempt < maxAttempts
    feedback = sprintf(['The problem asks for %s, but your script does not use it. Solve it exactly with the requested ' ...
        'function/method (never replace it with a guessed or "known" value), and rewrite the complete script.'], ...
        strjoin(absent, ' and '));
    return
elseif ~isempty(absent)
    warnings{end+1} = sprintf('The problem asks for %s, but the code does not use it.', strjoin(absent, ' and '));
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
[fb, w] = local_resultChecks(prompt, topics, code);
if ~isempty(fb) && attempt < maxAttempts
    feedback = fb;
    return
elseif ~isempty(fb)
    warnings{end+1} = local_firstLine(regexprep(fb, '^Your solution ', 'The solution '));
end
warnings = [warnings, w];
end

function [feedback, warnings] = local_resultChecks(prompt, topics, code)
% Independent checks of the computed answer in the workspace (ru's own, not printed by the script):
% linear systems A*x = b, roots f(x) = 0, eigenpairs A*v = lambda*v. Only variables that this
% script itself defines are checked.
feedback = '';
warnings = {};
p = lower(prompt);
try
    W = evalin('base', 'whos');
catch
    return
end
defined = local_definedNames(local_stripCode(code));
W = W(ismember({W.name}, defined));
if isempty(W)
    return
end
names = {W.name};
iterative = ~isempty(regexp(p, 'seidel|jacobi|iterat|relaxation|sor\>', 'once'));
% Linear system
if any(strcmp(topics, 'linear')) && all(ismember({'A', 'b', 'x'}, names))
    try
        A = evalin('base', 'A');
        b = evalin('base', 'b');
        x = evalin('base', 'x');
        if isnumeric(A) && isnumeric(b) && isnumeric(x) && size(A, 1) == size(A, 2) && numel(b) == size(A, 1) ...
                && numel(x) == size(A, 1) && size(A, 1) > 1 && all(isfinite(x(:)))
            r = norm(A * x(:) - b(:)) / max(norm(b(:)), eps);
            if ~iterative && r > 1e-6
                feedback = sprintf(['Your solution x does not satisfy A*x = b (relative residual %.2g). Check the ' ...
                    'matrix, the right-hand side and the elimination/substitution steps.'], r);
            elseif iterative && r > 0.05
                warnings{end+1} = sprintf('x satisfies A*x = b only roughly (relative residual %.2g).', r);
            end
        end
    catch
    end
end
% Root of an equation
if any(strcmp(topics, 'roots')) && isempty(regexp(p, 'maxim|minim|optim|extrem|golden|stationary', 'once'))
    rv = names(~cellfun(@isempty, regexp(names, '^(root|xr|x_?root|xroot)\d*$', 'once')));
    fh = names(strcmp({W.class}, 'function_handle'));
    fh = fh(~cellfun(@isempty, regexp(fh, '^(f|fx|func|fun|y)\d*$', 'once')));
    for i = 1:numel(rv)
        try
            x = evalin('base', rv{i});
            if ~isnumeric(x) || ~isscalar(x) || ~isreal(x) || ~isfinite(x)
                continue
            end
            for j = 1:numel(fh)
                f = evalin('base', fh{j});
                if nargin(f) ~= 1
                    continue
                end
                fx = f(x);
                if ~isnumeric(fx) || ~isscalar(fx) || ~isfinite(fx) || abs(fx) < 1e-8
                    continue
                end
                xt = fzero(f, x);
                if isfinite(xt) && abs(xt - x) > 0.1 * max(1, abs(xt))
                    warnings{end+1} = sprintf(['%s = %.6g is not close to a root of %s (fzero from there finds %.6g); ' ...
                        'check the equation.'], rv{i}, x, fh{j}, xt); %#ok<AGROW>
                end
                break
            end
        catch
        end
    end
end
% Eigenvalue and eigenvector
if any(strcmp(topics, 'eigen')) && ismember('A', names)
    lam = names(~cellfun(@isempty, regexp(names, '^(lambda|lam|eigval|lmax|lambda_max)$', 'once')));
    vec = names(~cellfun(@isempty, regexp(names, '^(v|x|vec|eigvec|v1)$', 'once')));
    if ~isempty(lam) && ~isempty(vec)
        try
            A = evalin('base', 'A');
            l = evalin('base', lam{1});
            v = evalin('base', vec{1});
            if isnumeric(A) && size(A, 1) == size(A, 2) && isscalar(l) && numel(v) == size(A, 1) && norm(v) > 0
                r = norm(A * v(:) - l * v(:)) / max(norm(l * v(:)), eps);
                rInv = norm(A \ v(:) - l * v(:)) / max(norm(l * v(:)), eps);
                if r > 0.05 && rInv > 0.05
                    warnings{end+1} = sprintf('%s and %s are not an eigenpair of A (residual %.2g).', lam{1}, vec{1}, r);
                end
            end
        catch
        end
    end
end
% "Exact" solution of an ODE that the model wrote itself: it must satisfy the ODE.
if isempty(feedback) && any(strcmp(topics, 'ode'))
    feedback = local_checkExactOde(W, ~isempty(regexp(p, 'exact|analytic|true (solution|value)|closed.form', 'once')));
end
% fprintf(fmt, [t y]) prints the numbers in the wrong order (MATLAB reads a matrix column by column).
if isempty(feedback)
    feedback = local_checkFprintfMatrix(code);
end
end

function fb = local_checkExactOde(W, asked)
fb = '';
names = {W.name};
isFh = strcmp({W.class}, 'function_handle');
exactNames = names(isFh & ~cellfun(@isempty, regexpi(names, 'exact|true|anal|closed', 'once')));
odeNames = names(isFh & ~cellfun(@isempty, regexpi(names, '^(f|dydt|dy|fun|func|ode|rhs|g|dydx)\d*$', 'once')));
if isempty(exactNames) || isempty(odeNames)
    return
end
try
    t = evalin('base', 't');
    t = t(:)';
    if ~isnumeric(t) || numel(t) < 2 || ~all(isfinite(t))
        t = linspace(0, 1, 6);
    end
catch
    t = linspace(0, 1, 6);
end
pts = t(unique(round(linspace(1, numel(t), min(6, numel(t))))));
for i = 1:numel(exactNames)
    for j = 1:numel(odeNames)
        try
            ye = evalin('base', exactNames{i});
            f = evalin('base', odeNames{j});
            if nargin(ye) ~= 1 || nargin(f) ~= 2
                continue
            end
            bad = 0;
            for tk = pts
                h = 1e-5 * max(1, abs(tk));
                y = ye(tk);
                if ~isscalar(y) || ~isfinite(y)
                    bad = -1;
                    break
                end
                d = (ye(tk + h) - ye(tk - h)) / (2 * h);
                v = f(tk, y);
                if ~isscalar(v)
                    bad = -1;
                    break
                end
                if abs(d - v) > 1e-4 * max([1, abs(d), abs(v)])
                    bad = bad + 1;
                    where = [tk d v];
                end
            end
            if bad > 0 && ~asked
                fb = sprintf(['Your %s(t) is not a solution of the ODE (at t = %.4g its derivative is %.6g but ' ...
                    '%s(t, %s(t)) = %.6g), and the problem does not ask for an exact solution. Remove %s and ' ...
                    'everything that uses it, and rewrite the complete script with only what the problem asks.'], ...
                    exactNames{i}, where(1), where(2), odeNames{j}, exactNames{i}, where(3), exactNames{i});
                return
            elseif bad > 0
                fb = sprintf(['Your exact solution %s(t) does not satisfy the ODE %s: at t = %.4g its derivative is ' ...
                    '%.6g but %s(t, %s(t)) = %.6g. Derive it again (it must satisfy the ODE and the initial ' ...
                    'condition) and rewrite the complete script.'], ...
                    exactNames{i}, odeNames{j}, where(1), where(2), odeNames{j}, exactNames{i}, where(3));
                return
            end
        catch
        end
    end
end
end

function fb = local_checkFprintfMatrix(code)
fb = '';
[s, ~] = local_stripCode(code);
[st, en] = regexp(s, 'fprintf\s*\([^\n]*,\s*\[[^\[\]\n;]+\]\s*\)', 'start', 'end');
for k = 1:numel(st)
    seg = code(st(k):en(k));
    b = find(seg == '[', 1, 'last');
    inner = strtrim(seg(b+1:find(seg == ']', 1, 'last')-1));
    parts = regexp(inner, '[A-Za-z]\w*(\([^()]*\))?(\.?'')?', 'match');
    if numel(parts) < 2
        continue
    end
    for j = 1:numel(parts)
        try
            n = evalin('base', ['numel(' parts{j} ')']);
        catch
            continue
        end
        if n > 1
            fb = sprintf(['fprintf reads a matrix column by column, so %s prints the numbers in the wrong ' ...
                'order. For column vectors write fprintf(fmt, [a b c]'') (transposed); for row vectors write ' ...
                'fprintf(fmt, [a; b; c]).'], strtrim(seg));
            return
        end
    end
end
end

function fb = local_feedback(info, kb, code, cut, lastChance)
msg = strtrim(info.message);
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
    lim = regexp(m, '(?:must not exceed|out of bound;? (?:value )?|bound )(\d+)', 'tokens', 'once');
    if ~isempty(lim) && ~isempty(info.lineText)
        N = str2double(lim{1});
        used = regexp(info.lineText, '([A-Za-z]\w*)\((\d+)\)', 'tokens');
        for j = 1:numel(used)
            if str2double(used{j}{2}) > N
                h = [h sprintf(['- %s has only %d element(s) but the code uses %s(%s): this problem has %d values, ' ...
                    'so every matrix and loop must be built for size %d (do not copy a larger example).\n'], ...
                    used{j}{1}, N, used{j}{1}, used{j}{2}, N, N)]; %#ok<AGROW>
                break
            end
        end
    end
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
if ~isempty(regexp(m, 'derivative is zero|zerodenom|cannot divide by zero', 'once'))
    h = [h sprintf(['- The derivative/slope is zero there (a flat point or a repeated root, e.g. (x+1)^2): start from ' ...
        'another initial guess; if the problem does not require this method, use roots(p) for a polynomial or ' ...
        'fzero(f, x0).\n'])];
end
if ~isempty(regexp(m, 'fzero|endpoints|change sign|sign change', 'once'))
    h = [h sprintf(['- fzero needs f(a) and f(b) of opposite signs for a bracket [a b]; plot f first or ' ...
        'use a single initial guess fzero(f, x0).\n'])];
end
if ~isempty(regexp(m, 'must return a column vector|column vector', 'once'))
    h = [h sprintf('- ODE functions must return a COLUMN vector: [dy1; dy2] with semicolons.\n')];
end
sizeErr = ~isempty(regexp(m, ['concatenat|dimensions mismatch|nonconformant|Vectors must be the same length|' ...
    'must have the same|incompatible sizes|Matrix dimensions must agree'], 'once'));
adaptive = ~isempty(regexp(local_stripCode(code), '(ode45|ode23|ode113|ode15s)\s*\([^,]+,\s*\[[^\]]*\]', 'once'));
if sizeErr && adaptive
    h = [h sprintf(['- ode45(f, [t0 tf], y0) chooses its OWN time points, so its result has a different number of ' ...
        'rows than your other method. To compare at the same times call it with that time vector: ' ...
        '[t, y] = ode_rk4(f, [t0 tf], y0, h); [~, y45] = ode45(f, t, y0);\n'])];
end
if ~isempty(regexp(m, 'concatenat|dimensions mismatch', 'once'))
    h = [h sprintf(['- The arrays joined with [ ] do not have matching sizes: check size() of every part; ' ...
        'use x(:) for columns and the same number of rows.\n'])];
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

function req = local_requiredCalls(prompt)
% What the problem explicitly asks to use, as short instructions with call templates.
req = local_missingMethods(prompt, '');
end

function absent = local_missingMethods(prompt, code)
% MATLAB functions and numerical methods that the problem names but the code never uses.
absent = {};
p = lower(prompt);
c = lower(local_stripCode(code));
cc = lower(code);                         % comments count as evidence for hand-written methods
funcs = {'fzero', 'fminsearch', 'fminbnd', 'roots', 'integral', 'integral2', 'quad', 'trapz', 'cumtrapz', ...
    'ode45', 'ode23', 'ode113', 'ode15s', 'polyfit', 'polyval', 'interp1', 'interp2', 'spline', 'pchip', 'lu', ...
    'chol', 'eig', 'inv', 'det', 'cond', 'norm', 'fft', 'ifft', 'gradient', 'meshgrid', 'mesh', 'surf', 'contour', ...
    'subplot', 'histogram', 'ttest', 'ttest2', 'fitlm', 'readtable', 'xlsread', 'csvread', 'stem', 'plot3', ...
    'semilogy', 'semilogx', 'loglog', 'expm', 'besselj', 'erf', 'cumsum', 'linsolve', 'plotmatrix'};
for k = 1:numel(funcs)
    fn = funcs{k};
    asked = ~isempty(regexp(p, ['(using|use|via|apply|employ|matlab''?s?|built-in)\s+(the\s+)?(matlab\s+)?(built-in\s+)?' ...
        fn '\>|\<' fn '\s*(\(|function|command)'], 'once'));
    if asked && isempty(regexp(c, ['(?<![\w.])' fn '\s*\('], 'once'))
        absent{end+1} = local_callTemplate(fn); %#ok<AGROW>
    end
end
methods = {
    'bisection|bisect|half-interval', 'root_bisection|\(\s*xl\s*\+\s*xu\s*\)\s*/\s*2|bisect', 'the bisection method', '[xr, fx, ea, iter, tab] = root_bisection(f, xl, xu, es, maxit)'
    'false position|regula[ -]?falsi', 'root_falseposition|false position|regula|falsi', 'the false-position (regula falsi) method', '[xr, fx, ea, iter, tab] = root_falseposition(f, xl, xu, es, maxit)'
    'newton[- ]raphson|newton''s method|newtraph', 'root_newton|newton', 'the Newton-Raphson method', '[xr, fx, ea, iter, tab] = root_newton(f, df, x0, es, maxit)'
    '(?<!modified )secant', 'root_secant|root_modsecant|secant', 'the secant method', '[xr, fx, ea, iter, tab] = root_secant(f, x0, x1, es, maxit)'
    'fixed[- ]point|simple iteration', 'root_fixedpoint|fixed', 'fixed-point iteration', '[xr, res, ea, iter, tab] = root_fixedpoint(g, x0, es, maxit)'
    'golden[- ]section', 'opt_golden|golden', 'golden-section search', 'xopt = opt_golden(f, xl, xu, es)  (minimum; use -f for a maximum)'
    'euler''?s? method|(using|use|apply|employ)\s+(the\s+)?euler\>|forward euler|explicit euler', 'ode_euler|euler', 'Euler''s method', '[t, y] = ode_euler(dydt, [t0 tf], y0, h)'
    'heun', 'ode_heun|heun', 'Heun''s method', '[t, y] = ode_heun(dydt, [t0 tf], y0, h)'
    'midpoint method', 'ode_midpoint|midpoint', 'the midpoint method', '[t, y] = ode_midpoint(dydt, [t0 tf], y0, h)'
    'ralston', 'ode_ralston|ralston', 'Ralston''s method', '[t, y] = ode_ralston(dydt, [t0 tf], y0, h)'
    'runge[- ]kutta|\<rk4\>|fourth[- ]order rk', 'ode_rk4|rk4|k4', 'the 4th-order Runge-Kutta method', '[t, y] = ode_rk4(dydt, [t0 tf], y0, h)'
    'simpson', 'integ_simp|simpson|/\s*3|3\s*\*\s*h\s*/\s*8', 'Simpson''s rule', 'I = integ_simp13(f, a, b, n)  (n even) or integ_simpdata(x, y) for data'
    'trapezoid(al)? (rule|method)|\<trapz\>|trapezoidal integration|composite trapezoid', 'trapz|integ_trap|trapezoid', 'the trapezoidal rule', 'I = integ_trap(f, a, b, n) or trapz(x, y) for data'
    'romberg', 'integ_romberg|romberg', 'Romberg integration', '[I, ea, iter, R] = integ_romberg(f, a, b, es)'
    'gauss(ian)?[- ](legendre|quadrature)|two-point gauss|three-point gauss', 'integ_gauss|gauss', 'Gauss quadrature', 'I = integ_gauss(f, a, b, npts)'
    'boole', 'boole', 'Boole''s rule', 'I = integ_newtoncotes(f, a, b, ''boole'')'
    'richardson', 'diff_richardson|richardson|4\s*/\s*3', 'Richardson extrapolation', 'D = diff_richardson(f, x, h1, h2)'
    '\<lu\>|lu decomposition|lu factori', '(?<![\w.])lu\s*\(|lin_lu', 'LU factorization', '[L, U] = lu(A); d = L\b; x = U\d;'
    'cholesky', 'chol|lin_cholesky', 'Cholesky factorization', 'U = chol(A); x = U\(U''\b);'
    'gauss[- ]seidel', 'lin_gaussseidel|seidel', 'the Gauss-Seidel method', '[x, ea, iter] = lin_gaussseidel(A, b, es, maxit)'
    '\<jacobi\>(?! ?an)', 'lin_jacobi|jacobi', 'the Jacobi method', '[x, ea, iter] = lin_jacobi(A, b, es, maxit)'
    'cramer', 'lin_cramer|cramer|det\s*\(', 'Cramer''s rule', 'x = lin_cramer(A, b)'
    'partial pivoting|pivoting', 'lin_gausspivot|pivot', 'Gauss elimination with partial pivoting', '[x, D] = lin_gausspivot(A, b, true)'
    'thomas algorithm|tridiagonal (solver|algorithm)|tridiag\s*\(', 'lin_tridiag|tridiag|thomas', 'the tridiagonal (Thomas) algorithm', 'x = lin_tridiag(e, f, g, r)'
    'lagrange', 'interp_lagrange|lagrange', 'the Lagrange polynomial', 'yi = interp_lagrange(x, y, xi)'
    'divided difference|newton''s interpolating|newton interpolating', 'interp_newton|interp_divdiff|divided|polyfit', 'Newton''s divided differences', '[yi, b] = interp_newton(x, y, xi)'
    'power method', 'eig_power|power', 'the power method', '[lambda, v] = eig_power(A)'
    'shooting', 'ode_shooting|shoot|fzero|res', 'the shooting method', 'solve the IVP with ode45 for a guessed slope and adjust it with fzero on the end residual'
    'finite[- ]difference (method|approach)', 'ode_fdbvp|\\|tridiag|finite', 'the finite-difference method', 'build the tridiagonal system of the node equations and solve it with \'
    };
for k = 1:size(methods, 1)
    if ~isempty(regexp(p, methods{k, 1}, 'once')) && isempty(regexp(cc, methods{k, 2}, 'once'))
        if strcmp(methods{k, 3}, 'Euler''s method') && ~isempty(regexp(p, 'euler''?s (formula|identity)', 'once'))
            continue
        end
        absent{end+1} = [methods{k, 3} ' (e.g. ' methods{k, 4} ')']; %#ok<AGROW>
    end
end
absent = unique(absent, 'stable');
end

function t = local_callTemplate(fn)
T = {'integral', 'I = integral(f, a, b) with a vectorized f (.* ./ .^)'; 'fzero', 'xr = fzero(f, [xl xu]) or fzero(f, x0)';
    'ode45', '[t, y] = ode45(dydt, tspan, y0)'; 'polyfit', 'p = polyfit(x, y, n); yi = polyval(p, xi)';
    'interp1', 'yi = interp1(x, y, xi, method)'; 'spline', 'yi = spline(x, y, xi)'; 'trapz', 'I = trapz(x, y)';
    'eig', '[V, D] = eig(A)'; 'lu', '[L, U] = lu(A); x = U\(L\b)'; 'roots', 'r = roots(c)'; 'fft', 'Y = fft(y)/n';
    'fminsearch', 'p = fminsearch(@(p) sum((y - model(p, x)).^2), p0)'; 'fminbnd', 'x = fminbnd(f, a, b)';
    'gradient', 'dy = gradient(y, h)'; 'cumtrapz', 'I = cumtrapz(x, y)'};
t = [fn '()'];
k = find(strcmp(T(:,1), fn), 1);
if ~isempty(k)
    t = sprintf('%s (e.g. %s)', t, T{k, 2});
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

function msgs = local_buildSolveMessages(root, prompt, kb, env, ctx, conv, follow, opts, numCtx, numPredict)
% System prompt (fixed for this PC, so the engine can reuse it from memory), the closest solved
% examples, then one message with the topic notes, library help and the problem.
extra = local_attachments(root, prompt, kb);
wsInfo = local_workspaceContext(prompt, follow);
cmdInfo = '';
if local_refersToCommands(prompt)
    cmdInfo = local_commandContext(12);
end
budget = max(8000, floor((numCtx - numPredict - 800) * 3));
sys = local_systemStatic(root, env, kb);
nTopics = numel(ctx.topicIdx);
for pass = 1:8
    msgs = {local_msg('system', sys)};
    for k = ctx.examples
        ex = kb.examples(k);
        msgs{end+1} = local_msg('user', ['PROBLEM:' char(10) ex.problem]); %#ok<AGROW>
        msgs{end+1} = local_msg('assistant', ['```matlab' char(10) local_compactCode(ex.code, ex.problem) char(10) '```']); %#ok<AGROW>
    end
    user = '';
    if follow
        [prev, older] = local_convContext(conv, pass);
        msgs = [msgs, prev]; %#ok<AGROW>
        if ~isempty(older)
            user = [user older char(10)]; %#ok<AGROW>
        end
    end
    for t = ctx.topicIdx(1:nTopics)
        T = kb.topics(t);
        if ~isempty(T.cheat)
            user = [user sprintf('NOTES FOR %s PROBLEMS:\n%s\n\n', upper(T.name), T.cheat)]; %#ok<AGROW>
        end
    end
    if ~isempty(ctx.libFull)
        user = [user sprintf('RU_LIB FUNCTIONS FOR THIS PROBLEM (already on the path):')]; %#ok<AGROW>
        for k = ctx.libFull
            user = [user sprintf('\n\n%s', kb.lib(k).help)]; %#ok<AGROW>
        end
        user = [user char(10) char(10)]; %#ok<AGROW>
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
    req = local_requiredCalls(prompt);
    if ~isempty(req)
        user = [user char(10) char(10) 'THE PROBLEM REQUIRES (use exactly these, with this problem''s own variables):' ...
            char(10) '- ' strjoin(req, [char(10) '- ']) char(10) ...
            'Compute true/exact values with the required MATLAB function; never type them from memory.']; %#ok<AGROW>
    end
    user = [user char(10) char(10) 'Write the complete MATLAB script.']; %#ok<AGROW>
    msgs{end+1} = local_msg('user', user); %#ok<AGROW>
    total = sum(cellfun(@(m) numel(m.content), msgs));
    if total <= budget
        break
    end
    % Too long for the context: drop the second example, trim the library help, the second topic's
    % notes, then the first example.
    if numel(ctx.examples) > 1
        ctx.examples = ctx.examples(1);
    elseif numel(ctx.libFull) > 4
        ctx.libFull = ctx.libFull(1:4);
    elseif nTopics > 1
        nTopics = 1;
    elseif ~isempty(ctx.examples)
        ctx.examples = zeros(1, 0);
    elseif numel(ctx.libFull) > 2
        ctx.libFull = ctx.libFull(1:2);
    elseif nTopics > 0
        nTopics = 0;
    end
end
end

function s = local_systemStatic(root, env, kb)
% The fixed part of every solve prompt on this PC (rules, MATLAB version, toolboxes, library names,
% the user's rules). It is identical for every problem, so the engine keeps it in memory.
s = local_systemPrompt(env);
if ~isempty(kb.lib)
    s = [s sprintf('\n\nALL RU_LIB FUNCTIONS (same conventions; the ones for this problem are explained with it): %s', ...
        strjoin({kb.lib.name}, ', '))];
end
mem = local_memory(root);
if ~isempty(mem)
    s = [s sprintf('\n\nUSER RULES (always follow):\n%s', mem)];
end
end

function s = local_systemPrompt(env)
L = {
    'You are ru, an expert MATLAB engineer and numerical-methods tutor for the BUET course CE206 (textbook: Chapra, Applied Numerical Methods with MATLAB).'
    ['Write ONE complete MATLAB script that solves the PROBLEM exactly as asked and runs without errors in MATLAB ' env.release '.']
    'The solved examples show the style and the ru_lib calls; adapt them to the new PROBLEM with its own numbers, guesses and names.'
    'Reply with exactly one ```matlab code block and nothing else.'
    ''
    'READING THE PROBLEM'
    '- Text copied from PDFs loses symbols: "x2" after a letter usually means x^2, "e-x" means exp(-x), "2pi(12.5)t" means 2*pi*12.5*t, "10-5" in "2x10-5" means 10^-5. Decide the intended math from context.'
    '- Solve every part (a), (b), (c)... in order.'
    '- Use exactly the method, initial guesses, interval, tolerance, number of iterations and step size that the problem gives. If no method is named, use the most reliable built-in (fzero, roots, backslash, polyfit, interp1, spline, integral, ode45, eig).'
    '- Values that depend on the student ID (e.g. X = last three digits) come from USER RULES; if unknown, use the example value given and print a one-line note.'
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
    'OUTPUT RULES (the user sees only your code and what it prints)'
    '8. Write no comments at all.'
    '9. Show every requested result once: leave the semicolon off its assignment (root = xr) or print it with one fprintf with enough digits and its unit (fprintf(''root = %.6f m\n'', xr)). Print the iteration table only when iterations are asked for, and one comparison table when methods are compared. With several parts, print the part label first, e.g. disp(''(a)'').'
    '10. Do not print the problem, the equations, explanations or checks: ru checks the results itself. Do not add anything the problem does not ask for (no exact/true values, errors, extra tables).'
    '11. Plot only when the problem asks for a graph/plot/figure: figure; plot(...); grid on; xlabel(...); ylabel(...); title(...); legend(...).'
    ['12. ' env.toolboxLine]
    '13. Prefer the ru_lib functions (already on the path) and call them exactly as documented. Never invent functions. Never call ru.'
    };
if ~isempty(env.oldLine)
    L{end+1} = ['14. ' env.oldLine];
end
s = strjoin(L', char(10));
end

function line = local_releaseLine(release)
% Functions that do not exist yet in an older MATLAB (the generated code must avoid them).
line = '';
t = regexp(release, 'R(\d{4})([ab])', 'tokens', 'once');
if isempty(t)
    return
end
v = str2double(t{1}) + 0.5 * strcmp(t{2}, 'b');
L = {2017.0, 'strings in double quotes "..." (use single quotes)';
    2017.5, 'isfile, isfolder (use exist), vecnorm, str2sym, mink, maxk, rescale';
    2018.0, 'normalize';
    2018.5, 'xline, yline, sgtitle';
    2019.0, 'readmatrix, writematrix, readcell, writecell (use dlmread, xlsread, csvread, dlmwrite)';
    2019.5, 'tiledlayout, nexttile, arguments blocks';
    2020.0, 'exportgraphics'};
miss = {};
for k = 1:size(L, 1)
    if v < L{k, 1}
        miss{end+1} = L{k, 2}; %#ok<AGROW>
    end
end
if ~isempty(miss)
    line = sprintf('This is the older MATLAB %s: do not use newer features: %s.', release, strjoin(miss, '; '));
end
end

function s = local_askSystemPrompt(env)
L = {
    'You are ru, a precise MATLAB and numerical-methods tutor for the BUET course CE206 (textbook: Chapra, Applied Numerical Methods with MATLAB).'
    'Answer the question correctly and clearly in plain English: short paragraphs or bullet points, formulas in plain text (x^2, sqrt(), exp()). Never use LaTeX; the answer is shown in the MATLAB Command Window.'
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
E.oldLine = local_releaseLine(E.release);
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
    local_say(root, '[ru] Using your file %s\n', fullfile(U.folder, [U.name '.m']));
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
if follow
    ctx = local_retrieve(kb, [conv{end}.prompt char(10) question]);
else
    ctx = local_retrieve(kb, question);
end
E = local_engine(root, false, 'text');
if isempty(E.model)
    local_busy('');
    local_engineHelp();
    return
end
sys = local_askSystemPrompt(env);
mem = local_memory(root);
if ~isempty(mem)
    sys = [sys sprintf('\n\nUSER RULES:\n%s', mem)];
end
msgs = {local_msg('system', sys)};
if follow
    prev = local_convContext(conv, 1);
    msgs = [msgs, prev];
end
user = '';
for t = ctx.topicIdx
    T = kb.topics(t);
    if ~isempty(T.cheat)
        user = [user sprintf('NOTES FOR %s:\n%s\n\n', upper(T.name), T.cheat)]; %#ok<AGROW>
    end
end
if ~isempty(opts.extraContext)
    user = [user opts.extraContext char(10)];
end
if local_refersToCommands(question)
    user = [user local_commandContext(12) char(10)];
end
if ~isempty(user)
    user = [user 'QUESTION:' char(10)];
end
msgs{end+1} = local_msg('user', [user question]);
think = opts.think && any(strcmp(E.caps, 'thinking'));
if local_isLoaded(E)
    local_busy(sprintf('ru: answering (%s) ...', E.model));
else
    local_busy(sprintf('ru: loading %s into memory (first use), then answering ...', E.model));
end
[reply, ~, err, E] = local_llm(root, E, msgs, 0.3, 1500, think);
local_busy('');
if ~isempty(err)
    local_err('[ru] AI engine error: %s\n', err);
    return
end
reply = local_plainText(strtrim(reply));
fprintf('%s\n', reply);
bad = local_unknownFunctionsInText(reply);
if ~isempty(bad)
    local_err(['[ru] Check: these names in the answer are not functions on this MATLAB (maybe a toolbox you do not ' ...
        'have, or a mistake): %s\n'], strjoin(bad, ', '));
end
local_say(root, '\n[ru] (%.0f s, %s) Answer from a small offline model: verify important facts. To compute: ru <problem>\n', ...
    toc(t0), E.model);
turnQ = question;
if ~isempty(opts.turnPrompt)
    turnQ = opts.turnPrompt;
end
local_convAdd(root, 'ask', turnQ, '', reply, true);
local_log(root, sprintf('ANSWER:\n%s', reply));
end

function t = local_plainText(t)
% LaTeX/Markdown -> readable Command Window text.
t = regexprep(t, '\\\[|\\\]|\\\(|\\\)|\$\$', '');
t = regexprep(t, '\\frac\{([^{}]*)\}\{([^{}]*)\}', '($1)/($2)');
t = regexprep(t, '\\(left|right)\s*', '');
t = regexprep(t, '\\(cdot|times)', '*');
t = regexprep(t, '\\(approx)', '~');
t = regexprep(t, '\\(le|leq)\>', '<=');
t = regexprep(t, '\\(ge|geq)\>', '>=');
t = regexprep(t, '\\(sqrt)\{([^{}]*)\}', 'sqrt($2)');
t = regexprep(t, '\\(alpha|beta|gamma|delta|Delta|epsilon|theta|lambda|mu|pi|sigma|tau|phi|omega|rho)\>', '$1');
t = regexprep(t, '_\{([^{}]*)\}', '_$1');
t = regexprep(t, '\^\{([^{}]*)\}', '^($1)');
t = regexprep(t, '\*\*([^*\n]+)\*\*', '$1');
t = regexprep(t, '(?m)^#{1,6}\s*', '');
t = regexprep(t, '\n{3,}', sprintf('\n\n'));
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
local_say(root, '[ru] Solving again: %s\n', local_preview(T.prompt, 300));
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
if local_verbose(root)
    fprintf('[ru] Error found:\n%s\n', local_preview(errText, 1500));
else
    fprintf('[ru] Fixing: %s\n', local_firstLine(errText));
end
ctxt = '';
if ~isempty(cmds)
    ctxt = [ctxt 'COMMANDS THE USER RAN IN THE COMMAND WINDOW (oldest first):' char(10) strjoin(cmds, char(10)) char(10)];
end
for k = 1:numel(files)
    ctxt = [ctxt sprintf('\nTHE USER''S FILE %s:\n```matlab\n%s\n```\n', files{k}, ...
        local_preview(local_ascii(local_readText(files{k})), 6000))]; %#ok<AGROW>
end
problem = ['Fix this MATLAB error: write the corrected complete script that does what the user intended ' ...
    '(keep its plots and printed results).' char(10) 'ERROR:' char(10) errText];
if ~isempty(strtrim(note))
    problem = [problem char(10) 'The user adds: ' local_ascii(note)];
end
opts.forceAI = true;
opts.forceSolve = true;
opts.extraContext = ctxt;
opts.turnPrompt = ['ru fix: ' local_firstLine(errText)];
opts.label = ' (fix)';
opts.keepAll = true;
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
    le = local_userError();
    if ~isempty(strtrim(le)) && isempty(strfind(le, 'ru_task_'))
        errText = strtrim(le);
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
        local_say(root, '[ru] Using the image on the clipboard.\n');
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
E = local_engine(root, false, 'vision');
local_busy('');
if isempty(E.model)
    env = local_env();
    if env.vision
        local_err('[ru] No vision model fits this PC; reading the text with MATLAB''s ocr (equations and tables may be lost).\n');
        try
            r = ocr(imread(file));
            text = strtrim(r.Text);
        catch ME
            fprintf(2, '[ru] ocr failed: %s\n', ME.message);
        end
        return
    end
    why = local_engineProblem();
    if isempty(why)
        why = 'reading pictures needs a vision model (qwen3.5) that fits this PC';
    end
    local_err('[ru] %s.\n[ru] Type or paste the problem instead: ru\n', why);
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
local_busy(sprintf('ru: reading the image (%s) ...', E.model));
[text, ~, err] = local_llm(root, E, {msg}, 0, 2500, false);
local_busy('');
if ~isempty(err)
    local_err('[ru] Vision model error: %s\n', err);
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
    % Remove workspace-destroying or blocking statements (whole statements only).
    rx = ['(^|[;,])\s*(?:clc|clear\s+all|clear\s+variables|clearvars[^;,]*|clear|close\s+all|' ...
        'close\s*\(\s*''all''\s*\)|pause(?:\s*\([^)]*\))?|commandwindow|home)\s*(?=[;,]|$)'];
    s2 = regexprep(s, rx, '$1');
    if isempty(regexp(s2, '[^\s;,]', 'once'))
        keep(k) = false;
    elseif ~strcmp(s2, s)
        lines{k} = regexprep(L, rx, '$1');
    end
    % "clear x y" keeps the listed variables' removal only; drop it (it can erase results).
    if ~isempty(regexp(s, '^\s*clear\s+\w', 'once'))
        keep(k) = false;
    end
end
code = strjoin(lines(keep), char(10));
% Octave logical operators outside strings: != -> ~=, !x -> ~x
code = local_fixBang(code);
% MATLAB before R2017a has no "double-quoted" strings.
if ~isempty(strfind(local_env().oldLine, 'double quotes'))
    code = local_singleQuotes(code);
end
% Implicit multiplication outside strings/comments: 2x -> 2*x, 2(x) -> 2*(x), )( -> )*(
code = local_fixImplicitMult(code);
code = regexprep(code, '\n{3,}', sprintf('\n\n'));
code = strtrim(code);
end

function code = local_fixBang(code)
if isempty(strfind(code, '!'))
    return
end
s = local_stripCode(code);
idx = find(s == '!');
for k = numel(idx):-1:1
    i = idx(k);
    lineStart = find(s(1:i-1) == char(10), 1, 'last');
    if isempty(lineStart)
        lineStart = 0;
    end
    if isempty(strtrim(s(lineStart+1:i-1)))
        continue                         % "!" at the start of a line is a shell escape (rejected later)
    end
    code(i) = '~';
end
end

function code = local_singleQuotes(code)
% "text" -> 'text' (outside comments), for MATLAB releases without string literals.
if isempty(strfind(code, '"'))
    return
end
[~, cm] = local_stripCode(code);
out = '';
i = 1;
n = numel(code);
while i <= n
    ch = code(i);
    if ch == '''' && ~cm(i)
        % copy a single-quoted string (or a transpose) unchanged
        lineStart = find(code(1:i-1) == char(10), 1, 'last');
        if isempty(lineStart)
            lineStart = 0;
        end
        if ~local_isTranspose(code, i, lineStart + 1)
            j = i + 1;
            while j <= n && code(j) ~= char(10)
                if code(j) == ''''
                    if j < n && code(j+1) == ''''
                        j = j + 2;
                        continue
                    end
                    break
                end
                j = j + 1;
            end
            out = [out code(i:min(j, n))]; %#ok<AGROW>
            i = j + 1;
            continue
        end
    end
    if ch == '"' && ~cm(i)
        j = i + 1;
        body = '';
        while j <= n && code(j) ~= char(10)
            if code(j) == '"'
                if j < n && code(j+1) == '"'
                    body = [body '"']; %#ok<AGROW>
                    j = j + 2;
                    continue
                end
                break
            end
            if code(j) == ''''
                body = [body ''''''];  %#ok<AGROW>
            else
                body = [body code(j)]; %#ok<AGROW>
            end
            j = j + 1;
        end
        if j <= n && code(j) == '"'
            out = [out '''' body '''']; %#ok<AGROW>
            i = j + 1;
            continue
        end
    end
    out = [out ch]; %#ok<AGROW>
    i = i + 1;
end
code = out;
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
        % An indented body followed by unindented code: the unindented part is script code.
        indented = ~cellfun(@isempty, regexp(stripped(f+1:e), '^\s+\S', 'once'));
        if any(indented)
            firstBody = f + find(~cellfun(@isempty, regexp(stripped(f+1:e), '\S', 'once')), 1);
            for j = max(firstBody, f+1):e
                if ~isempty(regexp(stripped{j}, '^\S', 'once')) && isempty(regexp(stripped{j}, '^(end|function)\>', 'once')) ...
                        && (isempty(strtrim(stripped{j-1})) || ~isempty(regexp(stripped{j-1}, '^\s+\S', 'once')))
                    e = j - 1;
                    break
                end
            end
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
L = strtrim(regexp(code, '\n', 'split'));
L = L(~cellfun(@isempty, L));
for k = 1:numel(L) - 3
    if numel(L{k}) > 15 && all(strcmp(L(k+1:k+3), L{k}))
        problem = sprintf(['Your reply repeats the same line again and again (%s). Write the script once, ' ...
            'short and complete, with only what the problem asks.'], L{k});
        return
    end
end
if ~isempty(regexp(c, '(?m)^\s*cd(\s+[^=\s]|\s*\()', 'once')) && ~any(strcmp(local_definedNames(c), 'cd'))
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
if ~isempty(regexp(code, '(?m)^\s*load\s*(\(\s*)?[''"]?[\w\\/:.-]*\.mat|(?m)^\s*load\s*(\(\s*)?[''"]?[\w\\/:.-]+[''"]?\s*\)?\s*;?\s*$', 'once')) ...
        && isempty(regexp(code, '\.(dat|txt|csv)', 'once'))
    return                                  % variables come from a .mat file: cannot know their names
end
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

function [s, cm] = local_stripCode(code)
% Replace comments and string literals by spaces (keeps line breaks and positions).
% cm marks the characters that belong to comments.
s = code;
n = numel(s);
cm = false(size(s));
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
        cm(i:i+e-2) = true;
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
        cm(i:i+e-2) = true;
        i = i + e - 1;
        continue
    end
    if ch == '.' && i + 2 <= n && strcmp(s(i:i+2), '...')
        e = find(s(i:end) == char(10), 1);
        if isempty(e)
            e = n - i + 2;
        end
        s(i+3:i+e-2) = ' ';
        cm(i+3:i+e-2) = true;
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

% =====================================================================
% Compact code: what the user sees is exactly what runs
% =====================================================================

function code = local_compactCode(code, prompt)
% No comments; no "Check ..." prints unless a check is asked for; no plots unless a plot is asked for.
code = local_dropComments(code);
if isempty(code)
    return
end
p = lower(prompt);
keepChecks = ~isempty(regexp(p, ['check|verif|confirm|substitut|residual|validat|compare|comparison|' ...
    'exact|true (value|error|solution)|analytical'], 'once'));
keepPlots = local_plotAsked(prompt);
if keepChecks && keepPlots
    return
end
lines = regexp(code, '\n', 'split');
stripped = regexp(local_stripCode(code), '\n', 'split');
if numel(stripped) ~= numel(lines)
    return
end
keep = true(size(lines));
k = 1;
while k <= numel(lines)
    stmts = local_statements(lines{k}, stripped{k});
    drop = ~isempty(stmts);
    for j = 1:numel(stmts)
        isCheck = ~keepChecks && ~isempty(regexpi(stmts{j}, ...
            '^\s*(fprintf|disp)\s*\(\s*(sprintf\s*\(\s*)?''(\\n|\s)*(checks?\>|verif|ode45 check)', 'once'));
        isPlot = ~keepPlots && local_isPlotStatement(stmts{j});
        if ~(isCheck || isPlot)
            drop = false;
            break
        end
    end
    last = k;
    while last < numel(lines) && ~isempty(regexp(stripped{last}, '\.\.\.\s*$', 'once'))
        last = last + 1;          % a statement continued with ... on the next lines
    end
    if drop
        keep(k:last) = false;
    end
    k = last + 1;
end
code = local_dropComments(strjoin(lines(keep), char(10)));
end

function tf = local_plotAsked(prompt)
tf = ~isempty(regexpi(prompt, ['\<(plot|plots|plotted|plotting|graph|graphs|graphical|graphically|figure|figures|' ...
    'sketch|draw|visuali[sz]e|chart|histogram|subplot|curve|curves|surface|contour|mesh|diagram|axes|' ...
    'legend|visual)\>'], 'once'));
end

function tf = local_isPlotStatement(st)
kw = ['figure|plot|plot3|fplot|fplot3|ezplot|hold|grid|xlabel|ylabel|zlabel|title|sgtitle|legend|subplot|axis|' ...
    'xlim|ylim|zlim|semilogx|semilogy|loglog|surf|surfc|mesh|meshc|meshz|contour|contourf|contour3|clabel|' ...
    'colorbar|colormap|shading|view|text|annotation|stem|stairs|bar|barh|bar3|area|fill|patch|scatter|scatter3|' ...
    'quiver|polar|polarplot|pie|histogram|errorbar|line|box|daspect|pbaspect|xticks|yticks|xticklabels|' ...
    'yticklabels|drawnow|fsurf|fmesh|fimplicit|yyaxis|clf|gtext|rotate3d|linkaxes'];
tf = ~isempty(regexp(st, ['^\s*(' kw ')(\s*\(|\s+[A-Za-z''-]|\s*$)'], 'once')) ...
    || ~isempty(regexp(st, '^\s*set\s*\(\s*(gca|gcf)\>', 'once'));
end

function stmts = local_statements(line, strippedLine)
% Split one line into statements at top-level ; and , (strings and brackets respected).
stmts = {};
if isempty(regexp(strippedLine, '\S', 'once'))
    return
end
depth = 0;
start = 1;
for i = 1:numel(strippedLine)
    ch = strippedLine(i);
    if any(ch == '([{')
        depth = depth + 1;
    elseif any(ch == ')]}')
        depth = max(0, depth - 1);
    elseif depth == 0 && (ch == ';' || ch == ',')
        piece = strtrim(line(start:i-1));
        if ~isempty(piece)
            stmts{end+1} = piece; %#ok<AGROW>
        end
        start = i + 1;
    end
end
piece = strtrim(line(start:min(end, numel(strippedLine))));
if ~isempty(regexp(strippedLine(start:end), '\S', 'once')) && ~isempty(piece)
    stmts{end+1} = piece;
end
end

function code = local_dropComments(code)
% Remove every comment (strings are kept); drop comment-only lines; at most one blank line in a row.
if isempty(code)
    return
end
code = strrep(code, char(13), '');
[~, cm] = local_stripCode(code);
lines0 = regexp(code, '\n', 'split');
lines = regexp(code(~cm), '\n', 'split');
if numel(lines) ~= numel(lines0)
    return
end
out = {};
for k = 1:numel(lines)
    L = regexprep(lines{k}, '\s+$', '');
    if isempty(regexp(L, '\S', 'once'))
        if ~isempty(regexp(lines0{k}, '\S', 'once')) || isempty(out) || isempty(out{end})
            continue
        end
        L = '';
    end
    out{end+1} = L; %#ok<AGROW>
end
while ~isempty(out) && isempty(out{end})
    out(end) = [];
end
code = strjoin(out, char(10));
end

% =====================================================================
% Terminal output: compact by default (ru verbose on shows every step)
% =====================================================================

function tf = local_verbose(root)
tf = any(strcmpi(local_setting(root, 'verbose', 'off'), {'on', '1', 'true', 'yes'}));
end

function local_say(root, varargin)
% A progress/information line, shown only in verbose mode.
if local_verbose(root)
    local_busy('');
    fprintf(varargin{:});
end
end

function local_err(varargin)
% A message that matters (errors, warnings): always shown, in red.
local_busy('');
fprintf(2, varargin{:});
end

function local_busy(txt)
% One temporary status line ("ru: writing code ...") that is erased again afterwards.
persistent n
if isempty(n)
    n = 0;
end
if n > 0
    b = repmat(sprintf('\b'), 1, n);
    fprintf('%s%s%s', b, repmat(' ', 1, n), b);
    n = 0;
end
if ~isempty(txt)
    fprintf('%s', txt);
    n = numel(txt);
    try
        if exist('OCTAVE_VERSION', 'builtin')
            fflush(stdout);
        else
            drawnow;
        end
    catch
    end
end
end

function local_show(root, code, output)
% The solution as the user sees it: the MATLAB commands, then what MATLAB printed.
local_busy('');
if local_verbose(root)
    bar = repmat('-', 1, 64);
    fprintf('\n%s\n%s\n%s\n', bar, code, bar);
else
    fprintf('%s\n', code);
end
if ~isempty(strtrim(output))
    if isempty(regexp(output, '^\s*\n', 'once'))
        fprintf('\n');
    end
    fprintf('%s', output);
    if output(end) ~= char(10)
        fprintf('\n');
    end
end
end

function [ok, info] = local_execute(root, code, echo)
if nargin < 3
    echo = true;
end
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
if echo
    fprintf('%s', out);
    if ~isempty(out) && out(end) ~= char(10)
        fprintf('\n');
    end
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
msg = strrep(msg, file, 'your script');
msg = strrep(msg, [name '.m'], 'your script');
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
% Data values in a text: thousands separators removed; digits inside words (interp1, m3, ode45)
% and problem/figure/table labels are ignored.
txt = regexprep(txt, '(?<=\d),(?=\d{3}(?!\d))', '');
txt = regexprep(txt, ['(?i)\<(problem|prob\.?|example|ex\.?|exercise|fig\.?|figure|table|eq\.?|' ...
    'equation|section|sec\.?|chapter|ch\.?|page|slide|question|q\.?|set)[\s\-]*[A-Z]?\d+(\.\d+)*[a-z]?'], ' ');
tok = regexp(txt, '(?<![A-Za-z_\d.])(\d+\.?\d*|\.\d+)', 'match');
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

function E = local_engine(root, forceStart, purpose, exclude)
% The engine (host) and model to use for 'text' or 'vision'. E.model is empty when none can be used.
% Quality first: the strongest installed model that fits this PC's free memory (RAM + graphics memory).
persistent C
if nargin < 4
    exclude = {};
end
if isempty(C)
    C = struct('text', [], 'vision', []);
end
E = local_emptyEngine(purpose);
key = 'model';
if strcmp(purpose, 'vision')
    key = 'vision';
end
want = local_modelChoice(root, key);
cached = C.(purpose);
if ~forceStart && isempty(exclude) && ~isempty(cached)
    names = local_tags(cached.host, 3);
    if any(strcmp(names, cached.model)) && (strcmpi(want, 'auto') || local_sameModel(want, cached.model))
        E = cached;
        return
    end
end
hosts = local_hosts(root);
pend = local_pendHost();
customUp = ~strcmp(hosts{1}, pend) && ~isempty(local_tags(hosts{1}, 3));
if local_ping(pend)
    local_checkEngineFolder(root);
end
if ~local_ping(pend) && (forceStart || ~customUp) ...
        && (forceStart || ~isempty(local_pendriveModels(root)) || ~isempty(local_findOllama(root)))
    local_busy('ru: starting the AI engine ...');
    local_startEngine(root, false);
    local_busy('');
end
[H, M, S] = local_findModels(hosts);
if isempty(M)
    if isempty(local_engineProblem())
        if isempty(local_pendriveModels(root))
            local_engineProblem('there is no AI model on the pendrive (run setup_ru.bat once on a PC with internet)');
        else
            local_engineProblem('the AI engine is not running (see ru status)');
        end
    end
    return
end
infos = cell(1, numel(M));
for k = 1:numel(M)
    infos{k} = local_modelInfo(H{k}, M{k});
end
[k, why] = local_chooseModel(root, H, M, S, infos, want, purpose, exclude);
if k == 0
    return
end
E.host = H{k};
E.model = M{k};
E.caps = infos{k}.caps;
E.maxCtx = infos{k}.ctx;
E.ctx = min(16384, infos{k}.ctx);
E.bytes = S(k);
E.why = why;
C.(purpose) = E;
if local_ping(E.host)
    local_engineProblem('');
end
end

function local_checkEngineFolder(root)
% An engine on port 11435 that was started from another folder (another copy of ru, setup_ru.bat)
% serves that folder's models, so models of THIS pendrive look "not installed". Restart it here.
persistent done
if ~isempty(done) && strcmp(done, root)
    return
end
done = root;
if isempty(local_findOllama(root))
    return
end
P = local_pendriveModels(root);
if isempty(P)
    return
end
served = local_tags(local_pendHost(), 3);
mine = {P([P.complete]).name};
missing = mine(cellfun(@(n) ~any(cellfun(@(m) local_sameModel(n, m), served)), mine));
if isempty(missing)
    return
end
local_err(['[ru] The running AI engine does not have %s from this folder (it was started from another ' ...
    'folder); restarting it from %s ...\n'], strjoin(missing, ', '), root);
local_restartEngine(root, false);
end

function E = local_emptyEngine(purpose)
E = struct('host', '', 'model', '', 'caps', {{}}, 'ctx', 16384, 'maxCtx', 8192, 'bytes', 0, ...
    'why', '', 'purpose', purpose);
end

function h = local_pendHost()
h = 'http://127.0.0.1:11435';
end

function tf = local_isPendHost(host)
tf = strcmp(host, local_pendHost());
end

function tf = local_isLocalHost(host)
tf = ~isempty(regexp(host, '//(127\.0\.0\.1|localhost)(:|/|$)', 'once'));
end

function msg = local_engineProblem(set)
% The last reason why the AI engine could not be used (shown by ru status and in offline mode).
persistent P
if isempty(P)
    P = '';
end
if nargin == 1
    P = set;
end
msg = P;
end

function hosts = local_hosts(root)
hosts = {local_pendHost(), 'http://127.0.0.1:11434'};
custom = strtrim(local_setting(root, 'host', ''));
if ~isempty(custom)
    if isempty(regexp(custom, '^https?://', 'once'))
        custom = ['http://' custom];
    end
    if isempty(regexp(custom, ':\d+/*$', 'once'))
        custom = [regexprep(custom, '/+$', '') ':11434'];
    end
    hosts = [{regexprep(custom, '/+$', '')}, hosts];
end
end

function [H, M, S] = local_findModels(hosts)
H = {};
M = {};
S = zeros(1, 0);
for i = 1:numel(hosts)
    [names, sizes] = local_tags(hosts{i}, 3);
    for k = 1:numel(names)
        if isempty(regexp(lower(names{k}), 'embed|bge|minilm|nomic', 'once'))
            H{end+1} = hosts{i}; %#ok<AGROW>
            M{end+1} = names{k}; %#ok<AGROW>
            S(end+1) = sizes(k); %#ok<AGROW>
        end
    end
end
end

function [names, sizes] = local_tags(host, timeout)
names = {};
sizes = zeros(1, 0);
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
        b = 0;
        if isfield(item, 'size') && isnumeric(item.size) && ~isempty(item.size)
            b = double(item.size);
        end
        sizes(end+1) = b; %#ok<AGROW>
    end
end
end

function L = local_loaded(host)
% Models currently in memory on an engine: name, total size and the part on the graphics card.
L = struct('name', {}, 'size', {}, 'vram', {}, 'ctx', {});
r = local_getJSON([host '/api/ps'], 3);
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
    if ~isstruct(item) || ~isfield(item, 'name')
        continue
    end
    e = struct('name', char(item.name), 'size', 0, 'vram', 0, 'ctx', 0);
    if isfield(item, 'size'), e.size = double(item.size); end
    if isfield(item, 'size_vram'), e.vram = double(item.size_vram); end
    if isfield(item, 'context_length'), e.ctx = double(item.context_length); end
    L(end+1) = e; %#ok<AGROW>
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
    info.caps = local_guessCaps(n);
end
CACHE(key) = info;
end

function caps = local_guessCaps(n)
caps = {'completion'};
if ~isempty(regexp(n, 'qwen3\.5|qwen3-vl|qwen2\.5vl|llava|gemma3|minicpm-v|vision|moondream|granite3\.2-vision|mistral-small3', 'once'))
    caps{end+1} = 'vision';
end
if ~isempty(regexp(n, 'qwen3|deepseek-r1|qwq|gpt-oss|magistral', 'once'))
    caps{end+1} = 'thinking';
end
end

function [k, why] = local_chooseModel(root, H, M, S, infos, want, purpose, exclude)
% Quality first: the strongest model (by local_modelScore) that fits the free memory of this PC.
persistent noted
if isempty(noted)
    noted = {};
end
k = 0;
why = '';
needVision = strcmp(purpose, 'vision');
ok = true(1, numel(M));
for i = 1:numel(M)
    if any(strcmp(exclude, M{i})) || (needVision && ~any(strcmp(infos{i}.caps, 'vision')))
        ok(i) = false;
    end
end
if ~isempty(want) && ~strcmpi(want, 'auto')
    for i = 1:numel(M)
        if ok(i) && local_sameModel(want, M{i})
            k = i;
            why = 'chosen for this PC with ru model / ru vision';
            return
        end
    end
    if any(cellfun(@(e) local_sameModel(want, e), exclude))
        local_err('[ru] %s does not fit in the free memory now; using a smaller model for this question.\n', want);
    elseif ~any(strcmp(noted, ['want:' want]))
        noted{end+1} = ['want:' want];
        md = local_modelsDir(root);
        if isempty(md)
            md = fullfile(root, 'model');
        end
        local_err(['[ru] %s (chosen with ru model) is not in the running AI engine, which has: %s.\n' ...
            '[ru] Models are read from %s. Check with  ru status ; download it with setup_ru.bat, or use  ru model auto\n'], ...
            want, strjoin(M, ', '), md);
    end
end
cand = find(ok);
if isempty(cand)
    return
end
if strcmpi(want, 'auto') && ~needVision
    % Automatic choice uses the small, fast models only; a big model (e.g. qwen3.5:9b) is used only
    % when chosen with  ru model <name>. The old ru_engine copy is never chosen automatically.
    small = cand(arrayfun(@(i) ~local_isBigModel(M{i}, S(i)) && isempty(regexp(lower(M{i}), '^ru_engine', 'once')), cand));
    if ~isempty(small)
        cand = small;
    end
end
score = zeros(1, numel(cand));
for j = 1:numel(cand)
    score(j) = local_modelScore(M{cand(j)}, purpose);
end
[~, o] = sort(score, 'descend');
cand = cand(o);
mem = local_memBudget(root, H);
need = zeros(1, numel(M));
for i = cand
    need(i) = max(local_memNeed(M{i}, S(i), min(16384, infos{i}.ctx)), local_modelStat(root, M{i}, 'needGB'));
end
for i = cand
    remote = ~local_isLocalHost(H{i});
    loaded = any(strcmp(mem.loaded, M{i}));
    if remote || loaded || isnan(mem.avail) || S(i) == 0
        k = i;
        why = 'automatic, already in memory';
        if remote
            why = 'on another computer (ru host)';
        elseif isnan(mem.avail) || S(i) == 0
            why = 'strongest installed model';
        end
        break
    end
    failedAt = local_modelStat(root, M{i}, 'failFree');
    if need(i) <= mem.avail && ~(failedAt > 0 && mem.avail <= failedAt + 0.5)
        k = i;
        why = sprintf('automatic: the best model that fits, needs ~%.1f GB, %.1f GB free', need(i), mem.avail);
        break
    end
end
if k == 0
    [~, j] = min(S(cand));
    k = cand(j);
    if needVision && ~isnan(mem.total) && need(k) > mem.total - 1
        local_engineProblem(sprintf(['reading pictures needs %s (~%.1f GB memory), but this PC has only ' ...
            '%.1f GB'], M{k}, need(k), mem.total));
        k = 0;
        return
    end
    why = sprintf('smallest model; only %.1f GB memory is free', mem.avail);
    if ~any(strcmp(noted, 'lowmem'))
        noted{end+1} = 'lowmem';
        local_err('[ru] Only %.1f GB memory is free; using %s. Close other programs for faster, better answers.\n', ...
            mem.avail, M{k});
    end
    return
end
best = cand(1);
if k ~= best && local_isLocalHost(H{best}) && ~isnan(mem.total) && need(best) > mem.avail ...
        && need(best) <= mem.total - 2 && ~any(strcmp(noted, ['close:' M{best}]))
    noted{end+1} = ['close:' M{best}];
    local_err('[ru] Close other programs to let ru use the stronger %s (needs ~%.1f GB, %.1f GB free now).\n', ...
        M{best}, need(best), mem.avail);
end
end

function mem = local_memBudget(root, H)
% Memory the engine can use now: free RAM + free memory of the dedicated graphics card(s),
% plus what the models already loaded on the local engines occupy.
hw = local_hw(root);
mem = struct('avail', hw.ramFree, 'total', hw.ramTotal, 'loaded', {{}});
prof = local_profile(root);
if ~prof.cpuOnly && ~strcmpi(local_setting(root, 'gpu', 'auto'), 'off')
    G = local_gpuList(prof);
    for g = 1:numel(G)
        if G(g).used
            mem.avail = mem.avail + G(g).free;
            mem.total = mem.total + G(g).total;
        end
    end
end
done = {};
for i = 1:numel(H)
    if ~local_isLocalHost(H{i}) || any(strcmp(done, H{i}))
        continue
    end
    done{end+1} = H{i}; %#ok<AGROW>
    L = local_loaded(H{i});
    for j = 1:numel(L)
        mem.loaded{end+1} = L(j).name;
        mem.avail = mem.avail + L(j).size / 2^30;
    end
end
end

function need = local_memNeed(name, bytes, ctx)
% Rough memory a model needs (GB): weights + attention cache for the context + working buffers.
gb = bytes / 2^30;
tok = regexp(lower(name), '(\d+(?:\.\d+)?)b(?![a-z])', 'tokens', 'once');
if ~isempty(tok)
    params = str2double(tok{1});
else
    params = gb / 0.6;
end
kvPerToken = 40e3;
if params >= 6
    kvPerToken = 70e3;
end
need = gb + ctx * kvPerToken / 2^30 + 0.8;
end

function k = local_pickModel(M, infos, want, purpose)
% Model preference without memory information (used by ru status for other engines).
k = 0;
needVision = strcmp(purpose, 'vision');
if ~isempty(want) && ~strcmpi(want, 'auto')
    for i = 1:numel(M)
        if local_sameModel(want, M{i})
            k = i;
            return
        end
    end
end
best = -Inf;
for i = 1:numel(M)
    if needVision && ~any(strcmp(infos{i}.caps, 'vision'))
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

function tf = local_isBigModel(name, bytes)
% 6 billion parameters or more (qwen3.5:9b, qwen2.5-coder:7b, ...): only used when chosen by name.
tok = regexp(lower(name), '(\d+(?:\.\d+)?)b(?![a-z])', 'tokens', 'once');
if ~isempty(tok)
    tf = str2double(tok{1}) >= 6;
else
    tf = bytes > 5e9;
end
end

function v = local_modelChoice(root, key)
% The model chosen for THIS PC with  ru model / ru vision  ('auto' when none was chosen).
P = local_profile(root);
v = 'auto';
if isfield(P, key) && ischar(P.(key)) && ~isempty(strtrim(P.(key)))
    v = strtrim(P.(key));
end
end

function names = local_installedNames(root)
% Models this ru can use: those of the running engines plus the complete ones on the pendrive.
[~, names] = local_findModels(local_hosts(root));
P = local_pendriveModels(root);
for k = 1:numel(P)
    if P(k).complete && ~any(cellfun(@(n) local_sameModel(n, P(k).name), names))
        names{end+1} = P(k).name; %#ok<AGROW>
    end
end
names = unique(names);
end

function d = local_editDistance(a, b)
a = lower(a);
b = lower(b);
d = 0:numel(b);
for i = 1:numel(a)
    prev = d;
    d(1) = i;
    for j = 1:numel(b)
        d(j+1) = min([prev(j+1) + 1, d(j) + 1, prev(j) + (a(i) ~= b(j))]);
    end
end
d = d(end);
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

% ---------------------------------------------------------------------
% This PC: hardware, and what ru learned about it (brain\pc_<name>.json)
% ---------------------------------------------------------------------

function hw = local_hw(root) %#ok<INUSD>
% Operating system, processor, cores and memory of this PC (free memory is measured on every call).
persistent H
if isempty(H)
    H = struct('pc', '', 'os', '', 'osMajor', 0, 'osBuild', 0, 'cpu', '', 'cores', 0, 'threads', 0);
    if ispc
        H.pc = getenv('COMPUTERNAME');
    else
        H.pc = getenv('HOSTNAME');
        if isempty(H.pc)
            [~, h] = system('hostname');
            H.pc = strtrim(h);
        end
    end
    if ispc
        H.os = 'Windows';
        try
            [~, v] = system('ver');
            t = regexp(v, '(\d+)\.(\d+)\.(\d+)', 'tokens', 'once');
            if ~isempty(t)
                maj = str2double(t{1});
                mnr = str2double(t{2});
                H.osBuild = str2double(t{3});
                H.osMajor = maj;
                if maj >= 10 && H.osBuild >= 22000
                    H.os = sprintf('Windows 11 (build %d)', H.osBuild);
                elseif maj >= 10
                    H.os = sprintf('Windows 10 (build %d)', H.osBuild);
                elseif maj == 6 && mnr == 3
                    H.os = 'Windows 8.1';
                elseif maj == 6 && mnr == 2
                    H.os = 'Windows 8';
                elseif maj == 6 && mnr == 1
                    H.os = 'Windows 7';
                else
                    H.os = sprintf('Windows %d.%d', maj, mnr);
                end
            end
        catch
        end
        try
            H.cpu = strtrim(winqueryreg('HKEY_LOCAL_MACHINE', ...
                'HARDWARE\DESCRIPTION\System\CentralProcessor\0', 'ProcessorNameString'));
        catch
            H.cpu = getenv('PROCESSOR_IDENTIFIER');
        end
        H.threads = str2double(getenv('NUMBER_OF_PROCESSORS'));
    else
        if ismac
            H.os = 'macOS';
        else
            H.os = 'Linux';
        end
        try
            t = regexp(fileread('/proc/cpuinfo'), 'model name\s*:\s*([^\n]+)', 'tokens', 'once');
            H.cpu = strtrim(t{1});
        catch
        end
        try
            [~, n] = system('nproc');
            H.threads = str2double(n);
        catch
        end
    end
    try
        n = 0;
        evalc('n = feature(''numcores'');');       % evalc: feature() prints diagnostics
        H.cores = n;
    catch
        H.cores = H.threads;
    end
    if isnan(H.threads) || H.threads < H.cores
        H.threads = H.cores;
    end
    H.cpu = regexprep(H.cpu, '\s+', ' ');
end
hw = H;
[hw.ramTotal, hw.ramFree] = local_ram();
end

function [total, free] = local_ram()
% Physical memory (GB): total and free now.
total = NaN;
free = NaN;
test = getenv('RU_TEST_RAM');                    % "total,free" (tests only)
if ~isempty(test)
    v = str2double(strsplit(test, ','));
    total = v(1);
    free = v(2);
    return
end
if ispc && ~exist('OCTAVE_VERSION', 'builtin')
    try
        [~, sys] = memory;
        total = sys.PhysicalMemory.Total / 2^30;
        free = sys.PhysicalMemory.Available / 2^30;
        return
    catch
    end
end
try
    t = fileread('/proc/meminfo');
    a = regexp(t, 'MemTotal:\s*(\d+)', 'tokens', 'once');
    b = regexp(t, 'MemAvailable:\s*(\d+)', 'tokens', 'once');
    total = str2double(a{1}) / 2^20;
    free = str2double(b{1}) / 2^20;
catch
end
end

function id = local_pcId(root)
hw = local_hw(root);
id = regexprep(hw.pc, '[^\w-]', '_');
if isempty(id)
    id = 'this_pc';
end
end

function P = local_profile(root, P)
% What ru learned about this PC: graphics devices and policy, model memory failures, speed.
persistent cache cacheFile
f = fullfile(local_brain(root), ['pc_' local_pcId(root) '.json']);
if nargin > 1
    try
        local_writeText(f, jsonencode(P));
    catch
    end
    cache = P;
    cacheFile = f;
    return
end
if ~isempty(cache) && strcmp(cacheFile, f)
    P = cache;
    return
end
P = struct('gpuChecked', false, 'cpuOnly', false, 'gpuEnv', struct(), 'gpus', [], 'models', [], ...
    'model', 'auto', 'vision', 'auto');
if exist(f, 'file') == 2
    try
        r = jsondecode(local_readText(f));
        fn = fieldnames(P);
        for k = 1:numel(fn)
            if isfield(r, fn{k})
                P.(fn{k}) = r.(fn{k});
            end
        end
    catch
    end
end
if ~isstruct(P.gpuEnv)
    P.gpuEnv = struct();
end
if ~ischar(P.model) || isempty(P.model)
    P.model = 'auto';
end
if ~ischar(P.vision) || isempty(P.vision)
    P.vision = 'auto';
end
P.gpuChecked = isequal(P.gpuChecked, true) || isequal(P.gpuChecked, 1);
P.cpuOnly = isequal(P.cpuOnly, true) || isequal(P.cpuOnly, 1);
cache = P;
cacheFile = f;
end

function v = local_modelStat(root, model, field, value)
% Read (3 inputs) or write (4 inputs) one number about a model on this PC.
P = local_profile(root);
v = 0;
idx = 0;
if isstruct(P.models)
    for k = 1:numel(P.models)
        if isfield(P.models(k), 'name') && strcmp(P.models(k).name, model)
            idx = k;
            break
        end
    end
end
if nargin < 4
    if idx > 0 && isfield(P.models(idx), field) && isnumeric(P.models(idx).(field)) && ~isempty(P.models(idx).(field))
        v = double(P.models(idx).(field));
    end
    return
end
e = struct('name', model, 'failFree', 0, 'needGB', 0, 'pp', 0, 'tg', 0, 'load', 0);
if idx > 0
    old = P.models(idx);
    f = fieldnames(e);
    for k = 2:numel(f)
        if isfield(old, f{k}) && isnumeric(old.(f{k})) && ~isempty(old.(f{k}))
            e.(f{k}) = double(old.(f{k}));
        end
    end
end
e.(field) = value;
if ~isstruct(P.models) || isempty(P.models)
    P.models = e;
elseif idx > 0
    list = num2cell(P.models);
    list{idx} = e;
    P.models = local_structList(list, e);
else
    list = [num2cell(P.models(:)'), {e}];
    P.models = local_structList(list, e);
end
local_profile(root, P);
v = value;
end

function S = local_structList(list, template)
% Cell of structs -> struct array with the template's fields.
f = fieldnames(template);
S = repmat(template, 1, numel(list));
for k = 1:numel(list)
    for j = 1:numel(f)
        if isfield(list{k}, f{j})
            S(k).(f{j}) = list{k}.(f{j});
        end
    end
end
end

function G = local_gpuList(prof)
% Graphics devices found by the engine (from the profile) and whether ru lets the engine use them.
G = struct('name', {}, 'library', {}, 'total', {}, 'free', {}, 'integrated', {}, 'used', {});
g = prof.gpus;
if isempty(g) || ~isstruct(g)
    return
end
off = isfield(prof.gpuEnv, 'OLLAMA_VULKAN') && strcmp(prof.gpuEnv.OLLAMA_VULKAN, '0');
for k = 1:numel(g)
    e = struct('name', '', 'library', '', 'total', 0, 'free', 0, 'integrated', false, 'used', true);
    f = fieldnames(e);
    for j = 1:numel(f)
        if isfield(g(k), f{j})
            e.(f{j}) = g(k).(f{j});
        end
    end
    e.integrated = isequal(e.integrated, true) || isequal(e.integrated, 1);
    e.used = ~(off && strcmpi(e.library, 'vulkan')) && ~prof.cpuOnly;
    G(end+1) = e; %#ok<AGROW>
end
end

function G = local_parseGpus(logText, ramTotal)
% "inference compute" lines of the Ollama log -> graphics devices (CPU lines are skipped).
G = struct('name', {}, 'library', {}, 'total', {}, 'free', {}, 'integrated', {});
lines = regexp(logText, '[^\n]*inference compute[^\n]*', 'match');
for k = 1:numel(lines)
    kv = regexp(lines{k}, '(\w+)=("[^"]*"|\S+)', 'tokens');
    m = struct();
    for j = 1:numel(kv)
        m.(kv{j}{1}) = regexprep(kv{j}{2}, '^"|"$', '');
    end
    if ~isfield(m, 'library') || strcmpi(m.library, 'cpu')
        continue
    end
    name = '';
    if isfield(m, 'description')
        name = m.description;
    elseif isfield(m, 'name')
        name = m.name;
    end
    e = struct('name', name, 'library', lower(m.library), 'total', 0, 'free', 0, 'integrated', false);
    if isfield(m, 'total')
        e.total = local_parseGiB(m.total);
    end
    if isfield(m, 'available')
        e.free = local_parseGiB(m.available);
    end
    typ = '';
    if isfield(m, 'type')
        typ = lower(m.type);
    end
    % The type field is not reliable on hybrid laptops; the device name decides first.
    intelIgpu = ~isempty(regexpi(name, 'intel', 'once')) && isempty(regexpi(name, 'arc\S*\s*(\(tm\)\s*)?[ab]\d{3}', 'once'));
    amdApu = ~isempty(regexpi(name, 'radeon\S*\s*(\(tm\)\s*)?(\d{3,4}m\s*)?graphics|vega\s*\d*\s*graphics', 'once'));
    soft = ~isempty(regexpi(name, 'llvmpipe|basic render|swiftshader|microsoft', 'once'));
    shared = ~isnan(ramTotal) && e.total > 0.6 * ramTotal;
    e.integrated = intelIgpu || amdApu || soft || any(strcmp(typ, {'igpu', 'integrated'})) || ...
        (shared && ~strcmp(e.library, 'cuda'));
    G(end+1) = e; %#ok<AGROW>
end
end

function g = local_parseGiB(s)
t = regexp(s, '([\d.]+)\s*([KMGT]?i?B)', 'tokens', 'once');
g = 0;
if isempty(t)
    return
end
g = str2double(t{1});
switch upper(t{2}(1))
    case 'K'
        g = g / 2^20;
    case 'M'
        g = g / 2^10;
    case 'T'
        g = g * 2^10;
end
end

function [genv, changed] = local_gpuPolicy(G)
% Which graphics devices the engine may use. NVIDIA cards run through CUDA; dedicated AMD/other
% cards through Vulkan. Integrated graphics are switched off: they share the PC's RAM (no memory
% gain) and old Intel/AMD drivers can make the AI slower or write garbage.
genv = struct();
changed = false;
if isempty(G)
    return
end
lib = {G.library};
isVk = strcmp(lib, 'vulkan');
if ~any(isVk)
    return
end
if any(strcmp(lib, 'cuda')) || any([G(isVk).integrated])
    genv.OLLAMA_VULKAN = '0';
    genv.GGML_VK_VISIBLE_DEVICES = '-1';
    changed = true;
end
end

% ---------------------------------------------------------------------
% Starting and stopping the pendrive engine
% ---------------------------------------------------------------------

function ok = local_startEngine(root, cpuOnly)
% Start the pendrive's Ollama on port 11435 with settings that suit this PC. Its log goes to
% brain\engine.log (graphics devices, errors).
ok = false;
hw = local_hw(root);
if ispc && hw.osMajor > 0 && hw.osMajor < 10
    local_engineProblem(sprintf(['this PC runs %s, but the AI engine (Ollama) needs Windows 10 or newer. ' ...
        'Use a Windows 10/11 PC, or run the engine on another PC and connect with: ru host <its IP address>'], hw.os));
    return
end
exe = local_findOllama(root);
if isempty(exe)
    local_engineProblem(['the AI engine (Ollama) is not on the pendrive: run setup_ru.bat once on a PC with ' ...
        'internet (it puts it in the "ollama" folder)']);
    return
end
prof = local_profile(root);
mode = lower(local_setting(root, 'gpu', 'auto'));
env = {'OLLAMA_HOST', '127.0.0.1:11435'; 'OLLAMA_NOPRUNE', '1'; 'OLLAMA_KEEP_ALIVE', '60m'; ...
    'OLLAMA_MAX_LOADED_MODELS', '1'; 'OLLAMA_NUM_PARALLEL', '1'; 'OLLAMA_LOAD_TIMEOUT', '30m'};
md = local_modelsDir(root);
if ~isempty(md)
    env(end+1, :) = {'OLLAMA_MODELS', md};
end
cpu = cpuOnly || strcmp(mode, 'off') || (strcmp(mode, 'auto') && prof.cpuOnly);
if cpu
    env = [env; {'CUDA_VISIBLE_DEVICES', '-1'; 'HIP_VISIBLE_DEVICES', '-1'; 'ROCR_VISIBLE_DEVICES', '-1'; ...
        'OLLAMA_VULKAN', '0'; 'GGML_VK_VISIBLE_DEVICES', '-1'}];
elseif strcmp(mode, 'auto')
    f = fieldnames(prof.gpuEnv);
    for i = 1:numel(f)
        env(end+1, :) = {f{i}, char(prof.gpuEnv.(f{i}))}; %#ok<AGROW>
    end
end
logf = fullfile(local_brain(root), 'engine.log');
if exist(logf, 'file') == 2
    try
        delete(logf);
    catch
    end
end
old = cell(size(env, 1), 1);
for i = 1:size(env, 1)
    old{i} = getenv(env{i, 1});
    setenv(env{i, 1}, env{i, 2});
end
st = 0;
out = '';
try
    if ispc
        % A small launcher file avoids quoting problems with spaces or & in the pendrive path.
        bat = fullfile(local_brain(root), 'ru_engine.bat');
        local_writeText(bat, sprintf(['@echo off\r\nchcp 65001 >nul\r\ntitle ru engine - close this window to stop the AI\r\n' ...
            '"%s" serve > "%s" 2>&1\r\n'], exe, logf));
        [st, out] = system(sprintf('start "ru engine" /min "%s"', bat));
    else
        [st, out] = system(sprintf('"%s" serve > "%s" 2>&1 &', exe, logf));
    end
catch err
    st = 1;
    out = err.message;
end
for i = 1:size(env, 1)
    setenv(env{i, 1}, old{i});
end
if st ~= 0 || ~isempty(regexpi(out, 'blocked|denied|group policy|cannot find|not recognized', 'once'))
    local_engineProblem(sprintf(['Windows did not start the AI engine (%s). This PC may block programs on USB ' ...
        'drives; ask the lab administrator'], strtrim(out)));
    return
end
t0 = tic;
while toc(t0) < 180
    pause(1);
    if local_ping(local_pendHost())
        ok = true;
        break
    end
    if toc(t0) > 20 && ~local_engineRunning()
        txt = local_readText(logf);
        if isempty(strtrim(txt))
            local_engineProblem(['Windows stopped ollama.exe right after it started: antivirus or the lab''s ' ...
                'policy blocks programs on USB drives. ru cannot run the AI on this PC']);
        else
            last = regexp(txt, '[^\n]*(Error|error|panic|fatal)[^\n]*', 'match');
            if isempty(last)
                last = {local_firstLine(txt)};
            end
            local_engineProblem(['the AI engine stopped: ' strtrim(last{end})]);
        end
        return
    end
end
if ~ok
    local_engineProblem('the AI engine did not answer within 3 minutes (see brain\engine.log)');
    return
end
local_engineProblem('');
if ~cpu && strcmp(mode, 'auto') && ~prof.gpuChecked
    % First start on this PC: see which graphics devices the engine found and apply the policy.
    txt = '';
    t1 = tic;
    while toc(t1) < 25
        txt = local_readText(logf);
        if ~isempty(regexp(txt, 'inference compute', 'once'))
            pause(1);
            txt = local_readText(logf);
            break
        end
        pause(1);
    end
    if isempty(regexp(txt, 'inference compute', 'once'))
        return                                   % devices not listed yet: check again at the next start
    end
    G = local_parseGpus(txt, hw.ramTotal);
    [genv, changed] = local_gpuPolicy(G);
    prof = local_profile(root);
    prof.gpus = G;
    prof.gpuEnv = genv;
    prof.gpuChecked = true;
    local_profile(root, prof);
    if changed
        local_killEngine();
        ok = local_startEngine(root, false);
    end
end
end

function tf = local_engineRunning()
tf = true;
try
    if ispc
        [~, out] = system('tasklist /FI "IMAGENAME eq ollama.exe" /NH');
        tf = ~isempty(strfind(lower(out), 'ollama.exe'));
    else
        [st, ~] = system('pgrep -f "ollama serve" > /dev/null 2>&1');
        tf = st == 0;
    end
catch
end
end

function local_killEngine()
% End the pendrive engine (port 11435) together with its model runner processes.
try
    if ispc
        [~, out] = system('netstat -ano -p tcp');
        pid = regexp(out, '127\.0\.0\.1:11435\s+\S+\s+LISTENING\s+(\d+)', 'tokens', 'once');
        if isempty(pid)
            pid = regexp(out, '127\.0\.0\.1:11435\s+0\.0\.0\.0:0\s+\S+\s+(\d+)', 'tokens', 'once');
        end
        if ~isempty(pid)
            [~, ~] = system(sprintf('taskkill /F /T /PID %s', pid{1}));
        else
            [~, ~] = system(['powershell -NoProfile -Command "Get-NetTCPConnection -LocalPort 11435 -State Listen ' ...
                '-ErrorAction SilentlyContinue | ForEach-Object { Stop-Process -Id $_.OwningProcess -Force }"']);
        end
        pause(1);
        if local_ping(local_pendHost())
            % Last resort: every ollama.exe of this user (the PID lookup failed, e.g. another Windows language).
            [~, ~] = system('taskkill /F /T /IM ollama.exe');
        end
    else
        [~, ~] = system('fuser -k -TERM 11435/tcp > /dev/null 2>&1 || (lsof -ti tcp:11435 | xargs -r kill) > /dev/null 2>&1');
    end
catch
end
for k = 1:20
    pause(0.5);
    if ~local_ping(local_pendHost())
        break
    end
end
end

function ok = local_restartEngine(root, cpuOnly)
local_killEngine();
ok = local_startEngine(root, cpuOnly);
end

function local_stopEngine(root) %#ok<INUSD>
if ~local_ping(local_pendHost())
    fprintf('[ru] The pendrive engine (port 11435) is not running.\n');
    return
end
local_killEngine();
if local_ping(local_pendHost())
    fprintf(2, ['[ru] Could not stop it. It was probably started as administrator (for example by setup_ru.bat ' ...
        'run as administrator). Close its window ("ru engine" or "ru setup engine"), or restart the PC.\n']);
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
why = local_engineProblem();
if ~isempty(why)
    local_err('[ru] %s.\n', why);
end
local_err('[ru] Details: ru status\n');
end

% ---------------------------------------------------------------------
% Requests: one call with automatic recovery (memory, graphics driver, engine stopped)
% ---------------------------------------------------------------------

function [txt, cut, err, E] = local_llm(root, E, msgs, temperature, numPredict, think, numCtx)
if nargin < 7 || isempty(numCtx)
    numCtx = E.ctx;
end
txt = '';
cut = false;
err = '';
chars = sum(cellfun(@(m) numel(m.content), msgs));
logf = fullfile(local_brain(root), 'engine.log');
for tries = 1:3
    logPos = local_fileBytes(logf);
    timeout = local_timeout(root, E, chars, numPredict, think);
    [txt, cut, err, st] = local_chat(E.host, E.model, msgs, temperature, numCtx, numPredict, think, E.caps, timeout);
    own = local_isPendHost(E.host);
    if isempty(err)
        local_recordSpeed(root, E, st);
        if local_isGarbage(txt) && own && ~local_cpuMode(root) && tries < 3
            local_err('[ru] The graphics driver gave broken output; the AI now runs on the processor on this PC.\n');
            local_setCpuOnly(root);
            local_busy('ru: restarting the AI engine ...');
            local_restartEngine(root, true);
            continue
        end
        return
    end
    detail = err;
    if own
        detail = [err ' ' local_readTail(logf, logPos)];
    end
    kind = local_errorKind(detail);
    if strcmp(kind, 'memory') && tries < 3
        hw = local_hw(root);
        local_modelStat(root, E.model, 'failFree', hw.ramFree);
        req = regexp(detail, 'requires more \w+ memory \(([\d.]+)\s*GiB\)', 'tokens', 'once');
        if ~isempty(req)
            local_modelStat(root, E.model, 'needGB', str2double(req{1}));
        end
        E2 = local_engine(root, false, E.purpose, {E.model});
        if ~isempty(E2.model) && ~strcmp(E2.model, E.model)
            local_err('[ru] %s needs more memory than this PC has free now; using %s.\n', E.model, E2.model);
            E = E2;
            numCtx = E.ctx;
            continue
        end
    elseif strcmp(kind, 'crash') && own && ~local_cpuMode(root) && tries < 3
        local_err('[ru] The graphics driver stopped the AI engine; the AI now runs on the processor on this PC.\n');
        local_setCpuOnly(root);
        local_busy('ru: restarting the AI engine ...');
        local_restartEngine(root, true);
        continue
    elseif strcmp(kind, 'down') && local_isPendHost(E.host) && tries < 3
        local_busy('ru: restarting the AI engine ...');
        if local_startEngine(root, false)
            continue
        end
    end
    err = local_friendlyError(err, kind, E);
    return
end
end

function kind = local_errorKind(s)
kind = 'other';
if ~isempty(regexpi(s, ['requires more system memory|out of memory|not enough memory|insufficient memory|' ...
        'unable to allocate|failed to allocate|cudaMalloc|ErrorOutOfDeviceMemory|memory layout cannot be allocated'], 'once'))
    kind = 'memory';
elseif ~isempty(regexpi(s, ['runner process has terminated|runner process no longer running|llama runner|' ...
        'exit status|0xc0000|access violation|segmentation|vk::|vulkan|CUDA error|ggml_|GGML_ASSERT'], 'once'))
    kind = 'crash';
elseif ~isempty(regexpi(s, 'timed? ?out|timeout|did not respond', 'once'))
    kind = 'timeout';
elseif ~isempty(regexpi(s, 'connect|refused|reset|closed|resolve|No connection|unreachable', 'once'))
    kind = 'down';
elseif ~isempty(strfind(s, '404')) || ~isempty(regexpi(s, 'not found', 'once'))
    kind = 'missing';
end
end

function msg = local_friendlyError(err, kind, E)
switch kind
    case 'missing'
        msg = sprintf('the model "%s" was not found on %s. Run: ru status', E.model, E.host);
    case 'timeout'
        msg = sprintf(['%s did not finish in time on this PC. Close other programs and try again, or choose ' ...
            'a smaller model: ru model <name>'], E.model);
    case 'memory'
        msg = sprintf('not enough free memory for %s: close other programs, or choose a smaller model: ru model <name>', E.model);
    case 'down'
        msg = 'the AI engine stopped running. Run: ru start';
    case 'crash'
        msg = ['the AI engine crashed (' local_firstLine(err) '). Try: ru gpu off'];
    otherwise
        msg = err;
end
end

function t = local_readTail(f, fromByte)
% Text appended to a file after byte position fromByte.
t = '';
try
    fid = fopen(f, 'r');
    if fid < 0
        return
    end
    fseek(fid, fromByte, 'bof');
    t = fread(fid, [1 Inf], '*char');
    fclose(fid);
catch
end
end

function tf = local_isGarbage(txt)
% Output of a broken graphics driver: almost no letters/digits, long runs of one character,
% or mostly non-ASCII noise.
t = strtrim(txt);
tf = false;
if numel(t) < 40
    return
end
alnum = mean(isstrprop(t, 'alphanum'));
nonAscii = mean(double(t) > 127);
tf = alnum < 0.25 || nonAscii > 0.3 || ~isempty(regexp(t, '(.)\1{40,}', 'once'));
end

function tf = local_cpuMode(root)
P = local_profile(root);
tf = P.cpuOnly || strcmpi(local_setting(root, 'gpu', 'auto'), 'off');
end

function local_setCpuOnly(root)
P = local_profile(root);
P.cpuOnly = true;
local_profile(root, P);
end

function local_recordSpeed(root, E, st)
% Remember how fast this PC reads (prompt) and writes (answer) with this model.
if ~local_isLocalHost(E.host)
    return
end
if st.pp > 0 && st.promptN >= 200
    local_modelStat(root, E.model, 'pp', local_avg(local_modelStat(root, E.model, 'pp'), st.pp));
end
if st.tg > 0 && st.genN >= 20
    local_modelStat(root, E.model, 'tg', local_avg(local_modelStat(root, E.model, 'tg'), st.tg));
end
if st.load > 1
    local_modelStat(root, E.model, 'load', st.load);
end
end

function v = local_avg(old, new)
if old > 0
    v = 0.5 * old + 0.5 * new;
else
    v = new;
end
end

function t = local_timeout(root, E, chars, numPredict, think)
% Seconds to wait for one answer: from this PC's measured speed (generous), else one hour.
pp = local_modelStat(root, E.model, 'pp');
tg = local_modelStat(root, E.model, 'tg');
if pp > 0 && tg > 0
    t = 1.5 * ((chars / 3) / pp + numPredict / tg) + 300;
else
    t = 3600;
end
t = min(max(t, 900), 3 * 3600);
if think
    t = min(2 * t, 4 * 3600);
end
end

function o = local_options(temperature, numCtx, numPredict)
o = struct('temperature', temperature, 'num_ctx', numCtx, 'num_predict', numPredict, ...
    'top_p', 0.9, 'top_k', 40, 'seed', 42);
end

function [txt, cut, err, st] = local_chat(host, model, msgs, temperature, numCtx, numPredict, think, caps, timeout)
txt = '';
cut = false;
err = '';
st = struct('pp', 0, 'tg', 0, 'load', 0, 'promptN', 0, 'genN', 0);
body = struct('model', model, 'stream', false, 'keep_alive', '60m');
body.messages = msgs;
body.options = local_options(temperature, numCtx, numPredict);
if any(strcmp(caps, 'thinking'))
    body.think = logical(think);
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
        break
    end
end
if ~isempty(err)
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
st.promptN = local_num(r, 'prompt_eval_count');
st.genN = local_num(r, 'eval_count');
d = local_num(r, 'prompt_eval_duration') / 1e9;
if d > 0
    st.pp = st.promptN / d;
end
d = local_num(r, 'eval_duration') / 1e9;
if d > 0
    st.tg = st.genN / d;
end
st.load = local_num(r, 'load_duration') / 1e9;
end

function v = local_num(r, f)
v = 0;
if isstruct(r) && isfield(r, f) && isnumeric(r.(f)) && ~isempty(r.(f))
    v = double(r.(f));
end
end

function local_warmup(root, E, sys)
% Load the model and read the fixed part of the prompt in the background (while the user types),
% with exactly the options the real requests use, so nothing has to be loaded twice.
if isempty(E.model) || ~local_isLocalHost(E.host)
    return
end
L = local_loaded(E.host);
if any(strcmp({L.name}, E.model))
    return
end
body = struct('model', E.model, 'stream', false, 'keep_alive', '60m');
body.messages = {local_msg('system', sys)};
body.options = local_options(0.1, E.ctx, 1);
if any(strcmp(E.caps, 'thinking'))
    body.think = false;
end
f = fullfile(local_brain(root), 'warmup.json');
local_writeText(f, jsonencode(body));
url = [E.host '/api/chat'];
try
    if ispc && ~exist('OCTAVE_VERSION', 'builtin')
        curl = fullfile(getenv('SystemRoot'), 'System32', 'curl.exe');
        if exist(curl, 'file') ~= 2 || ~usejava('jvm')
            return
        end
        pb = java.lang.ProcessBuilder({curl, '-s', '-m', '3600', '-o', 'NUL', '-H', 'Content-Type: application/json', ...
            '--data-binary', ['@' f], url});
        pb.redirectErrorStream(true);
        pb.redirectOutput(java.io.File(fullfile(local_brain(root), 'warmup.log')));
        pb.start();
    else
        [~, ~] = system(sprintf(['curl -s -m 3600 -o /dev/null -H "Content-Type: application/json" ' ...
            '--data-binary "@%s" "%s" > /dev/null 2>&1 &'], f, url));
    end
catch
end
end

% =====================================================================
% Status, model selection, settings
% =====================================================================

function local_status(root)
env = local_env();
kb = local_kb(root);
hw = local_hw(root);
prof = local_profile(root);
fprintf('\n== ru status ==\n');
fprintf('PC              : %s, %s\n', hw.pc, hw.os);
fprintf('Processor       : %s (%d cores, %d threads)\n', hw.cpu, hw.cores, hw.threads);
if ~isnan(hw.ramTotal)
    fprintf('Memory (RAM)    : %.1f GB, %.1f GB free now\n', hw.ramTotal, hw.ramFree);
end
gmode = lower(local_setting(root, 'gpu', 'auto'));
G = local_gpuList(prof);
if strcmp(gmode, 'off') || prof.cpuOnly
    why = 'ru gpu off';
    if prof.cpuOnly && ~strcmp(gmode, 'off')
        why = 'the graphics driver failed here before; ru gpu auto tries again';
    end
    fprintf('Graphics        : not used, the AI runs on the processor (%s)\n', why);
elseif ~prof.gpuChecked
    fprintf('Graphics        : not checked yet (it is checked the first time the engine starts: ru start)\n');
elseif isempty(G)
    fprintf('Graphics        : no graphics card the AI engine can use: it runs on the processor\n');
else
    for g = 1:numel(G)
        kind = 'dedicated';
        if G(g).integrated
            kind = 'integrated';
        end
        use = 'used together with the processor';
        if ~G(g).used
            use = 'not used (integrated graphics share the RAM and old drivers give wrong output)';
            if ~G(g).integrated
                use = 'not used (the NVIDIA card runs through CUDA instead)';
            end
        end
        fprintf('Graphics        : %s (%s, %s, %.1f GB, %.1f GB free) - %s\n', G(g).name, upper(G(g).library), ...
            kind, G(g).total, G(g).free, use);
    end
end
fprintf('GPU setting     : %s  (ru gpu auto | on | off)\n', gmode);
fprintf('MATLAB          : %s\n', version);
fprintf('%s\n', env.toolboxLine(1:find(env.toolboxLine == '.', 1)));
fprintf('Solver library  : %d functions (ru_lib)\n', numel(kb.lib));
fprintf('Knowledge base  : %d topics, %d verified solved examples (ru_kb)\n', numel(kb.topics), numel(kb.examples));
fprintf('Your M-files    : %d\n', numel(kb.userFiles));
fprintf('Conversation    : %d turns remembered (ru history / ru new)\n', numel(local_convLoad(root)));
fprintf('Output          : %s  (ru verbose on | off)\n', regexprep(local_setting(root, 'verbose', 'off'), '^$', 'off'));
exe = local_findOllama(root);
if isempty(exe)
    fprintf(2, 'Ollama program  : NOT FOUND (run setup_ru.bat on a PC with internet)\n');
else
    fprintf('Ollama program  : %s\n', exe);
end
if ispc && hw.osMajor > 0 && hw.osMajor < 10
    fprintf(2, 'Windows         : %s is too old for the AI engine (needs Windows 10+). Verified examples still work.\n', hw.os);
end
md = local_modelsDir(root);
if isempty(md)
    fprintf(2, 'Models folder   : NOT FOUND (expected %s)\n', fullfile(root, 'model'));
else
    fprintf('Models folder   : %s\n', md);
end
mem = local_memBudget(root, {local_pendHost()});
P = local_pendriveModels(root);
for k = 1:numel(P)
    if ~P(k).complete
        fprintf(2, '  model %-22s INCOMPLETE - missing file(s): %s\n', P(k).name, strjoin(P(k).missing, ', '));
        continue
    end
    need = local_memNeed(P(k).name, P(k).bytes, 16384);
    if any(strcmp(mem.loaded, P(k).name))
        fit = 'loaded now';
    elseif isnan(mem.avail) || need <= mem.avail
        fit = 'fits in the free memory';
    elseif ~isnan(mem.total) && need <= mem.total - 2
        fit = 'fits if you close other programs';
    else
        fit = 'too big for this PC';
    end
    fprintf('  model %-22s %.1f GB, needs ~%.1f GB: %s', P(k).name, P(k).bytes / 1e9, need, fit);
    pp = local_modelStat(root, P(k).name, 'pp');
    tg = local_modelStat(root, P(k).name, 'tg');
    if pp > 0 && tg > 0
        fprintf(' | here it reads %.0f and writes %.1f tokens/s', pp, tg);
    end
    fprintf('\n');
end
hosts = local_hosts(root);
for k = 1:numel(hosts)
    if local_ping(hosts{k})
        names = local_tags(hosts{k}, 3);
        if isempty(names)
            names = {'(no models)'};
        end
        fprintf('Engine %-24s: running, models: %s\n', hosts{k}, strjoin(names, ', '));
        L = local_loaded(hosts{k});
        for j = 1:numel(L)
            gpuPct = 0;
            if L(j).size > 0
                gpuPct = round(100 * L(j).vram / L(j).size);
            end
            fprintf('  in memory     : %s, %.1f GB, %d%% on the graphics card, %d%% on the processor', ...
                L(j).name, L(j).size / 2^30, gpuPct, 100 - gpuPct);
            if L(j).ctx > 0
                fprintf(', context %d', L(j).ctx);
            end
            fprintf('\n');
        end
    else
        fprintf('Engine %-24s: not running\n', hosts{k});
    end
end
why = local_engineProblem();
if ~isempty(why)
    fprintf(2, 'Engine problem  : %s\n', why);
end
fprintf('Model on this PC: text %s, vision %s  (ru model <name|auto>, ru vision <name|auto>)\n', ...
    local_modelChoice(root, 'model'), local_modelChoice(root, 'vision'));
[H, M, S] = local_findModels(hosts);
if isempty(M)
    fprintf(2, 'ru will use     : nothing yet - run  ru start\n');
else
    infos = cell(1, numel(M));
    for k = 1:numel(M)
        infos{k} = local_modelInfo(H{k}, M{k});
    end
    [k, why] = local_chooseModel(root, H, M, S, infos, local_modelChoice(root, 'model'), 'text', {});
    if k > 0
        fprintf('Text model      : %s (%s)\n', M{k}, why);
    end
    [k, why] = local_chooseModel(root, H, M, S, infos, local_modelChoice(root, 'vision'), 'vision', {});
    if k == 0
        why = local_engineProblem();
        if isempty(why)
            why = 'ru img needs a vision model such as qwen3.5';
        end
        fprintf('Image model     : none (%s)\n', why);
    else
        fprintf('Image model     : %s (%s)\n', M{k}, why);
    end
end
fprintf('\n');
end

function local_settingCommand(root, key, value)
settingKey = key;
value = strtrim(value);
if strcmp(key, 'verbose')
    if isempty(value)
        fprintf('[ru] verbose: %s  (ru verbose on | off)\n', local_setting(root, 'verbose', 'off'));
        return
    end
    v = lower(value);
    if ~any(strcmp(v, {'on', 'off'}))
        fprintf(2, '[ru] Use: ru verbose on   or   ru verbose off\n');
        return
    end
    local_setSetting(root, 'verbose', v);
    if strcmp(v, 'on')
        fprintf('[ru] verbose on: every step, attempt, comment and timing is shown.\n');
    else
        fprintf('[ru] verbose off: only the MATLAB code and its output are shown.\n');
    end
    return
end
if strcmp(key, 'gpu')
    if isempty(value)
        fprintf('[ru] gpu: %s  (ru gpu auto | on | off); details: ru status\n', local_setting(root, 'gpu', 'auto'));
        return
    end
    v = lower(value);
    if ~any(strcmp(v, {'auto', 'on', 'off'}))
        fprintf(2, '[ru] Use: ru gpu auto (recommended) | ru gpu on (all graphics, also integrated) | ru gpu off (processor only)\n');
        return
    end
    local_setSetting(root, 'gpu', v);
    P = local_profile(root);
    P.cpuOnly = false;
    if strcmp(v, 'auto')
        P.gpuChecked = false;                 % detect the graphics devices again at the next start
        P.gpuEnv = struct();
    end
    local_profile(root, P);
    if local_ping(local_pendHost())
        fprintf('[ru] gpu %s: restarting the AI engine ...\n', v);
        local_restartEngine(root, false);
    else
        fprintf('[ru] gpu %s: used from the next engine start.\n', v);
    end
    return
end
if any(strcmp(key, {'model', 'vision'}))
    local_modelCommand(root, key, value);
    return
end
if isempty(value)
    fprintf('[ru] %s setting: %s\n', key, local_setting(root, settingKey, ''));
    return
end
local_setSetting(root, settingKey, strtrim(value));
fprintf('[ru] %s set to %s\n', key, strtrim(value));
end

function local_modelCommand(root, key, value)
% ru model <name|auto> / ru vision <name|auto>: chosen per PC (other PCs keep their own choice).
value = regexprep(strtrim(value), '^["'']|["'']$', '');
names = local_installedNames(root);
what = 'problems';
if strcmp(key, 'vision')
    what = 'pictures (ru img)';
end
if isempty(value)
    fprintf('[ru] Model for %s on this PC: %s\n', what, local_modelChoice(root, key));
    if isempty(names)
        fprintf('[ru] No model found (no engine running and none on the pendrive). Check: ru status\n');
    else
        fprintf('[ru] Installed models: %s\n', strjoin(names, ', '));
    end
    return
end
if strcmpi(value, 'auto')
    choice = 'auto';
else
    choice = '';
    hit = find(cellfun(@(n) local_sameModel(value, n), names), 1);
    if isempty(hit)
        % Short forms: "9b" or "coder" when exactly one installed model contains it.
        part = find(~cellfun(@isempty, strfind(lower(names), lower(value))));
        if numel(part) == 1
            hit = part;
        end
    end
    if ~isempty(hit)
        choice = names{hit};
    elseif isempty(names)
        choice = value;
        fprintf(2, '[ru] Could not check the name (no engine running, no model on the pendrive).\n');
    else
        fprintf(2, '[ru] "%s" is not installed. Installed models: %s\n', value, strjoin(names, ', '));
        dist = cellfun(@(n) local_editDistance(value, regexprep(n, ':latest$', '')), names);
        [dmin, j] = min(dist);
        if dmin <= 3
            fprintf(2, '[ru] Did you mean:  ru %s %s\n', key, names{j});
        end
        fprintf(2, '[ru] Nothing changed. To download a model run setup_ru.bat on a PC with internet.\n');
        return
    end
end
P = local_profile(root);
P.(key) = choice;
local_profile(root, P);
if strcmp(choice, 'auto')
    if strcmp(key, 'model')
        fprintf('[ru] Automatic on this PC: the best small model that fits (a big model such as qwen3.5:9b only when you choose it).\n');
    else
        fprintf('[ru] Automatic on this PC: the best vision model that fits.\n');
    end
else
    fprintf('[ru] This PC now uses %s for %s. Other PCs keep their own choice; back to automatic: ru %s auto\n', ...
        choice, what, key);
end
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

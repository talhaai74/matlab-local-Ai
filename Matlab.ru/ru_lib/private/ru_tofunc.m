function fh = ru_tofunc(f, vars)
%RU_TOFUNC  Convert a function handle, text expression or sym to a function handle.
%   fh = ru_tofunc(f)             f is a handle, 'x^2-3', "x^2-3", 'f(x) = x^2-3' or a sym
%   fh = ru_tofunc(f, {'t','y'})  argument names to use for a text expression
%   Text expressions are vectorized (* / ^ become .* ./ .^).
%   Private helper for the ru_lib functions.
if nargin < 2 || isempty(vars)
    vars = {};
end
if ischar(vars)
    vars = {vars};
end
if isa(f, 'function_handle')
    fh = f;
    return
end
if isa(f, 'sym')
    if isempty(vars)
        fh = matlabFunction(f);
    else
        fh = matlabFunction(f, 'Vars', sym(vars));
    end
    return
end
if isa(f, 'string')
    f = char(f);
end
if ~ischar(f)
    error('ru_lib:ru_tofunc:type', ...
        'Expected a function handle such as @(x) x.^2 - 3 or a text expression such as ''x^2 - 3''.');
end
expr = strtrim(f);
% Accept 'f(x) = expr' and 'y = expr': keep the right-hand side.
eqPos = regexp(expr, '(?<![=<>~])=(?!=)', 'once');
if ~isempty(eqPos)
    lhs = strtrim(expr(1:eqPos-1));
    expr = strtrim(expr(eqPos+1:end));
    argTok = regexp(lhs, '\(([^)]*)\)', 'tokens', 'once');
    if isempty(vars) && ~isempty(argTok)
        vars = strtrim(strsplit(argTok{1}, ','));
    end
end
if isempty(expr)
    error('ru_lib:ru_tofunc:empty', 'The function expression is empty.');
end
expr = regexprep(expr, '(?<!\.)([\*/\^])', '.$1');
if isempty(vars)
    vars = symvar(expr);
    if isempty(vars)
        vars = {'x'};
    end
end
vars = vars(:)';
fh = str2func(['@(' strjoin(vars, ',') ') ' expr]);
end

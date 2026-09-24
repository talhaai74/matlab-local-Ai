# ru: an offline MATLAB assistant on a pendrive (CE206)

`ru` runs inside the MATLAB Command Window of any Windows PC, with no internet.
You give it a problem as plain text and equations (or a screenshot). It writes a
MATLAB script, **runs it**, checks the result and repairs the code until it works.
The results stay in your workspace. It also remembers the conversation, so you can
ask follow-up questions.

```
>> cd E:\Matlab.ru
>> ru find the root of x^3 - 10*x^2 + 5 between 0 and 1 by bisection with es = 0.01%
>> ru now use false position instead and compare the iterations
>> ru img                      % solve the screenshot on the clipboard (Win+Shift+S)
>> ru ask why does Newton-Raphson diverge?
```

## Honest limits (read this first)

* **No AI can guarantee zero mistakes.** `ru` reduces them with checks that run
  real code (see *How ru avoids wrong answers*), but a small offline model still
  makes errors. For important answers, read the printed equations and checks.
* The model you run decides how strong ru is. `qwen2.5-coder:3b` (the model
  already on your pendrive) solves standard CE206 problems when a similar solved
  example exists, but fails on some problems that need restructuring.
  **`qwen3.5:4b` is recommended**: it also reads screenshots. `setup_ru.bat` downloads it.
* Screenshots of **figures** (trusses, beams) are described in words by the vision
  model and can be wrong: `ru img` always shows the text it read and lets you fix
  it before solving.
* A CPU-only PC takes 30 s to 3 min per answer. The first call loads the model
  from the pendrive (USB 3 is much faster than USB 2).

## Setup

**Once, on a Windows PC with internet**

1. Copy the `Matlab.ru` folder to the pendrive. Use a pendrive formatted as
   **exFAT or NTFS** if you want models larger than 4 GB (FAT32 cannot hold them).
2. If you still have the 1.8 GB file
   `sha256-4a188102020e9c9530b687fd6400f775c45e90a0d7baafe65bd0a36963fbb7ba`
   (the qwen2.5-coder:3b weights; too big for GitHub), copy it into
   `Matlab.ru\model\blobs\`. The other files of that model are already in the repository.
3. Double-click `Matlab.ru\setup_ru.bat`. It downloads the portable Ollama engine
   into `Matlab.ru\ollama` and the model(s) you pick into `Matlab.ru\model`.

**On any PC with MATLAB (offline)**

```
>> cd E:\Matlab.ru      % the pendrive letter may differ
>> ru status            % checks MATLAB, toolboxes, engine, models, RAM
>> ru help
```

`ru` starts the engine by itself (a minimized "ru engine" window; keep it open).
`ru stop` closes it and frees the memory.

## Models

| Model | Download | RAM needed | Reads images | Notes |
|---|---|---|---|---|
| qwen3.5:4b | 3.4 GB | 8 GB | yes | **recommended** |
| qwen2.5-coder:3b | 1.9 GB | 6 GB | no | already on your pendrive (weights file above) |
| qwen3.5:2b | 2.7 GB | 4–6 GB | yes | weak PCs |
| qwen2.5-coder:7b | 4.7 GB | 16 GB | no | needs exFAT/NTFS |
| qwen3.5:9b | 6.6 GB | 16 GB | yes | strongest; needs exFAT/NTFS |

`ru` picks the best installed model automatically. Force one with
`ru model qwen2.5-coder:3b` (text) or `ru vision qwen3.5:4b` (images);
`ru model auto` goes back to automatic. It also uses models from an Ollama
installed on the PC.

## Commands

| Command | What it does |
|---|---|
| `ru <problem>` | solve a problem typed on the same line |
| `ru` | box for long problems: paste text, equations, tables (several lines) |
| `ru('...')` | same, for text with quotes, commas or semicolons |
| `ru paste` | solve the text on the clipboard |
| `ru img [file] [note]` | read a problem from a screenshot/photo (clipboard image if no file) |
| `ru ask <question>` | theory answer in words |
| `ru explain` | explain the last code step by step |
| `ru fix [note]` | find the last error in *your* Command Window work and fix it |
| `ru again [hint]` | solve the last problem again with another approach |
| `ru think <problem>` | step-by-step reasoning mode (slower; qwen3.5 models) |
| `ru ai <problem>` | skip the stored verified solutions and ask the AI |
| `ru history [n]` / `ru new` | show / clear the conversation memory |
| `ru remember <rule>` / `ru rules` | permanent rules, e.g. `ru remember my student ID is 1904032` |
| `ru last` / `ru save <name>` | show / save the last code as `<name>.m` |
| `ru status` / `ru start` / `ru stop` | engine and model status, start, stop |
| `ru list` / `ru test` | list the solver library / run the offline self-test |
| `ru --retrieve <text>` | show which topic and solved examples ru would use (no AI call) |

MATLAB command syntax splits a line at commas and semicolons, so for problems
that contain them type just `ru` and paste into the box.

## How ru avoids wrong answers

1. **Verified solutions first.** `ru_kb/examples` holds 125 solved problems from
   the CE206 slides, the final-quiz solution (set A) and the Chapra practice
   problems. If you paste one of them (same numbers, same method), ru runs the
   stored, checked solution instead of asking the AI.
2. **Grounding.** For other problems the AI receives the closest solved examples,
   a cheat sheet for the topic and the documentation of the tested solver library
   (`ru_lib`: bisection, false position, Newton, secant, Gauss/LU/Thomas,
   regression, splines, Simpson/Romberg/Gauss, finite differences, Euler/Heun/RK4,
   shooting/finite-difference BVPs, power method, t-tests, ...).
3. **Everything is executed.** The script runs in MATLAB; errors go back to the AI
   with targeted hints (up to 4 attempts; when it repeats an error it restarts
   without the example that misled it).
4. **Checks before accepting a result:**
   * code that calls functions which do not exist on this computer is rejected
     (catches invented functions and missing toolboxes);
   * every method or MATLAB function the problem names (bisection, RK4,
     `integral`, `ode45`, LU, ...) must appear in the code;
   * every significant number in the problem must be used;
   * no output, `NaN`/`Inf`, infinite loops, `input()`, `clear`, `cd`, file
     deletion and system commands are refused;
   * the script must print the equations it used and an independent check
     (`fzero`, `integral`, `ode45`, residuals, analytical solution).
   Remaining doubts are printed as `[ru] Check: ...` lines.

## Memory

* **Conversation** (`brain\conversation.json`): the last 40 problems, codes and
  outputs. Short follow-ups ("now use h = 0.1", "plot it", "why?") reuse them.
  `ru history`, `ru new`.
* **Your Command Window**: ru keeps a session log (`brain\session_log.txt`) and
  reads MATLAB's command history, so `ru fix` sees the command and error you got.
* **Workspace**: variables you mention by name (or with "my data", "workspace")
  are described to the AI, and every solution leaves its variables in the workspace.
* **Rules** (`memory.txt`): permanent instructions, e.g. your student ID for quiz
  problems that depend on it.

## Folder layout

```
Matlab.ru\            <- copy this folder to the pendrive
  ru.m                main program
  ru_selftest.m       offline self-test (ru test)
  setup_ru.bat        one-time download of the portable Ollama and models
  start_ru.bat        optional manual engine start
  startup.m           optional: starts the session log when MATLAB starts here
  memory.txt          your permanent rules
  ru_lib\             tested numerical-methods library (used by the AI)
  ru_kb\topics\       cheat sheets per chapter
  ru_kb\examples\     125 verified solved examples
  ru_tests\           library tests
  Endfiles\           your own course M-files (ru can use them: "use my bisection function")
  model\              AI models (Ollama format); weights are not in git
  ollama\             portable Ollama (created by setup_ru.bat)
  brain\              memory, logs, settings, temporary scripts (created at run time)
Slides\               the CE206 slides and quiz PDFs the knowledge base was built from
```

## Adding your own solved example

Create `Matlab.ru\ru_kb\examples\ex_<topic>_<name>.m`:

```matlab
% TOPIC: roots
% TITLE: short description
% SOURCE: where it comes from
% KEYWORDS: words a student would use
% PROBLEM:
% The problem text exactly as you would paste it.
% CHECK: abs(xr - 1.2345) < 1e-4
% CODE:
... working MATLAB code that prints the answers ...
```

Then run `ru test`. Examples with `% SELFTEST: skip` (they need data files) are not run.

## Troubleshooting

| Symptom | Fix |
|---|---|
| `No AI model is available` | `ru status`; run `setup_ru.bat` on a PC with internet |
| `model ... INCOMPLETE - missing file(s)` | copy the missing `sha256-...` blob into `model\blobs` or re-run `setup_ru.bat` |
| very slow / timeout | close other programs; `ru model qwen2.5-coder:3b` or `qwen3.5:2b` |
| `ru img` says no vision model | install `qwen3.5:4b` with `setup_ru.bat` |
| wrong numbers read from a screenshot | correct them in the check box, or paste the text with `ru` |
| a result looks wrong | `ru again`, `ru think <problem>`, or state the method and all numbers explicitly |

## What was broken before, and what changed

* `ru.m` was **truncated** (it ended at a `% @@CHUNK5@@` marker; about 20 helper
  functions were missing) and began with `Function` instead of `function`, so
  MATLAB could not run it at all.
* The knowledge-base topics and `ru_selftest.m` it referenced did not exist.
* `start_ru.bat`/`ru.m` pointed at a `models` folder while the model lived in
  `Matlab.ru\model`; `Modelfile` was a broken batch fragment with a hard-coded `G:` path.
* Library bugs fixed: the power method returned the wrong eigenvalue when the
  start vector was itself an eigenvector; bisection/false position returned `NaN`
  when a bracket end was an exact root.

Tested here with GNU Octave 8.4 and the same qwen2.5-coder:3b weights served
through llama.cpp: `ru test` passes 213 checks (the `xlswrite` example needs
MATLAB). The qwen3.5 models and the Windows scripts could not be run in that
environment; they follow the official Ollama documentation.

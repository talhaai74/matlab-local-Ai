% Optional. MATLAB runs startup.m automatically only when this folder is the
% MATLAB startup folder (Home > Preferences > General > Initial working folder,
% or userpath). It starts ru's session log (brain\session_log.txt) so that
% "ru fix" can read the errors in your Command Window.
% You do not need it: typing any ru command also starts the log.
% Delete this file to switch the automatic log off.
try
    ru --startup
catch
end

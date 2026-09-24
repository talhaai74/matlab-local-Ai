% MATLAB runs this at start-up because G:\ru_portable is the userpath.
% It starts ru's session log (brain\diary), which lets "ru fix" find the
% command that failed. Delete this file to turn the log off.
try
    ru --startup
catch
end

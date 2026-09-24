function ru_print_ode_table(name, t, Y, m)
%RU_PRINT_ODE_TABLE  Print a fixed-step ODE solver's [t,y] as a table.
%   ru_print_ode_table(name, t, Y, m)
%   Private helper for ru_lib ODE solvers called with nargout == 0.
fprintf('%s results:\n', name);
fprintf('%6s  %12s', 'i', 't');
for k = 1:m
    fprintf('  %12s', sprintf('y%d', k));
end
fprintf('\n');
n = length(t);
for i = 1:n
    fprintf('%6d  %12.6f', i, t(i));
    for k = 1:m
        fprintf('  %12.6f', Y(i,k));
    end
    fprintf('\n');
end
fprintf('Final: t = %.6f\n', t(end));
end

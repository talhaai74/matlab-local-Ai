% TOPIC: eigen
% TITLE: Power method for the highest eigenvalue and inverse power method for the lowest
% SOURCE: Chapra Probs. 13.2 and 13.3
% KEYWORDS: power method, inverse power method, highest eigenvalue, lowest eigenvalue, eigenvector, iteration, eig check
% PROBLEM:
% Use the power method to determine the highest eigenvalue and corresponding eigenvector of
% [2-lambda 8 10; 8 4-lambda 5; 10 5 7-lambda], i.e. of A = [2 8 10; 8 4 5; 10 5 7]. Then use the power
% method (on the inverse) to determine the lowest eigenvalue and its eigenvector. Check with eig.
% CHECK: abs(lmax - 19.884236) < 1e-5 && abs(lmin - 0.294244) < 1e-5
% CODE:
A = [2 8 10; 8 4 5; 10 5 7];
fprintf('Power method iterations (highest):\n');
eig_power(A);                              % no outputs: prints every iteration
[lmax, vmax] = eig_power(A);
[lmin, vmin] = eig_power(A, 'smallest');
fprintf('Highest eigenvalue = %.6f, eigenvector = [%s]\n', lmax, sprintf(' %.4f', vmax));
fprintf('Lowest (smallest magnitude) eigenvalue = %.6f, eigenvector = [%s]\n', lmin, sprintf(' %.4f', vmin));
fprintf('eig(A) = %s\n', mat2str(sort(eig(A))', 7));

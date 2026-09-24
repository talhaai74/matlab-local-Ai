% TOPIC: basics
% TITLE: Fibonacci sequence ratio converging to the golden ratio (for loop)
% SOURCE: Slides 01, page 35 (for loop; Fibonacci ratio exercise)
% KEYWORDS: fibonacci sequence, golden ratio, for loop, plot ratio convergence, fprintf table
% PROBLEM:
% Test the assertion that the ratio of successive Fibonacci terms approaches
% the golden ratio (sqrt(5)-1)/2. Build F(1)=0, F(2)=1, F(i)=F(i-1)+F(i-2)
% for i = 3:20 with a for loop, then plot the ratio F(1:19)./F(2:20) against
% n, with a dashed reference line at (sqrt(5)-1)/2.
% CHECK: F(19) == 2584 && F(20) == 4181
% CHECK: abs(ratio(19) - golden) < 1e-3
% CODE:
F = zeros(1,20);
F(1) = 0;
F(2) = 1;
for i = 3:20
    F(i) = F(i-1) + F(i-2);
end
ratio = F(1:19)./F(2:20);
golden = (sqrt(5)-1)/2;

figure;
plot(1:19, ratio, 'o');
hold on;
xlabel('n');
plot(1:19, ratio, '-');
legend('Ratio of terms f_{n-1}/f_n');
plot([0 20], golden*[1 1], '--');
hold off;

fprintf('%4s %10s %10s\n','n','F(n)','ratio');
for i = 1:19
    fprintf('%4d %10d %10.6f\n', i, F(i), ratio(i));
end
fprintf('golden ratio conjugate (sqrt(5)-1)/2 = %.6f\n', golden);

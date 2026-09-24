% TOPIC: basics
% TITLE: Greatest n with 1^2+2^2+...+n^2 under 100 (while loop)
% SOURCE: Slides 01, page 36 (while loop exercise)
% KEYWORDS: while loop, sum of squares, unknown iteration count, cumulative sum
% PROBLEM:
% What is the greatest value of n such that 1^2 + 2^2 + ... + n^2 is less
% than 100? Use a while loop: S=1, n=1; while S+(n+1)^2 < 100, n=n+1,
% S=S+n^2; end. Report n and S.
% CHECK: n == 6 && S == 91
% CODE:
S = 1;
n = 1;
while S + (n+1)^2 < 100
    n = n + 1;
    S = S + n^2;
end
fprintf('greatest n = %d, sum of squares S = 1^2+...+%d^2 = %d\n', n, n, S);

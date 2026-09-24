% TOPIC: basics
% TITLE: Function m-file: triangle area from three sides (Heron's formula)
% SOURCE: Slides 01, page 43 (function m-file: area.m)
% KEYWORDS: function m-file, local function, heron formula, triangle area, help comment block
% PROBLEM:
% Write a function that calculates the area of a triangle with sides a, b, c
% using Heron's formula: s = (a+b+c)/2, Area = sqrt(s*(s-a)*(s-b)*(s-c)).
% Use it to find the area of a 3-4-5 triangle and of a 7-8-9 triangle.
% CHECK: abs(Atri - 6) < 1e-9
% CHECK: abs(Atri2 - 26.8328157) < 1e-3
% CODE:
a = 3; b = 4; c = 5;
Atri = triangleArea(a,b,c);
fprintf('sides a=%.4f b=%.4f c=%.4f -> area = %.4f\n', a, b, c, Atri);

a2 = 7; b2 = 8; c2 = 9;
Atri2 = triangleArea(a2,b2,c2);
fprintf('sides a=%.4f b=%.4f c=%.4f -> area = %.4f\n', a2, b2, c2, Atri2);

function A = triangleArea(a,b,c)
% Compute the area of a triangle whose sides have length a, b and c.
% Inputs:  a,b,c - lengths of sides
% Output:  A     - area of the triangle (Heron's formula)
s = (a+b+c)/2;
A = sqrt(s*(s-a)*(s-b)*(s-c));
end

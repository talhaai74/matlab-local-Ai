% TOPIC: basics
% TITLE: 3-D saddle surface with meshgrid: mesh, surf, and shading modes
% SOURCE: Slides 01, pages 31-32 (mesh/meshgrid; surf and shading)
% KEYWORDS: meshgrid, mesh, surf, shading, colormap, saddle surface, 3d plot
% PROBLEM:
% Plot the saddle surface z = (x-3)^2 - (y-2)^2 for 2 <= x <= 4 and
% 1 <= y <= 3, built with meshgrid at 0.2 spacing. Show it with mesh(X,Y,Z)
% titled 'Saddle', then with surf(X,Y,Z) under shading faceted, shading flat,
% and colormap(gray).
% CHECK: isequal(size(Z), [11 11])
% CHECK: any(Z(:) > 0.5) && any(Z(:) < -0.5)
% CHECK: max(Z(:)) <= 1 + 1e-9 && min(Z(:)) >= -1 - 1e-9
% CODE:
[X,Y] = meshgrid(2:.2:4, 1:.2:3);
Z = (X-3).^2 - (Y-2).^2;    % minus sign: this is what makes it a SADDLE

figure;
mesh(X,Y,Z);
title('Saddle'); xlabel('x'); ylabel('y');

figure;
surf(X,Y,Z);
title('Saddle');
shading faceted;

figure;
surf(X,Y,Z);
title('Saddle');
shading flat;
colormap(gray);
fprintf('Z ranges from %.4f to %.4f over an %dx%d grid\n', min(Z(:)), max(Z(:)), size(Z,1), size(Z,2));

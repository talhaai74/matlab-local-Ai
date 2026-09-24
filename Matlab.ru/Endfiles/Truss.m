T = [-cosd(30) 0 cosd(60) 0 0 0; sind(30) 0 sind(60) 0 0 0 ; 
    cosd(30) 1 0 1 0 0 ; sind(30) 0 0 0 1 0 ; 0 1 cosd(60) 0 0 0 ; 
    0 0 sind(60) 0 0 1];
b = [0; -1000; 0;0;0;0];
[L,U]= lu(T);
d = L\b;
x= U\d;
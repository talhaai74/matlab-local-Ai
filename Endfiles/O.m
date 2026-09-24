function y = O(x)
y = (57/2)*x.^2-(10/3)*singular(x,0,3)+(10/3)*singular(x,5,3)+(15/2)*singular(x,8,2)+150*singular(x,7,1)-238.25;
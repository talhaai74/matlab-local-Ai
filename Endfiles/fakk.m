function f = fakk(x)

f = 265*singular(x,0,1)-(50/9)*singular(x,0,3)+(50/9)*singular(x,3,3)-50*singular(x,3,2)+50*singular(x,6,2)+285*singular(x,10,1)-100*singular(x,12,1);
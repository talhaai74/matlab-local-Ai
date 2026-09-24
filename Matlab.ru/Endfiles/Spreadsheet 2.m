dftable= readtable('data_stat_practice.xlsx');
pm25=dftable.PM25;
mean(pm25)
datamat= [dftable.PM25 dftable.Rain dftable.Temp dftable.WindSpeed];
mean(datamat)
minimum= min(datamat)
maximum = max(datamat)
SD=std(datamat)
Q1=prctile(datamat,25)
Q2=prctile(datamat,50)
Q3=prctile(datamat,75)

IQR=Q3-Q1

n=size(datamat,1);
meanvalue= mean(datamat);
SE=SD/sqrt(n);
CI95=meanvalue + tinv([0.025 ; 0.975], n-1).*SE

[n,x]=hist(pm25,20)
hist(pm25,20)
ylabel('frequency')

fitlm(dftable,'PM25~Rain+Temp+WindSpeed','Intercept','false')


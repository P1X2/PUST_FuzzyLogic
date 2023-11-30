x = -.3:0.1:11.5;
y = gbellmf(x,[0.8 3 2.133]);
y2 = gbellmf(x,[0.8 3 4]);
y3 = gbellmf(x,[0.8 3 5.8]);
y4 = gbellmf(x,[0.8 3 7.633]);
y5 = gbellmf(x,[0.8 3 9.4557]);
hold on
plot(x,y)
plot(x,y2)
plot(x,y3)
plot(x,y4)
plot(x,y5)

title('gbellmf, P=[2 4 6]')
xlabel('x')
ylabel('Degree of Membership')
hold off
x = -.3:0.1:11.5;
bell_shape = [0.8 3];
y = gbellmf(x,[bell_shape(1,1) bell_shape(1,2) 2.133]);
y2 = gbellmf(x,[bell_shape(1,1) bell_shape(1,2) 4]);
y3 = gbellmf(x,[bell_shape(1,1) bell_shape(1,2) 5.8]);
y4 = gbellmf(x,[bell_shape(1,1) bell_shape(1,2) 7.633]);
y5 = gbellmf(x,[bell_shape(1,1) bell_shape(1,2) 9.4557]);
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
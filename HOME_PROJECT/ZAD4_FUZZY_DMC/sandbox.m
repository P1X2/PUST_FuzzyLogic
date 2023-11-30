x = -.3:0.1:11.5;
bell_shape = [1.6 2];
y = gbellmf(x,[bell_shape(1,1) bell_shape(1,2) 0.15]);
y2 = gbellmf(x,[bell_shape(1,1) bell_shape(1,2) 3.5]);
y3 = gbellmf(x,[bell_shape(1,1) bell_shape(1,2) 7.75]);

hold on
plot(x,y)
plot(x,y2)
plot(x,y3)


title('gbellmf, P=[2 4 6]')
xlabel('x')
ylabel('Degree of Membership')
hold off
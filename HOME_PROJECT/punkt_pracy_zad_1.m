clear all;
steps = 200;

u(1:steps) = 0;
z(1:steps) = 0;
y(1:13) = 0;


for k=10:steps
    y(k) = symulacja_obiektu1y_p3(u(k-6), u(k-7), y(k-1), y(k-2));
end

fig = figure;
stairs(y, 'DisplayName','y')
title("Sprawdzenie poprawność podanego punku pracy:" + newline + "u = y = 0")
legend
% set(0,'defaultLineLineWidth',1.5);
% print (["sprawdzenie_punktu_pracy.png"], '-dpng', '-r400')




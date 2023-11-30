clear all;


steps = 300;
k_step = 100;

%% Charakterystyka statyczna 

% inicjalizacja potrzebnych macierzy
u_vec = [-1:.0001:1];
y_stat = zeros(1, length(u_vec));
for i = 1: length(u_vec)
    y(1:steps) = 0;
    u(1:k_step-1) = 0;
    u(k_step:steps) = u_vec(i); 
    for k=10:steps
        y(k) = symulacja_obiektu1y_p3(u(k-6), u(k-7), y(k-1), y(k-2));
    end
    y_stat(i) = y(steps);
end


fig2 = figure;
plot(u_vec, y_stat)
xlabel("u")
ylabel("y")
title("Charakterystyka statyczna obiektu")
% set(0,'defaultLineLineWidth',1.5);
% print (["ch_stat_sym.png"], '-dpng', '-r400')

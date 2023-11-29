steps = 300;
k_step = 100;

%% Tor wejście-wyjście

% inicjalizacja potrzebnych macierzy
y1(1:k_step) = 0; y2(1:k_step) = 0; y3(1:k_step) = 0; y4(1:k_step) = 0; y5(1:k_step) = 0; y6(1:k_step) = 0;
u(1:k_step-1) = 0;

 
% ograniczenie u [-1, 1]
u(k_step:steps) = -1; 
for k=10:steps
    y1(k) = symulacja_obiektu1y_p3(u(k-6), u(k-7), y1(k-1), y1(k-2)); % odp. skokowa
end

u(k_step:steps) = -0.75;
for k=10:steps
    y2(k) = symulacja_obiektu1y_p3(u(k-6), u(k-7), y2(k-1), y2(k-2));
end

u(k_step:steps) = -0.25;
for k=10:steps
    y3(k) = symulacja_obiektu1y_p3(u(k-6), u(k-7), y3(k-1), y3(k-2));
end

u(k_step:steps) = 0.25;
for k=10:steps
    y4(k) = symulacja_obiektu1y_p3(u(k-6), u(k-7), y4(k-1), y4(k-2));
end

u(k_step:steps) = .5;
for k=10:steps
    y5(k) = symulacja_obiektu1y_p3(u(k-6), u(k-7), y4(k-1), y4(k-2));
end

u(k_step:steps) = 1;
for k=10:steps
    y6(k) = symulacja_obiektu1y_p3(u(k-6), u(k-7), y4(k-1), y4(k-2));
end


fig1 = figure;
hold on
stairs(y1, 'DisplayName','u_s_k_o_k = -1')
stairs(y2, 'DisplayName','u_s_k_o_k = -0.75')
stairs(y3, 'DisplayName','u_s_k_o_k = -0.25')
stairs(y4, 'DisplayName','u_s_k_o_k = 0.25')
stairs(y5, 'DisplayName','u_s_k_o_k = 0.75')
stairs(y6, 'DisplayName','u_s_k_o_k = 1')
title('Odpowiedzi skokowe obiektu')
legend('Location','northwest')
hold off

% set(0,'defaultLineLineWidth',1.5);
% print (["odpowiedzi_skokowe_zad_1.png"], '-dpng', '-r400')



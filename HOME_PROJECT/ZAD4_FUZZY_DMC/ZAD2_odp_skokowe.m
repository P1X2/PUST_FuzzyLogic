steps = 300;
k_step = 100;

%% Tor wejście-wyjście

% inicjalizacja potrzebnych macierzy
y1(1:k_step) = 8.55; y2(1:k_step) = 0; y3(1:k_step) = 0; y4(1:k_step) = 0; y5(1:k_step) = 0; y6(1:k_step) = 0;
u(1:k_step-1) = .8233;

 
% ograniczenie u [-1, 1]
u(k_step:steps) = .8733; 
for k=10:steps
    y1(k) = symulacja_obiektu1y_p3(u(k-6), u(k-7), y1(k-1), y1(k-2)); % odp. skokowa
end

for k=10:steps
    y1(k) = (y1(k) - 8.55)/ .05 ; % odp. skokowa
end

fig1 = figure;
hold on
stairs(y1, 'DisplayName','u_s_k_o_k = -1')
title('Odpowiedzi skokowe obiektu')
legend('Location','northwest')
hold off

% set(0,'defaultLineLineWidth',1.5);
% print (["odpowiedzi_skokowe_zad_1.png"], '-dpng', '-r400')



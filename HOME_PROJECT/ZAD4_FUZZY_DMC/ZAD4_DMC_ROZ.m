clear all;
%% Konfiguracja zbiorów rozmytych

% ilosc zbiorów rozmytych
fuzzy_interrvals_cnt = 2; % F_I_cnt > 2

% niestandardowe przedziały przynależności [domyslnie równe]
duty_points = []; % <- wpisac co sie chce z zakresu 0-10 + zdefiniować kształt funkcji przynależnosci

% definicja kształtu funkcji przynależnosci dla automatycznie generowanych punktów pracy

if fuzzy_interrvals_cnt == 2
    bell_shape = [2 4];
elseif fuzzy_interrvals_cnt == 3
    bell_shape = [1.5 3];
elseif fuzzy_interrvals_cnt == 4
    bell_shape = [1 6];
elseif fuzzy_interrvals_cnt == 5
    bell_shape = [0.8 3];
end

%% Algorymt DMC

% Parametry DMC
D=90;
N=12;
Nu=5;
lambda = 100;

%% pozyskanie pkt. pracy, odpowiedzi skokowych i macierzy dla kazdego reg. lokalnego

% powywoływac tu funkcje zdefiniowane wczesniej



%% Skoki yzad

% pętla symulacji 

steps_sym = 1500; % steps_symulacji

% Momenty skoków yzad
k_step1 = 50; 
k_step2 = 300;
k_step3 = 500;
k_step4 = 700;
k_step5 = 900;
k_step6 = 1100;
k_step7 = 1300;

% yzad
yzad(1:k_step1-1) = 0; yzad(k_step1:k_step2) = 10;  % yzad z  przedziału  <-0.3, 11.5> bo ograniczenia na u 
yzad(k_step2-1:k_step3) = -.3; yzad(k_step3:k_step4-1) = 5;
yzad(k_step4:k_step5-1) = 9; yzad(k_step5:k_step6-1) = 3;
yzad(k_step6:k_step7-1) = 7; yzad(k_step7:steps_sym) = 4;


%% Inicjalizacja potrzebnych macierzy

 
u(1:k_step1) = 0;
y(1:k_step1) = 0;
delta_up = zeros(D-1, 1);
e(1:steps_sym) = 0;


K = (M'*M + lambda*eye(Nu))^(-1) * M';

zmienna_trajektoria_zadana = true;

for k=14:steps_sym

    y(k) = symulacja_obiektu1y_p3(u(k-6), u(k-7), y(k-1), y(k-2));
    Y(1:N, 1) = y(k);        % wektor aktualnego wyjscia

    if zmienna_trajektoria_zadana == false 
        % stała trajektoria zadana na horyzoncie predykcji
        Y_zad(1:N, 1) = yzad(k);

    elseif zmienna_trajektoria_zadana == true
        % zmienna trajektoria zadana na horyzoncie predykcji
        if k+N+1 > steps_sym
            Y_zad(1:N, 1) = yzad(k);
        else
            Y_zad(1:N, 1) = (yzad(k+1:k+N))';
        end       
    end

    delta_u = K*(Y_zad - Y - Mp * delta_up);

    u_k = delta_u(1,1) + u(k-1);
    
    if u_k > 1
        u_k = 1;
        delta_u(1,1) = 1 - u(k-1);
    elseif u_k < -1 
        u_k = -1;
        delta_u(1,1) = -1 - u(k-1);
    end

    delta_up = [delta_u(1,1); delta_up(1:D-2)];

    u(k) = u_k;
    e(k) = yzad(k)-y(k);

end

e = e.^2;
error_sum = sum(e);

%% Plots
fig1=figure;
subplot(2,1,1);
hold on
stairs(y, "DisplayName","y")
stairs(yzad, "DisplayName","y_z_a_d")
xlabel('k')
ylabel('y')
legend('Location','southeast')
title("D = "+ D + "; N = " + N + "; Nu = " + Nu + "; lambda = " + lambda  + newline + "error = " + error_sum + newline + 'Wyjście');
hold off


subplot(2,1,2)
stairs(u, "DisplayName","u")
xlabel('k')
ylabel('u')
legend('Location','southeast');
title('Sterowanie');


set(0,'defaultLineLineWidth',1.5);
print (["dmc_liniowy_symulacja.png"], '-dpng', '-r400')





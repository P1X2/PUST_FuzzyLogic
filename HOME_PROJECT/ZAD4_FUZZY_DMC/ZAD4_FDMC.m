clear all;
%% Konfiguracja zbiorów rozmytych

% ilosc zbiorów rozmytych
fuzzy_interrvals_cnt = 3; % F_I_cnt > 2

duty_points = []; % <- !! OPCJONALNE !! -> wpisac co sie chce z zakresu 0-10 + zdefiniować kształt funkcji przynależnosci i size(duty_points) == fuzzy_intervals_cnt

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
lambda = 500;
lambda = ones(1,fuzzy_interrvals_cnt) * lambda; % jednakowe lambdy dla wszystkich reg. lokalnych
lambda = [100 100 100]; % różne lambdy dla różnych reg. lokalnych %

% !!!!!!!!!!!!!!!!!!!!!!! ZAD7 !!!!!!!! |TODO| !!!!!!!!!!!!!!!!!




%% pozyskanie pkt. pracy, odpowiedzi skokowych i macierzy dla kazdego reg. lokalnego

% pozyskanie pkt_p i odp_skok dla kazdego zb. roz. 
[duty_points, step_responses] = GET_STEP_RESPONSES(fuzzy_interrvals_cnt, duty_points);

% pozyskanie macicierzy DMC dla ...
matrices = GET_DMC_MATRICES(D, N, Nu, lambda, fuzzy_interrvals_cnt, step_responses);

% plot funkcji przynależnosci
membership_fig = figure;
hold on
x = -1:0.1:11.5;
for o=1:fuzzy_interrvals_cnt

    y = gbellmf(x, [bell_shape(1,1) bell_shape(1,2) duty_points(1,o)]);
    plot(x, y)
    scatter(duty_points(1,o), 1);

end
hold off
title('Kształt funkcji przynależności')


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
e(1:steps_sym) = 0;

delta_up = zeros(D-1, 1);
delta_u = zeros(1, fuzzy_interrvals_cnt);


membership_degree = zeros(1, fuzzy_interrvals_cnt);

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

    if k==60
        p=1;
    end
    %% fjuzi dmcc

    for FI=1:fuzzy_interrvals_cnt
        % delta dla zb rozmytego
        K = matrices{1, FI};
        Mp =matrices{2, FI};
        d_u = K*(Y_zad - Y - Mp * delta_up);
        d_u = d_u(1,1);
       
        % d_u * membership_degree
        membership_degree(1, FI) = GET_MEMBERSHIP(duty_points(1, FI), y(k), bell_shape);


        delta_u(1, FI) = d_u; % finalnie wyznaczone d_u
    end
    % wyznaczenie sterowania ze zb rozmytych
    DELTA_U = sum(delta_u .* membership_degree) / sum(membership_degree);


    u_k = u(k-1) + DELTA_U;
    
    if u_k > 1
        u_k = 1;
        DELTA_U = 1 - u(k-1);
    elseif u_k < -1 
        u_k = -1;
        DELTA_U = -1 - u(k-1);
    end

    delta_up = [DELTA_U; delta_up(1:D-2)];

    u(k) = u_k;
    e(k) = yzad(k)-y(k);

end

e = e.^2;
error_sum = sum(e);

%% Plots
tit1 = strcat("Error = ", int2str(error_sum));
tit2 = strcat("Liczba regulatorów lokalnych - ", int2str(fuzzy_interrvals_cnt));
fig1=figure;
subplot(2,1,1);
hold on
stairs(y, "DisplayName","y")
stairs(yzad, "DisplayName","y_z_a_d")
xlabel('k')
ylabel('y')
legend('Location','southeast')
title(tit2 + newline + tit1 + newline + 'Wyjście');
hold off


subplot(2,1,2)
stairs(u, "DisplayName","u")
xlabel('k')
ylabel('u')
legend('Location','southeast');
title('Sterowanie');






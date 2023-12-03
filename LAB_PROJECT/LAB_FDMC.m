clear all;
load('Odpowiedzi skokowe.mat')
%% Konfiguracja zbiorów rozmytych

% ilosc zbiorów rozmytych
fuzzy_interrvals_cnt = 3; % F_I_cnt =3
bell_shape = [10 3];



%% Algorymt DMC

% Parametry DMC
D=380;
N=40;
Nu=8;
lambda = 1;
lambda = ones(1,fuzzy_interrvals_cnt) * lambda; % jednakowe lambdy dla wszystkich reg. lokalnych
% lambda = [100 100 100]; % różne lambdy dla różnych reg. lokalnych %


%% pozyskanie pkt. pracy, odpowiedzi skokowych i macierzy dla kazdego reg. lokalnego

% pozyskanie pkt_p i odp_skok dla kazdego zb. roz. 
[duty_points, step_responses] = GET_STEP_RESPONSES(pp30, pp50, pp70);

% pozyskanie macicierzy DMC dla ...
matrices = GET_DMC_MATRICES(D, N, Nu, lambda, fuzzy_interrvals_cnt, step_responses);

% plot funkcji przynależnosci
membership_fig = figure;
hold on
x = 25.1:80;
for o=1:fuzzy_interrvals_cnt

    y = gbellmf(x, [bell_shape(1,1) bell_shape(1,2) duty_points(1,o)]);
    plot(x, y)
    scatter(duty_points(1,o), 1);

end
hold off
title('Kształt funkcji przynależności')


%% Skoki yzad

% pętla symulacji 

% Momenty skoków yzad
k_step1 = 10; 
k_step2 = 280;
k_step3 = 600;

steps_sym = 900;


% yzad
yzad(1:k_step1-1) = 33; yzad(k_step1:k_step2) = 38;  
yzad(k_step2-1:k_step3) = 48; yzad(k_step3:steps_sym) = 33;


%% Inicjalizacja potrzebnych macierzy

 
u(1:k_step1) = 0;
y(1:k_step1) = 0;
e(1:steps_sym) = 0;

delta_up = zeros(D-1, 1);
delta_u = zeros(1, fuzzy_interrvals_cnt);


membership_degree = zeros(1, fuzzy_interrvals_cnt);

zmienna_trajektoria_zadana = true;

k=0;
while k<steps_sym

    temp = readMeasurements(1);

    y(k) = temp;
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


    %% fjuzi dmcc

    for FI=1:fuzzy_interrvals_cnt
        % delta dla zb rozmytego
        K = matrices{1, FI};
        Mp = matrices{2, FI};
        d_u = K*(Y_zad - Y - Mp * delta_up);
        d_u = d_u(1,1);
       
        % d_u * membership_degree
        membership_degree(1, FI) = GET_MEMBERSHIP(duty_points(1, FI), y(k), bell_shape);


        delta_u(1, FI) = d_u; % finalnie wyznaczone d_u
    end
    % wyznaczenie sterowania ze zb rozmytych
    DELTA_U = sum(delta_u .* membership_degree) / sum(membership_degree);


    u_k = u(k-1) + DELTA_U;
    
    if u_k > 100
        u_k = 100;
        DELTA_U = 100 - u(k-1);
    elseif u_k < 0 
        u_k = 0;
        DELTA_U = 0 - u(k-1);
    end

    delta_up = [DELTA_U; delta_up(1:D-2)];

    u(k) = u_k;
    e(k) = yzad(k)-y(k);



    sendNonlinearControls(u(k))
    waitForNewIteration();
    k = k+1
    
    hold on
    plot(y);
    plot(yzad)
    drawnow;

end

error_sum = sum(e.^2)/steps_sym;

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






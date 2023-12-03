clear all;
%% Konfiguracja zbiorów rozmytych; Optymalne k ti td w pliku nastawy fpida 

% ilosc zbiorów rozmytych
fuzzy_interrvals_cnt = 3; 


% ustalic 1@!@!@!@!#@!#!@
K = [.047 .038 .032 ];
Ti = [4 4 4];
Td = [.5 .5 .5];

% niestandardowe przedziały przynależności [domyslnie równe]
duty_points = [30 50 70]; % <- wpisac co sie chce z zakresu 0-10 + zdefiniować kształt funkcji przynależnosci i size(duty_points) == fuzzy_intervals_cnt


%%
% definicja kształtu funkcji przynależnosci dla automatycznie generowanych punktów pracy

bell_shape = [10 3];



DP = GET_DUTY_POINTS(fuzzy_interrvals_cnt, duty_points);


membership_fig = figure;
hold on
x = 25:0.1:80;
for o=1:fuzzy_interrvals_cnt

    y = gbellmf(x, [bell_shape(1,1) bell_shape(1,2) DP(o)]);
    plot(x, y)
    scatter(DP(o), 1);

end
hold off
title('Kształt funkcji przynależności')
%% Parametry reg. PID 
Tp = 1;

FPID_settings = GET_FPID_SETTINGS(K, Ti, Td, Tp, fuzzy_interrvals_cnt);

%% Momenty skoków yzad
k_step1 = 10; 
k_step2 = 280;
k_step3 = 600;


steps = 900;
%% inicjalizacja potrzebnych macierzy
u(1:k_step1-1) = 0; 
y(1:k_step1-1) = 0; 
e(1:k_step1-1) = 0;

fuzzy_u = zeros(1, fuzzy_interrvals_cnt);
membership_degree = zeros(1, fuzzy_interrvals_cnt);

% skoki yzad
yzad(1:k_step1-1) = 33; yzad(k_step1:k_step2) = 38;  
yzad(k_step2-1:k_step3) = 48; yzad(k_step3:steps) = 33;
 
% yzad(1:k_step1-1) = 0; yzad(k_step1:steps) = 11;

%% Pętla symulacji
k=0;
while k<steps

    temp1 = readMeasurements(1);

    y(k) = temp1;
    e(k) = yzad(k) - y(k);

    % FPID sterowanie
    for j=1:fuzzy_interrvals_cnt
        fuzzy_u(1, j) = FPID_settings{3, j}*e(k-2) + FPID_settings{2, j}*e(k-1) + FPID_settings{1, j}*e(k) + u(k-1);
        membership_degree(1, j) = GET_MEMBERSHIP(DP(j), y(k), bell_shape);
    end
    
    u(k) = sum(fuzzy_u .* membership_degree) / sum(membership_degree);


    if u(k) < 0
        u(k) = 0;
    
    elseif u(k) > 100
        u(k) = 100;

    end

    sendNonlinearControls(u(k))
    waitForNewIteration();
    k = k+1

    hold on
    plot(y);
    plot(yzad)
    drawnow;


end



error_sum = (sum(e.^2));
tit1 = strcat( "Error = ",  int2str(error_sum));

fig = figure;
subplot(2,1,2)
hold on
stairs(u, "DisplayName","uPID"); 
xlabel('k');
ylabel('u'); 
title('Sterowanie u(k)');

hold off


subplot(2,1,1)
hold on
stairs(yzad, "DisplayName","yzad"); 
title('yzad, y'); 
xlabel('k');
ylabel('y, yzad'); 

stairs(y,"DisplayName","yPID");
legend('Location','southeast')
title(tit1 + newline + "Wyjście");
hold off




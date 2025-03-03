clear all;
%% Konfiguracja zbiorów rozmytych; Optymalne k ti td w pliku nastawy fpida 

% ilosc zbiorów rozmytych
fuzzy_interrvals_cnt = 5; 

K = [.047 .038 .032 .027 .023];
Ti = [4 4 4 4 4];
Td = [.5 .5 .5 .5 .5];

% niestandardowe przedziały przynależności [domyslnie równe]
duty_points = []; % <- wpisac co sie chce z zakresu 0-10 + zdefiniować kształt funkcji przynależnosci i size(duty_points) == fuzzy_intervals_cnt


%%
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

DP = GET_DUTY_POINTS(fuzzy_interrvals_cnt, duty_points);


membership_fig = figure;
hold on
x = -1:0.1:11.5;
for o=1:fuzzy_interrvals_cnt

    y = gbellmf(x, [bell_shape(1,1) bell_shape(1,2) DP(o)]);
    plot(x, y)
    scatter(DP(o), 1);

end
hold off
title('Kształt funkcji przynależności')
%% Parametry reg. PID 
Tp = .5;

FPID_settings = GET_FPID_SETTINGS(K, Ti, Td, Tp, fuzzy_interrvals_cnt);

%% Momenty skoków yzad
k_step1 = 50; 
k_step2 = 300;
k_step3 = 500;
k_step4 = 700;
k_step5 = 900;
k_step6 = 1100;
k_step7 = 1300;
steps = 1500;
%% inicjalizacja potrzebnych macierzy
u(1:k_step1-1) = 0; 
y(1:k_step1-1) = 0; 
e(1:k_step1-1) = 0;

fuzzy_u = zeros(1, fuzzy_interrvals_cnt);
membership_degree = zeros(1, fuzzy_interrvals_cnt);

% skoki yzad
yzad(1:k_step1-1) = 0; yzad(k_step1:k_step2) = 10;  % yzad z  przedziału  <-0.3, 11.5> bo ograniczenia na u 
yzad(k_step2-1:k_step3) = -.3; yzad(k_step3:k_step4-1) = 5;
yzad(k_step4:k_step5-1) = 9; yzad(k_step5:k_step6-1) = 3;
yzad(k_step6:k_step7-1) = 7; yzad(k_step7:steps) = 4;
 
% yzad(1:k_step1-1) = 0; yzad(k_step1:steps) = 11;

%% Pętla symulacji
for k=12:steps

    y(k) = symulacja_obiektu1y_p3(u(k-6), u(k-7), y(k-1), y(k-2));
    e(k) = yzad(k) - y(k);

    % FPID sterowanie
    for j=1:fuzzy_interrvals_cnt
        fuzzy_u(1, j) = FPID_settings{3, j}*e(k-2) + FPID_settings{2, j}*e(k-1) + FPID_settings{1, j}*e(k) + u(k-1);
        membership_degree(1, j) = GET_MEMBERSHIP(DP(j), y(k), bell_shape);
    end
    
    u(k) = sum(fuzzy_u .* membership_degree) / sum(membership_degree);


    if u(k) <= -1
        u(k) = -1;
    
    elseif u(k) >= 1
        u(k) = 1;

    end

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




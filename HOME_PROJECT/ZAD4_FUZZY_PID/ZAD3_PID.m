clear all;
%% Konfiguracja zbiorów rozmytych

% ilosc zbiorów rozmytych
fuzzy_interrvals_cnt = 5; % F_I_cnt > 2

% niestandardowe przedziały przynależności [domyslnie równe]
duty_points = []; % <- wpisac co sie chce z zakresu 0-10 + zdefiniować kształt funkcji przynależnosci i size(duty_points) == fuzzy_intervals_cnt

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


%% Parametry reg. PID

% ilosc elem w wektorze = fuzz_inter_cnt
k = []; 
Ti = []; 
Td = []; 
Tp = 0.5; 


r0 = k*(1+(Tp/(2*Ti))+(Td/Tp));
r1 = k*((Tp/(2*Ti))-((2*Td)/Tp)-1);
r2 = (k*Td)/Tp;


%% inicjalizacja potrzebnych macierzy
u(1:k_step1-1) = 0; % 
y(1:k_step1-1) = 0; % 
e(1:k_step1-1) = 0;

%% Momenty skoków yzad
k_step1 = 50; 
k_step2 = 300;
k_step3 = 500;
k_step4 = 700;
k_step5 = 900;
k_step6 = 1100;
k_step7 = 1300;
steps = 1500;

yzad(1:k_step1-1) = 0; yzad(k_step1:k_step2) = 10;  % yzad z  przedziału  <-0.3, 11.5> bo ograniczenia na u 
yzad(k_step2-1:k_step3) = -.3; yzad(k_step3:k_step4-1) = 5;
yzad(k_step4:k_step5-1) = 9; yzad(k_step5:k_step6-1) = 3;
yzad(k_step6:k_step7-1) = 7; yzad(k_step7:steps) = 4;
 
% yzad(1:k_step1-1) = 0; yzad(k_step1:steps) = 11;

%% Pętla symulacji
for k=12:steps

    y(k) = symulacja_obiektu1y_p3(u(k-6), u(k-7), y(k-1), y(k-2));
    e(k) = yzad(k) - y(k);
    u(k) = r2*e(k-2) + r1*e(k-1) + r0*e(k) + u(k-1);

    if u(k) <= -1
        u(k) = -1;
    
    elseif u(k) >= 1
        u(k) = 1;

    end

end



error_sum = (sum(e.^2));


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
title("Regulacja PID " + newline + "|errorsum|^2 =" + error_sum);
hold off




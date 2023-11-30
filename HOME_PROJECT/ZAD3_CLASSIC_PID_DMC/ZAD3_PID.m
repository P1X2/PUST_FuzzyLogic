%% Momenty skoków yzad
k_step1 = 50; 
k_step2 = 300;
k_step3 = 500;
k_step4 = 700;
k_step5 = 900;
k_step6 = 1100;
k_step7 = 1300;
steps = 1500;

%% Parametry reg. PID
% strojone ziglerem nicholsem dla skoku u = 5
% k_kryt = 0.032
% T = 20s

% k = .0192; 
% Ti = 10; 
% Td = 2.5; 
% Tp = 0.5; 

% ręcznie poprawione nastawy
k = .1; 
Ti = 6; 
Td = .5; 
Tp = 0.5; 


r0 = k*(1+(Tp/(2*Ti))+(Td/Tp));
r1 = k*((Tp/(2*Ti))-((2*Td)/Tp)-1);
r2 = (k*Td)/Tp;


%% inicjalizacja potrzebnych macierzy
u(1:k_step1-1) = 0; % 
y(1:k_step1-1) = 0; % 
e(1:k_step1-1) = 0;

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




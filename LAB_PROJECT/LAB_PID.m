clear all
addpath('C:\Users\PUST 102\Desktop\PUST_lab_1_luki'); % add a path to the functions
initSerialControl COM4 
sendControls([ 1,5], ... 
             [50, 26]);

%% Momenty skoków yzad
k_step1 = 10; 
k_step2 = 280;
k_step3 = 600;

steps = 900;

%% Parametry reg. PID


% ręcznie poprawione nastawy
k = 5 ; 
Ti = 12;
Td = 0.001;
Tp = 1;


r0 = k*(1+(Tp/(2*Ti))+(Td/Tp));
r1 = k*((Tp/(2*Ti))-((2*Td)/Tp)-1);
r2 = (k*Td)/Tp;


%% inicjalizacja potrzebnych macierzy
u(1:k_step1-1) = 0; % 
y(1:k_step1-1) = 0; % 
e(1:k_step1-1) = 0;

yzad(1:k_step1-1) = 33; yzad(k_step1:k_step2) = 38;  
yzad(k_step2-1:k_step3) = 48; yzad(k_step3:steps) = 33;



%% Pętla symulacji
k = 0;

while k < steps
    temp1 = readMeasurements(1);

    y(k) = temp1;

    e(k) = yzad(k) - y(k);
    u(k) = r2*e(k-2) + r1*e(k-1) + r0*e(k) + u(k-1);

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

sendControls([ 1,5], ... 
             [50, 26]);




avg_error = (sum(e.^2)) / steps;

tit1 = strcat("Avg. error = ",int2str(avg_error));

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
title("Regulacja PID " + newline + tit1);
hold off




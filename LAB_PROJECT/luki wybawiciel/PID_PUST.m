addpath('C:\Users\PUST 102\Desktop\PUST_lab_1_luki'); % add a path to the functions
initSerialControl COM8 % initialise com port

W1 = 50;
G1 = 26;
Gpp = 26;

x = [];
s = [];
Ypp = 34.5; % Wartość temperatury dla W1=50 oraz G1=26

%dane projektowe
% K = 0.8;
% Ti = 11;
% Td = 0.39;

% Nastawy regulatora
K = 0.5;
Ti = 11;
Td = 0.39;

% Trajektoria zmian sygnału zadanego 
for i = 1:1500
    if i <= 100
        Y_zad(i) = 34.5;
    elseif 100 < i  && i <= 800
        Y_zad(i) = 39.5;
    elseif i > 800
        Y_zad(i) = 49.5;
    end

end
i=1;
T = 1;

U_pid = zeros(1,1);
Y_pid = zeros(1,1);

e = zeros(1,1);
E_pid = 0;

r2 = (K*Td)/T;

r1 = K*((T/(2*Ti)) - (2*(Td/T)) - 1);

r0 = K*(1 + (T/(2*Ti)) + (Td/T));

u = [];


while(1)
    
    % Wczytanie wartości aktualnej temperatury grzałki G1
    measurements1(i) = readMeasurements(1);
    
    % Aktualna wartość wyjścia
    Y_pid(i) = measurements1(i);
    
    % Obliczanie błędu
    e(i) = Y_zad(i) - Y_pid(i);
    E_pid = E_pid + (e(i))^2;

    % Obliczanie sterowania
    if i == 1
        U_pid(i) = r0*e(i) + 26;
    elseif i == 2
        U_pid(i) = r1*e(i-1) + r0*e(i) + U_pid(i-1);
    else
        U_pid(i) = r2*e(i-2) + r1*e(i-1) + r0*e(i) + U_pid(i-1);
    end
    
    % Ograniczenia sterowania
    if U_pid(i) > 99
        U_pid(i) = 99;
    end

    if U_pid(i) < 0
        U_pid(i) = 0;
    end

    % Wartość sterowania w chwili
    G1 = U_pid(i);

    u(i) = U_pid(i)

    
    % Przesyłanie wartości do stanowiska
%     sendControls([ 1,5], [ W1,G1]);
    sendControls([1], [W1]);
    sendNonlinearControls(u(i))


    x(i) = i;
    plot(x, Y_pid);
    save('wykres_pid_1_lab3', 'x', 'Y_pid', 'u', 'Y_zad');
    drawnow;
    waitForNewIteration();
    i  = i+1;
end
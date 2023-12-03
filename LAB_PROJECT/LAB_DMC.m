clear all;
addpath('D:\SerialCommunication');
initSerialControl COM4 

%% Odopowiedź skokowa tor wej-wyj z punktu pracy !!!! skok do u=30 !!! najpierw wgrac odp skokowe
 
s_ob = zeros(1, lenght(pp30));
for i=1:length(pp30)
    s_ob(i) = (pp30(i) - 31) / 4;
end

%% Algorymt DMC

% Parametry DMC
D=400;
N=50;
Nu=5;
lambda = 10;

% macierz M obiektu
M=zeros(N,Nu); 
for i=1:Nu
    M(i:N,i)=s_ob(1:(N-i+1));
end


% macierz Mp obiektu
Mp=zeros(N, D-1);
po1 = 1; % pomocnicza1
po2 = 1; % pomocnicza2
for j=1:D-1
    for i=1:N

        if po1+1 >= D %   po pozycji D w macierszy s przyjmujemy ze s=s(D)
            po1 = D-1;
        end

        Mp(i,j)=(s_ob(po1+1)-s_ob(po2));
        po1 = po1+1;
    end
    po2 = po2+1;
    po1 = j + 1;
end

%% Skoki yzad

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
delta_up = zeros(D-1, 1);
e(1:steps_sym) = 0;


K = (M'*M + lambda*eye(Nu))^(-1) * M';
zmienna_trajektoria_zadana = true;

k=0;
while k<steps_sym

    temp1 = readMeasurements(1);

    y(k) = temp1;
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
    
    if u_k > 100
        u_k = 100;
        delta_u(1,1) = 100 - u(k-1);
    elseif u_k < 0 
        u_k = 0;
        delta_u(1,1) = 0 - u(k-1);
    end

    delta_up = [delta_u(1,1); delta_up(1:D-2)];

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

e = e.^2;
error_sum = sum(e)/steps_sym;

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





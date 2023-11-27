clear all;


%% Odopowiedź skokowa tor wej-wyj i zakłócenie-wyj

steps_os = 400;
k_step_os = 50;

% inicjalizacja potrzebnych macierzy
y(1:k_step_os) = 0;
u(1:k_step_os-1) = 0;
u(k_step_os:steps_os) = 1; 

% tor wej-wyj
for k=10:steps_os
    y(k) = symulacja_obiektu1y_p3(u(k-6), u(k-7), y(k-1), y(k-2)); % odp. skokowa
end

s_ob = y(k_step_os+1:steps_os); 

%% Algorymt DMC

% Parametry DMC
D=80;
N=15;
Nu=5;
lambda = 100;

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

% pętla symulacji 

steps_sym = 800; % steps_symulacji

% Momenty skoków yzad
k_step1 = 50; % k_step1 >= 12
k_step2 = 200;
k_step3 = 350;
k_step4 = 450;
k_step5 = 550;

% yzad
yzad(1:k_step1-1) = 0; 
yzad(k_step1:k_step2) = 1;  % yzad z  przedziału  <8.5, 12> bo ograniczenia na u 
yzad(k_step2-1:k_step3) = 4;
yzad(k_step3:k_step4-1) = 6;
yzad(k_step4:k_step5-1) = 8; 
yzad(k_step5:steps_sym) = 11;


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
    elseif u_k < -1 
        u_k = -1;
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





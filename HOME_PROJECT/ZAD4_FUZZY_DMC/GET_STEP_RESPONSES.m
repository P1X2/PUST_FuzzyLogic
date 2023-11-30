function [DP, step_responses] = GET_STEP_RESPONSES(fuzzy_intervals_cnt, duty_points)

%% y_max i y_min, bo rozmywamy po wyjsciu ob
y_max = 11.3;
y_min = 0.3;
diff = y_max - y_min;

% duty_points = [];
% fuzzy_intervals_cnt = 5;

%% Wyznaczanie rownomiernie rozłożonych punktów pracy, z których pozyskamy odpowiedzi skokowe
if isempty(duty_points)
    DP = zeros(1,fuzzy_intervals_cnt); % duty points
    x = diff/(fuzzy_intervals_cnt + 1);

    for i=1:fuzzy_intervals_cnt

        if i == 1
            DP(1,i) = y_min + x;
        elseif i == fuzzy_intervals_cnt
            DP(1,i) = y_max - x;
        else
            DP(1,i) = DP(i-1) + x;
        end

    end
    DP = sort(DP);
else
    DP = duty_points;
end

%% Wyznaczanie odpowiedzi skokowych w wyznaczonych/przekazanych punktach pracy ~ chyba działa, ale trzeba uważac

steps = 200;
k_step = 20;
step_responses = cell(1,fuzzy_intervals_cnt);

% char stat do wyznaczania U w pkt. pracy
u_stat = [-1:.0001:1];
y_stat = zeros(1, length(u_stat));
for i = 1: length(u_stat)
    y(1:steps) = 0;
    u(1:k_step-1) = 0;
    u(k_step:steps) = u_stat(i); 
    for k=10:steps
        y(k) = symulacja_obiektu1y_p3(u(k-6), u(k-7), y(k-1), y(k-2));
    end
    y_stat(i) = y(steps);
end

for i=1:fuzzy_intervals_cnt
    % inicjalizacja potrzebnych macierzy
    [~, col] = find(round(y_stat, 2) == round(DP(i),2)); % znalezienie indeksu y_stat = punktowi pracy y 
    U = u_stat(col(1, int32( length(col)/2 )) ); % i wykorzystanie tego indeksu do wyznaczenia sterowania U w chwilach przed skokiem sterowania
    y(1:k_step-1) = DP(i);
    u(1:k_step-1) = U;
    u(k_step:steps) = U + 0.05; 
    
    % tor wej-wyj
    for k=10:steps
        y(k) = symulacja_obiektu1y_p3(u(k-6), u(k-7), y(k-1), y(k-2)); % odp. skokowa
    end

    %normalizacja odp skokowej
    for k=1:length(y)
        y(k) = (y(k) - DP(i)) / 0.05;
    end
    
    step_responses{1,i} = y(k_step+1:steps);
end

end


function [DP, step_responses] = GET_STEP_RESPONSES(fuzzy_intervals_cnt, duty_points)

%% y_max i y_min, bo rozmywamy po wyjsciu ob
y_max = 11.3;
y_min = 0.3;
diff = y_max - y_min;

% duty_points = [];
% fuzzy_intervals_cnt = 2;

%% Wyznaczanie rownomiernie rozłożonych punktów pracy, z których pozyskamy odpowiedzi skokowe
if isempty(duty_points)
    DP = zeros(1,fuzzy_intervals_cnt); % duty point
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
    %%%%
end

%% Wyznaczanie odpowiedzi skokowych w wyznaczonych/przekazanych punktach pracy

steps_os = 150;
k_step = 20;
step_responses = cell(1,fuzzy_intervals_cnt);

for i=1:fuzzy_intervals_cnt
    % inicjalizacja potrzebnych macierzy
    y(1:k_step) = DP(i);
    u(1:k_step-1) = 0;
    u(k_step:steps_os) = 0.05; 
    
    % tor wej-wyj
    for k=10:steps_os
        y(k) = symulacja_obiektu1y_p3(u(k-6), u(k-7), y(k-1), y(k-2)); % odp. skokowa
    end

    %normalizacja
    y = y./0.05;
    
    step_responses{1,i} = y(k_step+1:steps_os); % sprawdzić czy z +1 lepiej czy gorzej
end

end


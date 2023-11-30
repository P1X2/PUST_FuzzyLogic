function [DP] = GET_DUTY_POINTS(fuzzy_intervals_cnt, duty_points)

%% y_max i y_min, bo rozmywamy po wyjsciu ob
y_max = 11.3;
y_min = 0.3;
diff = y_max - y_min;

% duty_points = [];
% fuzzy_intervals_cnt = 5;

%% Wyznaczanie rownomiernie rozłożonych punktów pracy
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


end


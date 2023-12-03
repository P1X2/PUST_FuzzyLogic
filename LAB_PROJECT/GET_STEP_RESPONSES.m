function [DP, step_responses] = GET_STEP_RESPONSES(pp30, pp50, pp70)


%% Wyznaczanie rownomiernie rozłożonych punktów pracy, z których pozyskamy odpowiedzi skokowe
DP = [30 50 70];

%% Wyznaczanie odpowiedzi skokowych w wyznaczonych/przekazanych punktach pracy ~ chyba działa, ale trzeba uważac

    %normalizacja odp skokowej
    for k=1:400
        s(k) = (pp30(k) - 31) / 4;
    end
    step_responses{1,1} = s(1:400);

    for k=1:400
        s(k) = (pp50(k) - 40) / 10;
    end
    step_responses{1,2} = s(1:400);

    for k=1:400
        s(k) = (pp70(k) - 47) / 10;
    end
    step_responses{1,3} = s(1:400);



end


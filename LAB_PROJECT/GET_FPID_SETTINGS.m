function [SETTINGS] = GET_FPID_SETTINGS(K, Ti, Td, Tp, fuzzy_interrvals_cnt)

% K = [.1 .13]; 
% Ti = [.3 5]; 
% Td = [.01 .01]; 
% Tp = 0.5; 
% fuzzy_interrvals_cnt = 2;

SETTINGS = cell(3, fuzzy_interrvals_cnt);

for i=1:fuzzy_interrvals_cnt
    r0 = K(i)*(1+(Tp/(2*Ti(i)))+(Td(i)/Tp));
    r1 = K(i)*((Tp/(2*Ti(i)))-((2*Td(i))/Tp)-1);
    r2 = (K(i)*Td(i))/Tp;

    SETTINGS{1, i} = r0;
    SETTINGS{2, i} = r1;
    SETTINGS{3, i} = r2;
end

end
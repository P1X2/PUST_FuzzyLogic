function [SETTINGS] = GET_FPID_SETTINGS(K, Ti, Td, Tp, fuzzy_interrvals_cnt)
SETTINGS = cell(3, fuzzy_interrvals_cnt);

for i=1:fuzzy_interrvals_cnt
    r0 = K*(1+(Tp/(2*Ti))+(Td/Tp));
    r1 = K*((Tp/(2*Ti))-((2*Td)/Tp)-1);
    r2 = (K*Td)/Tp;

    SETTINGS{1, fuzzy_interrvals_cnt} = r0;
    SETTINGS{2, fuzzy_interrvals_cnt} = r1;
    SETTINGS{3, fuzzy_interrvals_cnt} = r2;
end

end
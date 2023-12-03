function [matrices] = GET_DMC_MATRICES(D, N, Nu, lambda, fuzzy_interrvals_cnt, step_responses)

matrices = cell(2, fuzzy_interrvals_cnt);

for l=1:fuzzy_interrvals_cnt  
    %M
    M=zeros(N,Nu); 
    for i=1:Nu
        M(i:N, i)=step_responses{1, l}(1:(N-i+1));
    end
    
    %Mp
    Mp=zeros(N, D-1);
    po1 = 1; 
    po2 = 1; 
    for j=1:D-1
        for i=1:N
    
            if po1+1 >= D 
                po1 = D-1;
            end
    
            Mp(i,j)=(step_responses{1, l}(po1+1)-step_responses{1, l}(po2));
            po1 = po1+1;
        end
        po2 = po2+1;
        po1 = j + 1;
    end
    
    % K
    K = (M'*M + lambda(l)*eye(Nu))^(-1) * M';
   
    matrices{1, l} = K;
    matrices{2, l} = Mp;
    
end

end


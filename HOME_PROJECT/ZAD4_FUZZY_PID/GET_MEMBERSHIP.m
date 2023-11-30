function [membership_degree] = GET_MEMBERSHIP(Duty_point, process_output, fun_shape) % proces output = fancy y

    membership_degree = gbellmf(process_output, [fun_shape(1,1) fun_shape(1,2) Duty_point]); % a-szerokosc dzwona; b-stromosc dzwona; c-srodek dzwona = D

end
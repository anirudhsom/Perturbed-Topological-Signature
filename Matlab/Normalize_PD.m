% This function assumes PD = [birth-times, death-times], with 
% birth-time is less than or equal to the death-time along each row.

function [PD_normalized]= Normalize_PD(PD)

if isempty(PD)
    PD_normalized = [];
else
    PD_normalized = PD./max(PD(:,2));    
end
end
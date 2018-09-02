function [output] = Random_perturbation(PD, param)

m = param.m; 
factor = 1000;
max_displacement = param.max_displacement*factor;

if isempty(PD)
    output = [];
else
    % (birth+death)/2
    a = 0.5 * (PD(:,1)+PD(:,2));
    % (death-birth)
    b = PD(:,2)-PD(:,1);
    
    % Unperturbed PD
    PD_rp{1,1} = [a,b];
    
    % Creating randomly perturbed PDs
    rp_a = (randi([-max_displacement,max_displacement],length(a),m))/factor;
    rp_b = (randi([-max_displacement,max_displacement],length(a),m))/factor;
    rp_a = a+rp_a;
    rp_b = b+rp_b;
    
    for i = 1:m
       temp_a = rp_a(:,i);
       temp_b = rp_b(:,i);
       % Removing rows with a<0
       indices = find(temp_a<0);
       temp_a(indices) = [];
       temp_b(indices) = [];
       
       % Removing rows with b<0
       indices = find(temp_b<0);
       temp_a(indices) = [];
       temp_b(indices) = [];
       
       % Removing rows with a>1
       indices = find(temp_a>1);
       temp_a(indices) = [];
       temp_b(indices) = [];
       
       % Removing rows with b>1
       indices = find(temp_b>1);
       temp_a(indices) = [];
       temp_b(indices) = [];
       
       PD_rp{i+1,1} = [temp_a,temp_b];
        
    end
    output = PD_rp;
end
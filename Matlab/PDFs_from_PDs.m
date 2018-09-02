function [output] = PDFs_from_PDs(PD_perturbed,param)
   
sigma = [param.sigma 0 ; 0 param.sigma];
x1 = param.x1;
x2 = param.x2;
smooth_weight = param.smooth_weight;
m = param.m;
   
if isempty(PD_perturbed)
    HeatMap = zeros(length(x1),length(x2));
    for i = 1:(m+1)
        PDF{1,i} = HeatMap;
    end
else
    [X1, X2] = meshgrid(x1,x2);
    for i = 1:(m+1)
        HeatMap = zeros(length(x1),length(x2));
        PD_temp = PD_perturbed{i,1};
        for j = 1:size(PD_temp,1)
            mu = [PD_temp(j,1) PD_temp(j,2)];
            F = mvnpdf([X1(:) X2(:)],mu,sigma);
            F = reshape(F,length(x2),length(x1));
                
            if strcmp(smooth_weight,'no')
                HeatMap = HeatMap + F;
            else
                HeatMap = HeatMap + F*(PersDiag(i,2));
            end
        end
        HeatMap = reshape(HeatMap,length(x2)*length(x1),1);
        PDF{1,i} = HeatMap/(sum(HeatMap(:)));
        
end
output = PDF;
end
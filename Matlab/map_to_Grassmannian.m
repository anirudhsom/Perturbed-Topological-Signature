function [output] = map_to_Grassmannian(PD_pdf,param)

subspace_dimension = param.subspace_dimension;

x = cell2mat(PD_pdf);
x(isnan(x)) = 0;
x(isinf(x)) = 0;

[U,S,V] = svds(x,subspace_dimension);
output = U;
end
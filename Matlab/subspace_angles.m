function out = subspace_angles(X1,X2)

temp = X1'*X2;
[U,S,V] = svd(temp);

thetas = acos(diag(S));

%out = sum(sin(thetas).^2);
out = (sum((thetas).^2));

end

function d = distChordalGrass(A,B)
% Compute the chordal distance between the subspaces A and B. The bases A
% and B are assumed to be orthonormal and of same dimensions nxk

[n,k1] = size(A);
k2 = size(B,2);
assert(size(B,1) == n);
%disp('one done');
d = sqrt(max(k1,k2)-norm(A'*B,'fro')^2);
d=real(d);

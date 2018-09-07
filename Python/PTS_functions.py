import os
import numpy as np
from scipy import stats
from scipy.sparse.linalg import svds, eigs

######################################

def Normalize_PD(PD):
    '''
    This function assumes PD = [birth-times, death-times], with
    birth-time less than or equal to death-time along each row.
    '''
    if not list(PD):
        output = []
    else:
        output = PD/np.max(PD)

    return output

######################################

def Random_perturbation(PD,param):
    
    m = param.m
    max_displacement = param.max_displacement

    if not list(PD):
        output = []
    else:
        PD_rp = []
        # (birth+death)/2
        a = 0.5*(PD[:,0]+PD[:,1])
        # (death-birth)
        b = (PD[:,1]-PD[:,0])
        temp = np.zeros((len(a),2))

        # Unperturbed PD
        temp[:,0],temp[:,1] = a,b
        PD_rp.append(temp)

        # Creating randomly perturbed PDs
        rp_a = np.random.random((len(a),m))*(2*max_displacement) - max_displacement
        rp_b = np.random.random((len(a),m))*(2*max_displacement) - max_displacement
        rp_a = rp_a + a[:,None]
        rp_b = rp_b + b[:,None]

        for i in range(m):
            temp_a = rp_a[:,i]
            temp_b = rp_b[:,i]

            # Removing rows with a<0
            temp_a = temp_a[np.where(temp_a>0)]
            temp_b = temp_b[np.where(temp_a>0)]
            # Removing rows with b<0
            temp_a = temp_a[np.where(temp_b>0)]
            temp_b = temp_b[np.where(temp_b>0)]
            # Removing rows with a>1
            temp_a = temp_a[np.where(temp_a<1)]
            temp_b = temp_b[np.where(temp_a<1)]
            # Removing rows with b<0
            temp_a = temp_a[np.where(temp_b<1)]
            temp_b = temp_b[np.where(temp_b<1)]

            temp = np.zeros((len(temp_a),2))
            temp[:,0],temp[:,1] = temp_a,temp_b
            PD_rp.append(temp)

        output = PD_rp
    
    return output

######################################

def PDFs_from_PDs(PD,param):
    
    sigma = param.sigma
    x1, x2 = param.x1, param.x2 
    m = param.m
    PDF = []

    if not list(PD):
        HeatMap = np.zeros((x1+1,x2+1))
        for i in range(m):
            PDF.append(HeatMap)
    else:
        X1,X2 = np.meshgrid(np.arange(0,1.01,1/x1),np.arange(0,1.01,1/x2))
        positions = np.vstack([X1.ravel(),X2.ravel()])
        HeatMap = np.zeros((x1+1,x2+1))
        PD_temp = []
        for i in range(1+m):
            PD_temp = PD[i].T
            
            kernel = stats.gaussian_kde(PD_temp,sigma)
            Z = np.reshape(kernel(positions).T,X1.shape)
            HeatMap = HeatMap + Z
            HeatMap_temp = HeatMap.reshape((X1.shape[0]*X2.shape[1]))
            PDF.append(HeatMap_temp/np.sum(HeatMap_temp))
    
    output = PDF
    return output

######################################

def map_to_Grassmannian(PDF,param):
    
    subspace_dimension = param.subspace_dimension
    
    temp = np.column_stack(PDF)
    
    U, S, V = svds(temp, k=subspace_dimension)
    
    output = U
    
    return output
    
############################
## Importing packages
import os
import pickle
import numpy as np
import matplotlib.pyplot as plt

import utils # User-defined
import PTS_functions as ptsf # User-defined

############################
## Path to code and PDs
code_path = os.getcwd()
pd_path = code_path + '/Datasets'
pd_files = ['Persistence_Diagrams_SHREC10_SIHKS.pckl']

## Parameter Initialization
param = utils.DoDict()
# Number of random perturbations
param.m = 40
# Maximum allowable displacement of points in PD
param.max_displacement = 0.05
# Grid size of 2D PDF
param.x1 = 50
param.x2 = 50
# Standard deviation of Gaussian kernel function for KDE
param.sigma = 0.04
# Subspace dimension of PTS Grassmannian representations
param.subspace_dimension = 10

############################
## Extracting PTS features
for z in range(len(pd_files)):    
    # Loading PDs
    f = open(pd_path + '/' + pd_files[z],'rb')
    PDs = pickle.load(f)
    f.close()
    
    pds_per_shape = len(PDs[0][2])
    temp = pd_files[z].split('_')
    descriptor = temp[3][0:-5]
    
    print('\n\n********** Extracting '+descriptor+' PTS Features **********\n\n')
    
    save_folder_name = 'PTS_' + descriptor
    save_path = code_path + '/' + save_folder_name
    if not os.path.exists(save_path):
        os.makedirs(save_path)
        
    # Loop over shapes
    for i in range(len(PDs)):
        PD = PDs[i][2]
        PTS = []
        # Loop over PDs in each shape
        for j in range(pds_per_shape):
            
            # Normalizing PD w.r.t. maximum death-time observed in PD
            PD_normalized = ptsf.Normalize_PD(PD[j])
            
            # Creating set of randomly perturbed PDs
            Perturbed_PDs = ptsf.Random_perturbation(PD_normalized,param)
            
            # Creating 2D PDFs using kernel density estimation
            PDFs = ptsf.PDFs_from_PDs(Perturbed_PDs,param)
            
            # Mapping PDFs to a point on the Grassmannian
            PTS.append(ptsf.map_to_Grassmannian(PDFs,param))
        if not (i+1)%8:
            print('#', end =" ")
        
        f = open(save_path + '/' + PDs[i][0],'wb')
        pickle.dump(PTS,f)
        f.close()
        
    f = open(save_path + '/Parameters.pckl','wb')
    pickle.dump(param,f)
    f.close()

############################    
## Computing distance matrix
for z in range(len(pd_files)):
    # Loading PDs
    f = open(pd_path + '/' + pd_files[z],'rb')
    PDs = pickle.load(f)
    f.close()
    
    total_shapes = len(PDs)
    pts_per_shape = len(PDs[0][2])
    temp = pd_files[z].split('_')
    descriptor = temp[3][0:-5]
    
    distmat1 = np.zeros((total_shapes,total_shapes))
    distmat2 = np.zeros((total_shapes,total_shapes))
    time_taken_Chordal = []
    time_taken_SubspaceAngle = []
    
    save_folder_name = 'PTS_' + descriptor
    save_path = code_path + '/' + save_folder_name
    
    print('\n\n************ Computing Distance Matrix ************\n\n')
    
    for i in range(total_shapes):
        f = open(save_path + '/' + PDs[i][0],'rb')
        pts1 = pickle.load(f)
        f.close()
        for j in range(i,total_shapes):    
            f = open(save_path + '/' + PDs[j][0],'rb')
            pts2 = pickle.load(f)
            f.close()
            for k in range(len(pts1)):
                utils.tic()
                distmat1[i,j] = distmat1[i,j] + utils.subspace_angle(pts1[k],pts2[k])
                time_taken_SubspaceAngle.append(utils.toc())
                utils.tic()
                distmat2[i,j] = distmat2[i,j] + utils.distChordalGrass(pts1[k],pts2[k])
                time_taken_Chordal.append(utils.toc())
        if not (i+1)%8:
            print('#', end =" ")
    distmat = distmat1+distmat1.T
    f = open(code_path + '/distmat_SubspaceAngle_' + descriptor + '.pckl','wb')
    pickle.dump(distmat,f)
    f.close()
    
    time_taken_SubspaceAngle = time_taken_SubspaceAngle[0:3000]
    f = open(code_path + '/time_taken_SubspaceAngle_' + descriptor + '.pckl','wb')
    pickle.dump(time_taken_SubspaceAngle,f)
    f.close()
    print('\n\nAverage time taken to compare PTS features using Subspace Angles metric = '+str(np.round(np.mean(time_taken_SubspaceAngle),4)))
    
    distmat = distmat2+distmat2.T
    f = open(code_path + '/distmat_Chordal_' + descriptor + '.pckl','wb')
    pickle.dump(distmat,f)
    f.close()
    
    time_taken_Chordal = time_taken_Chordal[0:3000]
    f = open(code_path + '/time_taken_Chordal_' + descriptor + '.pckl','wb')
    pickle.dump(time_taken_Chordal,f)
    f.close()
    print('\n\nAverage time taken to compare PTS features using Chordal metric = '+str(np.round(np.mean(time_taken_Chordal),4)))
    
############################
## 1-Nearest neighbor classification
# Loading PDs
f = open(pd_path + '/' + pd_files[0],'rb')
PDs = pickle.load(f)
f.close()

labels = []
for i in range(len(PDs)):
    labels.append(PDs[i][1])

f = open(code_path + '/distmat_Chordal_SIHKS.pckl','rb')
distmat = pickle.load(f)
f.close()
accuracy = utils.NearestNeighbor(distmat,labels)
print('1-NN Classification Accuracy using Chordal metric = ',str(accuracy))

f = open(code_path + '/distmat_SubspaceAngle_SIHKS.pckl','rb')
distmat = pickle.load(f)
f.close()
accuracy = utils.NearestNeighbor(distmat,labels)
print('1-NN Classification Accuracy using Subspace Angle metric = ',str(accuracy))

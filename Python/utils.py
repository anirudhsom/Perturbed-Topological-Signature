import os
import time
import numpy as np

################################

def TicTocGenerator():
    # Generator that returns time differences
    ti = 0           # initial time
    tf = time.time() # final time
    while True:
        ti = tf
        tf = time.time()
        yield tf-ti # returns the time difference

TicToc = TicTocGenerator() # create an instance of the TicTocGen generator

# This will be the main function through which we define both tic() and toc()
def toc(tempBool=True):
    # Prints the time difference yielded by generator instance TicToc
    tempTimeInterval = next(TicToc)
    if tempBool:
        #print( "Elapsed time: %f seconds.\n" %tempTimeInterval )
        return np.round(tempTimeInterval,4)

def tic():
    # Records a time in TicToc, marks the beginning of a time interval
    toc(False)
    
################################

class DoDict(dict):
    def __init__(self, **kwds):
        self.update(kwds)
        self.__dict__ = self

################################

def NearestNeighbor(distmat,labels):
    test_labels = []
    predicted_labels = []
    counter = 0
    for i in range(len(labels)):
        d_temp = list(distmat[i,:])
        l_temp = labels.copy()
        d_temp.pop(i)
        l_temp.pop(i)

        test_labels.append(int(labels[i]))

        mn,idx = min( (d_temp[i],i) for i in range(len(d_temp)) )
        predicted_labels.append(int(l_temp[idx]))
        if int(labels[i]==l_temp[idx]):
            counter+=1
    
    return (counter*100/len(labels))

################################

def subspace_angle(p1,p2):

    temp = np.dot(p1.T,p2)
    U, S, V = np.linalg.svd(temp)
    S = np.round(np.array(S),4)
    thetas = np.arccos(S)
    
    output = np.sum(np.square(thetas))
    
    return output

def distChordalGrass(p1,p2):
    # Compute the chordal distance between the subspaces A and B. The bases A
    # and B are assumed to be orthonormal and of same dimensions nxk
    
    m1,n1  = p1.shape
    m2,n2  = p2.shape
    if m1==m2:
        output = np.sqrt(max([n1,n2]) - np.round(np.square(np.linalg.norm(np.dot(p1.T,p2),'fro')),4))
        return output
    else:
        print("Number of elements don't match")
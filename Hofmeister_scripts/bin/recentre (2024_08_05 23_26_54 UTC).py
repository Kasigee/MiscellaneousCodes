#!/usr/bin/env python3
###!/cm/software/apps/python/3.7.3/bin/python
import numpy as np
import sys
import os

np.set_printoptions(precision=8,suppress=True)
X=float(sys.argv[1])
Y=float(sys.argv[2])
Z=float(sys.argv[3])
#Rotation https://en.wikipedia.org/wiki/Rotation_of_axes#Generalization_to_several_dimensions
#tanthetat=o/a
#First rotation
theta=np.arctan(Y/X)
RotationMatrixA = [[np.cos(theta), np.sin(theta), 0], [-np.sin(theta), np.cos(theta), 0],  [0, 0, 1]]
NewCoords=np.matmul(RotationMatrixA,[X,Y,Z])
#print(X,Y,Z)
#print(NewCoords)

X2=float(NewCoords[0])
Y2=float(NewCoords[1])
Z2=float(NewCoords[2])
#print(X2,Y2,Z2)
#omega=np.arctan(X2/Z2)
#RotationMatrixB = [[np.sin(omega), 0, np.cos(omega)], [0, 1, 0], [np.cos(omega), 0, -np.sin(omega)]]
omega=np.arctan(Z2/X2)
RotationMatrixB = [[np.cos(omega), 0, np.sin(omega)], [0, 1, 0], [-np.sin(omega), 0, np.cos(omega)]]
NewCoords2=np.matmul(RotationMatrixB,[X2,Y2,Z2])
#print("NewCoords2=",NewCoords2)

##Test of bigger system
'''
TestMat=[[0, 0, 0],
        [1.7777, -0.0315357, -0.00400551],
        [-0.386932, -1.00087, 0.281646],
        [-0.367383, 0.267109, -1.01215],
        [-0.354864, 0.75338, 0.732969]]

TestMat=-0.1056571936 0.0235814378 0.0036327637
1.6720471371 -0.0079542437 -0.0003727455
-0.4925889287 -0.9772883268 0.2852790264
-0.4730400681 0.2906901748 -1.0085202366
-0.4605215651 0.7769615093 0.7366018179
'''

#TestMat=np.load('tmpCoordsMatrix.dat')
#TestMat=loadtxt("tmpCoordsMatrix.dat")
TestMat=np.genfromtxt("tmpCoordsMatrix2.dat",delimiter=' ')
#print(TestMat)
NewCoords3=np.matmul(RotationMatrixA,np.transpose(TestMat))
#print(NewCoords3)
NewCoords4=np.matmul(RotationMatrixB,NewCoords3)
print(np.transpose(NewCoords4))



'''
X=float(sys.argv[4])
Y=float(sys.argv[5])
Z=float(sys.argv[6])

NewCoords=np.matmul(RotationMatrixA,[X,Y,Z])
X2=float(NewCoords[0])
Y2=float(NewCoords[1])
Z2=float(NewCoords[2])
NewCoords2=np.matmul(RotationMatrixB,[X2,Y2,Z2])
'''

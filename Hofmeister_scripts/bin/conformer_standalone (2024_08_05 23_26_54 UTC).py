#!/usr/bin/python
from ase.atom import Atom
from ase.atoms import Atoms
from ase.calculators.neighborlist import *
from ase.data import *

from collections import namedtuple
from math import pi
from ase.io import read, write
import numpy as np
import argparse
import random

parser = argparse.ArgumentParser(description="Generate an input file with connectivity and bond info from an experimental cif.")
parser.add_argument("-i", "--input-prefix", nargs="?", type=str, default="in",
                                   help="coordinate input file, default=in")
parser.add_argument("-o", "--output-prefix", nargs="?", type=str, default="out",
                           help="output file for structure, default=out")
parser.add_argument("-e", "--extn", type=str, default="xyz",
                           help="extn (format) for the input/output coordinates, default=xyz")
parser.add_argument("-c", "--config_extn", type=str, default="txt",
                           help="extn (format) for the atom pairs, default=txt")


args = parser.parse_args()
input=args.input_prefix+'.'+args.extn
output=args.output_prefix+'.'+args.extn
config=args.input_prefix+'.'+args.config_extn

#Read in config file
#and define a namedtuple
Tagpair = namedtuple('Tagpair', ['a', 'b'])
tag_pairs=[]

with open(config) as f:
    for line in f.readlines():
        (first,second) =line.split()
        this_pair = Tagpair(int(first.strip()),int(second.strip()))
        tag_pairs.append(this_pair)

#read in the molecule and build the neighbour list
mol = read(input)
natoms = len(mol)

cov_rad=[]
for atom in mol:
    cov_rad.append(covalent_radii[atom.number])

nlist = NeighborList(cov_rad,self_interaction=False,bothways=True)
nlist.build(mol)

for tagpair in tag_pairs:
    initial_placement=True
    #print tagpair
    left = tagpair.a - 1 #atom number to python index
    right = tagpair.b - 1
    left_mask = np.array(np.zeros(natoms))
    right_mask = np.array(np.zeros(natoms))
    index_locked = np.array(np.zeros(natoms))
    #Now we need to traverse each half of the molecule and create the masks
    left_index_queue=[]
    right_index_queue=[]
    left_mask[left] = 1
    right_mask[right] = 1
    index_locked[left] = 1
    index_locked[right] = 1
    while(not all(index_locked)):
        if initial_placement:
            #LHS
            indices, offsets = nlist.get_neighbors(left)
            #print indices
            for index in indices:
                if index != right and index != left and not index_locked[index]:
                    left_mask[index] = 1
                    index_locked[index] = 1
                    left_index_queue.append(index)
                    left_anchor = index
            #RHS
            indices, offsets = nlist.get_neighbors(right)
            #print indices
            for index in indices:
                if index != right and index != left and not index_locked[index]:
                    right_mask[index] = 1
                    index_locked[index] = 1
                    right_index_queue.append(index)
                    right_anchor = index
            #and reset the flag
            initial_placement=False
            #print left_index_queue
            #print right_index_queue
        else:
            #LHS
            for index in left_index_queue:
                indices, offsets = nlist.get_neighbors(int(index))
                for index in indices:
                    if index != right and index != left and not index_locked[index]:
                        left_mask[index] = 1
                        index_locked[index] = 1
                        left_index_queue.append(index)
            #RHS
            for index in right_index_queue:
                indices, offsets = nlist.get_neighbors(index)
                for index in indices:
                    if index != right and index != left and not index_locked[index]:
                        right_mask[index] = 1
                        index_locked[index] = 1
                        right_index_queue.append(index)
    #ok. so we have our masks 
    #print left_mask
    #print right_mask
    accept_rotation = False
    while accept_rotation == False:
        this_dihedral=random.uniform(-pi,pi)
        #print "rotating dihedral ", left_anchor,left,right,right_anchor, " by ", this_dihedral
        mol.rotate_dihedral([left_anchor,left,right,right_anchor],this_dihedral,mask=left_mask)
        new_nlist = NeighborList(cov_rad,self_interaction=False,bothways=True)
        new_nlist.build(mol)
        #Have to test connectivity atom by atom
        for atom in mol:
            old_indices, offsets = nlist.get_neighbors(atom.index)
            new_indices, offsets = new_nlist.get_neighbors(atom.index)
            if set(old_indices) != set(new_indices):
                #print old_indices, " != ", new_indices
                #print "Connectivity different!"
                #undo the rotation
                mol.rotate_dihedral([left_anchor,left,right,right_anchor],-this_dihedral,mask=left_mask)
                break
        else:
            #We made it all the way to the end of the molecule
            accept_rotation = True

write(output,mol)    


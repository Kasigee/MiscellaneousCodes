#!/usr/bin/env python3

import argparse
import logging
import sys
import os
import numpy as np
import matplotlib.pyplot as plt

parser = argparse.ArgumentParser()
parser.add_argument("--verbose", action="store_true")
parser.add_argument("traj_file")
parser.add_argument("out_file")
args = parser.parse_args()

# set verbosity
if args.verbose:
    # more advanced setup to avoid matplotlib errors:
    log = logging.getLogger(__name__)
    log.setLevel(logging.DEBUG)
    
    console_handler = logging.StreamHandler()
    console_handler.setFormatter(logging.Formatter("%(levelname)s: %(message)s"))
    console_handler.setLevel(logging.DEBUG)
    
    log.addHandler(console_handler)
    log.info("Verbose Output Set")
else:
    log.basicConfig(format="%(levelname)s: %(message)s")


# function definitions:
def read_file_header(traj_file):
    with open(traj_file, "r") as f:
        atoms = int(f.readline().strip())
        return atoms


def velocity_generator(traj_file, natoms):
    data = np.zeros((natoms, 3))
    with open(traj_file, "r") as f:
        while True:
            header = f.readline().strip()
            if header == '':
                break

            comment = f.readline().strip()
            for i in range(natoms):
                data[i] = f.readline().strip().split()[5:]
            yield comment, data

def calc_norms(d):
    norms = np.linalg.norm(d, axis=1) #, keepdims=True)
    return norms


# main
def main():
    # check if files exist:
    log.info("Trajectory File: {}".format(args.traj_file))
    if not os.path.exists(args.traj_file):
        log.exception("{} doesn't exist".format(args.traj_file))
        raise FileNotFoundError

    log.info(".out File: {}".format(args.out_file))
    if not os.path.exists(args.out_file):
        log.exception("{} doesn't exist".format(args.out_file))
        raise FileNotFoundError

    log.info("Checked both files, continuing...")

    # get the number of atoms from .xyz file:
    natoms = read_file_header(args.traj_file)
    log.info("# Atoms = {}".format(natoms))

    # get the generator for the velocities
    # (iterates throug file and returns numpy array of velocity data for a single frame)
    frame_velocities = velocity_generator(args.traj_file, natoms)

    ax = plt.axes(projection='3d')

    for i in range(500):
        comment, vel = next(frame_velocities)
        if i % 100 == 0:
            log.info(">> {}".format(comment))
            norms = calc_norms(vel)

            # numpy.histogram(a, bins=10, range=None, weights=None, density=None)
            hist, bin_edges = np.histogram(norms, bins=10, density=True)
            xval = np.ones(hist.size) * i
            ax.plot3D(xval, bin_edges[:-1], hist, c='b')
#            ax.contour3D(xval, bin_edges[:-1], hist, cmap='binary')

    plt.show()

if __name__ == "__main__":
    main()
    sys.exit(0)

blah = '''
    for i in range(10):
        comment, vel = next(frame_velocities)
        log.info(">> {}".format(comment))
    
        norms = calc_norms(vel)
        # numpy.histogram(a, bins=10, range=None, weights=None, density=None)
        hist, bin_edges = np.histogram(norms)
    
        plt.plot(bin_edges[:-1], hist)
    
'''

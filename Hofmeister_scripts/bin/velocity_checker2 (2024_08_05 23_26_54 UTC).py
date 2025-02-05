#!/usr/bin/env python3

import argparse
import logging
import sys
import os
import numpy as np
import matplotlib.pyplot as plt

parser = argparse.ArgumentParser()
parser.add_argument("--verbose", action="store_true")
parser.add_argument("--savefig", action="store_true")
parser.add_argument("--histmax", type=int, default=100)
parser.add_argument("--histbins", type=int, default=100)
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

def calc_square_diff(hist1, hist2):
    return np.sum(np.square((hist2 - hist1)))

def window_average(data, window_size):
    moving_averages = []
    i = 0
    while i < len(data) - window_size + 1:
        window_average = np.sum(data[i:i+window_size]) / window_size
        moving_averages.append(window_average)
        i += 1

    return moving_averages


class OutputFileData:
    def __init__(self, output_file):
        self.output_file = output_file
        self.pressure = []                  # Pa
        self.potential_energy = []          # eV
        self.kinetic_energy = []            # eV
        self.total_energy = []              # eV
        self.temperature = []               # K

        self.read_file()


    def read_file(self):
        with open(self.output_file, "r") as f:
            data = f.readlines() # output file is only ~50 M, so fine to read into memory

        for line in data:
            if line.startswith("Pressure:"):
                self.pressure.append(float(line.strip().split()[3]))

            elif line.startswith("Potential Energy:"):
                self.potential_energy.append(float(line.strip().split()[4]))

            elif line.startswith("MD Kinetic Energy:"):
                self.kinetic_energy.append(float(line.strip().split()[5]))

            elif line.startswith("Total MD Energy:"):
                self.total_energy.append(float(line.strip().split()[5]))

            elif line.startswith("MD Temperature:"):
                self.temperature.append(float(line.strip().split()[4]))







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

#     comment, vel = next(frame_velocities)
#     norm1 = calc_norms(vel)
#     hist1, bin_edges1 = np.histogram(norm1, bins=100, density=False, range=(0,100))
# 
#     comment, vel = next(frame_velocities)
#     norm2 = calc_norms(vel)
#     hist2, bin_edges2 = np.histogram(norm2, bins=100, density=False, range=(0,100))
#     print(bin_edges2)
# 
#     test = calc_square_diff(hist1, hist2)
# 
#     print(test)



    log.info("Reading {} ...".format(args.out_file))
    test = OutputFileData(args.out_file)
    log.info("done")


    # initialise some stuff:
    sum_list = [] # probably could make numpy array if necessary for speedup

    hist_previous = None

    range_to_check = 500

    hist_range_max = args.histmax
    hist_bins = args.histbins

    for i in range(range_to_check):
        comment, vel = next(frame_velocities)
        if i % 100 == 0:
            log.info(">> {}".format(comment))
        hist, bin_edges = np.histogram(calc_norms(vel), bins=hist_bins, density=True, range=(0,hist_range_max))
       
        # if first iteration no need to run calc_square_diff()
        if i == 0:
            hist_previous = hist
            continue

        sum_list.append(np.sqrt(calc_square_diff(hist_previous, hist)))
        hist_previous = hist



    fig = plt.figure(figsize=(12,6))

    vel_ax = fig.add_subplot(2, 2, 1)
    hist_ax = fig.add_subplot(2, 2, 2)
    temp_ax = fig.add_subplot(2, 2, 3)
    toten_ax = fig.add_subplot(2, 2, 4)

    hist_ax.plot(bin_edges[:-1], hist)
    hist_ax.set_title("Last Histogram")
    hist_ax.set_xlabel("Bin Edge")
    hist_ax.set_ylabel("Density (normalised count)")


    vel_ax.plot(sum_list, label="Raw")
    vel_ax.plot(window_average(sum_list, 10), label="Window Ave 10")
    vel_ax.plot(window_average(sum_list, 25), label="Window Ave 25")
    vel_ax.legend()
    vel_ax.set_title("RMSD of delta Speeds")
    vel_ax.set_xlabel("Frame # (not actual timestep)")
    vel_ax.set_ylabel("RMSD")

    temp_ax.plot(test.temperature[:range_to_check])
    temp_ax.set_title("MD Temperature")
    temp_ax.set_xlabel("Frame # (not actual timestep)")
    temp_ax.set_ylabel("Temperature [K]")

    toten_ax.plot(test.total_energy[:range_to_check])
    toten_ax.set_title("MD Total Energy")
    toten_ax.set_xlabel("Frame # (not actual timestep)")
    toten_ax.set_ylabel("Energy [eV]")

    fig.tight_layout()
    fig.canvas.draw()

    if args.savefig:
        fig.savefig('output_figure.png')
    else:
        plt.show()

    # plt.show()

#     ax = plt.axes(projection='3d')

#     for i in range(100000):
#         comment, vel = next(frame_velocities)
#         if i % 1000 == 0:
#             log.info(">> {}".format(comment))
#             norms = calc_norms(vel)
# 
#             # numpy.histogram(a, bins=10, range=None, weights=None, density=None)
#             hist, bin_edges = np.histogram(norms, bins=100, density=True)
#             xval = np.ones(hist.size) * i
#             ax.plot3D(xval, bin_edges[:-1], hist, c='b')
# 
#     plt.show()

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

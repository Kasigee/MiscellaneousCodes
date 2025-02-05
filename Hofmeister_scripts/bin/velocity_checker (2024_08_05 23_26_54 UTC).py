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
parser.add_argument("--saveas", type=str, default='output_figure.png')
parser.add_argument("--histmax", type=int, default=75)
parser.add_argument("--histbins", type=int, default=50)
parser.add_argument("--traj_range", type=int, default=500)
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
    import logging as log
    log.basicConfig(format="%(levelname)s: %(message)s")


if args.savefig:
    print("Saving figure as: {}".format(args.saveas))



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
    return np.linalg.norm(d, axis=1) #, keepdims=True)

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
    # (iterates through file and returns numpy array of velocity data for a single frame)
    frame_velocities = velocity_generator(args.traj_file, natoms)

    log.info("Reading {} ...".format(args.out_file))
    test = OutputFileData(args.out_file)
    log.info("done")


    # initialise some stuff:
    sum_list = [] # probably could make numpy array if necessary for speedup

    hist_previous = None

    range_to_check = args.traj_range

    hist_range_max = args.histmax
    hist_bins = args.histbins

#    log.warning("Kas Accidentally duplicated the first 100 timesteps, skipping them")

    for i in range(100):
        next(frame_velocities)

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



    fig = plt.figure(figsize=(8,6))

    split = 0.0
    height = 0.5 - (split/2)
    top_bottom = 0.5 + (split/2)
    # left, bottom, width, height
    temp_ax = fig.add_axes((0.0, 0.0, 1.0, height))
#     eng_ax = temp_ax.twinx()
    rmsd_ax = fig.add_axes((0.0, top_bottom, 1.0, height), sharex=temp_ax)

    # RMSD plot
    rmsd_ax.plot(sum_list, label="Raw", alpha=0.2)

    # get the window average and shift it so its in the middle of the data it is averaging:
    window_size = 25
    window_median = 13
    
    window_ave_data = np.array(window_average(sum_list, window_size))
    window_ave_x = np.linspace(window_median, len(window_ave_data) + window_median, num=len(window_ave_data))

    rmsd_ax.plot(window_ave_x, window_ave_data, label="Ave {}".format(window_size))
    rmsd_ax.legend()
    rmsd_ax.tick_params(axis="x",direction="in", pad=-15)
    rmsd_ax.set_ylabel("Consecutive Frame RMSD [Å/ps]")

    # temperature and total energy plot (secondary y axis)
    temp_line = temp_ax.plot(test.temperature[0:range_to_check], c="C2", label = "Temperature")
    temp_ax.set_ylabel("Temperature [K]")
    temp_ax.set_xlabel("Time [ps]")
    print()

    positions = temp_ax.get_xticks()[1:-1]
    labels = [float(x)/100 for x in positions]
    temp_ax.set_xticks(positions, labels)

#     eng_line = eng_ax.plot(test.total_energy[100:range_to_check + 100], c="C4", label = "Total Energy")
#     eng_ax.set_ylabel("Total Energy [eV]")

    # get a common legend for temp/energy figure
    lines = temp_line # + eng_line
    labels = [l.get_label() for l in lines]
    temp_ax.legend(lines, labels)
    
    # remove tick labels from upper plot
    plt.setp(rmsd_ax.get_xticklabels(), visible=False)

    fig.canvas.draw()

    if args.savefig:
        fig.savefig(args.saveas, bbox_inches='tight')
    else:
        plt.show()

#    hist_ax.plot(bin_edges[:-1], hist)
#    hist_ax.set_title("Last Histogram")
#    hist_ax.set_xlabel("Bin Edge")
#    hist_ax.set_ylabel("Density (normalised count)")

if __name__ == "__main__":
    main()

#!/usr/bin/env python3
###!/lustre/rcghead1/users/kpg600/psi4conda/bin/conda

import MDAnalysis as mda
import MDAnalysis.analysis.msd as msd
import numpy as np
import matplotlib.pyplot as plt

from MDAnalysis.tests.datafiles import RANDOM_WALK, RANDOM_WALK_TOPO

print(RANDOM_WALK,RANDOM_WALK_TOPO)

u = mda.Universe(RANDOM_WALK, RANDOM_WALK_TOPO)
print("u=",u)
MSD = msd.EinsteinMSD(u, select='all', msd_type='xyz', fft=True)
MSD.run()


print(MSD)

msd =  MSD.results.timeseries

print(msd)

"""
nframes = MSD.n_frames
timestep = 1 # this needs to be the actual time between frames
lagtimes = np.arange(nframes)*timestep # make the lag-time axis
fig = plt.figure()
ax = plt.axes()
# plot the actual MSD
ax.plot(lagtimes, msd, lc="black", ls="-", label=r'3D random walk')
exact = lagtimes*6
# plot the exact result
ax.plot(lagtimes, exact, lc="black", ls="--", label=r'$y=2 D\tau$')
plt.show()
"""

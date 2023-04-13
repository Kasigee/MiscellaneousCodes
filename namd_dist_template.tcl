# Load trajectory and topology files
mol new fep_dir_LAMBDA/fep_test_TEMPERATURE.dcd type dcd first 0 last -1 step 1 filebonds 1 autobonds 1 waitfor all
mol addfile solvate_RADIUS.psf waitfor all

# Create atom selections for the two atoms
set atom1 [atomselect top "index 1"]
set atom2 [atomselect top "index 2"]

# Open the output file
set outfile [open "distances.dat" w]

# Loop over all frames
set numframes [molinfo top get numframes]
set numatoms [molinfo top get numatoms]


for {set k 1} {$k < $numatoms} {incr k 3} {
        set k_int [expr {int($k)}]
#       puts $k_int
        for {set i 0} {$i < $numframes} {incr i} {
                # Go to the current frame
                animate goto $i

                    # Measure the distance between the two atoms
                #set atom_ids [list [expr $atom1] [expr $atom2] [expr $k_int]]
#               puts $k_int
                set distance [measure bond [list 0 $k_int]]
                #set distance [measure bond {0 $k_int}]

            # Write the distance to the output file
            puts $outfile "$k $i $distance"
        }
}
# Close the output file
close $outfile

# Delete the atom selections
$atom1 delete
$atom2 delete
exit

import screenshot as SCR
from IPython.display import clear_output, display

folder_path = "SAPT_data_HaloAce_structures"
xyz_files = glob.glob(os.path.join(folder_path, "*.FINAL.xyz"))
xyz_files = [os.path.normpath(file) for file in xyz_files]
output_dir ="SAPT_data_HaloAce_structures/screenshots"
def process_batch(batch):
    for index, xyz_file in enumerate(batch):
        # Your processing code here
        # Perform your operations with the current file
        file_format='png'
        output_filename = f"{os.path.splitext(os.path.basename(xyz_file))[0]}.{file_format}"
        fullpath=output_dir +"/"+ output_filename
        print(fullpath)
        if os.path.exists(fullpath): #prevents overwriting. NOTE! Make sure the files have downloaded (or been moved) to the directory you are checking, otherwise this step won't work as intended.
            print(f"File already processed: {fullpath}")
        else:
            print(f"Processing file: {xyz_file}")
            atoms= SCR.save_xyz_screenshots_ase([xyz_file], output_dir)
            if index == len(batch) - 1:
                print(f"{xyz_file} is the last file in the batch.")
                return 'TRUE'


# Batch size
batch_size = 8 #beyond this and I appear to get memory issues for actually generating the view of the structures for them to save.

# Calculate the number of batches
num_batches = len(xyz_files) // batch_size + (1 if len(xyz_files) % batch_size != 0 else 0)

# Iterate over batches
for i in range(num_batches):
    print(f"Processing batch {i + 1} of {num_batches}")
    start = i * batch_size
    end = (i + 1) * batch_size
    current_batch = xyz_files[start:end]
    
    should_continue=process_batch(current_batch)
    if should_continue:
        break #required to allow saves within memory

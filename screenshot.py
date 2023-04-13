import os
from ase.io import read
from ase.io import write
from ase.geometry import find_mic
from ase import Atoms
from ase.constraints import FixAtoms
import nglview as nv
from IPython.display import display
import numpy as np
from PIL import Image
import shutil
import glob
import time
from PIL import Image
from PIL import ImageDraw
from PIL import ImageFont
import pandas as pd

def save_xyz_screenshots_ase(xyz_files, index1, index2, index3, output_dir, width=1000, height=600, file_format='png'):
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    for xyz_file in xyz_files:
        print(xyz_file)
        atoms = read(xyz_file)
#        indices = [22,5,23]  # Indices of the atoms you want to align in the xy-plane for NIPAM
#        indices = [0,1,2]  # Indices of the atoms you want to align in the xy-plane for water
        indices = [index1,inbdex2,index3]  # Indices of the atoms you want to align in the xy-plane for water
        
        
        atoms, pos = align_atoms_in_plane(atoms, indices)
        print(atoms.positions[indices[0]])
        print(atoms.positions[indices[1]])
        print(atoms.positions[indices[2]])

        view = nv.show_ase(atoms)
        view.parameters = {"clipDist": 0, "cameraType": "orthographic"}

        display(view)

        
        # Save the screenshot
        image_file = f"{os.path.splitext(os.path.basename(xyz_file))[0]}.{file_format}"
        final_image=output_dir+'/'+image_file
        print("image_file:",image_file)
        if not os.path.exists(image_file):
            view.download_image(filename=image_file, factor=1, antialias=3, trim=True, transparent=False)
        else:
            print(f"File {image_file} already exists. Skipping.")

      
        # Add text to the image
        img = Image.open(final_image)
        draw = ImageDraw.Draw(img)
        font = ImageFont.truetype("arial.ttf", 16)
        text = "Draft of this code"

        # Get dimensions of original image and text
        orig_width, orig_height = img.size
        text_width, text_height = draw.textsize(text, font=font)

        # Create new image with space for original image and text
        new_width = orig_width + text_width + 10
        new_img = Image.new('RGB', (new_width, orig_height), color=(255, 255, 255))

        # Draw original image on left side of new image
        new_img.paste(img, (0, 0))

        # Draw text on right side of new image
        draw = ImageDraw.Draw(new_img)
        draw.text((orig_width + 10, 10), text, font=font, fill=(0, 0, 0))

        # Save the new image
        new_image_file = os.path.join(output_dir, f"{os.path.splitext(os.path.basename(xyz_file))[0]}_with_text.{file_format}")
        new_img.save(new_image_file)
        print(f"Saved screenshot with text: {new_image_file}")
        

def rotation_matrix_from_axis_angle(axis, angle):
    """
    Computes the rotation matrix from a given rotation axis and angle.

    Parameters:
    axis (np.ndarray): A NumPy array of shape (3,) representing the rotation axis.
    angle (float): The rotation angle in radians.

    Returns:
    np.ndarray: A NumPy array of shape (3, 3) representing the rotation matrix.
    """
    axis = axis / np.linalg.norm(axis)  # Normalize the rotation axis
    cos_angle = np.cos(angle)
    sin_angle = np.sin(angle)

    # Outer product of the rotation axis with itself
    outer_product = np.outer(axis, axis)

    # Cross product matrix of the rotation axis
    cross_product_matrix = np.array([
        [0, -axis[2], axis[1]],
        [axis[2], 0, -axis[0]],
        [-axis[1], axis[0], 0]
    ])

    # Compute the rotation matrix using Rodrigues' formula
    rotation_matrix = np.eye(3) * cos_angle + outer_product * (1 - cos_angle) + cross_product_matrix * sin_angle
    return rotation_matrix



def align_atoms_in_plane(atoms, indices):
    # Get positions of atoms with specified indices
    pos = atoms.positions[indices]

    # Step 1: Translate positions so that atom at index 5 is at origin
    translation = -pos[0]
    atoms.positions += translation

    # Step 2: Rotate the molecule so that the second atom lies on the x-axis
    second_atom = atoms.positions[indices[1]]
    rotation_axis_2 = np.cross(second_atom, np.array([1, 0, 0]))
    rotation_angle_2 = np.arccos(np.dot(second_atom, np.array([1, 0, 0])) / np.linalg.norm(second_atom))
    rotation_matrix_2 = rotation_matrix_from_axis_angle(rotation_axis_2, rotation_angle_2)  # Function to compute rotation matrix from axis and angle
    atoms.positions = np.dot(atoms.positions, rotation_matrix_2.T)

    # Step 3: Rotate the molecule so that the third atom lies in the xy-plane
    third_atom = atoms.positions[indices[2]]
    third_atom_yz_projection = np.array([0, third_atom[1], third_atom[2]])
    rotation_axis_3 = np.cross(third_atom_yz_projection, np.array([0, 1, 0]))
    rotation_angle_3 = np.arccos(np.dot(third_atom_yz_projection, np.array([0, 1, 0])) / np.linalg.norm(third_atom_yz_projection))
    rotation_matrix_3 = rotation_matrix_from_axis_angle(rotation_axis_3, rotation_angle_3)  # Function to compute rotation matrix from axis and angle
    atoms.positions = np.dot(atoms.positions, rotation_matrix_3.T)

    return atoms, pos

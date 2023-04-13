!/home/575/kpg575/miniconda3/envs/my-rdkit-env/bin/python

import sys
import os
from rdkit import Chem
from rdkit.Chem import AllChem
from openbabel import pybel
from rdkit.Chem import rdFMCS
from rdkit.Chem import rdFingerprintGenerator
from rdkit.DataStructs import FingerprintSimilarity

def xyz_to_smiles(fname: str) -> str:
    mol = next(pybel.readfile("xyz", fname))
    smi = mol.write(format="smi")
    return smi.split()[0].strip()

def read_xyz_file(file_path):
    with open(file_path, 'r') as file:
        xyz_contents = file.read()
    return xyz_contents

def xyz_to_mol(xyz_coordinates):
    # Convert the XYZ coordinates to an Open Babel molecule
    ob_mol = pybel.readstring("xyz", xyz_coordinates)

    # Convert the Open Babel molecule to an RDKit molecule
    mol = None
    try:
        mol = Chem.MolFromMolBlock(ob_mol.write("mol"), removeHs=False)
    except ValueError:
        print("Error converting Open Babel molecule to RDKit molecule")

    return mol

#def identify_molecule(mol, reference_molecules):
#    best_match = None
#    best_match_atoms = 0
#
#    for ref_name, ref_mol in reference_molecules.items():
#        match = rdFMCS.FindMCS([mol, ref_mol])
#        if match.numAtoms > best_match_atoms:
#            best_match_atoms = match.numAtoms
#            best_match = ref_name
#
#    return best_match

def identify_molecule(mol, reference_molecules):
    best_match = None
    best_similarity = 0

    # Generate the fingerprint for the input molecule
    mol_fp = rdFingerprintGenerator.GetFPs([mol])[0]

    for ref_name, ref_mol in reference_molecules.items():
        # Generate the fingerprint for the reference molecule
        ref_fp = rdFingerprintGenerator.GetFPs([ref_mol])[0]

        # Calculate the Tanimoto similarity between the input molecule and the reference molecule
        similarity = FingerprintSimilarity(mol_fp, ref_fp)

        # Update the best match if the similarity is higher than the current best similarity
        if similarity > best_similarity:
            best_similarity = similarity
            best_match = ref_name

    return best_match



def save_fragments_as_xyz(mol):
    # Split the molecule into fragments
    fragments = Chem.GetMolFrags(mol, asMols=True)
    # Iterate through the fragments and save them as XYZ files
    for i, fragment in enumerate(fragments):
        fragment_xyz = Chem.MolToXYZBlock(fragment)
        print(f"Fragments are {fragment_xyz}")
        identified_molecule = identify_molecule(fragment, reference_molecules)
        print(f"Identified molecule: {identified_molecule}")
        with open(f"{identified_molecule}_fragment_{i+1}.xyz", "w") as f:
            f.write(fragment_xyz)

# Define a dictionary of reference molecules
reference_molecules = {
    "water": Chem.MolFromSmiles("O"),
    "methane": Chem.MolFromSmiles("C"),
    "ethanol": Chem.MolFromSmiles("CCO"),
    "protonated_histidine": Chem.MolFromSmiles("N[C@@H](CC1=CN[CH]N1)C=O"),
    "histidine": Chem.MolFromSmiles("N[C@@H](Cc1[nH]cnc1)C=O"),
    "lactate": Chem.MolFromSmiles("O[C@@H](C)C(=O)[O]"),
    "lactic_acid": Chem.MolFromSmiles("CC(O)C(=O)O"),
    # Add more molecules as needed
}

xyz_file_path = sys.argv[1]
smi = xyz_to_smiles(xyz_file_path)
print(smi)

xyz_coordinates = read_xyz_file(xyz_file_path)
mol = xyz_to_mol(xyz_coordinates)

# Identify the input molecule
identified_molecule = identify_molecule(mol, reference_molecules)

# Save the fragments of the input molecule as separate XYZ files
save_fragments_as_xyz(mol)

#!/usr/bin/python3
#  -*-  coding:  utf-8  -*-

"""Run the gdma tests.
"""

import argparse
import sys
# import re
import os
# import string
import subprocess

this = __file__
parser = argparse.ArgumentParser(
formatter_class=argparse.RawDescriptionHelpFormatter,
description="""Run the gdma tests.
""",epilog="""
{} [-p program-file] [ test test ... ]
""".format(this))


here = os.environ["PWD"]
base = "/home/kpg600"
program = os.path.join(base,"bin","gdma")
diff = os.path.join(base,"bin","gdma_diff.py")

parser.add_argument("tests", help="Test directories", nargs="*")
parser.add_argument("-p", help="Alternative gdma program file",
                    default=program)

args = parser.parse_args()

for test in sys.argv[1:]:
    os.chdir(test)
    print("----------")
    print(f"{test}:")
    for f in ["out", "punch"]:
        if os.path.exists(f): os.remove(f)
    with open("data") as D, open("out","w") as OUT:
        rc = subprocess.call([program], stdin=D, stdout=OUT, stderr=subprocess.STDOUT)
    if rc != 0:
        print(f"GDMA failed with return code {rc:1d}")
    os.chdir(here)


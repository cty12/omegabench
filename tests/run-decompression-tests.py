#!/usr/bin/env python

#
# The script is part of the Omegabench project.
#
# Author: Tianyu Chen
# Date: May 19, 2016
# Organization: Tsinghua University
#

import sys
import os
import shutil
import json
import urllib     # for downloading files
import subprocess
from termcolor import cprint

# print python version
cprint("The python version to use is: ", attrs=["bold"])
print (sys.version)

# get the directory the script is placed
curr_dir = os.path.dirname(os.path.realpath(sys.argv[0]))
print "current dir: ", curr_dir

with open(os.path.join(curr_dir, "configs", "xz-tests-config.json"), 'r') as config_file:
    config = json.load(config_file)

# get the file name of the test file
# we assume that the file name is the last part of the url
test_file_url = config["test_file_url"]
test_file_name = test_file_url.rsplit('/', 1)[-1]

# if the test file does not exist, download it from the url in the config file
if not os.path.exists(os.path.join(curr_dir, test_file_name)):
    cprint("Downloading " + test_file_name + " from " + test_file_url + " ...",
           "yellow", attrs=["bold"])
    download = urllib.URLopener()
    download.retrieve(test_file_url, os.path.join(curr_dir, test_file_name))
    cprint("Download complete! ", "green", attrs=["bold"])
else:
    cprint("Test file already exists! ", "green", attrs=["bold"])

# begins test...
tests_result = dict()
tests_result["total_time"] = dict()
# remove previous temp files
if os.path.isdir(os.path.join(curr_dir, "tmp")):
    cprint("Removing temporary files...", "yellow", attrs=["bold"])
    shutil.rmtree(os.path.join(curr_dir, "tmp"))
    cprint("Remove complete! ", "green", attrs=["bold"])
os.mkdir(os.path.join(curr_dir, "tmp"))
shutil.copyfile(os.path.join(curr_dir, test_file_name), os.path.join(curr_dir, "tmp", test_file_name))
# change working directory to tmp/
os.chdir(os.path.join(curr_dir, "tmp"))
# print the workding directory
cprint("Working dir changed to: " + os.getcwd(), attrs=["bold"])
uncompress_cmd = "time bash -c \"" + config["unxz"] + \
                    " -T " + str(config["xz-threads"]) + \
                    " --keep " + test_file_name + \
                    "; tar -xf " + os.path.splitext(test_file_name)[0] + "\""
uncompress_proc = subprocess.Popen(uncompress_cmd, shell=True, stdout=subprocess.PIPE)
rc = uncompress_proc.wait()
out, err = uncompress_proc.communicate()

if rc == 0:
    cprint("Test completed! Please check the report. ", "green", attrs=["bold"])
    print out
else:
    cprint("Test failed with return code " + str(rc), "red", attrs=["bold"])

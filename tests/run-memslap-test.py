#!/usr/bin/env python

#
# The script is part of the Omegabench project.
# Test the performance of memcached on multiple hosts.
#
# Author: Tianyu Chen
# Date: May 24, 2016
# Organization: Tsinghua University
#

import sys
import os
import subprocess                        # for forking subprocesses
import json                              # for parsing config file
import re                                # for searching in test result
from pprint import pprint                # for debug print
from termcolor import cprint, colored
from plotting import *                   # for plotting

# print python version
cprint("The python version to use is: ", attrs=["bold"])
print sys.version

# get the current directory from which the script runs
curr_dir = os.path.dirname(os.path.realpath(sys.argv[0]))
print "current dir: ", curr_dir

# open the configuration that is placed in the configs/ directory
with open(os.path.join(curr_dir, "configs", "memslap-tests-config.json"), 'r') as config_file:
    config = json.load(config_file)

# debug print
# pprint(config)

# test result
tests_result = dict()
tests_result["total_time"] = dict()

for ip_addr in config["ip_addr"]:
    hostname = ip_addr.encode("utf8")
    cprint("Benchmarking host " + hostname + "...", "cyan", attrs=["bold"])
    memslap_cmd = config["benchmark"] + \
        " -s " + hostname + ":" + str(config["port"]) + \
        " --concurrency=" + str(config["concurrency"]) + \
        " --execute-number=" + str(config["exec_num"])
    # for debug
    cprint(memslap_cmd, "yellow")
    memslap_proc = subprocess.Popen(memslap_cmd, shell=True, stdout=subprocess.PIPE)
    rc = memslap_proc.wait()
    out, err = memslap_proc.communicate()
    if rc == 0:
        cprint("Success! ", "green", attrs=["bold"])
        # total time loading data (lower is better)
        total_time = re.search(r"Took (\d+\.\d+) seconds to load data", out)
        total_time = float(total_time.group(1))
        tests_result["total_time"][hostname] = total_time
    else:
        cprint("Failed with code " + str(rc) + " !", "red", attrs=["bold"])
        if err is not None:
            print err
        sys.exit(1)

# draw table
table.draw(tests_result)
# draw bar chart
histogram.draw(tests_result)
# finished!
cprint("All finished! ", "green", attrs=["bold"])

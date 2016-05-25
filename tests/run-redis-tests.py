#!/usr/bin/env python

#
# The script is part of the Omegabench project.
# Tests the performance of redis on multiple hosts.
#
# Author: Tianyu Chen
# Date: May 25, 2016
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
with open(os.path.join(curr_dir, "configs", "redis-tests-config.json"), 'r') as config_file:
    config = json.load(config_file)

for ip_addr in config["ip_addr"]:
    hostname = ip_addr.encode("utf8")
    cprint("Benchmarking host " + hostname + "...", "cyan", attrs=["bold"])
    redis_bench_cmd = config["benchmark"] + \
        " -h " + hostname + \
        " -p " + str(config["port"]) + \
        " -c " + str(config["concurrency"]) + \
        " -n " + str(config["num_req"]) + \
        " -q "
    cprint(redis_bench_cmd, "yellow")
    redis_bench_proc = subprocess.Popen(redis_bench_cmd, shell=True, stdout=subprocess.PIPE)
    rc = redis_bench_proc.wait()
    out, err = redis_bench_proc.communicate()
    if rc == 0:
        cprint("Success! ", "green", attrs=["bold"])
        print out
    else:
        cprint("Failed with code " + str(rc) + " !", "red", attrs=["bold"])
        if err is not None:
            print err
        sys.exit(1)

#!/usr/bin/env python

#
# The script is part of the Omegabench Project.
# Install termcolor as dependency.
#
# Author: Tianyu Chen
# Date: May 16, 2016
# Organization: Tsinghua University
#

import sys
import subprocess                      # for executing shell commands
import json                            # for parsing config file
import re                              # for searching in ab output
import os
from pprint import pprint
from termcolor import cprint, colored  # for termianl colored output
from plotting import *                 # import the plot library

# print python version
cprint("The python version to use is: ", attrs=["bold"])
print (sys.version)

# get the current directory from which the script runs
curr_dir = os.path.dirname(os.path.realpath(sys.argv[0]))
print "current dir: ", curr_dir

# open the configuration that is placed in the same directory
with open(os.path.join(curr_dir, "configs", "ab-tests-config.json"), 'r') as config_file:
    config = json.load(config_file)

# the test results
tests_result = dict()
tests_result["time taken"] = dict()
tests_result["requests per second"] = dict()
tests_result["time per request"] = dict()
tests_result["transfer rate"] = dict()

for ip_addr in config["ip_addr"]:
    hostname = ip_addr.encode("utf8")
    cprint("Benchmarking host " + hostname + "...", "blue", attrs=["bold"])
    ab_cmd = config["ab"] + \
        " -n " + str(config["num_req"]) + \
        " -c " + str(config["concurrency"]) + \
        " http://" + hostname + ":" + str(config["port"]) + "/test.php"
    ab_proc = subprocess.Popen(ab_cmd, shell=True, stdout=subprocess.PIPE)
    rc = ab_proc.wait()
    out, err = ab_proc.communicate()

    # cprint("Return code: ", attrs=["bold"])
    # print rc
    if rc == 0:
        cprint("Success! ", "green", attrs=["bold"])
        # total time taken for tests (lower is better)
        time_taken = re.search(
            r"Time taken for tests:[ \t]+(\d+\.\d+) seconds", out)
        time_taken = float(time_taken.group(1))
        tests_result["time taken"][hostname] = time_taken
        # requests per second (higher is better)
        req_per_sec = re.search(
            r"Requests per second:[ \t]+(\d+\.\d+) \[#/sec\] \(mean\)", out)
        req_per_sec = float(req_per_sec.group(1))
        tests_result["requests per second"][hostname] = req_per_sec
        # time consumed per request (lower is better)
        time_per_req = re.search(
            r"Time per request:[ \t]+(\d+\.\d+) \[ms\] \(mean\)", out)
        time_per_req = float(time_per_req.group(1))
        tests_result["time per request"][hostname] = time_per_req
        # transfer rate (higher is better)
        transfer_rate = re.search(
            r"Transfer rate:[ \t]+(\d+\.\d+) \[Kbytes/sec\] received", out)
        transfer_rate = float(transfer_rate.group(1))
        tests_result["transfer rate"][hostname] = transfer_rate
    else:
        cprint("Failed with code " + str(rc) + "!",
               "red", attrs=["bold"])
        if err is not None:
            print err
        sys.exit(1)

# print performance report
pprint(tests_result)
# draw histogram
histogram.draw(tests_result)
# draw pretty table
table.draw(tests_result)

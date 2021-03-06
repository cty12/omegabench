#!/usr/bin/env python

#
# The script is part of the Omegabench project.
# Test the performance of multiple instances of mysql server
# on hosts with various performance levels.
#
# Author: Tianyu Chen
# Date: May 23, 2016
# Organization: Tsinghua University
#

import os
import sys
import subprocess                      # for forking subprocesses
import json                            # for parsing config file
import re                              # for searching in sysbench output
from pprint import pprint              # for debug print
from termcolor import colored, cprint
from plotting import *                 # the plot library

# print python version
cprint("The python version to use is: ", attrs=["bold"])
print (sys.version)

# get the current directory from which the script runs
curr_dir = os.path.dirname(os.path.realpath(sys.argv[0]))
print "current dir: ", curr_dir

# open the configuration that is placed in the configs/ directory
with open(os.path.join(curr_dir, "configs", "mysql-tests-config.json"), 'r') as config_file:
    config = json.load(config_file)

# debug print
# pprint(config)

# test results
tests_result = dict()
tests_result["total_time"] = dict()
tests_result["response_time_avg"] = dict()

for ip_addr in config["ip_addr"]:
    hostname = ip_addr.encode("utf8")
    cprint("Benchmarking host " + hostname + "...", "cyan", attrs=["bold"])
    sysbench_cmd = config["benchmark"] + \
        " --mysql-host=" + hostname + \
        " --mysql-user=" + config["user"] + \
        " --mysql-port=" + str(config["port"]) + \
        " --num-threads=" + str(config["threads"]) + \
        " --max-requests=" + str(config["max_req"]) + \
        " --test=$OMEGA_HOME/mysql/sysbench-0.5/sysbench/tests/db/oltp.lua" + \
        " --oltp-table-size=" + str(config["table_size"]) + \
        " --oltp-table-name=sbtest" + \
        " --mysql-db=" + config["database"] + \
        " --oltp-test-mode=complex" + \
        " --mysql-engine-trx=yes" + \
        " --mysql-table-engine=InnoDB" + \
        " --oltp-index-updates=" + str(config["index_update"]) + \
        " --oltp-non-index-updates" + str(config["non_index_update"]) + \
        "  run"
    # for debug
    cprint(sysbench_cmd, "yellow")
    sysbench_proc = subprocess.Popen(sysbench_cmd, shell=True, stdout=subprocess.PIPE)
    rc = sysbench_proc.wait()
    out, err = sysbench_proc.communicate()
    if rc == 0:
        cprint("Success! ", "green", attrs=["bold"])
        # total time consumed in benchmark (lower is better)
        total_time = re.search(r"total time:[ \t]+(\d+\.\d+)s", out)
        total_time = float(total_time.group(1))
        # the average response time (lower is better)
        response_time_avg = re.search(r"avg:[ \t]+(\d+\.\d+)ms", out)
        response_time_avg = float(response_time_avg.group(1))
        # for debug
        # print out
        # cprint("The total time is: " + str(total_time), attrs=["bold"])
        # cprint("The average response time is: " + str(response_time_avg), attrs=["bold"])
        tests_result["total_time"][hostname] = total_time
        tests_result["response_time_avg"][hostname] = response_time_avg
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

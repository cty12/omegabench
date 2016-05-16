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
from pprint import pprint
from termcolor import cprint, colored  # for termianl colored output

# print python version
cprint("The python version to use is: ", attrs=["bold"])
print (sys.version)

with open("tests-config.json", 'r') as config_file:
    config = json.load(config_file)

tests_result = dict()

for ip_addr in config["ip_addr"]:
    cprint("Benchmarking host " + ip_addr + "...", "blue", attrs=["bold"])
    ab_cmd = config["ab"] + \
        " -n " + str(config["num_req"]) + \
        " -c " + str(config["concurrency"]) + \
        " http://" + ip_addr + ":" + str(config["port"]) + "/test.php"
    ab_proc = subprocess.Popen(ab_cmd, shell=True, stdout=subprocess.PIPE)
    rc = ab_proc.wait()
    out, err = ab_proc.communicate()

    # cprint("Return code: ", attrs=["bold"])
    # print rc
    if rc == 0:
        cprint("Success! ", "green", attrs=["bold"])
        tests_result[ip_addr.encode("utf8")] = dict()
        # total time taken for tests (lower is better)
        time_taken = re.search(r"Time taken for tests:[ \t]+(\d+\.\d+) seconds", out)
        time_taken = float(time_taken.group(1))
        tests_result[ip_addr]["time taken"] = time_taken
        # requests per second (higher is better)
        req_per_sec = re.search(r"Requests per second:[ \t]+(\d+\.\d+) \[#/sec\] \(mean\)", out)
        req_per_sec = float(req_per_sec.group(1))
        tests_result[ip_addr]["requests per second"] = req_per_sec
        # time consumed per request (lower is better)
        time_per_req = re.search(r"Time per request:[ \t]+(\d+\.\d+) \[ms\] \(mean\)", out)
        time_per_req = float(time_per_req.group(1))
        tests_result[ip_addr]["time per request"] = time_per_req
        # transfer rate (higher is better)
        transfer_rate = re.search(r"Transfer rate:[ \t]+(\d+\.\d+) \[Kbytes/sec\] received", out)
        transfer_rate = float(transfer_rate.group(1))
        tests_result[ip_addr]["transfer rate"] = transfer_rate
    else:
        cprint("Failed with code " + str(rc) + "! Error log dumped. ", "red", attrs=["bold"])
        print err

# print performance report
pprint(tests_result)

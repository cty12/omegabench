#
# This script is part of the Omegabench project.
# Draw table from the benchmark results.
#
# Author: Tianyu Chen
# Date: May 17, 2016
# Organization: Tsinghua University
#

from prettytable import PrettyTable
from termcolor import cprint, colored


def draw(bench_res):
    cprint("Drawing table...", attrs=["bold"])
    tests = bench_res.keys()
    hosts = bench_res.values()[0].keys()

    table = PrettyTable()
    table.add_column(colored("FIELD", "yellow", attrs=["bold"]),
                     [colored(test, "yellow") for test in tests])
    for host in hosts:
        res_list = list()
        for test in tests:
            res_list.append(bench_res[test][host])
        table.add_column(colored("HOST " + host, "blue", attrs=["bold"]),
                         [colored(res, "blue") for res in res_list])
    print table

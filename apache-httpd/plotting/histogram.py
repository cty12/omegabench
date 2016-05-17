#
# The script is part of the Omegabench project.
# Draw bar plot from a dictionary
#
# Author: Tianyu Chen
# Date: May 17, 2016
# Organization: Tsinghua University
#

import numpy as np
import matplotlib.pyplot as plt
from termcolor import cprint


def draw(bench_res):
    cprint("Drawing histogram...", attrs=["bold"])

    fig_idx = 1
    for test in bench_res.keys():
        plt.figure(fig_idx)
        sample = bench_res[test]
        n_hosts = len(sample)
        plt.bar(range(len(sample)), sample.values(), align="center")
        plt.xticks(range(len(sample)), sample.keys(), rotation=25)
        plt.title(test)
        fig_idx += 1

    plt.show()

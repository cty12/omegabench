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
        jet = plt.get_cmap("jet")
        plt.bar(range(len(sample)), sample.values(), align="center",
                color=jet(np.linspace(0, 1.0, n_hosts)))
        plt.xticks(range(len(sample)), sample.keys(), rotation=25)
        plt.title(test)
        fig_idx += 1

    plt.show()

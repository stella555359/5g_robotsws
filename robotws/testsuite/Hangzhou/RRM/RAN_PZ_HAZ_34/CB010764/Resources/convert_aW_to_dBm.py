import math
import sys


def convert_aW_to_dBm(aW):
    return 10 * math.log10(1000 * aW * pow(10, -18))

import os
import re


def check_info_in_file(filepath, str, datestr):
    fh = open(filepath)
    output = fh.read().split("\n")
    for i in range(len(output)):
        line = output[i]
        # print(line)
        if line.find(str) == -1:
            continue
        if line.find(datestr) == -1:
            continue
        break
    try:
        assert i != len(output) - 1
    except Exception:
        raise Exception(
            "file cannot find str:%s or datastr:%s!" % (str, datestr)
        )
    fh.close()

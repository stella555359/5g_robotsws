#!/usr/bin/env python3
import sys


def Finder(filename):
    with open(filename) as f:
        lines = f.readlines()
    return [line.strip().replace(":", "") for line in lines if "BTS" in line]


if __name__ == '__main__':
    Finder(str(sys.argv))

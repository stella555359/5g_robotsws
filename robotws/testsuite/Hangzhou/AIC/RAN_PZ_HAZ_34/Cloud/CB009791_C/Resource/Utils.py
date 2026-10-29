import csv
import sys
import re
import os
import ast
import time
import json
from taf.transport.ssh import ssh


def NestedDictValues(d):
    for v in d.values():
        if isinstance(v, dict):
            yield from NestedDictValues(v)
        else:
            yield v


def GetPMCountersValues(counters):
    return list(NestedDictValues(counters))

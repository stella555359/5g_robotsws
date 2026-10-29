import re
from datetime import datetime


def Select_power_information_smod_AWHQN(str1):
    result = 0
    sfppower = 0
    hostpower = 0
    list1 = []
    list1 = str1.split('\n')
    line = list1[1]
    matchobj = re.search(r'"SfpPowerLevel":"(\d+)""HostPowerLevel":"(\d+)""', line)
    sfppower = int(matchobj.group(1))
    hostpower = int(matchobj.group(2))
    if sfppower <= hostpower:
        result = 1
    return result

import os
import sys
import argparse
import re


def get_user():
    f = os.popen('/usr/bin/whoami')
    return f.read().rstrip()


SYS_REL_URL = "https://artifactory-espoo1.ext.net.nokia.com/artifactory/mnp5g-central-public-local/System_Release"
user = get_user()
logFile = "/tmp/Wget.{}.log".format(user)
outputFile = "/tmp/Wget.{}.txt".format(user)
ListVersion = []


class WftVersion:
    def __init__(self, str):
        self.name = ""
        match = re.match("<a href=\"(.*)/\">.*/</a> *(.*) *-", str)
        if match:
            self.name = match.group(1)
            self.date = match.group(2)

    def matchVersion(self, version):
        if len(self.name) == 0:
            return False
        return self.name.startswith(version)


def read_arguments():
    global PcapFile, Load, Filter, LuaSharkRequired, AfPath
    parser = argparse.ArgumentParser(description="", formatter_class=argparse.RawTextHelpFormatter)
    parser.add_argument("Version",  help='Version Start name')
    args = parser.parse_args()
    return args


def getUrl(version):
    return "{}/{}/luashark-{}.zip".format(SYS_REL_URL, version, version)


def readRootUrl(version):
    cmd = "wget -o {} -O {} {}".format(logFile, outputFile, SYS_REL_URL)
    try:
        os.system(cmd)
        with open(outputFile, 'r') as resFile:
            for line in resFile:
                v = WftVersion(line)
                if v.matchVersion(version):
                    ListVersion.append(v)
    except Exception as e:
        print("EXCEPTION:{}".format(e))


def checkLuashark(wftVersion):
    url = getUrl(wftVersion.name)
    cmd = "wget -o {} -O {} {}".format(logFile, outputFile, url)
    try:
        os.system(cmd)
        with open(logFile, 'r') as log:
            for line in log:
                if "ERROR" in line:
                    return False
        return True
    except Exception as e:
        return False


# =======================================================================================
args = read_arguments()
print("Version={}".format(args.Version))
readRootUrl(args.Version)

for idx, v in enumerate(ListVersion):
    print("%-4d: NAME=%-20s DATE=%-20s LUASHARK:%s" % (idx, v.name, v.date, checkLuashark(v)))

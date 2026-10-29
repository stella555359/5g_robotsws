import sys
import os
import os.path
import StringTool
import tempfile
from datetime import datetime


def mkdirIfNotExist(pathname):
    if not os.path.isdir(pathname):
        os.mkdir(pathname)


def getTempDir():
    temp_path = "{}/{}".format(tempfile.gettempdir(), StringTool.getUserName())
    mkdirIfNotExist(temp_path)
    return temp_path


def getFileNameFromPath(path):
    return os.path.basename(path)


def getDirFromPath(path):
    return os.path.dirname(path)


def getFileExtension(path):
    return os.path.splitext(path)[1]


def getSnapshotPath(path, prefix, isTimeStamped, postfix):
    ts = ""
    if isTimeStamped:
        ts = ".{}".format(datetime.now().strftime("%Y%m%d_%H%M%S"))
    finalPath = "{}/{}{}{}.zip".format(path, prefix, ts, postfix)
    StringTool.datedConsole("    Generating snapshot:{}".format(finalPath))
    return finalPath


def isDryRun():
    for arg in sys.argv:
        if "dryrun" in arg:
            return True
    return False


def isRobotCmd():
    for arg in sys.argv:
        if arg.endswith("robot"):
            return True
    return False


def buildStatusFromFileInfo(isFileExist, isLink, linkedFile):
    type = "NO_FILE"
    linked = ""
    if isLink:
        linked = StringTool.getStringFromCmdReturn(linkedFile)
    if isFileExist and isLink:
        type = "LINK"
    elif isFileExist and not isLink:
        type = "FILE"
    elif not isFileExist and isLink:
        type = "BAD_LINK"
    return {'type': type, 'linked': linked}


def check_imported(packtocheck):
    result = packtocheck in list(sys.modules.keys())
    return result

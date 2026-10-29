import subprocess
import shlex
import sys
import os
import os.path
import time
import StringTool
import tempfile
from datetime import datetime
from copy import deepcopy
from robot.libraries.BuiltIn import BuiltIn
import logging


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


def copyInstance(inst):
    return deepcopy(inst)


def cleanUnusedFiles(filesToBeDel=['core.', 'disconnect']):
    robotDir = os.path.abspath(__file__).split('robotws')[0] + 'robotws'
    StringTool.datedConsole("Unused files:{} will be deleted from {}".format(filesToBeDel, robotDir))
    for fname in os.listdir(robotDir):
        for element in filesToBeDel:
            if fname.startswith(element):
                StringTool.datedConsole("File will be deleted: {}".format(fname))
                os.remove(os.path.join(robotDir, fname))


def TracedSleep(duration, msg):
    StringTool.datedConsole("{}. Waiting for {} seconds...".format(msg, duration))
    time.sleep(duration)


def execCmd(cmd):
    """
    Execute a system command, and retrieve and trace console result
    WARNING : do not use "|" mechanism in command
    """
    list = shlex.split(cmd)
    proc = subprocess.Popen(list, stdout=subprocess.PIPE,
                            stderr=subprocess.PIPE, shell=False)
    stdout, stderr = proc.communicate()
    retCode = proc.returncode
    assert retCode == 0, \
        "Error on command {}:ERR CODE={} SDTERR={}"\
        .format(cmd, retCode, stderr)
    return stdout.decode('utf-8')


def waitUntil(keyword, retry=120, retry_interval=5, *args, **kwargs):
    must_end = time.time() + retry
    while time.time() < must_end:
        try:
            if keyword(*args, **kwargs):
                return True
        except Exception:
            pass
        time.sleep(retry_interval)
    return False


def pmcDebug():
    simu_file = BuiltIn().get_variable_value('${simu_glo_pm_file}')
    if simu_file is not None:
        return True
    else:
        return False


def translate_classical_dict(modify_param):
    classical_list = []
    assert isinstance(modify_param, list)
    for p in modify_param:
        if 'nodeType' in p:
            p.pop('nodeType')
        classical_list.append(p)
    return classical_list


def translate_dict(modify_param, isAIC):
    if not isAIC:
        return translate_classical_dict(modify_param), None
    assert isinstance(modify_param, list)
    StringTool.datedConsole("LIST provided: \n{}\n".format(modify_param))
    vdu_list = []
    vcu_list = []
    for p in modify_param:
        list_final = []
        if isinstance(p['value'], list):    # we have an xml list
            temp_list = []
            i = 0
            for pdict in p['value']:
                for k, v in pdict.items():
                    param_out = p['parameter'] + '/' + str(i) + '/' + k
                    elem = dict(dist_name=p['dist_name'], parameter=param_out, value=v)
                    temp_list.append(elem)
                i += 1
            list_final = temp_list
        else:                               # we have a simple param
            list_final.append(p)

        if 'nodeType' in p:
            nodeType = p['nodeType'].lower()    # to be case insensitive (Vcu, VCU, vcu, vCu ...)
            p.pop('nodeType')
            if 'vcu' in nodeType:
                for e in list_final:
                    vcu_list.append(e)
            if 'vdu' in nodeType:
                for e in list_final:
                    vdu_list.append(e)
            if nodeType == 'classical':
                logging.warning(
                    "WARNING! parameter:{} IGNORED cause nodeType is 'Classical' on AIC".format(p['parameter']))
        else:
            logging.warning("WARNING! parameter: {} IGNORED cause no nodeType provided".format(p['parameter']))
    if len(vdu_list) == 0:
        vdu_list = None
    if len(vcu_list) == 0:
        vcu_list = None
    return vdu_list, vcu_list

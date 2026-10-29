import subprocess
import shlex
import sys
import os
import os.path
import time
import StringTool
import tempfile
import re
from datetime import datetime
from copy import deepcopy
from robot.libraries.BuiltIn import BuiltIn
from taf.ccs.aashell import aashell
from types import ModuleType
import logging
import random


def mkdirIfNotExist(pathname):
    if not os.path.isdir(pathname):
        os.mkdir(pathname)


def getTempDir():
    temp_path = "{}/{}".format(tempfile.gettempdir(), StringTool.getUserName())
    mkdirIfNotExist(temp_path)
    return temp_path


def rmdirIfExist(pathname):
    if os.path.isdir(pathname):
        for root, dirs, files in os.walk(pathname, topdown=False):
            for name in files:
                os.remove(os.path.join(root, name))
            for name in dirs:
                os.rmdir(os.path.join(root, name))
        return True
    return False


def removeTempDir():
    temp_path = "{}/{}".format(tempfile.gettempdir(), StringTool.getUserName())
    rm_return = rmdirIfExist(temp_path)
    return rm_return


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


def saveBasicFileWithDate(pathname, fileName, logpath):
    c1 = datetime.now().strftime("%Y")
    c2 = datetime.now().strftime("%m")
    c3 = datetime.now().strftime("%d")
    curDate = datetime.now().strftime("_%H%M%S_")
    fullDate = c1 + c2 + c3 + curDate
    newFile = fullDate + fileName
    cmd1 = pathname + '/' + fileName
    cmd2 = logpath + '/' + newFile
    os.system("cp {} {}".format(cmd1, cmd2))
    luaSource = pathname + '/' + fileName.split(".")[0] + '.' + 'lua'
    if os.path.exists(luaSource):
        luaDest = logpath + '/' + fullDate + fileName.split(".")[0] + '.' + 'lua'
        os.system("cp {} {}".format(luaSource, luaDest))


def saveBasicFileWithPattern(pathname, fileName, logpath, pattern=''):
    c1 = datetime.now().strftime("%Y")
    c2 = datetime.now().strftime("%m")
    c3 = datetime.now().strftime("%d")
    curDate = datetime.now().strftime("_%H%M%S_")
    fullDate = c1 + c2 + c3 + curDate
    # newFile = fullDate + pattern + fileName
    newFile = fullDate + fileName.split(".")[0] + '_' + pattern + '.' + fileName.split(".")[1]
    cmd1 = pathname + '/' + fileName
    cmd2 = logpath + '/' + newFile
    os.system("cp {} {}".format(cmd1, cmd2))
    luaSource = pathname + '/' + fileName.split(".")[0] + '.' + 'lua'
    if os.path.exists(luaSource):
        # luaDest = logpath + '/' + fullDate + pattern + fileName.split(".")[0] + '.' + 'lua'
        luaDest = logpath + '/' + fullDate + fileName.split(".")[0] + '_' + pattern + '.' + 'lua'
        os.system("cp {} {}".format(luaSource, luaDest))


def saveFileWithDateAndPattern(pathname, fileName, logpath, pattern=''):
    c1 = datetime.now().strftime("%Y")
    c2 = datetime.now().strftime("%m")
    c3 = datetime.now().strftime("%d")
    curDate = datetime.now().strftime("_%H%M%S_")
    fullDate = c1 + c2 + c3 + curDate
    newFile = fullDate + pattern + '_' + fileName
    cmd1 = pathname + '/' + fileName
    cmd2 = logpath + '/' + newFile
    os.system("cp {} {}".format(cmd1, cmd2))


def saveFileWithDateFilePattern(pathname, fileName, logpath, pattern=''):
    c1 = datetime.now().strftime("%Y")
    c2 = datetime.now().strftime("%m")
    c3 = datetime.now().strftime("%d")
    curDate = datetime.now().strftime("_%H%M%S_")
    fullDate = c1 + c2 + c3 + curDate
    newFile = fullDate + fileName.split(".")[0] + '_' + pattern + '.' + fileName.split(".")[1]
    cmd1 = pathname + '/' + fileName
    cmd2 = logpath + '/' + newFile
    os.system("cp {} {}".format(cmd1, cmd2))


def ExistAndSimilar(file1, file2):
    if not os.path.exists(file2):
        status = False
        StringTool.console("step2 file does not exist:{}".format(file2), isConsole=False, isLogFile=True)
    else:
        output = subprocess.check_output("diff {} {} | wc -l".format(file1, file2), shell=True)
        output = output.decode('UTF-8')
        output = output.strip()
        if output == '0':
            StringTool.console("step2 files are similar:{} {}".format(file1, file2), isConsole=False, isLogFile=True)
            status = True
        else:
            StringTool.console("step2 files are different:{} {}".format(file1, file2), isConsole=False, isLogFile=True)
            status = False
    return status


def ConvertFormatForPM(lis):
    ulist = list(set(lis))
    my_string = ', '.join(lis)
    return my_string


def RmDeplicate(lis):
    for i, element1 in enumerate(lis):
        for j, element2 in enumerate(lis):
            if i != j and element1 == element2:
                lis.remove(element2)
    return lis


def GenerateRandomNumber():
    return random.randint(0, sys.maxsize)


def isAgentCAOrAgentSim():
    type = "ERROR : Unknown Type - Please contact AF Team"
    if os.path.exists("/home/ute/testline_init_results/agent.log"):
        type = "agentCA"
    elif os.path.exists("/home/ute/testline_init_results/logs/INFO_log.txt"):
        type = "agentSIM"
    StringTool.printLineWithTitle("UTE Agent Information")
    StringTool.printHeaderLine("Detected Agent is:", type)
    return type


def extract_domain_from_rad(rad_id):
    if isinstance(rad_id, int):
        rad_id = hex(rad_id)
    # in the first 2 hex symbols is the domain
    return (str(rad_id))[0:4]


def get_listening_tcp_ports_for_aashell(tcp_port):
    tcp_ports = [line for line in tcp_port.split('\n') if line.startswith('tcp')]
    tcp_ports = [line for line in tcp_ports if '150' in line]
    tcp_ports = [re.search('150[0-9]+', line).group() for line in tcp_ports]
    StringTool.datedConsole("Aashell tcp ports: {}".format(str(tcp_ports)))
    return tcp_ports


def execute_aashell_command(command, pod, namespace,  tcp_port, proxy):
    tcp_ports = get_listening_tcp_ports_for_aashell(tcp_port)

    # Create and configure aashell instance
    AaShellLib = aashell()
    AaShellLib.create_aashell_cli(name=pod,
                                  hops=proxy,
                                  namespace=namespace,
                                  pod=pod,
                                  forwarding_port=tcp_ports[0],
                                  port=tcp_ports[0])
    AaShellLib.setup(pod)
    StringTool.datedConsole("Aashell command: {}".format(command))
    result = AaShellLib.execute_aashell_command(pod, command)
    AaShellLib.teardown(pod)
    return result


def execute_aashell_command_gNB(command, nodeAlias="gNB-aashell-session"):
    # Create and configure aashell instance
    AaShellLib = aashell()
    AaShellLib.create_aashell_cli(name=nodeAlias)
    AaShellLib.setup(nodeAlias)
    StringTool.datedConsole("Aashell command: {}".format(command))
    result = AaShellLib.execute_aashell_command(nodeAlias, command)
    StringTool.datedConsole("==> Result: {}".format(result))
    AaShellLib.teardown(nodeAlias)
    return result


def create_nsa_ue_id_list(data):
    # data looks like this:
    # [101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 121, 122, 123, 124, 125, 126, 127, 128, 129, 130, 151,
    #  152, 153, 154, 155, 156, 157, 158, 159, 160, 171, 172, 173, 174, 175, 176, 177, 178, 179, 180]
    #
    split_data = []
    temp_list = [data[0]]
    for i in range(1, len(data)):
        if data[i] == temp_list[-1] + 1:
            temp_list.append(data[i])
        else:
            split_data.append(temp_list)
            temp_list = [data[i]]
    # Append the last list
    split_data.append(temp_list)
    return split_data


def get_testline_name():
    # Returns the name of the Testline. Ex: 2_16_UTE5GCLASSICAL4246
    for module in sys.modules.copy().values():
        if type(module) is ModuleType:
            if "tl" in dir(module):
                return os.path.basename(os.path.dirname(module.__file__))
    raise Exception('No Testline Module Loaded!')


def check_if_cm_execution():
    # returns False if the test was launched by the CloudManager, otherwise returns True.
    cm_execution = os.environ.get("CM_EXECUTION_ID")
    StringTool.datedConsole(">>> SCOUT INFO : CM_EXECUTION_ID is: >{}<".format(cm_execution))
    return False if cm_execution is not None else True

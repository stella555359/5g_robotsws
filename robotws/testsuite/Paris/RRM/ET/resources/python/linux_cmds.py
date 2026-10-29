from __future__ import print_function
import os
import zipfile
import logging
import subprocess
import shlex
import sys
from robot.api import logger

"""
Set of static methods aiming at performing some generic system services
Also, many of them provide a trace in robotframework report
"""


# ===========================================================================
# Set of services to manage display in terminal/Robot traces
# ===========================================================================
# By default, we are in Robot scope. But it can be set to false
# in a non robot code
# For instance, in a python standalone script
RobotScope = True
# Toogle that can be used in a python standalone
# to manage additional traces in option
# In Robot scope, all traces are logged,
# whatever info() of verbose() service used
VerboseMode = False
# In case of error, no stop is performed.
# We continue, in order to collect list of all errors
# Final exit will be done by invoking final_diag()
NbError = 0


def set_robot_scope(isRobotScope=True):
    """
    To set robot scope or not (python standalone script)
    """
    global RobotScope
    RobotScope = isRobotScope


def set_verbose(verboseValue=True):
    """
    To activate verbose mode (only for non robot scope)
    """
    global VerboseMode
    VerboseMode = verboseValue


def console(str):
    """
    to trace a string in robot console
    """
    logger.console(str)


def info(msg, prefix="INFO"):
    """
    To print a message in robot traces (robot scope)
    or in terminal (python standalone script)
    """
    str = f"{prefix}:{msg}"
    if RobotScope:
        logging.info(str)
    else:
        print(str)


def verbose(msg):
    """
    To print a message if verbose mode is activated
    """
    if RobotScope:
        logging.info(f"{msg} VERB")
    elif VerboseMode:
        print(f"{msg} VERB")


def error(msg):
    """
    To print an error, and increment error counter
    """
    global NbError
    NbError = NbError + 1
    info(f"{msg} ERROR")


def error_if(condition=False, msg=None):
    """
    To print an error if a condition is met
    """
    if condition:
        error(f"{msg}")
    return condition


def error_if_else_info(condition=False, msg=None):
    """
    To print an error or an info upon condition is met or not
    """
    if condition:
        error(f"{msg}")
    else:
        info(f"{msg}")


def fatal(msg):
    if RobotScope:
        assert False, msg
    else:
        info(f"{msg}", "FATAL")
        sys.exit(-1)


def fatal_if(condition, msg):
    """
    To assert upon a condition is met or not
    """
    if condition:
        fatal(f"{msg}")


def final_diag():
    """
    invoke a fatal error if at least one error was met
    """
    if RobotScope:
        fatal_if(NbError > 0, f"{NbError} errors met")


def reset_error():
    """
    Reset the error counter
    """
    global NbError
    NbError = 0


def get_user():
    """
    retrieve name of user as logged on VM
    """
    return exec_w_ret('/usr/bin/whoami').rstrip()


def get_extension(file):
    """
    retrieve extension of a file (from its name or path)
    """
    return os.path.splitext(file)[1]


def get_name_from_extension(file):
    """
    retrieve name of a file (from its name or path)
    """
    base = os.path.basename(file)
    return os.path.splitext(base)[0]


def unzip_file(sourceDir, destDir):
    """
    unzip <sourceDir> file into <destDir> directory
    """
    info(f"Unzip {sourceDir} into {destDir}")
    zip_ref = zipfile.ZipFile(sourceDir, 'r')
    zip_ref.extractall(destDir)
    zip_ref.close()


def execute(cmd):
    """
    Execute a system command (no trace on result)
    """
    info(f"Execute:({cmd})")
    os.system(cmd)


def exec_w_ret(cmd):
    """
    Execute a system command, and retrieve and trace console result
    WARNING : do not use "|" mechanism in command
    """
    list = shlex.split(cmd)
    info(f"Execute:({list})")
    proc = subprocess.Popen(list, stdout=subprocess.PIPE,
                            stderr=subprocess.PIPE, shell=False)
    stdout, stderr = proc.communicate()
    retCode = proc.returncode
    assert retCode == 0, f"Error on command {cmd}:ERR CODE={retCode} SDTERR={stderr}"
    info(f"Return:{stdout}")
    return stdout.decode('utf-8')


def rm_if_exist(file):
    """
    remove a file only if it exists
    """
    info(f"Attempting to remove {file}")
    if not os.path.exists(file):
        info(f"File {file} not found, nothing to do")
    else:
        try:
            os.remove(file)
            info(f"File {file} properly removed")
        except OSError as err:
            info(f"ERROR:Unable to remove {file}:{err}")


if __name__ == "__main__":
    user = get_user()
    info(f"USER=({user})")
    listCmd = ["date", "ls -al", "echo Hello"]
    for cmd in listCmd:
        res = exec_w_ret(cmd)
        info(f"CMD=({cmd}) RES=({res})")

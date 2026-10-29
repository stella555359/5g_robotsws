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
    str = "{}:{}".format(prefix, msg)
    if RobotScope:
        logging.info(str)
    else:
        print(str)


def verbose(msg):
    """
    To print a message if verbose mode is activated
    """
    if RobotScope:
        logging.info(msg, "VERB")
    elif VerboseMode:
        print((msg, "VERB"))


def error(msg):
    """
    To print an error, and increment error counter
    """
    global NbError
    NbError = NbError + 1
    info(msg, "ERROR")


def error_if(condition=False, msg=None):
    """
    To print an error if a condition is met
    """
    if condition:
        error(msg)
    return condition


def error_if_else_info(condition=False, msg=None):
    """
    To print an error or an info upon condition is met or not
    """
    if condition:
        error(msg)
    else:
        info(msg)


def fatal(msg):
    if RobotScope:
        assert False, msg
    else:
        info(msg, "FATAL")
        sys.exit(-1)


def fatal_if(condition, msg):
    """
    To assert upon a condition is met or not
    """
    if condition:
        fatal(msg)


def final_diag():
    """
    invoke a fatal error if at least one error was met
    """
    if RobotScope:
        fatal_if(NbError > 0, "{} errors met".format(NbError))


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
    info("Unzip {} into {}".format(sourceDir, destDir))
    zip_ref = zipfile.ZipFile(sourceDir, 'r')
    zip_ref.extractall(destDir)
    zip_ref.close()


def execute(cmd):
    """
    Execute a system command (no trace on result)
    """
    info("Execute:({})".format(cmd))
    os.system(cmd)


def exec_w_ret(cmd):
    """
    Execute a system command, and retrieve and trace console result
    WARNING : do not use "|" mechanism in command
    """
    list = shlex.split(cmd)
    info("Execute:({})".format(list))
    proc = subprocess.Popen(list, stdout=subprocess.PIPE,
                            stderr=subprocess.PIPE, shell=False)
    stdout, stderr = proc.communicate()
    retCode = proc.returncode
    assert retCode == 0, \
        "Error on command {}:ERR CODE={} SDTERR={}"\
        .format(cmd, retCode, stderr)
    info("Return:{}".format(stdout))
    return stdout.decode('utf-8')


def rm_if_exist(file):
    """
    remove a file only if it exists
    """
    info("Attempting to remove {}".format(file))
    if not os.path.exists(file):
        info("File {} not found, nothing to do".format(file))
    else:
        try:
            os.remove(file)
            info("File {} properly removed".format(file))
        except OSError as err:
            info("ERROR:Unable to remove {}:{}".format(file, err))


if __name__ == "__main__":
    user = get_user()
    info("USER=({})".format(user))
    listCmd = ["date", "ls -al", "echo Hello"]
    for cmd in listCmd:
        res = exec_w_ret(cmd)
        info("CMD=({}) RES=({})".format(cmd, res))

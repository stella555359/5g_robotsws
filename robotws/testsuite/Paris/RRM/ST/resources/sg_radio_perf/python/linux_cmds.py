from __future__ import print_function
import os
import zipfile
import logging
import subprocess
import shlex
import sys
from robot.api import logger


"""
Set of functions performing some generic system services
"""
# By default, we are in Robot scope. But it can be set to false
# in a non robot code
# For instance, in a python standalone script
RobotScope = True


def info(msg, prefix="INFO"):
    """
    To print a message in robot traces
    """
    str = f"{prefix}:{msg}"
    logging.info(str)


def get_user():
    """
    retrieve name of user as logged on VM
    """
    return exec_w_ret('/usr/bin/whoami').rstrip()


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


def console(str):
    """
    to trace a string in robot console
    """
    logger.console(str)


def get_name_from_extension(file):
    """
    retrieve name of a file (from its name or path)
    """
    base = os.path.basename(file)
    return os.path.splitext(base)[0]


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

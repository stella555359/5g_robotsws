import os
import subprocess
from robot.libraries.BuiltIn import BuiltIn


def execute_command(command):
    command_list = command.split()
    return subprocess.check_output(command_list).decode("utf-8")


def get_cm_execution_id():
    return os.environ.get("CM_EXECUTION_ID")


def is_manual_execution():
    return False if get_cm_execution_id() else True


def get_testline_name_in_scout():
    hostname = execute_command('hostname').strip().split("-")
    tl_name = "_".join(hostname[:3])
    return f"{tl_name}"

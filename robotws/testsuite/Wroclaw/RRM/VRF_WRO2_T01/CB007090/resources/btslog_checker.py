import subprocess
import os
from robot.libraries.BuiltIn import BuiltIn


def check_if_message_appeared(message, path='/tmp/btslog2/'):
    output = subprocess.check_output("cat {} | grep '{}'".format(path, message), shell=True)
    if output:
        BuiltIn().log_to_console("'{}' message has been found".format(message))
        return True
    assert False, "Missing '{}' message.".format(message)


def kill_admin_process():
    os.system("pgrep node | xargs kill -9")

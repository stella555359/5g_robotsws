from robot.libraries.BuiltIn import BuiltIn
import re


# TAF & UTE Libraries:
from taf.transport.ssh import ssh


def generate_command(list_of_commands):
    command = ";".join(cmd for cmd in list_of_commands)
    return command

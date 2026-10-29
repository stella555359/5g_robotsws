"""
:copyright: Nokia Solutions and Networks
:author: Michal Gorski <michal.gorski@nokia.com>
:maintainer: Michal Gorski <michal.gorski@nokia.com>
"""

import os
import sys
from subprocess import Popen, PIPE
from robot.api import logger
from robot.libraries.BuiltIn import BuiltIn


REPOSITORY_ORIGIN = "git@wrgitlab.ext.net.nokia.com:RAN/robotws.git"
OUTPUT_DIR = BuiltIn().get_variable_value('${OUTPUT_DIR}')
DEFAULT_OUTPUT_LOG = "default_output.log"


def _run_process(args, shell=False):
    process_info = "RUN COMMAND: " + " ".join(args) + "\n"
    logger.info(process_info)

    process = Popen(args=args, shell=shell, stdout=PIPE, stderr=PIPE)
    output, error = process.communicate()

    if _is_not_empty(output):
        _log_as_info(process_info, output)

    if _is_not_empty(error):
        if process.returncode != 0:
            logger.error(error)
        else:
            _log_as_info(process_info, error)


def _is_not_empty(data):
    return data is not None and len(data) > 0


def _log_as_info(header, data):
    if len(data) <= 1000:
        logger.info(data)
    else:
        _log_to_file(DEFAULT_OUTPUT_LOG, header + _decode_bytes(data) + "\n\n")
        logger.info("output logged to file: " + DEFAULT_OUTPUT_LOG)


def _log_to_file(filename, data):
    with open(os.path.join(OUTPUT_DIR, filename), "a") as file:
        file.write(data)


def _decode_bytes(data):
    if isinstance(data, bytes):
        try:
            data = data.decode()
        except UnicodeDecodeError as decoding_error:
            logger.error(decoding_error)

    return str(data)


def _append_ssh_config():
    ssh_config = "/home/ute/.ssh/config"
    lines_to_add = [
        "Host wrgitlab.int.net.nokia.com",
        "    IdentityFile ~/.ssh/ca_ute_gitlab/id_rsa",
        "    User ca_ute_gitlab",
        "\n"
    ]

    logger.info("Appending SSH config")
    with open(ssh_config, "a") as file:
        file.write("\n".join(lines_to_add))

    logger.info("SSH config after procedure:")
    with open(ssh_config, "r") as file:
        content = file.read()
    logger.info(content)


def _git_remote_remove_origin():
    cmd = ["git", "remote", "remove", "origin"]
    _run_process(args=cmd)


def _git_remote_add_origin():
    cmd = ["git", "remote", "add", "origin", REPOSITORY_ORIGIN]
    _run_process(args=cmd)


def _git_pull_origin_master():
    cmd = ["git", "pull", "origin", "master"]
    _run_process(args=cmd)


def _git_fetch():
    cmd = ["git", "fetch"]
    _run_process(args=cmd)


def _git_pull():
    """Change repository from gerrit and pull the proper one."""
    _git_remote_remove_origin()
    _git_remote_add_origin()
    _git_pull_origin_master()
    _git_fetch()


def _git_checkout(branch_name):
    """ Switch to given branch.

    :param branch_name: name of desired branch
    """
    cmd = ["git", "checkout", branch_name]
    _run_process(args=cmd)


def update_repository_and_checkout_branch(branch_name):
    """ Update repository and checkout to given branch.

    :param branch_name: name of desired branch
    """
    _append_ssh_config()
    _git_pull()
    _git_checkout(branch_name)


def _remove_test_case_names(robot_command):
    """Remove "-t" options with corresponding test case names from robot_command.

    Removes from robot_command all "-t" elements together with test case names "test_*_name" associated with them.
    :param robot_command: command used to run robot script, in a form:
        ["robot", "-v", "variable:value", "-L", "TRACE", "-t", "test_1_name", "-t", "test_2_name",
         "-d", "/home/ute/test_results", "-V", "variable_file", "path_to_test_suite"]
    """
    for _ in range(robot_command.count("-t")):
        index = robot_command.index("-t")
        del robot_command[index:index + 2]


def _replace_path_to_test_suite(robot_command, test_suite_path):
    """Replace the path to test suite in robot_command with given test_suite_path.

    :param robot_command: command used to run robot script
    :param test_suite_path: path to test suite to run
    """
    robot_command[-1] = test_suite_path


def _append_path_to_output_directory(robot_command, new_output_directory):
    """Append the path to output directory in robot_command with new_output_directory.

    :param robot_command: command used to run robot script
    :param new_output_directory: directory in which logs shall be placed
    """
    output_directory_index = robot_command.index("-d") + 1
    robot_command[output_directory_index] = os.path.join(robot_command[output_directory_index], new_output_directory)
    logger.info("Logs from suite run will be placed in directory " + new_output_directory)


def _get_single_run_argfile():
    argfile_index = sys.argv.index("-A") + 1
    return sys.argv[argfile_index]


def _get_robot_command_based_on_argfile(argfile):
    with open(argfile, "r") as file:
        lines = file.readlines()

    command_line_options = []
    for line in lines:
        command_line_options.extend(line.split())

    return ["robot"] + command_line_options


def run_test_suite(test_suite_path):
    """ Run test suite provided by path.

    Suite is run with configuration options taken from single run argfile.txt.
    Test names, added with "-t" option, are removed.
    :param test_suite_path: path to test suite to run
    """

    argfile = _get_single_run_argfile()
    command = _get_robot_command_based_on_argfile(argfile)

    _remove_test_case_names(command)
    _replace_path_to_test_suite(command, test_suite_path)
    _append_path_to_output_directory(command, "INNER_RUN")

    _run_process(args=command)

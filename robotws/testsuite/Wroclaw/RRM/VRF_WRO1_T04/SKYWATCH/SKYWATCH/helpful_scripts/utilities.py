import os
import socket
from robot.libraries.BuiltIn import BuiltIn, RobotNotRunningError


def update_repo_symlink_if_needed(exec_dir):
    symlink_path = '/home/ute/test_repository'
    if os.path.islink(symlink_path):
        if os.readlink('/home/ute/test_repository') == exec_dir:
            return
        else:
            os.unlink(symlink_path)
    os.symlink(exec_dir, symlink_path)
    print(f"Symbolic link '{symlink_path}' updated to point to '{exec_dir}'.")


def get_robot_output_dir():
    try:
        return f'{BuiltIn().get_variable_value("${OUTPUT_DIR}")}/'
    except RobotNotRunningError:
        return None


def get_machine_name():
    return socket.gethostname()

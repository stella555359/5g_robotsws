"""
Keywords for the feature CB008242.

:copyright: Nokia Networks
:author: Sara Nowak
:contact: sara.nowak@nokia.com
"""

from robot.api import logger
import os
import six
import paramiko

ssh = paramiko.SSHClient()

RFRL_TRUNK_HWF_FLAG = "0x89008e=0"
RFRL_BRANCH_HWF_FLAG = "0x89008e=0"


class MissingBipLog(Exception):
    """This exception is raised when there is no BIP log in directory ."""
    pass


class CounterNotIncrementedError(Exception):
    """Throws when counter value was not incremented."""


class CounterNotFoundError(Exception):
    """Throws when counter container is empty."""


def get_bip_file_name(path):
    """
    Get Bip file name from path
    :param path: the path of bip file
    :return: name of the newest bip file from path
    """
    files = os.listdir(path)
    if len(files) == 0:
        raise MissingBipLog("No BIP log in directory.")
    paths = [os.path.join(path, basename) for basename in files]
    return max(paths, key=os.path.getctime)


def compare_counter_values(counters_a, counters_b):
    """
    Compares two counters values
    :param counters_a: first counter to compare
    :param counters_b: second counter to compare
    """

    if len(counters_a) == 0:
        raise CounterNotFoundError('First counter container is empty.')

    if len(counters_b) == 0:
        raise CounterNotFoundError('Second counter container is empty.')

    invalid_counters_msg = ''

    for label, value_a in counters_a.items():
        value_b = counters_b.get(label)
        logger.info(f'Counter {label} value change: {value_a} -> {value_b}')

        if value_a >= value_b:
            invalid_counters_msg += f'Counter {label} value was not incremented: {value_a} <= {value_b}\n'

    if len(invalid_counters_msg) != 0:
        logger.info(f'<b>{invalid_counters_msg}</b>', html=True)
        raise CounterNotIncrementedError(f'Some counter values were not incremented (details in log.html file).')


def get_swconfig(filename, swconfig_dir):
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(hostname="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu")
    sftp = ssh.open_sftp()
    if not os.path.exists(swconfig_dir):
        os.makedirs(swconfig_dir)
    swconfig_file = "{}/{}.txt".format(swconfig_dir, filename)
    sftp.get("/ffs/run/swconfig.txt", swconfig_file)
    ssh.close()
    return swconfig_file


def add_flag_to_swconfig(swconfig_dir):
    """
    Add new flag to software configuration file.
    :param swconfig_dir: path to swconfig file directory
    :return: None
    """
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(hostname="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu")
    hostname = six.ensure_text(ssh.exec_command("hostname")[1].read()).strip()
    secondary_smod_alias = "fct-4a" if "0a" in hostname else "fct-0a"
    ping_result = six.ensure_text(ssh.exec_command("ping -c 1 {}".format(secondary_smod_alias))[1].read()).strip()
    sftp = ssh.open_sftp()
    swconfig_backup_local = get_swconfig("swconfig_original", swconfig_dir)
    modified_swconfig_local = "{}/swconfig.txt".format(swconfig_dir)
    sftp.get("/ffs/run/swconfig.txt", swconfig_backup_local)
    with open(swconfig_backup_local, "r") as swconfig_bk, open(modified_swconfig_local, "w") as new_swconfig:
        for line in swconfig_bk:
            if RFRL_TRUNK_HWF_FLAG.split("=")[0] in line or RFRL_BRANCH_HWF_FLAG.split("=")[0] in line:
                continue
            new_swconfig.write(line)
        new_swconfig.write("\n{} #CU Overload Test flag".format(RFRL_BRANCH_HWF_FLAG))
        new_swconfig.write("\n{} #CU Overload Test flag".format(RFRL_TRUNK_HWF_FLAG))
    sftp.put(modified_swconfig_local, "/ffs/run/swconfig.txt")
    ssh.close()

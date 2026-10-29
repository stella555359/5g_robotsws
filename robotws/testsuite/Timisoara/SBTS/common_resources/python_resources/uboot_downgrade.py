from taf.rfrl.csv4all.resources.node.uboot_downgrade.uboot import CSV4ALLUboot
from taf.rfrl.csv4all.resources.node.ssh_manager.node_ssh_manager import NodeSSHManager
from taf.rfrl.csv4all.resources.utilities.utilities import test_logger

"""
File Overview:
This file contains a function `perform_uboot_downgrade` that is designed to execute a U-Boot firmware downgrade on a
target node, which in this context refers to a Base Transceiver Station (BTS). The code is based on CSV4ALL functions,
leveraging Nokia's CSV4ALL framework for node management and U-Boot operations.

Purpose:
The primary purpose of this file is to automate the process of downgrading U-Boot firmware on a node using SSH-based
management and U-Boot-specific utilities.
"""


def perform_uboot_downgrade():
    """
    Perform U-Boot Downgrade on a Target Node.

    This function facilitates the downgrade of U-Boot firmware on a specified node. It uses the NodeSSHManager
    to establish a connection to the node and the CSV4ALLUboot class to execute U-Boot-related operations.
    The function also logs the outcome of the downgrade process and returns whether a reboot is required.

    Returns:
        bool: True if the U-Boot downgrade was performed and a reboot is required, False otherwise.

    Raises:
        Exception: If any error occurs during node initialization, script preparation, or downgrade execution.
    """
    node = NodeSSHManager(node_alias='downgrade')
    uboot = CSV4ALLUboot(node)
    uboot.prepare_uboot_scripts()
    uboot.uboot_downgrade()
    if uboot.perform_reset:
        test_logger(msg='Uboot downgrade performed, reboot needed.')
    else:
        test_logger(msg='Uboot downgrade not performed.', log_level='WARN')
    return uboot.perform_reset

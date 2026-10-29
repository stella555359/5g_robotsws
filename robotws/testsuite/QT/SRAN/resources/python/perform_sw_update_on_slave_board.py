# -*- coding: utf-8 -*-
"""
:description: Functions to perform SW update on slave board, for Dualcore via ssh tunneling.
:copyright: Nokia Networks
:author: Mateusz Porzucek
:contact: mateusz.porzucek@nokia.com
"""

import sys
from taf.fdsw.rc import rc
from robot.libraries.BuiltIn import BuiltIn

taf_fdsw = rc()


def perform_sw_update_on_slave_board(
        ssh_host,
        ssh_username,
        ssh_password,
        sw_pkg_path):
    '''
    Perform SW update on slave board for Dualcore via ssh tunneling.
    :param ssh_host: IP address of the remote SSH server.
    :param ssh_username: Username to authenticate to the remote SSH server.
    :param ssh_password: Password to authenticate to the remote SSH server.
    :param sw_pkg_path: Absolute or relative path to software package (zip) that will be uploaded.
                        Should contain TargetBD file.
    :return: status of SW update.
    '''

    remote_connection = taf_fdsw.setup_remote(
        ssh_host=ssh_host,
        ssh_port=22,
        ssh_username=ssh_username,
        ssh_password=ssh_password)

    rc_connection = taf_fdsw.connect_to(
        ip_address="127.0.0.1",
        port=8888,
        username="Nemuadmin",
        password="nemuuser",
        secure=True)

    rc_connection.enable_ssh_service()
    rc_connection.disable_ethernet_port_security()
    sw_update = rc_connection.software_update(
        sw_pkg_path=sw_pkg_path,
        sw_slot_id=None,
        timeout=900,
        activate=True)
    try:
        rc_connection.disconnect()
        remote_connection.disconnect_remote(remote_connection=remote_connection)
    except Exception as e:
        print(f"An error occurred when disconnect connection: {e}")
    return sw_update


if __name__ == "__main__":
    func = sys.argv[1]
    ssh_host = sys.argv[2]
    ssh_username = sys.argv[3]
    ssh_password = sys.argv[4]
    sw_pkg_path = sys.argv[5]
    if func == "perform_sw_update_on_slave_board":
        perform_sw_update_on_slave_board(
            ssh_host, ssh_username, ssh_password, sw_pkg_path)
    else:
        logging.critical("Wrong arg provided.")

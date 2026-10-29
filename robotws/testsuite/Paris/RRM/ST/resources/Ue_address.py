"""
:copyright: Nokia Networks
:author: Yves Gorjux (SyVe)
:contact: yves.gorjux@nokia.com
"""

import time
import re

from taf.transport.ssh import ssh
from robot.libraries.BuiltIn import BuiltIn


rob = BuiltIn()
ssh_mgt = ssh()


def get_ue_ip_address(host, user, password):
    """
    Retrieve the UE IP address from Android.
    It should assert if there is no UE IP configuration
    :param host: IP address of the machine hosting the UE
    :param user: user name to be used for the connection to this machine
    :param password: password to be used for the connection to this machine
    :return: the UE IP address
    """
    # Open the connection to the machine hosting the UE
    cnx = ssh_mgt.connect_to(host, user, password)
    rob.log('Session opened: {}'.format(cnx), 'DEBUG')
    # Send the command to set Android in root mode
    cmd = 'adb root'
    result = ssh_mgt.execute(cmd, connection=cnx)
    rob.log('Set Android in root: {}'.format(result), 'DEBUG')
    # Send the command to retrieve the IP addresses of the UE
    time.sleep(1)
    cmd = 'adb shell ifconfig'
    result = ssh_mgt.execute(cmd, connection=cnx)
    rob.log('Android IP config 1st trial: {}'.format(result), 'DEBUG')
    if 'error: no devices/emulators found' in result:
        # wait some time and do a 2nd trial
        time.sleep(10)
        result = ssh_mgt.execute(cmd, connection=cnx)
        rob.log('Android IP config: 2nd trial {}'.format(result), 'DEBUG')

    # Retrieve the IP address
    re_ip_addr = re.compile(r'inet addr:(172\.[\d]*\.[\d]*\.[\d]*)')

    group_list = re_ip_addr.search(result)
    # If an IP address is found, the group list is not empty
    assert group_list, 'No IP address has been found in the UE IP configuration'
    ip_addr = group_list.groups()[0]
    rob.log('UE IP address: {}'.format(ip_addr), 'INFO')
    return ip_addr

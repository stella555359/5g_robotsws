"""
:copyright: Nokia Networks
:author: Marek Kieltyka <marek.kieltyka@nokia.com>
:maintainer: Marek Kieltyka <marek.kieltyka@nokia.com>
"""

from taf.transport.ssh import ssh


def reset_airphone():
    ssh_instance = ssh()
    ssh_instance.connect_to(hostname="192.168.200.1",
                            username="toor4nsn", password="oZPS0POrRieRtu")
    output = ssh_instance.execute("system-module-reboot; sleep 5; echo")
    rc = ssh_instance.get_exit_status()
    ssh_instance.disconnect()
    return rc, output

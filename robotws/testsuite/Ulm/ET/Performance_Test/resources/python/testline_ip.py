"""
This module provides functions for managing network interfaces and IP addresses on remote devices using SSH.

"""

import logging

from testsuite.Ulm.ET.Performance_Test.resources.python import taf_transport_ssh_wrapper as sshw


logger = logging.getLogger(__name__)


def reset_ip(connection: str):
    """
    Resets the network interface by bringing it down and up again.
    """
    reset_eth('eth3', connection=connection)
    reset_eth('eth4', connection=connection)


def reset_eth(eth: str, connection: str):
    """
    Resets the network interface by bringing it down and up again.
    """
    for cmd in [f"sudo ifdown {eth}", f"sudo ifup {eth}"]:
        sshw.execute(cmd, connection=connection)


def net_sctp_rto_min(connection: str, value: int = 100):
    """Sets the SCTP RTO minimum value on a remote device.

    Args:
        value: The new SCTP RTO minimum value.
        connection: The connection string to the remote device.
    """
    return sshw.execute(f'sudo sysctl net.sctp.rto_min={value}', connection=connection)


def add_ip(ip: str, eth: str, connection: str, subnet: int = 24):
    """Adds a single IP address to a given interface on a remote device.

    Args:
        ip: The IP address to add.
        eth: The name of the network interface.
        connection: The connection string to the remote device.
        subnet: The subnet mask for the IP address.
    """
    cmd = f'sudo ip addr add {ip}/{subnet} dev {eth}'
    return sshw.execute(cmd, connection=connection)


def add_ip_range(base_ip: str, start: int, end: int, eth: str, connection: str, subnet: int = 24):
    """Adds a range of IP addresses to a given interface on a remote device.

    Args:
        base_ip: The base IP address for the range.
        start: The starting IP address in the range.
        end: The ending IP address in the range.
        eth: The name of the network interface.
        connection: The connection string to the remote device.
        subnet: The subnet mask for the IP addresses.
    """
    for ip in range(start, end+1):
        add_ip(f"{base_ip}.{ip}", eth, connection, subnet=subnet)


def set_default_ips(connection: str):
    """Sets the default IP addresses on a remote device.

    Args:
        connection: The connection string to the remote device.
    """
    reset_ip(connection)
    add_ip_range('10.0.1', 2, 3, 'eth3', connection, subnet=24)
    add_ip_range('10.0.1', 121, 137, 'eth3', connection, subnet=24)

"""
BTS (Base Transceiver Station) utilities module.

This module provides functionality for managing and verifying BTS status and operations.
"""

from retrying import retry
from taf.sbts.oam.coam.admin import admin_interface_context
from taf.rfrl.bts.operations import verify_bts_is_up_and_on_air
from taf.transport.ssh import ssh
from testsuite.Wroclaw.RRM.resources.log.log import blog

_ssh = ssh()


@retry(wait_fixed=600, stop_max_attempt_number=120)
def wait_for_nr_cells_on_air() -> None:
    """
    Keeps checking cell's administrativeState and operationalState until they're on air.

    This function checks NR, LTE, and GSM cells and verifies their operational status.
    It retries every 600ms for up to 120 attempts.

    :return: None
    :raises AssertionError: If any cells are not on air after all retry attempts.
    """
    cell_types = ('nr', 'lte', 'gsm')
    not_on_air = []

    with admin_interface_context() as admin_connection:
        for cell_type in cell_types:
            cell_info = admin_connection.get_cells_info(cell_type=cell_type)
            for cell_status in cell_info:
                status = cell_status['status']
                energy_saving = status.get('EnergySaving', '').lower() == 'energysaving'
                operational = 'enabled' if not energy_saving else 'disabled'

                try:
                    if status['administrativeState'].lower() != 'locked':
                        assert status['operationalState'].lower() == operational
                        if cell_type == 'nr':
                            assert status['proceduralStatus'].lower() == 'configured'
                except AssertionError:
                    not_on_air.append(cell_status['id']['configuration'])

    assert not not_on_air, f"Following cells are not onAir:\n{chr(10).join(not_on_air)}"


def verify_bts_is_operational() -> None:
    """
    Verifies that the BTS is operational and checks for detected alarms.

    This function combines verification that BTS is up and on air with alarm checking.

    :return: None
    :raises Exception: If BTS is not operational or if there are unexpected alarms.
    """
    blog("Verifying the status of BTS.")
    verify_bts_is_up_and_on_air()


def setup_bts_ssh_connection(host: str = "192.168.255.129",
                             user: str = "toor4nsn",
                             password: str = "oZPS0POrRieRtu",
                             alias: str = "bts_ssh") -> None:
    """
    Sets up an SSH connection to the BTS.

    :param host: The BTS host address. Defaults to "192.168.255.129".
    :type host: str
    :param user: The SSH username. Defaults to "toor4nsn".
    :type user: str
    :param password: The SSH password. Defaults to "oZPS0POrRieRtu".
    :type password: str
    :param alias: The alias name for the SSH connection. Defaults to "bts_ssh".
    :type alias: str
    :return: None
    """
    _ssh.connect_to(host, user, password, alias=alias)


def disconnect_bts_ssh(alias: str = "bts_ssh") -> None:
    """
    Disconnects an SSH connection to the BTS.

    :param alias: The alias name of the SSH connection to disconnect. Defaults to "bts_ssh".
    :type alias: str
    :return: None
    """
    _ssh.disconnect(connection=alias)

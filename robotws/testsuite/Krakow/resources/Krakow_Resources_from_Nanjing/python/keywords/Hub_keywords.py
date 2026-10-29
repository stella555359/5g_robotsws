# -*- coding: utf-8 -*-
"""
Keywords for GNB - FSP device.


:copyright: Nokia Networks
:author: I_SC_KRK_PROD_NITROGEN_GMS
:contact: I_SC_KRK_PROD_NITROGEN@internal.nsn.com
:maintainer: I_SC_KRK_PROD_NITROGEN_GMS
:contact: I_SC_KRK_PROD_NITROGEN@internal.nsn.com

"""

__author__ = 'Tomasz Krol, Agnieszka Bylica, Adam Moszczynski'
__copyright__ = 'Copyright (C) 2019, Nokia'
__email__ = 'tomasz.krol@nokia.com, agnieszka.bylica@nokia.com, adam.1.moszczynski@nokia.com'


import time
import datetime
from taf.ul.sc.hub import Hub
from moler.util.moler_test import MolerTest
from moler.exceptions import NoResultSinceCancelCalled, CommandTimeout, CommandFailure, DeviceChangeStateFailure, \
    MolerException
from OAM5G_keywords import ping_host
from ta_moler.device.hub import Hub as MolerHub
from OAM5G_keywords import run_keyword_for_all_devices


def collect_snapshot_from_hub(device_name='GNB0_HUB0'):
    """
    Collect snapshot.

    :param device_name: name of the device, e.g 'GNB0_HUB0'
    :return: name of the snapshot file
    """
    now = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
    filename = "Hub_Snapshot_{}.zip".format(now)
    result = Hub(device_name=device_name, autoconnect=True).collect_snapshot(filename=filename)

    if result["SUCCESS"]:
        MolerTest.info("Logs from the Hub have been collected successfully")
    else:
        MolerTest.error("There was an error while collecting logs from the Hub")

    return filename


def download_snapshot_from_hub(output_dir, filename, device_name='GNB0_HUB0'):
    """
    Download snapshot file from Hub to local directory.

    :param output_dir: local directory to save snapshot
    :param filename: name of file to download
    :param device_name: name of the device, e.g 'GNB0_HUB0'
    :return: None
    """
    Hub(device_name=device_name, autoconnect=True).download_snapshot_from_hub(output_dir=output_dir, filename=filename)


@MolerTest.raise_background_exceptions(check_steps_end=True)
def check_cpri_link(device_name='GNB0_HUB0'):
    """
    Checks status of the CPRI link.
    If the status is not 0x...F it raises exception.

    :param device_name: name of the device, e.g 'GNB0_HUB0'
    :return: nothing
    """
    synced, value = Hub(device_name=device_name, autoconnect=True).get_cpri_link_status()

    if synced == 'Synced':
        MolerTest.info("CPRI link is synced")
    else:
        MolerTest.error("CPRI link is not synced - error code [{}]".format(value))

    MolerTest.steps_end()


@MolerTest.raise_background_exceptions(check_steps_end=True)
def check_if_antennas_detected(device_name='GNB0_HUB0', number_of_antennas=1, device=0, address=0):
    """
    Check if there is a record in the register corresponding to the given antenna parameters.

    :param number_of_antennas: number of antennas available
    :param device: device number
    :param address: antenna address
    :param device_name: name of the device, e.g 'GNB0_HUB0'
    :return: nothing
    """
    MolerTest.info("Checking if {} antennas detected on {}...".format(number_of_antennas, device_name))
    hub = wait_for_connection_to_hub(device_name=device_name)
    for i in range(number_of_antennas):
        detected_status = hub.get_ant_status(i, device, address)

        if detected_status == 'Detected':
            MolerTest.info('Ant {} is detected'.format(i))
        else:
            MolerTest.error('Ant {} is not detected'.format(i))

    MolerTest.steps_end()


@MolerTest.raise_background_exceptions(check_steps_end=True)
def check_if_antennas_detected_on_hubs(antennas_dict={'GNB0_HUB0': 1}, device=0, address=0):
    """
    Check if given number of antennas is detected on given Hubs.

    :param antennas_dict: hub device name and number of antennas available
    e.g. {
            'GNB0_HUB0' : 1
         }
    :param device: device number
    :param address: antenna address
    :return: nothing
    """
    for device_name in antennas_dict.keys():
        check_if_antennas_detected(device_name=str(device_name), number_of_antennas=antennas_dict[device_name],
                                   device=device, address=address)
    MolerTest.steps_end()


@run_keyword_for_all_devices(device_type=MolerHub)
def collect_snapshot_from_all_hubs(device_name):
    """
    Collect snapshot from all available Hubs.
    :return:
    """
    return collect_snapshot_from_hub(device_name=device_name)


def checking_banners_when_logging_in_into_hub(password):
    """
    Check if after trying to log into Hub banner about private system appears, and default password
    information appears after ssh
    :param password: string, password to Hub
    :return: out1, string with banner with information about private system
            out2, string with banner with information about default password
    """
    hub = Hub(autoconnect=False)
    hub.connect_to_hub()

    hub.device.goto_state("PROXY_PC")
    event_baner = hub.device.get_event(event_name="private_system", event_params={"till_occurs_times": 1})
    event_password = hub.device.get_event(event_name="warning_default_password",
                                          event_params={"till_occurs_times": 1})
    event_baner.start()
    event_password.start()
    cmd_ssh = hub.device.get_cmd(cmd_name="ssh",
                                 cmd_params={"login": "toor4nsn", "password": password, "host": '192.168.255.129',
                                             "expected_prompt": "toor4nsn@fzhub"})

    cmd_ssh()
    pwd = hub.device.get_cmd(cmd_name="pwd")
    pwd()
    hub.device.goto_state('PROXY_PC')
    try:
        event_baner.cancel()
        baner = event_baner.result()
    except NoResultSinceCancelCalled:
        baner = False

    try:
        event_password.cancel()
        passwrd = event_password.result()
    except NoResultSinceCancelCalled:
        passwrd = False

    return passwrd, baner


def ssh_to_hub(user, pwd, expected_prompt='>'):
    """
    SSH to Hub
    :param user: string, username
    :param pwd: string, password
    :param expected_prompt: string, expected prompt default '>'
    :return: None
    """
    hub = Hub(autoconnect=True)

    hub.device.goto_state("PROXY_PC")
    cmd_ssh = hub.device.get_cmd(cmd_name="ssh", cmd_params={"login": user, "password": pwd,
                                                             "host": "192.168.255.129",
                                                             "expected_prompt": expected_prompt
                                                             })
    cmd_ssh()


def creation_of_hubapp_user_on_hub():
    """
    Create new user named hubapp on Hub
    :return: None
    """
    hub = Hub(autoconnect=True)
    export_path = hub.device.get_cmd(cmd_name="export", cmd_params={"set_param": "PATH=$PATH:/usr/sbin"})
    export_path()
    switch_to_hubapp = hub.device.get_cmd(cmd_name="su", cmd_params={"login": "hubapp"})
    try:
        switch_to_hubapp()
        raise EnvironmentError("You can switch to hubapp without creating it before")
    except CommandFailure:
        pass

    create_hubapp = hub.device.get_cmd(cmd_name="useradd", cmd_params={"user": "hubapp"})
    create_hubapp()
    switch_to_hubapp = hub.device.get_cmd(cmd_name="su", cmd_params={"login": "hubapp"})
    switch_to_hubapp()
    go_back_to_root = hub.device.get_cmd(cmd_name="echo", cmd_params={"options": "goBackToRoot; exit"})
    go_back_to_root()
    remove_hubapp = hub.device.get_cmd(cmd_name="echo", cmd_params={
        "options": "removingHubapp; /usr/sbin/userdel hubapp; echo removingHubapp"
    })
    remove_hubapp()


def check_if_ssh_is_failing_with_credentials(user, pwd):
    """
    Check if logging in fails with incorrect credentials
    :param user: string,  username
    :param pwd: string, invalid password
    :return: None
    """
    hub = Hub(autoconnect=True)
    hub.device.goto_state("PROXY_PC")
    cmd_ssh = hub.device.get_cmd(cmd_name="ssh", cmd_params={"login": user, "password": pwd,
                                                             "host": "192.168.255.129"})
    try:
        cmd_ssh()
        raise EnvironmentError("SSH is not failing with credentials: \n user: {} \n password: {}".format(user, pwd))
    except CommandTimeout:
        pass


def change_password_on_hub(current_pwd, new_pwd):
    """
    Change password on Hub
    :param current_pwd: string, current password
    :param new_pwd: string, new password
    :return: None
    """
    hub = Hub(autoconnect=True)

    hub.device.goto_state("LINUX")
    change_password = hub.device.get_cmd(cmd_name="passwd", cmd_params={"current_password": current_pwd,
                                                                        "new_password": new_pwd})

    change_password()
    hub.device.goto_state('PROXY_PC')


def create_new_user(user, pwd):
    """
    Create new user on Hub
    :param user: string, name of new user
    :param pwd: string, password for new user
    :return: None
    """
    hub = Hub(autoconnect=True)
    add_user = hub.device.get_cmd(cmd_name="echo",
                                  cmd_params={"text": "addUser ; /usr/sbin/useradd {}".format(user)})
    add_user()
    change_password = hub.device.get_cmd(cmd_name="passwd", cmd_params={
        "current_password": "",
        "new_password": pwd,
        "user": user
    })
    change_password()


def check_if_there_were_failed_logins(count, user='toor4nsn', pwd='oZPS0POrRieRtu'):
    """
    Check banner about failure login attempts
    :param count: int, expected number of failed logins
    :param user: string with username, default toor4nsn
    :param pwd: string with password, default oZPS0POrRieRtu
    :return: None
    """
    hub = Hub(autoconnect=True)

    hub.device.goto_state("PROXY_PC")
    watcher = hub.device.get_event(event_name="failed_login_counter", event_params={"till_occurs_times": 1})
    watcher.start()
    ssh_to_hub(user, pwd, expected_prompt="toor4nsn")
    watcher.cancel()
    MolerTest.info(watcher.result())
    if watcher.result()[0]['named_groups']['ATTEMPTS_NR'] != count:
        raise EnvironmentError(
            "There is no msg about failed logins or the counter shows unexpected value. Counter value: {}".format(
                watcher.result()[0]['named_groups']['ATTEMPTS_NR']))


def remove_user_by_root(username):
    """
    Remove specific user from Hub
    :param username: string, name of the user
    :return: None
    """
    hub = Hub(autoconnect=True)
    rm_user = hub.device.get_cmd(cmd_name="userdel", cmd_params={"user": username})
    rm_user()


def ensure_there_is_no_conectivity_to_hub(host="192.168.255.129", packets_to_send=5):
    """
    Check if there is no connection to Hub.
    :param host: string, ip of the host
    :param packets_to_send: int, number of ping packets to be sent
    :return: None
    """

    MolerTest.info("Ensure that there is NO connectivity to HUB.")
    try:
        hub = Hub(autoconnect=True)
        ping_host(device=hub, host=host, state="PROXY_PC", packets_to_send=packets_to_send,
                  expected_packets_received=0)
    except DeviceChangeStateFailure:
        MolerTest.info("There is no connection to HUB Device")
    MolerTest.steps_end()


def ensure_there_is_conectivity_to_hub(host="192.168.255.129", packets_to_send=5):
    """
    Check if there is connection to Hub.
    :param host: string, ip of the host
    :param packets_to_send: int, number of ping packets to be sent
    :return: None
    """
    MolerTest.info("Ensure that connectivity to HUB exists.")
    hub = Hub(autoconnect=True)
    ping_host(device=hub, host=host, state="PROXY_PC", packets_to_send=packets_to_send,
              expected_packets_received=5)

    MolerTest.steps_end()


def perform_hub_reset():
    """
    Perform hub reset
    :return: None
    """
    hub = Hub(autoconnect=True)
    reset_hub = hub.device.get_cmd(cmd_name="reboot")
    reset_hub()


def power_management_ant(ant_id=1, state="off"):
    """
    Turn off power for specific ant's interface.
    :param ant_id: int, number of ant which port will be turned off
    :param state: string - on or off. If on - we turn on the interface, if off - we turn it off
    :return: None
    """
    hub = Hub(autoconnect=True)
    hub.device.goto_state("RFSW_CLI")
    change_power_ant = hub.device.get_cmd(cmd_name="poe_switch", cmd_params={"port": ant_id, "mode": state})
    change_power_ant()


def perform_reset_hub_from_asir_mgr(asimgr, rerun=1):
    """
    Perform Hub reset
    :param asimgr: object, asimgr
    :param rerun: number of tries, default 1
    :return: None
    """
    asimgr.goto_state(state="CLI")

    for i in range(rerun):
        resetunit_cmd = asimgr.get_cmd(cmd_name="resetunit", cmd_params={
            'ne': '192.168.255.129',
            'pw': 'Nemuadmin:nemuuser',
            'unit_type': 'ASIHUB',
            'number': 1
        })
        try:
            resetunit_cmd(timeout=180)
            break
        except MolerException as ex:
            MolerTest.warning("{}: cannot finish 'resetunit' cmd properly, retrying {} of {}".format(
                asimgr.name, i, rerun))
            MolerTest.sleep(seconds=10)
    else:
        MolerTest.error("{}: cannot finish 'resetunit' cmd properly! - '{}'".format(asimgr.name, ex))


def wait_for_connection_to_hub(device_name='GNB0_HUB0', timeout=330, step=10):
    """
    Wait for establishing ssh connection to Hub
    :param device_name: name of device e.g. GNB0_HUB0
    :param timeout: timeout for establishing connection
    :param step: step between tries
    :return: None
    """
    start_time = time.time()
    MolerTest.info("Wait for connection to Hub...")
    while (time.time() - start_time) < timeout:
        try:
            hub = Hub(device_name=device_name, autoconnect=True)
            return hub
        except CommandTimeout:
            MolerTest.warning("Can not establish connection to Hub. Retrying...")
            MolerTest.sleep(step)
    MolerTest.error("Failed to establish connection to Hub after retrying for {}".format(timeout))


def change_power_state_of_all_ants(ants_number=1, state="off"):
    """
    Change power state of ants interfaces.
    :param ants_number: int, number of configured ants
    :param state: string - on or off. If on - we turn on the interface, if off - we turn it off
    :return: None
    """
    hub = Hub(autoconnect=True)
    hub.device.goto_state("RFSW_CLI")
    for ant_number in range(ants_number):
        change_power_ant = hub.device.get_cmd(cmd_name="poe_switch", cmd_params={"port": ant_number, "mode": state})
        change_power_ant()

import datetime
import logging
import random
import string
import time
import copy

from moler.config import devices as dev_cfg
from taf.rfrl.utilities.tl_config import load_moler_configuration_from_tl
from taf.rfrl.bts.connections import device_aliases as connection_names
from taf.rfrl.utilities import tl_config
from moler.device import DeviceFactory
from moler.exceptions import DeviceFailure, CommandTimeout, InvalidStateError
from robot.libraries import DateTime
from taf.rfrl.bts.devices.exceptions import SshKeyNotExists, InvalidParameterValue


def _calc_time_diff(current_time, log_datetime):
    return DateTime.subtract_date_from_date(current_time, log_datetime)


def _generate_ssh_key():
    base_ssh_key = \
                    'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCmA2RbCPGDhYxnzm9+4mA5WEDlWodUyg/7aKgL/XTPd'\
                    'BevHs0mXkjc5DxJX1HVncDhg83XGEmrkK9OJsBU+Kml9CDcjlR1n+wGQY0xqy5PZee5wvFcjIdhH1Pi9/DNI'\
                    'NMK28EGGbHdmxc8xQNfdxfmV4ALMOwzk1SmITYiUXlUbuh161gNRKbCCCWKCWKSNbJwzObE6ip18cKJOvvjUtF'\
                    'Bct2GAMKrWIGgSn1QUBy+ttIpUXWzczmuUI9bRMGlNVoX9e+xmgeRNg89F3ynPXI7QmvSirFGWQBf2xXCmabY'\
                    '9oPb5uG15cgLtkC03214jQ4MlR8RgGmkhrEL{} test.mail@testers.com'

    changing_part = ''.join(random.sample(string.ascii_letters, 4))
    final_key = base_ssh_key.format(changing_part)
    logging.info("ssh-rsa new kew: {}".format(final_key))
    return final_key


@load_moler_configuration_from_tl()
def _verify_logs(number_of_connections, username, grep_phrase, bts_id=0):
    gnb = DeviceFactory.get_device(name=connection_names.ssh_gnb_cu.format(bts_id))
    gnb.goto_state("OAM")
    max_delta = 180
    log_file = '/mnt/log/master/fsaudit/auth.log'
    failures = []
    current_time = datetime.datetime.now()

    grep_cmd = gnb.get_cmd(cmd_name="grep",
                           cmd_params={
                               'options': ' -e "{}.*{}" {}  |'
                                          ' grep -v grep | tail -{}'.format(username,
                                                                            grep_phrase,
                                                                            log_file,
                                                                            number_of_connections)
                           })
    sudo_cmd = gnb.get_cmd(cmd_name="sudo",
                           cmd_params={
                               'cmd_object': grep_cmd
                           })
    grepped_logs = sudo_cmd()
    grepped_logs = grepped_logs['LINES']
    failures.append("Did not get any logs!") if len(grepped_logs) == 0 else None
    for log in grepped_logs:
        event_time = datetime.datetime.strptime(log.split('+')[0], "%Y-%m-%dT%H:%M:%S.%f")
        event_delta = _calc_time_diff(current_time, event_time)
        if event_delta > max_delta:
            failures.append("Event occured {} seconds ago, max is {}".format(event_delta, max_delta))
    assert failures == [] and len(grepped_logs) > 0, failures


def verify_logouts(number_of_connections, username, bts_id=0):
    _verify_logs(number_of_connections=number_of_connections,
                 username=username,
                 grep_phrase="terminated",
                 bts_id=bts_id)


def verify_ssh_keys(number_of_connections, bts_id=0):
    _verify_logs(number_of_connections=number_of_connections,
                 username="",
                 grep_phrase="ssh-rsa",
                 bts_id=bts_id)


@load_moler_configuration_from_tl()
def _add_ssh_public_key(ssh_key, gnb, username,  bts_id=0):
    """
    Add ssh public key via fsclish.

    :param ssh_key: full ssh-rsa key
    :param bts_id: id of bts from which the symptom report will be saved
    """
    options = 'user-management ssh-public-key user-key key "{}" user-name {}'.format(ssh_key, username)

    set_ssh_key = gnb.get_cmd(cmd_name='set',
                              cmd_params={'options': options})
    set_ssh_key()


@load_moler_configuration_from_tl()
def _verify_ssh_public_key_added_correctly(ssh_key, gnb, username,  bts_id=0):
    """
    Verify if SSH public key was added correctly.

    :param ssh_key: full ssh-rsa key
    :param bts_id: id of bts from which the symptom report will be saved
    """
    options = 'user-management ssh-public-key user-key user-name {}'.format(username)
    show_ssh_key = gnb.get_cmd(cmd_name='show',
                               cmd_params={'options': options})
    result = show_ssh_key()
    logging.info("Resulting key: {}".format(result))

    keys_list = []

    for item in result['RESULT']:
        for k, v in item.items():
            if k == 'Key':
                keys_list.append(v)
    if ssh_key in keys_list:
        logging.info("SSH public key added correctly")
    else:
        raise SshKeyNotExists("SSH public key: {} not in list of ssh keys".format(ssh_key))


@load_moler_configuration_from_tl()
def _delete_ssh_public_key(gnb, username, bts_id=0):
    """
    Delete ssh public key via fsclish.

    :param bts_id: id of bts from which the symptom report will be saved
    """
    options = 'user-management ssh-public-key user-key user-name {}'.format(username)
    delete_ssh_key = gnb.get_cmd(cmd_name='delete',
                                 cmd_params={'options': options})
    delete_ssh_key()


@load_moler_configuration_from_tl()
def create_multiple_ssh_connections(number_of_connections, username, bts_id=0):
    gnb = DeviceFactory.get_device(format(connection_names.ssh_gnb_cu.format(bts_id)))
    gnb.goto_state("SERVICE_USER")
    number_of_connections = int(number_of_connections)
    devices = [gnb]

    for i in range(number_of_connections):
        devices.append(DeviceFactory.get_cloned_device(gnb, "GNB_CU_Connection{}".format(i+1)))

    for device in devices:
        device.goto_state("OAM")
        device.goto_state("FSCLISH")
        new_ssh_key = _generate_ssh_key()
        _add_ssh_public_key(new_ssh_key, device, username)
        _verify_ssh_public_key_added_correctly(new_ssh_key, device, username)
        _delete_ssh_public_key(device, username)


@load_moler_configuration_from_tl()
def verify_f1_link_ssh_connection(bts_id=0, du_id=0):

    gnb = DeviceFactory.get_device(format(connection_names.ssh_gnb_cu.format(bts_id)))
    gnb.goto_state("CPIF")
    options = '-o BatchMode=no -o PasswordAuthentication=yes -o PreferredAuthentications=password'
    credentials = tl_config.get_du_lmp_credentials(bts_id, du_id)
    f1cplane_addr = tl_config.get_du_f1_plane_addresses(bts_id, du_id)['f1_cplane']
    username = credentials['username']
    password = credentials['password']
    ssh_cmd = gnb.get_cmd(cmd_name='ssh',
                          cmd_params={
                             'login': username,
                             'host': f1cplane_addr,
                             'password': password,
                             'encrypt_password': True,
                             'options': options
                          })
    sudo_cmd = gnb.get_cmd(cmd_name="sudo",
                           cmd_params={
                               'cmd_object': ssh_cmd
                           })
    exit_cmd = gnb.get_cmd(cmd_name='exit',
                           cmd_params={
                               'expected_prompt': r'(robot|root)@.*'
                           })
    try:
        sudo_cmd()
        exit_cmd()
    except DeviceFailure:
        logging.error("SSH connection to DU cannot be established")


@load_moler_configuration_from_tl()
def _verify_clientAlive_values(gnb, value=1):
    options = '-i clientalive /etc/ssh/sshd_config'
    grep_cmd = gnb.get_cmd(cmd_name='grep',
                           cmd_params={
                               'options': options
                           })
    grep_out = grep_cmd()

    alive_interval, alive_count_max = grep_out['LINES'][0], grep_out['LINES'][1]
    alive_interval = int(alive_interval[-3:])
    alive_count_max = int(alive_count_max[-1])
    value_to_sec = int(value) * 60
    actual_value = alive_count_max * alive_interval
    if actual_value != value_to_sec:
        raise InvalidParameterValue('Wrong alive timer value. Expected: {}, actual: {}'.format(value_to_sec,
                                                                                               actual_value))


@load_moler_configuration_from_tl()
def _modify_rule_in_iptables(test_pc, insert=True):
    if insert:
        options = '-I OUTPUT -p tcp --dport 22 -j DROP'
    else:
        options = '-D OUTPUT -p tcp --dport 22 -j DROP'
    iptables_cmd = test_pc.get_cmd(cmd_name='iptables',
                                   cmd_params={
                                       'options': options
                                   })
    sudo_cmd = test_pc.get_cmd(cmd_name='sudo',
                               cmd_params={
                                   'cmd_object': iptables_cmd
                               })
    sudo_cmd()


@load_moler_configuration_from_tl()
def verify_ssh_session(value=1, bts_id=0, du_id=0):
    gnb = DeviceFactory.get_device(format(connection_names.ssh_bts_du.format('GNB', bts_id, du_id)))
    test_gnb_name = _generate_gnb_device(gnb)
    test_gnb = DeviceFactory.get_device(test_gnb_name)
    test_pc = DeviceFactory.get_device('TEST_PC')
    test_pc.goto_state('UNIX_LOCAL')
    _verify_clientAlive_values(test_gnb, value)

    for i in range(2):
        try:
            test_cmd = test_gnb.get_cmd(cmd_name='enter')
            _modify_rule_in_iptables(test_pc, insert=True)
            if i == 0:
                time.sleep(15)
            else:
                time.sleep(60)
            _modify_rule_in_iptables(test_pc, insert=False)
            test_cmd()
        except CommandTimeout:
            if test_gnb.current_state == 'FCT':
                raise InvalidStateError('SSH session not dropped! Current state should be equal to PROXY_PC')
        else:
            if test_gnb.current_state != 'FCT':
                raise InvalidStateError(
                    'SSH session dropped. Current state: {}. Expected: {}'.format(test_gnb.current_state, 'FCT'))


@load_moler_configuration_from_tl()
def verify_sshSessionLoginDelayTimer_parameter(timeout=20, bts_id=0, du_id=0):
    ws = DeviceFactory.get_device(format(connection_names.ws_du.format('GNB', bts_id, du_id)))
    credentials = tl_config.get_du_lmp_credentials(bts_id, du_id)
    username = credentials['username']
    password = credentials['password']
    host = credentials['host']
    passwords = ['WRONGPASS', password]
    for i in range(2):
        ssh_cmd = ws.get_cmd(cmd_name='ssh',
                             cmd_params={
                                 'login': username,
                                 'host': host,
                                 'password': passwords[i]
                             })
        try:
            ssh_cmd(timeout=int(timeout))
        except CommandTimeout:
            logging.info('First login attempt failed as expected')


def _generate_gnb_device(source_device):

    device_name = '{}_TEST'.format(source_device.name)
    connection_hops = copy.deepcopy(source_device._configurations['CONNECTION_HOPS'])
    connection_hops['PROXY_PC']['FCT']['command_params']['options'] =\
        '-o ServerAliveInterval=20 -o ServerAliveCountMax=3'
    connection_hops['UNIX_LOCAL']['PROXY_PC']['command_params']['options'] = \
        '-o ServerAliveInterval=20 -o ServerAliveCountMax=3'
    constructor_params = DeviceFactory._devices_params[source_device.name]['constructor_parameters']
    io_type = constructor_params['io_type']
    variant = constructor_params['variant']
    dev_cfg.define_device(
        name=device_name,
        device_class=DeviceFactory._devices_params[source_device.name]['class_fullname'],
        connection_desc={
            'io_type': io_type,
            'variant': variant
        },
        connection_hops={'CONNECTION_HOPS': connection_hops},
        initial_state=source_device.initial_state,
        lazy_cmds_events=False
    )
    return device_name

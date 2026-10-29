import os
import re
import testsuite.Wroclaw.RRM.resources.rrm_fixture as fixture
from testsuite.Wroclaw.RRM.resources.command_assemblers.iperf_assembler import IperfCommandAssembler
from testsuite.Wroclaw.RRM.resources.pcap_verification.tsharkWithLuaVerifier import TSharkCommandAssembler, \
    get_parameter_value_from_command_output


ssh_connection = fixture.ssh()

UL_MESSAGE_MARKER = 'UL-RLC numOfBearers'
DL_MESSAGE_MARKER = 'DL-RLC numOfBearers'

UL_MESSAGE_REGEX = r'^.* (\d+) bytes.*$'
DL_MESSAGE_REGEX = r'^.* (\d+) bytes.*$'

UL_CELL_ID_REGEX = r'^.* nrCellIdentity (\d+).*$'
DL_CELL_ID_REGEX = r'^.*nrCellId (\d+) .*$'


def start_traffic_on_mue_config(*args, **kwargs):
    """
        This is pretty ugly workaround. It will be changed after multi UE traffic implementation in taf.ue will be done
        :param args: (str) ue aliases (UE_1 or UE_2)
        :param kwargs: for specific traffic values set:
            * ul_throughput: (str)
            * ul_traffic_time: (str) in seconds
            * dl_throughput: (str)
            * dl_traffic_time: (str) in seconds
            * do_not_kill_pppd: set this if eny traffic is already started
        :return:
        """
    core_type = fixture.get_robot_variable('${tl.core.__class__.__name__}')
    if core_type == 'RealCore5G':
        _start_traffic_on_appsrv_and_realcore(*args, **kwargs)
    elif core_type == 'EPCSim':
        _start_traffic_on_appsrv_and_epcsim(*args, **kwargs)
    assert core_type in ['RealCore5G', 'EPCSim'], 'Core type: {} not recognized'.format(core_type)


def get_ue_ip_from_lte_attach_pcap(pcap_file=None):
    if not pcap_file:
        pcap_file = os.path.join(fixture.get_robot_variable("${LOG_PATH}"),
                                 fixture.get_robot_variable("${test_name}"))
    ue_ip = get_parameter_value_from_command_output(output=TSharkCommandAssembler().with_pcap_file(pcap_file)
                                                                                   .with_filter('nas_eps.esm.pdn_ipv4')
                                                                                   .build(),
                                                    parameter='PDN IPv4')
    return ue_ip


def get_ue_rnti_from_lte_attach_pcap(pcap_file=None):
    if not pcap_file:
        pcap_file = fixture.get_default_pcap_filepath()
    ue_rnti = get_parameter_value_from_command_output(output=TSharkCommandAssembler()
                                                      .with_filter('f1ap.UEContextSetupResponse_element')
                                                      .with_pcap_file(pcap_file).build(),
                                                      parameter='C-RNTI:')
    return ue_rnti


@fixture.logged_keyword
def get_average_ul_dl_throughput(logs):
    logs = logs.splitlines()
    ul_logs, dl_logs = _separate_ul_dl_log_messages(logs)

    ul_avg = _get_avg_throughput(_get_ul_ids(ul_logs), _get_uplink_values(ul_logs))
    dl_avg = _get_avg_throughput(_get_dl_ids(dl_logs), _get_downlink_values(dl_logs))

    return ul_avg, dl_avg


@fixture.logged_keyword
def get_active_cell_ids(logs):
    global UL_MESSAGE_MARKER, DL_MESSAGE_MARKER
    global UL_MESSAGE_REGEX, DL_MESSAGE_REGEX
    UL_MESSAGE_MARKER = 'L2_LO_UL_0 INF/L2Lo, UlCounterUpdate.cpp'
    DL_MESSAGE_MARKER = 'L2_LO_TB_BUI0'
    UL_MESSAGE_REGEX = r'^.*: (\d+) Bytes received.*$'
    DL_MESSAGE_REGEX = r'^.*\[.* (?:\d+\|){3}(\d+)\].*$'

    logs = logs.splitlines()
    ul_logs, dl_logs = _separate_ul_dl_log_messages(logs)

    ul_tput = _get_uplink_values(ul_logs)
    dl_tput = _get_downlink_values(dl_logs)
    ul_ids = _get_ul_ids(ul_logs)
    dl_ids = _get_dl_ids(dl_logs)

    ul_ids = [str(i) for i in set(_get_ids_with_traffic(ul_ids, ul_tput))]
    dl_ids = [str(i) for i in set(_get_ids_with_traffic(dl_ids, dl_tput))]

    return ul_ids, dl_ids


def _start_traffic_on_appsrv_and_epcsim(*args, **kwargs):
    """
    This is pretty ugly workaround. It will be changed after multi UE traffic implementation in taf.ue will be done.
    :param args: (str) ue aliases (UE_1 or UE_2)
    :param kwargs: for specific traffic values set:
        * ul_throughput: (str)
        * ul_traffic_time: (str) in seconds
        * dl_throughput: (str)
        * dl_traffic_time: (str) in seconds
        * do_not_kill_pppd: set this if eny traffic is already started
    :return:
    """
    kwargs["do_not_kill_pppd"] = kwargs.get("do_not_kill_pppd", False)

    ue_commands = {'UE_1': {'start_ppoe': 'sudo pppd file /etc/ppp/peers/e500',
                            'route_cmd': 'sudo route add 192.168.60.254 dev ppp0',
                            'ue_ip': '192.168.60.70',
                            'gateway_ip': '192.168.60.254',
                            'ul_port': '5023',
                            'dl_port': '5033'},
                   'UE_2': {'start_ppoe': 'sudo pppd file /etc/ppp/peers/e501',
                            'route_cmd': 'sudo route add 192.168.60.253 dev ppp1',
                            'ue_ip': '192.168.60.71',
                            'gateway_ip': '192.168.60.253',
                            'ul_port': '5024',
                            'dl_port': '5034'}}
    appserver_alias = fixture.run_robot_keyword('Connect to Appserver', 'appserver')
    epcsim_alias = fixture.run_robot_keyword('Connect to EPCsim', 'epcsim')

    if not kwargs["do_not_kill_pppd"]:
        __kill_all_pppd(appserver_alias)

    __start_pppd(appserver_alias=appserver_alias, ue_commands=ue_commands, *args)

    for ue in args:
        fixture.log_message(message=ssh_connection.execute(command=ue_commands[ue]['route_cmd'],
                                                           connection=appserver_alias))
    fixture.RobotBuiltIn().sleep('10s', reason='Wait for route startup')

    __start_iperf_commands(appserver_alias, epcsim_alias, ue_commands, *args, **kwargs)


def _start_traffic_on_appsrv_and_realcore(*args, **kwargs):
    """
    This is pretty ugly workaround. It will be changed after multi UE traffic implementation in taf.ue will be done.
    :param args: (str) ue aliases (UE_1 or UE_2)
    :param kwargs: for specific traffic values set:
        * ul_throughput: (str)
        * ul_traffic_time: (str) in seconds
        * dl_throughput: (str)
        * dl_traffic_time: (str) in seconds
        * do_not_kill_pppd: set this if eny traffic is already started
    :return:
    """
    kwargs["do_not_kill_pppd"] = kwargs.get("do_not_kill_pppd", False)

    ue_ips = fixture.get_robot_variable('${ue_ip_dict}')
    ue_rntis = fixture.get_robot_variable('${ue_rnti_dict}')
    assert len(ue_ips), 'UE alias was not entered. Did attach has been called before?'
    ue_aliases = ue_ips.keys()
    for ue_alias in ue_aliases:
        tmp = ue_ips[ue_alias].split('.')
        tmp[-1] = '1'
        ue_ips['{}_gateway'.format(ue_alias)] = '.'.join(tmp)

    ue_commands = {'UE_1': {'start_ppoe': 'sudo pppd file /etc/ppp/peers/e500',
                            'ue_ip': ue_ips.get('UE_1', None),
                            'gateway_ip': ue_ips.get('UE_1_gateway', None),
                            'ul_port': '5023',
                            'dl_port': '5033'},
                   'UE_2': {'start_ppoe': 'sudo pppd file /etc/ppp/peers/e501',
                            'ue_ip': ue_ips.get('UE_2', None),
                            'gateway_ip': ue_ips.get('UE_2_gateway', None),
                            'ul_port': '5024',
                            'dl_port': '5034'}}
    appserver_alias = fixture.run_robot_keyword('Connect to Appserver', 'appserver')
    realcore_alias = fixture.run_robot_keyword('Connect to RealCore', 'realcore')

    if not kwargs["do_not_kill_pppd"]:
        __kill_all_pppd(appserver_alias)

    __start_pppd(appserver_alias, ue_commands, *args)

    for ue in args:
        fixture.log_message(message='sudo ip r add {} via {}'.format(ue_commands[ue]['gateway_ip'],
                                                                     ue_commands[ue]['ue_ip']))
        fixture.log_message(message=ssh_connection.execute(command='sudo ip r add {} via {}'.format(
            ue_commands[ue]['gateway_ip'], ue_commands[ue]['ue_ip']),
            connection=appserver_alias))
    fixture.RobotBuiltIn().sleep('5s', reason='Wait for route startup')

    __start_iperf_commands(appserver_alias, realcore_alias, ue_commands, *args, **kwargs)


def __start_pppd(appserver_alias, ue_commands, *args):
    for ue in args:
        fixture.log_message(message=ssh_connection.execute(command=ue_commands[ue]['start_ppoe'],
                                                           connection=appserver_alias))
    fixture.RobotBuiltIn().sleep('5s', reason='Wait for pppd startup')


def __kill_all_pppd(appserver_alias):
    fixture.log_message(message=ssh_connection.execute(command='sudo killall pppd',
                                                       connection=appserver_alias))
    fixture.RobotBuiltIn().sleep('5s', reason='Wait till all pppd dies')


def __start_iperf_commands(appserver_alias, core_alias, ue_commands, *args, **kwargs):
    kwargs["ul_throughput"] = kwargs.get("ul_throughput", "40M")
    kwargs["ul_traffic_time"] = kwargs.get("ul_traffic_time", None)
    kwargs["dl_throughput"] = kwargs.get("dl_throughput", "40M")
    kwargs["dl_traffic_time"] = kwargs.get("dl_traffic_time", None)

    for ue in args:
        if kwargs["ul_traffic_time"]:
            ssh_connection.send_command(command=IperfCommandAssembler().on_client_ip(ue_commands[ue]['gateway_ip'])
                                        .on_bind_ip(ue_commands[ue]['ue_ip'])
                                        .with_bandwidth(kwargs['ul_throughput'])
                                        .with_buffer_length('1300')
                                        .on_port(ue_commands[ue]['ul_port'])
                                        .with_transmit_time(kwargs['ul_traffic_time'])
                                        .build(),
                                        connection=appserver_alias)

        if kwargs["dl_traffic_time"]:
            ssh_connection.send_command(command=IperfCommandAssembler().on_client_ip(ue_commands[ue]['ue_ip'])
                                        .on_bind_ip(ue_commands[ue]['gateway_ip'])
                                        .with_bandwidth(kwargs['dl_throughput'])
                                        .with_buffer_length('1200')
                                        .on_port(ue_commands[ue]['dl_port'])
                                        .with_transmit_time(kwargs['dl_traffic_time'])
                                        .build(),
                                        connection=core_alias)
    fixture.RobotBuiltIn().sleep('5s', reason='Iperf warmup')


def _get_avg_throughput(ids, values):
    averages = 0
    for cell_id in set(ids):
        x = [z[1] for z in filter(lambda x: x[0] == cell_id, zip(ids, values))]
        cell_avg = sum(x) / len(x)
        averages += cell_avg
        fixture.log_message(message="Average value for cell {} is {} Mbit/s".format(cell_id, _byte_to_mbit(cell_avg)))
    return _byte_to_mbit(averages)


def _byte_to_mbit(byte):
    return byte * 8 / (1024 * 1024)


def _separate_ul_dl_log_messages(logs):
    ul_messages = []
    dl_messages = []
    for message in logs:
        if UL_MESSAGE_MARKER in message:
            ul_messages.append(message)
        elif DL_MESSAGE_MARKER in message:
            dl_messages.append(message)
    return ul_messages, dl_messages


@fixture.logged_keyword
def _get_uplink_values(uplink_logs):
    return _get_values_out_of_logs(uplink_logs, UL_MESSAGE_REGEX)


@fixture.logged_keyword
def _get_downlink_values(downlink_logs):
    return _get_values_out_of_logs(downlink_logs, DL_MESSAGE_REGEX)


def _get_values_out_of_logs(logs, regex):
    values = []
    for message in logs:
        match = re.search(regex, message)
        if match is None:
            continue
        value = match.groups()[0]
        values.append(int(value))
    return values


@fixture.logged_keyword
def _get_ul_ids(ul_logs):
    return _get_values_out_of_logs(ul_logs, UL_CELL_ID_REGEX)


@fixture.logged_keyword
def _get_dl_ids(dl_logs):
    return _get_values_out_of_logs(dl_logs, DL_CELL_ID_REGEX)


@fixture.logged_keyword
def _get_ids_with_traffic(cell_ids, tput_values):
    return [cell_ids[i] for i in range(len(cell_ids)) if tput_values[i] > 0]

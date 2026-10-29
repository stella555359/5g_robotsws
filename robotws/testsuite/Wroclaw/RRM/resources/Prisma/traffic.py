import re
import testsuite.Wroclaw.RRM.resources.rrm_fixture as fixture
from testsuite.Wroclaw.RRM.resources.command_assemblers.iperf_assembler import IperfCommandAssembler


UL_MESSAGE_MARKER = 'L2_LO_UL_0 INF/L2Lo, UlCounterUpdate.cpp'
DL_MESSAGE_MARKER = 'L2_LO_TB_BUI0'
UL_MESSAGE_REGEX = r'^.*: (\d+) Bytes received.*$'
DL_MESSAGE_REGEX = r'^.*\[.* (?:\d+\|){3}(\d+)\].*$'
UL_CELL_ID_REGEX = r'^.* nrCellIdentity (\d+).*$'
DL_CELL_ID_REGEX = r'^.*nrCellId (\d+) .*$'


def get_average_ul_dl_throughput(logs):
    logs = logs.splitlines()
    ul_logs, dl_logs = separate_ul_dl_log_messages(logs)
    ul_values = get_uplink_values(ul_logs)
    dl_values = get_downlink_values(dl_logs)

    byte_ul_avg = (sum(ul_values) / len(ul_values))
    byte_dl_avg = (sum(dl_values) / len(dl_values))
    mbit_ul_avg = byte_ul_avg * 8 / (1024 * 1024)
    mbit_dl_avg = byte_dl_avg * 8 / (1024 * 1024)

    return mbit_ul_avg, mbit_dl_avg


def separate_ul_dl_log_messages(logs):
    ul_messages = []
    dl_messages = []
    for message in logs:
        if UL_MESSAGE_MARKER in message:
            ul_messages.append(message)
        elif DL_MESSAGE_MARKER in message:
            dl_messages.append(message)
    return ul_messages, dl_messages


@fixture.logged_keyword
def get_uplink_values(uplink_logs):
    return get_values_out_of_logs(uplink_logs, UL_MESSAGE_REGEX)


@fixture.logged_keyword
def get_downlink_values(downlink_logs):
    return get_values_out_of_logs(downlink_logs, DL_MESSAGE_REGEX)


def get_values_out_of_logs(logs, regex):
    values = []
    for message in logs:
        match = re.search(regex, message)
        if match is None:
            continue
        value = match.groups()[0]
        values.append(int(value))
    return values


def iperf_downlink_command(transmit_time_in_sec):
    return IperfCommandAssembler()\
        .from_ue_to_pgw()\
        .with_bandwidth(fixture.get_robot_variable('${TRAFFIC DL VALUE IN Mbps}') + 'M')\
        .with_transmit_time(transmit_time_in_sec)\
        .with_buffer_length('1200')\
        .build()


def iperf_uplink_command(transmit_time_in_sec):
    cmd = IperfCommandAssembler() \
        .from_pgw_to_ue() \
        .with_bandwidth(fixture.get_robot_variable('${TRAFFIC UL VALUE IN Mbps}') + 'M') \
        .with_transmit_time(transmit_time_in_sec) \
        .with_buffer_length('1024') \
        .build()
    return cmd.replace('iperf', 'iperf.exe')


@fixture.logged_keyword
def get_ul_ids(ul_logs):
    return get_values_out_of_logs(ul_logs, UL_CELL_ID_REGEX)


@fixture.logged_keyword
def get_dl_ids(dl_logs):
    return get_values_out_of_logs(dl_logs, DL_CELL_ID_REGEX)


@fixture.logged_keyword
def get_ids_with_traffic(cell_ids, tput_values):
    return [cell_ids[i] for i in range(len(cell_ids)) if tput_values[i] > 0]


@fixture.logged_keyword
def get_active_cell_ids(logs):
    logs = logs.splitlines()
    ul_logs, dl_logs = separate_ul_dl_log_messages(logs)

    ul_tput = get_uplink_values(ul_logs)
    dl_tput = get_downlink_values(dl_logs)
    ul_ids = get_ul_ids(ul_logs)
    dl_ids = get_dl_ids(dl_logs)

    ul_ids = [str(i) for i in set(get_ids_with_traffic(ul_ids, ul_tput))]
    dl_ids = [str(i) for i in set(get_ids_with_traffic(dl_ids, dl_tput))]

    return ul_ids, dl_ids

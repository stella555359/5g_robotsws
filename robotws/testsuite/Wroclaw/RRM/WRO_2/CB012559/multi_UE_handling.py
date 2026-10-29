import time
from datetime import datetime, timedelta
import re
import telnetlib
import subprocess


scell_activation_template = r"\[UeId:{ue_id},SubcellId:.*, PhysCellId: {phy_id}\] SCellIndex"
reg_exp_for_ACTIVE_UE_template = "{ue_id} +INT +ACTIVE"
bash_command_set_interface_template = "sudo ifconfig {} add {}"


def set_simulated_interface(name, ip):
    command = bash_command_set_interface_template.format(name, ip)
    set_interface = subprocess.Popen([command],
                                     stdout=subprocess.PIPE,
                                     stderr=subprocess.PIPE,
                                     universal_newlines=True,
                                     shell=True)
    output, errors = set_interface.communicate()
    return output.strip()


def attach_multiple_ues_via_telnet(number_of_ues, enb_id, cell_id, gw_id):
    tn = telnetlib.Telnet("127.0.0.1", 20000)
    execute_multiple_commands_for_ue(tn,
                                     number_of_ues,
                                     "ue_change_location id={} " + "enb={} cell={}\n".format(enb_id, cell_id),
                                     0.4)
    execute_multiple_commands_for_ue(tn, number_of_ues, "ue_register id={}\n", 1)
    time.sleep(5)
    execute_multiple_commands_for_ue(tn, number_of_ues, "set_pdu_param ue={} pdu={} trf_type=internal\n", 1)
    execute_multiple_commands_for_ue(tn,
                                     number_of_ues,
                                     "ue_pdu_session_setup ue={} pdu={} nwslice=1 " + "gw={}\n".format(gw_id),
                                     1.3)
    tn.close()


def execute_multiple_commands_for_ue(telnet_connection, number_of_ues, command, time_delay):
    for ue_id in range(1, int(number_of_ues) + 1, 1):
        time.sleep(time_delay)
        telnet_connection.write(fill_command(command, ue_id))
        # if "pdu=" in command:
        #     pdu_id = (ue_id % 14) + 1
        #     telnet_connection.write(command.format(ue_id, pdu_id).encode())
        # else:
        #     telnet_connection.write(command.format(ue_id).encode())


def fill_command(command, ue_id):
    if "pdu=" in command:
        pdu_id = (ue_id % 14) + 1
        return command.format(ue_id, pdu_id).encode()
    else:
        return command.format(ue_id).encode()


def send_A2_measurement_for_multiple_ues_via_telnet(number_of_ues, meas_id):
    tn = telnetlib.Telnet("127.0.0.1", 20000)
    sleep_period = 1 / int(number_of_ues)
    execute_multiple_commands_for_ue(tn, number_of_ues,
                                     "ue_measurement_send_nr id={} " +
                                     "meas_id={} event=A2 srsrp_nr=30\n".format(meas_id),
                                     sleep_period)
    tn.close()


def get_last_run_line_to_split(phrase='marker_for_file_parsing', filename='/opt/iphy/latest/egate_console.log'):
    match_indexes = [0]
    with open(filename, 'r') as f:
        for (i, line) in enumerate(f):
            if phrase in line:
                match_indexes.append(i)
    match_indexes.sort()
    return match_indexes[-1]


def break_file_after_split_marker(break_line, filename='/opt/iphy/latest/egate_console.log'):
    filtered_lines = []
    with open(filename, 'r') as f:
        for lineno, line in enumerate(f):
            if lineno > break_line:
                filtered_lines.append(line)
    return filtered_lines


def get_measurement_reports_and_check_if_exceeded_limit(timeslot,
                                                        timestamp_marker='message c1 : measurementReport :'):
    filtered_lines = break_file_after_split_marker(get_last_run_line_to_split())
    lines_with_timestamps = []
    for line_no, line in enumerate(filtered_lines):
        if timestamp_marker in line:
            lines_with_timestamps.append(filtered_lines[line_no - 3].split()[1])
    captured_timestamps = []
    for time_stamp in lines_with_timestamps:
        dt_object = datetime.strptime(time_stamp, "%H:%M:%S.%f")
        captured_timestamps.append(dt_object)
    start_timestamp = min(captured_timestamps)
    stop_timestamp = max(captured_timestamps)
    difference = stop_timestamp - start_timestamp
    timeslot_with_buffer = timedelta(seconds=int(timeslot) * 1.15)
    return difference, timeslot_with_buffer < difference


def create_list_for_all_scells_activation(number_of_ues, physcellids):
    list_of_items_to_be_verified = []
    for i in range(number_of_ues):
        for j in range(len(physcellids)):
            list_of_items_to_be_verified.append(scell_activation_template.format(
                ue_id=i,
                phy_id=int(physcellids[j])
            ))
    return list_of_items_to_be_verified


def check_5cc_activation_for_multiUE(number_of_ues, physcellids,
                                     activation_marker="activated successfully at airphone"):
    filtered_lines = break_file_after_split_marker(get_last_run_line_to_split())
    lines_with_scell_activation = []
    for line_no, line in enumerate(filtered_lines):
        if activation_marker in line:
            lines_with_scell_activation.append(filtered_lines[line_no])
    expected_scells_activation = create_list_for_all_scells_activation(number_of_ues=int(number_of_ues),
                                                                       physcellids=physcellids)
    for element in expected_scells_activation:
        presence_flag = 0
        for line in lines_with_scell_activation:
            if re.search(element, line):
                presence_flag = 1
        if presence_flag == 0:
            return False
    return True


def check_if_multiUE_still_active_after_test(number_of_ues, activation_marker="ue_disp format=long"):
    filtered_lines = break_file_after_split_marker(get_last_run_line_to_split())
    line_with_ue_disp_command = -1

    for line_no, line in enumerate(filtered_lines):
        if activation_marker in line:
            line_with_ue_disp_command = line_no
    for i in range(1, int(number_of_ues), 1):
        reg_exp_for_exact_ue = reg_exp_for_ACTIVE_UE_template.format(ue_id=i)
        if not re.search(reg_exp_for_exact_ue, filtered_lines[int(line_with_ue_disp_command)+4+i]):
            return False
    return True

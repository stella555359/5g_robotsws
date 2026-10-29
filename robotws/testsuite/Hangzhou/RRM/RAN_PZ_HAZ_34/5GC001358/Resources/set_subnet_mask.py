import os
import time

DHCP_PATH_LEFT = "/tmp/node_0x1018/tmp/dhcpd.cfg"
DHCP_PATH_RIGHT = "/tmp/node_0x2018/tmp/dhcpd.cfg"
PATTERN_LINE = "#FHNET"
PATTERN_TO_SEARCH = "option subnet-mask 255.255.255.252"
MAX_LINES_DIFF = 20

LOGGING_TO_RADIO_STRING_LEFT = "lxc-attach --set-var COLUMNS=250 -n 0x1018 -- "
LOGGING_TO_RADIO_STRING_RIGHT = "lxc-attach --set-var COLUMNS=250 -n 0x2018 -- "
DHCP_CHECK_STRING = "ps aux | grep dhcpd | egrep -v grep"
DHCP_KILL_STRING = "killall -HUP dhcpd"
SPLIT_STRING = "0:00 "


def check_radio_side_for_logging():
    """
    :return:  True if right side, False if left side
    """
    slot_str = os.popen('ddal -s ddal_id_get_slot_id | grep "slot_id"').read()
    slot = slot_str.split("=")[1]
    return True if int(slot) > 3 else False


def read_dhcpd_file(path_to_file):
    with open(path_to_file, 'r') as f:
        lines_of_file = f.read().splitlines()
    return lines_of_file


def list_of_new_lines(list_of_file_lines):
    pattern_line_number = 0
    for counter, line in enumerate(list_of_file_lines):
        if line.find(PATTERN_LINE) != -1:
            pattern_line_number = counter
        elif pattern_line_number + MAX_LINES_DIFF > counter > pattern_line_number:
            if line.find(PATTERN_TO_SEARCH) != -1:
                subnet_mask_line = counter
                list_of_file_lines[subnet_mask_line] = list_of_file_lines[subnet_mask_line].replace("255.255.255.252",
                                                                                                    "255.255.255.248")
                break
    return list_of_file_lines


def write_dhcpd_file(list_of_file_lines, output_file):
    with open(output_file, 'w') as set_f:
        for x in list_of_file_lines:
            set_f.write(x + '\n')


def chose_dhcpd_file_path():
    side = check_radio_side_for_logging()
    return DHCP_PATH_RIGHT if side else DHCP_PATH_LEFT


def chose_logging_to_radio_string():
    side = check_radio_side_for_logging()
    return LOGGING_TO_RADIO_STRING_RIGHT if side else LOGGING_TO_RADIO_STRING_LEFT


def restart_dhcp():
    logging = chose_logging_to_radio_string()
    result_check_string = os.popen(logging + DHCP_CHECK_STRING).read()
    run_dhcp_string = result_check_string.split(SPLIT_STRING)[1]
    os.system(logging + DHCP_KILL_STRING)
    time.sleep(3)
    os.system("echo '  >>>>>   SETTING DHCP SUBNET MASK: 255.255.255.248'")
    os.system("echo '  >>>>>   RUN DHCP: '" + logging + run_dhcp_string)
    os.system(logging + run_dhcp_string)


if __name__ == "__main__":
    dhcpd_file_path = chose_dhcpd_file_path()
    lines = read_dhcpd_file(dhcpd_file_path)
    list_of_new_file_lines = list_of_new_lines(lines)
    write_dhcpd_file(list_of_new_file_lines, dhcpd_file_path)
    restart_dhcp()

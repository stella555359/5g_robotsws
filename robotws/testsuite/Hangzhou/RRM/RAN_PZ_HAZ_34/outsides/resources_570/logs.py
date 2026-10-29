import os
import testsuite.Hangzhou.RRM.RAN_PZ_HAZ_34.outsides.resources_570.rrm_fixture as fixture
import testsuite.Hangzhou.RRM.RAN_PZ_HAZ_34.outsides.resources_570.webUI_operations as webUI
from taf.transport.ssh import ssh

ssh = ssh()

asik_eif2_port = ' 15 '
abil_master_xeon_port = ' 20 '
abil_slave_xeon_port = ' 21 '
abil_eth_switch_port = ' 23 '
abil_loner_port = ' 25 '
ALLOWED_BB_SLOTS = (1, 2, 3, 5, 6, 7)
SCRIPT_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'gnbMirroring')
GNB_MIRRORING_CONFIG = '{dir_path}/gnbMirroringConfig.sh'.format(dir_path=SCRIPT_DIR)
GNB_MIRRORING_CONFIG_BKP = '{dir_path}/gnbMirroring_bak.sh'.format(dir_path=SCRIPT_DIR)


def set_mirroring_in_ABIL_LONER(operation):
    loner_commands = commands_for_loner_mirroring(operation)
    abil_alias = fixture.run_robot_keyword('Connect to ABIL LONER')
    ssh.send_command(loner_commands, connection=abil_alias)


def set_mirroring_in_ASIK(operation, mirroring_mode, syscom_mirroring, carrier_aggregation):
    asik_alias = fixture.run_robot_keyword('Connect to ASIK')
    if operation == 'enable':
        action = 'enable both'
    else:
        action = 'disable both'
    if mirroring_mode == 'standalone':
        dst_port = abil_slave_xeon_port
    else:
        dst_port = asik_eif2_port

    ssh.send_command('dbgrrc mirror sport' + abil_loner_port + 'dport' + dst_port + action,
                     connection=asik_alias)
    if syscom_mirroring == 'true':
        ssh.send_command('dbgrrc mirror sport' + abil_eth_switch_port + 'dport' + dst_port + action,
                         connection=asik_alias)
    if carrier_aggregation == 'true':
        ssh.send_command('dbgrrc mirror sport' + abil_master_xeon_port + 'dport' + dst_port + action,
                         connection=asik_alias)

    if mirroring_mode == 'remote' and operation == 'enable':
        ssh.send_command('dbgrrc enable port' + asik_eif2_port, connection=asik_alias)
        ssh.send_command('dbgrrc set port' + asik_eif2_port + 'speed 10000', connection=asik_alias)


@fixture.logged_keyword
def commands_for_loner_mirroring(operation):
    loner_mirror_command = None
    if operation == 'enable':
        if get_software_release_name() == '5G19B':
            loner_mirror_command = 'echo 0x1 > /sys/class/xlgx/xlgx0/device/monitored_ports_mask && ' \
                                   'echo 0x4 > /sys/class/xlgx/xlgx0/device/monitoring_port_flag'
        else:
            loner_mirror_command = 'echo 0x3 > /sys/class/xlgx/xlgx0/device/monitored_ports_mask && ' \
                                   'echo 0x4 > /sys/class/xlgx/xlgx0/device/monitoring_port_flag'
    else:
        loner_mirror_command = 'echo 0x0 > /sys/class/xlgx/xlgx0/device/monitored_ports_mask && ' \
                               'echo 0x0 > /sys/class/xlgx/xlgx0/device/monitoring_port_flag'
    return loner_mirror_command


def get_software_release_name():
    if fixture.get_robot_variable('${sw release name}'):
        return fixture.get_robot_variable('${sw release name}')


def return_master_if_release_is_5G19B_else_slave():
    release = get_software_release_name()
    if release == '5G19B':
        return 'MASTER'
    return 'SLAVE'


def _change_filter_in_gnbMirroring(config_file, filter):
    filter_marker = 'FILTER='
    file_content = read_gnbmirroring_config()

    for idx, line in enumerate(file_content):
        if line.startswith(filter_marker):
            org_line = line
            file_content[idx] = filter_marker + filter + '\n'
            fixture.log_message(message='\n'.join(["Original filter:", org_line,
                                                   "changed to:", file_content[idx],
                                                   "line number: {}".format(idx + 1)]))

    overwrite_gnbmirroring_config(file_content)


def assign_specific_filter_to_gnbMirroring(filtering='off'):
    backup_original_gnbMirroring()

    if filtering.lower() in ["on", "off"]:
        return filtering.lower()

    _change_filter_in_gnbMirroring(config_file=GNB_MIRRORING_CONFIG, filter=filtering)
    return "on"


def backup_original_gnbMirroring():
    fixture.copyfile(GNB_MIRRORING_CONFIG, GNB_MIRRORING_CONFIG_BKP)


def restore_original_gnbMirroring():
    fixture.copyfile(GNB_MIRRORING_CONFIG_BKP, GNB_MIRRORING_CONFIG)


def read_gnbmirroring_config():
    with open(GNB_MIRRORING_CONFIG, 'r') as mirroring_file:
        return mirroring_file.readlines()


def overwrite_gnbmirroring_config(file_content):
    with open(GNB_MIRRORING_CONFIG, 'w') as mirroring_file:
        mirroring_file.writelines(file_content)


def merge_pcap(output_directory, output_name, inputs, flags="-w"):
    import os
    os.system("mergecap {} {}{} {}".format(flags, output_directory, output_name, inputs))
    os.system("rm -f {}".format(inputs))
    return output_directory+output_name


def rename_pcap(input_name, dest_name):
    import os
    return os.system("mv {} {}".format(input_name, dest_name))


def enable_mirroring_in_bb_slots(slots=None):
    """
    Enabling mirroring in BB slots, BB_SLOT_1 is set to true by default.
    ---------
    | 3   7 |
    | 2   6 |
    | 1   5 |
    ---------
    :param slots: slots splitted by comma
    """
    if slots is None:
        slots = '1'
    slots = [int(s) for s in slots.split(',')]
    _set_logging_on_bb_slots(config_file=GNB_MIRRORING_CONFIG, slots=slots)


def _set_logging_on_bb_slots(config_file, slots):
    file_content = read_gnbmirroring_config()

    for slot in slots:
        slot_variable = 'BB_SLOT_{}='.format(slot)
        if slot not in ALLOWED_BB_SLOTS:
            raise RuntimeError("Selected BB slot {} is not allowed. Allowed slots: {}".format(slot, ALLOWED_BB_SLOTS))
        for idx, line in enumerate(file_content):
            if line.startswith(slot_variable):
                file_content[idx] = slot_variable + "'true'" + '\n'
                fixture.log_message(message='\n'.join(["Default {} setting:".format(slot_variable), line,
                                                       "changed to:", file_content[idx],
                                                       "line number: {}".format(idx + 1)]))

    overwrite_gnbmirroring_config(file_content)

import os
import csv
import json
import paramiko
from jinja2 import Template
from robot.libraries.BuiltIn import BuiltIn
import testsuite.Wroclaw.RRM.resources.webUI_operations as webUI
from testsuite.Wroclaw.RRM.VRF_WRO2_T05.classical.regression.common_keywords.tl_configuration import tl
from taf.sbts.oam.coam.admin import admin

DELTA_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'delta_templates')
admin = admin()
ssh = paramiko.SSHClient()
mrbts_id = tl.gnbs[0].global_bts_id

messages_9208 = [r'"usage":\s?"antennaSwitching"',
                 r'"srs-ResourceSetToAddModList"']


def load_delta_template(filename):
    delta_filepath = os.path.join(DELTA_DIR, filename)
    with open(delta_filepath) as f:
        return Template(f.read())


def delta_commisioning(json_delta,):
    template = load_delta_template('{}.json'.format(json_delta))
    delta = template.render(mrbts_id=mrbts_id)
    __perform_delta(delta)


def __perform_delta(delta_str):
    with webUI.WebUIOperations() as coam:
        coam.perform_delta_recommissioning(delta_file=delta_str, skip_parameter_relation_errors=False,
                                           should_activate=True, timeout=300)


def lock_cell(cell_id):
    dist_name = 'MRBTS-{}/NRBTS-{}/NRCELL-{}'.format(mrbts_id, mrbts_id, cell_id)
    admin.perform_parameter_recommissioning(dist_name=dist_name,
                                            parameter='administrativeState',
                                            operation='update',
                                            value='Locked',
                                            connection='cOAM')


def unlock_cell(cell_id):
    dist_name = 'MRBTS-{}/NRBTS-{}/NRCELL-{}'.format(mrbts_id, mrbts_id, cell_id)
    admin.perform_parameter_recommissioning(dist_name=dist_name,
                                            parameter='administrativeState',
                                            operation='update',
                                            value='Unlocked',
                                            connection='cOAM')


def load_scf(filename):
    scf_filepath = os.path.join(DELTA_DIR, '{}.xml'.format(filename))
    admin.perform_commissioning(scf_file=scf_filepath,
                                skip_parameter_relation_errors=False,
                                should_activate=True,
                                timeout=300,
                                connection='cOAM')


def verify_all_cells_onair_with_admin():
    expected_cell_state = {'operationalState': 'Enabled', 'proceduralStatus': 'configured',
                           'blockingState': 'Unblocked', 'administrativeState': 'Unlocked', 'usageState': 'Active',
                           'barringStatus': 'unbarred'}
    expected_bts_status = {'operationalState': 'Enabled', 'proceduralState': 'OnAir',
                           'blockingState': 'Unblocked'}
    cells_info = admin.get_cells_info(cell_type='nr', timeout=30, connection='cOAM')
    for cell in cells_info:
        for key, val in cell['status'].items():
            if expected_cell_state[key].lower() != val.lower():
                raise Exception("The cell status is not as expected. Current cell status : {} "
                                "and Expected Cell Status : {}".format(cell['status'], expected_cell_state))
    bts_status = admin.get_bts_statuses(timeout=30, connection='cOAM')
    if bts_status != expected_bts_status:
        raise Exception("The BTS status is not as expected. Current BTS status : {} and Expected BTS status : {}"
                        .format(bts_status, expected_bts_status))
    return True


def verify_cell_locked_with_admin(cell_id):
    expected_cell_state_locked = {'operationalState': 'disabled', 'proceduralStatus': 'initialization required',
                                  'blockingState': 'Unblocked', 'administrativeState': 'Locked', 'usageState': 'Idle',
                                  'barringStatus': 'unbarred', "availabilityStatus": "off line"}
    expected_cell_state = {'operationalState': 'Enabled', 'proceduralStatus': 'configured',
                           'blockingState': 'Unblocked', 'administrativeState': 'Unlocked', 'usageState': 'Active',
                           'barringStatus': 'unbarred'}
    expected_bts_status = {'operationalState': 'Enabled', 'proceduralState': 'OnAir',
                           'blockingState': 'Unblocked'}
    cells_info = admin.get_cells_info(cell_type='nr', timeout=30, connection='cOAM')
    print('cells_info', cells_info)
    for cell in cells_info:
        print('cell', cell)
        if str(cell['physicalCellId']) == cell_id:
            for key, val in cell['status'].items():
                if expected_cell_state_locked[key].lower() != val.lower():
                    raise Exception("The cell status is not as expected. Current cell status : {} "
                                    "and Expected Cell Status : {}".format(cell['status'], expected_cell_state_locked))
        else:
            for key, val in cell['status'].items():
                if expected_cell_state[key].lower() != val.lower():
                    raise Exception("The cell status is not as expected. Current cell status : {} "
                                    "and Expected Cell Status : {}".format(cell['status'], expected_cell_state))
    bts_status = admin.get_bts_statuses(timeout=30, connection='cOAM')
    if bts_status != expected_bts_status:
        raise Exception("The BTS status is not as expected. Current BTS status : {} and Expected BTS status : {}"
                        .format(bts_status, expected_bts_status))
    return True


def set_prachSequenceType_on_cell(cell_id, value):
    dist_name = 'MRBTS-{}/NRBTS-{}/NRCELL-{}'.format(mrbts_id, mrbts_id, cell_id)
    admin.perform_parameter_recommissioning(dist_name=dist_name,
                                            parameter='prachSequenceType',
                                            operation='update',
                                            value=value,
                                            connection='cOAM')


def set_dlMuMimoCorrThd_on_cell(cell_id, value):
    dist_name = 'MRBTS-{}/NRBTS-{}/NRCELL-{}/NRDLMUMIMO-1'.format(mrbts_id, mrbts_id, cell_id)
    admin.perform_parameter_recommissioning(dist_name=dist_name,
                                            parameter='dlMuMimoCorrThd',
                                            operation='update',
                                            value=value,
                                            connection='cOAM')


def get_swconfig(filename, swconfig_dir):
    swconfig_dir = os.path.join(BuiltIn().get_variable_value('${outputdir}'), swconfig_dir)
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(hostname="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu")
    sftp = ssh.open_sftp()
    if not os.path.exists(swconfig_dir):
        os.makedirs(swconfig_dir)
    swconfig_file = "{}/{}.txt".format(swconfig_dir, filename)
    sftp.get("/ffs/run/swconfig.txt", swconfig_file)
    ssh.close()
    return swconfig_file


def add_flag_to_swconfig(swconfig_dir, flag):
    """
    Add new flag to software configuration file.
    :param swconfig_dir: path to swconfig file directory
    :return: None
    """
    swconfig_dir = os.path.join(BuiltIn().get_variable_value('${outputdir}'), swconfig_dir)
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(hostname="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu")
    sftp = ssh.open_sftp()
    swconfig_backup_local = get_swconfig("swconfig_original", swconfig_dir)
    modified_swconfig_local = "{}/swconfig.txt".format(swconfig_dir)
    sftp.get("/ffs/run/swconfig.txt", swconfig_backup_local)
    with open(swconfig_backup_local, "r") as swconfig_bk, open(modified_swconfig_local, "w") as new_swconfig:
        for line in swconfig_bk:
            if flag.split("=")[0] in line:
                continue
            new_swconfig.write(line)
        new_swconfig.write("\n{} #{} Test flag".format(flag, BuiltIn().get_variable_value('${testname}')))
    sftp.put(modified_swconfig_local, "/ffs/run/swconfig.txt")
    ssh.close()
    # admin.reset_site(timeout=600, connection='cOAM')


def restore_original_swconfig(swconfig_dir):
    """Restore original software configuration file."""
    swconfig_dir = os.path.join(BuiltIn().get_variable_value('${outputdir}'), swconfig_dir)
    swconfig_backup_local = "{}/swconfig_original.txt".format(swconfig_dir)
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    ssh.connect(hostname="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu")
    sftp = ssh.open_sftp()
    sftp.put(swconfig_backup_local, "/ffs/run/swconfig.txt")
    ssh.close()
    admin.reset_site(timeout=600, connection='cOAM')


def check_if_antenna_switching_in_rrc_reconfiguration_dcap_logs(dcap_logs_path):
    rrc_reconfiguration_contents = []
    with open(dcap_logs_path, mode="r", newline="") as file:
        csv_reader = csv.DictReader(file)
        for row in csv_reader:
            if row['Message name'] == 'rrcReconfiguration':
                print(f'rrcReconfiguration msg: {row}\n\n')
                rrc_reconfiguration_contents.append(row["Message body"])

    for content in rrc_reconfiguration_contents:
        if 'antennaSwitching' in content:
            return True
    return False

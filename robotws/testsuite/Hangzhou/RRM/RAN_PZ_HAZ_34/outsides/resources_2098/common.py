from robot.api import logger
from taf.sbts.oam.coam.admin import admin
import logging
import socket
import re
import os


def check_if_no_unexpected_alarms(alarms_list):
    formatted_logs = ', '.join(['{}: {}'.format(alarm['alarmDetail'], alarm['severity']) for alarm in alarms_list])
    logger.console('Found alarms: {}'.format(formatted_logs))
    assert all([alarm['severity'] == 'Minor' or alarm['severity'] == 'Warning' for alarm in alarms_list]) is True, \
        'Alarm of severity major/critical has been found'


def configure_gnbmirroring_script(file_path, time, size, num_of_files, filtering, bb_slot_1, bb_slot_2, bb_slot_3,
                                  bb_slot_4, bb_slot_5, bb_slot_6, bb_slot_7):
    """
    Used in KW Start L1L2 Logs Gathering
    """
    file = open(str(file_path), 'r')
    file_res = open(str(file_path[:-21] + 'tmp.sh'), 'w')
    r_1 = r'(^CAPTURING_TIME_SECONDS=)(\d*)(\s)'
    r_2 = r'(^FILE_SIZE_MBYTES=)(\d*)(\s)'
    r_3 = r'(^NUMBER_OF_FILES=)(\d*)(\s)'
    r_4 = r"(^FILTERING=)'([a-z]{2,3})'"
    r_5 = r"(^BB_SLOT_1=)'([a-z]{4,5})'"
    r_6 = r"(^BB_SLOT_2=)'([a-z]{4,5})'"
    r_7 = r"(^BB_SLOT_3=)'([a-z]{4,5})'"
    r_8 = r"(^BB_SLOT_4=)'([a-z]{4,5})'"
    r_9 = r"(^BB_SLOT_5=)'([a-z]{4,5})'"
    r_10 = r"(^BB_SLOT_6=)'([a-z]{4,5})'"
    r_11 = r"(^BB_SLOT_7=)'([a-z]{4,5})'"
    for line in file:
        if re.match(r_1, line):
            t = re.match(r_1, line)
            temp = line.replace(t.group(2), str(time))
            file_res.write(temp)
            continue
        if re.match(r_2, line):
            t = re.match(r_2, line)
            temp = line.replace(t.group(2), str(size))
            file_res.write(temp)
            continue
        if re.match(r_3, line):
            t = re.match(r_3, line)
            temp = line.replace(t.group(2), str(num_of_files))
            file_res.write(temp)
            continue
        if re.match(r_4, line):
            t = re.match(r_4, line)
            temp = line.replace(t.group(2), str(filtering))
            file_res.write(temp)
            continue
        if re.match(r_5, line):
            t = re.match(r_5, line)
            temp = line.replace(t.group(2), str(bb_slot_1))
            file_res.write(temp)
            continue
        if re.match(r_6, line):
            t = re.match(r_6, line)
            temp = line.replace(t.group(2), str(bb_slot_2))
            file_res.write(temp)
            continue
        if re.match(r_7, line):
            t = re.match(r_7, line)
            temp = line.replace(t.group(2), str(bb_slot_3))
            file_res.write(temp)
            continue
        if re.match(r_8, line):
            t = re.match(r_8, line)
            temp = line.replace(t.group(2), str(bb_slot_4))
            file_res.write(temp)
            continue
        if re.match(r_9, line):
            t = re.match(r_9, line)
            temp = line.replace(t.group(2), str(bb_slot_5))
            file_res.write(temp)
            continue
        if re.match(r_10, line):
            t = re.match(r_10, line)
            temp = line.replace(t.group(2), str(bb_slot_6))
            file_res.write(temp)
            continue
        if re.match(r_11, line):
            t = re.match(r_11, line)
            temp = line.replace(t.group(2), str(bb_slot_7))
            file_res.write(temp)
            continue
        file_res.write(line)
    os.remove(file_path)
    os.rename(str(file_path[:-21] + 'tmp.sh'), file_path)


def get_dir_from_path(path):
    path = re.findall(r'^[\w*/]*/', path)[0]
    return path


def get_file_from_path(path):
    filename = re.findall(r'\w*[.]\w*$', path)[0]
    return filename


def get_file_without_ext(path):
    filename = get_file_from_path(path)
    f = re.findall(r'^\w*', filename)[0]
    return f

# Keywords returns path to SCF stored in 'custom-config/RRM_WRO7' with given parameters for testline
# SCF should be stored in 'custom-config/RRM_WRO7/[testline]'
# SCF name should be like this: [testline]_[cofnig_type]_[architecture]_[cipri]_[branch]
# example SCF path: 'custom-config/RRM_WRO7/7_16_UTE5GCLOUDT151/7_16_UTE5GCLOUDT151_FDD_NSA_CPRI_21A.xml'
# arguments:  config_type = TFF/FDD, architecture = NSA/SA, cpri = CPRI/ECIPRI, branch = 20B/21A/SBTS21B/SBTS00
# example of use: get_test_line_scf_path  FDD  NSA  CPRI  21A


def get_test_line_scf_path(config_type=None, architecture=None, cpri=None, branch=None):
    tl_name = socket.gethostname().replace('-', '_')
    if config_type or architecture or cpri or branch:
        scf_path = 'custom-config/RRM_WRO7/{}/{}_{}_{}_{}_{}.xml'.\
          format(tl_name, tl_name, config_type, architecture, cpri, branch)
    else:
        scf_path = 'custom-config/RRM_WRO7/{}/{}.xml'.format(tl_name, tl_name)
    if os.path.isfile(scf_path):
        return scf_path
    else:
        logging.debug('File under path {} does not exist'.format(scf_path))


def get_interface_name():
    api = admin()
    conn = api.connect_to()

    sysmod_info = conn.get_fsm_info()
    sysmod_name = sysmod_info[0]['productName']

    if not sysmod_name:
        assert False, 'There is no sysmod !'

    names = {
        'ASIK': 'fp0',
        'ASIB': 'br1',
        'ASIL': 'br0'
    }

    sysmod_version = sysmod_name.replace(' AirScale Common', '')
    api.teardown()
    return names[sysmod_version]

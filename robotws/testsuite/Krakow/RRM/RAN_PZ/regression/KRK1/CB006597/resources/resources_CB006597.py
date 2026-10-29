import os
import re
import time
import logging
from datetime import datetime
from moler.device import DeviceFactory
from taf.rfrl.utilities.tl_config import load_moler_configuration_from_tl
from taf.rfrl.utilities.tl_config import get_oam_ip_address
from taf.rfrl.ue.parsers.qxdm_parser import QxdmLogParser
from taf.rfrl.ue.connections import device_aliases


def get_releasePreference_from_qxdm_log(file_path):
    """
        Parse QXDM for releasePreference-r16 value

        :param file_path:         directory where QXDM log to parse is
        :return: time of the message
        """
    parser = QxdmLogParser(file_path=file_path, message_ids=['0xB821'])
    parser.parse()
    results = parser.ret
    for msg in results['0xB821']:
        logging.info(msg['message']['name'])
        if msg['message']['name'] == 'NR5G RRC OTA Packet  --  UL_DCCH / UeCapabilityInformation':
            supported = (msg['UE-NR-Capability']['nonCriticalExtension']
                            ['nonCriticalExtension']['nonCriticalExtension']
                            ['nonCriticalExtension']['nonCriticalExtension']
                            ['nonCriticalExtension']['powSav-Parameters-r16']
                            ['powSav-ParametersCommon-r16']['releasePreference-r16'])
            logging.info(msg['message']['time'])
            return supported


def validate_releasePreference_in_qxdm_log(file_path):
    """
        Validate if releasePreference-r16 value is set to supported

        :param file_path:         directory where QXDM log to parse is
        :return: time of the message
        """
    supported = get_releasePreference_from_qxdm_log(file_path)
    if supported != 'supported':
        raise WrongMessageException('Feature not supported')


def get_releasePreferenceProhibitTimer_from_qxdm_log(file_path):
    """
        Parse QXDM for releasePreferenceProhibitTimer-r16 value

        :param file_path:         directory where QXDM log to parse is
        :return: time of the message
        """
    parser = QxdmLogParser(file_path=file_path, message_ids=['0xB821'])
    parser.parse()
    results = parser.ret
    for msg in results['0xB821']:
        logging.info(msg['message']['name'])
        if msg['message']['name'] == 'NR5G RRC OTA Packet  --  DL_DCCH / RRCReconfiguration':
            timer = (msg['DL-DCCH-Message']['message']['c1']['rrcReconfiguration']
                        ['criticalExtensions']['rrcReconfiguration']['nonCriticalExtension']
                        ['nonCriticalExtension']['nonCriticalExtension']['nonCriticalExtension']
                        ['otherConfig-v1610']['releasePreferenceConfig-r16']
                        ['setup']['releasePreferenceProhibitTimer-r16'])
            logging.info(msg['message']['time'])
            return timer


def validate_releasePreferenceProhibitTimer_in_qxdm_log(file_path, target_timer='s30'):
    """
        Validate if releasePreferenceProhibitTimer-r16 value is set to supported

        :param file_path:         directory where QXDM log to parse is
        :param target_timer:        target timer
        :return: time of the message
        """
    timer = get_releasePreferenceProhibitTimer_from_qxdm_log(file_path)
    logging.info(timer)
    if timer != target_timer:
        raise WrongMessageException('PreferenceProhibitTimer mismatch, {} is not {}'.format(timer, target_timer))


def get_preferredRRC_from_qxdm_log(file_path):
    """
        Parse QXDM for preferredRRC-State-r16 value

        :param file_path:         directory where QXDM log to parse is
        :return: time of the message
        """
    parser = QxdmLogParser(file_path=file_path, message_ids=['0xB821'])
    parser.parse()
    results = parser.ret
    for msg in results['0xB821']:
        logging.info(msg['message']['name'])
        if msg['message']['name'] == 'NR5G RRC OTA Packet  --  UL_DCCH / ueAssistanceInformation':
            state = (msg['UL-DCCH-Message']['message']['c1']['ueAssistanceInformation']
                        ['criticalExtensions']['ueAssistanceInformation']['nonCriticalExtension']
                        ['nonCriticalExtension']['releasePreference-r16']['preferredRRC-State-r16'])
            logging.info(msg['message']['time'])
            return state, msg['message']['time']


def validate_OutOfConnected_in_qxdm_log(file_path):
    """
        Validate if preferredRRC-State-r16 value is OutOfConnected

        :param file_path:         directory where QXDM log to parse is
        :return: message time
        """
    state, message_time = get_preferredRRC_from_qxdm_log(file_path)
    logging.info(state)
    if state != 'outOfConnected':
        raise WrongMessageException('State {} is not OutOfConnected'.format(state))
    return message_time


def get_releasePreference_after_handover(file_path):
    """
    Get releasePreferenceConfig-r16 from QXDM log

    :param file_path:         directory where QXDM log to parse is
    :return: time of the message
    """
    messages = []
    parser = QxdmLogParser(file_path=file_path, message_ids=['0xB821'])
    parser.parse()
    results = parser.ret
    for msg in results['0xB821']:
        if msg['message']['name'] == 'NR5G RRC OTA Packet  --  DL_DCCH / RRCReconfiguration':
            value = (msg['DL-DCCH-Message']['message']['c1']['rrcReconfiguration']
                        ['criticalExtensions']['rrcReconfiguration']['nonCriticalExtension']
                        ['nonCriticalExtension']['nonCriticalExtension']['nonCriticalExtension']
                        ['otherConfig-v1610']['releasePreferenceConfig-r16'])
            if 'release' in value.keys():
                return value['release']
    raise MessageNotInLog('No message in log')


def verify_releasePreference_after_handover(file_path):
    """
    Verify releasePreferenceConfig-r16 is not set after HO

    :param file_path:         directory where QXDM log to parse is
    :return: time of the message
    """
    value = get_releasePreference_after_handover(file_path)
    if not value:
        logging.info(value)
    else:
        logging.info(value)
        raise WrongMessageException('releasePreferenceConfig-r16 is not None')


def verify_ueAssistanceInformation_not_in_log(file_path):
    """
    Verify ueAssistanceInformation is not in log

    :param file_path:         directory where QXDM log to parse is
    :return: None
    """
    parser = QxdmLogParser(file_path=file_path, message_ids=['0xB821'])
    parser.parse()
    results = parser.ret
    for msg in results['0xB821']:
        if msg['message']['name'] != 'NR5G RRC OTA Packet  --  UL_DCCH / ueAssistanceInformation':
            logging.info(msg['message']['name'])
        else:
            raise WrongMessageException('ueAssistanceInformation in log')


def get_all_RRCReconfiguration_times(file_path):
    """
    Get all RRCReconfiguration message times
    :param file_path:         directory where QXDM log to parse is
    :return: None
    """
    message_times = []
    parser = QxdmLogParser(file_path=file_path, message_ids=['0xB821'])
    parser.parse()
    results = parser.ret
    for msg in results['0xB821']:
        if msg['message']['name'] == 'NR5G RRC OTA Packet  --  DL_DCCH / RRCReconfiguration':
            test_time = msg['message']['time']
            message_times.append(datetime.strptime(test_time, '%H:%M:%S.%f'))
    return message_times


def check_if_RRCReconfiguration_in_log_after_target_time(file_path, target_time):
    """
    Check if RRCReconfiguration not in log after target_time
    :param file_path:         directory where QXDM log to parse is
    :param target_time:     time of the latest message
    :return: None
    """
    message_times = get_all_RRCReconfiguration_times(file_path)
    logging.info(message_times)
    target_time = datetime.strptime(target_time, '%H:%M:%S.%f')
    for msg in message_times:
        if msg < target_time:
            continue
        else:
            raise WrongMessageException('RRCReconfiguration in log after target time')


@load_moler_configuration_from_tl()
def ping_gnb_from_ue(ue_id=0, timeout=60, error_regex=re.compile("error", re.IGNORECASE), background=False):
    """
    Ping gnb from ue

   :param ue_id:           UE id - related to Test Line configuration - tl.ues.
   :param timeout:         Command timeout
   :param error_regex:     Regex for failure command
   :param background:      True/False - run command in the background
   :return: None
   """
    oam_ip = get_oam_ip_address()
    ue_pc_device_name = device_aliases.ue_pc.format(ue_id)
    ping_device = DeviceFactory.get_cloned_device(source_device=ue_pc_device_name,
                                                  new_name="{}_ping".format(ue_pc_device_name))
    cmd = f'adb shell ping -c 200 {oam_ip}'
    time.sleep(0.5)
    _cmd = ping_device.get_cmd(cmd_name="run_script", cmd_params={'script_command': cmd, 'error_regex': error_regex})
    logging.info(cmd)
    if background:
        _cmd.start(timeout=timeout)
        return _cmd
    else:
        _cmd(timeout=timeout)
        time.sleep(0.5)


def search_syslog_for_message(message, syslog_dir='/tmp/btslog2'):
    """
        Execute any Windows command on UEPC device.

       :param message:           message for which we parse syslog
       :param syslog_dir:         directory where syslog to parse is
       :return: line with the message
    """
    files = (syslogfile for syslogfile in os.listdir(syslog_dir)
             if syslogfile.startswith('SYSLOG'))
    for filename in files:
        with open(syslog_dir + '/' + filename, 'r') as file_content:
            for line in file_content:
                if message in line:
                    logging.info(line)
                    return line
    raise MessageNotInLog(f'{message} not in syslog')


class MessageNotInLog(Exception):
    pass


class WrongMessageException(Exception):
    pass

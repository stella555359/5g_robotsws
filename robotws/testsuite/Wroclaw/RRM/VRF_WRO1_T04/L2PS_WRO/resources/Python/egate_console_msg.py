"""
:copyright: Nokia Networks
:author: Gall Anonim
:maintainer: Mateusz Bilewicz
:contact: mateusz.bilewicz@nokia.com
:team: MN_RAN_L2_SW_WRO_7_SG
"""

import datetime
import re
from robot.api import logger


class EgateConsoleMsg(object):
    """
    Collect messages from egate_console.log
    """

    def __init__(self):
        self.regexp_rrc_release = re.compile("(\\n.*\\n.*\\n.*\\n.*: rrcRelease :"
                                             "\\s+\\n\\s+\\{\\s?[\\s\\S]+?\\}\\s+?)")
        self.regexp_freq_eutra = re.compile("(freqPriorityListEUTRA.*\\n\\s+\\{\\s?[\\s\\S]+?\\}\\s+?)")
        self.regexp_freq_nr = re.compile("(freqPriorityListNR.*\\n\\s+\\{\\s?[\\s\\S]+?\\}\\s+?)")
        self.regexp_timer = re.compile("(t320 min\\d+)")
        self.regexp_cap_enquiry = re.compile("(\\n.*\\n.*\\n.*\\n.*ueCapabilityEnquiry :"
                                             "\\s+\\n\\s+\\{\\s?[\\s\\S]+?\\}\\s+?)")
        self.regexp_cap_request = re.compile("(ue-CapabilityRAT-RequestList\\s+\\n\\s+\\{\\s?[\\s\\S]+?\\}\\s+?)")
        self.regexp_cap_container = re.compile('(ue-CapabilityRAT-ContainerList\\s+\\n\\s+\\{\\s?[\\s\\S]+?\\}\\s+?)')
        self.regexp_transaction_id = re.compile("(rrc-TransactionIdentifier \\d+)")
        self.regexp_transaction_time = re.compile("(\\d+:\\d+:\\d+.\\d+)")
        self.regexp_ue_detach = re.compile('(\\n.*Deregistration Initiated for UE)')
        self.regexp_ue_attach = re.compile('(\\n.*Received REGISTRATION COMPLETE from UE with RAN UE NGAP ID \\d+ '
                                           'and AMF UE NGAP ID \\d+)')
        self.regexp_cap_info = re.compile('(\\n.*\\n.*\\n.*\\n.*ueCapabilityInformation :'
                                          '\\s+\\n\\s+\\{\\s?[\\s\\S]+?\\}\\s+?)')
        self.regexp_rnti = re.compile('UE(\\d+):.*\\(crnti: \\d+ = (0x.*)\\)')

    def get_freq_priority_lists_from_rrc_releases(self, egate_console_log_path='/opt/iphy/latest/egate_console.log'):
        """
        Read egate_console.log and return freqPriorityLists from all RRC Release messages.
        :param egate_console_log_path: Path to egate_console.log
        :return: Example: ({'freqPriorityListNR': [{'carrierFreq': '633372', 'cellReselectionPriority': '7'},
            {'carrierFreq': '630000', 'cellReselectionPriority': '1,', 'cellReselectionSubPriority': 'oDot4'}],
            'freqPriorityListEUTRA': []}, 'min5')
        """
        with open(egate_console_log_path, "r") as log_file:
            data = log_file.read()
        try:
            rrc_release_messages = self.regexp_rrc_release.findall(data)
            messages_number = len(rrc_release_messages)
        except TypeError:
            logger.info("No RRC Release messages found", also_console=True)
            return {}, None, None
        timer = self._search_for_t320_timer_in_rrc_release_msg(data)
        freq_priorities_list_nr, empty_msg_number = self._search_for_priority_list_in_rrc_release_msg(
            data, 'freqPriorityListNR', messages_number)
        freq_priorities_list_eutra, _ = self._search_for_priority_list_in_rrc_release_msg(
            data, 'freqPriorityListEUTRA')
        freq_priorities_dict = {
            'freqPriorityListNR': freq_priorities_list_nr,
            'freqPriorityListEUTRA': freq_priorities_list_eutra}
        return freq_priorities_dict, timer, empty_msg_number

    def _search_for_t320_timer_in_rrc_release_msg(self, data):
        """
        Get t320 timer from RRC Release message. (Helper function)
        """
        try:
            timer_list = self.regexp_timer.findall(data)
            timer_list = [timer.split(' ')[-1] for timer in timer_list]
            timer = timer_list[0] if len(timer_list) == 1 else timer_list
            logger.info("Timer: {}".format(timer))
        except IndexError:
            timer = None
            logger.info('No t320 timer found in RRC Release message')
        return timer

    def _search_for_priority_list_in_rrc_release_msg(self, data, list_type, messages_number=1):
        """
        Get NR or EUTRA frequency priority list from RRC Release message. (Helper function)
        """
        freq_priorities_list = []
        regexp = self.regexp_freq_nr if list_type == 'freqPriorityListNR' else self.regexp_freq_eutra
        try:
            params_list = regexp.findall(data)
            empty_msg_number = messages_number - len(params_list)
            for params in params_list:
                freq_priorities_list.append(self._parse_single_priority_list(params, list_type))
            if len(freq_priorities_list) == 1:
                freq_priorities_list = freq_priorities_list[0]
        except IndexError:
            logger.info("No {} found in RRC Release message".format(list_type), also_console=True)
        return freq_priorities_list, empty_msg_number

    @staticmethod
    def _parse_single_priority_list(nr_params, list_type):
        """
        Parse parameters and values from frequency priority list. (Helper function)
        """
        freq_priorities_list = []
        fp_list = nr_params.split('}')
        fp_list = [freq.split() for freq in fp_list]
        fp_list = filter(None, fp_list)
        for freq in fp_list:
            freq = [item.replace(',', '') for item in freq if item not in [
                '{', '},', '}', '', ',', list_type]]
            fp_dict = _convert_to_dict(freq)
            freq_priorities_list.append(fp_dict)
        return freq_priorities_list

    def get_ue_capability_enquiry(self, trigger, egate_console_log_path='/opt/iphy/latest/egate_console.log'):
        """
        Read egate_console.log and return ue-CapabilityRAT-RequestList from ueCapabilityEnquiry message.
        :param egate_console_log_path: Path to egate_console.log
        :param trigger: 'ue_attach' or 'ue_detach'
        :return: Example: {'capabilityRequestFilter': '80040460', 'rat-Type': 'nr'}
        """
        transaction_enquiry_id = None
        transaction_enquiry_time = None
        ue_cap_dict = dict()
        with open(egate_console_log_path, "r") as log_file:
            data = log_file.read()
        try:
            found_msg, transaction_enquiry_time = self._get_enquiry_msg_according_to_trigger_event(trigger, data)
            if not found_msg:
                logger.info("No ueCapabilityEnquiry found", also_console=True)
                return {}, transaction_enquiry_id, transaction_enquiry_time
            transaction_enquiry_id = self.regexp_transaction_id.findall(found_msg)[0].split()[-1]
            ue_cap_enquiry = self.regexp_cap_request.findall(found_msg)[0].split()
            capability_request_filter, rat_type = self._parse_ue_cap_enquiry_msg(ue_cap_enquiry)
            ue_cap_dict.update({'capabilityRequestFilter': capability_request_filter})
            ue_cap_dict.update({'rat-Type': rat_type})
        except IndexError:
            logger.info("No ueCapabilityEnquiry found", also_console=True)
        return ue_cap_dict, transaction_enquiry_id, transaction_enquiry_time

    def _get_enquiry_msg_according_to_trigger_event(self, trigger, data):
        """
        Get ueCapabilityEnquiry sent after trigger event. (Helper function)
        """
        found_msg = None
        transaction_time = None
        prev_time = datetime.time(23, 59, 59, 999999)
        ue_trigger_msg = self.regexp_ue_detach.findall(data)[-1] if trigger == 'ue_detach' \
            else self.regexp_ue_attach.findall(data)[-1]
        ue_trigger_time = datetime.datetime.strptime(
            self.regexp_transaction_time.findall(ue_trigger_msg)[0], '%H:%M:%S.%f').time()
        ue_cap_container = self.regexp_cap_enquiry.findall(data)
        for message in ue_cap_container:
            transaction_time = datetime.datetime.strptime(
                self.regexp_transaction_time.findall(message)[0], '%H:%M:%S.%f').time()
            if transaction_time < ue_trigger_time:
                continue
            elif transaction_time < prev_time:
                prev_time = transaction_time
                found_msg = message
        return found_msg, transaction_time

    @staticmethod
    def _parse_ue_cap_enquiry_msg(ue_cap_enquiry):
        """
        Parse parameters and values from ueCapabilityEnquiry message. (Helper function)
        """
        for item in ['ue-CapabilityRAT-RequestList', '{', '{', '}']:
            ue_cap_enquiry.remove(item)
        ue_cap_dict = _convert_to_dict(ue_cap_enquiry)
        capability_request_filter = ue_cap_dict['capabilityRequestFilter'].replace("'", "").replace("H", "")
        rat_type = ue_cap_dict['rat-Type'].replace(",", "")
        return capability_request_filter, rat_type

    def get_ue_capability_information(self, ue_cap_enquiry_id, ue_cap_enquiry_time, rrc_guard_timer,
                                      egate_console_log_path='/opt/iphy/latest/egate_console.log'):
        """
        Read egate_console.log and return ue-CapabilityRAT-ContainerList from ueCapabilityInformation message.
        :param ue_cap_enquiry_id: rrc-TransactionIdentifier from ueCapabilityEnquiry message
        :param ue_cap_enquiry_time: time of sending ueCapabilityEnquiry message
        :param rrc_guard_timer: Value of timerRRCGuard [ms]
        :param egate_console_log_path: Path to egate_console.log
        :return: Example: {'ue-CapabilityRAT-Container': 'E5A00000014758030300005FAB00048174', 'rat-Type': 'nr'}
        """
        ue_cap_dict = dict()
        ue_cap_info = ''
        with open(egate_console_log_path, "r") as log_file:
            data = log_file.read()
        try:
            ue_cap_container = self.regexp_cap_info.findall(data)
            for message in ue_cap_container:
                result = self._check_if_ue_cap_info_was_sent_within_rrc_guard_time(
                    message, ue_cap_enquiry_id, ue_cap_enquiry_time, rrc_guard_timer
                )
                if not result:
                    continue
                ue_cap_info = self.regexp_cap_container.findall(message)[0].split()
                if not ue_cap_info:
                    raise ValueError
            ue_capability_rat_container, rat_type = self._parse_ue_cap_info_msg(ue_cap_info)
            ue_cap_dict.update({'ue-CapabilityRAT-Container': ue_capability_rat_container})
            ue_cap_dict.update({'rat-Type': rat_type})
        except (IndexError, ValueError):
            logger.info("No ueCapabilityInformation found", also_console=True)
            return ue_cap_dict
        return ue_cap_dict

    @staticmethod
    def _parse_ue_cap_info_msg(ue_cap_info):
        """
        Parse parameters and values from ueCapabilityInformation message. (Helper function)
        """
        for item in ['ue-CapabilityRAT-ContainerList', '{', '{', '}', "...'H"]:
            ue_cap_info.remove(item)
        ue_cap_dict = _convert_to_dict(ue_cap_info)
        ue_capability_rat_container = ue_cap_dict['ue-CapabilityRAT-Container'].replace("'", "")
        rat_type = ue_cap_dict['rat-Type'].replace(",", "")
        return ue_capability_rat_container, rat_type

    def _check_if_ue_cap_info_was_sent_within_rrc_guard_time(self, message, ue_cap_enquiry_id, ue_cap_enquiry_time,
                                                             rrc_guard_timer):
        """
        Validate if ueCapabilityInformation was sent within RRC Guard time. (Helper function)
        """
        rrc_guard_timer = datetime.timedelta(seconds=rrc_guard_timer // 1000,
                                             microseconds=rrc_guard_timer % 1000 * 1000)
        transaction_id = self.regexp_transaction_id.findall(message)[0].split()[-1]
        if transaction_id != ue_cap_enquiry_id:
            return False
        transaction_time = datetime.datetime.strptime(self.regexp_transaction_time.findall(message)[0],
                                                      '%H:%M:%S.%f').time()
        elapsed_time = datetime.timedelta(hours=ue_cap_enquiry_time.hour, minutes=ue_cap_enquiry_time.minute,
                                          seconds=ue_cap_enquiry_time.second,
                                          microseconds=ue_cap_enquiry_time.microsecond) + rrc_guard_timer
        elapsed_time = datetime.datetime.strptime(str(elapsed_time), '%H:%M:%S.%f').time()
        if transaction_time > elapsed_time:
            return False
        return True

    def get_ues_rnti(self, egate_console_log_path='/opt/iphy/latest/egate_console.log'):
        """
        Get UEs RNTI from egate_console.log

        :param egate_console_log_path: (str) Path to egate_console.log
        :return rnti_dict: (dict) Dictionary with UEs RNTI
        """
        rnti_dict = dict()
        with open(egate_console_log_path, "r") as log_file:
            data = log_file.read()
        rnti_list = self.regexp_rnti.findall(data)
        for rnti in rnti_list:
            rnti_dict.update({int(rnti[0]): rnti[1]})
        logger.info('UE RNTI assignment: {}'.format(rnti_dict))
        return rnti_dict


def _convert_to_dict(lst):
    """
    Convert list to dictionary
    :param lst: input list
    :return: list converted to dictionary
    """
    res_dct = {lst[i]: lst[i + 1] for i in range(0, len(lst), 2)}
    return res_dct

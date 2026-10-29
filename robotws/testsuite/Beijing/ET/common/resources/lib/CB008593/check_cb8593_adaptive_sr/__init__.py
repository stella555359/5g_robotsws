# -*- coding: utf-8 -*-
"""
2022/05/25 first version by sheng.1.ye@nokia-sbell.com
           this is the checker to verify Cb8593AdaptiveSr
2022/06/09 update to fit new base class Checker
2022/06/14 refactoring, by Ye Sheng
2022/06/17 resolve case of SgNBModification sent before SgNBAdditionRequestAcknowledge, by Ye Sheng
2022/06/30 update format of item_list, by Ye Sheng
2022/08/25 change periodicity and threshold to configurable values and other refactoring, by Ye Sheng
2022/08/26 add min_time and max_time check for changing to period_and_offset_1, by Ye Sheng
"""

import unittest
from testsuite.Beijing.ET.common.resources.lib.info_parser import InfoParser
from testsuite.Beijing.ET.common.resources.lib.checker import Checker


class InvalidInfo:
    LESS_THAN_4_ADDITION_OF_UE_FOUND = "Only {add_num} <SgNBAdditionRequestAcknowledge> is found, less then 4"


class FailInfo:
    UE_BEFORE_13_HAS_ZERO_STARTING_PRB = "The starting PRB must NOT be 0 before UE13 added(ue_num={ue_num})"
    UE_AFTER_12_HAS_NON_ZERO_STARTING_PRB = "The starting PRB must be 0 after UE12 added(ue_num={ue_num})"

    UNEXPECTED_PERIOD_AND_OFFSET_TO_ADD = "Unexpected Period and Offset To Add: {period_and_offset} (ue_num={ue_num})"
    UNEXPECTED_MODIFICATION_REQUIRED_MESSAGES = "Unexpected Sgnb Modification Required Message:item_id={item_id}"
    MODIFY_PERIOD_AND_OFFSET_INCOMPLETE = "Some ues({ue_ids}) are not modified to expected Periodicity and Offset"
    MODIFY_PERIOD_AND_OFFSET_TO_SAME_VALUE = "Modify ue({ue_id) to the same Periodicity and Offset"
    MODIFY_PERIOD_AND_OFFSET_TO_UNEXPECTED_VALUE = ("Modify ue({ue_id)) to unexpected Periodicity and Offset: "
                                                    "{period_and_offset}")
    CHANGE_TO_PERIOD_AND_OFFSET_1_TIMER_EXCEED = "No change to period_and_offset_1: time={time} exceed {max_time}"
    CHANGE_TO_PERIOD_AND_OFFSET_1_TIME_OUT_OF_RANGE = ("Change to period_and_offset_1: time={time} "
                                                       "not in ({min_time}, {max_time})")

    UE_ID_ADDED_TWICE = "UE is {ue_id} added twice"
    RELEASE_OF_NON_EXIST_UE_ID = "release of non-exist UE_ID: {ue_id}"
    MODIFY_NON_EXIST_UE_ID = "modify non-exist UE_ID: {ue_id}"


class Const:
    PERIODICITY_AND_OFFSET_1 = 'sl10'
    PERIODICITY_AND_OFFSET_2 = 'sl20'
    PERIODICITY_AND_OFFSET_THRESHOLD_UP = 5
    PERIODICITY_AND_OFFSET_THRESHOLD_DOWN = 2
    MIN_TIME_TO_PERIODICITY_AND_OFFSET_1 = 38
    MAX_TIME_TO_PERIODICITY_AND_OFFSET_1 = 42


class CheckCb8593AdaptiveSr(Checker):

    def __init__(self, log_path, log_file, *args, **kwargs):
        super().__init__(log_path, *args, **kwargs)
        self.info_parser = InfoParser(filename=log_file)
        self.ue_info = {}
        self.sgnb_modification_required_msg_buffer = []
        self.current_periodicity_and_offset = None
        self.changing_to_period_and_offset_1_timer = None

    def verify(self):
        self.reset_ue_info()
        self.verify_message_flow()
        self.verify_sgnb_addtion_reach_expected_number()
        self.case_pass()

    def reset_ue_info(self):
        self.ue_info = {}
        self.sgnb_modification_required_msg_buffer = []
        self.current_periodicity_and_offset = Const.PERIODICITY_AND_OFFSET_1
        self.changing_to_period_and_offset_1_timer = None

    def verify_message_flow(self):
        message_info_list = self.get_x2ap_info_from_msg()
        self.logger.debug("ue_info=%s" % self.ue_info)
        for n, item in enumerate(message_info_list):
            self.logger.debug("n=%d, msg=%s" % (n, item))
            self.merge_sgnb_addition_request_with_acknowledge(n, item, message_info_list)
            self.update_message_counter(item['filter_match'])
            self.verify_message(item)
        self.changing_to_period_and_offset_1_check()

    def get_x2ap_info_from_msg(self):
        x2ap_info = self.info_parser.get_info(
            item_list=['Arrival Time',
                       'SgNB-UE-X2AP-ID:[-1] as UE_ID',
                       'SchedulingRequestResourceConfig->periodicityAndOffset:',
                       'SchedulingRequestResourceConfig->resource:',
                       'PUCCH-Resource->pucch-ResourceId:[] as ResourceIds',
                       'PUCCH-Resource->startingPRB:[] as startingPRBs'],
            filter_pattern=r'SgNBAdditionRequestAcknowledge|SgNBModificationRequired|UEContextRelease|'
                           r'SgNBAdditionRequest\b')
        return x2ap_info

    def merge_sgnb_addition_request_with_acknowledge(self, n, item, message_info_list):
        message = item['filter_match']
        if message == 'SgNBAdditionRequest':
            for i in range(n+1, len(message_info_list)):
                if message_info_list[i]['filter_match'] == 'SgNBAdditionRequestAcknowledge':
                    item.update(message_info_list[i])
                    message_info_list[i]['filter_match'] = '(SgNBAdditionRequestAcknowledge)'
                    break

    def verify_sgnb_addtion_reach_expected_number(self):
        add_num = self.counters['SgNBAdditionRequestAcknowledge']
        if add_num < 4:
            self.case_invalid(InvalidInfo.LESS_THAN_4_ADDITION_OF_UE_FOUND.format(add_num=add_num))

    def update_message_counter(self, message):
        if message[0] != '(':
            self.counters[message] += 1

    def verify_message(self, item):
        message = item['filter_match']
        if message == 'SgNBAdditionRequestAcknowledge':
            self.verify_sgnb_addition_request_acknowledge(item)
        elif message == 'SgNBModificationRequired':
            self.sgnb_modification_required_msg_buffer.append(item)
        elif message == 'UEContextRelease':
            self.verify_ue_context_release(item)

    def verify_sgnb_addition_request_acknowledge(self, msg_info):
        self.changing_to_period_and_offset_1_check(msg_time=msg_info['time_ms'])
        self.add_ue_id_to_list(msg_info)
        self.validate_sgnb_addition_period_and_offset(msg_info)
        self.validate_sgnb_addition_starting_prb(msg_info)
        if len(self.ue_info) > Const.PERIODICITY_AND_OFFSET_THRESHOLD_DOWN:
            self.changing_to_period_and_offset_1_timer = None

    def add_ue_id_to_list(self, msg_info):
        ue_id = msg_info['UE_ID']
        if ue_id in self.ue_info:
            self.case_fail(FailInfo.UE_ID_ADDED_TWICE.format(ue_id))
        if len(self.ue_info) + 1 == Const.PERIODICITY_AND_OFFSET_THRESHOLD_UP:
            self.current_periodicity_and_offset = Const.PERIODICITY_AND_OFFSET_2
            self.verify_sgnb_modification_required()
        elif self.sgnb_modification_required_msg_buffer:
            self.case_fail(FailInfo.UNEXPECTED_MODIFICATION_REQUIRED_MESSAGES.format(
                item_id=self.sgnb_modification_required_msg_buffer[0]['item_id']))
        self.ue_info[ue_id] = msg_info['periodicityAndOffset']
        self.logger.debug("ue_info=%s" % self.ue_info)

    def validate_sgnb_addition_period_and_offset(self, msg_info):
        ue_num = len(self.ue_info)
        info = FailInfo.UNEXPECTED_PERIOD_AND_OFFSET_TO_ADD.format(
            ue_num=ue_num, period_and_offset=msg_info['periodicityAndOffset'])
        self.assert_equal(
            'periodicityAndOffset', self.current_periodicity_and_offset, msg_info['periodicityAndOffset'], info)

    def validate_sgnb_addition_starting_prb(self, msg_info):
        ue_num = len(self.ue_info)
        staring_prb = dict(zip(msg_info['ResourceIds'], msg_info['startingPRBs']))[msg_info['resource']]
        if ue_num < 13:
            info = FailInfo.UE_BEFORE_13_HAS_ZERO_STARTING_PRB.format(ue_num=ue_num)
            self.assert_unequal('startingPRB', 0, staring_prb, info)
        else:
            info = FailInfo.UE_AFTER_12_HAS_NON_ZERO_STARTING_PRB.format(ue_num=ue_num)
            self.assert_equal('startingPRB', 0, staring_prb, info)

    def verify_sgnb_modification_required(self):
        for msg_info in self.sgnb_modification_required_msg_buffer:
            ue_id = msg_info['UE_ID']
            period_and_offset = msg_info['periodicityAndOffset']
            self.modify_ue(ue_id, period_and_offset)
        ue_ids = [ue_id for ue_id, v in self.ue_info.items() if v != self.current_periodicity_and_offset]
        if ue_ids:
            self.case_fail(FailInfo.MODIFY_PERIOD_AND_OFFSET_INCOMPLETE.format(ue_ids=ue_ids))
        self.sgnb_modification_required_msg_buffer = []

    def modify_ue(self, ue_id, period_and_offset):
        if ue_id not in self.ue_info:
            self.case_fail(FailInfo.MODIFY_NON_EXIST_UE_ID.format(ue_id=ue_id))
        if self.ue_info[ue_id] == self.current_periodicity_and_offset:
            self.case_fail(FailInfo.MODIFY_PERIOD_AND_OFFSET_TO_SAME_VALUE.format(ue_id=ue_id))
        elif period_and_offset != self.current_periodicity_and_offset:
            self.case_fail(FailInfo.MODIFY_PERIOD_AND_OFFSET_TO_UNEXPECTED_VALUE.format(
                ue_id=ue_id, period_and_offset=period_and_offset))
        self.ue_info[ue_id] = period_and_offset
        self.logger.debug("ue_info=%s" % self.ue_info)

    def verify_ue_context_release(self, msg_info):
        self.changing_to_period_and_offset_1_check(msg_time=msg_info['time_ms'])
        self.remove_ue_id_from_list(msg_info)

    def remove_ue_id_from_list(self, msg_info):
        ue_id = msg_info['UE_ID']
        if ue_id not in self.ue_info:
            self.case_fail(FailInfo.RELEASE_OF_NON_EXIST_UE_ID.format(ue_id=ue_id))
        del self.ue_info[ue_id]
        if len(self.ue_info) <= Const.PERIODICITY_AND_OFFSET_THRESHOLD_DOWN:
            if not self.changing_to_period_and_offset_1_timer:
                self.changing_to_period_and_offset_1_timer = msg_info['time_ms']

        self.logger.debug("ue_info=%s" % self.ue_info)

    def changing_to_period_and_offset_1_check(self, msg_time=None):
        if self.changing_to_period_and_offset_1_timer:
            self.verify_time_to_period_and_offset_1(msg_time)
            if self.sgnb_modification_required_msg_buffer:
                self.current_periodicity_and_offset = Const.PERIODICITY_AND_OFFSET_1
                self.verify_sgnb_modification_required()
                self.changing_to_period_and_offset_1_timer = None

    def verify_time_to_period_and_offset_1(self, msg_time):
        if self.sgnb_modification_required_msg_buffer:
            stop_time = self.sgnb_modification_required_msg_buffer[0]['time_ms']
            self.verify_time_to_period_and_offset_1_in_range(stop_time - self.changing_to_period_and_offset_1_timer)
        elif msg_time:
            self.verify_time_to_period_and_offset_1_not_reach(msg_time - self.changing_to_period_and_offset_1_timer)

    def verify_time_to_period_and_offset_1_in_range(self, time_used):
        time_used /= 1000
        min_time = Const.MIN_TIME_TO_PERIODICITY_AND_OFFSET_1
        max_time = Const.MAX_TIME_TO_PERIODICITY_AND_OFFSET_1
        description = "Change to period_and_offset_1, time between (%d, %d)" % (min_time, max_time)
        fail_info = FailInfo.CHANGE_TO_PERIOD_AND_OFFSET_1_TIME_OUT_OF_RANGE.format(
            time=time_used, min_time=min_time, max_time=max_time)
        self.assert_true(description, min_time < time_used < max_time, fail_info)

    def verify_time_to_period_and_offset_1_not_reach(self, time_used):
        time_used /= 1000
        max_time = Const.MAX_TIME_TO_PERIODICITY_AND_OFFSET_1
        description = "No change to period_and_offset_1, because timer not exceed %d" % max_time
        fail_info = FailInfo.CHANGE_TO_PERIOD_AND_OFFSET_1_TIMER_EXCEED.format(time=time_used, max_time=max_time)
        self.assert_true(description, time_used < max_time, fail_info)


def verify_cb8593_adaptive_sr(log_path, x2_file, log_level=None):
    checker = CheckCb8593AdaptiveSr(log_path, x2_file, log_level=log_level)
    checker.verify()
    checker.create_robot_file()
    return True


if __name__ == '__main__':
    import ut
    unittest.main(module=ut)

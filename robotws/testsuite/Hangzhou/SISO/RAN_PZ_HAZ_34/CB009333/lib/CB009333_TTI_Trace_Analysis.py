# -*- coding: utf-8 -*

"""
Author:         Zhang Xuewen developped for 23R3
Contact Mail:   22R4:xuewen.zhang@nokia-sbell.com
Description:    Event trace log analysis
                Column index may changes in different program, so when calling this file,
                you will need to set value for program. Currently supported versions are:  22R4
                If program is not set, it's default to 23R3
"""
import logging
from testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.python.check_csv_log import *

frame_structure_info = {
    "name": "1208_GP1 _A1",
    "prach_configuration_index": 92,
    "sp_slots": [3, 8, 13, 18],
    "sib1_slots": [10, 11],
    "ssb_slots": [0],
    "trs_slots": [2, 3],
    "ul_slots": [4, 9, 14, 19],
    "dl_slots": [0, 1, 2, 5, 6, 7, 10, 11, 12, 15, 16, 17],
    "csirsTrackingPeriod": 20,
    "ssBurstSetPeriod": 20,
}


class CB009333_TTI_Analyzer(object):
    def __init__(self, file_path):
        self.INDEX_event = 1
        self.file_path = file_path
        self.INDEX_dlFdSchedData_numOfPrb = self.get_column_value_index_from_event(
            "dlFdSchedData", "numOfPrb"
        )
        self.INDEX_dlFdSchedData_rnti = self.get_column_value_index_from_event(
            "dlFdSchedData", "rnti"
        )
        try:
            self.INDEX_dlPreSchedData_rnti = self.get_column_value_index_from_event(
                "dlPreSchedData", "rnti"
            )
        except ValueError as e:
            logging.info("rnti  not found in dlPreSchedData!{}".format(e))
            self.INDEX_dlPreSchedData_rnti = 0

        try:
            self.INDEX_dlPreSchedData_highestClassPriority = (
                self.get_column_value_index_from_event(
                    "dlPreSchedData", "highestClassPriority"
                )
            )
        except ValueError as e:
            logging.info("highestClassPriority not found in dlPreSchedData!{}".format(e))
            self.INDEX_dlPreSchedData_highestClassPriority = 0
        self.INDEX_dlTdSchedSubcellData_resReqClassPrio = (
            self.get_column_value_index_from_event(
                "dlTdSchedSubcellData", "resReqClassPrio"
            )
        )
        self.INDEX_dlTdSchedSubcellData_rnti = (
                self.INDEX_dlTdSchedSubcellData_resReqClassPrio - 1
        )

    def get_rnti(self):
        """
        Filter for event dlTdSchedSubcellData and find resReqClassPrio=40,
        which means rnti used for DL data traffic in initial transmission.
        :return: rnti value
        """
        try:
            dlTdSchedSubcellData_event_with_data_traffic = (
                get_lines_with_multiple_column_filter(
                    file_path=self.file_path,
                    column_list=[
                        self.INDEX_event,
                        self.INDEX_dlTdSchedSubcellData_resReqClassPrio,
                    ],
                    expected_list=["dlTdSchedSubcellData", "40"],
                )
            )
        except LookupError:
            raise LookupError(
                "Fail to get rnti as no event found for dlTdSchedSubcellData with resReqClassPrio=40"
            )
        rnti = dlTdSchedSubcellData_event_with_data_traffic[
            len(dlTdSchedSubcellData_event_with_data_traffic) - 1
            ][1][self.INDEX_dlTdSchedSubcellData_rnti - 1]
        logging.info("Current available rnti is: {}".format(rnti))
        print("Current available rnti is: {}".format(rnti))
        print(
            "INDEX_dlTdSchedSubcellData_rnti is: {}".format(
                self.INDEX_dlTdSchedSubcellData_rnti
            )
        )
        print(dlTdSchedSubcellData_event_with_data_traffic[0][1])
        print(
            "INDEX_dlTdSchedSubcellData_resReqClassPrio is: {}".format(
                self.INDEX_dlTdSchedSubcellData_resReqClassPrio
            )
        )
        return rnti

    def get_dlFdSchedData_event(self):
        rnti = self.get_rnti()
        print(rnti, self.INDEX_dlFdSchedData_rnti)
        try:
            dlFdSchedData_event = get_lines_with_multiple_column_filter(
                file_path=self.file_path,
                column_list=[self.INDEX_event, self.INDEX_dlFdSchedData_rnti],
                expected_list=["dlFdSchedData", rnti],
            )
        except LookupError:
            raise LookupError("No dlFdSchedData event found")
        else:
            return dlFdSchedData_event

    def reassign_event_column_number(self, event, col_filter=None):
        """
        Author: Ren Biyao
        Get column number base on event
        """
        column_list = []
        last_col_num = None
        with open(self.file_path) as f:
            lines = f.readlines()
            for line in lines:
                if event in line:
                    if col_filter:
                        if col_filter in line:
                            column_list = line.split(",")
                            break
                    else:
                        column_list = line.split(",")
                        break
        for i, value in enumerate(column_list):
            if value.isdigit():
                last_col_num = i
                break
        return column_list, last_col_num

    def get_column_value_index_from_event(self, event, column_name):
        """
        Author: Zhang xuewen
        find column number by column name from event, if multi same column name,
        only return the first index
        :param column_name:
        :param event:
        :return:
        """
        event_column_list, last_col_num = self.reassign_event_column_number(event)
        column_index = event_column_list.index(column_name) + 1
        column_value_index = last_col_num + column_index
        return column_value_index

    def if_highestClassPriority17_in_dlPreSchedData(self, rnti=None):
        try:
            rnti = self.get_rnti() if rnti is None else rnti
            logging.info(
                "INDEX_dlPreSchedData_rnti:{} ".format(self.INDEX_dlPreSchedData_rnti)
            )
            dlPreSchedData_event = get_lines_with_multiple_column_filter(
                file_path=self.file_path,
                column_list=[
                    self.INDEX_event,
                    self.INDEX_dlPreSchedData_highestClassPriority,
                    self.INDEX_dlPreSchedData_rnti,
                ],
                expected_list=["dlPreSchedData", "18", rnti],
            )
            print(dlPreSchedData_event[0][1])
        except LookupError:
            # raise LookupError("No dlPreSchedData event found")
            logging.info(
                "No dlPreSchedData event found for which highestClassPriority=18 "
            )
            print("No dlPreSchedData event found for which highestClassPriority=18 ")
            return False
        else:
            return True

    def get_32sfn_lines_with_multiple_column_filter(
            self, file_path, column_list, expected_list, delimiter=","
    ):
        """
        get all lines that match all filter.

        :param file_path: String: csv log file path.
        :param column_list: List: a list content all target filters' column number.
                             column number count start from 1.
        :param expected_list: List: a list content all filters, the sort should match with column_list
        :param delimiter: String: the spliter to split values into cells.
        :return: List: content all lines match the filter.
        """
        result = []
        sfn_start = -1
        sfn_end = 0
        event_column_list, last_col_num = self.reassign_event_column_number(
            "dlPreSchedData"
        )
        column_index = event_column_list.index("highestClassPriority")
        column_value_index = last_col_num + column_index
        column_index = event_column_list.index("sfn")
        sfn_value_index = last_col_num + column_index
        matrix = read_csv_file_into_matrix(file_path, delimiter)
        # print("matrix len:{}".format(len(matrix)))
        for line in matrix:
            if line[1]:
                for i in range(len(column_list)):
                    try:
                        target = line[1][int(column_list[i]) - 1]
                        expected = expected_list[i]
                        if isinstance(expected, list):
                            have_item = False
                            for item in expected:
                                if item in target:
                                    have_item = True
                            if not have_item:
                                break
                        elif expected not in target:
                            break
                    except IndexError:
                        continue
                else:
                    if "dlPreSchedData" in line[1][0]:
                        # print("line[1][sfn_value_index]:{}, line[1][column_value_index]:{} mod32={}".format(
                        #     line[1][sfn_value_index], line[1][column_value_index],
                        #     int(line[1][sfn_value_index]) % 32))
                        # if int(line[1][column_value_index]) == 18 and sfn_start == -1:
                        if sfn_start == -1:
                            sfn_start = int(line[1][sfn_value_index])
                            print("sfn_start={}".format(sfn_start))
                            print(
                                "line[1][sfn_value_index]:{}, line[1][column_value_index]:{}".format(
                                    line[1][sfn_value_index],
                                    line[1][column_value_index],
                                )
                            )
                        if sfn_start > 0:
                            sfn_counter = (
                                int(line[1][sfn_value_index]) - sfn_start
                                if int(line[1][sfn_value_index]) - sfn_start >= 0
                                else int(line[1][sfn_value_index]) - sfn_start + 1024
                            )
                            if sfn_counter > 32 and sfn_end == 0:
                                sfn_end = int(line[1][sfn_value_index])
                                print(
                                    "sfn_start={},sfn_end={}".format(sfn_start, sfn_end)
                                )
                    if sfn_start > 0 and sfn_end == 0:
                        result.append(line)
                    if sfn_end > 0:
                        break
        if not result:
            raise LookupError("Can't found any line match all column expected.")
        return result

    def CB009333_A_drbDifferentiationEnabled(self):
        """
        Author: Zhang xuewen
        1.UE enters micro-DTX dtxOptimizedDrbTraffic scheduler, highestClassPriority=17 in L2-PS tti-trace
        2.UE enters micro-DTX dtxOptimizedDrbTraffic scheduler decision is based on NRDRB.X.dtxMaxRetentionDelay
        and NRDRB.X.dtxDelaySinceLastScheduling
        3.UE receives bundled packets on non-GBR 5QI-7(example) service with additional delay
        (NRDRB.X.dtxMaxRetentionDelay=5ms)
        4.Any GBR and delay-sensitive user data packets without any impact
        - HARQ retransmission
        - MAC CE
        - SIB1,SIBX
        - DL SRB data
        - 5QI5,5QI1,5QI2
        - RACH MSG2
        - GBR (CB008379)
        - RLC ACK/NACK status AM PDU for UL packets are transmitted on DL (CB009333-F)
        :return:
        """
        # check NRDRB-12.dtxMaxRetentionDelay=5ms
        try:
            event_data = self.get_32sfn_lines_with_multiple_column_filter(
                file_path=self.file_path,
                column_list=[
                    self.INDEX_event,
                ],
                expected_list=[
                    [
                        "dlPreSchedData",
                        "dlFdSchedData",
                        "dlDtxOptimData",
                    ],
                ],
            )
        except LookupError:
            logging.info("No dlPreSchedData event found!")
            return False

        return self.check_dtxMaxRetentionDelay(event_data)

    def check_dtxMaxRetentionDelay(self, event_data):
        """
        Author: Zhang xuewen
        check NRDRB-12.dtxMaxRetentionDelay=5ms
        :return:
        """
        event_column_list, last_col_num = self.reassign_event_column_number(
            "dlPreSchedData"
        )
        column_index = event_column_list.index("highestClassPriority")
        highestClassPriority_value_index = last_col_num + column_index
        column_index = event_column_list.index("sfn")
        dlPreSchedData_sfn_value_index = last_col_num + column_index
        slot_index = event_column_list.index("slot")
        dlPreSchedData_slot_value_index = last_col_num + slot_index

        event_column_list, last_col_num = self.reassign_event_column_number(
            "dlFdSchedData"
        )
        column_index = event_column_list.index("sfn")
        dlFdSchedData_sfn_value_index = last_col_num + column_index
        slot_index = event_column_list.index("slot")
        dlFdSchedData_slot_value_index = last_col_num + slot_index
        line_index = 0
        print("event_data:{}".format(len(event_data)))
        for line in event_data:
            line_index = line_index + 1

            if (
                    line[1][0] == "dlPreSchedData"
                    and int(line[1][highestClassPriority_value_index]) == 18
            ):
                # dtxMaxRetentionDelay=5ms, so delay slots = 10
                print(
                    "dlPreSchedData: sfn:{},slot:{}".format(
                        line[1][dlPreSchedData_sfn_value_index],
                        line[1][dlPreSchedData_slot_value_index],
                    )
                )
                expected_dlFdSchedData_slot = (
                        int(line[1][dlPreSchedData_slot_value_index]) + 10
                )
                expected_dlFdSchedData_sfn = int(
                    line[1][dlPreSchedData_sfn_value_index]
                )
                print(
                    "[before]expected_dlFdSchedData_sfn:{},expected_dlFdSchedData_slot:{}".format(
                        expected_dlFdSchedData_sfn, expected_dlFdSchedData_slot
                    )
                )
                if expected_dlFdSchedData_slot >= 20:
                    expected_dlFdSchedData_sfn = (
                            int(line[1][dlPreSchedData_sfn_value_index]) + 1
                    )
                    expected_dlFdSchedData_slot = expected_dlFdSchedData_slot % 20

                # exception 1: if target slot is UL slot, then target slot change to next DL slot
                if expected_dlFdSchedData_slot in frame_structure_info["ul_slots"]:
                    if (
                            expected_dlFdSchedData_slot
                            > frame_structure_info["dl_slots"][-1]
                    ):
                        expected_dlFdSchedData_slot = frame_structure_info["dl_slots"][
                            0
                        ]
                        expected_dlFdSchedData_sfn = expected_dlFdSchedData_sfn + 1
                    else:
                        for slot in frame_structure_info["dl_slots"]:
                            if expected_dlFdSchedData_slot < slot:
                                expected_dlFdSchedData_slot = slot
                                break

                # exception 2: if there is SSB or TRS slot before target slot, then schedule it on SSS or TRS slot
                if (
                        expected_dlFdSchedData_slot <= 10
                        and expected_dlFdSchedData_sfn
                        % (frame_structure_info["ssBurstSetPeriod"] / 10)
                        == 0
                ):
                    expected_dlFdSchedData_slot = frame_structure_info["ssb_slots"][0]
                elif (
                        frame_structure_info["trs_slots"][0]
                        <= expected_dlFdSchedData_slot
                        <= frame_structure_info["trs_slots"][-1] + 10
                        and expected_dlFdSchedData_sfn
                        % (frame_structure_info["csirsTrackingPeriod"] / 10)
                        == 1
                ):
                    if (
                            expected_dlFdSchedData_slot
                            - frame_structure_info["trs_slots"][0]
                            <= 10
                    ):
                        expected_dlFdSchedData_slot = frame_structure_info["trs_slots"][
                            0
                        ]
                    else:
                        expected_dlFdSchedData_slot = frame_structure_info["trs_slots"][
                            -1
                        ]

                expected_dlFdSchedData_sfn = expected_dlFdSchedData_sfn % 1024
                print(
                    "[after]expected_dlFdSchedData_sfn:{},expected_dlFdSchedData_slot:{}".format(
                        expected_dlFdSchedData_sfn, expected_dlFdSchedData_slot
                    )
                )

                for next_line in event_data[line_index:]:
                    if "dlFdSchedData" in next_line[1][0]:
                        if (
                                int(next_line[1][dlFdSchedData_sfn_value_index])
                                != expected_dlFdSchedData_sfn
                                or int(next_line[1][dlFdSchedData_slot_value_index])
                                != expected_dlFdSchedData_slot
                        ):
                            logging.error(
                                "dlFdSchedData expected sfn:{} slot:{},but receive sfn:{} slot:{}!".format(
                                    expected_dlFdSchedData_sfn,
                                    expected_dlFdSchedData_slot,
                                    int(next_line[1][dlFdSchedData_sfn_value_index]),
                                    int(next_line[1][dlFdSchedData_slot_value_index]),
                                )
                            )
                            return False
                        else:
                            print(
                                "dlFdSchedData matched: sfn:{} [{}] slot:{} [{}]!".format(
                                    expected_dlFdSchedData_sfn,
                                    int(next_line[1][dlFdSchedData_sfn_value_index]),
                                    expected_dlFdSchedData_slot,
                                    int(next_line[1][dlFdSchedData_slot_value_index]),
                                )
                            )
                            break
                    if "dlDtxOptimData" in next_line[1][0]:
                        column_list = next_line[1]
                        for i, value in enumerate(column_list):
                            if value.isdigit():
                                last_col_num = i
                                break
                        column_index = column_list.index("dlDtxOptimEvent")
                        dlDtxOptimEvent_value_index = last_col_num + column_index
                        column_index = column_list.index("sfn")
                        dlDtxOptimEvent_sfn_value_index = last_col_num + column_index
                        slot_index = event_column_list.index("slot")
                        dlDtxOptimEvent_slot_value_index = last_col_num + slot_index

                        print(
                            "next_line[1][dlDtxOptimEvent_value_index]:{}".format(
                                next_line[1][dlDtxOptimEvent_value_index]
                            )
                        )

                        if (
                                next_line[1][dlDtxOptimEvent_value_index]
                                == "SCHEDONSIBORPAGING"
                        ):
                            logging.info(
                                "Paging received! dlFdSchedData expected sfn:{} slot:{},\
                                          change to sfn:{} slot:{}!".format(
                                    expected_dlFdSchedData_sfn,
                                    expected_dlFdSchedData_slot,
                                    int(next_line[1][dlDtxOptimEvent_sfn_value_index]),
                                    int(next_line[1][dlDtxOptimEvent_slot_value_index]),
                                )
                            )
                            expected_dlFdSchedData_sfn = int(
                                next_line[1][dlDtxOptimEvent_sfn_value_index]
                            )
                            expected_dlFdSchedData_slot = int(
                                next_line[1][dlDtxOptimEvent_slot_value_index]
                            )

        return True

    def CB009333_B_multiCellSyncEnabled(self):
        """
        Author: Zhang xuewen
        Check if dlDtxOptimData have value MULTICELLSYNCSLOT in dlDtxOptimEvent
        :return:
        """
        try:
            event_data = self.get_32sfn_lines_with_multiple_column_filter(
                file_path=self.file_path,
                column_list=[
                    self.INDEX_event,
                ],
                expected_list=[
                    [
                        "dlPreSchedData",
                        "dlFdSchedData",
                        "dlDtxOptimData",
                    ],
                ],
            )
        except LookupError:
            logging.info("No dlPreSchedData event found")

            return False

        return self.check_multiCellSyncEnabled(event_data)

    def check_multiCellSyncEnabled(self, event_data):
        """
        Author: Zhang xuewen
        check multiCellSyncEnabled
        :return:
        """
        event_column_list, last_col_num = self.reassign_event_column_number(
            "dlDtxOptimData"
        )
        column_index = event_column_list.index("dlDtxOptimEvent")
        dlDtxOptimEvent_value_index = last_col_num + column_index
        column_index = event_column_list.index("sfn")
        dlDtxOptimData_sfn_value_index = last_col_num + column_index
        slot_index = event_column_list.index("slot")
        dlDtxOptimData_slot_value_index = last_col_num + slot_index

        event_column_list, last_col_num = self.reassign_event_column_number(
            "dlFdSchedData"
        )
        column_index = event_column_list.index("sfn")
        dlFdSchedData_sfn_value_index = last_col_num + column_index
        slot_index = event_column_list.index("slot")
        dlFdSchedData_slot_value_index = last_col_num + slot_index
        physCellId_index = event_column_list.index("physCellId")
        dlFdSchedData_physCellId_value_index = last_col_num + physCellId_index
        line_index = 0
        print("event_data:{}".format(len(event_data)))
        for line in event_data:
            line_index = line_index + 1

            if (
                    "dlDtxOptimData" in line[1][0]
                    and line[1][dlDtxOptimEvent_value_index] == "MULTICELLSYNCSLOT"
            ):
                print(
                    "dlDtxOptimData: sfn:{},slot:{}".format(
                        line[1][dlDtxOptimData_sfn_value_index],
                        line[1][dlDtxOptimData_slot_value_index],
                    )
                )
                return True
        return False

    def CB009333_D_drxOnDurationTimer(self):
        """
        Author: Zhang xuewen
        Check DL data delay <= dtxMaxRetentionDelay=10ms
        :return:
        """
        try:
            event_data = self.get_32sfn_lines_with_multiple_column_filter(
                file_path=self.file_path,
                column_list=[
                    self.INDEX_event,
                ],
                expected_list=[
                    [
                        "dlPreSchedData",
                        "dlFdSchedData",
                        "dlDtxOptimData",
                    ],
                ],
            )
        except LookupError:
            logging.info(
                "No dlPreSchedData event found!")
            return False

        return self.check_drxOnDurationTimer(event_data)

    def check_drxOnDurationTimer(self, event_data, dtxMaxRetentionDelay=10):
        """
        Author: Zhang xuewen
        Check DL data delay <= dtxMaxRetentionDelay=10ms
        :return:
        """
        event_column_list, last_col_num = self.reassign_event_column_number(
            "dlPreSchedData"
        )
        column_index = event_column_list.index("highestClassPriority")
        highestClassPriority_value_index = last_col_num + column_index
        column_index = event_column_list.index("sfn")
        dlPreSchedData_sfn_value_index = last_col_num + column_index
        slot_index = event_column_list.index("slot")
        dlPreSchedData_slot_value_index = last_col_num + slot_index

        event_column_list, last_col_num = self.reassign_event_column_number(
            "dlFdSchedData"
        )
        column_index = event_column_list.index("sfn")
        dlFdSchedData_sfn_value_index = last_col_num + column_index
        slot_index = event_column_list.index("slot")
        dlFdSchedData_slot_value_index = last_col_num + slot_index
        line_index = 0
        print("event_data:{}".format(len(event_data)))
        for line in event_data:
            line_index = line_index + 1

            if (
                    "dlPreSchedData" in line[1][0]
                    and int(line[1][highestClassPriority_value_index]) == 18
            ):
                # dtxMaxRetentionDelay=5ms, so delay slots = 10
                print(
                    "dlPreSchedData: sfn:{},slot:{}".format(
                        line[1][dlPreSchedData_sfn_value_index],
                        line[1][dlPreSchedData_slot_value_index],
                    )
                )
                expected_dlFdSchedData_slot = (
                        int(line[1][dlPreSchedData_slot_value_index]) + int(dtxMaxRetentionDelay / 0.5)
                )
                expected_dlFdSchedData_sfn = int(
                    line[1][dlPreSchedData_sfn_value_index]
                )
                print(
                    "[before]expected_dlFdSchedData_sfn:{},expected_dlFdSchedData_slot:{}".format(
                        expected_dlFdSchedData_sfn, expected_dlFdSchedData_slot
                    )
                )
                if expected_dlFdSchedData_slot >= 20:
                    expected_dlFdSchedData_sfn = (
                            int(line[1][dlPreSchedData_sfn_value_index]) + 1
                    )
                    expected_dlFdSchedData_slot = expected_dlFdSchedData_slot % 20

                # exception 1: if target slot is UL slot, then target slot change to next DL slot
                if expected_dlFdSchedData_slot in frame_structure_info["ul_slots"]:
                    if (
                            expected_dlFdSchedData_slot
                            > frame_structure_info["dl_slots"][-1]
                    ):
                        expected_dlFdSchedData_slot = frame_structure_info["dl_slots"][
                            0
                        ]
                        expected_dlFdSchedData_sfn = expected_dlFdSchedData_sfn + 1
                    else:
                        for slot in frame_structure_info["dl_slots"]:
                            if expected_dlFdSchedData_slot < slot:
                                expected_dlFdSchedData_slot = slot
                                break

                # exception 2: if there is SSB or TRS slot before target slot, then schedule it on SSS or TRS slot
                if (
                        expected_dlFdSchedData_slot <= 10
                        and expected_dlFdSchedData_sfn
                        % (frame_structure_info["ssBurstSetPeriod"] / 10)
                        == 0
                ):
                    expected_dlFdSchedData_slot = frame_structure_info["ssb_slots"][0]
                elif (
                        frame_structure_info["trs_slots"][0]
                        <= expected_dlFdSchedData_slot
                        <= frame_structure_info["trs_slots"][-1] + 10
                        and expected_dlFdSchedData_sfn
                        % (frame_structure_info["csirsTrackingPeriod"] / 10)
                        == 1
                ):
                    if (
                            expected_dlFdSchedData_slot
                            - frame_structure_info["trs_slots"][0]
                            <= 10
                    ):
                        expected_dlFdSchedData_slot = frame_structure_info["trs_slots"][
                            0
                        ]
                    else:
                        expected_dlFdSchedData_slot = frame_structure_info["trs_slots"][
                            -1
                        ]

                print(
                    "[after]expected_dlFdSchedData_sfn:{},expected_dlFdSchedData_slot:{}".format(
                        expected_dlFdSchedData_sfn, expected_dlFdSchedData_slot
                    )
                )
                next_sfn_cycle = expected_dlFdSchedData_sfn / 1024
                expected_dlFdSchedData_sfn = expected_dlFdSchedData_sfn % 1024
                for next_line in event_data[line_index:]:
                    if "dlFdSchedData" in next_line[1][0]:
                        if (
                                int(next_line[1][dlFdSchedData_sfn_value_index])
                                == expected_dlFdSchedData_sfn
                                and int(next_line[1][dlFdSchedData_slot_value_index])
                                > expected_dlFdSchedData_slot
                        ) or (
                                next_sfn_cycle == 0
                                and int(next_line[1][dlFdSchedData_sfn_value_index])
                                > expected_dlFdSchedData_sfn
                        ) or (
                                next_sfn_cycle == 1
                                and 0 < int(next_line[1][dlFdSchedData_sfn_value_index])
                                - expected_dlFdSchedData_sfn < 1000
                        ):
                            logging.error(
                                "dlFdSchedData expected sfn:{} slot:{},but receive sfn:{} slot:{}!".format(
                                    expected_dlFdSchedData_sfn,
                                    expected_dlFdSchedData_slot,
                                    int(next_line[1][dlFdSchedData_sfn_value_index]),
                                    int(next_line[1][dlFdSchedData_slot_value_index]),
                                )
                            )
                            return False
                        else:
                            print(
                                "dlFdSchedData expected and received sfn:{} [{}] slot:{} [{}]!".format(
                                    expected_dlFdSchedData_sfn,
                                    int(next_line[1][dlFdSchedData_sfn_value_index]),
                                    expected_dlFdSchedData_slot,
                                    int(next_line[1][dlFdSchedData_slot_value_index]),
                                )
                            )
                            break
                    if "dlDtxOptimData" in next_line[1][0]:
                        column_list = next_line[1]
                        for i, value in enumerate(column_list):
                            if value.isdigit():
                                last_col_num = i
                                break
                        column_index = column_list.index("dlDtxOptimEvent")
                        dlDtxOptimEvent_value_index = last_col_num + column_index
                        column_index = column_list.index("sfn")
                        dlDtxOptimEvent_sfn_value_index = last_col_num + column_index
                        slot_index = event_column_list.index("slot")
                        dlDtxOptimEvent_slot_value_index = last_col_num + slot_index

                        print(
                            "next_line[1][dlDtxOptimEvent_value_index]:{}".format(
                                next_line[1][dlDtxOptimEvent_value_index]
                            )
                        )

                        if (
                                next_line[1][dlDtxOptimEvent_value_index]
                                == "SCHEDONSIBORPAGING"
                        ):
                            logging.info(
                                "Paging received! dlFdSchedData expected sfn:{} slot:{},\
                                          change to sfn:{} slot:{}!".format(
                                    expected_dlFdSchedData_sfn,
                                    expected_dlFdSchedData_slot,
                                    int(next_line[1][dlDtxOptimEvent_sfn_value_index]),
                                    int(next_line[1][dlDtxOptimEvent_slot_value_index]),
                                )
                            )
                            expected_dlFdSchedData_sfn = int(
                                next_line[1][dlDtxOptimEvent_sfn_value_index]
                            )
                            expected_dlFdSchedData_slot = int(
                                next_line[1][dlDtxOptimEvent_slot_value_index]
                            )

        return True

    def CB009333_E_SliceAwareScheduler(self):
        """
        Author: Zhang xuewen
        Check EnhDtxOptimizedScheduler_interaction_with_SliceAwareScheduler_when_multiple_UE
        :return:
        """
        try:
            event_data = self.get_32sfn_lines_with_multiple_column_filter(
                file_path=self.file_path,
                column_list=[
                    self.INDEX_event,
                ],
                expected_list=[
                    [
                        "dlDrbWeightData",
                        "dlSliceData",
                        "dlDtxOptimData",
                        "dlPreSchedData"
                    ],
                ],
            )
        except LookupError:
            logging.info(
                "No dlDrbWeightData dlSliceData dlDtxOptimData event found for which highestClassPriority=18"
            )
            print("No dlDrbWeightData dlSliceData dlDtxOptimData event found")
            return False

        return self.check_SliceAwareScheduler(event_data)

    def find_last(self, lst, item):
        try:
            return len(lst) - next(i for i, elem in enumerate(reversed(lst), 1) if elem == item)
        except StopIteration:
            return -1

    def check_SliceAwareScheduler(self, event_data):
        """
        Author: Zhang xuewen
        1 Check rrmSliceAvgLowShare between maxQuota and minQuota，
        Note: If traffic is very low，it maybe less than minQuota
        2 Check rrmAvgDrbPrbAlloc，average PRB share of a slice in the range of about 1000ms
        :return:
        """
        snssai_1 = {
            'sst': 1,
            'maxQuota': 80,
            'minQuota': 10
        }
        snssai_2 = {
            'sst': 2,
            'maxQuota': 60,
            'minQuota': 20
        }
        event_column_list, last_col_num = self.reassign_event_column_number(
            "dlSliceData"
        )
        column_index = event_column_list.index("rrmSliceAvgLowShare")
        rrmSliceAvgLowShare_value_index = last_col_num + column_index
        column_index = event_column_list.index("sst")
        sst_value_index = last_col_num + column_index
        column_index = event_column_list.index("sfn")
        dlSliceData_sfn_value_index = last_col_num + column_index
        slot_index = event_column_list.index("slot")
        dlSliceData_slot_value_index = last_col_num + slot_index

        line_index = 0
        print("event_data:{}".format(len(event_data)))
        check_rrmSliceAvgLowShare = False
        check_dlDtxOptimData = False
        for line in event_data:
            line_index = line_index + 1

            if "dlSliceData" in line[1][0]:
                print(
                    "dlDrbWeightData: sfn:{},slot:{}".format(
                        line[1][dlSliceData_sfn_value_index],
                        line[1][dlSliceData_slot_value_index],
                    )
                )
                for next_line in event_data[line_index:]:
                    if "dlSliceData" in next_line[1][0]:
                        if (
                                next_line[1][dlSliceData_sfn_value_index]
                                == line[1][dlSliceData_sfn_value_index]
                                and next_line[1][dlSliceData_slot_value_index]
                                == line[1][dlSliceData_slot_value_index]
                        ):
                            if ((int(line[1][sst_value_index]) == snssai_1['sst']
                                 and float(line[1][rrmSliceAvgLowShare_value_index]) * 100 < snssai_1['maxQuota'])
                                or (int(line[1][sst_value_index]) == snssai_2['sst']
                                    and float(line[1][rrmSliceAvgLowShare_value_index]) * 100 < snssai_2['maxQuota'])) \
                                    and ((int(line[1][sst_value_index]) == snssai_1['sst']
                                          and float(line[1][rrmSliceAvgLowShare_value_index]) * 100 < snssai_1[
                                              'maxQuota'])
                                         or (int(line[1][sst_value_index]) == snssai_2['sst']
                                             and float(line[1][rrmSliceAvgLowShare_value_index]) * 100 < snssai_2[
                                                 'maxQuota'])):
                                check_rrmSliceAvgLowShare = True
                                logging.info(
                                    "rrmSliceAvgLowShare unexpected:sst[{}] {}, sst[{}] {}! ratio:{}".format(
                                        int(line[1][sst_value_index]),
                                        float(line[1][rrmSliceAvgLowShare_value_index]),
                                        int(next_line[1][sst_value_index]),
                                        float(next_line[1][rrmSliceAvgLowShare_value_index]),
                                        round(float(line[1][rrmSliceAvgLowShare_value_index])/float(
                                            next_line[1][rrmSliceAvgLowShare_value_index]), 2))
                                    )

                            else:
                                check_rrmSliceAvgLowShare = False
                                logging.error(
                                    "rrmSliceAvgLowShare unexpected:sst[{}] {}, sst[{}] {}!".format(
                                        int(line[1][sst_value_index]),
                                        float(line[1][rrmSliceAvgLowShare_value_index]),
                                        int(next_line[1][sst_value_index]),
                                        float(next_line[1][rrmSliceAvgLowShare_value_index])
                                    )
                                )
                        else:
                            break
            if "dlDtxOptimData" in line[1][0]:
                check_dlDtxOptimData = True
        print("check_rrmSliceAvgLowShare:{},check_dlDtxOptimData:{}".format(
             check_rrmSliceAvgLowShare, check_dlDtxOptimData))

        return check_rrmSliceAvgLowShare and check_dlDtxOptimData

    def numberof_highestClassPriority17_in_dlPreSchedData(self, rnti=None):
        try:
            rnti = self.get_rnti() if rnti is None else rnti
            logging.info(
                "INDEX_dlPreSchedData_rnti:{} ".format(self.INDEX_dlPreSchedData_rnti)
            )
            dlPreSchedData_event = get_lines_with_multiple_column_filter(
                file_path=self.file_path,
                column_list=[
                    self.INDEX_event,
                    self.INDEX_dlPreSchedData_highestClassPriority,
                    self.INDEX_dlPreSchedData_rnti,
                ],
                expected_list=["dlPreSchedData", "18", rnti],
            )
            print(dlPreSchedData_event[0][1])
        except LookupError:
            # raise LookupError("No dlPreSchedData event found")
            logging.info(
                "No dlPreSchedData event found for which highestClassPriority=18 "
            )
            print("No dlPreSchedData event found for which highestClassPriority=18")
            return 0
        else:
            return len(dlPreSchedData_event)

    def CB009333_C_CA_and_9333_Enabled(self):
        """
            Author: Zhang xuewen
            check CA and 9333 enable
            check CA with dlFdSchedData column contain PCELL or SCELL
            check 9333 enable with dlDtxOptimData contain DTXPRBTHRES
        """
        try:
            event_data = self.get_32sfn_lines_with_multiple_column_filter(
                file_path=self.file_path,
                column_list=[
                    self.INDEX_event,
                ],
                expected_list=[
                    [
                        "dlPreSchedData",
                        "dlFdSchedData",
                        "dlDtxOptimData",
                    ],
                ],
            )
        except LookupError:
            logging.info(
                "PCELL or SCELL or DTXPRBTHRES not found"
            )
            print("PCELL or SCELL or DTXPRBTHRES not found ")
            return False

        return self.check_CAand9333_enable(event_data)

    def check_CAand9333_enable(self, event_data):
        """
            Author: Zhang xuewen
            Check include PCELL or SCELL and DTXPRBTHRES
            :return:
        """
        testResult = False
        event_column_list, last_col_num = self.reassign_event_column_number(
             "dlDtxOptimData"
        )
        column_index = event_column_list.index("dlDtxOptimEvent")
        dlDtxOptimEvent_value_index = last_col_num + column_index
        line_index = 0
        print("event_data:{}".format(len(event_data)))
        for line in event_data:
            if (
                "dlDtxOptimData" in line[1][0]
                and line[1][dlDtxOptimEvent_value_index] == "DTXPRBTHRES"
            ):
                testResult = True
                print(testResult)
                print(
                    "CB009333 is enabled"
                     )
                break
        event_column_list, last_col_num = self.reassign_event_column_number(
            "dlFdSchedData"
        )
        column_index = event_column_list.index("ueType")
        dlFdSchedData_ueType_value_index = last_col_num + column_index
        for line in event_data:
            if (
                "dlFdSchedData" in line[1][0]
                and line[1][dlFdSchedData_ueType_value_index] == "PCELL"
            ):
                print(
                    "CA is enabled"
                     )
                testResult = True
                break
            if (
                "dlFdSchedData" in line[1][0]
                and line[1][dlFdSchedData_ueType_value_index] == "SCELL"
            ):
                print(
                    "CA is enabled"
                     )
                testResult = True
                break
            else:
                testResult = False
        return testResult


def get_tti_analyzer(file_path):
    return CB009333_TTI_Analyzer(file_path)


# tti = get_tti_analyzer("/home/ute/xuewen/robotws/sample_ttitrace.dl.csv")
# tti.CB009333_E_SliceAwareScheduler()

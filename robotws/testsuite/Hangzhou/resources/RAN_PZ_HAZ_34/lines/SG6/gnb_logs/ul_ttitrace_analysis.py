# -*- coding: utf-8 -*

"""
Author:         stella.lin@nokia-sbell.com ; lei.jia@nokia-sbell.com
Description:    please note: Event trace log analysis, only used to analyse tti trace captured by gnb_logs.exe
"""
import logging
from collections import Counter
import csv
from taf.analyzer.ttitrace import *
from testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.python.check_csv_log import *

__all__ = [
    "calculate_ubler_and_ultput_for_ues",
    "check_ul_ue_paried_status_for_ues",
    "check_ulMuStatus_and_ulMuGroupStatus_ratio_for_ues",
    "verify_Ues_paired_status_with_varied_reqprb",
    "check_antPort_info_for_two_subcells",
    "check_subcell_is_same_for_retransmission_data",
    "check_rnti_subcell_mapping",
    "check_ue_unpaired_with_corrthd_not_reached",
    "check_retransmission_data_mustatus",
    # "check_pBoost_value_above_zero",
    "calculate_ul_non_dtx_and_ul_txnumber",
    "calculate_ul_ulmugroup_status",
]


PAIRED_SUCCESS_TABLE = [
    "MUPAIRED_TAPERING",
    "MUPAIRED_NO_TAPERING",
    "MUPAIRED_TAPERING_SIMPLERE",
    "MUPAIRED_NON_TAPERING_SIMPLERE",
]

UNPAIRED_TABLE = [
    "MUNONPAIRED_EMPTYDEDICATELIST",
    "MUNONPAIRED_BADCORR",
    "MUNONELIGIBLE_LOWSINR",
    "MUNONPAIRED_LOWSINGLEUESE",
    "MUNONPAIRED_LOWVIRTUALUESE",
    "MUNONPAIRED_OVERLOAD",
    "MUNONPAIRED_ENOUGHPRB",
    "MUNONELIGIBLE_LOWPRBREQ",
    "MUINVALID_STATUS",
    "MUNEEDLESS",
]

ANTPORT_MAPPING_TABLE = {
    "port0": "32768",
    "port1": "16384",
    "port2": "8192",
    "port3": "4096",
    "port01": "49152",  # port(0,1)
    "port23": "12288",  # port(2,3)
    "port0_1": ["32768", "16384"],  # port(0/1)
    "port2_3": ["8192", "4096"],  # port(2/3)
}

ULMUGROUPS_PAIRED_SUCCESS_TABLE = [
    "MUGROUPSPAIRED_TAPERING_ROOT",
    "MUGROUPSPAIRED_TAPERING_INGROUP",
]


class TTI_Trace_analysis(object):
    def __init__(self):
        self.parameter_dict = {}
        self.file_path = "ul_tti_trace.csv"

    def set_tti_trace_file_path(self, file_path):
        self.file_path = file_path

    def get_column_header(self, delimiter=","):
        """
        author: jialei
        :param file_path: String: csv log file path.
        :param delimiter: String: the spliter to split values into cells.
        :return: The value matrix
        """
        with open(self.file_path) as csvfile:
            column_header_dict = {}
            reader = csv.reader(csvfile, delimiter=str(delimiter))
            header_row = next(reader)
            for index, column_header in enumerate(header_row):
                column_index = int(index) + 1
                column_header_dict[column_header] = column_index
        return column_header_dict

    def get_columns(self, reader_list, filter, column_name):
        """
        author: jialei
        :param reader_list:
        :param filter:
        :param column_name:
        :return:
        """
        column_header_dict = self.get_column_header()
        for low in reader_list:
            if len(low) != 0:
                if low[0] == filter:
                    column_index = column_header_dict[column_name]
                    return column_index

    def get_unique_column_values_and_count(self, matrix, column_number):
        """
        author: jialei
        :param matrix:
        :param column_number:
        :return:
        """
        column = self.get_column_values_from_matrix(matrix, column_number)
        result = list(set(column))
        result_count = Counter(column)
        return result, result_count

    def get_column_values_from_matrix(self, matrix, column_number):
        """
        author: jialei
        :param matrix:
        :param column_number:
        :return:
        """
        column = int(column_number) - 1
        column_list = []
        for row in matrix:
            if len(row[1]) < column:
                continue
            column_list.append(row[1][column])
        return column_list

    def find_item_indices_in_a_list(self, item, item_list):
        """
        author: Stella
        :param item:
        :param item_list:
        :return:
        """
        item_indices = []
        for index in range(len(item_list)):
            if item_list[index] == item:
                item_indices.append(index)
        return item_indices

    def get_ul_parameters_column(self):
        """
        author: Stella
        :return:
        """
        with open(self.file_path, "r") as csv_file:
            reader = list(csv.reader(csv_file))
        self.parameter_dict["INDEX_ulFdSchedData"] = self.get_columns(
            reader_list=reader,
            filter="ulFdSchedData",
            column_name="type",
        )
        self.parameter_dict["INDEX_ulFdSchedData_rnti"] = self.get_columns(
            reader_list=reader,
            filter="ulFdSchedData",
            column_name="rnti",
        )
        self.parameter_dict["INDEX_ulFdSchedData_slot"] = self.get_columns(
            reader_list=reader,
            filter="ulFdSchedData",
            column_name="slot",
        )
        self.parameter_dict["INDEX_ulFdSchedData_SFN"] = self.get_columns(
            reader_list=reader,
            filter="ulFdSchedData",
            column_name="sfn",
        )
        self.parameter_dict["INDEX_ulFdSchedData_physCellId"] = self.get_columns(
            reader_list=reader,
            filter="ulFdSchedData",
            column_name="physCellId",
        )
        self.parameter_dict["INDEX_ulFdSchedData_txNumber"] = self.get_columns(
            reader_list=reader,
            filter="ulFdSchedData",
            column_name="txNumber",
        )
        self.parameter_dict["INDEX_ulFdSchedData_tbsize"] = self.get_columns(
            reader_list=reader,
            filter="ulFdSchedData",
            column_name="tbSize",
        )
        self.parameter_dict["INDEX_ulFdSchedData_antPort"] = self.get_columns(
            reader_list=reader,
            filter="ulFdSchedData",
            column_name="antPort",
        )
        self.parameter_dict["INDEX_ulFdSchedData_subcellId"] = self.get_columns(
            reader_list=reader,
            filter="ulFdSchedData",
            column_name="subcellId",
        )
        self.parameter_dict[
            "INDEX_ulFdSchedData_ulHarqProcessIndex"
        ] = self.get_columns(
            reader_list=reader,
            filter="ulFdSchedData",
            column_name="ulHarqProcessIndex",
        )
        self.parameter_dict["INDEX_ulHarqRxData_rnti"] = self.get_columns(
            reader_list=reader,
            filter="ulHarqRxData",
            column_name="rnti",
        )
        self.parameter_dict["INDEX_ulHarqRxData_SFN"] = self.get_columns(
            reader_list=reader,
            filter="ulHarqRxData",
            column_name="sfn",
        )
        self.parameter_dict["INDEX_ulHarqRxData_dtx"] = self.get_columns(
            reader_list=reader,
            filter="ulHarqRxData",
            column_name="dtx",
        )
        self.parameter_dict["INDEX_ulHarqRxData_crcResult"] = self.get_columns(
            reader_list=reader,
            filter="ulHarqRxData",
            column_name="crcResult",
        )
        self.parameter_dict["INDEX_ulHarqRxData_ulHarqProcessIndex"] = self.get_columns(
            reader_list=reader,
            filter="ulHarqRxData",
            column_name="ulHarqProcessIndex",
        )
        self.parameter_dict["INDEX_ulFdSchedData_ulMuStatus"] = self.get_columns(
            reader_list=reader,
            filter="ulFdSchedData",
            column_name="ulMuStatus",
        )
        self.parameter_dict["INDEX_ulFdSchedData_ulMuGroupStatus"] = self.get_columns(
            reader_list=reader,
            filter="ulFdSchedData",
            column_name="ulMuGroupStatus",
        )
        self.parameter_dict["INDEX_ulFdSchedData_virtualUeIndex"] = self.get_columns(
            reader_list=reader,
            filter="ulFdSchedData",
            column_name="virtualUeIndex",
        )
        self.parameter_dict["INDEX_ulFdSchedData_pairedUeRnti"] = self.get_columns(
            reader_list=reader,
            filter="ulFdSchedData",
            column_name="pairedUeRnti",
        )
        self.parameter_dict["INDEX_ulFdSchedData_startPrb"] = self.get_columns(
            reader_list=reader,
            filter="ulFdSchedData",
            column_name="startPrb",
        )
        self.parameter_dict["INDEX_ulFdSchedData_numOfPrb"] = self.get_columns(
            reader_list=reader,
            filter="ulFdSchedData",
            column_name="numOfPrb",
        )
        self.parameter_dict["INDEX_ulFdSchedData_requiredPrb"] = self.get_columns(
            reader_list=reader,
            filter="ulFdSchedData",
            column_name="requiredPrb",
        )
        self.parameter_dict["INDEX_ulPuschReceiveRespPsData_ulRank"] = self.get_columns(
            reader_list=reader,
            filter="ulPuschReceiveRespPsData",
            column_name="ulRank",
        )
        # self.parameter_dict["INDEX_ulFdSchedData_pBoost"] = self.get_columns(
        #     reader_list=reader,
        #     filter="ulFdSchedData",
        #     column_name="pBoost",
        # )

    def get_ul_basic_parameters_column(self):
        """
        author: Stella
        :return:
        """
        with open(self.file_path, "r") as csv_file:
            reader = list(csv.reader(csv_file))
        self.parameter_dict["INDEX_ulFdSchedData"] = self.get_columns(
            reader_list=reader,
            filter="ulFdSchedData",
            column_name="type",
        )
        self.parameter_dict["INDEX_ulFdSchedData_rnti"] = self.get_columns(
            reader_list=reader,
            filter="ulFdSchedData",
            column_name="rnti",
        )
        self.parameter_dict["INDEX_ulFdSchedData_physCellId"] = self.get_columns(
            reader_list=reader,
            filter="ulFdSchedData",
            column_name="physCellId",
        )
        self.parameter_dict["INDEX_ulFdSchedData_txNumber"] = self.get_columns(
            reader_list=reader,
            filter="ulFdSchedData",
            column_name="txNumber",
        )
        self.parameter_dict[
            "INDEX_ulFdSchedData_ulHarqProcessIndex"
        ] = self.get_columns(
            reader_list=reader,
            filter="ulFdSchedData",
            column_name="ulHarqProcessIndex",
        )
        self.parameter_dict["INDEX_ulHarqRxData_rnti"] = self.get_columns(
            reader_list=reader,
            filter="ulHarqRxData",
            column_name="rnti",
        )
        self.parameter_dict["INDEX_ulHarqRxData_dtx"] = self.get_columns(
            reader_list=reader,
            filter="ulHarqRxData",
            column_name="dtx",
        )
        self.parameter_dict["INDEX_ulHarqRxData_ulHarqProcessIndex"] = self.get_columns(
            reader_list=reader,
            filter="ulHarqRxData",
            column_name="ulHarqProcessIndex",
        )

    def get_ulMuUeData_params_only(self):
        """
        author: Stella
        :return:
        """
        with open(self.file_path, "r") as csv_file:
            reader = list(csv.reader(csv_file))
        self.parameter_dict["INDEX_ulMuUeData_otherUesCorrSum"] = self.get_columns(
            reader_list=reader,
            filter="ulMuUeData",
            column_name="otherUesCorrSum",
        )
        self.parameter_dict["INDEX_ulMuUeData_status"] = self.get_columns(
            reader_list=reader,
            filter="ulMuUeData",
            column_name="status",
        )

    def get_specific_event(self, event_name):
        """
        author: Stella
        :param event_name:
        :return:
        """
        return get_lines_with_multiple_column_filter(
            file_path=self.file_path, column_list=[1], expected_list=[event_name]
        )

    def get_event_by_filter_rnti(self, event_matrix, rnti):
        """
        author: Stella
        :param event_matrix:
        :param rnti:
        :return:
        """
        return add_filters_to_matrix(
            event_matrix,
            [self.parameter_dict["INDEX_ulFdSchedData_rnti"], [rnti]],
        )

    def get_ul_fdSchedData_event(self):
        """
        author: Stella
        :return:
        """
        event_res = self.get_specific_event(event_name="ulFdSchedData")
        return add_filters_to_matrix(
            event_res, [self.parameter_dict["INDEX_ulFdSchedData"], ["ulFdSchedData"]]
        )

    # def get_ulHarqRxData_with_Non_DTX(self):
    #     event_res = self.get_specific_event(event_name="ulHarqRxData")
    #     return add_filters_to_matrix(
    #         event_res, [self.parameter_dict["INDEX_ulHarqRxData_dtx"], ["NON_DTX"]]
    #     )

    def get_ulHarqRxData_event(self):
        """
        author: Stella
        :return:
        """
        return self.get_specific_event(event_name="ulHarqRxData")

    def get_ulPuschReceiveRespPsData_event(self):
        """
        author: Stella
        :return:
        """
        return self.get_specific_event(event_name="ulPuschReceiveRespPsData")

    def get_ulMuUeData_event(self):
        """
        author: Stella
        :return:
        """
        return self.get_specific_event(event_name="ulMuUeData")

    def get_ulPuschReceiveRespPsData_event_by_rnti(self, event_matrix, rnti):
        """
        author: Stella
        :param event_matrix:
        :param rnti:
        :return:
        """
        return self.get_event_by_filter_rnti(event_matrix=event_matrix, rnti=rnti)

    def get_ul_fdSchedData_event_by_rnti(self, event_matrix, rnti):
        """
        author: Stella
        :param event_matrix:
        :param rnti:
        :return:
        """
        return self.get_event_by_filter_rnti(event_matrix=event_matrix, rnti=rnti)

    def get_ul_ulHarqRxData_event_by_rnti(self, event_matrix, rnti):
        """
        author: Stella
        :param event_matrix:
        :param rnti:
        :return:
        """
        return self.get_event_by_filter_rnti(event_matrix=event_matrix, rnti=rnti)

    def get_ul_fdSchedData_event_by_txNumber(self, event_matrix, txNumber):
        """
        author: Stella
        :param event_matrix:
        :param txNumber:
        :return:
        """
        txNumber = str(txNumber)
        logging.debug("ul tx_number is {}".format(txNumber))
        return add_filters_to_matrix(
            event_matrix,
            [self.parameter_dict["INDEX_ulFdSchedData_txNumber"], [txNumber]],
        )

    def get_ulMuStatus_values(self, event_matrix):
        """
        author: Stella
        :param event_matrix:
        :return:
        """
        return self.get_unique_column_values_and_count(
            matrix=event_matrix,
            column_number=self.parameter_dict["INDEX_ulFdSchedData_ulMuStatus"],
        )

    def get_ulMuGroupStatus_values(self, event_matrix):
        """
        author: Stella
        :param event_matrix:
        :return:
        """
        return self.get_unique_column_values_and_count(
            matrix=event_matrix,
            column_number=self.parameter_dict["INDEX_ulFdSchedData_ulMuGroupStatus"],
        )

    def get_requiredPrb_values(self, event_matrix):
        """
        author: Stella
        :param event_matrix:
        :return:
        """
        return self.get_unique_column_values_and_count(
            matrix=event_matrix,
            column_number=self.parameter_dict["INDEX_ulFdSchedData_requiredPrb"],
        )

    def get_pairedUeRnti_values(self, event_matrix):
        """
        author: Stella
        :param event_matrix:
        :return:
        """
        return self.get_unique_column_values_and_count(
            matrix=event_matrix,
            column_number=self.parameter_dict["INDEX_ulFdSchedData_pairedUeRnti"],
        )

    def get_pairedUeRnti_values(self, event_matrix):
        """
        author: Stella
        :param event_matrix:
        :return:
        """
        return self.get_unique_column_values_and_count(
            matrix=event_matrix,
            column_number=self.parameter_dict["INDEX_ulFdSchedData_pairedUeRnti"],
        )

    def get_rnti_values(self, event_matrix):
        """
        author: Stella
        :param event_matrix:
        :return:
        """
        return self.get_unique_column_values_and_count(
            matrix=event_matrix,
            column_number=self.parameter_dict["INDEX_ulFdSchedData_rnti"],
        )

    def get_slot_values(self, event_matrix):
        """
        author: Stella
        :param event_matrix:
        :return:
        """
        return self.get_unique_column_values_and_count(
            matrix=event_matrix,
            column_number=self.parameter_dict["INDEX_ulFdSchedData_slot"],
        )

    def get_slot_value_list(self, event_matrix):
        """
        author: Stella
        :param event_matrix:
        :return:
        """
        return self.get_column_values_from_matrix(
            matrix=event_matrix,
            column_number=self.parameter_dict["INDEX_ulFdSchedData_slot"],
        )

    def get_sfn_value_list(self, event_matrix, event_name="ulFdSchedData"):
        """
        author: Stella
        :param event_matrix:
        :return:
        """
        return self.get_column_values_from_matrix(
            matrix=event_matrix,
            column_number=self.parameter_dict["INDEX_{}_SFN".format(event_name)],
        )

    def get_tbsize_value_list(self, event_matrix):
        """
        author: Stella
        :param event_matrix:
        :return:
        """
        return self.get_column_values_from_matrix(
            matrix=event_matrix,
            column_number=self.parameter_dict["INDEX_ulFdSchedData_tbsize"],
        )

    def get_antPort_value_list(self, event_matrix):
        """
        author: Stella
        :param event_matrix:
        :return:
        """
        return self.get_column_values_from_matrix(
            matrix=event_matrix,
            column_number=self.parameter_dict["INDEX_ulFdSchedData_antPort"],
        )

    def get_subcellId_value_list(self, event_matrix):
        """
        author: Stella
        :param event_matrix:
        :return:
        """
        return self.get_column_values_from_matrix(
            matrix=event_matrix,
            column_number=self.parameter_dict["INDEX_ulFdSchedData_subcellId"],
        )

    def get_ulRank_value_list(self, event_matrix):
        """
        author: Stella
        :param event_matrix:
        :return:
        """
        return self.get_column_values_from_matrix(
            matrix=event_matrix,
            column_number=self.parameter_dict["INDEX_ulPuschReceiveRespPsData_ulRank"],
        )

    # def get_pBoost_value_list(self, event_matrix):
    #     return self.get_unique_column_values_and_count(
    #         matrix=event_matrix,
    #         column_number=self.parameter_dict["INDEX_ulFdSchedData_pBoost"],
    #     )

    def get_diff_sfn_indices_between_two_events(
        self,
        event_matrix1,
        event_matrix2,
        event_name1="ulFdSchedData",
        event_name2="ulHarqRxData",
    ):
        origin_sfn_index_list_event1 = self.get_sfn_value_list(
            event_matrix=event_matrix1, event_name=event_name1
        )
        origin_sfn_index_list_event2 = self.get_sfn_value_list(
            event_matrix=event_matrix2, event_name=event_name2
        )
        origin_sfn_event1_dict = dict(Counter(origin_sfn_index_list_event1))
        origin_sfn_event2_dict = dict(Counter(origin_sfn_index_list_event2))
        sfn_diff_all = list(
            origin_sfn_event1_dict.items() - origin_sfn_event2_dict.items()
        )
        logging.debug("sfn diff all is {} ".format(sfn_diff_all))
        diff_sfn_list = [x[0] for x in sfn_diff_all]
        logging.debug("diff sfn list is {} ".format(diff_sfn_list))
        diff_sfn_indices_event1 = [
            index
            for (index, item) in enumerate(origin_sfn_index_list_event1)
            if item in diff_sfn_list
        ]
        diff_sfn_indices_event2 = [
            index
            for (index, item) in enumerate(origin_sfn_index_list_event2)
            if item in diff_sfn_list
        ]
        logging.debug(
            "diff sfn indices for {} is {}, diff sfn indices for {} is {}".format(
                event_name1,
                diff_sfn_indices_event1,
                event_name2,
                diff_sfn_indices_event2,
            )
        )
        return diff_sfn_indices_event1, diff_sfn_indices_event2

    def removelistDepulicates(self, nums):
        """
        author: lei.jia
        :param
        :return: sfn list after remove depulicates, for exmaple [114, 115...1023, 0, 1, 2,...330].
        """
        slow = 1
        fast = 1
        while fast < len(nums):
            if nums[fast] != nums[fast - 1]:
                nums[slow] = nums[fast]
                slow += 1
            fast += 1
        return nums[:slow]

    def calculate_ul_tput_and_ul_bler_for_ues(
        self, is_bler_cal=True, txNumer_2="2.0", txNumer_1="1.0"
    ):
        """
        author: Stella
        :param is_bler_cal:
        :return:
        """
        ues_tput_bler_dict = {}
        fdSchedData_event = self.get_ul_fdSchedData_event()
        fdSchedData_event_with_txNumber = self.get_ul_fdSchedData_event_by_txNumber(
            event_matrix=fdSchedData_event, txNumber=txNumer_1
        )
        rnti_values, rnti_count = self.get_rnti_values(
            event_matrix=fdSchedData_event_with_txNumber
        )
        for rnti in rnti_values:
            logging.debug(
                "------ Start to calculate ul tput for ue rnti-{} ------".format(rnti)
            )
            tput_bler_info_dict = {}
            fdSchedData_event_with_rnti = self.get_ul_fdSchedData_event_by_rnti(
                event_matrix=fdSchedData_event_with_txNumber, rnti=rnti
            )
            tbsize_values_list = self.get_tbsize_value_list(
                event_matrix=fdSchedData_event_with_rnti
            )
            sfn_values_list = self.get_sfn_value_list(
                event_matrix=fdSchedData_event_with_rnti
            )
            fdSchedData_event_with_txNumber = self.get_ul_fdSchedData_event_by_txNumber(
                event_matrix=fdSchedData_event, txNumber=txNumer_1
            )
            slot_values, slot_count = self.get_slot_values(
                event_matrix=fdSchedData_event_with_rnti
            )
            sfn_list_removeDepulicates = self.removelistDepulicates(sfn_values_list)
            logging.debug("all ul sfn are {}".format(sfn_list_removeDepulicates))
            # calculate total tbsize within one second, only txnumber=1
            # 1 second equals to 100 subframes
            logging.debug("all ul slot are {}".format(slot_values))
            duration = len(sfn_list_removeDepulicates) / 100
            tbsize_total = sum([int(float(x)) for x in tbsize_values_list])
            average_tput = float(tbsize_total) / (duration * 1000 * 1000)
            logging.debug(
                "average tput for rnti-{} is {}, tput duration is {}".format(
                    rnti, average_tput, duration
                )
            )
            tput_bler_info_dict["tput"] = average_tput
            tput_bler_info_dict["duration"] = duration
            tput_bler_info_dict["bler"] = None
            if is_bler_cal:
                logging.debug(
                    "------ Start to calculate ul bler for ue rnti-{} ------".format(
                        rnti
                    )
                )
                ulHarqRxData_event = self.get_ulHarqRxData_event()
                fdSchedData_event_by_rnti_only = self.get_ul_fdSchedData_event_by_rnti(
                    event_matrix=fdSchedData_event, rnti=rnti
                )
                ulHarqRxData_event_with_rnti = self.get_ul_ulHarqRxData_event_by_rnti(
                    event_matrix=ulHarqRxData_event, rnti=rnti
                )
                ul_bler, ul_ibler = self.calculate_ul_bler_for_single_ue(
                    fdSchedData_event=fdSchedData_event_by_rnti_only,
                    ulHarqRxData_event=ulHarqRxData_event_with_rnti,
                    txNumer_2=txNumer_2,
                    txNumer_1=txNumer_1,
                )
                tput_bler_info_dict["bler"] = ul_bler
                tput_bler_info_dict["ibler"] = ul_ibler
            ues_tput_bler_dict[rnti] = tput_bler_info_dict
        logging.debug(
            "------ Calculate ul tput and ul bler Done! result is {} ------".format(
                ues_tput_bler_dict
            )
        )
        return ues_tput_bler_dict

    def calculate_ul_bler_for_single_ue(
        self, fdSchedData_event, ulHarqRxData_event, txNumer_2="2.0", txNumer_1="1.0"
    ):
        """
        author: Stella
        :param fdSchedData_event:
        :param ulHarqRxData_event:
        :return:
        """
        txnumber = self.get_column_values_from_matrix(
            matrix=fdSchedData_event,
            column_number=self.parameter_dict["INDEX_ulFdSchedData_txNumber"],
        )
        ulHarqRxData_crcResult = self.get_column_values_from_matrix(
            matrix=ulHarqRxData_event,
            column_number=self.parameter_dict["INDEX_ulHarqRxData_crcResult"],
        )
        logging.debug("origin txnumber length is {}".format(len(txnumber)))
        logging.debug("origin dtx lenth is {}".format(len(ulHarqRxData_crcResult)))
        # ul bler: type=ulHarqRxData：crcResult NOK samples/crcResult NOK+OK samples
        # ul ibler: type=ulFdSchedData：txNumber=2 samples/txNumber=1 samples
        txnumber_value_count = Counter(txnumber)
        ulHarqRxData_crcResult_value_count = Counter(ulHarqRxData_crcResult)
        logging.debug("txnumber_value_count is{}".format(txnumber_value_count))
        bler = 1
        try:
            ibler = txnumber_value_count[txNumer_2] / (txnumber_value_count[txNumer_1])
            logging.debug("ul ibler is {}".format(ibler))
            bler = ulHarqRxData_crcResult_value_count["NOK"] / (
                ulHarqRxData_crcResult_value_count["NOK"]
                + ulHarqRxData_crcResult_value_count["OK"]
            )
            logging.debug("ul bler is {}".format(bler))
        except Exception as e:
            logging.debug("error {} found on bler compute")
        return bler, ibler

    def get_ulMuStatus_info_for_ues(self):
        """
        author: Stella
        :return:
        """
        ues_ulMuStatus_dict = {}
        fdSchedData_event = self.get_ul_fdSchedData_event()
        fdSchedData_event_with_txNumber = self.get_ul_fdSchedData_event_by_txNumber(
            event_matrix=fdSchedData_event, txNumber=1.0
        )
        rnti_values, rnti_count = self.get_rnti_values(
            event_matrix=fdSchedData_event_with_txNumber
        )
        # rnti_values, rnti_count = self.get_rnti_values(event_matrix=fdSchedData_event)
        for rnti in rnti_values:
            ue_ulMuStatus_dict = {}
            fdSchedData_event_with_rnti = self.get_ul_fdSchedData_event_by_rnti(
                event_matrix=fdSchedData_event, rnti=rnti
            )
            ulMuStatus_values, ulMuStatus_count = self.get_ulMuStatus_values(
                event_matrix=fdSchedData_event_with_rnti
            )
            (
                ulMuGroupStatus_values,
                ulMuGroupStatus_count,
            ) = self.get_ulMuGroupStatus_values(
                event_matrix=fdSchedData_event_with_rnti
            )
            ue_ulMuStatus_dict["ulMuStatus_values"] = ulMuStatus_values
            ue_ulMuStatus_dict["ulMuStatus_count"] = ulMuStatus_count
            ue_ulMuStatus_dict["ulMuGroupStatus_values"] = ulMuGroupStatus_values
            ue_ulMuStatus_dict["ulMuGroupStatus_count"] = ulMuGroupStatus_count
            ues_ulMuStatus_dict[rnti] = ue_ulMuStatus_dict
        logging.debug("ulMuStatus for all ues is {}".format(ues_ulMuStatus_dict))
        return ues_ulMuStatus_dict

    def get_all_ues_ulMuStatus_info(self):
        """
        author: lei.jia
        :return:
        """
        ues_ulMuStatus_dict = {}
        fdSchedData_event = self.get_ul_fdSchedData_event()
        ulMuStatus_values, ulMuStatus_count = self.get_ulMuStatus_values(
            event_matrix=fdSchedData_event
        )
        ulMuGroupStatus_values, ulMuGroupStatus_count = self.get_ulMuGroupStatus_values(
            event_matrix=fdSchedData_event
        )
        ues_ulMuStatus_dict["ulMuStatus_values"] = ulMuStatus_values
        ues_ulMuStatus_dict["ulMuStatus_count"] = ulMuStatus_count
        ues_ulMuStatus_dict["ulMuGroupStatus_values"] = ulMuGroupStatus_values
        ues_ulMuStatus_dict["ulMuGroupStatus_count"] = ulMuGroupStatus_count
        logging.debug("ulMuStatus for all ues is {}".format(ues_ulMuStatus_dict))
        return ues_ulMuStatus_dict

    def get_all_ues_related_info(self):
        """
        author: Stella
        :return:
        """
        ues_info_dict = {}
        fdSchedData_event = self.get_ul_fdSchedData_event()
        ulPuschReceiveRespPsData_event = self.get_ulPuschReceiveRespPsData_event()
        rnti_values, rnti_count = self.get_rnti_values(event_matrix=fdSchedData_event)
        for rnti in rnti_values:
            ue_info_dict = {}
            fdSchedData_event_with_rnti = self.get_ul_fdSchedData_event_by_rnti(
                event_matrix=fdSchedData_event, rnti=rnti
            )
            ulPuschReceiveRespPsData_event_with_rnti = (
                self.get_ulPuschReceiveRespPsData_event_by_rnti(
                    event_matrix=ulPuschReceiveRespPsData_event, rnti=rnti
                )
            )
            antPort, count = self.get_unique_column_values_and_count(
                matrix=fdSchedData_event_with_rnti,
                column_number=self.parameter_dict["INDEX_ulFdSchedData_antPort"],
            )
            subcellId, count = self.get_unique_column_values_and_count(
                matrix=fdSchedData_event_with_rnti,
                column_number=self.parameter_dict["INDEX_ulFdSchedData_subcellId"],
            )
            ulRank, count = self.get_unique_column_values_and_count(
                matrix=ulPuschReceiveRespPsData_event_with_rnti,
                column_number=self.parameter_dict[
                    "INDEX_ulPuschReceiveRespPsData_ulRank"
                ],
            )
            ue_info_dict["antPort"] = antPort[0]
            ue_info_dict["subcellId"] = subcellId[0]
            ue_info_dict["ulRank"] = ulRank[0]
            ues_info_dict[rnti] = ue_info_dict
        logging.debug("all ue info is {}".format(ues_info_dict))
        return ues_info_dict

    def check_antPort_info_for_subcells(
        self,
        subcell0_id=None,
        subcell1_id=None,
        expect_subcell0_port=None,
        expect_subcell1_port=None,
    ):
        """
        author: Stella
        :return:
        """
        fdSchedData_event = self.get_ul_fdSchedData_event()
        antPort = self.get_antPort_value_list(event_matrix=fdSchedData_event)
        subcells = self.get_subcellId_value_list(event_matrix=fdSchedData_event)
        if subcell0_id is not None:
            subcell0 = [
                index for (index, item) in enumerate(subcells) if item == subcell0_id
            ]
        if subcell1_id is not None:
            subcell1 = [
                index for (index, item) in enumerate(subcells) if item == subcell1_id
            ]
        antPort_value_on_subcell0 = [
            item for (index, item) in enumerate(antPort) if index in subcell0
        ]
        antPort_value_on_subcell1 = [
            item for (index, item) in enumerate(antPort) if index in subcell1
        ]
        if expect_subcell0_port is not None:
            subcell0_port_number = ANTPORT_MAPPING_TABLE[expect_subcell0_port]
            if not isinstance(subcell0_port_number, list):
                subcell0_port_number = [subcell0_port_number]
            assert set(antPort_value_on_subcell0) == set(
                subcell0_port_number
            ), "antport is not {} for sucell0, actual is {}".format(
                subcell0_port_number,
                set(antPort_value_on_subcell0),
            )
        if expect_subcell1_port is not None:
            subcell1_port_number = ANTPORT_MAPPING_TABLE[expect_subcell1_port]
            if not isinstance(subcell1_port_number, list):
                subcell1_port_number = [subcell1_port_number]
            assert set(antPort_value_on_subcell1) == set(
                subcell1_port_number
            ), "antport is not {} for sucell1, actual is {}".format(
                subcell1_port_number,
                set(antPort_value_on_subcell1),
            )

    # def check_virtualUe_for_4ues_per_slot(self, expect_virtualue_number=2):
    #     fdSchedData_event = self.get_ul_fdSchedData_event()
    #     fdSchedData_event_with_txNumber = self.get_ul_fdSchedData_event_by_txNumber(
    #         event_matrix=fdSchedData_event, txNumber=1
    #     )
    #     slot = self.get_column_values_from_matrix(
    #         matrix=fdSchedData_event_with_txNumber,
    #         column_number=self.parameter_dict["INDEX_ulFdSchedData_slot"],
    #     )
    #     virtualUeIndex = self.get_column_values_from_matrix(
    #         matrix=fdSchedData_event_with_txNumber,
    #         column_number=self.parameter_dict["INDEX_ulFdSchedData_virtualUeIndex"],
    #     )
    #     slot_index = [
    #         index
    #         for (index, item) in enumerate(slot[:-3])
    #         if slot[index] == slot[index + 1] == slot[index + 2] == slot[index + 3]
    #     ]
    #     for index in slot_index:
    #         virtualUe_list = virtualUeIndex[index: index + 4]
    #         assert len(set(virtualUe_list)) == int(
    #             expect_virtualue_number
    #         ), "virtualue for slot-{} is {},length is not {}".format(
    #             slot[index], virtualUe_list, expect_virtualue_number
    #         )

    def check_ul_ue_paried_or_not_paired_status(
        self,
        paired_status="paired",
        is_ulmustatus_need_to_check=False,
        ulmustatus="MUPAIRED_NO_TAPERING",
        percent_exp=0.98,
        is_ulmugroup_status_need_to_check=False,
        group_paird_percent_exp=0.1,
    ):
        """
        author: Stella
        :param paired_status:
        :param is_ulmustatus_need_to_check:
        :param ulmustatus:
        :param percent_exp:
        :return:
        """
        ues_ulMuStatus_dict = self.get_ulMuStatus_info_for_ues()
        for rnti, ulMuStatus_info in ues_ulMuStatus_dict.items():
            logging.debug(
                "------ Start to calculate {} status for ue rnti-{} ------".format(
                    paired_status, rnti
                )
            )
            status_percent = 0
            try:
                if is_ulmustatus_need_to_check:
                    status_count = ulMuStatus_info["ulMuStatus_count"][ulmustatus]
                    ulmustatus_exp = ulmustatus
                else:
                    status_count = 0
                    if paired_status == "paired":
                        ulmustatus_exp = PAIRED_SUCCESS_TABLE
                    else:
                        ulmustatus_exp = UNPAIRED_TABLE
                    for status in ulmustatus_exp:
                        try:
                            status_count = (
                                status_count
                                + ulMuStatus_info["ulMuStatus_count"][status]
                            )
                        except Exception as e:
                            logging.debug("error {} found when get status_count")
                status_percent = status_count / sum(
                    ulMuStatus_info["ulMuStatus_count"].values()
                )
                logging.debug(
                    "{} with status {} percent is {}".format(
                        paired_status, ulmustatus_exp, status_percent
                    )
                )
            except Exception as e:
                logging.debug("error {} found on percent compute")
            logging.debug("start to check ue ulmustatus status")
            if is_ulmustatus_need_to_check:
                assert (
                    ulmustatus in ulMuStatus_info["ulMuStatus_values"]
                ), "UE rnti {} is not {} with status {}".format(
                    rnti, paired_status, ulmustatus
                )
            assert (
                status_percent >= percent_exp
            ), "UE rnti {} is not always {} with status {} , actual percent is {}".format(
                rnti, paired_status, ulmustatus_exp, status_percent
            )
            if is_ulmugroup_status_need_to_check:
                group_status_count = 0
                for status in ULMUGROUPS_PAIRED_SUCCESS_TABLE:
                    try:
                        group_status_count = (
                            group_status_count
                            + ulMuStatus_info["ulMuGroupStatus_count"][status]
                        )
                    except Exception as e:
                        logging.debug("error {} found when get group status count")
                group_status_percent = group_status_count / sum(
                    ulMuStatus_info["ulMuGroupStatus_count"].values()
                )
                logging.debug(
                    "paired ulMuGroupStatus {} percent is {}".format(
                        ULMUGROUPS_PAIRED_SUCCESS_TABLE, group_status_percent
                    )
                )
                assert (
                    group_status_percent >= group_paird_percent_exp
                ), "UE rnti {} is ulMuGroupStatus paired percent is {},actual is {}".format(
                    rnti, group_status_percent, group_paird_percent_exp
                )

    def check_ulMuStatus_and_ulMuGroupStatus_ratio(
        self,
        paired_status="paired",
        is_ulmustatus_need_to_check=True,
        percent_exp=0.11,
        is_ulmugroup_status_need_to_check=True,
        group_paird_percent_exp=0,
    ):
        """
        author: lei.jia
        :param paired_status:
        :param is_ulmustatus_need_to_check:
        :param percent_exp:
        :return:
        """
        ulMuStatus_info = self.get_all_ues_ulMuStatus_info()
        try:
            status_count = 0
            if paired_status == "paired":
                ulmustatus_exp = PAIRED_SUCCESS_TABLE
            else:
                ulmustatus_exp = UNPAIRED_TABLE
            for status in ulmustatus_exp:
                try:
                    status_count = (
                        status_count + ulMuStatus_info["ulMuStatus_count"][status]
                    )
                except Exception as e:
                    logging.debug("error {} found when get status_count")
            status_percent = status_count / sum(
                ulMuStatus_info["ulMuStatus_count"].values()
            )
            logging.debug(
                "{} with status {} percent is {}".format(
                    paired_status, ulmustatus_exp, status_percent
                )
            )
        except Exception as e:
            logging.debug("error {} found on percent compute")
            logging.debug("start to check ue ulmustatus status")
        if is_ulmustatus_need_to_check:
            assert (
                status_percent >= percent_exp
            ), "UE is not always {} with status {} , actual percent is {}".format(
                paired_status, ulmustatus_exp, status_percent
            )
        if is_ulmugroup_status_need_to_check:
            group_status_count = 0
            for status in ULMUGROUPS_PAIRED_SUCCESS_TABLE:
                try:
                    group_status_count = (
                        group_status_count
                        + ulMuStatus_info["ulMuGroupStatus_count"][status]
                    )
                except Exception as e:
                    logging.debug("error {} found when get group status count")
            group_status_percent = group_status_count / sum(
                ulMuStatus_info["ulMuGroupStatus_count"].values()
            )
            logging.debug(
                "paired ulMuGroupStatus {} percent is {}".format(
                    ULMUGROUPS_PAIRED_SUCCESS_TABLE, group_status_percent
                )
            )
            assert (
                group_status_percent >= group_paird_percent_exp
            ), "UE is ulMuGroupStatus paired percent is {},actual is {}".format(
                group_status_percent, group_paird_percent_exp
            )

    def verify_Ues_paired_status_with_varied_prb(
        self, ulMuMimoPrbThresholdAbsolute=30, ulMinPrbThreshold=100
    ):
        """
        author: Stella
        :param ulMuMimoPrbThresholdAbsolute:
        :param ulMinPrbThreshold:
        :return:
        """
        rnti_req_prb_count_dict = {}
        rnti_req_prb_dict = {}
        rnti_ul_fdSchedData = {}
        fdSchedData_event = self.get_ul_fdSchedData_event()
        fdSchedData_event_with_txNumber = self.get_ul_fdSchedData_event_by_txNumber(
            event_matrix=fdSchedData_event, txNumber=1.0
        )
        rnti_values, rnti_count = self.get_rnti_values(
            event_matrix=fdSchedData_event_with_txNumber
        )
        for rnti in rnti_values:
            fdSchedData_event_with_rnti = self.get_ul_fdSchedData_event_by_rnti(
                event_matrix=fdSchedData_event_with_txNumber, rnti=rnti
            )
            req_prb, req_prb_count = self.get_requiredPrb_values(
                event_matrix=fdSchedData_event_with_rnti
            )
            rnti_req_prb_count_dict[rnti] = len(req_prb_count.values())
            rnti_req_prb_dict[rnti] = req_prb
            rnti_ul_fdSchedData[rnti] = fdSchedData_event_with_rnti
        root_ue_rnti = (
            min(zip(rnti_req_prb_count_dict.values(), rnti_req_prb_count_dict.keys()))
        )[1]
        logging.debug("root ue rnti is {}".format(root_ue_rnti))
        candidate_ue_rnti = (
            max(zip(rnti_req_prb_count_dict.values(), rnti_req_prb_count_dict.keys()))
        )[1]
        logging.debug("candidate ue rnti is {}".format(candidate_ue_rnti))
        candidate_ue_max_prb = int(max(rnti_req_prb_dict[root_ue_rnti])) + int(
            ulMuMimoPrbThresholdAbsolute
        )
        logging.debug("candidate_ue_max_prb is {}".format(candidate_ue_max_prb))
        candidate_ue_min_prb = int(min(rnti_req_prb_dict[root_ue_rnti])) - int(
            ulMuMimoPrbThresholdAbsolute
        )
        logging.debug("candidate_ue_min_prb is {}".format(candidate_ue_min_prb))
        filter_candidate_prb = list(
            filter(
                lambda x: int(x) < candidate_ue_min_prb
                and candidate_ue_max_prb > int(x),
                rnti_req_prb_dict[candidate_ue_rnti],
            )
        )
        logging.debug("filter_candidate_prb is {}".format(filter_candidate_prb))
        candidate_ue_ul_fdSchedData_matrix_with_prb_filter = add_filters_to_matrix(
            rnti_ul_fdSchedData[candidate_ue_rnti],
            [
                self.parameter_dict["INDEX_ulFdSchedData_requiredPrb"],
                filter_candidate_prb,
            ],
        )
        ulMuStatus_values, ulMuStatus_count = self.get_ulMuStatus_values(
            event_matrix=candidate_ue_ul_fdSchedData_matrix_with_prb_filter
        )
        logging.debug(
            "ulmustatus under unpair condition {}, {}:".format(
                ulMuStatus_values, ulMuStatus_count
            )
        )
        unpair_condition = "|root_ue_required_prb-candidate_ue_required_prb| > ulMuMimoPrbThresholdAbsolute"
        pair_condition = "|root_ue_required_prb-candidate_ue_required_prb| < ulMuMimoPrbThresholdAbsolute"
        logging.debug(
            "start to check ue unpaired status under condition {}:".format(
                unpair_condition
            )
        )
        assert not bool(
            set(PAIRED_SUCCESS_TABLE) & set(ulMuStatus_values)
        ), "UE rnti {} is still paired under condition {}".format(
            candidate_ue_rnti, unpair_condition
        )
        assert (
            "MUNONPAIRED_EMPTYDEDICATELIST" in ulMuStatus_values
        ), "UE rnti {} not have unpaired status with reason MUNONPAIRED_EMPTYDEDICATELIST".format(
            candidate_ue_rnti
        )
        logging.debug(
            "start to check ue paired status under condition {}:".format(pair_condition)
        )
        candidate_ue_ul_fdSchedData_matrix_with_ulmustatus = add_filters_to_matrix(
            rnti_ul_fdSchedData[candidate_ue_rnti],
            [
                self.parameter_dict["INDEX_ulFdSchedData_ulMuStatus"],
                ["MUPAIRED_NO_TAPERING"],
            ],
        )
        candidate_ue_prb_result, count = self.get_requiredPrb_values(
            event_matrix=candidate_ue_ul_fdSchedData_matrix_with_ulmustatus
        )
        logging.debug(
            "candidate ue prb result {} {}:".format(candidate_ue_prb_result, count)
        )
        filter_candidate_prb_with_condition = list(
            filter(
                lambda x: int(x) < candidate_ue_min_prb
                and candidate_ue_max_prb > int(x),
                candidate_ue_prb_result,
            )
        )
        assert (
            len(filter_candidate_prb_with_condition) == 0
        ), "UE rnti {} is still paired with condition {}".format(
            candidate_ue_rnti, unpair_condition
        )
        return root_ue_rnti, candidate_ue_rnti

    def check_retransmission_subcell_id_same_for_single_ue(
        self, fdSchedData_event, ulHarqRxData_event
    ):
        """
        Auther:Stella
        :return:
        """
        (
            diff_sfn_index_fdSchedData_event,
            diff_sfn_index_ulHarqRxData_event,
        ) = self.get_diff_sfn_indices_between_two_events(
            event_matrix1=fdSchedData_event, event_matrix2=ulHarqRxData_event
        )
        sfn = self.get_column_values_from_matrix(
            matrix=fdSchedData_event,
            column_number=self.parameter_dict["INDEX_ulFdSchedData_SFN"],
        )
        slot = self.get_column_values_from_matrix(
            matrix=fdSchedData_event,
            column_number=self.parameter_dict["INDEX_ulFdSchedData_slot"],
        )
        txnumber = self.get_column_values_from_matrix(
            matrix=fdSchedData_event,
            column_number=self.parameter_dict["INDEX_ulFdSchedData_txNumber"],
        )
        subcells = self.get_subcellId_value_list(event_matrix=fdSchedData_event)
        crc = self.get_column_values_from_matrix(
            matrix=ulHarqRxData_event,
            column_number=self.parameter_dict["INDEX_ulHarqRxData_crcResult"],
        )
        ulHarqProcessIndex = self.get_column_values_from_matrix(
            matrix=ulHarqRxData_event,
            column_number=self.parameter_dict["INDEX_ulHarqRxData_ulHarqProcessIndex"],
        )
        txnumber = [
            item
            for (index, item) in enumerate(txnumber)
            if index not in diff_sfn_index_fdSchedData_event
        ]
        subcells = [
            item
            for (index, item) in enumerate(subcells)
            if index not in diff_sfn_index_fdSchedData_event
        ]
        sfn = [
            item
            for (index, item) in enumerate(sfn)
            if index not in diff_sfn_index_fdSchedData_event
        ]
        slot = [
            item
            for (index, item) in enumerate(slot)
            if index not in diff_sfn_index_fdSchedData_event
        ]
        crc = [
            item
            for (index, item) in enumerate(crc)
            if index not in diff_sfn_index_ulHarqRxData_event
        ]
        ulHarqProcessIndex = [
            item
            for (index, item) in enumerate(ulHarqProcessIndex)
            if index not in diff_sfn_index_ulHarqRxData_event
        ]
        logging.debug("new sfn length is {}".format(len(sfn)))
        logging.debug("new slot length is {}".format(len(slot)))
        logging.debug("new txnumber length is {}".format(len(txnumber)))
        logging.debug("new subcells lenth is {}".format(len(subcells)))
        logging.debug("new crc lenth is {}".format(len(crc)))
        logging.debug(
            "new ulHarqProcessIndex lenth is {}".format(len(ulHarqProcessIndex))
        )
        crc_nok_indices = [
            index
            for (index, item) in enumerate(crc[: (min(len(txnumber), len(crc)))])
            if item == "NOK" and txnumber[index] == "1.0"
        ]
        logging.debug("crc_nok_indices is {}".format(crc_nok_indices))
        for crc_nok_index in crc_nok_indices[:-16]:
            harq_id = ulHarqProcessIndex[crc_nok_index]
            same_harq_id_index = [
                index
                for (index, item) in enumerate(ulHarqProcessIndex)
                if item == harq_id and crc[index] == "OK"
            ]
            retransmit_harq_id_index = [
                item
                for (index, item) in enumerate(same_harq_id_index)
                if item > crc_nok_index
            ][0]
            first_transmit_subcell = subcells[crc_nok_index]
            retransmit_subcell = subcells[retransmit_harq_id_index]
            first_transmit_txnumber = txnumber[crc_nok_index]
            retransmit_txnumber = txnumber[retransmit_harq_id_index]
            first_transmit_sfn = sfn[crc_nok_index]
            retransmit_sfn = sfn[retransmit_harq_id_index]
            first_transmit_slot = slot[crc_nok_index]
            retransmit_slot = slot[retransmit_harq_id_index]
            logging.debug(
                "checkd sfn,slot is {}-{} and {}-{},txnumber is {} and {}".format(
                    first_transmit_sfn,
                    first_transmit_slot,
                    retransmit_sfn,
                    retransmit_slot,
                    first_transmit_txnumber,
                    retransmit_txnumber,
                )
            )
            if (
                int(retransmit_sfn) - int(first_transmit_sfn) <= 1
                and int(first_transmit_txnumber) == 1
                and int(retransmit_txnumber) == 2
            ):
                assert (
                    first_transmit_subcell == retransmit_subcell
                ), "subcell id changed after retransmission，origin is {},retransmit is {}".format(
                    first_transmit_subcell, retransmit_subcell
                )

    def check_retransmission_subcell_id_same_for_ues(self):
        """
        Auther:Stella
        :return:
        """
        fdSchedData_event = self.get_ul_fdSchedData_event()
        fdSchedData_event_with_txNumber = self.get_ul_fdSchedData_event_by_txNumber(
            event_matrix=fdSchedData_event, txNumber=1.0
        )
        rnti_values, rnti_count = self.get_rnti_values(
            event_matrix=fdSchedData_event_with_txNumber
        )
        for rnti in rnti_values:
            logging.debug("start to check subcell id for rnti {}".format(rnti))
            ulHarqRxData_event = self.get_ulHarqRxData_event()
            fdSchedData_event_by_rnti_only = self.get_ul_fdSchedData_event_by_rnti(
                event_matrix=fdSchedData_event, rnti=rnti
            )
            ulHarqRxData_event_with_rnti = self.get_ul_ulHarqRxData_event_by_rnti(
                event_matrix=ulHarqRxData_event, rnti=rnti
            )
            self.check_retransmission_subcell_id_same_for_single_ue(
                fdSchedData_event=fdSchedData_event_by_rnti_only,
                ulHarqRxData_event=ulHarqRxData_event_with_rnti,
            )

    def check_ue_mustatus_with_corrthd_not_reached(
        self, corrthd=0.03, expect_unpair_status="MUNONPAIRED_EMPTYDEDICATELIST"
    ):
        """
        author: Stella
        :param corrthd:
        :param expect_unpair_status:
        :return:
        """
        ue_mustatus_event = self.get_ulMuUeData_event()
        otheruescorrsum = self.get_column_values_from_matrix(
            matrix=ue_mustatus_event,
            column_number=self.parameter_dict["INDEX_ulMuUeData_otherUesCorrSum"],
        )
        mu_status = self.get_column_values_from_matrix(
            matrix=ue_mustatus_event,
            column_number=self.parameter_dict["INDEX_ulMuUeData_status"],
        )
        logging.debug("otheruescorrsum length is {}".format(len(otheruescorrsum)))
        logging.debug("mu_status is {}".format(len(mu_status)))
        index_above_corrthd = [
            index
            for (index, item) in enumerate(otheruescorrsum)
            if float(item) > float(corrthd)
        ]
        logging.debug("above length is {}".format(len(index_above_corrthd)))
        status_above_corrthd = [mu_status[index] for index in index_above_corrthd]
        assert (
            len(set(status_above_corrthd)) == 1
        ), "ul mustatus for above corrthd should only one status,actual is {}".format(
            set(status_above_corrthd)
        )
        assert (
            status_above_corrthd[0] == expect_unpair_status
        ), "ue should not paired with status {},but actual is{}".format(
            expect_unpair_status, status_above_corrthd[0]
        )

    def get_sfn_slot_results_for_retransmission_data(self):
        """
        author: Stella
        :param is_bler_cal:
        :return:
        """
        ues_retransmission_sfn_slot_info_dict = {}
        fdSchedData_event = self.get_ul_fdSchedData_event()
        fdSchedData_event_with_retransmission = (
            self.get_ul_fdSchedData_event_by_txNumber(
                event_matrix=fdSchedData_event, txNumber=2.0
            )
        )
        rnti_values, rnti_count = self.get_rnti_values(
            event_matrix=fdSchedData_event_with_retransmission
        )
        for rnti in rnti_values:
            logging.debug(
                "------ Start to get retransmission sfn_slot info for rnti-{} ------".format(
                    rnti
                )
            )
            sfn_slot_info_dict = {}
            fdSchedData_event_with_rnti = self.get_ul_fdSchedData_event_by_rnti(
                event_matrix=fdSchedData_event_with_retransmission, rnti=rnti
            )
            ulMuStatus_values = self.get_column_values_from_matrix(
                matrix=fdSchedData_event_with_rnti,
                column_number=self.parameter_dict["INDEX_ulFdSchedData_ulMuStatus"],
            )
            sfn = self.get_sfn_value_list(event_matrix=fdSchedData_event_with_rnti)
            slot = self.get_slot_value_list(event_matrix=fdSchedData_event_with_rnti)
            simple_pair_index = [
                index
                for (index, item) in enumerate(ulMuStatus_values)
                if item == "MUPAIRED_TAPERING_SIMPLERE"
                or item == "MUPAIRED_NON_TAPERING_SIMPLER"
            ]
            normal_pair_index = [
                index
                for (index, item) in enumerate(ulMuStatus_values)
                if item == "MUPAIRED_TAPERING" or item == "MUPAIRED_NON_TAPERING"
            ]
            if len(simple_pair_index) == 0 and len(normal_pair_index) != 0:
                senario_triggered = False
                simple_pair_status = False
                normal_pair_status = True
            elif len(simple_pair_index) != 0 and len(normal_pair_index) == 0:
                senario_triggered = False
                simple_pair_status = True
                normal_pair_status = False
            elif len(simple_pair_index) == 0 and len(normal_pair_index) == 0:
                senario_triggered = False
                simple_pair_status = False
                normal_pair_status = False
            else:
                senario_triggered = True
                simple_pair_status = True
                normal_pair_status = True
            simple_pair_sfn = [sfn[index] for index in simple_pair_index]
            simple_pair_slot = [slot[index] for index in simple_pair_index]
            simple_pair_sfn_slot_elements = list(zip(simple_pair_sfn, simple_pair_slot))
            normal_pair_sfn = [sfn[index] for index in normal_pair_index]
            normal_pair_slot = [slot[index] for index in normal_pair_index]
            normal_pair_sfn_slot_elements = list(zip(normal_pair_sfn, normal_pair_slot))
            sfn_slot_info_dict["simple_pair_sfn_slot"] = simple_pair_sfn_slot_elements
            sfn_slot_info_dict["normal_pair_sfn_slot"] = normal_pair_sfn_slot_elements
            ues_retransmission_sfn_slot_info_dict[rnti] = sfn_slot_info_dict
            logging.debug(
                "ues retransmission pair info is {} ".format(
                    ues_retransmission_sfn_slot_info_dict
                )
            )
        return senario_triggered, simple_pair_status, normal_pair_status

    # def check_pBoost_value(self):
    #     event_matrix = self.get_ul_fdSchedData_event()
    #     pBoost_value_list = self.get_pBoost_value_list(event_matrix=event_matrix)
    #     pBoost_not_above_zero = [x for x in pBoost_value_list if float(x) <= 0]
    #     ratio = len(pBoost_not_above_zero) / len(pBoost_value_list)
    #     assert (
    #         len(pBoost_not_above_zero) == 0
    #     ), "pBoost not above zero exist, raito is {}".format(ratio)

    def calculate_ul_non_dtx(self, ulHarqRxData_event):
        """
        author: xiaoxia.hao
        :param ulHarqRxData_event:
        :return:
        """
        ulHarqRxData_dtxResult = self.get_column_values_from_matrix(
            matrix=ulHarqRxData_event,
            column_number=self.parameter_dict["INDEX_ulHarqRxData_dtx"],
        )
        logging.debug(
            "origin dtx result is {} on UL dtx".format(ulHarqRxData_dtxResult)
        )
        logging.debug(
            "origin dtx length is {} on UL dtx".format(len(ulHarqRxData_dtxResult))
        )
        ulHarqRxData_dtxResult_value_count = Counter(ulHarqRxData_dtxResult)
        logging.debug(
            "origin non_dtx length is {} on UL dtx".format(
                ulHarqRxData_dtxResult_value_count["NON_DTX"]
            )
        )
        logging.debug(
            "origin dtx length is {} on UL dtx".format(
                ulHarqRxData_dtxResult_value_count["DTX"]
            )
        )
        non_dtx_percent = 1
        try:
            non_dtx_percent = ulHarqRxData_dtxResult_value_count["NON_DTX"] / (
                ulHarqRxData_dtxResult_value_count["NON_DTX"]
                + ulHarqRxData_dtxResult_value_count["DTX"]
            )
            logging.debug(
                "ul non_dtx percentage is {} on UL dtx".format(non_dtx_percent)
            )
        except Exception as e:
            logging.debug("error {} found on non_dtx percent compute")
        return non_dtx_percent

    def calculate_ul_retry_conuter_txnumber(self, fdSchedData_event):
        """
        author: xiaoxia.hao
        :param fdSchedData_event:
        :return:
        """
        txnumber = self.get_column_values_from_matrix(
            matrix=fdSchedData_event,
            column_number=self.parameter_dict["INDEX_ulFdSchedData_txNumber"],
        )
        txnumber_value_count = Counter(txnumber)
        logging.debug("txnumber_value_count is{}".format(txnumber_value_count))
        retry_txnumber = txnumber_value_count["2.0"]
        return retry_txnumber

    def calculate_ul_non_dtx_and_retry_txnumber_conuter(self):
        """
        author: xiaoxia.hao
        :param fdSchedData_event:
        :return:
        """
        fdSchedData_event = self.get_ul_fdSchedData_event()
        ulHarqRxData_event = self.get_ulHarqRxData_event()
        non_dtx_percent = self.calculate_ul_non_dtx(
            ulHarqRxData_event=ulHarqRxData_event,
        )
        retry_txnumber = self.calculate_ul_retry_conuter_txnumber(
            fdSchedData_event=fdSchedData_event,
        )
        return retry_txnumber, non_dtx_percent

    def get_ul_ulmugroup_paird_percent(self, group_paird_percent_exp=0.1):
        """
        author: xiaoxia.hao
        :return:
        """
        total_group_status_count = 0
        group_status_count = 0
        ues_ulMuStatus_dict = self.get_ulMuStatus_info_for_ues()
        for rnti, ulMuStatus_info in ues_ulMuStatus_dict.items():
            logging.debug(
                "------ Start to calculate ulMuGroupStatus status for ue rnti-{} ------".format(
                    rnti
                )
            )
            for status in ULMUGROUPS_PAIRED_SUCCESS_TABLE:
                try:
                    group_status_count = (
                        group_status_count
                        + ulMuStatus_info["ulMuGroupStatus_count"][status]
                    )
                    logging.debug(
                        "ue rnti-{}:{} status_count is {}".format(
                            rnti,
                            status,
                            ulMuStatus_info["ulMuGroupStatus_count"][status],
                        )
                    )
                except Exception as e:
                    logging.debug("error {} found when get group status count")
            total_group_status_count = total_group_status_count + sum(
                ulMuStatus_info["ulMuGroupStatus_count"].values()
            )
        group_status_percent = group_status_count / total_group_status_count
        logging.debug(
            "paired ulMuGroupStatus {} percent is {}".format(
                ULMUGROUPS_PAIRED_SUCCESS_TABLE, group_status_percent
            )
        )
        assert (
            group_status_percent >= group_paird_percent_exp
        ), "ulMuGroupStatus paired percent is {},actual is {}".format(
            group_status_percent, group_paird_percent_exp
        )


tti_trace_analysis = TTI_Trace_analysis()


def calculate_ubler_and_ultput_for_ues(
    file_path, is_bler_cal=True, txNumer_2="2.0", txNumer_1="1.0"
):
    """
    Auther:Stella
    :return:
    """
    tti_trace_analysis.set_tti_trace_file_path(file_path=file_path)
    tti_trace_analysis.get_ul_parameters_column()
    return tti_trace_analysis.calculate_ul_tput_and_ul_bler_for_ues(
        is_bler_cal=is_bler_cal, txNumer_2=txNumer_2, txNumer_1=txNumer_1
    )


def check_ul_ue_paried_status_for_ues(
    file_path,
    expect_pair_status="paired",
    is_ulmustatus_need_to_check=True,
    ulmustatus="MUPAIRED_NO_TAPERING",
    percent_exp=0.98,
    is_ulmugroup_status_need_to_check=False,
    group_paird_percent_exp=0.1,
    checked_pair_ue_rnti=None,
):
    """
    Auther:Stella
    :return:
    """
    tti_trace_analysis.set_tti_trace_file_path(file_path=file_path)
    tti_trace_analysis.get_ul_parameters_column()
    tti_trace_analysis.check_ul_ue_paried_or_not_paired_status(
        paired_status=expect_pair_status,
        is_ulmustatus_need_to_check=is_ulmustatus_need_to_check,
        ulmustatus=ulmustatus,
        percent_exp=percent_exp,
        is_ulmugroup_status_need_to_check=is_ulmugroup_status_need_to_check,
        group_paird_percent_exp=group_paird_percent_exp,
    )


def check_ulMuStatus_and_ulMuGroupStatus_ratio_for_ues(
    file_path,
    expect_pair_status="paired",
    is_ulmustatus_need_to_check=True,
    percent_exp=0.11,
    is_ulmugroup_status_need_to_check=True,
    group_paird_percent_exp=0,
):
    """
    Author:lei.jia@nokia-sbell.com
    :return:
    """
    tti_trace_analysis.set_tti_trace_file_path(file_path=file_path)
    tti_trace_analysis.get_ul_parameters_column()
    tti_trace_analysis.check_ulMuStatus_and_ulMuGroupStatus_ratio(
        paired_status=expect_pair_status,
        is_ulmustatus_need_to_check=is_ulmustatus_need_to_check,
        percent_exp=percent_exp,
        is_ulmugroup_status_need_to_check=is_ulmugroup_status_need_to_check,
        group_paird_percent_exp=group_paird_percent_exp,
    )


def verify_Ues_paired_status_with_varied_reqprb(
    file_path, ulMuMimoPrbThresholdAbsolute=30, ulMinPrbThreshold=100
):
    """
    Auther:Stella
    :return:
    """
    tti_trace_analysis.set_tti_trace_file_path(file_path=file_path)
    tti_trace_analysis.get_ul_parameters_column()
    return tti_trace_analysis.verify_Ues_paired_status_with_varied_prb(
        ulMuMimoPrbThresholdAbsolute=ulMuMimoPrbThresholdAbsolute,
        ulMinPrbThreshold=ulMinPrbThreshold,
    )


def check_antPort_info_for_two_subcells(
    file_path,
    subcell0_id=None,
    subcell1_id=None,
    expect_subcell0_port=None,
    expect_subcell1_port=None,
):
    """
    Auther:Stella
    :return:
    """
    tti_trace_analysis.set_tti_trace_file_path(file_path=file_path)
    tti_trace_analysis.get_ul_parameters_column()
    tti_trace_analysis.check_antPort_info_for_subcells(
        subcell0_id=subcell0_id,
        subcell1_id=subcell1_id,
        expect_subcell0_port=expect_subcell0_port,
        expect_subcell1_port=expect_subcell1_port,
    )


def check_subcell_is_same_for_retransmission_data(file_path):
    """
    Auther:Stella
    :return:
    """
    tti_trace_analysis.set_tti_trace_file_path(file_path=file_path)
    tti_trace_analysis.get_ul_parameters_column()
    tti_trace_analysis.check_retransmission_subcell_id_same_for_ues()


def check_rnti_subcell_mapping(
    file_path,
    rnti_number=4,
    subcell0_id=None,
    subcell1_id=None,
    subcell0_rnti_number=None,
    subcell1_rnti_number=None,
):
    """
    Auther:Stella
    :return:
    """
    tti_trace_analysis.set_tti_trace_file_path(file_path=file_path)
    tti_trace_analysis.get_ul_parameters_column()
    all_ues_info = tti_trace_analysis.get_all_ues_related_info()
    assert len(all_ues_info.keys()) == int(
        rnti_number
    ), "scheduled rnti number should be {},actual is {}".format(
        rnti_number, len(all_ues_info.keys())
    )
    if subcell0_rnti_number is not None:
        rnti_subcell0_mapping = {
            rnti: subcell_info
            for rnti, subcell_info in all_ues_info.items()
            if subcell_info["subcellId"] == subcell0_id
        }
    if subcell1_rnti_number is not None:
        rnti_subcell1_mapping = {
            rnti: subcell_info
            for rnti, subcell_info in all_ues_info.items()
            if subcell_info["subcellId"] == subcell1_id
        }
    if subcell0_rnti_number is not None:
        assert len(rnti_subcell0_mapping.keys()) == int(
            subcell0_rnti_number
        ), "scheduled rnti number on sunbcell0 should be {},actual is {}".format(
            subcell0_rnti_number, len(rnti_subcell0_mapping.keys())
        )
    if subcell1_rnti_number is not None:
        assert len(rnti_subcell1_mapping.keys()) == int(
            subcell1_rnti_number
        ), "scheduled rnti number on sunbcell0 should be {},actual is {}".format(
            subcell1_rnti_number, len(rnti_subcell1_mapping.keys())
        )


def check_ue_unpaired_with_corrthd_not_reached(
    file_path, corrthd=0.03, expect_unpair_status="MUNONPAIRED_EMPTYDEDICATELIST"
):
    """
    Auther:Stella
    :return:
    """
    tti_trace_analysis.set_tti_trace_file_path(file_path=file_path)
    tti_trace_analysis.get_ul_parameters_column()
    tti_trace_analysis.get_ulMuUeData_params_only()
    tti_trace_analysis.check_ue_mustatus_with_corrthd_not_reached(
        corrthd=corrthd, expect_unpair_status=expect_unpair_status
    )


def check_retransmission_data_mustatus(file_path):
    tti_trace_analysis.set_tti_trace_file_path(file_path=file_path)
    tti_trace_analysis.get_ul_parameters_column()
    (
        senario_triggered,
        simple_pair_status,
        normal_pair_status,
    ) = tti_trace_analysis.get_sfn_slot_results_for_retransmission_data()
    return senario_triggered, simple_pair_status, normal_pair_status


# def check_virtualUe_number_for_4ues_per_slot(file_path, expect_virtualue_number=2):
#     tti_trace_analysis.set_tti_trace_file_path(file_path=file_path)
#     tti_trace_analysis.get_ul_parameters_column()
#     tti_trace_analysis.check_virtualUe_for_4ues_per_slot(
#         expect_virtualue_number=expect_virtualue_number
#     )


# def check_pBoost_value_above_zero(file_path):
#     tti_trace_analysis.set_tti_trace_file_path(file_path=file_path)
#     tti_trace_analysis.get_ul_parameters_column()
#     tti_trace_analysis.check_pBoost_value()


def calculate_ul_non_dtx_and_ul_txnumber(file_path):
    """
    Auther:Stella
    :return:
    """
    logging.debug(file_path)
    tti_trace_analysis.set_tti_trace_file_path(file_path=file_path)
    tti_trace_analysis.get_ul_basic_parameters_column()
    return tti_trace_analysis.calculate_ul_non_dtx_and_retry_txnumber_conuter()


def calculate_ul_ulmugroup_status(file_path, group_paird_percent_exp=0.1):
    logging.debug(file_path)
    tti_trace_analysis.set_tti_trace_file_path(file_path=file_path)
    tti_trace_analysis.get_ul_parameters_column()
    return tti_trace_analysis.get_ul_ulmugroup_paird_percent(
        group_paird_percent_exp=group_paird_percent_exp
    )

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
    "calculate_dlbler_and_dltput_for_ues",
    "calculate_dl_non_dtx_and_dl_txnumber",
    "calculate_dl_muStatus_and_dl_numberOfCorrCalcDuringSelectUes",
    "calculate_dl_muStatus_no_pair_littledatanotneedpair_Counter",
    "calculate_dl_muStatus_mupair_Counter",
    "calculate_dl_beamtype_Counter"
]


class DlTtiTraceAnalysis(object):
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

    def get_dl_parameters_column(self):
        """
        author:lei.jia@nokia-sbell.com
        :return:
        """
        with open(self.file_path, "r") as csv_file:
            reader = list(csv.reader(csv_file))
        self.parameter_dict["INDEX_dlFdSchedData"] = self.get_columns(
            reader_list=reader,
            filter="dlFdSchedData",
            column_name="type",
        )
        self.parameter_dict["INDEX_dlFdSchedData_rnti"] = self.get_columns(
            reader_list=reader,
            filter="dlFdSchedData",
            column_name="rnti",
        )
        self.parameter_dict["INDEX_dlFdSchedData_slot"] = self.get_columns(
            reader_list=reader,
            filter="dlFdSchedData",
            column_name="slot",
        )
        self.parameter_dict["INDEX_dlFdSchedData_SFN"] = self.get_columns(
            reader_list=reader,
            filter="dlFdSchedData",
            column_name="sfn",
        )
        self.parameter_dict["INDEX_dlFdSchedData_physCellId"] = self.get_columns(
            reader_list=reader,
            filter="dlFdSchedData",
            column_name="physCellId",
        )
        self.parameter_dict["INDEX_dlFdSchedData_txNumber"] = self.get_columns(
            reader_list=reader,
            filter="dlFdSchedData",
            column_name="txNumber",
        )
        self.parameter_dict["INDEX_dlFdSchedData_tbsize"] = self.get_columns(
            reader_list=reader,
            filter="dlFdSchedData",
            column_name="tbSize",
        )
        self.parameter_dict["INDEX_dlFdSchedData_antPort"] = self.get_columns(
            reader_list=reader,
            filter="dlFdSchedData",
            column_name="antPort",
        )
        self.parameter_dict["INDEX_dlFdSchedData_muStatus"] = self.get_columns(
            reader_list=reader,
            filter="dlFdSchedData",
            column_name="muStatus",
        )
        self.parameter_dict["INDEX_dlFdSchedData_beamType"] = self.get_columns(
            reader_list=reader,
            filter="dlFdSchedData",
            column_name="beamType",
        )
        self.parameter_dict["INDEX_dlHarqRxDataArray_rnti"] = self.get_columns(
            reader_list=reader,
            filter="dlHarqRxDataArray",
            column_name="rnti",
        )
        self.parameter_dict["INDEX_dlHarqRxDataArray_SFN"] = self.get_columns(
            reader_list=reader,
            filter="dlHarqRxDataArray",
            column_name="sfn",
        )
        self.parameter_dict["INDEX_dlHarqRxDataArray_dtx"] = self.get_columns(
            reader_list=reader,
            filter="dlHarqRxDataArray",
            column_name="dtx",
        )
        self.parameter_dict["INDEX_dlHarqRxDataArray_ackNack"] = self.get_columns(
            reader_list=reader,
            filter="dlHarqRxDataArray",
            column_name="ackNack",
        )
        self.parameter_dict[
            "INDEX_dlMuAwareTdSchInfo_numberOfCorrCalcDuringSelectUes"
        ] = self.get_columns(
            reader_list=reader,
            filter="dlMuAwareTdSchInfo",
            column_name="numberOfCorrCalcDuringSelectUes",
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
            [self.parameter_dict["INDEX_dlFdSchedData_rnti"], [rnti]],
        )

    def get_dl_fdSchedData_event(self):
        """
        author: Stella
        :return:
        """
        event_res = self.get_specific_event(event_name="dlFdSchedData")
        return add_filters_to_matrix(
            event_res, [self.parameter_dict["INDEX_dlFdSchedData"], ["dlFdSchedData"]]
        )

    def get_dlHarqRxDataArray_event(self):
        """
        author: Stella
        :return:
        """
        return self.get_specific_event(event_name="dlHarqRxDataArray")

    def get_dlMuAwareTdSchInfo_event(self):
        """
        author: Stella
        :return:
        """
        return self.get_specific_event(event_name="dlMuAwareTdSchInfo")

    def get_dl_fdSchedData_event_by_rnti(self, event_matrix, rnti):
        """
        author: Stella
        :param event_matrix:
        :param rnti:
        :return:
        """
        return self.get_event_by_filter_rnti(event_matrix=event_matrix, rnti=rnti)

    def get_dl_dlHarqRxDataArray_event_by_rnti(self, event_matrix, rnti):
        """
        author: Stella
        :param event_matrix:
        :param rnti:
        :return:
        """
        return self.get_event_by_filter_rnti(event_matrix=event_matrix, rnti=rnti)

    def get_dl_fdSchedData_event_by_txNumber(self, event_matrix, txNumber):
        """
        author: Stella
        :param event_matrix:
        :param txNumber:
        :return:
        """
        txNumber = str(txNumber)
        return add_filters_to_matrix(
            event_matrix,
            [self.parameter_dict["INDEX_dlFdSchedData_txNumber"], [txNumber]],
        )

    def get_rnti_values(self, event_matrix):
        """
        author: Stella
        :param event_matrix:
        :return:
        """
        return self.get_unique_column_values_and_count(
            matrix=event_matrix,
            column_number=self.parameter_dict["INDEX_dlFdSchedData_rnti"],
        )

    def get_dl_slot_values(self, event_matrix):
        """
        author: Stella
        :param event_matrix:
        :return:
        """
        return self.get_unique_column_values_and_count(
            matrix=event_matrix,
            column_number=self.parameter_dict["INDEX_dlFdSchedData_slot"],
        )

    def get_dl_slot_value_list(self, event_matrix):
        """
        author: Stella
        :param event_matrix:
        :return:
        """
        return self.get_column_values_from_matrix(
            matrix=event_matrix,
            column_number=self.parameter_dict["INDEX_dlFdSchedData_slot"],
        )

    def get_dl_sfn_value_list(self, event_matrix, event_name="dlFdSchedData"):
        """
        author: Stella
        :param event_matrix:
        :return:
        """
        return self.get_column_values_from_matrix(
            matrix=event_matrix,
            column_number=self.parameter_dict["INDEX_{}_SFN".format(event_name)],
        )

    def get_dl_tbsize_value_list(self, event_matrix):
        """
        author: lei.jia@nokia-sbell.com
        :param event_matrix:
        :return:
        """
        return self.get_column_values_from_matrix(
            matrix=event_matrix,
            column_number=self.parameter_dict["INDEX_dlFdSchedData_tbsize"],
        )

    def calculate_dl_bler_for_single_ue(
        self,
        fdSchedData_event,
        dlHarqRxDataArray_event,
        tx_number_2=2.0,
        tx_number_1=1.0,
    ):
        """
        author: Stella
        :param fdSchedData_event:
        :param ulHarqRxData_event:
        :return:
        """
        txnumber = self.get_column_values_from_matrix(
            matrix=fdSchedData_event,
            column_number=self.parameter_dict["INDEX_dlFdSchedData_txNumber"],
        )
        ackNack = self.get_column_values_from_matrix(
            matrix=dlHarqRxDataArray_event,
            column_number=self.parameter_dict["INDEX_dlHarqRxDataArray_ackNack"],
        )
        logging.debug("origin txnumber length is {}".format(len(txnumber)))
        logging.debug("origin ackNack lenth is {}".format(len(ackNack)))
        # dlHarqRxDataArray：NACK samples/all ACK+NACK samples
        ackNack_value_count = Counter(ackNack)
        txnumber_value_count = Counter(txnumber)
        logging.debug("ackNack_value_count is{}".format(ackNack_value_count))
        bler = 1
        try:
            bler = ackNack_value_count["NACK"] / (
                ackNack_value_count["NACK"] + ackNack_value_count["ACK"]
            )
            logging.debug("dl bler is {}".format(bler))
            logging.debug("dl tx_number is {},{}".format(tx_number_2, tx_number_1))
            ibler = txnumber_value_count["{}".format(str(tx_number_2))] / (
                txnumber_value_count["{}".format(str(tx_number_1))]
            )
            logging.debug("dl ibler is {}".format(ibler))
        except Exception as e:
            logging.debug("error {} found on bler compute")
        return bler, ibler

    def removeDepulicates(self, nums):
        """
        author: lei.jia
        :param
        :return: sfn list after remove depulicates, for exmaple [114, 115...1023, 0, 1, 2,...330]
        """
        slow = 1
        fast = 1
        while fast < len(nums):
            if nums[fast] != nums[fast - 1]:
                nums[slow] = nums[fast]
                slow += 1
            fast += 1
        return nums[:slow]

    def calculate_dl_tput_for_sinlge_ue(self, rnti):
        """
        author: lei.jia
        :param
        :return:
        """
        logging.debug(
            "------ Start to calculate dl tput for ue rnti-{} ------".format(rnti)
        )
        fdSchedData_event = self.get_dl_fdSchedData_event()
        fdSchedData_event_with_txNumber = self.get_dl_fdSchedData_event_by_txNumber(
            event_matrix=fdSchedData_event, txNumber=1
        )
        tput_bler_info_dict = {}
        fdSchedData_event_with_rnti = self.get_dl_fdSchedData_event_by_rnti(
            event_matrix=fdSchedData_event_with_txNumber, rnti=rnti
        )
        tbsize_values_list = self.get_dl_tbsize_value_list(
            event_matrix=fdSchedData_event_with_rnti
        )
        sfn_values_list = self.get_dl_sfn_value_list(
            event_matrix=fdSchedData_event_with_rnti
        )
        slot_values, slot_count = self.get_dl_slot_values(
            event_matrix=fdSchedData_event_with_rnti
        )
        sfn_list_removeDepulicates = self.removeDepulicates(sfn_values_list)
        logging.debug(
            "all dl sfn remove depulicates is {}".format(sfn_list_removeDepulicates)
        )
        # calculate total tbsize within one second, only txnumber=1
        # 1 second equals to 100 subframes
        duration = len(sfn_list_removeDepulicates) / 100
        tbsize_total = sum([int(x) for x in tbsize_values_list])
        average_dl_tput = float(tbsize_total) / (duration * 1000 * 1000)
        logging.debug(
            "average dl tput for rnti-{} is {}, dl tput duration is {}".format(
                rnti, average_dl_tput, duration
            )
        )
        tput_bler_info_dict["tput"] = average_dl_tput
        tput_bler_info_dict["duration"] = duration
        return tput_bler_info_dict

    def calculate_dl_tput_and_dl_bler(
        self, is_bler_cal=True, tx_number_2="2.0", tx_number_1="1.0"
    ):
        """
        author: lei.jia
        :param is_bler_cal:
        :return:
        """
        ues_tput_bler_dict = {}
        fdSchedData_event = self.get_dl_fdSchedData_event()
        fdSchedData_event_with_txNumber = self.get_dl_fdSchedData_event_by_txNumber(
            event_matrix=fdSchedData_event, txNumber=1
        )
        rnti_values, rnti_count = self.get_rnti_values(
            event_matrix=fdSchedData_event_with_txNumber
        )
        for rnti in rnti_values:
            tput_bler_info_dict = dl_tti_trace_analysis.calculate_dl_tput_for_sinlge_ue(
                rnti=rnti
            )
            if is_bler_cal:
                logging.debug(
                    "------ Start to calculate dl bler for ue rnti-{} ------".format(
                        rnti
                    )
                )
                dlHarqRxDataArray_event = self.get_dlHarqRxDataArray_event()
                fdSchedData_event_by_rnti_only = self.get_dl_fdSchedData_event_by_rnti(
                    event_matrix=fdSchedData_event, rnti=rnti
                )
                dlHarqRxDataArray_event_with_rnti = (
                    self.get_dl_dlHarqRxDataArray_event_by_rnti(
                        event_matrix=dlHarqRxDataArray_event, rnti=rnti
                    )
                )
                dl_bler, dl_ibler = self.calculate_dl_bler_for_single_ue(
                    fdSchedData_event=fdSchedData_event_by_rnti_only,
                    dlHarqRxDataArray_event=dlHarqRxDataArray_event_with_rnti,
                    tx_number_2=tx_number_2,
                    tx_number_1=tx_number_1,
                )
                tput_bler_info_dict["bler"] = dl_bler
                tput_bler_info_dict["ibler"] = dl_ibler
            ues_tput_bler_dict[rnti] = tput_bler_info_dict
        logging.debug(
            "------ Calculate dl tput and dl bler Done! result is {} ------".format(
                ues_tput_bler_dict
            )
        )
        return ues_tput_bler_dict

    def calculate_dl_non_dtx(self, dlHarqRxDataArray_event):
        """
        author: xiaoxia.hao
        :param ulHarqRxData_event:
        :return:
        """
        dlHarqRxDataArray_dtxResult = self.get_column_values_from_matrix(
            matrix=dlHarqRxDataArray_event,
            column_number=self.parameter_dict["INDEX_dlHarqRxDataArray_dtx"],
        )
        logging.debug(
            "origin dtx result is {} on DL dtx".format(dlHarqRxDataArray_dtxResult)
        )
        logging.debug(
            "origin dtx length is {} on DL dtx".format(len(dlHarqRxDataArray_dtxResult))
        )
        dlHarqRxDataArray_dtxResult_value_count = Counter(dlHarqRxDataArray_dtxResult)
        logging.debug(
            "origin non_dtx length is {} on DL dtx".format(
                dlHarqRxDataArray_dtxResult_value_count["NON_DTX"]
            )
        )
        logging.debug(
            "origin dtx length is {} on DL dtx".format(
                dlHarqRxDataArray_dtxResult_value_count["DTX"]
            )
        )
        non_dtx_percent = 1
        try:
            non_dtx_percent = dlHarqRxDataArray_dtxResult_value_count["NON_DTX"] / (
                dlHarqRxDataArray_dtxResult_value_count["NON_DTX"]
                + dlHarqRxDataArray_dtxResult_value_count["DTX"]
            )
            logging.debug("dl non_dtx percent is {}".format(non_dtx_percent))
        except Exception as e:
            logging.debug("error {} found on non_dtx percent compute")
        return non_dtx_percent

    def calculate_dl_retry_txnumber_conuter(self, fdSchedData_event):
        """
        author: xiaoxia.hao
        :param fdSchedData_event:
        :return:
        """
        txnumber = self.get_column_values_from_matrix(
            matrix=fdSchedData_event,
            column_number=self.parameter_dict["INDEX_dlFdSchedData_txNumber"],
        )
        txnumber_value_count = Counter(txnumber)
        logging.debug("origin txnumber length is {}".format(len(txnumber_value_count)))
        retry_txnumber = txnumber_value_count["2.0"]
        return retry_txnumber

    def calculate_dl_mupair_conuter(self, muStatus_value="MUPAIR"):
        """
        author: xiaoxia.hao
        :param fdSchedData_event:
        :return:
        """
        fdSchedData_event = self.get_dl_fdSchedData_event()
        muStatus = self.get_column_values_from_matrix(
            matrix=fdSchedData_event,
            column_number=self.parameter_dict["INDEX_dlFdSchedData_muStatus"],
        )
        muStatus_value_count = Counter(muStatus)
        total_muStatus_value_count = len(muStatus)
        mupair = muStatus_value_count[muStatus_value]
        logging.debug("origin muStatus detail is {}".format(muStatus))
        logging.debug("total muStatus length is {}".format(total_muStatus_value_count))
        logging.debug("origin muStatus length is {}".format(mupair))
        return mupair, total_muStatus_value_count

    def calculate_dl_BeamType(self, beamType_value="SUBBAND"):
        """
        author: xiaoxia.hao
        :param fdSchedData_event:
        :return:
        """
        fdSchedData_event = self.get_dl_fdSchedData_event()
        beamType_counter = self.get_column_values_from_matrix(
            matrix=fdSchedData_event,
            column_number=self.parameter_dict["INDEX_dlFdSchedData_beamType"],
        )
        beamType_value_count = Counter(beamType_counter)
        total_beamType_value_count = len(beamType_counter)
        beamType = beamType_value_count[beamType_value]
        logging.debug("origin beamType detail is {}".format(beamType_counter))
        logging.debug("total beamType length is {}".format(total_beamType_value_count))
        logging.debug("origin beamType length is {}".format(beamType))
        return beamType, total_beamType_value_count

    def calculate_dl_no_pair_littledatanotneedpair_conuter(self):
        """
        author: xiaoxia.hao
        :param fdSchedData_event:
        :return:
        """
        fdSchedData_event = self.get_dl_fdSchedData_event()
        muStatus = self.get_column_values_from_matrix(
            matrix=fdSchedData_event,
            column_number=self.parameter_dict["INDEX_dlFdSchedData_muStatus"],
        )
        muStatus_value_count = Counter(muStatus)
        logging.debug("origin muStatus detail is {}".format(muStatus))
        logging.debug("origin muStatus length is {}".format(muStatus_value_count))
        no_pair_littledatanotneedpair = muStatus_value_count[
            "NOPAIR_LITTLEDATANOTNEEDPAIR"
        ]
        return no_pair_littledatanotneedpair

    def calculate_dl_numberOfCorrCalcDuringSelectUes_conuter(
        self, dlMuAwareTdSchInfo_event
    ):
        """
        author: xiaoxia.hao
        :param fdSchedData_event:
        :return:
        """
        numberOfCorrCalcDuringSelectUes = self.get_column_values_from_matrix(
            matrix=dlMuAwareTdSchInfo_event,
            column_number=self.parameter_dict[
                "INDEX_dlMuAwareTdSchInfo_numberOfCorrCalcDuringSelectUes"
            ],
        )
        numberOfCorrCalcDuringSelectUes_value_count = Counter(
            numberOfCorrCalcDuringSelectUes
        )
        logging.debug(
            "totol numberOfCorrCalcDuringSelectUes detail infor is {}".format(
                numberOfCorrCalcDuringSelectUes
            )
        )
        logging.debug(
            "origin numberOfCorrCalcDuringSelectUes length is {}".format(
                numberOfCorrCalcDuringSelectUes_value_count
            )
        )
        numberOfCorrCalcDuringSelectUes_percent = 1
        try:
            numberOfCorrCalcDuringSelectUes_percent = (
                numberOfCorrCalcDuringSelectUes_value_count["0.0"]
                / (
                    numberOfCorrCalcDuringSelectUes_value_count["0.0"]
                    + numberOfCorrCalcDuringSelectUes_value_count["1.0"]
                    + numberOfCorrCalcDuringSelectUes_value_count["2.0"]
                    + numberOfCorrCalcDuringSelectUes_value_count["3.0"]
                    + numberOfCorrCalcDuringSelectUes_value_count["4.0"]
                    + numberOfCorrCalcDuringSelectUes_value_count["5.0"]
                )
            )
            logging.debug(
                "dl numberOfCorrCalcDuringSelectUes value is 0 percent is {}".format(
                    numberOfCorrCalcDuringSelectUes_percent
                )
            )
        except Exception as e:
            logging.debug("error {} found numberOfCorrCalcDuringSelectUes compute")
        return numberOfCorrCalcDuringSelectUes_percent

    def calculate_dl_non_dtx_and_retry_txnumber_conuter(self):
        """
        author: xiaoxia.hao
        :param fdSchedData_event:
        :return:
        """
        fdSchedData_event = self.get_dl_fdSchedData_event()
        dlHarqRxDataArray_event = self.get_dlHarqRxDataArray_event()
        non_dtx_percent = self.calculate_dl_non_dtx(
            dlHarqRxDataArray_event=dlHarqRxDataArray_event,
        )
        retry_txnumber = self.calculate_dl_retry_txnumber_conuter(
            fdSchedData_event=fdSchedData_event,
        )
        return retry_txnumber, non_dtx_percent

    def calculate_dl_muStatus_and_dl_numberOfCorrCalcDuringSelectUes_conuter(self):
        """
        author: xiaoxia.hao
        :param fdSchedData_event:
        :return:
        """
        #        fdSchedData_event = self.get_dl_fdSchedData_event()
        dlMuAwareTdSchInfo_event = self.get_dlMuAwareTdSchInfo_event()
        numberOfCorrCalcDuringSelectUes_percent = (
            self.calculate_dl_numberOfCorrCalcDuringSelectUes_conuter(
                dlMuAwareTdSchInfo_event=dlMuAwareTdSchInfo_event,
            )
        )
        mupair = self.calculate_dl_mupair_conuter()
        return mupair, numberOfCorrCalcDuringSelectUes_percent


dl_tti_trace_analysis = DlTtiTraceAnalysis()


def calculate_dlbler_and_dltput_for_ues(
    file_path, is_bler_cal=True, txNumer_2="2.0", txNumer_1="1.0"
):
    """
    Author:leijia
    :return:
    """
    dl_tti_trace_analysis.set_tti_trace_file_path(file_path=file_path)
    dl_tti_trace_analysis.get_dl_parameters_column()
    return dl_tti_trace_analysis.calculate_dl_tput_and_dl_bler(
        is_bler_cal=is_bler_cal, tx_number_2=txNumer_2, tx_number_1=txNumer_1
    )


def calculate_dl_non_dtx_and_dl_txnumber(file_path):
    """
    Auther:Stella
    :return:
    """
    logging.debug(file_path)
    dl_tti_trace_analysis.set_tti_trace_file_path(file_path=file_path)
    dl_tti_trace_analysis.get_dl_parameters_column()
    return dl_tti_trace_analysis.calculate_dl_non_dtx_and_retry_txnumber_conuter()


def calculate_dl_muStatus_and_dl_numberOfCorrCalcDuringSelectUes(file_path):
    """
    Auther:Stella
    :return:
    """
    logging.debug(file_path)
    dl_tti_trace_analysis.set_tti_trace_file_path(file_path=file_path)
    dl_tti_trace_analysis.get_dl_parameters_column()
    return (
        dl_tti_trace_analysis.calculate_dl_muStatus_and_dl_numberOfCorrCalcDuringSelectUes_conuter()
    )


def calculate_dl_muStatus_no_pair_littledatanotneedpair_Counter(file_path):
    """
    Auther:Stella
    :return:
    """
    logging.debug(file_path)
    dl_tti_trace_analysis.set_tti_trace_file_path(file_path=file_path)
    dl_tti_trace_analysis.get_dl_parameters_column()
    return dl_tti_trace_analysis.calculate_dl_no_pair_littledatanotneedpair_conuter()


def calculate_dl_muStatus_mupair_Counter(file_path, muStatus_value="MUPAIR"):
    """
    Auther:Stella
    :return:
    """
    logging.debug(file_path)
    dl_tti_trace_analysis.set_tti_trace_file_path(file_path=file_path)
    dl_tti_trace_analysis.get_dl_parameters_column()
    return dl_tti_trace_analysis.calculate_dl_mupair_conuter(muStatus_value=muStatus_value)


def calculate_dl_beamtype_Counter(file_path, beamType_value="SUBBAND"):
    """
    Auther:Stella
    :return:
    """
    logging.debug(file_path)
    dl_tti_trace_analysis.set_tti_trace_file_path(file_path=file_path)
    dl_tti_trace_analysis.get_dl_parameters_column()
    return dl_tti_trace_analysis.calculate_dl_BeamType(beamType_value=beamType_value)

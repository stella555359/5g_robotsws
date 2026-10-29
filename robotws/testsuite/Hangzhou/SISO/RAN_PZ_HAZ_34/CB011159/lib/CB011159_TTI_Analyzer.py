# -*- coding: utf-8 -*

"""
Author:         Zhang Xuewen developped for 25R1
Contact Mail:   xuewen.zhang@nokia-sbell.com
Description:    Event trace log analysis
                Column index may changes in different program, so when calling this file,
                you will need to set value for program. Currently supported versions are:  25R1
                If program is not set, it's default to 23R3
"""
import logging
from testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.python.check_csv_log import *


class TTIAnalyzer(object):
    def __init__(self, file_path):
        self.INDEX_srsState = None
        self.INDEX_beamType = None
        self.INDEX_event = 1
        self.file_path = file_path

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

    def check_beamType_in_dlPreSchedData(self, beamType="SUBBAND"):
        try:
            self.INDEX_beamType = self.get_column_value_index_from_event(
                "dlFdSchedData", "beamType"
            )
            event = get_lines_with_multiple_column_filter(
                file_path=self.file_path,
                column_list=[self.INDEX_event, self.INDEX_beamType],
                expected_list=["dlFdSchedData", beamType],
            )
            print(event[0][1])
        except LookupError:
            logging.info(
                "No dlFdSchedData event found for which beamType={}".format(beamType)
            )
            print("No dlFdSchedData event found for which beamType={}".format(beamType))
            return False
        else:
            return True

    def check_srsState_in_srsSwitchMeasData(self, srsState="WBSRS"):
        try:
            self.INDEX_srsState = self.get_column_value_index_from_event(
                "srsSwitchMeasData", "srsState"
            )
            event = get_lines_with_multiple_column_filter(
                file_path=self.file_path,
                column_list=[self.INDEX_event, self.INDEX_srsState],
                expected_list=["srsSwitchMeasData", srsState],
            )
            print(event[0][1])
        except LookupError:
            logging.info(
                "No srsSwitchMeasData event found for which srsState={}".format(
                    srsState
                )
            )
            print(
                "No srsSwitchMeasData event found for which srsState={}".format(
                    srsState
                )
            )
            return False
        else:
            return True


def get_tti_analyzer(file_path):
    return TTIAnalyzer(file_path)


def has_attribute(obj, attr_name):
    return hasattr(obj, attr_name)

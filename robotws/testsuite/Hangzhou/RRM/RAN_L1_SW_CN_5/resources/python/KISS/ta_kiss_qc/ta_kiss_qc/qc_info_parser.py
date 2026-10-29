# -*- coding: utf-8 -*-
"""
:created on: 2020-07-19

:copyright: Nokia
:author: Yao Yonna
:contact: yonna.yao@nokia-sbell.com
"""
import os
import logging
from robot.libraries.BuiltIn import BuiltIn


class CaseQCInfoParser(object):

    def __init__(self):
        self.qc_info_file_path = "/home/ute/kiss_files/private/case_qc_id/case_qc_info.md"

    def set_qc_tag_in_case(self, case_name, sw_info):
        all_case_qc_info = self._get_all_case_qc_info()
        logging.info(all_case_qc_info)
        logging.info(case_name)
        if not self.is_case_name_in_case_qc_info_file(all_case_qc_info, case_name):
            logging.info("This case not in case qc info file.")
            return
        qc_id = self.get_case_qc_id(all_case_qc_info, case_name, sw_info)
        BuiltIn().set_tags("QC_{}".format(qc_id))

    def is_case_name_in_case_qc_info_file(self, all_case_qc_info, case_name):
        for case in all_case_qc_info:
            if case.split("|")[1].strip() == case_name:
                return True
        return False

    def get_case_qc_id(self, all_case_qc_info, case_name, sw_info):
        branches = 'SBTS00' if sw_info.split("_")[2] == '9999' else sw_info.split("_")[0]
        logging.info("Branch is {}".format(branches))
        branches_index = self._get_branches_index(all_case_qc_info, branches)
        qc_id = self._get_qc_id_by_case_name(all_case_qc_info, case_name, branches_index)
        logging.info("QC id is :{}".format(qc_id))
        if not qc_id.isdigit():
            raise Exception("QC id should be digit.")
        return qc_id

    def _get_all_case_qc_info(self):
        if not os.path.exists(self.qc_info_file_path):
            raise Exception("QC ID file not exist!")
        with open(self.qc_info_file_path) as f:
            return f.readlines()

    def _get_branches_index(self, content, branches):
        head = content[0].split("|")
        for i in range(len(head)):
            if branches.upper() == head[i].strip().split("-")[0].strip():
                return i
        raise Exception("{} is not recorded in config file.".format(branches))

    def _get_qc_id_by_case_name(self, content, case_name, branches_index):
        for item in content:
            record = item.split("|")
            if record[1].strip() == case_name:
                return record[branches_index].strip()
        return 'NULL'


def set_qc_tag_in_case(case_name, sw_info):
    return CaseQCInfoParser().set_qc_tag_in_case(case_name, sw_info)

# -*- coding: utf-8 -*-
import logging
import json
import os
import re


class iolibrary():
    def write_file(self, s):
        '''
        '''
        f1 = open('write.txt', 'a')
        f1.writelines(s)
        f1.flush()
        f1.close()

    def read_file(self, filename):
        file_list = []
        with open(filename, 'r') as read_file:
            print(read_file)
            while True:
                # line = read_file.readline().strip()
                line = read_file.readline().strip()
                file_list.append(line)
                if not line:
                    break
                    pass
        for x in file_list:
            if '' in file_list:
                file_list.remove('')
        return file_list

    def get_aasell_output_info(self, data, identity_id, cellgroup_id):
        cleaned_data = data.replace("\\n", "").replace(" ", "")
        logging.debug("cleaned_data********************", cleaned_data)
        json_data = json.loads(cleaned_data)
        logging.debug("json_data***************", json_data)
        nrcell_list = json_data["cellList"]["cellInfo"]
        cellinfo_dict = {}
        cellgroupsusage_dict = {}
        for nrcell in nrcell_list:
            if nrcell["nrCellIdentity"] == identity_id:
                cellinfo_dict["bitMapOfDrbUsage"] = nrcell["bitMapOfDrbUsage"]
                cellinfo_dict["bitMapOfUeUsage"] = nrcell["bitMapOfUeUsage"]
                cellinfo_dict["dedicatedBwpsUsage"] = nrcell["dedicatedBwpsUsage"]
        cellgroupsusage_list = json_data["cellGroupsUsage"]["cellGroupUsage"]
        for cellgroupsusage in cellgroupsusage_list:
            if cellgroupsusage["cellGroupId"] == cellgroup_id:
                cellgroupsusage_dict["bitMapOfDrbUsage"] = cellgroupsusage["bitMapOfDrbUsage"]
                cellgroupsusage_dict["bitMapOfUeUsage"] = cellgroupsusage["bitMapOfUeUsage"]
        return cellinfo_dict, cellgroupsusage_dict

    def get_cellbwpld_value(self, cellbwpld_list):
        for cellbwpld_info in cellbwpld_list:
            if cellbwpld_info["cellBwpId"] != 0:
                return cellbwpld_info["cellBwpId"]

    def extract_pdl_validation_result(self, file_path):
        with open(file_path, 'r', encoding='utf-8') as file:
            content = file.read()
        # Use regex to find the dict data starting with "pdlValidationResult"
        match = re.findall(r'"pdlValidationResult":\s*({.*?})\s*,"status"', content, re.DOTALL)
        if match:
            pdl_validation_result_str = match[-1]
            pdl_validation_result = re.sub(r'"logs":\s*', '', pdl_validation_result_str, 1)
            pdl_validation_result = pdl_validation_result.replace('{', '', 1)
            pdl_validation_result_dict = json.loads(pdl_validation_result)
            pdl_validation_list = pdl_validation_result_dict["relationErrors"]
            logging.debug("pdl_validation_list length: {}".format(len(pdl_validation_list)))
            return len(pdl_validation_list)
        else:
            return None

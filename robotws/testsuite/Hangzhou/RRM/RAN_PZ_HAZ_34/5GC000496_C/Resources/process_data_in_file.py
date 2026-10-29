#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
To facilitate checkpoint verification, you can use this module to process data in different file, including:
json : currently it is used for analyse trace result from DCAP.
csv : currently it is mainly for parse sherpa log.
html: currently it is used for get the mcshark version from its download url
txt:  currently it is used for create personal profile for wireshark.
xlsx: currently it is used for read the KPI data extracted from snapshot using tool LTEPAT.exe.

"""

import json
import csv
import re
import string

from bs4 import BeautifulSoup
import requests
import os
from openpyxl import load_workbook, Workbook


def json_value_find(json_data, target_key):
    def iter_node(node_data):
        if isinstance(node_data, dict):
            key_value_iter = (x for x in node_data.items())
        elif isinstance(node_data, list):
            key_value_iter = (x for x in enumerate(node_data))
        else:
            return

        for key, value in key_value_iter:
            if key == target_key:
                yield value
            if isinstance(value, (dict, list)):
                for item in iter_node(value):
                    yield item
                # yield from iter_node(value)

    dict_data = json.loads(json_data)
    return list(iter_node(dict_data))


def json_path_find(json_data, target_key):
    def iter_node(node_data, road_step):
        if isinstance(node_data, dict):
            key_value_iter = (x for x in node_data.items())
        elif isinstance(node_data, list):
            key_value_iter = (x for x in enumerate(node_data))
        else:
            return

        for key, value in key_value_iter:
            current_path = road_step.copy()
            current_path.append(key)
            if key == target_key:
                yield current_path
            if isinstance(value, (dict, list)):
                for item in iter_node(value, current_path):
                    yield item
                # yield from iter_node(value, current_path)

    dict_data = json.loads(json_data)
    return list(iter_node(dict_data, []))


# filter a dict list.
def filter_dict_list_by_key_value(my_list, my_key, my_value):
    res_list = []
    if isinstance(my_list, list):
        for row in my_list:
            for key, value in row.items():
                if key == my_key and value == my_value:
                    res_list.append(row)
    else:
        return
    print("{} items are found for {}.".format(len(res_list), my_value))
    return res_list


def convert_string_value_to_list_value(my_list, my_key, delimiter):
    if isinstance(my_list, list):
        for row in my_list:
            for key, value in row.items():
                if key == my_key:
                    new_value = string.split(value, delimiter)
                    print("The list converted from string {} is {}".format(value, new_value))
                    value = new_value

    else:
        return
    print("The list after conversion is : {}".format(my_list))
    return my_list


def compare_values_in_dict_lists(list1, list2, my_key, distance):
    res_list1 = []
    res_list2 = []
    index = 0
    for item1 in list1:
        for key1, value1 in item1.items():
            if key1 == my_key:
                print("value for DL {} is {}.".format(my_key, value1))
                for key2, value2 in list2[index].items():
                    if key2 == my_key:
                        print("value for UL {} is {}.".format(my_key, value2))
                        print("distance is {}.".format(abs(int(value1)-int(value2))))
                        print("result is {}.".format(abs(int(value1)-int(value2)) < distance))
                        if abs(int(value1)-int(value2)) < distance:
                            res_list1.append(item1)
                            res_list2.append(list2[index])
        index += 1
    print("{} and {} items are found.".format(len(res_list1), len(res_list2)))
    return res_list1, res_list2


class DcapTrace:

    def __init__(self):
        pass

    def _get_value_of_certain_key(self, data, target_key):
        if not isinstance(data, dict):
            return []

        values = []
        for key, value in data.items():
            if key == target_key:
                values.append(value)
            else:
                subvalues = self._get_value_of_certain_key(value, target_key)
                if subvalues:
                    values += subvalues

        return values

    def get_all_log_files(self, json_file, target_key):
        with open(json_file) as f:
            data = json.load(f)
        log_result = self._get_value_of_certain_key(data, target_key)
        print(type(log_result))
        print(log_result)
        if not isinstance(log_result, list):
            return []
        log_files = []
        for item in log_result:
            logfile = []
            logfile = self._get_value_of_certain_key(item, 'path')
            log_files += logfile
        print("You have captured {} " + target_key + "log files!".format(len(log_files)))
        return log_files


class SherpaCsv:

    def __init__(self):
        pass
        self.column_names = []
        self.row_num = 0
        self.rows = []
        self.rows_with_column_name = []

    def read_column_names(self, file_path):
        headers = []
        with open(file_path) as csvfile:
            reader = csv.DictReader(csvfile)
            headers = reader.fieldnames
        self.column_names = headers
        return headers

    @staticmethod
    def get_values_of_one_column(file_path, column_name):
        c_values = []
        with open(file_path) as csvfile:
            reader = csv.DictReader(csvfile)
            c_values = [column[column_name] for column in reader]
        return c_values

    def get_values_of_all_rows(self, file_path):
        values = []
        with open(file_path) as csvfile:
            reader = csv.reader(csvfile)
            values = [row for row in reader]
        self.row_num = len(values)
        return values

    def get_values_of_all_rows_with_column_name(self, file_path):
        values = []
        with open(file_path) as csvfile:
            reader = csv.DictReader(csvfile)
            values = [column for column in reader]
        self.rows_with_column_name = values
        return values

    def filter_file_by_column_value(self, file_path, column_name, column_value):
        self.get_values_of_all_rows_with_column_name(file_path)
        rows = filter_dict_list_by_key_value(self.rows_with_column_name, column_name, column_value)
        return rows

    @staticmethod
    def filter_rows_from_two_containers_by_column_value(rows1, rows2, column_to_compare):
        res_rows1 = []
        res_rows2 = []
        for row1 in rows1:
            for key1, value1 in row1.items():
                for row2 in rows2:
                    for key2, value2 in row2.items():
                        if key1 == column_to_compare and key2 == column_to_compare and value1 == value2:
                            print("For column of {},the values are {} and {}".format(
                                column_to_compare, value1, value2))
                            res_rows1.append(row1)
                            res_rows2.append(row2)
                            break
        # there can be more than one matches for one entry, here break is to exit the loop once the first match is got.
        print("{} and {} items are filtered.".format(len(res_rows1), len(res_rows2)))
        return res_rows1, res_rows2

    @staticmethod
    def compare_values_in_container_column(rows1, rows2, column_to_compare, delimiter, indexes1, indexes2):
        # converted_rows1 = convert_string_value_to_list_value(rows1, column_to_compare, delimiter)
        # converted_rows2 = convert_string_value_to_list_value(rows2, column_to_compare, delimiter)
        res_rows1 = []
        res_rows2 = []
        index = zip(indexes1, indexes2)
        print("The indexes are {}.".format(index))
        row_index = 0
        for row1 in rows1:
            for key1, value1 in row1.items():
                if key1 == column_to_compare:
                    value1_list = string.split(value1, delimiter)
                    print("The value of {} in DL is {}".format(column_to_compare, value1_list))
                    for key2, value2 in rows2[row_index].items():
                        if key2 == column_to_compare:
                            value2_list = string.split(value2, delimiter)
                            print("The value of {} in UL is {}".format(column_to_compare, value2_list))
                            cnt = 0
                            for item in index:
                                print("Values of item {} are {} and {}".format(
                                    item, value1_list[item[0]], value2_list[item[1]]))
                                if value1_list[item[0]] == value2_list[item[1]]:
                                    print("The {} item are: {} and {}".format(
                                        cnt, value1_list[item[0]], value2_list[item[1]]))
                                    cnt += 1
                            if cnt == len(index):
                                res_rows1.append(row1)
                                res_rows2.append(rows2[row_index])
            row_index += 1
        print("{} and {} items are filtered.". format(len(res_rows1), len(res_rows2)))
        return res_rows1, res_rows2

    def verify_ul_dl_schedule(self, file_path):
        all_rows = self.get_values_of_all_rows(file_path)
        headers = all_rows[0]
        all_rows.pop(0)
        DL_PDCCH = []
        # UL_PDCCH = []
        # DL_PDSCH = []
        # DL_PDSCH_Error = []
        DL_PDCCH_cnt = 0
        UL_PDCCH_cnt = 0
        DL_PDSCH_cnt = 0
        DL_PDSCH_Error_cnt = 0
        TTI_index = headers.index("AIR TTI")
        SEQ_index = headers.index("SEQ")
        TEXT_index = headers.index("TEXT")
        MSGID_index = headers.index("MSGID")
        RNTI_index = headers.index("RNTI")
        filtered_DL_PDCCH = []
        filtered_UL_PDCCH = []
        filtered_DL_PDSCH = []

        for row in all_rows:
            if row[MSGID_index] == "Dl PdcchSendReq(29)" and row[RNTI_index] != "0xffff":
                filtered_DL_PDCCH.append(row)
            elif row[MSGID_index] == "Dl PdcchSendReq(31)":
                filtered_UL_PDCCH.append(row)
            elif row[MSGID_index] == "Dl PdschSendReq(30)":
                filtered_DL_PDSCH.append(row)
        print("{}, {} and {} items are filtered for each.".format(
            len(filtered_DL_PDCCH), len(filtered_UL_PDCCH), len(filtered_DL_PDSCH)))

        def convert_text_content_to_dict(text=None):
            res_dict = {}
            index = 0
            # print('The text content in string is : {}'.format(text))
            for item in text.split(';'):
                key = item.split('=')[0] if len(item.split('=')) == 2 else 'col' + str(index)
                value = item.split('=')[1] if len(item.split('=')) == 2 else item
                res_dict[key] = value
            # print(res_dict)
            return res_dict

        for dl_row in filtered_DL_PDCCH:
            dl_row_text = convert_text_content_to_dict(dl_row[TEXT_index])
            # print("The corset for current dl pdcch is {}.".format(dl_row_text['coreSet']))
            # print("The start symbol for current dl pdcch is {}.".format(dl_row_text['startPDCCHSymbol']))
            for ul_row in filtered_UL_PDCCH:
                if (dl_row[TTI_index] == ul_row[TTI_index]
                        and abs(int(dl_row[SEQ_index])-int(ul_row[SEQ_index])) < 1023):
                    ul_row_text = convert_text_content_to_dict(ul_row[TEXT_index])
                    # print("The corset for current ul pdcch is {}.".format(ul_row_text['coreSet']))
                    # print("The start symbol for current ul pdcch is {}.".format(ul_row_text['startPDCCHSymbol']))

                    if (dl_row_text['coreSet'] == ul_row_text['coreSet']
                            and dl_row_text['startPDCCHSymbol'] == ul_row_text['startPDCCHSymbol']):
                        DL_PDCCH.append(dl_row)
                        # UL_PDCCH.append(ul_row)
                        DL_PDCCH_cnt += 1
                        UL_PDCCH_cnt += 1
                        break

        for pdcch_row in DL_PDCCH:
            for pdsch_row in filtered_DL_PDSCH:
                if (pdcch_row[TTI_index] == pdsch_row[TTI_index]
                        and abs(int(pdcch_row[SEQ_index]) - int(pdsch_row[SEQ_index])) < 1023):
                    pdsch_row_text = convert_text_content_to_dict(pdsch_row[TEXT_index])
                    # print("The start symbol for dl pdsch is {}.".format(pdsch_row_text['startPDSCHSymbol']))
                    if pdsch_row_text["startPDSCHSymbol"] == "1":
                        # DL_PDSCH.append(pdsch_row)
                        DL_PDSCH_cnt += 1
                        break
                    else:
                        # DL_PDSCH_Error.append(pdsch_row)
                        DL_PDSCH_Error_cnt += 1

        # print("{}, {}, {} and {} items are found for each finally.".format(
        #     len(DL_PDCCH), len(UL_PDCCH), len(DL_PDSCH), len(DL_PDSCH_Error)))
        # return len(DL_PDCCH), len(UL_PDCCH), len(DL_PDSCH), len(DL_PDSCH_Error)
        print("{}, {}, {} and {} items are found for each finally.".format(
            DL_PDCCH_cnt, UL_PDCCH_cnt, DL_PDSCH_cnt, DL_PDSCH_Error_cnt))
        return DL_PDCCH_cnt, UL_PDCCH_cnt, DL_PDSCH_cnt, DL_PDSCH_Error_cnt


class HtmlParser:
    def __init__(self):
        pass
        self.content = ""
        self.USER_AGENT = 'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) \
        Chrome/45.0.2454.101 Safari/537.36'
        self.HEADERS = {'User-Agent': self.USER_AGENT, 'Content-type': 'application/json', 'Accept': '*/*'}

    def _get_content(self, url):
        resp = requests.get(url=url, headers=self.HEADERS)
        if resp.status_code != 200:
            raise Exception("Error: page is not available!")
        self.content = resp.text

    def get_hyper_links(self, url):
        self._get_content(url)
        # print(self.content)
        soup = BeautifulSoup(self.content, 'html.parser')
        # print(".......................................")
        # print(soup)
        links = []
        for link in soup.find_all('a'):
            links.append(link["href"])
        return links

    def get_download_link_by_ext(self, url, ext):
        links = self.get_hyper_links(url)
        # print(links)
        download_link = []
        pattern = r"." + re.escape(ext) + r"$"
        # print(pattern)
        for link in links:
            print(link)
            ret = re.search(pattern, link)
            if ret:
                download_link.append(link)
                # print(download_link)
        return download_link


class TextWriter:
    def __init__(self):
        pass
        self.file = ""
        self.line_num = 0

    def write_lines_to_file(self, file_path, file_name, lines):
        if not os.path.isdir(file_path):
            os.mkdir(file_path)
        self.file = os.path.join(file_path, file_name)
        with open(self.file, 'w') as f:
            for item in lines:
                print >> f, item
                self.line_num = self.line_num + 1

    @staticmethod
    def write_dicts_to_json_file(file_path, file_name, data):
        string_content = json.dumps(data)
        f = open(file_path + "/" + file_name, 'w')
        f.write(string_content)
        f.close()


class ExcelReader:
    def __init__(self, ):
        pass
        self.file = ""
        self.sheets = []

    def _load_file(self, excel_file):
        self.file = excel_file
        workbook = load_workbook(filename=excel_file, data_only=True)
        self.sheets = workbook.sheetnames
        return workbook

    def _get_sheet_by_name(self, excel_file, sheet_name):
        workbook = self._load_file(excel_file)
        worksheet = workbook[sheet_name]
        return worksheet

    def get_column_values_by_column_name(self, excel_file, sheet_name, column_name):
        worksheet = self._get_sheet_by_name(excel_file, sheet_name)
        try:
            rows = list(worksheet.values)
            col_idx = rows[0].index(column_name)
        except ValueError:
            raise ValueError("'{}' header not found in sheet '{}'".
                             format(column_name, sheet_name))
        col_values = dict(enumerate([row[col_idx] for row in worksheet.values]))
        print('Col values with corresponding indices are:\n'.format([x for x in col_values.items()]))
        return [row[col_idx] for row in worksheet.values]

    def get_column_indices_by_column_names(self, excel_file, sheet_name, column_names):
        col_indices = []
        worksheet = self._get_sheet_by_name(excel_file, sheet_name)
        rows = list(worksheet.values)
        for name in column_names:
            col_indices.append(rows[0].index(name))
        return col_indices

    def get_row_indices_by_values_in_a_column(self, excel_file, sheet_name, column_name, cell_values):
        col_values = self.get_column_values_by_column_name(excel_file, sheet_name, column_name)
        # print("col values are: {}".format(col_values))
        row_indices = []
        for index, value in enumerate(col_values):
            if value in cell_values:
                row_indices.append(index)
        return row_indices

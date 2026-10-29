# -*- coding: utf-8 -*-
"""
:created on: 03-30-2021

:copyright: Nokia
:author: Chen jin Emily
:contact: jin_emily.chen@nokia-sbell.com.cn
"""

import logging
import re
import os
import io
import csv
from .exception import KissFileException


class CsvHandler(object):
    """find value in .csv file
    """

    def __init__(self, file_path, title=[]):
        self._log = logging.getLogger(__name__)
        self._log.setLevel(logging.DEBUG)
        self.csv_file = file_path
        self.csv_raw_list = []
        # for valid line list
        self.valid_line_list = []
        # index title line keyword
        self.title = title
        # title name list
        self.title_list = []

    def _read_raw_list(self):
        with open(self.csv_file, 'r') as file_object:
            content = csv.reader(file_object)
            for con in content:
                self.csv_raw_list.append(con)

    def null_list(self, check_list):
        """to judge if a list is null
        """
        return (check_list == []) or len(set(check_list)) == 1

    def get_valid_line_lists(self, filter=None):
        """to get the valid line lists
        """
        title_line_num = 0
        for line_index in range(len(self.csv_raw_list)):
            if self.title in self.csv_raw_list[line_index]:
                self.title_list = self.csv_raw_list[line_index]
                title_line_num = line_index
                break
        for line_index in range(title_line_num + 1, len(self.csv_raw_list)):
            line_info = self.csv_raw_list[line_index]
            if self.null_list(line_info):
                continue
            if len(self.title_list) != len(line_info):
                continue
            if filter:
                judge = filter
                ado = ['&', '|']
                cmp = ['<=', '>=', '==', '!=', '<', '>']
                con_cmp = '|'.join(cmp)
                pat = re.compile(r'\w+=\w+')
                equal_cons = pat.findall(judge)
                for old in equal_cons:
                    new = old.replace('=', '==')
                    judge = re.sub(old, new, judge)
                multi_cond = re.split(r'[&|\|]', judge)
                title_list = []
                for cond in multi_cond:
                    for c in cmp:
                        if c in cond:
                            title_list.append(cond.split(c)[0].strip('('))
                t_list = list(set(title_list))

                for t in t_list:
                    get_value = line_info[self.title_list.index(t)]
                    if not get_value:
                        get_value = 'EMPTY'
                    judge = judge.replace(t, get_value)

                multi_cond = re.split(r'[&|\|]', judge)
                replace_items = []
                for con in multi_cond:
                    key, value = re.split(con_cmp, con)
                    cmp = re.search(con_cmp, con).group()
                    s_key = key.strip(')').strip('(')
                    s_value = value.strip(')').strip('(')
                    try:
                        s_value = float(s_value)
                        continue
                    except Exception as err:
                        m_key = s_key.replace(s_key, '"%s"' % s_key)
                        m_value = s_value.replace(s_value, '"%s"' % s_value)
                    old = cmp.join([s_key, s_value])
                    new = cmp.join([m_key, m_value])
                    replace_items.append((old, new))
                for r in replace_items:
                    judge = judge.replace(r[0], r[1])

                judge = eval(judge)
                if judge:
                    self.valid_line_list.append(line_info)
                    continue

            else:
                self.valid_line_list.append(line_info)

    def get_csv_columns_list(self, *cared_title, **kwargs):
        """to get the columns with the cared titles
        """
        filter = kwargs.get("filter", None)
        calculator = kwargs.get("calculator", None)
        csv_columns_list = []
        self.get_valid_line_lists(filter)
        for title in cared_title:
            if title not in self.title_list:
                raise KissFileException("Title '%s' cann't be find." % title)
            else:
                column_pos = self.title_list.index(title)
                column_list = []
                for valid in self.valid_line_list:
                    value = valid[column_pos].strip()
                    if value == '':
                        continue
                    if re.match(r'^\d+$', value):
                        value = int(value)
                    elif re.match(r'^\d+\.\d+$', value):
                        value = float(value)
                    column_list.append(value)
                csv_columns_list.append(column_list)
        result_list = [csv_columns_list, csv_columns_list[0]
                       ][len(csv_columns_list) == 1]
        if calculator:
            result_list = self.aggregate_rows(result_list, calculator)
        return result_list

    def write_csv(self, file_path, content_list):
        par_dir = os.path.dirname(file_path)
        if not os.path.exists(par_dir):
            os.makedirs(par_dir)

        with open(file_path, 'w') as file_object:
            csv_w = csv.writer(file_object)
            for con in content_list:
                csv_w.writerow(con)

    def handle_col_and_save_in_new_col(self, col_name, new_col_name):
        self._read_raw_list()
        raw_list = self.csv_raw_list
        if col_name in raw_list[0]:
            index = raw_list[0].index(col_name)
        else:
            raise Exception("not find %s" % col_name)
        raw_list[0].append(new_col_name)
        for i in range(1, len(raw_list)):
            try:
                source = raw_list[i][index]
            except Exception as err:
                continue
            try:
                b = bin(int(source[:2], 16))[2:]
                b = b.zfill(8)
                target = int(b[1:5], 2)

            except Exception as err:
                target = ''
                pass
            raw_list[i].append(target)
        return raw_list

    def _is_number(self, data):
        try:
            float(data)
            return True
        except ValueError:
            return False

    def aggregate_rows(self, datas, calculator=None):
        results = []
        for each_row in datas:
            if self._is_number(each_row):
                results.append(each_row)
                continue
        return_value = []
        if calculator == "sum":
            return_value = sum(results)
        elif calculator == "avg":
            return_value = sum(results) / len(results)
        elif calculator == "max":
            return_value = max(results)
        return return_value

    def get_ues_tbsize_by_sfn(
            self, time, ratio, rnti_ignore, filter, target_file):
        """
        """
        time = int(time)
        self._read_raw_list()
        flines = self.csv_raw_list
        title = flines[0]
        sfn_pos = title.index('sfn')
        pstart = 1
        vstart = int(flines[1][sfn_pos])
        vstart = vstart + int(0.1 * 1)
        vstop = vstart + int(102.4 * time)
        if vstop > 1024:
            mod = int(vstop / 1024)
            vstop = vstop % 1024
        else:
            mod = 1
        self._log.info("start/stop value is %s/%s" % (vstart, vstop))

        valid_list = []
        for i in range(2, len(flines)):
            if flines[i][sfn_pos] == str(
                    vstart) and flines[i - 1][sfn_pos] == str(int(vstart) - 1):
                pstart = i
            if flines[i][sfn_pos] == str(
                    vstop) and flines[i - 1][sfn_pos] == str(int(vstop) - 1):
                pstop = i
                valid_list.append((pstart, pstop))
        if len(valid_list) == 0:
            raise Exception(
                "not find block info sfn from %s~%s" %
                (vstart, vstop))
        self._log.info("find all match lines as follow: %s" % valid_list)
        pstop = valid_list[mod - 1][1]
        pstart = valid_list[0][0]
        self._log.info("chose start/stop line is: %s/%s" % (pstart, pstop))

        # filter by rnti value 0, 65535
        valid_list = []
        rnti_list = []
        rnti_pos = title.index('rnti')
        for value in flines[pstart:pstop]:
            if value[rnti_pos] not in ['0', '65535']:
                valid_list.append(value)
                rnti_list.append(int(value[rnti_pos]))
        self._log.info("lines number(no rnti 0, 65535) is %s" %
                       len(valid_list))
        ignore_list = []
        if rnti_ignore:
            ignore_list += [int(ig) for ig in rnti_ignore.split(',')]

        # calculate rnti's ratio, if less than expect value, it will be delete
        ue_list = []
        for value in set(rnti_list):
            calc_ratio = float(rnti_list.count(value)) / float(len(rnti_list))
            if calc_ratio < float(ratio):
                ignore_list.append(value)
                self._log.info("rnti value %s's ratio %s < %s, so it will be delete later." %
                               (value, calc_ratio, ratio))
            else:
                ue_list.append(value)
        if ignore_list:
            self._log.info(
                "drop date which rnti's value is : %s" %
                ignore_list)
        self.csv_raw_list = [title]
        for value in valid_list:
            if int(value[rnti_pos]) not in ignore_list:
                self.csv_raw_list.append(value)
        self._log.info("after del nouse rnti, the line number is %s" %
                       len(self.csv_raw_list))

        if filter:
            self._log.info("start to filter %s" % filter)
            self.get_valid_line_lists(filter)
        else:
            self.valid_line_list = self.csv_raw_list[1:]
        self._log.info("after filter, the line number is %s" %
                       len(self.valid_line_list))
        new = [title]
        new += self.valid_line_list
        self.write_csv(target_file, new)
        return ue_list


if __name__ == '__main__':
    pass

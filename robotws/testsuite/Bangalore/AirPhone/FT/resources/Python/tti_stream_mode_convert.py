# -*- coding: utf-8 -*-
import os


class TtiStreamModeConvert(object):
    def __init__(self, csv_name, output_name, filters=None):
        self.csv_name = csv_name
        self.output_name = output_name
        self.filters = filters

        self.all_column_names = list()
        self.all_msg_names = list()
        self.all_matched_msg_items = dict()
        self.part_index = list()
        self.related_column_names = list()

        self.column_name_line = self._get_column_names_line()
        print(self.column_name_line)
        if os.path.exists(self.output_name):
            os.remove(self.output_name)

    def run(self):
        print('--------Start Tti Stream Convert...')
        if self.filters:
            self.get_related_column_names()
            self._append_to_file(','.join(self.related_column_names))
        else:
            self.get_all_column_names()
            self._append_to_file(','.join(self.all_column_names))
        self.get_all_msg_names()
        self.get_matched_msg_items()
        self.get_different_part_index()
        self.format_tti_with_stream_mode()
        print('--------End Tti Stream Convert...')

    def get_related_column_names(self):
        self.related_column_names.extend(['type', 'timeStamp', 'sfn', 'slot', 'rnti', 'physCellId', 'ackNack'])
        print(self.related_column_names)
        items = self.column_name_line.split(',')
        for item in items[1:]:
            if '.' in item:
                msg, column_name = item.split('.', 1)[0], item.split('.', 1)[1]
                if msg in self.filters and column_name not in self.related_column_names:
                    self.related_column_names.append(column_name)

    def get_all_column_names(self):
        self.all_column_names.extend(['type', 'timeStamp', 'sfn', 'slot', 'rnti', 'physCellId'])
        print("VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV")
        items = self.column_name_line.split(',')
        for item in items[1:]:
            column_name = item.split('.', 1)[-1]
            if column_name not in self.all_column_names:
                self.all_column_names.append(column_name)

    def get_all_msg_names(self):
        self.all_msg_names.append('basic')
        items = self.column_name_line.split(',')
        for item in items:
            if '.' in item:
                msg_name = item.split('.')[0]
                if msg_name not in self.all_msg_names:
                    self.all_msg_names.append(msg_name)

    def get_matched_msg_items(self):
        self.all_matched_msg_items = {msg: list() for msg in self.all_msg_names}
        items = self.column_name_line.split(',')
        for item in items:
            if '.' not in item:
                self.all_matched_msg_items.get('basic').append(item)
            else:
                msg, sub_item = item.split('.', 1)[0], item.split('.', 1)[1]
                self.all_matched_msg_items.get(msg).append(sub_item)

    def get_different_part_index(self):
        for msg in self.all_msg_names:
            if len(self.part_index) == 0:
                self.part_index.append(len(self.all_matched_msg_items.get(msg)))
            else:
                self.part_index.append(self.part_index[-1] + len(self.all_matched_msg_items.get(msg)))

    def format_tti_with_stream_mode(self):
        with open(self.csv_name, 'r') as f:
            for line in f:
                if len(line.strip()) == 0 or line.strip().startswith('timeStamp'):
                    continue
                items = self._get_line_items(line)
                basic_keys = self.all_matched_msg_items.get('basic')
                basic_values = items[:self.part_index[0]]
                basic_items = {key: val for key, val in zip(basic_keys, basic_values)}
                # create new msg and its content
                for i in range(1, len(self.all_msg_names)):
                    if self.filters:
                        new_msg_items = {key: '' for key in self.related_column_names}
                    else:
                        new_msg_items = {key: '' for key in self.all_column_names}
                    new_msg_items.update(basic_items)

                    msg = self.all_msg_names[i]
                    if self.filters and msg not in self.filters:
                        continue
                    new_msg_items['type'] = msg

                    msg_keys = self.all_matched_msg_items.get(msg)
                    msg_values = items[self.part_index[i - 1]:self.part_index[i]]
                    if list(set(msg_values)) == ['']:
                        continue  # if all values equal to 0, means no such msg currently
                    msg_items = {key: val for key, val in zip(msg_keys, msg_values)}
                    new_msg_items.update(msg_items)

                    if self.filters:
                        new_msg_content = ','.join([new_msg_items.get(key) for key in self.related_column_names])
                    else:
                        new_msg_content = ','.join([new_msg_items.get(key) for key in self.all_column_names])

                    self._append_to_file(new_msg_content)

    def _get_line_items(self, line):
        items = line.split(',')
        i, ret = 0, list()
        while i < len(items):
            tmp = items[i].strip('\n')
            if '"' in items[i]:
                for j in range(i + 1, len(items)):
                    tmp = tmp + ', ' + items[j].strip('\n')
                    if '"' in items[j]:
                        i = j
                        break
            ret.append(tmp)
            i += 1
        assert len(ret) == self.part_index[-1]
        return ret

    def _get_column_names_line(self):
        with open(self.csv_name, 'r') as f:
            for line in f:
                if line.strip().startswith('timeStamp'):
                    return line.strip()
        return None

    def _append_to_file(self, content):
        with open(self.output_name, 'a+') as f:
            f.writelines(content + '\n')


def format_tti_stream_mode_with_filters(input_file_name, output_file_name, filters=None):
    """
    filters: str, dlFdSchedData;dlFlowControlData;ulIntraDlToUlDrxSyncDlData
    """
#    filters = filters.split(';')
#    filters ="dlFdSchedData"
    obj = TtiStreamModeConvert(input_file_name, output_file_name, filters)
    obj.run()


def format_tti_stream_mode_no_filters(input_file_name, output_file_name):
    print(input_file_name)
    print(output_file_name)
    obj = TtiStreamModeConvert(input_file_name, output_file_name)
    obj.run()


if __name__ == '__main__':
    path = r"C:\comWork\robottest\Examples\slot ue check\TtiFiles\output_ul.csv"
    out_name = r"C:\comWork\robottest\Examples\slot ue check\TtiFiles\format_stream_ul.csv"
    format_tti_stream_mode_no_filters(path, out_name)

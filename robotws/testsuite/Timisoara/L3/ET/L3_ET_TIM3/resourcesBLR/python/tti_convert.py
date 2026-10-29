# -*- coding: utf-8 -*-
import os


class TtiConvert(object):
    def __init__(self, path, output_path, filters=None):
        self.column_names = list()
        self.tti_path = path
        self.output_path = output_path
        self.filters = filters

        self.column_names.extend(['type', 'sfn', 'slot', 'rnti', 'physCellId', 'subcellId'])

        if os.path.exists(self.output_path):
            os.remove(self.output_path)

    def run(self):
        print('--------Start Tti Convert...')
        self._get_all_column_names()
        self._format_msg()
        print('--------End Tti Convert...')

    def _get_all_column_names(self):
        with open(self.tti_path, 'r') as f:
            for line in f:
                if not line.strip():
                    continue
                items = line.strip().split(',')
                msg_type = items[0].split(':')[0]
                items[0] = items[0].split(':')[1].strip()
                if self.filters:
                    if msg_type in self.filters:
                        for i in range(len(items) // 2):
                            if items[i] not in self.column_names:
                                self.column_names.append(items[i])
                else:
                    for i in range(len(items) // 2):
                        if items[i] not in self.column_names:
                            self.column_names.append(items[i])
        self._append_to_file(','.join(self.column_names))

    def _format_msg(self):
        with open(self.tti_path, 'r') as f:
            for line in f:
                if not line.strip():
                    continue
                init_msg_items = self._init_msg_items()
                msg_items = self._get_single_msg_items(line, init_msg_items)
                if msg_items:
                    msg_content = ','.join([msg_items.get(key) for key in self.column_names])
                    self._append_to_file(msg_content)

    def _get_single_msg_items(self, line, init_msg_items):
        items = line.strip().split(',')
        msg_type = items[0].split(':')[0]
        items[0] = items[0].split(':')[1].strip()
        init_msg_items['type'] = msg_type
        if self.filters and msg_type not in self.filters:
            return None

        index = 0
        for i in range(len(items)):
            if items[i].isdigit():
                index = i
                break
        keys, values = items[:index], items[index:]

        for key, val in zip(keys, values):
            if not init_msg_items.get(key, None):
                init_msg_items[key] = val

        return init_msg_items

    def _init_msg_items(self):
        items = {key: '' for key in self.column_names}
        return items

    def _append_to_file(self, content):
        with open(self.output_path, 'a+') as f:
            f.writelines(content + '\n')


def format_tti_with_filters(path, output_path, filters=None):
    """
    filters: str, dlFdSchedData;dlFlowControlData;ulIntraDlToUlDrxSyncDlData
    """
    filters = filters.split(';')
    obj = TtiConvert(path, output_path, filters)
    obj.run()


def format_tti_no_filters(path, output_path):
    obj = TtiConvert(path, output_path)
    obj.run()


if __name__ == '__main__':
    filters = 'dlFdSchedData'
    filename = r"C:\comWork\robottest\Examples\slot ue check\TtiFiles\L2TtiTrace_EventsSnapshot.bin.01.dl.csv"
    out_name = r"C:\comWork\robottest\Examples\slot ue check\TtiFiles\with_filters.csv"
    format_tti_with_filters(filename, out_name, filters)
    out_name = r"C:\comWork\robottest\Examples\slot ue check\TtiFiles\no_filters.csv"
    format_tti_no_filters(filename, out_name)

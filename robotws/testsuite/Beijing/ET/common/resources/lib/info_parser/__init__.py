# -*- coding: utf-8 -*-
"""
2022/06/08 first version by @author: sheng.1.ye@nokia.com
    The InfoParser class is used to parse info from txt file with indent format.
2022/06/17 refactoring, by Ye Sheng
2022/06/20 support CSV parser for TTI log, by Ye Sheng
2022/06/29 add function description, by Ye Sheng
2022/06/30 update format of item_list, by Ye Sheng
2022/07/01 item_list support expression for any parser as well as csv parser, by Ye Sheng
2022/07/06 support filter_expression for any parser as well as csv parser, by Ye Sheng
2022/07/06 fix problem of match_id does not increase, by Ye Sheng
2022/07/14 add silent option for get_info, by Ye Sheng
2022/07/27 add pos_info option for get_info, to return match position info, by Ye Sheng
2023/04/06 support making 'group' for values, by Ye Sheng
2023/04/10 support 'find' syntax to match expected value, by Ye Sheng
"""

import os
import glob
import re
import unittest

try:
    from .info_reader import InfoReader
    from .csv_info_parser_mixin import CsvInfoParserMixin
except ImportError:
    from info_reader import InfoReader
    from csv_info_parser_mixin import CsvInfoParserMixin


class FailInfo:
    NO_FILE_FOUND = r"No file found for path={path}, filename={filename}"
    READ_FILE_FAIL = r"Get no information from: filelist={file_list}"
    GET_INFO_FAIL = r"Get info from file fail:\n: {error_info}"


class InfoParser(CsvInfoParserMixin):
    def __init__(self, filename='', path='', file_type=None, time_stamp_str='Arrival Time', debug=False):
        """
        Parse info from txt based file
        :param filename: filename or pattern, e.g. pcap.txt,  pcap*.txt,  logs*/pcap*.txt
        :param path: filepath or pattern, e.g  /home/logs/,  /home/test/logs*/
        :param file_type: 'scf', 'egate', 'emil', 'csv' or None(auto detect)
        :param time_stamp_str: string used to parse timestamp, default is 'Arrival Time'
        """
        self.debug = debug
        self.time_stamp_str = time_stamp_str
        self.file_type = file_type
        self.file_list = self._get_file_list(path, filename)
        self.txt_list = self._get_merged_txt_list()
        self.silent = False

    @staticmethod
    def fail_if(condition, info, **param):
        if condition:
            raise Exception(info.format(**param))

    def _get_file_list(self, path, filename):
        file_list = [filename for filename in glob.glob(os.path.join(path, filename))]
        self.fail_if(not file_list, FailInfo.NO_FILE_FOUND, path=path, filename=filename)
        return file_list

    def _get_merged_txt_list(self):
        if self.file_list[0].endswith('csv'):
            self.file_type = 'csv'
            return None
        txt_list = [InfoReader.read_file(f, self.file_type) for f in self.file_list]
        self.fail_if(not txt_list, FailInfo.READ_FILE_FAIL, file_list=self.file_list)
        return self._merge_txt_list(txt_list)

    def _merge_txt_list(self, txt_list):
        merged_txt_list = [t for txt in txt_list for t in re.split(r"\n\r?(?:\n\r?)+", txt) if t]
        if len(self.file_list) > 1:
            merged_txt_list = sorted(set(merged_txt_list), key=lambda x: x.split(self.time_stamp_str + ':')[-1])
        return merged_txt_list

    def get_info(self, item_list, filter_pattern='', filter_expression='', count=0,
                 auto_formatter=True, formatter_func=None, silent=False, item_id_list=None, pos_info=None):
        """
        Extract item info from txt files.
        :param item_list: a list of str item to search from text file as key.
            e.g. ['abc()', 'abc:', 'abc', 'abc[]', 'abc[3]', 'xyz->abc', 'abc[] as abc_list', 'abc find \\d+']
            'abc()': will match values enclosed by (), e.g. "abc ip (10.1.2.3)" will get "10.1.2.3"
            'abc:': will match values after : and outside (), e.g. "abc: ip (10.1.2.3)" will get "ip"
            'abc': will match everything after abc, e.g. "abc ip (10.1.2.3)" will get "ip (10.1.2.3)"
            'abc find \\d+': will match first value match \\d+, e.g. "abc ip (10.1.2.3)" will get 10
            'abc[]': will collect all items matched by 'abc',
                  e.g. with "abc ip(10.1.2.3)" and "abc ip(10.1.2.4)" will get ["ip(10.1.2.3)", "ip(10.1.2.4)"]
            'abc[3]': will collect the 4th element matching 'abc'
            'xyz->abc': will get abc which is under range of xyz
            'xyz~~~abc': will get abc which is 3 lines after xyz
            'abc[] as abc_list': will get a list of abc, but use 'abc_list' as output name
            '=abc+def as xyz': will evaluate expression after "="
        :param filter_pattern: a regular expression to filter message.(FOR non-csv parser ONLY)
            e.g. "SgNBModificationRequired|UEContextRelease" will filter message match this regular expression
        :param filter_expression: a python expression to filter message
            e.g. "abc > 0 and def == 8", will evaluate expression as filter
        :param count: number of items to return, 0 means unlimited
        :param auto_formatter: default=True, will format each output items automatically or not.
        :param formatter_func: user-specific formatter function for output, e.g.
            formatter_func={'abc': func1 } -- for name 'abc', formatted_value = func1(value)
            formatter_func={'*': func1} -- for all name, formatted_value = func(value)
        :param silent: if silent is False and count does not meet expectation, will raise exception
        :param item_id_list: if exists, will only check item ids in this list
        :param pos_info: for non-csv type, if pos_info is a list, the match position info will be filled in pos_info.
        :return: a list of dict, which contains matched items and value, value is None if not matched
            [{'item_id': 3, 'match_id': 0, 'abc': '10.1.2.3'},
             {'item_id': 4, 'match_id': 1, 'abc': '10.1.2.4'}]
        """
        self.silent = silent
        if self.file_type == 'csv':
            return self._csv_get_info(item_list, filter_expression, count, auto_formatter, formatter_func)
        else:
            return self._get_info(item_list, filter_expression, count, auto_formatter, formatter_func, filter_pattern,
                                  item_id_list, pos_info)

    def _get_info(self, item_list, filter_expression, count, auto_formatter, formatter_func, filter_pattern,
                  item_id_list, pos_info):
        pattern_list, name_dict, addon_name_map = self._build_pattern_from_item_list(item_list)
        result = []
        if type(pos_info) is list:
            pos_info.clear()
        for ret in self._match_txt_list(filter_pattern, pattern_list, result, item_id_list):
            ret, ret_pos, ret_group = self._format_output(ret, auto_formatter, formatter_func, name_dict)
            if ret_group:
                self._update_group_info(ret, ret_group)
            if addon_name_map:
                self._apply_expression(ret, addon_name_map)
            if filter_expression and not self._match_filter_expression(ret, filter_expression):
                continue
            result.append(ret)
            if type(pos_info) is list:
                pos_info.append(ret_pos)
            if len(result) >= count > 0:
                break
        self._validate_match_result(len(result), count, filter_pattern, filter_expression)
        return result

    def _update_group_info(self, ret, ret_group):
        for k, v in list(ret.items()):
            if ret_group.get(k, None):
                r = ret.setdefault('group', {})
                if type(v) is not list:
                    for item in ret_group[k][1:]:
                        r = r.setdefault(item, {})
                    r[k] = v
                else:
                    single = False
                    for n, i in enumerate(v):
                        r = ret.setdefault('group', {})
                        if ret_group[k][n]:
                            single = ret_group[k][n][0]
                            for item in ret_group[k][n][1:]:
                                r = r.setdefault(item, {})
                            if single:
                                if k not in r:
                                    r[k] = i
                            else:
                                r.setdefault(k, []).append(i)
                    if single:
                        ret[k] = v[0]

    def _apply_filter_expression(self, result, filter_expression):
        if filter_expression:
            return [item for item in result if self._match_filter_expression(item, filter_expression)]
        else:
            return result

    @staticmethod
    def _match_filter_expression(item, filter_expression):
        locals().update(item)
        try:
            return eval(filter_expression) if filter_expression else True
        except Exception:
            return False

    def _match_txt_list(self, filter_pattern, pattern_list, result, item_id_list=None):
        for item_id, txt in enumerate(self.txt_list):
            if not item_id_list or item_id in item_id_list:
                result_dict = {"match_id": len(result), "item_id": item_id}
                if self._match_filter(filter_pattern, txt, result_dict):
                    self._match_items(txt, pattern_list, result_dict)
                    yield result_dict

    def _validate_match_result(self, match_num, count, filter_pattern, filter_expression):
        if not self.silent and (match_num < count or match_num == 0):
            info = "%s:\n match fail, expect: %s, found: %d" % (self.file_list, count or 'any', match_num)
            if filter_pattern:
                info += "\nfilter_pattern=%s" % filter_pattern
            if filter_expression:
                info += "\nfilter_expression=%s" % filter_expression
            self.fail_if(info, FailInfo.GET_INFO_FAIL, error_info=info)

    @staticmethod
    def _match_filter(filter_pattern, txt, result_dict):
        if filter_pattern:
            new_filter_pattern = r"(?P<filter_match>%s)" % filter_pattern
            m = re.search(new_filter_pattern, txt)
            if not m:
                return False
            result_dict.update({k: (v, m.start(k), m.end(k), None) for k, v in m.groupdict().items()} if m else {})
            # result_dict.update(m.groupdict())
        return True

    @classmethod
    def _match_items(cls, txt, pattern_list, result_dict):
        old_txt = txt
        for pattern, repeater, name, range_pattern in pattern_list:
            range_info = []
            txt = cls._get_txt_in_range(range_pattern, old_txt, range_info)
            result_dict.update({name: None})
            if repeater:
                result_dict.update(cls._match_item_list(pattern, repeater, txt, range_info))
            else:
                result_dict.update(cls._match_item_single(pattern, txt, range_info))

    @classmethod
    def _match_item_single(cls, pattern, txt, range_info):
        if not range_info:
            m = re.search(pattern, txt)
            return {k: (v, m.start(k), m.end(k), None) for k, v in m.groupdict().items()} if m else {}
        else:
            result_dict = cls._match_item_collect_list(pattern, txt, range_info, single=True)
            cls._match_item_slice_list('[]', result_dict)
            return result_dict

            # return {k: (v, m.start(k), m.end(k), cls._get_group_list(m.start(k), range_info))
            #         for k, v in m.groupdict().items()} if m else {}

    @classmethod
    def _get_group_list(cls, s, range_info, single=False):
        group_list = [single]
        for range_dict in range_info:
            for r, v_list in range_dict.items():
                for start, end in v_list:
                    if start <= s <= end:
                        group_list.append(r)
                        break  # found
                else:
                    continue
                break  # found
            else:
                return None
        return group_list

    @classmethod
    def _match_item_list(cls, pattern, repeater, txt, range_info):
        result_dict = cls._match_item_collect_list(pattern, txt, range_info)
        cls._match_item_slice_list(repeater, result_dict)
        return result_dict

    @classmethod
    def _match_item_slice_list(cls, repeater, result_dict):
        for k, v in list(result_dict.items()):
            try:
                result_dict[k] = eval("v" + (repeater if repeater != "[]" else ""))
            except Exception:
                result_dict[k] = None

    @classmethod
    def _match_item_collect_list(cls, pattern, txt, range_info, single=False):
        result_dict = {}
        for m in re.finditer(pattern, txt):
            for k, v in m.groupdict().items():
                if not range_info:
                    result_dict.setdefault(k, []).append((v, m.start(k), m.end(k), None))
                else:
                    result_dict.setdefault(k, []).append((v, m.start(k), m.end(k),
                                                          cls._get_group_list(m.start(k), range_info, single)))
        return result_dict

    def _build_pattern_from_item_list(self, items):
        pattern_list = []
        name_dict = {'TIME_STAMP': self.time_stamp_str}
        addon_name_map = self._build_addon_name_map(items)
        for item in items:
            if item[0] != '=':
                pattern_list.append(self._build_pattern_for_item(item, name_dict))
        return pattern_list, name_dict, addon_name_map

    def _build_pattern_for_item(self, item, name_dict):
        old_name, pattern, repeater, value_type, range_pattern, find_pattern = self._parse_item(item)
        new_name = self._make_name_mapping(old_name, name_dict)
        pattern = self._format_n_line_pattern(pattern)
        pattern = self._build_pattern_by_value_type(new_name, pattern, value_type, find_pattern)
        return pattern, repeater, new_name, range_pattern

    @staticmethod
    def _make_name_mapping(old_name, name_dict):
        name = "v%d" % len(name_dict)
        name_dict[name] = old_name
        return name

    @staticmethod
    def _format_n_line_pattern(pattern):
        pattern = re.sub('~+', r'.*\g<0>', pattern).replace('~', '(\\n.*?)')
        return pattern

    def _build_pattern_by_value_type(self, name, pattern, value_type, find_pattern):
        if value_type == ':':  # take value after : and before () or \n: ":value(xxx)" or ":value\n"
            return r'(?:\b|\W){0}(?:\b|\W)(.*:[ \t]*(?P<{1}>[^\(\)]*?)([ \t]*\(.*?\)|\r|\n|$))?'.format(pattern, name)
        elif value_type == '()':  # take value inside (): "xxx (value)"
            return r'(?:\b|\W){0}(?:\b|\W)(.*\((?P<{1}>.*?)\))?'.format(pattern, name)
        elif pattern == self.time_stamp_str:
            return r'%s:.*(?P<TIME_STAMP>\d\d:\d\d:\d\d\.\d\d\d)' % self.time_stamp_str
        elif find_pattern:  # take value match find regex:   "xxx  ...{regex matches value}..."
            if '(' in find_pattern and ')' in find_pattern:
                find_pattern = find_pattern.replace('(', '(?P<{0}>', 1).format(name)
            else:
                find_pattern = ('(?P<{0}>' + find_pattern + ')').format(name)
            return r'(?:\b|\W){0}(?:\b|\W)(.*?{1}.*?(\r|\n|$))?'.format(pattern, find_pattern)
        else:   # value_type == '':  # take value before \n: " value\n"
            return r'(?:\b|\W){0}(?:\b|\W)([ \t]*(?P<{1}>.*?)[ \t]*(\r|\n|$))?'.format(pattern, name)

    @classmethod
    def _parse_item(cls, item):
        m = re.match('(?:(.*)->)?(.*?)(?: find (.*?))?(?: as (.*))?$', item)
        range_pattern = m.group(1)
        item, repeater = cls._get_pattern_and_repeater(m.group(2))
        pattern, value_type = cls._parse_value_type(item)
        find_pattern = m.group(3)
        old_name = m.group(4) or pattern.strip() or range_pattern.strip().split('>')[-1]
        return old_name, pattern, repeater, value_type, range_pattern, find_pattern

    @staticmethod
    def _parse_value_type(item):
        if item.endswith('()'):
            return item[:-2] or ' ', '()'
        elif item.endswith(':'):
            return item[:-1] or ' ', ':'
        else:
            return item or ' ', ''

    @staticmethod
    def _get_pattern_and_repeater(pattern):
        m = re.search(r'(.*?)(\[[\-\d:]*?\]|\{\})$', pattern)
        if m:
            return m.group(1), m.group(2)
        else:
            return pattern, ''

    def _format_output(self, ret, auto_formatter, formatter_func, name_dict):
        ret = self._translate_output_name(name_dict, ret)
        ret, ret_pos, ret_group = self._split_pos_number(ret)
        if auto_formatter:
            self._auto_formatter(ret, formatter_func)
        return ret, ret_pos, ret_group

    def _split_pos_number(self, ret):
        ret_new, ret_pos, ret_group = {}, {}, {}
        for k, v in ret.items():
            if type(v) is tuple:
                ret_group[k] = v[3]
                ret_pos[k] = v[1:3]
                ret_new[k] = v[0]
            elif type(v) is list:
                ret_group[k] = [i[3] if type(i) is tuple else None for i in v]
                ret_pos[k] = [i[1:3] if type(i) is tuple else None for i in v]
                ret_new[k] = [i[0] if type(i) is tuple else i for i in v]
            else:
                ret_group[k] = None
                ret_pos[k] = None
                ret_new[k] = v
        return ret_new, ret_pos, ret_group

    @staticmethod
    def _translate_output_name(name_dict, ret):
        return {name_dict.get(name, name): value for name, value in ret.items()} if name_dict else ret

    @classmethod
    def _get_txt_in_range(cls, range_pattern, txt, range_info):
        if range_pattern:
            for single_range in range_pattern.split('->'):
                txt = cls._get_txt_in_single_range(single_range, txt, range_info)
        return txt

    @classmethod
    def _get_txt_in_single_range_old(cls, range_pattern, txt):
        pattern = r'(\n *)' + range_pattern + r'([ :].*)?(?P<range>(\1 {4}.*)*)'
        result_list = []
        for m in re.finditer(pattern, txt):
            leading_spaces = m.group(1)
            result_list.append(m.groupdict()['range'].replace(leading_spaces, "\n") + "\n")
        return "".join(result_list)

    @classmethod
    def _get_txt_in_single_range(cls, range_pattern, txt, range_info):
        pattern = r'(\n *)' + range_pattern + r'()([ :].*)?(?P<range>(\1 {4}.*)*)'
        end = 0
        range_dict = {}
        for m in re.finditer(pattern, txt):
            if m.group(2) != '':
                key = int(m.group(2)) if m.group(2).isdigit() else m.group(2)
                range_dict.setdefault(key, []).append((m.start('range'), m.end('range')))
            txt = txt[:end] + 'Y' * (m.start('range') - end) + txt[m.start('range'):]
            # txt = txt[:end] + 'X\n' + txt[m.start('range'):]
            end = m.end('range')+1
        txt = txt[:end] + 'Y' * (len(txt) - end)
        if range_dict:
            range_info.append(range_dict)
        return txt

    def _auto_formatter(self, item_dict, func_dict=None):
        self._format_timestamp(item_dict)
        self._format_items(item_dict, func_dict)
        return item_dict

    def _format_items(self, item_dict, func_dict):
        for k, v in item_dict.items():
            if type(v) is list:
                for i, value in enumerate(v):
                    item_dict[k][i] = self._convert_format(k, value, func_dict)
            else:
                item_dict[k] = self._convert_format(k, v, func_dict)

    @staticmethod
    def _build_addon_name_map(item_list):
        return dict([(i[1:] + ' as ' + i[1:]).split(' as ')[:2] for i in item_list if i[0] == '='])

    @classmethod
    def _convert_format(cls, key, value, func_dict):
        if value is None:
            return None
        elif cls._has_func(key, func_dict):
            return cls._apply_func(key, value, func_dict)
        else:
            return cls._apply_default_func(value)

    @staticmethod
    def _has_func(key, func_dict):
        return func_dict and (key in func_dict or '*' in func_dict)

    @staticmethod
    def _apply_func(key, value, func_dict):
        func = func_dict[key] if key in func_dict else func_dict['*']
        if callable(func):
            return func(value)

    @staticmethod
    def _apply_default_func(value):
        if type(value) is str:
            if value.isdigit():
                return int(value)
            elif value.startswith('0x') or value.startswith('0X'):
                return int(value, 16)
        return value

    @staticmethod
    def _apply_expression(item, addon_name_map):
        if addon_name_map:
            locals().update(item)
            for exp, k in addon_name_map.items():
                try:
                    locals()[k] = item[k] = eval(exp)
                except Exception as e:
                    item[k] = 'Error(%s)' % e

    def _format_timestamp(self, item_dict):
        if item_dict.get(self.time_stamp_str, None):
            item_dict['time_ms'] = self._convert_time_to_ms(item_dict[self.time_stamp_str])
        elif self.time_stamp_str in item_dict:
            item_dict['time_ms'] = 0

    @staticmethod
    def _convert_time_to_ms(time_str):
        match = re.search(r'(\d\d):(\d\d):(\d\d)[:.](\d\d\d)', time_str)
        if match:
            h, m, s, ms = map(int, match.groups()[0:4])
            return (((h * 60) + m) * 60 + s) * 1000 + ms
        return -1


if __name__ == '__main__':
    import ut
    unittest.main(module=ut)

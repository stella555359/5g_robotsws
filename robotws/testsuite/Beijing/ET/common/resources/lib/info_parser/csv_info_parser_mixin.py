# -*- coding: utf-8 -*-
"""
2022/06/20 first version by @author: sheng.1.ye@nokia.com
    This file focus on csv info parsing, serve as part of info_parser.InfoParser class.
2022/07/02 rename by adding Mixin suffix, by Ye Sheng
2022/07/02 support item_id for filter_pattern, by Ye Sheng
"""

import unittest
import csv
import ast


class CsvInfoParserMixin:

    def _external_members(self):
        # Note: this function will never run, following lines are only for IDE convenience.
        self._validate_match_result = None
        self._convert_format = None
        self.file_list = None
        self._format_timestamp = None
        self.debug = None
        self._apply_expression = None
        self._build_addon_name_map = None

    def _csv_get_info(self, item_list, filter_expression, count=0, auto_formatter=True, formatter_func=None):
        self._init_csv_parameters(item_list, filter_expression, auto_formatter, formatter_func)
        ret = self._match_csv_lines(count)
        self._validate_match_result(len(ret), count, '', filter_expression)
        return ret

    def _init_csv_parameters(self, item_list, filter_expression, auto_formatter, formatter_func):
        self.field_name_map = self._build_field_name_map(item_list)
        self.addon_name_map = self._build_addon_name_map(item_list)
        self.filter_expression = filter_expression
        self.auto_formatter = auto_formatter
        self.formatter_func = formatter_func
        self.all_related_fields = self._get_all_related_fields()
        self.filter_related_fields = self._get_filter_related_fields()

    def _get_all_related_fields(self):
        fields = list(self.field_name_map.values()) + list(self._parse_var_names(self.filter_expression))
        for code in self.addon_name_map.keys():
            fields.extend(list(self._parse_var_names(code)))
        return fields

    def _get_filter_related_fields(self):
        filter_fields = list(self._parse_var_names(self.filter_expression))
        if self._filter_use_expression(filter_fields):
            filter_fields = self.all_related_fields
        return filter_fields

    def _filter_use_expression(self, filter_fields):
        return any(f in self.addon_name_map.values() for f in filter_fields)

    @staticmethod
    def _build_field_name_map(item_list):
        return dict([(i + ' as ' + i).split(' as ')[:2] for i in item_list if i[0] != '='])

    def _match_csv_lines(self, count):
        ret = []
        for item_id, item in enumerate(self._read_csv_line(self.file_list[0])):
            self._convert_csv_item_for_filter(item)
            if self._match_csv_filter(item, item_id):
                result_dict = {'match_id': len(ret), 'item_id': item_id}
                self._fill_csv_item(item, result_dict)
                ret.append(result_dict)
                if len(ret) >= count > 0:
                    break
        return ret

    def _read_csv_line(self, filename):
        self.txt_list = []
        with open(filename) as rf:
            reader = csv.reader(rf)
            first_line = next(reader)
            header_line = [self.field_name_map.get(name, name) for name in first_line]
            for item in reader:
                if self.debug:
                    self.txt_list.append("%s\n%s" % (first_line, item))
                yield dict(zip(header_line, item))

    def _convert_csv_item_for_filter(self, item):
        if self.auto_formatter:
            self._format_csv_item_fields(item, self.filter_related_fields)

        if self.filter_related_fields is self.all_related_fields:
            self._apply_expression(item, self.addon_name_map)

    def _format_csv_item_fields(self, item, fields):
        item.update({k: self._convert_format(k, v, self.formatter_func) for k, v in item.items() if k in fields})

    def _match_csv_filter(self, item, item_id):
        locals().update(item)
        locals()['item_id'] = item_id
        try:
            return eval(self.filter_expression) if self.filter_expression else True
        except Exception:
            return False

    def _fill_csv_item(self, item, result_dict):
        self._convert_csv_item_for_output(item)
        self._collect_csv_item_for_output(item, result_dict)

    def _convert_csv_item_for_output(self, item):
        if self.filter_related_fields is not self.all_related_fields:
            if self.auto_formatter:
                self._format_csv_item_fields(item, self.all_related_fields)
            self._apply_expression(item, self.addon_name_map)

    def _collect_csv_item_for_output(self, item, result_dict):
        if self.field_name_map:
            result_dict.update({k: item.get(k, None) for k in self.field_name_map.values()})
        if self.addon_name_map:
            result_dict.update({k: item.get(k, None) for k in self.addon_name_map.values()})
        if self.auto_formatter:
            self._format_timestamp(result_dict)

    @staticmethod
    def _parse_var_names(code):
        st = ast.parse(code)
        for node in ast.walk(st):
            if type(node) is ast.Name:
                yield node.id


if __name__ == '__main__':
    import ut
    unittest.main(module=ut)

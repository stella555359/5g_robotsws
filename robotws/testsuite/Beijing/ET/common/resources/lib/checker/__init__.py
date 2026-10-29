# -*- coding: utf-8 -*-
"""
2022/06/02 first version by @author: sheng.1.ye@nokia-sbell.com
           This is the base class for all Checkers
2022/07/08 add case_warning, add kwargs for case_pass, case_invalid, by Ye Sheng
2022/07/19 add assert_true and assert_false, and counters for assert functions, by Ye Sheng
2022/08/09 add algorithm mixin, by Ye Sheng
2022/08/23 add function get_mapping_value, by Ye Sheng
2022/08/24 add value to assert_equal and assert_unequal counters, by Ye Sheng
2023/03/31 add pep_check, by Ye Sheng
2023/04/11 add classify and classify_counter, by Ye Sheng
2023/05/08 add stats_param as case_pass parameters, by Ye Sheng
"""
from ..exception_et import *
from ..logger_et import LoggingEt
from .algorithm_mixin import AlgorithmMixin
from collections import defaultdict, OrderedDict
import inspect
import sys
SHOW_COUNTER_MAX = 100


def file_pep8_check(file_list=None):
    """
    check PEP8 for files in file_list, if file_list is blank, the caller file will be checked.
    return information if there is warning/error, otherwise return None
    """
    from io import StringIO
    from .pep8 import StyleGuide
    if not file_list:
        file_list = [inspect.stack()[2][1]]
    pep8style = StyleGuide(paths=file_list, config_file=os.path.join(os.path.dirname(__file__), 'pep8.cfg'))
    sys_stdout, sys.stdout = sys.stdout, StringIO()  # redirect sys.stdout to string
    report = pep8style.check_files()
    output_str, sys.stdout = sys.stdout.getvalue(), sys_stdout  # recover sys.stdout
    statistics = report.get_statistics()
    return ("Errors/Warnings in PEP8 check:\n%s\n" % output_str,
            "Count\tError/Warning\n%s\n" % ("\n".join(statistics))) if statistics else None


class Checker(AlgorithmMixin):

    def __init__(self, log_path, log_level=None):
        self.log_path = log_path
        self.logger = LoggingEt(path=log_path).log()
        self.set_log_level(log_level)
        self.counters = defaultdict(int)
        self.classify_counter = defaultdict(lambda: defaultdict(int))
        self.check_pep8()

    def set_log_level(self, level):
        if level is not None:
            for hdlr in self.logger.handlers:
                hdlr.setLevel(level)

    def case_pass(self, stats_param=None):
        if self.counters:
            counter_list = sorted(self.counters.items())
            self.logger.info("Counters: \n" + "\n".join("%s: %d" % (k, v) for k, v in counter_list[:SHOW_COUNTER_MAX]))
            if len(counter_list) > SHOW_COUNTER_MAX:
                self.logger.debug(
                    "More Counters: \n" + "\n".join("%s: %d" % (k, v) for k, v in counter_list[SHOW_COUNTER_MAX:]))

        if self.classify_counter:
            self.logger.debug("\n" + self._get_classify_stats())

        if stats_param:
            missed_stats = self.get_missed_classify_counter(stats_param)
            if missed_stats:
                self.case_fail("stats missing: %s" % missed_stats)
        self.logger.info('Pass')

    def get_missed_classify_counter(self, stats_param):
        for item in stats_param:
            for k, v in self.classify_counter.items():
                if list(item) == list(k[:len(item)]):
                    break
            else:
                return item
        return None

    def _get_classify_stats(self):
        stats_tree = {}
        for k, v in self.classify_counter.items():
            node = stats_tree
            for item in k:
                node = node.setdefault(item, {})
        out = []
        self._make_classify_stats(tuple(), stats_tree, '', out)
        return self._make_tree_text(out)

    def _make_classify_stats(self, root, tree, prefix, out):
        for n, (k, v) in enumerate(tree.items()):
            new_root = root + (k,)
            out.append(prefix + str(k))
            if new_root in self.classify_counter:
                out[-1] += ': ' + str(list(self.classify_counter[new_root].keys()))
            if v:
                self._make_classify_stats(new_root, v, prefix + '    ', out)

    def _make_tree_text(self, out):
        tree_text = []
        column_symbol = {}
        for item in reversed(out):
            level = (len(item) - len(item.lstrip()))//4
            line_text = ''
            for i in range(level):
                line_text += column_symbol.get(i, '     ')
            line_text += ' |___' + item.strip()
            for i in list(column_symbol.keys()):
                if i > level:
                    column_symbol.pop(i)
            column_symbol[level] = ' |   '
            tree_text.insert(0, line_text)
        return "\n".join(['classified counters'] + tree_text)

    def case_fail(self, info='', **kwargs):
        self.logger.info("[Fail] %s" % info.format(**kwargs))
        raise CaseFail(info)

    def case_warning(self, info='', max_count=5, **kwargs):
        if self.counters['WARNING: ' + info.replace("\n", "; ")] < max_count:
            self.logger.warning(info.format(**kwargs))
        self.counters['WARNING: ' + info.replace("\n", "; ")] += 1

    def case_invalid(self, info='', **kwargs):
        self.logger.info("[Invalid] %s" % info.format(**kwargs))
        raise CaseInvalid(info)

    @staticmethod
    def get_hashable_value(value):
        try:
            hash(value)
            return value
        except TypeError:
            return str(value)

    def assert_equal(self, value_name, expected_value, real_value, additional_info='', action='fail',
                     classify=None, classify_value=None):
        if expected_value != real_value:
            info = "%s unmatch -- expected: %s, real: %s" % (
                value_name, expected_value, real_value)
            if additional_info:
                info += "\nNote: " + additional_info
            if action == 'fail':
                self.case_fail(info)
            elif action == 'invalid':
                self.case_invalid(info)
            return False
        if classify:
            self.classify_counter[tuple(classify)][self.get_hashable_value(classify_value or real_value)] += 1
        else:
            self.counters["ASSERT_EQUAL '%s' = %s -- PASS COUNT" % (value_name, repr(expected_value))] += 1
        return True

    def assert_unequal(self, value_name, expected_value, real_value, additional_info='', action='fail',
                       classify=None, classify_value=None):
        if expected_value == real_value:
            info = "%s unmatch -- expected: not %s, real: %s" % (
                value_name, expected_value, real_value)
            if additional_info:
                info += "\nNote: " + additional_info
            if action == 'fail':
                self.case_fail(info)
            elif action == 'invalid':
                self.case_invalid(info)
            return False
        if classify:
            self.classify_counter[tuple(classify)][self.get_hashable_value(classify_value or real_value)] += 1
        else:
            self.counters["ASSERT_UNEQUAL '%s' != %s -- PASS COUNT" % (value_name, repr(expected_value))] += 1
        return True

    def assert_true(self, value_name, value, additional_info='', action='fail', classify=None, classify_value=None):
        if not value:
            info = "%s is %s" % (value_name, value)
            if additional_info:
                info += "\nNote: " + additional_info
            if action == 'fail':
                self.case_fail(info)
            elif action == 'invalid':
                self.case_invalid(info)
            return False
        if classify:
            self.classify_counter[tuple(classify)][self.get_hashable_value(classify_value or 'AssertTrue')] += 1
        else:
            self.counters["ASSERT_TRUE '%s' -- PASS COUNT" % value_name.split(':')[0]] += 1
        return True

    def assert_false(self, value_name, value, additional_info='', action='fail', classify=None, classify_value=None):
        if value:
            info = "%s is %s" % (value_name, value)
            if additional_info:
                info += "\nNote: " + additional_info
            if action == 'fail':
                self.case_fail(info)
            elif action == 'invalid':
                self.case_invalid(info)
            return False
        if classify:
            self.classify_counter[tuple(classify)][self.get_hashable_value(classify_value or 'AssertFalse')] += 1
        else:
            self.counters["ASSERT_FALSE '%s' -- PASS COUNT" % value_name] += 1
        return True

    def get_mapping_value(self, mapping_table, variables, default=None, allow_none=False):
        if not allow_none and any(value is None for value in variables.values()):
            self.case_invalid(info="Parameter value is None: %s " % [k for k, v in variables.items() if v is None])
        if type(mapping_table) is dict and mapping_table:
            for condition, value in mapping_table.items():
                if type(value) is not dict:
                    return mapping_table
                if eval(condition, variables):
                    ret = self.get_mapping_value(value, variables, default='UNMATCHED')
                    if ret != 'UNMATCHED':
                        return ret
            return default
        return mapping_table

    def check_pep8(self):
        pep8_result = file_pep8_check(file_list=[inspect.stack()[2][1]])
        if pep8_result:
            self.case_warning(pep8_result[1])
            print(pep8_result[0])

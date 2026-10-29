# -*- coding: utf-8 -*-
"""
:author: He Winnie
:contact: winnie.he@nokia-sbell.com
:maintainer: winnie.he@nokia-sbell.com
:contact: winnie.he@nokia-sbell.com
"""
import sys
import re
import os
import traceback
import collections
import time
import json
from datetime import datetime, timezone, timedelta
from taf.sbts.oam.coam.admin import admin
from taf.transport.ssh import ssh
from taf.gnb.oam.coam.cu import cu
from taf.gnb.oam.coam.vdu import vdu
from abc import ABCMeta, abstractmethod
from ute_testline_configuration.loader import Loader
from robot.api import logger
from robot.libraries.BuiltIn import BuiltIn
from taf.internal.aliasing import aliasing_scope
import xml.etree.ElementTree as ET
from .utils import get_all_values_by_key, get_value_by_unique_key
from .logger import simple_counter_logger, table_counter_logger
from dateutil import parser  # 在文件头部导入


CounterRuleIndex = collections.namedtuple(
    'CounterRuleIndex', ["distname", "counterid", "origin_str", "comment", "counter_rule_origin_str"])


class CounterRule(object):
    def __init__(self, counterrule):
        self.counterid_re = r"M\d+C\d*|[A-Z][A-Z0-9_]+"
        self.counterid_re_withx = f"{self.counterid_re}X?"
        self.aggregation_re = "(sum|min|max|avg|latest|has_no_0_value)"
        self.formula_re_with_x = r"(\(?((M\d+C\d*X?|[A-Z][A-Z0-9_]+)|([+\-*/%\s])|(\d*)|([\(\)]))+\)?)+"
        self.formula_re = r"(\(?((M\d+C\d*|[A-Z][A-Z0-9_]+)|([+\-*/%\s])|(\d*)|([\(\)]))+\)?)+"
        if isinstance(counterrule,
                      str) and counterrule != "" and counterrule is not None:
            file_exist = os.path.exists(counterrule)
            if file_exist:
                fp = open(counterrule, 'r')
                self.counter_rule_content = fp.read().splitlines()
            else:
                raise Exception(f'Counter rule file not found: {counterrule}')
        elif isinstance(counterrule, list):
            logger.info(counterrule)
            self.counter_rule_content = counterrule
        elif counterrule == "" or counterrule is None:
            raise Exception(
                f'Please input the correct rule type, dict or json file: {counterrule}')
        else:
            raise Exception(
                f'Please input the correct rule type, dict or json file: {counterrule}')

    @property
    def get_counter_rule(self):
        return self.counter_rule

    def _parse_range_counter(self, counter_origin_str, id_or_rule):
        logger.info(f"convert {counter_origin_str}")
        ret = counter_origin_str

        if "to" in counter_origin_str:
            for counter_str in re.findall(r"M\d+C\d*\s*to\s*M\d+C\d*|[A-Z][A-Z0-9_]+\s*to\s*[A-Z][A-Z0-9_]+",
                                          counter_origin_str):
                allcounter = []
                counter_range = counter_str.split("to")
                start = int(counter_range[0].split("C")[-1].lstrip().rstrip())
                end = int(counter_range[1].split("C")[-1].lstrip().rstrip())
                counter_prefix = counter_range[0].split("C")[0]
                counter_zfill_length = len(counter_range[1].split("C")[-1])
                if start >= end:
                    raise Exception(
                        f"Please check your counter rule, should be 'Counter: xxx to xxx; wrong format: {counter_str}")

                allcounter = [f"{counter_prefix}C{str(i).zfill(counter_zfill_length)}" for i in range(start, end + 1)]
                counter_origin_str = counter_origin_str.replace(counter_str, "[{}]".format(",".join(allcounter)))
            if id_or_rule == "counter":
                return counter_origin_str.replace("],[", ",").replace("[", "").replace("]", "")
            else:
                return counter_origin_str

        else:
            return counter_origin_str

    def parse(self):
        self.counter_rule = {}

        def clean_string(s):
            return s.rstrip().strip()

        # Distname: MDI1; Counter: xxx; Counter rule: xxx;
        for counter_rule_str in self.counter_rule_content:
            if counter_rule_str.strip() == "":
                continue
            field_map = {
                "distname": "all",
                "counter": None,
                "counter rule": None,
                "comment": "",
                "counter_rule_origin_str": None}
            for counter_info_origin in counter_rule_str.split(";"):
                counter_info = counter_info_origin.rstrip().strip()
                if counter_info == "":
                    continue
                info = counter_info.split(":")
                if len(info) != 2:
                    raise Exception(f"Please check your counter rule, should be 'Distname: MDI1; Counter: xxx; " +
                                    f"Counter rule: xxx; wrong format: {counter_rule_str}")
                key = clean_string(info[0]).lower()
                value = clean_string(info[1])

                if key.lower() in ["counter", "counter rule"]:
                    if key.lower() == "counter rule":
                        counter_rule_origin_str = value
                    value = self._parse_range_counter(value, key.lower())
                if key.lower() in field_map.keys():
                    field_map[key.lower()] = value
                else:
                    raise Exception(f"Please check your counter rule, should be 'Distname: MDI1; Counter: xxx; " +
                                    f"Counter rule: xxx;, wrong format: {counter_rule_str}")
            if field_map["counter"] is not None:
                k = CounterRuleIndex(distname=field_map["distname"],
                                     counterid=field_map["counter"],
                                     origin_str=counter_rule_str,
                                     comment=field_map["comment"],
                                     counter_rule_origin_str=counter_rule_origin_str)
                if k not in self.counter_rule.keys():
                    self.counter_rule[k] = []
                self.counter_rule[k].append(field_map["counter rule"])
            else:
                raise Exception(f"Please check your counter rule, should be 'Distname: MDI1; Counter: xxx; " +
                                f"Counter rule: xxx;, wrong format: {counter_rule_str}")
            counters_in_rule = self._parse_range_counter(k.counter_rule_origin_str, "counter rule")
            counters_in_rule = re.findall(r"M\d+C\d*|[A-Z][A-Z0-9_]+", counters_in_rule)
            logger.info(f"counters in rule: {counters_in_rule}")
            if len(counters_in_rule) == 0:
                raise Exception(f"Please check your counter rule, no counters in rule formule:" +
                                f"wrong format: {k.counter_rule_origin_str}")
            else:
                for c in counters_in_rule:
                    if c not in k.counterid:
                        raise Exception(f"Please check your counter rule, counter {c} not in counterid {k.counterid}")
        for c in self.counter_rule.keys():
            logger.info(f"counter_rule {c} {self.counter_rule[c]}")

    def get_counter_distname(self):
        self.distname_counterids = {}
        for k in self.counter_rule.keys():
            if k.distname not in self.distname_counterids.keys():
                self.distname_counterids[k.distname] = []
            counterids = k.counterid.split(",")
            for counterid in counterids:
                if counterid not in self.distname_counterids[k.distname]:
                    self.distname_counterids[k.distname].append(counterid)
        return self.distname_counterids

    def isdistname_match(self, filter_distname, distname):
        for distname_part in filter_distname.split("/"):
            if "[" in distname:
                if "'" + distname_part + "'" not in distname:
                    return False
            else:
                if distname_part not in distname:
                    return False
                else:
                    has_object = False
                    for objdistname in distname.split("/"):
                        if distname_part == objdistname:
                            has_object = True
                            break
                    if not has_object:
                        return False
        return True

    # counterid_values: {"distname": {"mcid": {"timestamp": "value"}}}
    def filter_counter_values(self, counterid_distname, counterinfo_values, use_latest=False):
        counterid_values = {}
        counterid_timestamp_values = {}
        timestamp = []
        logger.info(f"filter_counter_values {counterid_distname} {counterinfo_values}")
        for filter_distname in counterid_distname.distname.split(","):
            filter_counters = counterid_distname.counterid.split(",")
            for distname, counterinfo in counterinfo_values.items():
                for filter_counter in filter_counters:
                    logger.info(f"Filtering counter {filter_counter} for distname {filter_distname} \
                                {self.isdistname_match(filter_distname, distname)}")
                    if filter_distname.lower() == "all" or self.isdistname_match(filter_distname, distname):
                        if filter_counter in counterinfo.keys():
                            timestamp_value = counterinfo[filter_counter]
                            if filter_counter not in counterid_timestamp_values.keys():
                                counterid_timestamp_values[filter_counter] = dict(
                                    [[time, value] for time, value in timestamp_value.items() if value != ""])
                            else:
                                for time, value in timestamp_value.items():
                                    counterid_timestamp_values[filter_counter][time] += value
                            timestamp.append(
                                list(counterid_timestamp_values[filter_counter].keys()))
        filter_timestamp = []
        for t in timestamp:
            if len(filter_timestamp) == 0:
                filter_timestamp = t
            else:
                filter_timestamp = filter_timestamp and t
        for counterid, timestamp_value in counterid_timestamp_values.items():
            counterid_values[counterid] = [
                v for t, v in timestamp_value.items() if t in filter_timestamp]
            # counterid_values[counterid] = [0,1,2]
            # logger.info(f"Added counter {counterid} {counterid_values[counterid]}")
            if use_latest and len(counterid_values[counterid]) > 0:
                counterid_values[counterid] = [counterid_values[counterid][-1]]
                # for test
                # counterid_values[counterid] = [0,1,1]
        return counterid_values

    def _compare_sub_formula_with_aggrega(self,
                                          calculate_rule,
                                          delta_formulas,
                                          before_counterid_values,
                                          after_counterid_values):
        for formula_g in delta_formulas:
            formula = formula_g[0]
            if "delta_value" in formula_g[0]:
                formula = formula.replace("delta_value(", "")
            elif "delta_precent" in formula_g[0]:
                formula = formula.replace("delta_precent(", "")
            formula = formula[0:-1]  # to remove the delta )
            sub_calculate_rule_before = self.check_with_aggregation(
                formula, before_counterid_values)
            sub_calculate_rule_after = self.check_with_aggregation(
                formula, after_counterid_values)
            if "delta_value" in formula_g[0]:
                result = (float(sub_calculate_rule_after) -
                          float(sub_calculate_rule_before))
            elif "delta_precent" in formula_g[0]:
                result = (float(sub_calculate_rule_after) -
                          float(sub_calculate_rule_before)) / float(sub_calculate_rule_before) * 100

            calculate_rule = calculate_rule.replace(formula_g[0], str(result))
        return calculate_rule

    def _compare_sub_formula_without_aggrega(self,
                                             calculate_rule,
                                             delta_formulas,
                                             before_counterid_values,
                                             after_counterid_values):
        for formula_g in delta_formulas:
            formula = formula_g[0]
            if "delta_value" in formula_g[0]:
                formula = formula.replace("delta_value(", "")
            elif "delta_precent" in formula_g[0]:
                formula = formula.replace("delta_precent(", "")

            # remove delta_value() for formula
            formula = "".join(formula.rsplit(")", 1))
            # to convert after formula to formulaB
            formula_b = formula
            for mcid in re.findall(r"M\d+C\d*|[A-Z][A-Z0-9_]+", formula_b):
                if "delta_value" in formula_g[0]:
                    formula_b = formula_b.replace(mcid, f"({mcid}X-{mcid})")
                elif "delta_precent" in formula_g[0]:
                    formula_b = formula_b.replace(
                        mcid, f"({mcid}X-{mcid})*100/({mcid}X)")
                before_counterid_values[f"{mcid}X"] = after_counterid_values[mcid]

            result = self.check_without_aggregation(formula_b,
                                                    before_counterid_values)

            calculate_rule = calculate_rule.replace(formula_g[0], result)

        return calculate_rule

    def sync_before_after_values(self, before_counter_value, after_counter_value):
        fixed_before_counter_value = {}
        fixed_after_counter_value = {}
        for counterid, values in before_counter_value.items():
            if after_counter_value[counterid]:
                delta_len = len(after_counter_value[counterid]) - len(values)
                if delta_len > 0:
                    fixed_before_counter_value[counterid] = values
                    fixed_after_counter_value[counterid] = after_counter_value[counterid][:len(values)]
                elif delta_len < 0:
                    fixed_before_counter_value[counterid] = values[:len(after_counter_value[counterid])]
                    fixed_after_counter_value[counterid] = after_counter_value[counterid]
                else:
                    fixed_before_counter_value[counterid] = values
                    fixed_after_counter_value[counterid] = after_counter_value[counterid]
        return fixed_before_counter_value, fixed_after_counter_value

    def compare(self, before_counter_value, after_counter_value):
        self.check_result = {}
        for counterid_distname, rules in self.counter_rule.items():
            before_counterid_values = self.filter_counter_values(
                counterid_distname, before_counter_value)
            after_counterid_values = self.filter_counter_values(
                counterid_distname, after_counter_value)
            before_counterid_values, after_counterid_values = self.sync_before_after_values(before_counterid_values,
                                                                                            after_counterid_values)
            for rule in rules:
                try:
                    k = counterid_distname.origin_str
                    logger.info(k)
                    if "delta_value" in rule or "delta_precent" in rule:
                        logger.info("compare check start")
                    else:
                        result = None
                        continue
                    calculate_rule = rule
                    aggrega_delta_formulas = re.findall(r"(delta_((value)|(precent))\(" +
                                                        self.aggregation_re + r"\(" + self.formula_re + r"\)\))",
                                                        calculate_rule)
                    if len(aggrega_delta_formulas) > 0:
                        calculate_rule = self._compare_sub_formula_with_aggrega(
                            calculate_rule=calculate_rule,
                            delta_formulas=aggrega_delta_formulas,
                            before_counterid_values=before_counterid_values,
                            after_counterid_values=after_counterid_values)
                    noaggrega_delta_formulas = re.findall(r"((delta_((value)|(precent))\(" +
                                                          self.formula_re + r"\))+[><=!\s]+[a-z0-9A-Z_]+)",
                                                          calculate_rule)
                    if len(noaggrega_delta_formulas) > 0:
                        calculate_rule = self._compare_sub_formula_without_aggrega(
                            calculate_rule=calculate_rule,
                            delta_formulas=noaggrega_delta_formulas,
                            before_counterid_values=before_counterid_values,
                            after_counterid_values=after_counterid_values)
                    logger.debug(
                        f"rule {rule}, calculate_rule {calculate_rule}")
                    result = eval(calculate_rule)

                except Exception as e:
                    logger.error(
                        f"rule {rule} check found error: {traceback.format_exc()}")
                finally:
                    self.check_result[k] = result
        return self.check_result

    def check_with_aggregation(self, rule, counterid_values):
        calculate_rule = rule
        for formula_g in self.with_aggregation_formulate_handle(
                calculate_rule):
            # to remove the sum, min, max and avg from formula
            logger.debug(formula_g)
            if re.search(f"{self.aggregation_re}", formula_g) is None:
                continue
            else:
                aggrega = re.search(f"{self.aggregation_re}",
                                    formula_g).group(0)
            formula = formula_g.replace(aggrega, "")
            # formula = formula[1:(len(formula)-1)]
            counters_str = re.findall(r"M\d+C\d*|[A-Z][A-Z0-9_]+", formula)
            formula_with_real_v_list = []
            length = 0
            for c in counters_str:
                length = len(counterid_values[c])
                if c not in counterid_values:
                    logger.warn(
                        f"Can't get the counter:{c} value of rule {rule}")
                for i, v in enumerate(counterid_values[c]):
                    if len(formula_with_real_v_list) < length:
                        formula_with_real_v_list.append(formula)
                    formula_with_real_v_list[i] = formula_with_real_v_list[i].replace(
                        c, str(counterid_values[c][i]))
            formula_with_real_v_result = []
            logger.debug(f"formula_with_real_v_list {formula_with_real_v_list}")
            for formula_with_real in formula_with_real_v_list:
                if isinstance(eval(formula_with_real), list):
                    formula_with_real_v_result += eval(formula_with_real)
                else:
                    formula_with_real_v_result.append(eval(formula_with_real))
            if "avg" in aggrega:
                result = eval(
                    f"sum({str(formula_with_real_v_result)})/{length}")
            elif "latest" in aggrega:
                result = eval(f"{formula_with_real_v_result[-1]}")
            elif "has_no_0_value" in aggrega:
                result = False
                logger.debug(f"formula_with_real_v_result {formula_with_real_v_result}")
                for formula_each in formula_with_real_v_result:
                    if i > 0:
                        result = True
                        break
            else:
                result = eval(f"{aggrega}({str(formula_with_real_v_result)})")
            calculate_rule = calculate_rule.replace(
                formula_g.rstrip().strip(), str(result))
        return calculate_rule

    def with_aggregation_formulate_handle(self, calculate_rule):
        fix_formula = []
        formulas = self.without_aggregation_formulate_handle(
            calculate_rule=calculate_rule)
        for formula in formulas:
            aggregation = None
            for f in re.split(self.aggregation_re, formula):
                if f == "":
                    continue
                if re.search(self.aggregation_re, f):
                    aggregation = f
                else:
                    if aggregation is not None:
                        fix_formula.append(aggregation + f)
                        aggregation = None
        formula = []
        for f in fix_formula:
            fix_f = re.sub(r"\)[^\)]*$", "", f)+")"
            if fix_f.count("(") > fix_f.count(")"):
                for i in range(fix_f.count("(") - fix_f.count(")")):
                    fix_f = "".join([fix_f.rpartition("(")[0],
                                     fix_f.rpartition("(")[-1]])
            elif fix_f.count("(") < fix_f.count(")"):
                for i in range(fix_f.count(")") - fix_f.count("(")):
                    fix_f = "".join([fix_f.partition(")")[0],
                                     fix_f.partition(")")[-1]])
            formula.append(fix_f.strip())
        logger.info(f"fixed formula {formula}")
        return formula

    def without_aggregation_formulate_handle(self, calculate_rule):
        formulas = []
        if "or" or "and" in calculate_rule:
            if "or" in calculate_rule:
                tmp_formulas = calculate_rule.split("or")
            else:
                tmp_formulas = [calculate_rule]
            for formula in tmp_formulas:
                formulas += formula.split("and")
        else:
            formulas = calculate_rule
        # to remove invalid '(' or ')'
        ret = []
        for formula in formulas:
            if formula.count("(") > formula.count(")"):
                ret.append(
                    formula.replace(
                        "(", "", formula.count("(") - formula.count(")")).strip())
            elif formula.count("(") < formula.count(")"):
                for i in range(formula.count(")") - formula.count("(")):
                    formula = "".join([formula.rpartition(")")[
                                      0], formula.rpartition(")")[-1]])
                ret.append(formula.strip())
            else:
                ret.append(formula.strip())
        # remove the space
        logger.info(f"ret {ret}")
        return ret

    def check_without_aggregation(self, rule, counterid_values):
        calculate_rule = rule
        for formula_g in self.without_aggregation_formulate_handle(
                calculate_rule):
            formula = formula_g
            logger.info(f"formula: {formula}")
            counters_str = re.findall(r"M\d+C\d*X?|[A-Z][A-Z0-9_]+", formula)
            calculate_formula = []
            if len(counters_str) == 0:
                continue
            for c in counters_str:
                if c not in counterid_values:
                    Warning(f"Can't get the counter:{c} value of rule {rule}")
                for i, v in enumerate(counterid_values[c]):
                    if len(calculate_formula) <= i:
                        calculate_formula.append(formula)
                    calculate_formula[i] = calculate_formula[i].replace(
                        c, str(v))
            logger.info(f"calculate_formula {calculate_formula}")
            if len(calculate_formula) > 0:
                result = list(map(eval, calculate_formula))
                if False in result:
                    calculate_rule = calculate_rule.replace(formula, 'False')
                else:
                    calculate_rule = calculate_rule.replace(formula, 'True')
            else:
                calculate_rule = calculate_rule.replace(formula, 'False')
        return calculate_rule

    def check(self, counterinfo_values):
        self.check_result = {}
        for counterid_distname, rules in self.counter_rule.items():
            counterid_values = self.filter_counter_values(
                counterid_distname, counterinfo_values, counterid_distname.comment.lower() == "latest")
            logger.debug(f"checked values {counterid_values}")
            for rule in rules:
                try:
                    result = False
                    k = rule
                    if "delta" in rule:
                        result = None  # no need to check return None
                        continue
                    calculate_rule = rule
                    # (sum(M55110C00005)>=100 and (avg(M55110C00007)<90 or avg(M55110C00006)>=90))
                    if re.search(f"{self.aggregation_re}", rule) is not None:
                        calculate_rule = self.check_with_aggregation(rule=calculate_rule,
                                                                     counterid_values=counterid_values)
                    print(f"rule {rule}, after aggre calculate_rule {calculate_rule}")
                    calculate_rule = self.check_without_aggregation(rule=calculate_rule,
                                                                    counterid_values=counterid_values)
                    print(f"rule {rule}, calculate_rule {calculate_rule}")
                    result = eval(calculate_rule)
                    k = counterid_distname.origin_str
                except Exception as e:
                    logger.error(
                        f"rule {rule} check found error: {traceback.format_exc()}")
                finally:
                    self.check_result[k] = result
        return self.check_result


class BaseSiteOperation(object):
    def __init__(self):
        sys.path.append(os.path.join(os.path.dirname(__file__), "../../library/module_utils"))
        from module_utils import module_utils
        from snapshot_utils import snapshot_utils
        self.counter_re = r"M\d+[A-Z]\d*|[A-Z][A-Z0-9_]+"
        self.value = {}
        self.fix_value = {}
        self.interval_second = 15 * 60
        self.pm_type = "pm"
        self.log_path = module_utils().setup_module_directory()

    @abstractmethod
    def connect_to(self, host, username, password, port=443):
        pass

    @abstractmethod
    def disconnect(self):
        pass

    @abstractmethod
    def collect_counter(self, counterids, distname='All',
                        starttime=None, endtime=None, timeout=600):
        pass

    # @property
    def get_value(self):
        return self.value

    def get_fix_value(self):
        return self.fix_value

    @abstractmethod
    def get_counter_interval(self, ssh_connection):
        pass

    def get_checked_time(self, t, tz):
        return datetime.fromtimestamp(int(t), tz)

    def get_measurement_id(self, counter_id):
        measurement_re = re.match(r"M\d+C|[A-Z][A-Z0-9_]+|[A-Z][A-Z0-9_]+", counter_id)
        if measurement_re is not None:
            return measurement_re.group(0).replace("C", "").replace("M", "")
        else:
            raise BaseException(f"counter can't match MxxCxx, {counter_id}")

    def convert_timestring_to_time(self, t_string):
        import re
        # remove the .000
        t_string = re.sub(r'\.\d+', '', t_string)
        # +08:00:00 -> +08:00
        t_string = re.sub(r'(\+\d{2}:\d{2}):\d{2}$', r'\1', t_string)
        try:
            return parser.parse(t_string)
        except Exception as e:
            logger.error(f"Failed to parse time string: {t_string}, error: {e}")
            raise

    def isdistname_match(self, filter_distname, distname):
        for distname_part in filter_distname.split("/"):
            if distname_part not in distname:
                return False
            else:
                has_object = False
                for objdistname in distname.split("/"):
                    if distname_part == objdistname:
                        has_object = True
                        break
                if not has_object:
                    return False
        return True

    def _handle_one_rd_counter(self, rules_info, rd_counter_path,
                               distname_counterid_timestamp_value, starttime=None, endtime=None):
        logger.info(f"rules_info: {rules_info}")
        with open(rd_counter_path, 'r') as f:
            root = ET.fromstring(f.read())
            for time_pm_setup in root.findall(".//PMSetup"):
                t = time_pm_setup.attrib["startTime"]
                # 2025-07-08T15:00:00+08:00
                if starttime is not None and endtime is not None:
                    # "%Y-%m-%dT%H:%M:%S%z"
                    converted_time = self.convert_timestring_to_time(t)
                    converted_time = converted_time.astimezone(timezone.utc)
                    converted_time = converted_time.strftime("%Y%m%d.%H%M%S")
                    if not (starttime <= converted_time <= endtime):
                        continue
                for pmmo_result in time_pm_setup.findall(".//PMMOResult"):
                    mo = None
                    for mo_result in pmmo_result:
                        if mo_result.tag == "MO":
                            if mo is None:
                                mo = mo_result.find("DN").text
                            else:
                                mo = mo + "/" + mo_result.find("DN").text.replace("PLMN-PLMN/", "")
                                logger.info(f"long mo {mo}")

                        if mo is not None and (mo_result.tag == "NE-WBTS_1.0" or mo_result.tag == "PMTarget"):
                            measurementType = mo_result.attrib["measurementType"]
                            xml_distname = mo + "/" + measurementType
                            need_to_check = False
                            for child in mo_result:
                                counter_id = child.tag

                                for rule_info in rules_info:
                                    if rule_info.distname.lower() == "all" or \
                                            self.isdistname_match(rule_info.distname, xml_distname):
                                        if counter_id in rule_info.counterid.split(","):
                                            need_to_check = True
                                            break
                                if not need_to_check:
                                    continue

                                counter_value = child.text
                                if xml_distname not in distname_counterid_timestamp_value.keys():
                                    distname_counterid_timestamp_value[xml_distname] = {}
                                if counter_id not in distname_counterid_timestamp_value[xml_distname].keys():
                                    distname_counterid_timestamp_value[xml_distname][counter_id] = {}
                                distname_counterid_timestamp_value[xml_distname][counter_id][t] = \
                                    counter_value

    def vran_value_filter_by_time(self, v, starttime, endtime):
        if len(v) != 0:
            for distname, counterid_timestamp_value in v.items():
                for counter_id, timestamp_value in counterid_timestamp_value.items():
                    if distname not in self.value.keys():
                        self.value[distname] = {}
                        self.fix_value[distname] = {}
                    if starttime is None and endtime is None:
                        self.value[distname][counter_id] = dict([
                            (self.convert_timestring_to_time(t_value["start_time"]), t_value["value"])
                            for t_value in timestamp_value
                        ])
                    elif starttime is not None and endtime is not None:
                        self.value[distname][counter_id] = dict([
                            (self.convert_timestring_to_time(t_value["start_time"]), t_value["value"])
                            for t_value in timestamp_value
                            if self.convert_timestring_to_time(t_value["start_time"]) >= starttime and
                            self.convert_timestring_to_time(t_value["start_time"]) <= endtime])
                    elif starttime is not None and endtime is None:
                        self.value[distname][counter_id] = dict([
                            (self.convert_timestring_to_time(t_value["start_time"]), t_value["value"])
                            for t_value in timestamp_value
                            if self.convert_timestring_to_time(t_value["start_time"]) >= starttime])
                    elif starttime is None and endtime is not None:
                        self.value[distname][counter_id] = dict([
                            (self.convert_timestring_to_time(t_value["start_time"]), t_value["value"])
                            for t_value in timestamp_value
                            if self.convert_timestring_to_time(t_value["start_time"]) <= endtime])
                    self.fix_value[distname][counter_id] = dict([
                        (t.strftime("%Y-%m-%d %H:%M:%S"), value)
                        for t, value in self.value[distname][counter_id].items()])
        return self.fix_value


class ClassicalOperation(BaseSiteOperation):
    def __init__(self):
        super().__init__()
        self.alias = "counter_module_classical"
        self.coam_admin = admin()

    def connect_to(self, host, username, password, port='443'):
        self.coam_admin.connect_to(bts_host=host,
                                   username=username,
                                   password=password,
                                   # bts_port=port,
                                   name=self.alias,
                                   timeout=90,
                                   release="SBTS00")

    def disconnect(self):
        self.coam_admin.teardown_admin(connection=self.alias)

    def get_counter_interval(self, ssh_connection):
        pmfiles = ssh_connection.execute(
            "cd /tmp;ls |grep PM.BTS |sort |uniq").split()
        pmfiles = [f for f in pmfiles if ".xml" in f]
        if len(pmfiles) >= 2:
            second_time = re.search(r"20\d+\.\d+", pmfiles[-1]).group(0)
            first_time = re.search(r"20\d+\.\d+", pmfiles[-2]).group(0)
            interval_second = datetime.strptime(
                second_time, "%Y%m%d.%H%M%S") - datetime.strptime(first_time, "%Y%m%d.%H%M%S")
            self.interval_second = interval_second.seconds
        logger.debug(f"interval_second {self.interval_second}")

    def clean_pm_file(self, ):
        self.coam_admin.clean_pm_file(connection=self.alias)

    def collect_counter(self, counterids, distname='All',
                        starttime=None, endtime=None, timeout=600, rules_info=None):
        if self.pm_type == "pm":
            return self.collect_pm_counters(
                counterids=counterids,
                distname=distname,
                starttime=starttime,
                endtime=endtime,
                timeout=timeout
            )
        elif self.pm_type == "rd":
            return self.collect_rd_counters(
                rules_info=rules_info,
                starttime=starttime,
                endtime=endtime,
                timeout=timeout
            )
        else:
            raise BaseException(f"Unsupported pm_type: {self.pm_type}, please set pm_type to pm or rd")

    def handle_all_rd_counters(self, rules_info, rd_counter_file_path=None,
                               starttime=None, endtime=None, timeout=600):

        rd_counter_files = []
        distname_counterid_timestamp_value = {}
        if starttime is not None:
            starttime = starttime.strftime("%Y%m%d.%H%M%S")
        if endtime is not None:
            endtime = endtime.strftime("%Y%m%d.%H%M%S")

        for root, dirs, files in os.walk(rd_counter_file_path):
            for filename in files:
                if filename.endswith(".xml") or filename.endswith(".raw"):
                    filetime = re.search(r"20\d+\.\d+", filename).group(0)
                    logger.info(f"start time is: {starttime}, end time is: {endtime}, filetime is:{filetime}")
                    if starttime is not None:
                        if filetime < starttime:
                            continue
                    if endtime is not None:
                        if filetime > endtime:
                            continue
                    logger.info(f"Found rd counter file: {os.path.join(root, filename)}")
                    self._handle_one_rd_counter(rules_info,
                                                os.path.join(root, filename),
                                                distname_counterid_timestamp_value=distname_counterid_timestamp_value,
                                                starttime=starttime,
                                                endtime=endtime)
                    logger.info(f"distname_counterid_timestamp_value: {distname_counterid_timestamp_value}")

        self.fix_value = distname_counterid_timestamp_value
        self.value = self.fix_value.copy()
        return self.fix_value

    def collect_rd_counters(self, rules_info, starttime=None, endtime=None, timeout=600):
        sys.path.append(os.path.join(os.path.dirname(__file__), "../../library/module_utils"))
        from module_utils import module_utils
        from snapshot_utils import snapshot_utils
        snapshotdir = f"rd_counters_files_{datetime.now().strftime('%Y%m%d_%H%M%S')}"
        if not os.path.exists(os.path.join(self.log_path, snapshotdir)):
            os.makedirs(os.path.join(self.log_path, snapshotdir))
        target_file_name = os.path.join(self.log_path,
                                        snapshotdir,
                                        "rd_counters_snapshot.zip")
        logger.info(f"Collecting rd counters, target file: {target_file_name}")
        self.coam_admin.collect_snapshot(target_file_name=target_file_name,
                                         regexp_filter="_RD.BTS",
                                         connection=self.alias,
                                         timeout=timeout)
        os.system(f"unzip -o {target_file_name} -d {os.path.dirname(target_file_name)}")
        snapshotfile_path = os.path.join(os.path.dirname(target_file_name), "snapshot_file_list.txt")
        snapshot_handler = snapshot_utils()
        logger.info(f"Unzipping snapshot file: {target_file_name}")
        pm_path = snapshot_handler.get_pmfile_from_snapshot_file_classical(
            snapshot_file_path=snapshotfile_path,
            file_reg=r"_RD\.BTS")
        logger.info(f"PM file path: {pm_path}")
        return self.handle_all_rd_counters(
            rules_info=rules_info,
            rd_counter_file_path=pm_path,
            starttime=starttime,
            endtime=endtime)

    def collect_pm_counters(self, counterids, distname='All',
                            starttime=None, endtime=None, timeout=600):
        logger.info(f"Collecting counter : {counterids} distname: {distname}")
        timezone_hour = re.search(
            r"[+-]?\d+", self.coam_admin.get_bts_time_zone(connection=self.alias)).group(0)
        tz = timezone(timedelta(hours=int(timezone_hour)))
        counter_infos = self.coam_admin.get_pm_counters(
            counter_ids=counterids, connection=self.alias, timeout=timeout)

        v = get_all_values_by_key(counter_infos,
                                  r"M\d+[A-Z]\d*")
        logger.info(f"v {v}")
        if len(v) != 0:
            input_distname = distname
            for distname_counterid, timestamp_value in v.items():
                counter_id = re.search(
                    r"\[\'" + r"M\d+[A-Z]\d*" + r"\'\]", distname_counterid).group(0)
                distname = distname_counterid.replace(counter_id, "")
                logger.info(f"distname is {distname}, input distname is {input_distname}")
                counter_id = counter_id.replace("['", "").replace("']", "")
                if input_distname.lower() != "all":
                    no_match = False
                    for n in input_distname.split("/"):
                        if n not in distname:
                            no_match = True
                    if no_match:
                        continue
                logger.info(f"start to fetch counter {input_distname} {counter_id}")
                if distname not in self.value.keys():
                    self.value[distname] = {}
                    self.fix_value[distname] = {}
                if starttime is None and endtime is None:
                    self.value[distname][counter_id] = dict([
                        (self.get_checked_time(t, tz), value)
                        for t, value in timestamp_value.items()])
                    self.fix_value[distname][counter_id] = dict([
                        (t.strftime("%Y-%m-%d %H:%M:%S"), value)
                        for t, value in self.value[distname][counter_id].items()])
                elif starttime is not None and endtime is not None:
                    self.value[distname][counter_id] = dict([
                        (self.get_checked_time(t, tz), value)
                        for t, value in timestamp_value.items()
                        if self.get_checked_time(t, tz) >= starttime and
                        self.get_checked_time(t, tz) <= endtime])
                    self.fix_value[distname][counter_id] = dict([
                        (t.strftime("%Y-%m-%d %H:%M:%S"), value)
                        for t, value in self.value[distname][counter_id].items()])
                elif starttime is not None and endtime is None:
                    self.value[distname][counter_id] = dict([
                        (self.get_checked_time(t, tz), value)
                        for t, value in timestamp_value.items()
                        if self.get_checked_time(t, tz) >= starttime])
                    self.fix_value[distname][counter_id] = dict([
                        (t.strftime("%Y-%m-%d %H:%M:%S"), value)
                        for t, value in self.value[distname][counter_id].items()])
                elif starttime is None and endtime is not None:
                    self.value[distname][counter_id] = dict([
                        (self.get_checked_time(t, tz), value)
                        for t, value in timestamp_value.items()
                        if self.get_checked_time(t, tz) <= endtime])
                    self.fix_value[distname][counter_id] = dict([
                        (t.strftime("%Y-%m-%d %H:%M:%S"), value)
                        for t, value in self.value[distname][counter_id].items()])

            return self.fix_value


class CuOperation(BaseSiteOperation):
    def __init__(self):
        super().__init__()
        self.alias = "counter_module_cu"
        self.cu_object = cu()

    def connect_to(self, host, username, password, port=''):
        self.cu_object.connect_to(host=host,
                                  username=username,
                                  password=password,
                                  secure=True,
                                  port=port,
                                  alias=self.alias)

    def disconnect(self):
        self.cu_object.disconnect(connection=self.alias)

    @abstractmethod
    def get_counter_interval(self, ssh_connection):
        pass

    def collect_counter(self, counterids, distname='.*',
                        starttime=None, endtime=None, timeout=600, rules_info=None):
        if self.pm_type == "pm":
            return self.collect_pm_counters(
                counterids=counterids,
                distname=distname,
                starttime=starttime,
                endtime=endtime,
                timeout=timeout
            )
        else:
            return self.collect_rd_counters(
                rules_info=rules_info,
                starttime=starttime,
                endtime=endtime,
                timeout=timeout
            )

    def collect_rd_counters(self, rules_info, starttime=None, endtime=None, timeout=600):
        sys.path.append(os.path.join(os.path.dirname(__file__), "../../library/module_utils"))
        from module_utils import module_utils
        from snapshot_utils import snapshot_utils
        logger.info(f"Collecting counter for {rules_info}")
        snapshotdir = f"rd_counters_files_{datetime.now().strftime('%Y%m%d_%H%M%S')}"
        if not os.path.exists(os.path.join(self.log_path, snapshotdir)):
            os.makedirs(os.path.join(self.log_path, snapshotdir))
        snapshotdir = os.path.join(self.log_path, snapshotdir)
        logger.info(f"Snapshot directory: {snapshotdir}")
        self.cu_object.get_local_snapshot(directory=snapshotdir,
                                          filter_regx="_rad_counters",
                                          compressed=False,
                                          connection=self.alias)
        snapshotfile_path = os.path.join(snapshotdir, "snapshot_file_list.txt")
        snapshot_handler = snapshot_utils()
        logger.info(f"Unzipping snapshot file: {snapshotfile_path}")
        pm_path = snapshot_handler.get_pmfile_from_snapshot_file_vran(
            snapshot_file_path=snapshotfile_path,
            file_reg=r"_rad_counters")
        logger.info(f"RD PM file path: {pm_path}")
        return self.handle_all_rd_counters(
            rules_info=rules_info,
            rd_counter_file_path=pm_path,
            starttime=starttime,
            endtime=endtime)

    def handle_all_rd_counters(self, rules_info, rd_counter_file_path=None,
                               starttime=None, endtime=None, timeout=600):

        rd_counter_files = []
        distname_counterid_timestamp_value = {}

        for root, dirs, files in os.walk(rd_counter_file_path):
            for filename in files:
                if filename.endswith(".xml") or filename.endswith(".raw"):
                    # RD20250602.1600+0800-20250602.1615+0800
                    times = re.findall(r"20\d+\.\d+\+\d+", filename)
                    file_starttime = datetime.strptime(times[0], "%Y%m%d.%H%M%z")
                    file_starttime = file_starttime.astimezone(timezone.utc)
                    file_endtime = datetime.strptime(times[1], "%Y%m%d.%H%M%z")
                    file_endtime = file_endtime.astimezone(timezone.utc)

                    logger.info(f"start time is: {starttime}, end time is: {endtime}, \
                                file_starttime is:{file_starttime}, file_endtime is: {file_endtime}")
                    if starttime is not None:
                        if file_endtime < starttime:
                            continue
                    if endtime is not None:
                        if file_starttime > endtime:
                            continue
                    logger.info(f"Found rd counter file: {os.path.join(root, filename)}")
                    self._handle_one_rd_counter(rules_info,
                                                os.path.join(root, filename),
                                                distname_counterid_timestamp_value=distname_counterid_timestamp_value,
                                                starttime=starttime.strftime("%Y%m%d.%H%M%S") if starttime else None,
                                                endtime=endtime.strftime("%Y%m%d.%H%M%S") if endtime else None)
                    logger.info(f"distname_counterid_timestamp_value: {distname_counterid_timestamp_value}")

        self.fix_value = distname_counterid_timestamp_value
        self.value = self.fix_value.copy()
        return self.fix_value

    def collect_pm_counters(self, counterids, distname='.*',
                            starttime=None, endtime=None, timeout=600):
        counter_infos = {}
        for counterid in counterids.split(","):
            measurement_id = self.get_measurement_id(counterid)
            counter_info = self.cu_object.get_counter(measurement_id=measurement_id,
                                                      dimension_dist_name=distname,
                                                      counter_id=counterid,
                                                      connection=self.alias)
            if distname not in counter_infos.keys():
                counter_infos[distname] = {}
            counter_infos[distname][counterid] = counter_info["values"]
        # logger.info(counter_infos)
        v = counter_infos
        self.fix_value = self.vran_value_filter_by_time(v=v, starttime=starttime, endtime=endtime)
        return self.fix_value


class DuOperation(BaseSiteOperation):
    def __init__(self):
        super().__init__()
        self.alias = "counter_module_du"
        self.du_object = vdu()
        self.instance_id = None

    def connect_to(self, host, username, password, port=''):
        logger.info(self.alias)
        self.du_object.connect_to(host=host,
                                  username=username,
                                  password=password,
                                  timeout=60,
                                  port=port,
                                  secure=True,
                                  connection_name=self.alias)

    def disconnect(self):
        self.du_object.disconnect(vdu_connection=self.alias)

    @abstractmethod
    def get_counter_interval(self, ssh_connection):
        pass

    def collect_counter(self, counterids, distname='.*',
                        starttime=None, endtime=None, timeout=600):
        # get_counter_values
        logger.info(f"Collecting counter : {counterids}")
        counter_infos = {}
        for counterid in counterids.split(","):
            if distname.lower() == "all":
                distname = ".*"
            counter_info = self.du_object.get_counter_values(counter_id=counterid,
                                                             dimension_dn=distname,
                                                             vdu_connection=self.alias)
            if distname not in counter_infos.keys():
                counter_infos[distname] = {}
            counter_infos[distname][counterid] = counter_info
        v = counter_infos
        self.fix_value = self.vran_value_filter_by_time(v=v, starttime=starttime, endtime=endtime)
        return self.fix_value


class SiteOperationFactory(object):
    def __init__(self):
        self.tl_obj = None

    def create_handler(self, product_type, bts_index, cudu_index, oam_ip):
        if product_type in ["vcu", "vdu", "enb", "gnb"]:
            try:
                self.tl_obj = BuiltIn().get_variable_value("${tl}")
                # if self.tl_obj is None:
                #     self.tl_obj = tl
            except Exception as e:
                logger.warn(traceback.format_exc())
            if product_type == "vcu":
                self.product_handle = CuOperation()
                self.host = self.tl_obj.gnbs[bts_index].cu.oam_http_connection_details.addr
                self.username = self.tl_obj.gnbs[bts_index].cu.oam_http_connection_details.username
                self.password = self.tl_obj.gnbs[bts_index].cu.oam_http_connection_details.password
                self.port = self.tl_obj.gnbs[bts_index].cu.oam_http_connection_details.port
                vcu_ssh_config = self.tl_obj.gnbs[bts_index].cloud_deployment.cloud_hosting.master_node
                ssh_host = vcu_ssh_config.ssh_connection_details.addr
                ssh_username = vcu_ssh_config.ssh_connection_details.username
                ssh_password = vcu_ssh_config.ssh_connection_details.password
            elif product_type == "vdu":
                self.product_handle = DuOperation()
                self.host = self.tl_obj.gnbs[bts_index].dus[cudu_index].oam_http_connection_details.addr
                self.username = self.tl_obj.gnbs[bts_index].dus[cudu_index].oam_http_connection_details.username
                self.password = self.tl_obj.gnbs[bts_index].dus[cudu_index].oam_http_connection_details.password
                self.port = self.tl_obj.gnbs[bts_index].dus[cudu_index].oam_http_connection_details.port
                vdu_config = self.tl_obj.gnbs[bts_index].dus[cudu_index]
                ssh_host = vdu_config.cloud_deployment.cloud_hosting.master_node.ssh_connection_details.addr
                ssh_username = vdu_config.cloud_deployment.cloud_hosting.master_node.ssh_connection_details.username
                ssh_password = vdu_config.cloud_deployment.cloud_hosting.master_node.ssh_connection_details.password
            elif product_type == "gnb":
                self.product_handle = ClassicalOperation()
                if oam_ip is not None:
                    self.host = oam_ip
                else:
                    self.host = self.tl_obj.gnbs[bts_index].cu.oam_http_connection_details.addr
                self.username = self.tl_obj.gnbs[bts_index].cu.oam_http_connection_details.username
                self.password = self.tl_obj.gnbs[bts_index].cu.oam_http_connection_details.password
                self.port = None
                ssh_host = self.tl_obj.gnbs[bts_index].cu.oam_ssh_connection_details.addr
                ssh_username = self.tl_obj.gnbs[bts_index].cu.oam_ssh_connection_details.username
                ssh_password = self.tl_obj.gnbs[bts_index].cu.oam_ssh_connection_details.password
            elif product_type == "enb":
                self.product_handle = ClassicalOperation()
                if oam_ip is not None:
                    self.host = oam_ip
                else:
                    self.host = self.tl_obj.enbs[bts_index].oam_ip.v4
                self.username = "Nemuadmin"
                self.password = "nemuuser"
                self.port = None
                ssh_host = self.host
                ssh_username = "toor4nsn"
                ssh_password = "oZPS0POrRieRtu"
        else:
            raise BaseException(
                f"can't support this product type:{product_type}")
        ssh_handle = ssh()
        logger.debug(f"password {ssh_password}")
        ssh_connection = ssh_handle.connect_to(hostname=ssh_host,
                                               username=ssh_username,
                                               password=ssh_password,
                                               alias=f"ssh_{ssh_host}")
        ssh_handle.force_reconnect(connection=f"ssh_{ssh_host}")
        if product_type in ["enb", "gnb"]:
            self.product_handle.get_counter_interval(ssh_connection)
            ssh_connection.execute("rm -rf /tmp/PM.BTS*")
        return self.product_handle

    def connect_to(self):
        self.product_handle.connect_to(host=self.host,
                                       username=self.username,
                                       password=self.password,
                                       port=self.port)

    def get_value(self):
        return self.product_handle.get_value()


class CounterModuleFactory(object):

    def __init__(self):
        self.tl_obj = None
        self.starttime = None
        self.endtime = None
        self.counter_rule = None
        self.distname_counterids = None
        self.sitehandler = None
        self.interval = None

    def start_collect_counter(self,
                              product_type="gnb",
                              bts_index=0,
                              cudu_index=0,
                              interval=5,
                              wait_for_next_counter_generate=False,
                              oam_ip=None,
                              pm_type="pm",
                              counterrule="counter_rule.txt"):
        self.interval = interval
        self.counter_rule = CounterRule(counterrule=counterrule)
        self.counter_rule.parse()
        self.distname_counterids = self.counter_rule.get_counter_distname()
        self.site_factory = SiteOperationFactory()
        self.site_factory.create_handler(product_type,
                                         bts_index,
                                         cudu_index,
                                         oam_ip)
        self.site_factory.product_handle.pm_type = pm_type
        self.wait_for_next_counter = wait_for_next_counter_generate
        starttime = datetime.now(tz=timezone(
            timedelta(hours=0))) - timedelta(minutes=interval)
        if self.wait_for_next_counter:
            self.wait_for_next_counter_generate(starttime,
                                                datetime.now(tz=timezone(timedelta(hours=0))))
            logger.info(msg="will abandon the latest counter, now start next counter cycle")
            self.starttime = datetime.now(tz=timezone(
                timedelta(hours=0))) - timedelta(minutes=interval)
        else:
            self.starttime = starttime
        logger.info(
            msg=f"counter start time is:{self.starttime.strftime('%Y%m%d %H:%M:%S')}")

    def wait_for_next_counter_generate(self,
                                       counter_fetch_starttime,
                                       counter_fetch_endtime):
        starttime = datetime.now()
        self.site_factory.connect_to()
        # self.endtime = datetime.now(tz=timezone(timedelta(hours=0)))
        tracemsg = []
        while datetime.now() < starttime + timedelta(minutes=self.interval):
            time.sleep(10)
            logger.info(f"start to collect counter {counter_fetch_starttime} ~ {counter_fetch_endtime}")
            if self.site_factory.product_handle.pm_type == "pm":
                for distname, counetrids in self.distname_counterids.items():
                    try:
                        self.site_factory.product_handle.collect_counter(
                            counterids=",".join(counetrids),
                            distname=distname,
                            starttime=counter_fetch_starttime,
                            endtime=counter_fetch_endtime)
                    except Exception as e:
                        tracemsg.append(traceback.format_exc())
            else:
                self.site_factory.product_handle.collect_counter(
                    counterids=[],
                    rules_info=self.counter_rule.get_counter_rule.keys(),
                    starttime=counter_fetch_starttime,
                    endtime=counter_fetch_endtime)
            empty_value = False
            values = self.site_factory.product_handle.get_fix_value()
            for distname, counterids_timeval in values.items():
                for counter, timeval in counterids_timeval.items():
                    if len(timeval) == 0:
                        empty_value = True
                        break
            if empty_value is False:
                break
        logger.info(f"values {values}")
        if len(tracemsg) > 0:
            logger.debug(f"Tracing msg is {tracemsg}")

    def get_value(self):
        return self.site_factory.product_handle.get_fix_value()

    def collect_counter(self):
        self.site_factory.connect_to()
        self.endtime = datetime.now(tz=timezone(timedelta(hours=0)))
        if self.wait_for_next_counter:
            starttime = self.endtime - timedelta(minutes=self.interval)
            logger.info(f"wait for latest counter generate {starttime} ~ {self.endtime}")
            self.wait_for_next_counter_generate(starttime, self.endtime)
            self.endtime = datetime.now(tz=timezone(timedelta(hours=0)))
            logger.info(f"start to collect counter {self.starttime} ~ {self.endtime}")
            self.wait_for_next_counter_generate(self.starttime, self.endtime)
        else:
            self.wait_for_next_counter_generate(self.starttime, self.endtime)
        self.starttime = self.endtime - timedelta(minutes=self.interval)
        return self.site_factory.product_handle.get_fix_value()

    def check_result_to_str(self, check_result):
        s = ""
        for rule, result in check_result.items():
            s += f"{rule} is {result}\n"
        return s

    def convert_counter_value_to_str(self, counter_time_vals):
        s = ""
        for counter_time_vale in counter_time_vals:
            for counter_id, time_value in counter_time_vale.items():
                s += f"{counter_id}:\n"
                for time, value in time_value.items():
                    s += f"{time} : {value}\n"
        return s

    def convert_checkresult_to_table(self, check_result, fix_v):
        rules_obj = self.counter_rule.get_counter_rule
        table_rows = []
        for rule_obj, rule in rules_obj.items():
            if rule_obj.origin_str in check_result.keys():
                counter_time_vale = []
                for distname, counter_time_value in fix_v.items():
                    if rule_obj.distname.lower() == "all" or \
                       self.counter_rule.isdistname_match(rule_obj.distname, distname):
                        for counter_id, time_value in counter_time_value.items():
                            if counter_id in rule_obj.counterid:
                                counter_time_vale.append({counter_id: time_value})

                table_rows.append({"dist_name": rule_obj.distname,
                                   "counter_rule": rule_obj.counter_rule_origin_str,
                                   "value": self.convert_counter_value_to_str(counter_time_vale),
                                   "comment": rule_obj.comment,
                                   "result": check_result[rule_obj.origin_str]})
        logger.debug(f"table_rows {table_rows}")
        table_counter_logger(table_rows)

    def collect_counter_and_calculate(self):
        # self.site_factory.connect_to()
        self.collect_counter()
        v = self.site_factory.get_value()
        fix_v = self.site_factory.product_handle.get_fix_value()
        check_result = self.counter_rule.check(counterinfo_values=v)
        self.convert_checkresult_to_table(check_result, fix_v)
        return {"value": fix_v, "check_result": check_result}

    def collect_counter_and_check_rule(self):
        # self.site_factory.connect_to()
        self.collect_counter()
        v = self.site_factory.get_value()
        fix_v = self.site_factory.product_handle.get_fix_value()
        check_result = self.counter_rule.check(counterinfo_values=v)
        self.convert_checkresult_to_table(check_result, fix_v)
        if False in check_result.values():
            logger.info(f"check_result is False,value is: {json.dumps(fix_v)}")
            logger.info(
                f"check_result is False,result is: {json.dumps(check_result)}")
            raise BaseException(
                f"check_result is False, {self.check_result_to_str(check_result)}")
        return {"value": fix_v, "check_result": check_result}

    def _counter_rule_check_test(self, counterrule="counter_rule.txt"):
        import json
        fp = open("counter_test_data.json", 'r')
        v = json.loads(fp.read())
        self.counter_rule = CounterRule(counterrule=counterrule)
        self.counter_rule.parse()
        self.counter_rule.check(counterinfo_values=v)

    def _counter_rule_compare_test(self, counterrule="counter_rule.txt"):
        import json
        fp = open("counter_test_data.json", 'r')
        v = json.loads(fp.read())
        self.counter_rule = CounterRule(counterrule=counterrule)
        self.counter_rule.parse()
        fp = open("counter_test_data2.json", 'r')
        v2 = json.loads(fp.read())
        self.counter_rule.compare(
            before_counter_value=v, after_counter_value=v2)

    def compare(self, before_counter_value, after_counter_value):
        check_result = self.counter_rule.compare(
            before_counter_value, after_counter_value)
        if False in check_result.values():
            logger.info(
                f"check_result is False,before value is: {json.dumps(before_counter_value)}")
            logger.info(
                f"check_result is False,after value is: {json.dumps(after_counter_value)}")
            logger.info(
                f"check_result is False,result is: {json.dumps(check_result)}")
            raise BaseException(f"check_result is False, {check_result}")
        return check_result

    def teardown(self):
        self.site_factory.product_handle.disconnect()

    def _out_of_scope(self):
        self.site_factory.product_handle.disconnect()


class counter_rule(object):
    ROBOT_LIBRARY_SCOPE = 'TEST SUITE'
    ROBOT_LISTENER_API_VERSION = 2

    lookup_handler, configured_counter_modules = aliasing_scope(
        lookup_arg='alias', lookup_type=CounterModuleFactory)

    def __init__(self):
        self.lookup_handler.store = self.configured_counter_modules

    def start_collect_counter(self,
                              product_type="gnb",
                              bts_index=0,
                              cudu_index=0,
                              counterrule="counter_rule.txt",
                              interval=5,
                              *args,
                              **kwargs):
        if "wait_for_next_counter_generate" in kwargs.keys():
            wait_for_next_counter_generate = kwargs["wait_for_next_counter_generate"]
        else:
            wait_for_next_counter_generate = False
        if "oam_ip" in kwargs.keys():
            oam_ip = kwargs["oam_ip"]
        else:
            oam_ip = None
        if "pm_type" in kwargs.keys():
            pm_type = kwargs["pm_type"]
        else:
            pm_type = "pm"
        counter_module_handler = CounterModuleFactory()
        module_handler = counter_module_handler.start_collect_counter(
            product_type=product_type,
            bts_index=bts_index,
            cudu_index=cudu_index,
            counterrule=counterrule,
            interval=interval,
            oam_ip=oam_ip,
            wait_for_next_counter_generate=wait_for_next_counter_generate,
            pm_type=pm_type
        )
        self.configured_counter_modules.add(counter_module_handler,
                                            alias=f"{product_type}_{bts_index}_{cudu_index}")
        logger.info(f"alias {product_type}_{bts_index}_{cudu_index}")

    @lookup_handler.implicit_lookup
    def collect_counter(self, alias=None):
        return alias.collect_counter()

    @lookup_handler.implicit_lookup
    def collect_counter_and_check_rule(self, alias=None):
        return alias.collect_counter_and_check_rule()

    @lookup_handler.implicit_lookup
    def collect_counter_and_calculate(self, alias=None):
        return alias.collect_counter_and_calculate()

    @lookup_handler.implicit_lookup
    def compare(self,
                before_counter_value,
                after_counter_value,
                alias=None):
        return alias.compare(before_counter_value,
                             after_counter_value)

    @lookup_handler.implicit_lookup
    def teardown(self,
                 alias=None):
        return alias.teardown()

    @lookup_handler.implicit_lookup
    def _out_of_scope(self,
                      alias=None):
        return alias._out_of_scope()
# if __name__ == "__main__":
#   counter_module = CounterModuleFactory()
#   counter_module._counter_rule_compare_test()
#   # counter_module.start_collect_counter(product_type='vdu')
#   # counter_module.collect_counter()
#   # s = 15*60
#   # time.sleep(s)
#   counter_module.collect_counter_and_check_rule()
#   # counter_rule = CounterRule()
#   # counterid_values = {""}

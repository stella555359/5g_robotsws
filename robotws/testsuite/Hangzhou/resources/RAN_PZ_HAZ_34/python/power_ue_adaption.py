# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Tingting Zhong
:contact: tingting.zhong@nokia-sbell.com
:maintainer: Tingting Zhong
:contact: tingting.zhong@nokia-sbell.com
"""
import re
from robot.api import logger
from taf.ul.stream.aasyslog.exceptions import UnexpectedCellsThroughputError
from taf.ul.power_ue.exception import VerifyThroughputError
from robot.libraries.BuiltIn import BuiltIn

__all__ = ["check_unidirectional_tput", "check_unidirectional_throughput_from_syslog"]


def check_unidirectional_tput(
    ue_class_name,
    tp_class_name,
    dt_name,
    direction,
    theoretical_throughput,
    average_tolerance,
    minimum_tolerance,
    omit,
    end,
    cells,
    upload_tp=True,
):
    power_ue = BuiltIn().get_library_instance(ue_class_name)
    tp_object = BuiltIn().get_library_instance(tp_class_name)
    tput_result = {}
    try:
        tput_result = power_ue.check_unidirectional_throughput(
            dt_name=dt_name,
            direction=direction,
            theoretical_throughput=theoretical_throughput,
            average_tolerance=average_tolerance,
            minimum_tolerance=minimum_tolerance,
            omit=omit,
            end=end,
        )
        return tput_result
    except VerifyThroughputError as err:
        tput_result = err.throughput
        raise err
    finally:
        logger.info("real {} is {}".format(direction, tput_result))
        if upload_tp:
            tp_object.add_iperf_tp(
                cell=cells,
                avg_tput=_calcullate_throughput_mbps_value(
                    tput_result["average_statistics"]
                ),
                min_tput=_calcullate_throughput_mbps_value(
                    tput_result["minimum_statistics"]
                ),
                max_tput=_calcullate_throughput_mbps_value(
                    tput_result["maximum_statistics"]
                ),
                direction=direction,
                target_tp=theoretical_throughput,
                avg_percent=average_tolerance,
                min_percent=minimum_tolerance,
            )


def check_unidirectional_throughput_from_syslog(
    ue_class_name,
    tp_class_name,
    direction,
    theoretical_throughput,
    average_tolerance,
    minimum_tolerance,
    cells,
    ca,
    enable_chart_generation,
    customized_chart_file_name,
    alias,
    upload_tp=True,
):
    power_ue = BuiltIn().get_library_instance(ue_class_name)
    tp_object = BuiltIn().get_library_instance(tp_class_name)
    tput_result = {}
    try:
        tput_result = power_ue.check_unidirectional_throughput_from_syslog(
            direction=direction,
            theoretical_throughput=theoretical_throughput,
            average_tolerance=average_tolerance,
            minimum_tolerance=minimum_tolerance,
            nrcellids=cells,
            ca=ca,
            enable_chart_generation=enable_chart_generation,
            customized_chart_file_name=customized_chart_file_name,
            alias=alias,
        )
        return tput_result
    except UnexpectedCellsThroughputError as err:
        tput_result = err.throughput
        raise err
    finally:
        logger.info("real {} is {}".format(direction, tput_result), also_console=True)
        if upload_tp:
            tp_object.add_aasyslog_tp(
                cells=cells,
                origin_tput=tput_result,
                direction=direction,
                target_tp=theoretical_throughput,
                avg_percent=average_tolerance,
                min_percent=minimum_tolerance,
                ca=ca,
            )


def _calcullate_throughput_mbps_value(throughput):
    throughput_num = re.search(r"\d+\.?\d*", str(throughput)).group()
    if "g" in throughput.lower():
        throughput = float(throughput_num) * 1000
    elif "m" in throughput.lower():
        throughput = float(throughput_num)
    elif "k" in throughput.lower():
        throughput = float(throughput_num) / 1000
    elif "bits/sec" in throughput.lower():
        throughput = float(throughput_num) / (1000 * 1000)
    else:
        throughput = float(throughput_num)
    return throughput

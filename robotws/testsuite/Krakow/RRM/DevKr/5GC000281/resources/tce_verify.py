"""
:copyright: Nokia Networks
:author: Mateusz Matusik  <mateusz.matusik@nokia.com>
:maintainer: Mateusz Matusik  <mateusz.matusik@nokia.com>
"""

from ta_pcmd.submodule_ute_common_abstract_core.message import NotFoundKey
from robot.libraries.BuiltIn import BuiltIn


def verify_if_ngap_message_is_traced(message_name):
    all_reports = BuiltIn().get_library_instance('ta_pcmd').get_all_pcmd_reports()
    for report in all_reports:
        try:
            report.get_value_by_unique_key("ngap.{}_element".format(message_name))
            break
        except NotFoundKey:
            pass
    else:
        raise Exception("Message NGAP:{} not found in PCMD reports".format(message_name))


def verify_if_meas_report_is_traced(message_name):
    all_reports = BuiltIn().get_library_instance('ta_pcmd').get_all_pcmd_reports()
    for report in all_reports:
        try:
            report.get_all_values_by_key("nr-rrc.{}_element".format(message_name))
            break
        except NotFoundKey:
            pass
    else:
        raise Exception("Message NR-RRC:{} not found in TCE reports".format(message_name))

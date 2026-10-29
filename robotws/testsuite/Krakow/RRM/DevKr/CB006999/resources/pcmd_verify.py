"""
:copyright: Nokia Networks
:author: Maciej Pikula  <maciej.pikula@nokia.com>
:maintainer: Cezary Dudek <cezary.dudek@nokia.com>
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

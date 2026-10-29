"""
:copyright: Nokia Networks
:author: Maciej Pikula  <maciej.pikula@nokia.com>
:maintainer: Konrad Krzyzak <konrad.krzyzak@nokia.com>, Maciej Pikula  <maciej.pikula@nokia.com>
"""

import time
from robot.api.deco import keyword
from ta_pcmd import ta_pcmd
from ta_pcmd.submodule_ute_common_abstract_core.message import NotFoundKey
from robot.libraries.BuiltIn import BuiltIn


class pcmd_verify(object):
    """Assumption is ONLY ONE ue is connected!!!"""

    @keyword("Verify that X2AP:${message_name} is traced with PCMD")
    def verify_if_x2ap_message_is_traced(self, message_name):
        pcmd_inst = BuiltIn().get_library_instance('ta_pcmd')
        all_reports = pcmd_inst.get_all_pcmd_reports()
        for report in all_reports:
            try:
                report.get_value_by_unique_key("x2ap.{}_element".format(message_name))
                break
            except NotFoundKey:
                pass
        else:
            raise Exception("Message X2AP:{} not found in PCMD reports".format(message_name))

    def verify_if_ngap_message_is_traced(self, message_name):
        pcmd_inst = BuiltIn().get_library_instance('ta_pcmd')
        all_reports = pcmd_inst.get_all_pcmd_reports()
        for report in all_reports:
            try:
                report.get_value_by_unique_key("ngap.{}_element".format(message_name))
                break
            except NotFoundKey:
                pass
        else:
            raise Exception("Message NGAP:{} not found in PCMD reports".format(message_name))

    def verify_if_meas_report_is_traced(self, message_name):
        pcmd_inst = BuiltIn().get_library_instance('ta_pcmd')
        all_reports = pcmd_inst.get_all_pcmd_reports()
        for report in all_reports:
            try:
                tce_msgId = report.get_value_by_unique_key("nsetapx.asn1_MsgId")
                tce_payload = report.get_value_by_unique_key("nsetapx.asn1_Payload")
                message = report.get_all_values_by_key("nr-rrc.{}_element".format(message_name))[0]
                break
            except NotFoundKey:
                pass
        else:
            raise Exception("Message NR-RRC:{} not found in TCE reports".format(message_name))

    def verify_that_pcmd_menbInitiatedSgNBModRecord_result_is_cplaneOverloadCausedFailure(self):
        pcmd_inst = BuiltIn().get_library_instance('ta_pcmd')
        results = {0:  'success',
                   15: 'cplaneOverloadCausedFailure'}
        all_reports = pcmd_inst.get_all_pcmd_reports()
        for report in all_reports:
            try:
                menbInitiatedSgNBModRecord = report.get_value_by_unique_key('nsetapx.menbInitiatedSgNBModRecord_tree')
                break
            except NotFoundKey:
                pass
        else:
            raise Exception("Record menbInitiatedSgNBModRecord and en-dc modification result"
                            " was not found in PCMD reports")

        result = int(menbInitiatedSgNBModRecord.get_value_by_unique_key('nsetapx.result'))
        assert result == 15, "menbInitiatedSgNBModRecord result is {}".format(result)

    def clear_collected_pcmd_reports(self):
        pcmd_inst = BuiltIn().get_library_instance('ta_pcmd')
        pcmd_inst.clear_already_collected_pcmd_reports()

    @keyword("Wait 5 to collect all PCMD reports")
    def wait_for_reports(self):
        time.sleep(5)

    @keyword("Verify that sgNB_SecurityKey for UE1 is different between"
             " X2AP:SgNBAdditionRequest and X2AP:SgNBModificationRequest in PCMD")
    def compare_sgNB_SecurityKey(self):
        pcmd_inst = BuiltIn().get_library_instance('ta_pcmd')
        all_reports = pcmd_inst.get_all_pcmd_reports()
        sgNB_SecurityKeys = []
        for report in all_reports:
            try:
                sgNB_SecurityKey = report.get_value_by_unique_key('x2ap.sgNB_SecurityKey')
                sgNB_SecurityKeys.append(sgNB_SecurityKey)
            except NotFoundKey:
                pass
            try:
                SgNBSecurityKey = report.get_value_by_unique_key('x2ap.SgNBSecurityKey')
                sgNB_SecurityKeys.append(SgNBSecurityKey)
            except NotFoundKey:
                pass
        assert len(sgNB_SecurityKeys) == 2, "Found {} x2ap.sgNB_SecurityKey fields in PCMD reports." \
                                            " Should be 2".format(len(sgNB_SecurityKeys))
        assert sgNB_SecurityKeys[0] != sgNB_SecurityKeys[1], "x2ap.sgNB_SecurityKey are identical in PCMD reports"

# ====================================================================================================================
# This is a Python File, which helps to implement the Robot Keywords used in 5GC000706-C.robot
# Team: 'MN 5G&SC PZ ULM 2 SqdGp63'
# Email: 'I_MN_5GSC_PZ_ULM_SQD_63@nokia.com'
# ----------------------------------------------------------------------------------------------------[120 characters]

import os
import json

# Robot Framework Libraries:
from robot.libraries.BuiltIn import BuiltIn

# TAF & UTE Libraries:
from taf.analyzer.pdml import PdmlReader, pdml  # noqa: E402

# ====================================================================================================================
#   Keywords for 5GC000706.robot
# ====================================================================================================================

xnap = ""


def verify_f1xn_trace_FD07(pdml_file_path, xnap):
    """Keyword: Verify F1 Xn trace FD07"""
    BuiltIn().log_to_console("-" * 65)
    BuiltIn().log_to_console("Verify F1 Xn trace of 5GC000706-FD07:")
    testname = BuiltIn().get_variable_value("${TEST NAME}")
    BuiltIn().log_to_console(testname)
    # ================================================================================================================
    tcResultDict = {}
    if not os.path.isfile(pdml_file_path):
        raise AssertionError("verify_f1xn_trace(): %s does not exist!!!" % pdml_file_path)
    try:
        with open(pdml_file_path, 'rb') as file_obj:
            for entry in PdmlReader(file_obj=file_obj):
                root = entry.packet
                tcResultDict["UEContextSetupRequest"] = verify_UEContextSetupRequest(root, pdml_file_path)
                tcResultDict["UEContextModificationRequest"] = \
                    verify_UEContextModificationRequest(root, pdml_file_path)
                # tcResultDict["drxConfig"] = verify_rrc_drxConfig(root)
                tcResultDict["eventCheck"] = verify_rrc_events(root, pdml_file_path)
                tcResultDict["reconfigurationWithSync"] = verify_rrc_reconfigurationWithSync(root)
                tcResultDict["RRCReconfiguration_measGap"] = verify_rrcReconfiguration_measGap(root)
            tcResultDict["InterGnbHOSequence"] = \
                verify_inter_gnb_handover_sequence(pdml_file_path, xnap)
    except Exception as e:
        BuiltIn().log("Analysis has not started: %s!!!" % e)
    tcResultJsonDict = json.dumps(tcResultDict, sort_keys=True, indent=4)
    BuiltIn().log_to_console("verify_f1xn_trace(): tcResultDict = %s" % tcResultJsonDict)
    BuiltIn().log("verify_f1xn_trace(): tcResultDict = %s" % tcResultJsonDict)
    if "failed" in tcResultDict.values():
        result = "failed"
        failed_messages = [k for k, v in tcResultDict.items() if v == 'failed']
        BuiltIn().log_to_console("Failed points: %s" % failed_messages)
    else:
        result = "passed"
    BuiltIn().log_to_console("Verify F1 Xn trace of 5GC000706-FD-07: %s" % result)
    if result == "failed":
        BuiltIn().fail('Verification of F1 Xn trace of 5GC000706-FD-07 failed')
# --------------------------------------------------------------------------------------


def verify_f1xn_trace_FD05(pdml_file_path, xnap):
    """Keyword: Verify F1 Xn trace FD05"""
    BuiltIn().log_to_console("-" * 65)
    BuiltIn().log_to_console("Verify F1 Xn trace of 5GC000706-FD05:")
    testname = BuiltIn().get_variable_value("${TEST NAME}")
    BuiltIn().log_to_console(testname)
    # ================================================================================================================
    tcResultDict = {}
    if not os.path.isfile(pdml_file_path):
        raise AssertionError("verify_f1xn_trace(): %s does not exist!!!" % pdml_file_path)
    try:
        with open(pdml_file_path, 'rb') as file_obj:
            for entry in PdmlReader(file_obj=file_obj):
                root = entry.packet
                tcResultDict["UEContextSetupRequest"] = verify_UEContextSetupRequest(root, pdml_file_path)
                tcResultDict["UEContextModificationRequest"] = \
                    verify_UEContextModificationRequest(root, pdml_file_path)
                tcResultDict["drxConfig"] = verify_rrc_drxConfig(root)
                tcResultDict["eventCheck"] = verify_rrc_events(root, pdml_file_path)
                tcResultDict["RRCReconfiguration_measGap"] = verify_rrcReconfiguration_measGap(root)
                tcResultDict["measurementReport"] = verify_measurement_report(root)
            tcResultDict["InterGnbHOSequence"] = \
                verify_inter_gnb_handover_sequence(pdml_file_path, xnap)
    except Exception as e:
        BuiltIn().log("Analysis has not started: %s!!!" % e)
    tcResultJsonDict = json.dumps(tcResultDict, sort_keys=True, indent=4)
    BuiltIn().log_to_console("verify_f1xn_trace(): tcResultDict = %s" % tcResultJsonDict)
    BuiltIn().log("verify_f1xn_trace(): tcResultDict = %s" % tcResultJsonDict)
    if "failed" in tcResultDict.values():
        result = "failed"
        failed_messages = [k for k, v in tcResultDict.items() if v == 'failed']
        BuiltIn().log_to_console("Failed points: %s" % failed_messages)
    else:
        result = "passed"
    BuiltIn().log_to_console("Verify F1 Xn trace of 5GC000706-FD-05: %s" % result)
    if result == "failed":
        BuiltIn().fail('Verification of F1 Xn trace of 5GC000706-FD-05 failed')

# ================================================================================================================


def verify_f1xn_trace_Pathswitchsequence(pdml_file_path, xnap):
    """Keyword: Verify F1 Xn trace Pathswitchsequence"""
    BuiltIn().log_to_console("-" * 65)
    BuiltIn().log_to_console("Verify F1 Xn trace of Pathswitchsequence:")
    testname = BuiltIn().get_variable_value("${TEST NAME}")
    BuiltIn().log_to_console(testname)
    # ================================================================================================================
    tcResultDict = {}
    if not os.path.isfile(pdml_file_path):
        raise AssertionError("verify_f1xn_trace(): %s does not exist!!!" % pdml_file_path)
    try:
        with open(pdml_file_path, 'rb') as file_obj:
            tcResultDict["PathSwitchSequence"] = \
                verify_path_switch_sequence(pdml_file_path)
    except Exception as e:
        BuiltIn().log("Analysis has not started: %s!!!" % e)
    tcResultJsonDict = json.dumps(tcResultDict, sort_keys=True, indent=4)
    BuiltIn().log_to_console("verify_f1xn_trace(): tcResultDict = %s" % tcResultJsonDict)
    BuiltIn().log("verify_f1xn_trace(): tcResultDict = %s" % tcResultJsonDict)
    if "failed" in tcResultDict.values():
        result = "failed"
        failed_messages = [k for k, v in tcResultDict.items() if v == 'failed']
        BuiltIn().log_to_console("Failed points: %s" % failed_messages)
    else:
        result = "passed"
    BuiltIn().log_to_console("Verify F1 Xn trace Pathswitchsequence: %s" % result)
    if result == "failed":
        BuiltIn().fail('Verification of F1 Xn trace failed Pathswitchsequence')


def verify_f1xn_trace_FD02(pdml_file_path):
    """Keyword: Verify F1 Xn trace FD02"""
    BuiltIn().log_to_console("-" * 65)
    BuiltIn().log_to_console("Verify F1 Xn trace of 5GC000706-FD02:")
    testname = BuiltIn().get_variable_value("${TEST NAME}")
    BuiltIn().log_to_console(testname)
    # ================================================================================================================
    tcResultDict = {}
    if not os.path.isfile(pdml_file_path):
        raise AssertionError("verify_f1xn_trace(): %s does not exist!!!" % pdml_file_path)
    try:
        with open(pdml_file_path, 'rb') as file_obj:
            for entry in PdmlReader(file_obj=file_obj):
                root = entry.packet
                tcResultDict["UEContextSetupRequest"] = verify_UEContextSetupRequest(root, pdml_file_path)
                tcResultDict["UEContextModificationRequest"] = \
                    verify_UEContextModificationRequest(root, pdml_file_path)
                tcResultDict["eventCheck"] = verify_rrc_events(root, pdml_file_path)
                tcResultDict["reconfigurationWithSync"] = verify_rrc_reconfigurationWithSync(root)
                tcResultDict["RRCReconfiguration_measGap"] = verify_rrcReconfiguration_measGap(root)
                tcResultDict["measurementReport"] = verify_measurement_report(root)
            tcResultDict["IntraGnbHOSequence"] = verify_intra_gnb_handover_sequence(pdml_file_path)
    except Exception as e:
        BuiltIn().log("Analysis has not started: %s!!!" % e)
    tcResultJsonDict = json.dumps(tcResultDict, sort_keys=True, indent=4)
    BuiltIn().log_to_console("verify_f1xn_trace(): tcResultDict = %s" % tcResultJsonDict)
    BuiltIn().log("verify_f1xn_trace(): tcResultDict = %s" % tcResultJsonDict)
    if "failed" in tcResultDict.values():
        result = "failed"
        failed_messages = [k for k, v in tcResultDict.items() if v == 'failed']
        BuiltIn().log_to_console("Failed points: %s" % failed_messages)
    else:
        result = "passed"
    BuiltIn().log_to_console("Verify F1 Xn trace of 5GC000706-FD-02: %s" % result)
    if result == "failed":
        BuiltIn().fail('Verification of F1 Xn trace 5GC000706-FD-02 failed')

# -------------------------------------------------------------------------------------


def verify_f1xn_trace_C02(pdml_file_path, xnap):
    """Keyword: Verify F1 Xn trace C02"""
    BuiltIn().log_to_console("-" * 65)
    BuiltIn().log_to_console("Verify F1 Xn trace of 5GC000706-C02:")
    testname = BuiltIn().get_variable_value("${TEST NAME}")
    BuiltIn().log_to_console(testname)
    # ================================================================================================================
    tcResultDict = {}
    if not os.path.isfile(pdml_file_path):
        raise AssertionError("verify_f1xn_trace(): %s does not exist!!!" % pdml_file_path)
    try:
        with open(pdml_file_path, 'rb') as file_obj:
            for entry in PdmlReader(file_obj=file_obj):
                root = entry.packet
                tcResultDict["UEContextSetupRequest"] = verify_UEContextSetupRequest(root, pdml_file_path)
                tcResultDict["UEContextModificationRequest"] = \
                    verify_UEContextModificationRequest(root, pdml_file_path)
                tcResultDict["drxConfig"] = verify_rrc_drxConfig(root)
                tcResultDict["eventCheck"] = verify_rrc_events(root, pdml_file_path)
                tcResultDict["reconfigurationWithSync"] = verify_rrc_reconfigurationWithSync(root)
                tcResultDict["RRCReconfiguration_measGap"] = verify_rrcReconfiguration_measGap(root)
                tcResultDict["measurementReport"] = verify_measurement_report(root)
            tcResultDict["IntraGnbHOSequence"] = \
                verify_intra_gnb_handover_sequence(pdml_file_path, xnap)
    except Exception as e:
        BuiltIn().log("Analysis has not started: %s!!!" % e)
    tcResultJsonDict = json.dumps(tcResultDict, sort_keys=True, indent=4)
    BuiltIn().log_to_console("verify_f1xn_trace(): tcResultDict = %s" % tcResultJsonDict)
    BuiltIn().log("verify_f1xn_trace(): tcResultDict = %s" % tcResultJsonDict)
    if "failed" in tcResultDict.values():
        result = "failed"
        failed_messages = [k for k, v in tcResultDict.items() if v == 'failed']
        BuiltIn().log_to_console("Failed points: %s" % failed_messages)
    else:
        result = "passed"
    BuiltIn().log_to_console("Verify F1 Xn trace of 5GC000706-C02: %s" % result)
    if result == "failed":
        BuiltIn().fail('Verification of F1 Xn trace C02 failed')

# ----------------------------------------------------------------------------------------------


def verify_f1xn_trace_C03(pdml_file_path, xnap):
    """Keyword: Verify F1 Xn trace C03"""
    BuiltIn().log_to_console("-" * 65)
    BuiltIn().log_to_console("Verify F1 Xn trace of 5GC000706-C03:")
    testname = BuiltIn().get_variable_value("${TEST NAME}")
    BuiltIn().log_to_console(testname)
    # ================================================================================================================
    tcResultDict = {}
    if not os.path.isfile(pdml_file_path):
        raise AssertionError("verify_f1xn_trace(): %s does not exist!!!" % pdml_file_path)
    try:
        with open(pdml_file_path, 'rb') as file_obj:
            for entry in PdmlReader(file_obj=file_obj):
                root = entry.packet
                tcResultDict["UEContextSetupRequest"] = verify_UEContextSetupRequest(root, pdml_file_path)
                tcResultDict["UEContextModificationRequest"] = \
                    verify_UEContextModificationRequest(root, pdml_file_path)
                tcResultDict["eventCheck"] = verify_rrc_events(root, pdml_file_path)
                tcResultDict["reconfigurationWithSync"] = verify_rrc_reconfigurationWithSync(root)
            tcResultDict["InterGnbHOSequence"] = \
                verify_inter_gnb_handover_sequence(pdml_file_path, xnap)
    except Exception as e:
        BuiltIn().log("Analysis has not started: %s!!!" % e)
    tcResultJsonDict = json.dumps(tcResultDict, sort_keys=True, indent=4)
    BuiltIn().log_to_console("verify_f1xn_trace(): tcResultDict = %s" % tcResultJsonDict)
    BuiltIn().log("verify_f1xn_trace(): tcResultDict = %s" % tcResultJsonDict)
    if "failed" in tcResultDict.values():
        result = "failed"
        failed_messages = [k for k, v in tcResultDict.items() if v == 'failed']
        BuiltIn().log_to_console("Failed points: %s" % failed_messages)
    else:
        result = "passed"
    BuiltIn().log_to_console("Verify F1 Xn trace of 5GC000706-C03: %s" % result)
    if result == "failed":
        BuiltIn().fail('Verification of F1 Xn trace C03 failed')
# ---------------------------------------------------------------------------------------------------------------------


def verify_UEContextModificationRequest(root, pdml_file_path):
    tcResult = "passed"
    elements = ["f1ap.UEContextModificationRequest_element"]
    if all(x in root.keys() for x in elements):
        BuiltIn().log("============================== Begin verify_UEContextModificationRequest()")
        BuiltIn().log_to_console("-" * 65)
        # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ueContextMod = root.xpath("f1ap//..//f1ap.UEContextModificationRequest_element")[0].showname
        BuiltIn().log_to_console("%s" % ueContextMod)
        BuiltIn().log_to_console("-" * 65)
        # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        try:
            if root.xpath("f1ap//..//f1ap.UEContextModificationRequest_element"):
                event_ids = root.xpath("f1ap//..//nr-rrc.ReportConfigToAddMod_element//..//nr-rrc.eventId")
                for idx, event_id in enumerate(event_ids):
                    if "eventA3" in event_id.showname:
                        event_id_A3 = BuiltIn().run_keyword("find_a3_measurement_id_SA", pdml_file_path)
                        BuiltIn().log("find_a3_measurement_id():  %s %s" % (event_id_A3, event_id.showname))
                        tcResult = "passed"
                        BuiltIn().log_to_console("find_a3_measurement_id():  %s %s" % (event_id_A3, event_id.showname))
                    elif "eventA5" in event_id.showname:
                        event_id_A5 = BuiltIn().run_keyword("find_a5_measurement_id_SA", pdml_file_path)
                        BuiltIn().log("find_a5_measurement_id():  %s %s" % (event_id_A5, event_id.showname))
                        BuiltIn().log_to_console("find_a5_measurement_id():  %s %s" % (event_id_A5, event_id.showname))
                        tcResult = "passed"
                    elif "eventA1" in event_id.showname:
                        event_id_A1 = BuiltIn().run_keyword("find_a1_measurement_id_SA", pdml_file_path)
                        BuiltIn().log("find_a1_measurement_id():  %s %s" % (event_id_A1, event_id.showname))
                        BuiltIn().log_to_console("find_a1_measurement_id():  %s %s" % (event_id_A1, event_id.showname))
                        tcResult = "passed"
                    else:
                        BuiltIn().log("No events found")
                        BuiltIn().log_to_console("No events found")
                        tcResult = "failed"
        except Exception as e:
            BuiltIn().log("verify_UEContextModificationRequest(): %s" % e)
            tcResult = "failed"
            # pass
        # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        BuiltIn().log_to_console("-" * 65)
        BuiltIn().log_to_console(tcResult)
        BuiltIn().log_to_console("-" * 65)
        BuiltIn().log("verify_UEContextModificationRequest(): tcResult = %s" % tcResult)
        BuiltIn().log("============================== End verify_UEContextModificationRequest()")
    return tcResult


def verify_UEContextSetupRequest(root, pdml_file_path):
    tcResult = "passed"
    elements = ["f1ap.UEContextSetupRequest_element"]
    if all(x in root.keys() for x in elements):
        BuiltIn().log("============================== Begin verify_UEContextSetupRequest()")
        BuiltIn().log_to_console("-" * 65)
        # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        ueContextSetup = root.xpath("f1ap//..//f1ap.UEContextSetupRequest_element")[0].showname
        BuiltIn().log_to_console("%s" % ueContextSetup)
        BuiltIn().log_to_console("-" * 65)
        # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        try:
            if root.xpath("f1ap//..//f1ap.UEContextSetupRequest_element"):
                event_ids = root.xpath("f1ap//..//nr-rrc.ReportConfigToAddMod_element//..//nr-rrc.eventId")
                for idx, event_id in enumerate(event_ids):
                    if "eventA2" in event_id.showname:
                        event_id_A2 = BuiltIn().run_keyword("find_a2_measurement_id_SA", pdml_file_path)
                        BuiltIn().log("find_a2_measurement_id():  %s %s" % (event_id_A2, event_id.showname))
                        BuiltIn().log_to_console(
                            "find_a2_measurement_id():  %s %s" % (event_id_A2, event_id.showname))
                        tcResult = "passed"
                    elif "eventA3" in event_id.showname:
                        event_id_A3 = BuiltIn().run_keyword("find_a3_measurement_id_SA", pdml_file_path)
                        BuiltIn().log("find_a3_measurement_id():  %s %s" % (event_id_A3, event_id.showname))
                        BuiltIn().log_to_console(
                            "find_a3_measurement_id():  %s %s" % (event_id_A3, event_id.showname))
                        tcResult = "passed"
                    elif "eventA5" in event_id.showname:
                        event_id_A5 = BuiltIn().run_keyword("find_a5_measurement_id_SA", pdml_file_path)
                        BuiltIn().log("find_a5_measurement_id():  %s %s" % (event_id_A5, event_id.showname))
                        BuiltIn().log_to_console(
                            "find_a5_measurement_id():  %s %s" % (event_id_A5, event_id.showname))
                        tcResult = "passed"
                    elif "eventA1" in event_id.showname:
                        event_id_A1 = BuiltIn().run_keyword("find_a1_measurement_id_SA", pdml_file_path)
                        BuiltIn().log("find_a1_measurement_id():  %s %s" % (event_id_A1, event_id.showname))
                        BuiltIn().log_to_console(
                            "find_a1_measurement_id():  %s %s" % (event_id_A1, event_id.showname))
                        tcResult = "passed"
                    else:
                        tcResult = "failed"
        except Exception as e:
            BuiltIn().log("verify_UEContextSetupRequest(): %s" % e)
            tcResult = "failed"
        # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        BuiltIn().log_to_console("-" * 65)
        BuiltIn().log_to_console(tcResult)
        BuiltIn().log_to_console("-" * 65)
        BuiltIn().log("verify_UEContextSetupRequest(): tcResult = %s" % tcResult)
        BuiltIn().log("============================== End verify_UEContextSetupRequest()")
    return tcResult


def verify_measurement_report(root):
    tcResult = "passed"
    if "nr-rrc.measurementReport_element" in root.keys():
        BuiltIn().log("============================== Begin verify_measurement_report()")
        BuiltIn().log_to_console("-" * 65)
        measurementReport = root.xpath("f1ap//..//nr-rrc.measurementReport_element")[0].showname
        BuiltIn().log_to_console("%s" % measurementReport)
        BuiltIn().log_to_console("-" * 65)
        # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        try:
            if root.xpath("f1ap//..//nr-rrc.servCellId//..//nr-rrc.physCellId"):
                serving_physCellId = root.xpath("f1ap//..//nr-rrc.servCellId//..//nr-rrc.physCellId")
                BuiltIn().log("verify_handover(): Serving cell physCellId = %s" % serving_physCellId)
                BuiltIn().log_to_console(". serving physCellId = %s" % serving_physCellId[0].show)
                serving_cell_rsrp = root.xpath("f1ap//..//nr-rrc.servCellId//..//nr-rrc.rsrp")
                BuiltIn().log_to_console(". serving rsrp = %s" % serving_cell_rsrp[0].showname)
                serving_cell_rsrq = root.xpath("f1ap//..//nr-rrc.servCellId//..//nr-rrc.rsrq")
                BuiltIn().log_to_console(". serving rsrq = %s" % serving_cell_rsrq[0].showname)
                tcResult = "passed"
        except Exception as e:
            BuiltIn().log("verify_measurement_report() - nr-rrc.servCellId: %s" % e)
            tcResult = "failed"
        # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        try:
            if root.xpath("f1ap//..//nr-rrc.measResultNeighCells//nr-rrc.physCellId"):
                target_physCellId = root.xpath("f1ap//..//nr-rrc.measResultNeighCells//nr-rrc.physCellId")
                BuiltIn().log("verify_handover(): Target cell physCellId = %s" % target_physCellId)
                BuiltIn().log_to_console(". target physCellId = %s" % target_physCellId[0].show)
                target_cell_rsrp = \
                    root.xpath("f1ap//..//nr-rrc.measResultNeighCells//nr-rrc.physCellId//..//nr-rrc.rsrp")
                BuiltIn().log_to_console(". target rsrp = %s" % target_cell_rsrp[0].showname)
                target_cell_rsrq = \
                    root.xpath("f1ap//..//nr-rrc.measResultNeighCells//nr-rrc.physCellId//..//nr-rrc.rsrq")
                BuiltIn().log_to_console(". target rsrq = %s" % target_cell_rsrq[0].showname)
                tcResult = "passed"
        except Exception as e:
            BuiltIn().log("verify_measurement_report() - target_physCellId: %s" % e)
            tcResult = "failed"
        # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        BuiltIn().log_to_console("-" * 65)
        BuiltIn().log_to_console(tcResult)
        BuiltIn().log_to_console("-" * 65)
        BuiltIn().log(tcResult)
        BuiltIn().log("verify_measurement_report(): tcResult = %s" % tcResult)
        BuiltIn().log("============================== End verify_measurement_report()")
    return tcResult


def verify_HandoverRequest(root, xnap):
    tcResult = "passed"
    xnap_req_ho_element = ["{}.HandoverRequest_element".format(xnap)]
    if all(x in root.keys() for x in elements):
        BuiltIn().log("============================== Begin verify_HandoverRequest()")
        BuiltIn().log_to_console("-" * 65)
        sgNBModReq = root.xpath("xnap//..//{}".format(xnap_req_ho_element))[0].showname
        BuiltIn().log_to_console("%s" % sgNBModReq)
        BuiltIn().log_to_console("-" * 65)
        # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        try:
            xnap_req_ho_cause = ["{}.HandoverRequest_element//{}.Cause".format(xnap, xnap)]
            cause = root.xpath(xnap_req_ho_cause)
            BuiltIn().log("verify_HandoverRequest(): Handover Cause = %s" % cause[0].showname)
            BuiltIn().log_to_console("%s" % cause[0].showname)
            tcResult = "passed"
        except Exception as e:
            BuiltIn().log("verify_HandoverRequest(): %s" % e)
            tcResult = "failed"
            BuiltIn().log("============================== End verify_HandoverRequest()")
        # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        BuiltIn().log_to_console("-" * 65)
        BuiltIn().log_to_console(tcResult)
        BuiltIn().log_to_console("-" * 65)
        BuiltIn().log("verify_HandoverRequest(): tcResult = %s" % tcResult)
        BuiltIn().log("============================== End verify_HandoverRequest()")
    return tcResult


def verify_rrc_reconfigurationWithSync(root):
    tcResult = "passed"
    elements = ["nr-rrc.rrcReconfiguration_element"]
    if all(x in root.keys() for x in elements):
        BuiltIn().log("============================== Begin verify_rrc_reconfigurationWithSync()")
        BuiltIn().log_to_console("-" * 65)
        rrcReconfiguration = root.xpath("f1ap//..//nr-rrc.rrcReconfiguration_element")[0].showname
        BuiltIn().log_to_console("reconfigurationWithSync: %s" % rrcReconfiguration)
        BuiltIn().log_to_console("-" * 65)
        # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        try:
            reconfigWithSync = root.xpath("f1ap//..//nr-rrc.reconfigurationWithSync_element")
            if reconfigWithSync:
                BuiltIn().log(" %s" % reconfigWithSync[0].showname)
                BuiltIn().log_to_console(" %s" % reconfigWithSync[0].showname)
                if "reconfigurationWithSync" in reconfigWithSync[0].showname:
                    phycell = root.xpath("f1ap//..//nr-rrc.spCellConfigCommon_element//nr-rrc.physCellId")[0].showname
                    BuiltIn().log("Found Cell %s for reconfigWithSync " % phycell)
                    BuiltIn().log_to_console("Found Cell %s for reconfigWithSync " % phycell)
                    tcResult = "passed"
        except Exception as e:
            BuiltIn().log("verify_rrc_reconfigurationWithSync(): %s" % e)
            BuiltIn().log_to_sonsole("verify_rrc_reconfigurationWithSync(): %s" % e)
            tcResult = "failed"
        # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        BuiltIn().log_to_console("-" * 65)
        BuiltIn().log_to_console(tcResult)
        BuiltIn().log_to_console("-" * 65)
        BuiltIn().log("verify_rrc_reconfigurationWithSync(): tcResult = %s" % tcResult)
        BuiltIn().log("============================== End verify_rrc_reconfigurationWithSync()")
    return tcResult


def verify_rrcReconfiguration_measGap(root):
    tcResult = "passed"
    elements = ["nr-rrc.rrcReconfiguration_element"]
    if all(x in root.keys() for x in elements):
        BuiltIn().log("============================== Begin verify_rrcReconfiguration_measGap()")
        BuiltIn().log_to_console("-" * 65)
        rrcReconfiguration = root.xpath("f1ap//..//nr-rrc.rrcReconfiguration_element")[0].showname
        BuiltIn().log_to_console("MeasGap: %s" % rrcReconfiguration)
        BuiltIn().log_to_console("-" * 65)
        # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        try:
            measGapConfig = root.xpath("f1ap//..//nr-rrc.gapUE")
            if measGapConfig:
                BuiltIn().log(" %s" % measGapConfig[0].showname)
                BuiltIn().log_to_console(" %s" % measGapConfig[0].showname)
                if "setup" in measGapConfig[0].showname:
                    setup = root.xpath("f1ap//..//nr-rrc.gapUE//nr-rrc.setup_element")[0].showname
                    BuiltIn().log("Found: %s in measGapConfig " % setup)
                    BuiltIn().log_to_console("Found: %s in measGapConfig " % setup)
                    tcResult = "passed"
                elif "release" in measGapConfig[0].showname:
                    release = root.xpath("f1ap//..//nr-rrc.gapUE//nr-rrc.release_element")[0].showname
                    BuiltIn().log("Found: %s in measGapConfig " % release)
                    BuiltIn().log_to_console("Found: %s in measGapConfig" % release)
                    tcResult = "passed"
        except Exception as e:
            BuiltIn().log("verify_rrcReconfiguration_measGap(): %s" % e)
            tcResult = "failed"
        # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        BuiltIn().log_to_console("-" * 65)
        BuiltIn().log_to_console(tcResult)
        BuiltIn().log_to_console("-" * 65)
        BuiltIn().log("verify_rrcReconfiguration_measGap(): tcResult = %s" % tcResult)
        BuiltIn().log("============================== End verify_rrcReconfiguration_measGap()")
    return tcResult


def verify_rrc_events(root, pdml_file_path):
    tcResult = "passed"
    elements = ["nr-rrc.rrcReconfiguration_element"]
    if all(x in root.keys() for x in elements):
        BuiltIn().log("============================== Begin verify_rrc_events()")
        BuiltIn().log_to_console("-" * 65)
        rrcReconfiguration = root.xpath("f1ap//..//nr-rrc.rrcReconfiguration_element")[0].showname
        BuiltIn().log_to_console("rrc_events: %s" % rrcReconfiguration)
        BuiltIn().log_to_console("-" * 65)
        # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        try:
            if root.xpath("f1ap//..//nr-rrc.rrcReconfiguration_element"):
                event_ids = root.xpath("f1ap//..//nr-rrc.ReportConfigToAddMod_element//..//nr-rrc.eventId")
                for idx, event_id in enumerate(event_ids):
                    if "eventA2" in event_id.showname:
                        event_id_A2 = BuiltIn().run_keyword("find_a2_measurement_id_SA", pdml_file_path)
                        BuiltIn().log("find_a2_measurement_id():  %s %s" % (event_id_A2, event_id.showname))
                        BuiltIn().log_to_console("find_a2_measurement_id():  %s %s" % (event_id_A2, event_id.showname))
                        tcResult = "passed"
                    if "eventA3" in event_id.showname:
                        event_id_A3 = BuiltIn().run_keyword("find_a3_measurement_id_SA", pdml_file_path)
                        BuiltIn().log("find_a3_measurement_id():  %s %s" % (event_id_A3, event_id.showname))
                        BuiltIn().log_to_console("find_a3_measurement_id():  %s %s" % (event_id_A3, event_id.showname))
                        tcResult = "passed"
                    if "eventA5" in event_id.showname:
                        event_id_A5 = BuiltIn().run_keyword("find_a5_measurement_id_SA", pdml_file_path)
                        BuiltIn().log("find_a5_measurement_id():  %s %s" % (event_id_A5, event_id.showname))
                        BuiltIn().log_to_console("find_a5_measurement_id():  %s %s" % (event_id_A5, event_id.showname))
                        tcResult = "passed"
                    if "eventA1" in event_id.showname:
                        event_id_A1 = BuiltIn().run_keyword("find_a1_measurement_id_SA", pdml_file_path)
                        BuiltIn().log("find_a1_measurement_id():  %s %s" % (event_id_A1, event_id.showname))
                        BuiltIn().log_to_console("find_a1_measurement_id():  %s %s" % (event_id_A1, event_id.showname))
                        tcResult = "passed"
        except Exception as e:
            BuiltIn().log("verify_rrc_events: %s" % e)
            tcResult = "failed"
            # pass
        # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        BuiltIn().log_to_console("-" * 65)
        BuiltIn().log_to_console(tcResult)
        BuiltIn().log_to_console("-" * 65)
        BuiltIn().log("verify_rrc_events(): tcResult = %s" % tcResult)
        BuiltIn().log("============================== End verify_rrc_events()")
    return tcResult


def verify_rrc_drxConfig(root):
    tcResult = "passed"
    elements = ["nr-rrc.rrcReconfiguration_element"]
    if all(x in root.keys() for x in elements):
        BuiltIn().log("============================== Begin verify_rrc_drxConfig()")
        BuiltIn().log_to_console("-" * 65)
        rrcReconfiguration = root.xpath("f1ap//..//nr-rrc.rrcReconfiguration_element")[0].showname
        BuiltIn().log_to_console("rrc_drxConfig: %s" % rrcReconfiguration)
        BuiltIn().log_to_console("-" * 65)
        try:
            drxConfig = root.xpath("f1ap//..//nr-rrc.mac_CellGroupConfig_element//nr-rrc.drx_Config")[0].showname
            BuiltIn().log(" %s" % drxConfig)
            BuiltIn().log_to_console(" %s" % drxConfig)
            if "setup" in drxConfig:
                setup = root.xpath("f1ap//..//nr-rrc.drx_Config//nr-rrc.setup_element")[0].showname
                BuiltIn().log("Found: %s in drxConfig " % setup)
                BuiltIn().log_to_console("Found: %s in drxConfig " % setup)
                drx_onDurationTimer = \
                    root.xpath("f1ap//..//nr-rrc.setup_element//nr-rrc.drx_onDurationTimer")[0].showname
                BuiltIn().log(". Found: %s" % drx_onDurationTimer)
                BuiltIn().log_to_console(". Found: %s" % drx_onDurationTimer)
                drx_InactivityTimer = \
                    root.xpath("f1ap//..//nr-rrc.setup_element//nr-rrc.drx_InactivityTimer")[0].showname
                BuiltIn().log(". Found: %s" % drx_InactivityTimer)
                BuiltIn().log_to_console(". Found: %s" % drx_InactivityTimer)
                drx_HARQ_RTT_TimerDL = \
                    root.xpath("f1ap//..//nr-rrc.setup_element//nr-rrc.drx_HARQ_RTT_TimerDL")[0].showname
                BuiltIn().log(". Found: %s" % drx_HARQ_RTT_TimerDL)
                BuiltIn().log_to_console(". Found: %s" % drx_HARQ_RTT_TimerDL)
                drx_HARQ_RTT_TimerUL = \
                    root.xpath("f1ap//..//nr-rrc.setup_element//nr-rrc.drx_HARQ_RTT_TimerUL")[0].showname
                BuiltIn().log(". Found: %s" % drx_HARQ_RTT_TimerUL)
                BuiltIn().log_to_console(". Found: %s" % drx_HARQ_RTT_TimerUL)
                drx_RetransmissionTimerDL = \
                    root.xpath("f1ap//..//nr-rrc.setup_element//nr-rrc.drx_RetransmissionTimerDL")[0].showname
                BuiltIn().log(". Found: %s" % drx_RetransmissionTimerDL)
                BuiltIn().log_to_console(". Found: %s" % drx_RetransmissionTimerDL)
                drx_RetransmissionTimerUL = \
                    root.xpath("f1ap//..//nr-rrc.setup_element//nr-rrc.drx_RetransmissionTimerUL")[0].showname
                BuiltIn().log(". Found: %s" % drx_RetransmissionTimerUL)
                BuiltIn().log_to_console(". Found: %s" % drx_RetransmissionTimerUL)
                drx_LongCycleStartOffset = \
                    root.xpath("f1ap//..//nr-rrc.setup_element//nr-rrc.drx_LongCycleStartOffset")[0].showname
                BuiltIn().log(". Found: %s" % drx_LongCycleStartOffset)
                BuiltIn().log_to_console(". Found: %s" % drx_LongCycleStartOffset)
                drx_SlotOffset = \
                    root.xpath("f1ap//..//nr-rrc.setup_element//nr-rrc.drx_SlotOffset")[0].showname
                BuiltIn().log(". Found: %s" % drx_SlotOffset)
                BuiltIn().log_to_console(". Found: %s" % drx_SlotOffset)
                tcResult = "passed"
            elif "release" in drxConfig:
                release = root.xpath("f1ap//..//nr-rrc.drx_Config//nr-rrc.release_element")[0].showname
                BuiltIn().log("Found: %s in drxConfig " % release)
                BuiltIn().log_to_console("Found: %s in drxConfig" % release)
                tcResult = "passed"
            else:
                BuiltIn().log("No drxConfig found")
                BuiltIn().log_to_console("No drxConfig found")
                pass
        except Exception as e:
            BuiltIn().log("verify_rrcReconfiguration: %s" % e)
            tcResult = "failed"
            # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        BuiltIn().log_to_console("-" * 65)
        BuiltIn().log_to_console(tcResult)
        BuiltIn().log_to_console("-" * 65)
        BuiltIn().log("verify_rrc_drxConfig(): tcResult = %s" % tcResult)
        BuiltIn().log("============================== End verify_rrc_drxConfig()")
    return tcResult


def verify_rrcRelease(root):
    tcResult = "passed"
    elements = ["nr-rrc.rrcRelease_element"]
    if all(x in root.keys() for x in elements):
        BuiltIn().log("============================== Begin verify_rrcRelease()")
        BuiltIn().log_to_console("-" * 65)
        try:
            rrcRelease = root.xpath("f1ap//..//nr-rrc.rrcRelease_element")[0].showname
            BuiltIn().log_to_console("rrcRelease: %s" % rrcRelease)
            BuiltIn().log_to_console("-" * 65)
            tcResult = "passed"
        except Exception as e:
            BuiltIn().log("verify_rrcRelease: %s" % e)
            tcResult = "failed"
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        BuiltIn().log_to_console("-" * 65)
        BuiltIn().log_to_console(tcResult)
        BuiltIn().log_to_console("-" * 65)
        BuiltIn().log("verify_rrcRelease(): tcResult = %s" % tcResult)
        BuiltIn().log("============================== End verify_rrcRelease()")
    return tcResult


def verify_intra_gnb_handover_sequence(pdml_file_path):
    BuiltIn().log("============================== Begin verify_intra_gnb_handover_sequence()")
    tcResult = "passed"
    field_name_list = ["nr-rrc.measurementReport_element", "nr-rrc.rrcReconfiguration_element",
                       "nr-rrc.rrcReconfigurationComplete_element"]
    message_sequence = "rrcReconfiguration.*" \
                       "rrcReconfigurationComplete.*" \
                       "measurementReport.*" \
                       "rrcReconfiguration.*" \
                       "rrcReconfigurationComplete"
    try:
        BuiltIn().log("verify_intra_gnb_handover_sequence(): pdml_file_path = %s" % pdml_file_path)
        BuiltIn().log("verify_intra_gnb_handover_sequence(): field_name_list = %s" % field_name_list)
        BuiltIn().log("verify_intra_gnb_handover_sequence(): message_sequence = %s" % message_sequence)
        pdml().check_msc(pdml_file_path, field_name_list, message_sequence)
    except Exception as e:
        BuiltIn().log("verify_intra_gnb_handover_sequence(): %s" % e)
        tcResult = "failed"
    BuiltIn().log("============================== End verify_intra_gnb_handover_sequence()")
    return tcResult

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


def verify_inter_gnb_handover_sequence(pdml_file_path, xnap):
    BuiltIn().log("============================== Begin verify_inter_gnb_handover_sequence()")
    tcResult = "passed"
    xnap_req_ho_element = "{}.HandoverRequest_element".format(xnap)
    xnap_req_ack_element = "{}.HandoverRequestAcknowledge_element".format(xnap)
    field_name_list = ["nr-rrc.measurementReport_element", "nr-rrc.rrcReconfiguration_element",
                       "nr-rrc.rrcReconfigurationComplete_element", xnap_req_ho_element,
                       "nr-rrc.measurementReport_element", xnap_req_ack_element,
                       "nr-rrc.rrcReconfiguration_element", "nr-rrc.rrcReconfigurationComplete_element"]
    message_sequence = "rrcReconfiguration.*" \
                       "rrcReconfigurationComplete.*" \
                       "measurementReport.*" \
                       "HandoverRequest.*" \
                       "HandoverRequestAcknowledge.*" \
                       "rrcReconfiguration"
    try:
        BuiltIn().log("verify_inter_gnb_handover_sequence(): pdml_file_path = %s" % pdml_file_path)
        BuiltIn().log("verify_inter_gnb_handover_sequence(): field_name_list = %s" % field_name_list)
        BuiltIn().log("verify_inter_gnb_handover_sequence(): message_sequence = %s" % message_sequence)
        pdml().check_msc(pdml_file_path, field_name_list, message_sequence)
    except Exception as e:
        BuiltIn().log("verify_inter_gnb_handover_sequence(): %s" % e)
        tcResult = "failed"
    BuiltIn().log("============================== End verify_inter_gnb_handover_sequence()")
    return tcResult

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


def verify_path_switch_sequence(pdml_file_path):
    BuiltIn().log("============================== Begin path_switch_sequence()")
    tcResult = "passed"
    field_name_list = ["ngap.PathSwitchRequest_element", "ngap.PathSwitchRequestAcknowledge_element"]
    message_sequence = "PathSwitchRequest.*" \
                       "PathSwitchRequestAcknowledge"
    try:
        BuiltIn().log("verify_path_switch_sequence(): pdml_file_path = %s" % pdml_file_path)
        BuiltIn().log("verify_path_switch_sequence(): field_name_list = %s" % field_name_list)
        BuiltIn().log("verify_path_switch_sequence(): message_sequence = %s" % message_sequence)
        pdml().check_msc(pdml_file_path, field_name_list, message_sequence)
    except Exception as e:
        BuiltIn().log("verify_path_switch_sequence(): %s" % e)
        tcResult = "failed"
    BuiltIn().log("============================== End verify_path_switch_sequence()")
    return tcResult

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


def verify_f1xn_trace_InterGNBsequence(pdml_file_path, xnap):
    """Keyword: Verify F1 Xn trace InterGnbHOSequence"""
    BuiltIn().log_to_console("-" * 65)
    BuiltIn().log_to_console("Verify F1 Xn trace of InterGnbHOSequence:")
    testname = BuiltIn().get_variable_value("${TEST NAME}")
    BuiltIn().log_to_console(testname)
    # ================================================================================================================
    tcResultDict = {}
    if not os.path.isfile(pdml_file_path):
        raise AssertionError("verify_f1xn_trace(): %s does not exist!!!" % pdml_file_path)
    try:
        with open(pdml_file_path, 'rb') as file_obj:
            tcResultDict["InterGnbHOSequence"] = \
                verify_inter_gnb_handover_sequence(pdml_file_path, xnap)
    except Exception as e:
        BuiltIn().log("Analysis has not started: %s!!!" % e)
    tcResultJsonDict = json.dumps(tcResultDict, sort_keys=True, indent=4)
    BuiltIn().log_to_console("verify_f1xn_trace(): tcResultDict = %s" % tcResultJsonDict)
    BuiltIn().log("verify_f1xn_trace(): tcResultDict = %s" % tcResultJsonDict)
    if "failed" in tcResultDict.values():
        result = "failed"
        failed_messages = [k for k, v in tcResultDict.items() if v == 'failed']
        BuiltIn().log_to_console("Failed points: %s" % failed_messages)
    else:
        result = "passed"
    BuiltIn().log_to_console("Verify F1 Xn trace InterGnbHOSequence: %s" % result)
    if result == "failed":
        BuiltIn().fail('Verification of F1 Xn trace failed InterGnbHOSequence')

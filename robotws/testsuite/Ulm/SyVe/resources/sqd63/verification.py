# ====================================================================================================
# This is a Python File, which helps to implement the Robot Keywords used in 5GC001167.robot
# Team: 'MN 5G&SC 5G Pz ULM 2 SqdGp63'
# Email: 'I_MN_5GSC_PZ_ULM_SQD_63@nokia.com'
# ----------------------------------------------------------------------------------------------------[120 characters]

import os
import json
from itertools import groupby

# Robot Framework Libraries:
from robot.libraries.BuiltIn import BuiltIn

# TAF & UTE Libraries:
from taf.analyzer.pdml import PdmlReader, pdml  # noqa: E402
from taf.analyzer.pmcounter.pm_log_reader import PMCounterLogReader

# ====================================================================================================
#   Keywords for Verification of 5GC001167.robot
# ====================================================================================================


def verify_CA_addition(pdml_file_path, sband1, scell1, smimo1, num_cc,
                       ue_id='None', sband2='None', scell2='None', smimo2='None', ue_check='False'):
    """Keyword: Verify CA Addition"""
    BuiltIn().log_to_console("-" * 65)
    BuiltIn().log_to_console("Verify CA Addition:")
    testname = BuiltIn().get_variable_value("${TEST NAME}")
    # ================================================================================================
    tcResultDict = {}
    tcResultDict["FreqBandConfirm"] = 'failed'
    tcResultDict["PhysicalCellConfirm"] = 'failed'
    tcResultDict["MimoCellConfirm"] = 'failed'
    first_band = 'FreqBandIndicatorNR: %s' % sband1
    first_cell = 'physCellId: %s' % scell1
    first_mimo = 'maxMIMO-Layers: %s' % smimo1
    freq_list, cell_list, mimo_list = ([] for i in range(3))
    if num_cc == 3:
        freq_list_compare = [first_band, 'FreqBandIndicatorNR: %s' % sband2]
        cell_list_compare = [first_cell, 'physCellId: %s' % scell2]
        mimo_list_compare = [first_mimo, 'maxMIMO-Layers: %s' % smimo2]
    else:
        freq_list_compare = [first_band]
        cell_list_compare = [first_cell]
        mimo_list_compare = [first_mimo]
    if ue_check == 'True':
        ue_number = ue_id
        tcResultDict["UeConfirm"] = 'failed'
        ue_list = []
        ue_list_compare = [ue_number]
    if not os.path.isfile(pdml_file_path):
        BuiltIn().fail("verify_s1x2_trace(): %s does not exist!!!" % pdml_file_path)
    try:
        with open(pdml_file_path, 'rb') as file_obj:
            for entry in PdmlReader(file_obj=file_obj):
                root = entry.packet
                tcResultDict["FreqBandConfirm"], freq_list = \
                    verify_band(root, first_band, tcResultDict["FreqBandConfirm"], freq_list, num_cc)
                tcResultDict["PhysicalCellConfirm"], cell_list = \
                    verify_phys_cell(root, first_cell, tcResultDict["PhysicalCellConfirm"], cell_list, num_cc)
                tcResultDict["MimoCellConfirm"], mimo_list = \
                    verify_mimo_cell(root, first_mimo, tcResultDict["MimoCellConfirm"], mimo_list, num_cc)
                if ue_check == 'True':
                    tcResultDict["UeConfirm"], ue_list = \
                        verify_GNB_DU_UE(root, tcResultDict["UeConfirm"], ue_list)
                    if len(ue_list) > len(cell_list):
                        ue_list.pop(-1)
    except Exception as e:
        BuiltIn().log("Analysis has not started: %s!!!" % e)
    BuiltIn().log_to_console("Freq list = %s" % freq_list_compare)
    BuiltIn().log_to_console("Physical cell list = %s" % cell_list_compare)
    BuiltIn().log_to_console("mimo cell list = %s" % mimo_list_compare)
    if ue_check == 'True':
        if ue_list_compare in ue_list:
            tcResultDict["UeConfirm"] = "passed"
        else:
            tcResultDict["UeConfirm"] = "failed"
        ue_index = ue_list.index(ue_list_compare)
    if freq_list_compare in freq_list:
        tcResultDict["FreqBandConfirm"] = "passed"
    else:
        tcResultDict["FreqBandConfirm"] = "failed"
    if ue_check == 'True':
        if cell_list_compare == cell_list[ue_index]:
            tcResultDict["PhysicalCellConfirm"] = "passed"
        else:
            tcResultDict["PhysicalCellConfirm"] = "failed"
    else:
        if cell_list_compare in cell_list:
            tcResultDict["PhysicalCellConfirm"] = "passed"
        else:
            tcResultDict["PhysicalCellConfirm"] = "failed"
    if mimo_list_compare in mimo_list:
        tcResultDict["MimoCellConfirm"] = "passed"
    else:
        tcResultDict["MimoCellConfirm"] = "failed"
    tcResultJsonDict = json.dumps(tcResultDict, sort_keys=True, indent=4)
    BuiltIn().log_to_console("verify_s1x2_trace(): tcResultDict = %s" % tcResultJsonDict)
    BuiltIn().log("verify_s1x2_trace(): tcResultDict = %s" % tcResultJsonDict)
    if "failed" in tcResultDict.values():
        result = "failed"
        failed_messages = [k for k, v in tcResultDict.items() if v == 'failed']
        BuiltIn().log_to_console("Failed points: %s" % failed_messages)
    else:
        result = "passed"
    BuiltIn().log_to_console("Verify CA Addition: %s" % result)
    if result == "failed":
        BuiltIn().fail('Verification of CA Addition failed')


def verify_GNB_DU_UE(root, prev_result, ue_list):
    tcResult = prev_result
    elements = ["f1ap.GNB_DU_UE_F1AP_ID"]
    if all(x in root.keys() for x in elements):
        tcResult = "passed"
        BuiltIn().log("============================== Begin verify_ue_ids_list_complete()")
        BuiltIn().log_to_console("-" * 65)
        value = root.xpath("f1ap//..//f1ap.GNB_DU_UE_F1AP_ID")[0].showname
        BuiltIn().log_to_console("%s" % value)
        BuiltIn().log_to_console("-"*65)
        # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        try:
            ue_ids = []
            value1 = root.xpath("f1ap//..//f1ap.GNB_DU_UE_F1AP_ID")[0].showname
            ue_ids.extend([value1])
            BuiltIn().log_to_console("UE ID. %s" % value)
            ue_list.append(ue_ids)
        except Exception as e:
            BuiltIn().log("verify_ue_ids_list_complete(): %s" % e)
            tcResult = "failed"
        # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        BuiltIn().log_to_console("-" * 65)
        BuiltIn().log_to_console(tcResult)
        BuiltIn().log_to_console("-" * 65)
        BuiltIn().log(tcResult)
        BuiltIn().log("============================== End verify_ue_ids_list_complete()")
    return tcResult, ue_list


def verify_f1xn_trace_Intra(pdml_file_path):
    """Keyword: Verify F1 Xn and this will be for Intra check"""
    BuiltIn().log_to_console("-" * 65)
    BuiltIn().log_to_console("Verify F1 Xn trace Intra:")
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
    BuiltIn().log_to_console("Verify F1 Xn trace : %s" % result)
    if result == "failed":
        BuiltIn().fail('Verification of F1 Xn trace failed')


def verify_f1xn_trace_Inter(pdml_file_path):
    """Keyword: Verify F1 Xn trace and this will be for Inter check"""
    BuiltIn().log_to_console("-" * 65)
    BuiltIn().log_to_console("Verify F1 Xn trace Inter:")
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
    BuiltIn().log_to_console("Verify F1 Xn trace : %s" % result)
    if result == "failed":
        BuiltIn().fail('Verification of F1 Xn trace failed')


def verify_f1xn_trace_H_TC02(pdml_file_path):
    """Keyword: Verify F1 Xn trace H002"""
    BuiltIn().log_to_console("-" * 65)
    BuiltIn().log_to_console("Verify F1 Xn trace of 5GC001167-H-TC02:")
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
                tcResultDict["eventCheck"] = verify_rrc_events(root, pdml_file_path)
                tcResultDict["RRCReconfiguration_measGap"] = verify_rrcReconfiguration_measGap(root)
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
    BuiltIn().log_to_console("Verify F1 Xn trace of 5GC000706-H-TC02: %s" % result)
    if result == "failed":
        BuiltIn().fail('Verification of F1 Xn trace of 5GC000706-H-TC02 failed')


def verify_f1xn_trace_M13(pdml_file_path):
    """Keyword: Verify F1 Xn trace M13"""
    BuiltIn().log_to_console("-" * 65)
    BuiltIn().log_to_console("Verify F1 Xn trace of 5GC001167-M-13:")
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
                tcResultDict["drxConfig"] = verify_rrc_drxConfig(root)
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
    BuiltIn().log_to_console("Verify F1 Xn trace of 5GC001167-M-13: %s" % result)
    if result == "failed":
        BuiltIn().fail('Verification of F1 Xn trace of 5GC001167-M-13 failed')


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
        log_events_results(tcResult, "UEContextModificationRequest")
    return tcResult


def verify_band(root, band, prev_result, freq_list, num_cc):
    tcResult = prev_result
    elements = ["nr-rrc.FreqBandIndicatorNR"]
    if all(x in root.keys() for x in elements):
        tcResult = "passed"
        BuiltIn().log("============================== Begin verify_freq_band_complete()")
        BuiltIn().log_to_console("-" * 65)
        freqbanddetect_1 = root.xpath("f1ap//..//nr-rrc.frequencyBandList//nr-rrc.FreqBandIndicatorNR")[0].showname
        BuiltIn().log_to_console("%s" % freqbanddetect_1)
        if num_cc == 3:
            freqbanddetect_2 = root.xpath("f1ap//..//nr-rrc.frequencyBandList//nr-rrc.FreqBandIndicatorNR")[1].showname
            BuiltIn().log_to_console("%s" % freqbanddetect_2)
        BuiltIn().log_to_console("-"*65)
        # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        try:
            freq_cells = []
            value1 = root.xpath("f1ap//..//nr-rrc.frequencyBandList//nr-rrc.FreqBandIndicatorNR")[0].showname
            if num_cc == 3:
                value2 = root.xpath("f1ap//..//nr-rrc.frequencyBandList//nr-rrc.FreqBandIndicatorNR")[1].showname
                freq_cells.extend([value1, value2])
                BuiltIn().log_to_console("First Frequency. %s  Second Frequency. %s" % (value1, value2))
            else:
                freq_cells.extend([value1])
                BuiltIn().log_to_console("First Frequency. %s" % value1)
            freq_list.append(freq_cells)
        except Exception as e:
            BuiltIn().log("verify_freq_band_complete(): %s" % e)
            tcResult = "failed"
        # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        log_events_results(tcResult, "freq_band_complete")
    return tcResult, freq_list


def verify_phys_cell(root, cell, prev_result, cell_list, num_cc):
    tcResult = prev_result
    elements = ["nr-rrc.sCellConfigCommon_element"]
    if all(x in root.keys() for x in elements):
        tcResult = "passed"
        BuiltIn().log("============================== Begin verify_physical_cell_list_complete()")
        BuiltIn().log_to_console("-" * 65)
        value_1 = root.xpath("f1ap//..//nr-rrc.sCellConfigCommon_element//nr-rrc.physCellId")[0].showname
        BuiltIn().log_to_console("%s" % value_1)
        if num_cc == 3:
            value_2 = root.xpath("f1ap//..//nr-rrc.sCellConfigCommon_element//nr-rrc.physCellId")[1].showname
            BuiltIn().log_to_console("%s" % value_2)
        BuiltIn().log_to_console("-"*65)
        # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        try:
            physical_cells = []
            value1 = root.xpath("f1ap//..//nr-rrc.sCellConfigCommon_element//nr-rrc.physCellId")[0].showname
            if num_cc == 3:
                value2 = root.xpath("f1ap//..//nr-rrc.sCellConfigCommon_element//nr-rrc.physCellId")[1].showname
                physical_cells.extend([value1, value2])
                BuiltIn().log_to_console("First Cell. %s  Second Cell. %s" % (value1, value2))
            else:
                physical_cells.extend([value1])
                BuiltIn().log_to_console("First Cell. %s" % value1)
            cell_list.append(physical_cells)
        except Exception as e:
            BuiltIn().log("verify_physical_cell_list_complete(): %s" % e)
            tcResult = "failed"
        # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        log_events_results(tcResult, "physical_cell_list_complete")
    return tcResult, cell_list


def verify_mimo_cell(root, mimo, prev_result, mimo_list, num_cc):
    tcResult = prev_result
    elements = ["nr-rrc.sCellConfigDedicated_element"]
    if all(x in root.keys() for x in elements):
        element_path = "f1ap//..//nr-rrc.pdsch_ServingCellConfig//nr-rrc.setup_element//nr-rrc.maxMIMO_Layers"
        tcResult = "passed"
        BuiltIn().log("============================== Begin verify_mimo_cell_list_complete()")
        BuiltIn().log_to_console("-" * 65)
        mimodetect1 = root.xpath(element_path)[0].showname
        BuiltIn().log_to_console("%s" % mimodetect1)
        if num_cc == 3:
            mimodetect2 = root.xpath(element_path)[1].showname
            BuiltIn().log_to_console("%s" % mimodetect2)
        BuiltIn().log_to_console("-"*65)
        # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        try:
            mimo_cells = []
            value1 = root.xpath(element_path)[0].showname
            if num_cc == 3:
                value2 = root.xpath(element_path)[1].showname
                mimo_cells.extend([value1, value2])
                BuiltIn().log_to_console("First mimo Cell. %s  Second mimo Cell. %s" % (value1, value2))
            else:
                mimo_cells.extend([value1])
                BuiltIn().log_to_console("First mimo Cell. %s" % value1)
            mimo_list.append(mimo_cells)
        except Exception as e:
            BuiltIn().log("verify_mimo_cell_list_complete(): %s" % e)
            tcResult = "failed"
        # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        log_events_results(tcResult, "rrc_mimo_cell_list_complete")
    return tcResult, mimo_list


def verify_pm_counters(resultDir_att, resultDir_ho, cell_attach, cell_ho):
    """Keyword: Verify PM Counters"""
    BuiltIn().log_to_console("-" * 65)
    BuiltIn().log_to_console("Verify PM counters of 5GC001167:")
    attach_counters_list = ["M55114C00501", "M55114C00502"]
    ho_counters_list = ["M55114C00503", "M55114C00504"]
    latest_pm_filename_att = os.popen("cd %s; ls -dr1 *PM*.xml |head -1" % (resultDir_att)).read()
    latest_pm_filename_ho = os.popen("cd %s; ls -dr1 *PM*.xml |head -1" % (resultDir_ho)).read()
    BuiltIn().log("pm_filename = %s" % latest_pm_filename_att)
    BuiltIn().log("pm_filename = %s" % latest_pm_filename_ho)
    for pm_name in attach_counters_list:
        pm_value = get_pm_value_from_file(pm_dir=resultDir_att+"/", pm_name=pm_name,
                                          pm_filename=latest_pm_filename_att.rstrip())
        BuiltIn().log("gNB Attach %s = %s" % (pm_name, pm_value))
        BuiltIn().log_to_console("gNB Attach %s = %s" % (pm_name, pm_value[cell_attach]))
        if int(pm_value[cell_attach]) < 1:
            BuiltIn().log_to_console("The counter %s is: %s" % (pm_name, pm_value[cell_attach]))
            BuiltIn().log_to_console("Verify PM counters of 5GC001167-NSA: failed")
            BuiltIn().fail()
    for pm_name in ho_counters_list:
        pm_value = get_pm_value_from_file(pm_dir=resultDir_ho+"/", pm_name=pm_name,
                                          pm_filename=latest_pm_filename_ho.rstrip())
        BuiltIn().log("gNB HO %s = %s" % (pm_name, pm_value))
        BuiltIn().log_to_console("gNB HO %s = %s" % (pm_name, pm_value[cell_ho]))
        if int(pm_value[cell_ho]) < 1:
            BuiltIn().log_to_console("The counter %s is: %s" % (pm_name, pm_value[cell_ho]))
            BuiltIn().log_to_console("Verify PM counters of 5GC001167: failed")
            BuiltIn().fail()
    BuiltIn().log_to_console("Verify PM counters of 5GC001167-NSA: passed")
    BuiltIn().log_to_console("-" * 65)


def get_pm_value_from_file(pm_dir, pm_name, pm_filename):
    for file_name in os.listdir(pm_dir):
        if file_name == pm_filename:
            with open(pm_dir+file_name, 'rb') as file_obj:
                for log_entry in PMCounterLogReader(file_obj_iterator=[file_obj]):
                    if log_entry.pm_setup.findall(pm_name):
                        return log_entry.pm_setup.findall(pm_name)


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
        log_events_results(tcResult, "rrc_events")
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
        log_events_results(tcResult, "rrc_reconfigurationWithSync")
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
        log_events_results(tcResult, "rrcReconfiguration_measGap")
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
        log_events_results(tcResult, "measurement_report")
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
        log_events_results(tcResult, "rrc_drxConfig")
    return tcResult


def log_events_results(result, verify_event):
    BuiltIn().log_to_console("-" * 65)
    BuiltIn().log_to_console(result)
    BuiltIn().log_to_console("-" * 65)
    BuiltIn().log("verify_%s (): tcResult = %s" % (verify_event, result))
    BuiltIn().log("============================== End verify_%s()" % verify_event)

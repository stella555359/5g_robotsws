import csi_report
import tools_523
import logging
import RRC_Reconfig_parser
import json

from robot.libraries.BuiltIn import BuiltIn

logging.basicConfig(filename='csi_periodicity_validator.log', level=logging.DEBUG)


""" Run analysis on UE(s) containing CSI Reports """


def generate_verdict(path_to_tti_json, FRconfig, expectedperiodicity,
                     dtx_threshold_percentage, path_to_rrc_reconfig_pdml, expected_cqi, expected_ri):
    RRC_Extract = RRC_Reconfig_parser.Extract(path_to_rrc_reconfig_pdml)
    slotsperframe = tools_523.determine_slots_per_frame(FRconfig)
    with open(path_to_tti_json, "r") as json_file:
        tti_trace_extract = json.load(json_file)
    event_to_be_analyzed_csireport = tti_trace_extract['csiSrReportData']
    event_to_be_analyzed_csiref = tti_trace_extract['csiRsSchedData']
    result_rnti = {}
    result_all_ue = True
    if len(event_to_be_analyzed_csireport.keys()) == 0:
        logging.error("NO UEs found in TTI trace to analyze, check if TTI trace has event csiSrReportData")
        return False  # Return False if no UEs were found
    if len(event_to_be_analyzed_csiref.keys()) == 0:
        logging.error("No CSI Reference Signals traced in TTI events, check if TTI trace filter "
                      "includes csiRsSchedData")
        return False  # Return False if no CSI Reference Signals were found
    for rnti in event_to_be_analyzed_csireport.keys():
        csi_analysis = csi_report.analyzer(event_to_be_analyzed_csireport[rnti])
        result_csi_report = csi_report.periodicity_validator(csi_analysis, slotsperframe=slotsperframe,
                                                             expectedperiodicity=expectedperiodicity,
                                                             dtx_threshold_percentage=dtx_threshold_percentage,
                                                             type="CSI Report")
        result_rnti[rnti] = result_csi_report
        result_report_validator = csi_report.report_validator(csi_analysis, expected_cqi, expected_ri)
        result_rnti[rnti] = result_rnti[rnti] and result_report_validator
        csirep_slotoffset_RRC = RRC_Extract[int(rnti)]['CSI_Report_SlotOffset']
        result_CSI_Report_slot_offset_validator = csi_report.slot_validator(csi_analysis=csi_analysis,
                                                                            expected_slot_offset=csirep_slotoffset_RRC,
                                                                            slotsperframe=slotsperframe)
        result_rnti[rnti] = result_rnti[rnti] and result_CSI_Report_slot_offset_validator
        csi_rs_analysis = csi_report.analyzer(event_to_be_analyzed_csiref[rnti])
        result_csi_rs = csi_report.periodicity_validator(csi_rs_analysis, slotsperframe=slotsperframe,
                                                         expectedperiodicity=expectedperiodicity,
                                                         dtx_threshold_percentage=dtx_threshold_percentage,
                                                         type="CSI RS")
        result_rnti[rnti] = result_rnti[rnti] and result_csi_rs
        csi_rs_slot_offset_RRC = RRC_Extract[int(rnti)]['CSI_RS_SlotOffset']
        result_CSI_RS_slot_offset_validator = csi_report.slot_validator(csi_analysis=csi_rs_analysis,
                                                                        expected_slot_offset=csi_rs_slot_offset_RRC,
                                                                        slotsperframe=slotsperframe)
        result_rnti[rnti] = result_rnti[rnti] and result_CSI_RS_slot_offset_validator
        if result_csi_report:
            logging.info("CSI Report Periodicity validation PASSED for UE with RNTI : %s", rnti)
        else:
            logging.error("CSI Report Periodicity validation FAILED for UE with RNTI : %s", rnti)

        if result_csi_rs:
            logging.info("CSI RS Periodicity validation PASSED for UE with RNTI : %s", rnti)
        else:
            logging.error("CSI RS Periodicity validation FAILED for UE with RNTI : %s", rnti)

        if result_report_validator:
            logging.info("CSI Report validation PASSED for UE with RNTI : %s", rnti)
        else:
            logging.error("CSI Report validation FAILED for UE with RNTI : %s", rnti)

        if result_CSI_Report_slot_offset_validator:
            logging.info("CSI Report Slot offset validation PASSED for UE with RNTI : %s", rnti)
        else:
            logging.error("CSI Report Slot offset validation FAILED for UE with RNTI : %s", rnti)

        if result_CSI_RS_slot_offset_validator:
            logging.info("CSI RS Slot offset validation PASSED for UE with RNTI : %s", rnti)
        else:
            logging.error("CSI RS Slot offset validation FAILED for UE with RNTI : %s", rnti)

        logging.info("********************************************************************")

    for res in result_rnti.values():
        result_all_ue = res and result_all_ue

    return result_all_ue


if __name__ == "__main__":
    file_name = "/mnt/etfiles/users/srjanard/CsiReportTest1/csi_periodicity160/ttitrace_streaming.udp"
    multi_dir = '/opt/ttistream/'
    result = generate_verdict(file_name, multi_dir, FRconfig="cmW", expectedperiodicity=160,
                              num_of_events_to_analyze=None,
                              dtx_threshold_percentage=0.01, gnb_build="5G_0.800.342", expected_cqi=8, expected_ri=1,
                              path_to_rrc_reconfig_pdml="/mnt/etfiles/users/srjanard/CsiReportTest1/5G523-E/"
                                                        "5G_0.800.342/20200511_171103/"
                                                        "[1]5GC000523_E_US#6_Configurable_CSI_Reporting_periodicity/"
                                                        "backhaul.pdml")
    print(result)

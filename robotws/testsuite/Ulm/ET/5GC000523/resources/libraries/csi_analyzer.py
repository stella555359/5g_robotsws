# Notes
# Not tested with Carrier aggregation and multiple UEs on multiple cells

# Place BIP trace and RRC Reconfiguration trace in the same folder
# Name the BIP pdml file as : tracefile_bip.pdml
# Name the RRC Reconfiguration pdml file as : RRC_Reconfig.pdml
# Function 'run()' accepts the following parameters
# rootdir = 'R:/logs/automation/CSI_Analyzer/data/' -> Path to the directory which contains the folders PDML
# and ExtractedReport
# Directory PDML is expected to contain the BIP and RRC Reconfiguration trace in pdml format
# Directory ExtractedReport contains the decoded CSI report in CSV format
# PERMITTED_DTX_PERCENTAGE should be an integer, acceptable percentage of of DTX in the reports
# EXPECTED_REPORT should be a list containing the expected CSI report for each UE ['0x1e', '0x1e', '0x1e']
# EXPECTED_REPORT to be later changed to a dictionary with RNTI as key and expected report as value

import sys
from taf.analyzer.pdml import PdmlReader
import csi_packet
import numpi as numpy
import csi_validator
import RRC_Reconfig_parser
import logging

logging.basicConfig(level=logging.INFO)
##############################################################################################


def run(rootdir='Z:/users/srjanard/clock_test/',
        EXPECTED_REPORT=['0x4f', '0x4f', '0x4f', '0x4f', '0x4f', '0x4f', '0x4f', '0x4f', '0x4f', '0x4f'],
        PERMITTED_DTX_PERCENTAGE=20):
    RRC_Extract = RRC_Reconfig_parser.Extract(rootdir + 'PDML/RRC_Reconfig.pdml')
    logging.info("RRC Reconfiguration detected for UE(s) with RNTI : %s", RRC_Extract[0])
    logging.info("CSI Report Slot offset detected in RRC Reconfiguration for UE(s) : %s", RRC_Extract[2])
    logging.info("CSI RS Slot offset detected in RRC Reconfiguration for UE(s) : %s", RRC_Extract[4])
    TL_CONFIG = numpy.unique(RRC_Extract[3])
    logging.info("TL Configured : %s", TL_CONFIG[0])
    EXPECTED_CSI_PERIODICITY_IN_SLOTS = RRC_Extract[1]
    SLOT_OFFSET = RRC_Extract[2]
    EXPECTED_RNTI_FROM_RRC = RRC_Extract[0]
    csi_sendreq_slotoffset = RRC_Extract[4]
    csi_sendreq_periodicity = RRC_Extract[5]
    periodicity_check_verdict = 1
    report_check_verdict = 1

    if TL_CONFIG[0] == "Above6GHz":
        NumberOfSlotsPerFrame = 80
    elif TL_CONFIG[0] == "Below6GHz":
        NumberOfSlotsPerFrame = 20
    else:
        logging.error("Incorrect TL Configuration !! Choose 'Above6GHz' or 'Below6GHz'")

    # Assuming only 1 PDML file exists
    filename = rootdir + "PDML/tracefile_bip.pdml"
    ##
    CSIRefSignalSfn = csi_packet.CsiSendReq()
    PucchReqObj = csi_packet.PucchReceiveReq()
    PucchRespObj = csi_packet.PucchReceiveResp()
    CSIValidatorObj = csi_validator.reportValidator(NumberOfSlotsPerFrame)
    CSISendReqValidator = csi_validator.RefSignalValidator(NumberOfSlotsPerFrame)

    # Collect Data
    with open(filename) as file_obj:
        logging.info("Collecting necessary data for CSI Report Analysis")
        for entry in PdmlReader(file_obj=file_obj):
            root = entry.packet
            if "dldata_csirssendreq" in root:
                CSIRefSignalSfn.extractPacket(root)
            if "uldata_pucchreceivereq" in root:
                PucchReqObj.extractPacket(root)
            if "UlData_PucchReceiveRespPs" in root:
                PucchRespObj.extractPacket(root)
    logging.info("Collection of data for CSI Report analysis complete")
    # Analyze Data

    # Separate data for each UE
    dataExtract = []
    if len(PucchRespObj.get_sfn()) == 0:
        logging.error("No Uldata_PucchReceiveResp messages found, check lua decoding or validate BIP trace manually")
        return "Fail"

    RNTI_Detected = (numpy.unique(PucchReqObj.get_rnti()))
    logging.info("CSI Reports found with UE(s) with the following RNTI(s) %s", RNTI_Detected)
    if len(RNTI_Detected) < len(EXPECTED_RNTI_FROM_RRC):
        logging.error("ERR: BIP trace does not contain all RNTI(s)")
        rnti_found_verdict = 1
    else:
        rnti_found_verdict = 0
    for itr in range(len(RNTI_Detected)):
        logging.info("Preparing data for analysis - UE: %s / %s", itr + 1, len(RNTI_Detected))
        logging.info("RNTI detected: %s", RNTI_Detected[itr])
        dataExtract_rnti = csi_packet.sortPerUE(RNTI_Detected[itr])
        dataExtract.append(dataExtract_rnti)
        for index_rnti in range(len(PucchReqObj.get_rnti())):
            if PucchReqObj.get_rnti()[index_rnti] == RNTI_Detected[itr]:
                dataExtract[itr].add_sfn_PucchReq(PucchReqObj.get_sfn()[index_rnti])
                dataExtract[itr].add_slots_PucchReq(PucchReqObj.get_slots()[index_rnti])

        for index_rnti in range(len(PucchRespObj.get_rnti())):
            if PucchRespObj.get_rnti()[index_rnti] == RNTI_Detected[itr]:
                dataExtract[itr].add_sfn_PucchResp(PucchRespObj.get_sfn()[index_rnti])
                dataExtract[itr].add_slots_PucchResp(PucchRespObj.get_slots()[index_rnti])
                dataExtract[itr].add_report(PucchRespObj.get_UCIbits()[index_rnti])
                dataExtract[itr].add_dtx(PucchRespObj.get_dtx()[index_rnti])
                dataExtract[itr].add_crc(PucchRespObj.get_crc()[index_rnti])
    logging.info("Data prepared for analysis")
    logging.info("###################################################################################################")

    #####################################################################
    # Analyze Data for Each UE:
    ue_cnt = 0
    logging.info("Running CSI Send Request Analyzer")
    csi_sendreq_check_verdict = CSISendReqValidator.periodictyValidation(CSIRefSignalSfn.get_sfn(),
                                                                         CSIRefSignalSfn.get_slots(),
                                                                         csi_sendreq_periodicity,
                                                                         csi_sendreq_slotoffset,
                                                                         EXPECTED_RNTI_FROM_RRC)

    for data in dataExtract:
        logging.info("Analyzing data for - UE: %s / %s", ue_cnt + 1, len(RNTI_Detected))
        RNTI_Detected_Flag = False
        logging.info("Validating RNTI %s ", data.rnti)
        if int(data.rnti, 16) in EXPECTED_RNTI_FROM_RRC:
            logging.info("RNTI %s detected present in RRC Reconfiguration", data.rnti)
            RNTI_Detected_Flag = True
        else:
            logging.error("RNTI detected %s not present in RRC Reconfiguration", data.rnti)
        if RNTI_Detected_Flag:
            logging.info("Verifying CSI Report Periodicity for RNTI: %s", data.rnti)
            periodicity_check_verdict = CSIValidatorObj.periodictyValidation(data.get_sfn(), data.get_slots(),
                                                                             EXPECTED_CSI_PERIODICITY_IN_SLOTS[ue_cnt],
                                                                             SLOT_OFFSET[int(data.rnti, 16)])
            decodedReport = CSIValidatorObj.reportValidation(data.get_sfn(), data.get_slots(),
                                                             data.get_sfn_PucchResp(),
                                                             data.get_slots_PucchResp(), data.get_dtx(),
                                                             data.get_crc(), data.get_report(),
                                                             EXPECTED_REPORT[ue_cnt], PERMITTED_DTX_PERCENTAGE)
            report_check_verdict = decodedReport[7]
            CSIValidatorObj.writeDataToFile(decodedReport, data.rnti, rootdir)
        ue_cnt += 1
        logging.info("###############################################################################################")

    if periodicity_check_verdict == 0 and report_check_verdict == 0 and rnti_found_verdict == 0 and \
            csi_sendreq_check_verdict == 0:
        return "PASS"
    else:
        return "FAIL"


if __name__ == '__main__':
    if len(sys.argv) == 2:
        run(sys.argv[1])
    else:
        run()

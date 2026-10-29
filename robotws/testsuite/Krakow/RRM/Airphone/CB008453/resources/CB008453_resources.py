"""
:copyright: Nokia Networks
:authors:
    Arkadiusz Sobejko, arkadiusz.sobejko@nokia.com
    Michal Obszarny, michal.obszarny@nokia.com
:maintainers:
    Arkadiusz Sobejko, arkadiusz.sobejko@nokia.com
"""
import glob

from ute_wtssim import ute_wtssim
from ta_egate_cmd_parser import ta_egate_cmd_parser
from math import floor

from testsuite.Krakow.RRM.Airphone.resources.former_l2_sw1.python.csv_verifiers import csv_verifiers
from testsuite.Krakow.RRM.Airphone.resources.former_l2_sw1.python.ue_handling import ue_handling
from testsuite.Krakow.RRM.Airphone.resources.former_l2_sw1.python.traffic_handling import traffic_handling


csv_tti_trace = csv_verifiers()
bip_trace = csv_verifiers()
csv_bip = csv_verifiers()
ue_handling = ue_handling()
traffic_handling = traffic_handling()
wts = ute_wtssim()
ta_egate = ta_egate_cmd_parser()


def verify_dc_state(ue_id, state):
    """
        Check on egate console NR-DC state
        :param ue_id: ue id
        :param state: wanted NR-DC state
    """
    cmd = ta_egate.get_command('ue_disp')
    dc_state = cmd(id=ue_id).execute_and_parse()['DC state']['Value']
    assert dc_state == state, f"UE {ue_id} is not in expected NR-DC expected:{state}, but is {dc_state}"


def verify_harq_feedback_on_single_pucch(csv_directory, ack_nack_check=True):
    """
        Verify that HARQ Fedback have proper PUCCH format. Also expected only nonDTX
        :param csv_directory: (str) file path directory, where tti traces are collected
    """
    collected_values = {"dlHarqRxDataArray.pucchFormat": [], "dlHarqRxDataArray.dtx": [],
                        "dlHarqRxDataArray.ackNack": []}
    for csv_file in glob.glob(csv_directory + 'output_dl.*'):
        collected_tti = csv_tti_trace.create_list_of_lists_from_csv(csv_file)
        collected_file_values = csv_tti_trace.get_multiple_columns_values('dlHarqRxDataArray.pucchFormat',
                                                                          'dlHarqRxDataArray.dtx',
                                                                          'dlHarqRxDataArray.ackNack',
                                                                          input_list=collected_tti, as_dict=True)
        collected_values["dlHarqRxDataArray.pucchFormat"].extend(collected_file_values["dlHarqRxDataArray.pucchFormat"])
        collected_values["dlHarqRxDataArray.dtx"].extend(collected_file_values["dlHarqRxDataArray.dtx"])
        collected_values["dlHarqRxDataArray.ackNack"].extend(collected_file_values["dlHarqRxDataArray.ackNack"])

    for row in range(len(collected_values['dlHarqRxDataArray.dtx'])):
        if collected_values['dlHarqRxDataArray.dtx'][row] != "":
            assert collected_values["dlHarqRxDataArray.dtx"][row] == "NON_DTX", "SOME DTX in TTI trace"
            assert collected_values["dlHarqRxDataArray.pucchFormat"][row] in ["FORMAT_0", "FORMAT_2"], \
                f"Wrong PUCCH format. PUCCH format is {collected_values['dlHarqRxDataArray.pucchFormat'][row]}"
            if ack_nack_check:
                assert collected_values["dlHarqRxDataArray.ackNack"][row] == "ACK", "SOME NACK in TTI trace"


def verify_periodic_csi_is_transmitting(csv_directory):
    """
        Verify that only PERIODIC CSI is transmitted in tti trace
        param csv_directory: (str) file path directory, where tti traces are collected
    """
    collected_values = {"csiSrReportData.reportType": []}
    for csv_file in glob.glob(csv_directory + 'output_dl.*'):
        collected_tti = csv_tti_trace.create_list_of_lists_from_csv(csv_file)
        collected_file_values = csv_tti_trace.get_multiple_columns_values('csiSrReportData.reportType',
                                                                          input_list=collected_tti, as_dict=True)
        collected_values["csiSrReportData.reportType"].extend(collected_file_values["csiSrReportData.reportType"])

    for row in range(len(collected_values['csiSrReportData.reportType'])):
        if collected_values['csiSrReportData.reportType'][row] != "":
            assert collected_values["csiSrReportData.reportType"][row] == "PERIODIC_CSI", "WRONG CSI REPORT"

    for csv_file in glob.glob(csv_directory + 'output_ul.*'):
        collected_tti = csv_tti_trace.create_list_of_lists_from_csv(csv_file)
        collected_file_values = csv_tti_trace.get_multiple_columns_values('csiSrReportData.reportType',
                                                                          input_list=collected_tti, as_dict=True)
        collected_values["csiSrReportData.reportType"].extend(collected_file_values["csiSrReportData.reportType"])

    for row in range(len(collected_values['csiSrReportData.reportType'])):
        if collected_values['csiSrReportData.reportType'][row] != "":
            assert collected_values["csiSrReportData.reportType"][row] == "PERIODIC_CSI", "WRONG CSI REPORT"


def verify_trs_on_slots(slots, csv_directory):
    """
        Verify that TRS is on specific slots in TTI trace
        param slots: (str) splited by "," with slots on which is expected TRS
        param csv_directory: (str) file path directory, where tti traces are collected
    """
    collected_values = {"sfn": [], "slot": [],
                        "csiRsSchedData.csiRsTraceType": [],
                        "csiSrReportData.reportType": [],
                        "dlFdSchedData.rrmDlUsedMcs": []}
    slots = list(slots.split(','))
    for csv_file in glob.glob(csv_directory + 'output_dl.*'):
        collected_tti = csv_tti_trace.create_list_of_lists_from_csv(csv_file)
        collected_file_values = csv_tti_trace.get_multiple_columns_values('sfn',
                                                                          'slot',
                                                                          'csiRsSchedData.csiRsTraceType',
                                                                          'csiSrReportData.reportType',
                                                                          'dlFdSchedData.rrmDlUsedMcs',
                                                                          input_list=collected_tti, as_dict=True)
        collected_values["sfn"].extend(collected_file_values["sfn"])
        collected_values["slot"].extend(collected_file_values["slot"])
        collected_values["csiRsSchedData.csiRsTraceType"].extend(collected_file_values["csiRsSchedData.csiRsTraceType"])
        collected_values["csiSrReportData.reportType"].extend(collected_file_values["csiSrReportData.reportType"])
        collected_values["dlFdSchedData.rrmDlUsedMcs"].extend(collected_file_values["dlFdSchedData.rrmDlUsedMcs"])

    for row in range(len(collected_values['csiRsSchedData.csiRsTraceType'])):
        if collected_values['csiRsSchedData.csiRsTraceType'][row] == "CELLTRS":
            if int(collected_values["sfn"][row]) % 32 in [1, 9, 17, 25]:
                assert collected_values["slot"][row] in slots, \
                    f'TRS on wrong slot, on slot {collected_values["slot"][row]}'
            else:
                assert collected_values["slot"][row] in slots, \
                    f'TRS on wrong SFN, on SFN {collected_values["sfn"][row]}, slot {collected_values["slot"][row]}'
        else:
            if ((collected_values["csiSrReportData.reportType"][row] != "PERIODIC_CSI") and
                    (collected_values["dlFdSchedData.rrmDlUsedMcs"][row] != "")):
                if int(collected_values["sfn"][row]) % 32 in [1, 9, 17, 25]:
                    assert collected_values["slot"][row] not in slots, \
                        (f'TRS on wrong SFN, on SFN {collected_values["sfn"][row]}, '
                            f'slot {collected_values["slot"][row]}')


def verify_ssb_on_slots(slots, bip_csv_directory, tti_csv_directory):
    """
        Verify that TRS is on specific slots in TTI trace
        param slots: (str) splited by "," with slots on which is expected TRS
        param bip_csv_directory: (str) file path directory, where BIP are collected
        param tti_csv_directory: (str) file path directory, where tti traces are collected
    """
    collected_tti_values = {"sfn": [], "slot": [],
                            "dlFdSchedData.rrmDlUsedMcs": []}
    collected_bip_values = {"sfn": [], "slot": []}
    slots = list(slots.split(','))
    for csv_file in glob.glob(tti_csv_directory + 'output_dl.*'):
        collected_tti = csv_tti_trace.create_list_of_lists_from_csv(csv_file)
        collected_file_values = csv_tti_trace.get_multiple_columns_values('sfn',
                                                                          'slot',
                                                                          'dlFdSchedData.rrmDlUsedMcs',
                                                                          input_list=collected_tti, as_dict=True)
        collected_tti_values["sfn"].extend(collected_file_values["sfn"])
        collected_tti_values["slot"].extend(collected_file_values["slot"])
        collected_tti_values["dlFdSchedData.rrmDlUsedMcs"].extend(collected_file_values["dlFdSchedData.rrmDlUsedMcs"])
    for row in range(len(collected_tti_values['dlFdSchedData.rrmDlUsedMcs'])):
        if int(collected_tti_values["sfn"][row]) % 2 == 0:
            if collected_tti_values["slot"][row] in slots:
                assert collected_tti_values["dlFdSchedData.rrmDlUsedMcs"][row] == "", \
                    (f'Scheduling on SSB, on sfn {collected_tti_values["sfn"][row]} '
                        f'slot {collected_tti_values["slot"][row]}')

    for csv_file in glob.glob(bip_csv_directory + 'BIP_Logs.*'):
        collected_bip = bip_trace.create_list_of_lists_from_csv(csv_file)
        collected_file_values = bip_trace.get_multiple_columns_values('3gpp.sfn',
                                                                      '3gpp.slot',
                                                                      input_list=collected_bip, as_dict=True)
        collected_bip_values["sfn"].extend(collected_file_values["3gpp.sfn"])
        collected_bip_values["slot"].extend(collected_file_values["3gpp.slot"])

    for row in range(len(collected_bip_values["sfn"])):
        if int(collected_bip_values["slot"][row]) % 2 == 0:
            assert collected_bip_values["slot"][row] in slots, \
                (f'SSB on wrong sfn {collected_bip_values["sfn"][row]} '
                    f'and slot {collected_bip_values["slot"][row]}')
        else:
            assert collected_bip_values["slot"][row] in slots, \
                (f'SSB on wrong sfn {collected_bip_values["sfn"][row]} '
                    f'and slot {collected_bip_values["slot"][row]}')


def calculate_timing_advance(dist):
    """https://confluence.ext.net.nokia.com/display/AirPhoneWTS/ue_ta_nr"""
    c = 300000000
    ta = 2 * int(dist) / c
    ts = 64 / (480000 * 4096)
    tg = 16 * ts / (2 ** 3)
    return floor(ta / tg)

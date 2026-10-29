import logging
from robot.libraries.BuiltIn import BuiltIn
from robot.api.deco import keyword
from taf.analyzer.pcap.pcap_packet import PcapPacket
from taf.rfrl.utilities.parsers.pcap_checker import pcap_checker, VerificationError

import testsuite.Wroclaw.RRM.VRF_WRO2_T05.airphone.CB008490.CB008490_LD.resources.pcap_rrc_msgs as rrc


def get_and_log_field_value(packet: PcapPacket, xpath: str, console: bool = False):
    """
    Function for getting filed value by XPATH from PCAP packet with additional logging for debugging purposes

    :param packet: PCAP packet
    :param xpath: str in XPATH format to retrieve value of field(s)
    :param console: bool to decide if logs to be displayed on console
    """

    frame_no = packet.get_field_value_by_name('frame.number')
    real_value = packet.get_field_value_by_xpath(xpath)
    msg = (f'Packet Number: {frame_no}\n'
           f' XPath: {xpath}\n'
           f' Value: {real_value}\n')
    logging.info(msg)
    if console:
        BuiltIn().log_to_console(msg)
    return real_value


def list_contains_same_values(list_obj: [], value: any, length: int):
    """
    Function checks if list contains all the same values. Length of list is also checked

    :param list_obj: list to be checked
    :param value: value in list to be checked
    :param length: length of list to be checked
    """

    return list_obj.count(value) == length


def verify_csi_report_config_ids(rrc_snode_add: PcapPacket, rrc_snode_mod: PcapPacket) -> None:
    """Verifies the presence of specific CSI Report Config IDs in RRC Reconfiguration messages for
    NRDC call establishment.
    Report Config IDs: 0 for PSCell CQI, 2 for PSCell BM (added in SNodeModification), 13-19 for SCell CQI

    :param rrc_snode_add: RRC Reconfiguration message with NRDC Setup
    :param rrc_snode_mod: RRC Reconfiguration message with NRDC SCG Modification.
    :raises: VerificationError
    """
    report_configs_ids = "//nr-rrc.csi_MeasConfig//nr-rrc.csi_ReportConfigToAddModList//nr-rrc.reportConfigId"
    report_config_id_values = get_and_log_field_value(rrc_snode_add, report_configs_ids)
    expected_report_config_id_values = {'0', '13', '14', '15', '16', '17', '18', '19'}
    msg = f'Verifying that CSI reportConfigIds: {expected_report_config_id_values} ' \
          f'are subset of {report_config_id_values}'
    logging.info(msg)
    if not expected_report_config_id_values.issubset(report_config_id_values):
        raise VerificationError(msg)

    values = get_and_log_field_value(rrc_snode_mod, report_configs_ids)
    msg = f'Verifying that reportConfigId: 2 is present in RRC Reconfiguration with SCG Modification'
    logging.info(msg)
    if not {'2'}.issubset(values):
        raise VerificationError(msg)


# CB008490_ET_LD_alt6
@keyword()
def verify_pucch_mux_two_process_four_report_groups(pcap_file: str) -> None:
    """KW verifies that
    - Two CSI-Process are sufficient for multiplexing, which means that there are two groups of csi-ReportConfigs cells
      and these four groups of cells use four different periodicities and

    - First CSI-Process is sufficient for multiplexing what means that all the same csi-ReportConfigs
      uses the same periodicity and offset
      [configured BM report non-multiplexing]+[PSCell (CQI)+1SCell (CQI)]+[2SCell (CQI)] =4cells
    - Second CSI-Process is sufficient for multiplexing what means that all the same csi-ReportConfigs
      uses the same periodicity and offset [2SCells (CQ1)+2SCells (CQI)] =4 cells
    - PSCell (CQI +SR) + 1 SCell CQI is multiplexed into a Report_#1 = PSCell + SCell2 (Resource0=9)
    - Remaining 2 SCells CQI are multiplexed into a Report_#2
    - Remaining 2 SCells CQI are multiplexed into a Report_#3
    - Remaining 2 SCells CQI are multiplexed into a Report_#4
    - After first SNodeModification the csi-ReportConfig for non_BM (reportConfigId : 2)
      is added to the multiplexed report in the CSI-Process #1 and CSI-Process #2 and Report_#1
    :param pcap_file: path to pcap file
    """
    xnap_rrc_snode_add, xnap_rrc_snode_mod = get_xnap_rrc_snode_add_snode_mod_packets(pcap_file)
    verify_different_pucch_mux_resource_is_used_in_report_configs(xnap_rrc_snode_add, xnap_rrc_snode_mod)
    verify_csi_report_config_ids(xnap_rrc_snode_add, xnap_rrc_snode_mod)
    verify_elements_from_two_prcccesses_are_different(xnap_rrc_snode_add)

    verify_pucch_code_rate(xnap_rrc_snode_add, '1')
    verify_four_csi_groups_pscell_bm_one_scell_in_first(xnap_rrc_snode_add)
    verify_BM_report_with_separate_non_multiplexed_PUCCH_resource(xnap_rrc_snode_add, xnap_rrc_snode_mod)


def verify_pucch_code_rate(rrc_snode_add: PcapPacket, value: str) -> None:
    """Verifies that PUCCH Max Code Rate

    :param rrc_snode_add: PCAP packet with RRC Reconfiguration message with NRDC Setup
    :param value: str with enum of PUCCH-MaxCodeRate ::=
                  ENUMERATED {zeroDot08, zeroDot15, zeroDot25, zeroDot35, zeroDot45, zeroDot60, zeroDot80}
                  e.g. '2' for zeroDot25
    :raises: VerificationError
    """
    pucch_code_rate = "//nr-rrc.bwp_Dedicated_element//nr-rrc.pucch_Config//nr-rrc.maxCodeRate"
    pucch_code_rate_value = get_and_log_field_value(rrc_snode_add, pucch_code_rate)[0]

    msg = f'Verifying that PUCCH Max Code Rate value {pucch_code_rate_value} is equal to {value}'
    logging.info(msg)
    if pucch_code_rate_value != value:
        raise VerificationError(msg)


# CB008490_ET_LD_alt6
def get_xnap_rrc_snode_add_snode_mod_packets(pcap_file: str) -> tuple[PcapPacket, PcapPacket]:
    """Function returns 2 PCAP packets with RRC Reconfiguration containing NDRC Setup and NRDC SCG Modification
    :param pcap_file: path to pcap file
    :return: two RRC Reconfiguration messages with SCG configuration
    """
    pc = pcap_checker()
    rrc_snode_config_packets = pc.get_packets(pcap_file=pcap_file,
                                              display_filter='xnap',
                                              awaited_message=rrc.rrc_reconfig_snode_add_mod)
    try:
        xnap_rrc_snode_add = rrc_snode_config_packets[0]
        xnap_rrc_snode_mod = rrc_snode_config_packets[1]
        return xnap_rrc_snode_add, xnap_rrc_snode_mod
    except ValueError:
        logging.error("PCAP does not contain two RRC Reconfiguration messages with SCG Configuration")


# CB008490_ET_LD_alt6
def verify_different_pucch_mux_resource_is_used_in_report_configs(xnap_rrc_snode_add: PcapPacket,
                                                                  xnap_rrc_snode_mod: PcapPacket) -> None:
    """Verifies that PUCCH Resource ID selected for Multiplexing is used for all CSI Report Configs but not the same
    for CB008490-LD-alt6
    Two CSI process -> all cells uses same PUCCH Resource ID selected for MUX

    :param rrc_snode_add: RRC Reconfiguration message with NRDC Setup
    :param rrc_snode_mod: RRC Reconfiguration message with NRDC SCG Modification.
    :raises: VerificationError
    """
    pucch_mux_res_id = "//nr-rrc.multi_CSI_PUCCH_ResourceList//nr-rrc.PUCCH_ResourceId"
    pucch_mux_res_id_value = get_and_log_field_value(xnap_rrc_snode_add, pucch_mux_res_id)[0]

    csi_report_pucch_res = "//nr-rrc.csi_MeasConfig//nr-rrc.csi_ReportConfigToAddModList//nr-rrc.pucch_Resource"
    csi_report_pucch_res_values_list = get_and_log_field_value(xnap_rrc_snode_add, csi_report_pucch_res)
    snode_mod_csi_report_pucch_res_values_list = get_and_log_field_value(xnap_rrc_snode_mod, csi_report_pucch_res)
    msg = f'PUCCH MUX Resource ID slected for MUX: {pucch_mux_res_id_value} ' \
          f'should be used for all SCG reportConfigs: {csi_report_pucch_res_values_list}'
    logging.info(msg)
    if not list_contains_same_values(csi_report_pucch_res_values_list, pucch_mux_res_id_value, 8):
        raise VerificationError(msg)

    msg = f'CSI Report Res has value equal 10 in SnodeAdditionAcknowledge: {csi_report_pucch_res_values_list} ' \
          f'CSI Report Res should be used with different value e.g == 12: {snode_mod_csi_report_pucch_res_values_list}'
    if not snode_mod_csi_report_pucch_res_values_list[0] != csi_report_pucch_res_values_list[0]:
        raise VerificationError(msg)


# CB008490_ET_LD_alt6
@keyword()
def verify_elements_from_two_prcccesses_are_different(xnap_rrc_snode_add: PcapPacket) -> None:
    """Verifies If Two CSI Process is used for NRDC SCG
    Two CSI Process -> PSCell + 3 SCells are using the same periodicityOffset vales and remaining 4 SCells are using
    the same but different compared to the first CSI Process
    :param xnap_rrc_snode_add: RRC Reconfiguration message with NRDC Setup
    :raises: VerificationError
    """

    csi_res_periodicity_scells = "//xnap//nr-rrc.secondaryCellGroup//nr-rrc.CellGroupConfig_element//" \
                                 "nr-rrc.sCellToAddModList//" \
                                 "nr-rrc.sCellConfigDedicated_element//nr-rrc.csi_MeasConfig//" \
                                 "nr-rrc.nzp_CSI_RS_ResourceToAddModList//nr-rrc.periodicityAndOffset"
    csi_res_periodicity_pscell = "//xnap//nr-rrc.secondaryCellGroup//nr-rrc.spCellConfig_element//" \
                                 "nr-rrc.spCellConfigDedicated_element//nr-rrc.csi_MeasConfig//" \
                                 "nr-rrc.nzp_CSI_RS_ResourceToAddModList//nr-rrc.periodicityAndOffset"
    csi_res_offset_scells = csi_res_periodicity_scells + "/nr-rrc.slots320"
    csi_res_offset_pscells = csi_res_periodicity_pscell + "/nr-rrc.slots320"
    csi_res_periodicity_values_scells = get_and_log_field_value(xnap_rrc_snode_add, csi_res_offset_scells)
    csi_res_periodicity_values_pscell = get_and_log_field_value(xnap_rrc_snode_add, csi_res_offset_pscells)
    msg = f'csi_res_periodicity_values_scells {csi_res_periodicity_values_scells}'
    logging.info(msg)
    msg = f'csi_res_periodicity_values_pscell {csi_res_periodicity_values_pscell}'
    logging.info(msg)
    msg = 'periodicityAndOffset of CSI-RS Resources are not the same for all SCG cells'
    logging.info(msg)

    scells_lists = [int(value) for value in csi_res_periodicity_values_scells]
    msg = f'{scells_lists}'
    logging.info(msg)
    unique_values = list(set(scells_lists))  # 1, 171
    msg = f'{unique_values}'
    logging.info(msg)
    scell_first_value = unique_values[0]
    scell_second_value = unique_values[1]
    first_value_amount = scells_lists.count(scell_first_value)  # 3
    second_value_amount = scells_lists.count(scell_second_value)  # 4
    msg = f'{first_value_amount}'
    logging.info(msg)
    msg = f'{second_value_amount}'
    logging.info(msg)
    pscell_value = int(csi_res_periodicity_values_pscell[0])
    msg = f'{pscell_value}'
    logging.info(msg)
    first_list_of_values = [value for value in scells_lists if value == scell_first_value]
    second_list_of_values = [value for value in scells_lists if value == scell_second_value]
    msg = f'{first_list_of_values}'
    logging.info(msg)
    msg = f'{second_list_of_values}'
    logging.info(msg)
    # mniejsza liczba zawiera elementy równe 1 i koresponduje do wartosci pscellki
    smaller_list = min(first_list_of_values, second_list_of_values)
    msg = f'{smaller_list}'
    logging.info(msg)
    assert pscell_value == smaller_list[0]


# CB008490_ET_LD_alt6
def verify_four_csi_groups_pscell_bm_one_scell_in_first(xnap_rrc_snode_add: PcapPacket) -> None:
    """Verifies if four CSI Report Groups are used for NRDC SCG cells.
    4 CSI Groups -> reportSlotConfig values in to groups: 2xX 2xY 2xW 2xZ, X for PSCell (first in table) and one SCell
    - [PSCell (CQI)+1SCell (CQI)]
    - [2SCells (CQI)],
    - [2SCells (CQ1)]
    - [2SCells (CQI)]
    :param xnap_rrc_snode_add: RRC Reconfiguration message with NRDC Setup
    :param xnap_rrc_snode_mod: RRC Reconfiguration message with NRDC SCG Modification.
    """
    csi_report_periodicity_all_groups = "//xnap.SNodeAdditionRequestAcknowledge_element//nr-rrc.secondaryCellGroup//" \
                                        "nr-rrc.spCellConfig_element//nr-rrc.spCellConfigDedicated_element//" \
                                        "nr-rrc.csi_MeasConfig//nr-rrc.csi_ReportConfigToAddModList//" \
                                        "nr-rrc.reportSlotConfig//nr-rrc.slots320"

    csi_report_periodicity_values = get_and_log_field_value(xnap_rrc_snode_add, csi_report_periodicity_all_groups)
    msg = f'csi_report_periodicity_values {csi_report_periodicity_values}'
    logging.info(msg)
    msg = f'Verifying if CSI Report Config offset values are divided in 4 groups'
    logging.info(msg)

    report_lists = [int(value) for value in csi_report_periodicity_values]
    msg = f'{report_lists}'
    logging.info(msg)
    unique_values = list(set(report_lists))     # 9, 169, 179, 183
    msg = f'{unique_values}'
    logging.info(msg)
    report_first_value = unique_values[0]
    report_second_value = unique_values[1]
    report_third_value = unique_values[2]
    report_fourth_value = unique_values[3]
    first_value_amount = report_lists.count(report_first_value)     # 9
    second_value_amount = report_lists.count(report_second_value)   # 169
    third_value_amount = report_lists.count(report_third_value)     # 179
    fourth_value_amount = report_lists.count(report_fourth_value)   # 183
    msg = f'{first_value_amount}'
    logging.info(msg)
    msg = f'{second_value_amount}'
    logging.info(msg)
    msg = f'{third_value_amount}'
    logging.info(msg)
    msg = f'{fourth_value_amount}'
    logging.info(msg)


# CB008490_ET_LD_alt6
def verify_BM_report_with_separate_non_multiplexed_PUCCH_resource(xnap_rrc_snode_add: PcapPacket,
                                                                  xnap_rrc_snode_mod: PcapPacket) -> None:
    """Verifies if BM report:
    SNodeAddition: BM report is configured with non-multiplexing PUCCH resource
    SNodeModification: BM report is configured with a separate non-multiplexed PUCCH resource in the CSI-Process #1
    :param xnap_rrc_snode_add: RRC Reconfiguration message with NRDC Setup
    :param xnap_rrc_snode_mod: RRC Reconfiguration message with NRDC SCG Modification.
    """
    bm_report_snode_add = "//xnap.SNodeAdditionRequestAcknowledge_element//nr-rrc.secondaryCellGroup//" \
                          "nr-rrc.CellGroupConfig_element//nr-rrc.spCellConfigDedicated_element//" \
                          "nr-rrc.uplinkBWP_ToAddModList//nr-rrc.BWP_Uplink_element//" \
                          "nr-rrc.multi_CSI_PUCCH_ResourceList//nr-rrc.PUCCH_ResourceId"
    bm_report_snode_mod = "//xnap.SNodeModificationRequired_element//nr-rrc.secondaryCellGroup//" \
                          "nr-rrc.spCellConfig_element//nr-rrc.spCellConfigDedicated_element//" \
                          "nr-rrc.csi_MeasConfig//nr-rrc.csi_ReportConfigToAddModList//nr-rrc.pucch_Resource"

    bm_report_snode_values_add = get_and_log_field_value(xnap_rrc_snode_add, bm_report_snode_add)
    bm_report_snode_values_mod = get_and_log_field_value(xnap_rrc_snode_mod, bm_report_snode_mod)
    msg = f'Veryfing if value of configured BM report has different BM report value: \n' \
          f'{bm_report_snode_values_add} has configured BM report with non-multiplexing PUCCH resource \n' \
          f'{bm_report_snode_values_mod} has configured BM as above but different value\n'
    logging.info(msg)
    if not bm_report_snode_values_add.count(bm_report_snode_values_add[0]) == 1:
        raise VerificationError(msg)
    if not bm_report_snode_values_add[0] != bm_report_snode_values_mod[0]:
        raise VerificationError

# *** Settings ***
# Documentation
# ...    author: Yishuang Wang
# ...    contact: yishuang.wang@nokia-sbell.com
# ...    squad group: SG_03
# ...    feature : 5GC001700BA
# 
# Force Tags    CA_5G_RRM        CRT_TRUNK    CRT_22R4    CRT_22R3
# ...    PY36
# 
# Suite Setup    Common Suite Setup for COAM
# 
# Suite Teardown    Run Keyword If Any Tests Failed
# ...               Run Keyword And Ignore Error    Common Suite Teardown for COAM
# 
# Resource    ../Resources/5GC001700BA_coam_common_keywords.robot
# Resource    ../Resources/5GC001700BA_REG_coam_common_keywords.robot
# 
# *** Variables ***
# #${tl_scf_filename}    Configuration_scf_MRBTS-tl233-1094.xml
# #${tl_scf_dir_path}    /opt/workspace/CIT/Master/SCF_file/
# ${tl_scf_dir_path}    /opt/workspace/SCF/
# ${tl_scf_filename}    gold_347_236_233.xml
# ${enbx2_dist}    MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNADJGNB-1
# ${x2logname_01}    gnb_x2_016_01.pcap
# ${x2logname_02}    gnb_x2_016_02.pcap
# ${x2_sctp_port}    36422
# 
# *** Test Cases ***
# #[1]5GC001094_G_016_PSCell_change_A3_and_A5_enable_spilt_mode
# #    [Documentation]
# #    ...    This case verify the PSCell change with initial Blacklisting configuration
# #    [Tags]    Qualcomm    classical    #CRT_TRUNK
# #    [Timeout]    1 hour
# #    [Setup]
# #    Prepare with COMA classical BTS cell onair
# #    COAM get cell id
# #    Prepare the atten for case016
# #    Precondition for power UE    ue_type=${ue_type}
# #    sleep    10s
# #    Start Capture Classical enb x2 Logs    x2logname=${x2logname_01}
# #    Attach and check power UE    ue_type=${ue_type}
# #    Start DL UL traffic and monitor throughput
# #    sleep    3s
# #    Adjust the atten and check HO status    value1=${30}    value2=${30}
# #    Evaluate throughput on target cell
# #    Stop and Save classical enb x2 Logs    x2logname=${x2logname_01}
# #    sleep    5s
# #    Start Capture Classical enb x2 Logs    x2logname=${x2logname_02}
# #    Adjust the atten and check HO status    value1=${0}    value2=${0}
# #    Evaluate throughput on source cell
# #    Stop and Save classical enb x2 Logs    x2logname=${x2logname_02}
# #    Analysis wireshark log for case016    x2log1=${x2logname_01}    x2log2=${x2logname_02}
# #    [Teardown]    Run Keyword And Ignore Error    Tests Recovery    x2logname=${x2logname_01}
# 
# [1]5G001707_primary_fiber_and_secondary_fiber_pull_out_pull_in_behavior
#     [Documentation]
#     ...    This case verify the fiber pull in/our, L3 call successfully
#     ...    author:cris.cai
#     [Tags]    Qualcomm    classical    CRT_TRUNK    CRT_22R4    CRT_22R3
#     [Timeout]    1 hour
#     [Setup]
#     sleep    5s
#     [Teardown]    sleep    4s
# 
# 
# *** Keywords ***
# Prepare the atten for case016
#     Adjust RU1 Attenuation    value=${5}
# 
# Adjust RU atten for HO
#     [Arguments]    ${value1}    ${value2}
#     Adjust the Attenuation Value    ports=${5GRU1_ANT1}    value=${value1}    attenuation_port_numbers_oneport=${5GRU1_ANT1}
#     Adjust the Attenuation Value    ports=${5GRU1_ANT2}    value=${value1}    attenuation_port_numbers_oneport=${5GRU1_ANT2}
#     Adjust the Attenuation Value    ports=${5GRU1_ANT3}    value=${value2}    attenuation_port_numbers_oneport=${5GRU1_ANT3}
#     Adjust the Attenuation Value    ports=${5GRU1_ANT4}    value=${value2}    attenuation_port_numbers_oneport=${5GRU1_ANT4}
# 
# Analysis wireshark log for case016
#     [Arguments]    ${x2log1}    ${x2log2}
#     ${all_packets}=    load_pcap_file    pcap_file=${epc_log_path}${x2log1}
#     ${MR_Fliter} =    Catenate    x2ap.X2AP_PDU == 0 and x2ap.procedureCode == 35
#     ${MR} =    filter_packets_by_expression    filter_expression=${MR_Fliter}
#     ${MR_Value} =    get_field_value_by_xpath    pdml_list=${MR}    xpath=.//x2ap.procedureCode
#     should be equal    ${MR_Value[0]}    35
#     ${SgNBModif_Conf_Fliter} =    Catenate    x2ap.X2AP_PDU == 1 and x2ap.procedureCode == 30
#     ${SgNBModif_Conf} =    filter_packets_by_expression    filter_expression=${SgNBModif_Conf_Fliter}
#     ${SgNBModif_Conf_Value} =    get_field_value_by_xpath    pdml_list=${SgNBModif_Conf}    xpath=.//x2ap.procedureCode
#     should be equal    ${SgNBModif_Conf_Value[0]}    30
#     ${SgNBModif_Req_Fliter} =    Catenate    x2ap.X2AP_PDU == 0 and x2ap.procedureCode == 30
#     ${SgNBModif_Req} =    filter_packets_by_expression    filter_expression=${SgNBModif_Req_Fliter}
#     ${pci_value} =    get_field_value_by_xpath    pdml_list=${SgNBModif_Req}    xpath=.//nr-rrc.physCellId
#     should be equal    ${pci_value[0]}    81
#     ${t304_value} =    get_field_value_by_xpath    pdml_list=${SgNBModif_Req}    xpath=.//nr-rrc.t304
#     should be equal    ${t304_value[0]}    6
#     ${recoverPDCP_value} =    get_field_value_by_xpath    pdml_list=${SgNBModif_Req}    xpath=.//nr-rrc.recoverPDCP
#     should be equal    ${recoverPDCP_value[0]}    0
#     ${reestablishRLC_value} =    get_field_value_by_xpath    pdml_list=${SgNBModif_Req}    xpath=.//nr-rrc.reestablishRLC
#     should be equal    ${reestablishRLC_value[0]}    0
#     ${reestablishPDCP_value} =    get_field_value_by_xpath    pdml_list=${SgNBModif_Req}    xpath=.//nr-rrc.reestablishPDCP
#     should be empty    ${reestablishPDCP_value}
#     ${CRNTI_cell2} =    get_field_value_by_xpath    pdml_list=${SgNBModif_Req}    xpath=.//nr-rrc.newUE_Identity
#     should not be empty    ${CRNTI_cell2}
#     ${SgNBaddition_Ack_Fliter} =    Catenate    x2ap.X2AP_PDU == 1 and x2ap.procedureCode == 27
#     ${SgNBaddition_Ack} =    filter_packets_by_expression    filter_expression=${SgNBaddition_Ack_Fliter}
#     ${CRNTI_cell1} =    get_field_value_by_xpath    pdml_list=${SgNBaddition_Ack}    xpath=.//nr-rrc.newUE_Identity
#     should not be empty    ${CRNTI_cell1}
#     ${SgNBRelease_Required_Fliter} =  Catenate    x2ap.X2AP_PDU == 0 and x2ap.procedureCode == 32
#     ${SgNBRelease_Required} =    filter_packets_by_expression    filter_expression=${SgNBRelease_Required_Fliter}
#     ${SgNBRelease_Required_value} =    get_field_value_by_xpath    pdml_list=${SgNBRelease_Required}    xpath=.//x2ap.procedureCode
#     should be empty     ${SgNBRelease_Required_value}
#     ${UEContext_Release_fliter} =  Catenate    x2ap.X2AP_PDU == 0 and x2ap.procedureCode == 5
#     ${UEContext_Release} =    filter_packets_by_expression    filter_expression=${UEContext_Release_fliter}
#     ${UEContext_Release_Value} =    get_field_value_by_xpath    pdml_list=${UEContext_Release}    xpath=.//x2ap.procedureCode
#     should be empty    ${UEContext_Release_Value}
#     sleep    5s
#     ${all_packets1}=    load_pcap_file    pcap_file=${epc_log_path}${x2log2}
#     ${MR_Fliter} =    Catenate    x2ap.X2AP_PDU == 0 and x2ap.procedureCode == 35
#     ${MR} =    filter_packets_by_expression    filter_expression=${MR_Fliter}
#     ${MR_Value} =    get_field_value_by_xpath    pdml_list=${MR}    xpath=.//x2ap.procedureCode
#     should be equal    ${MR_Value[0]}    35
#     ${SgNBModif_Conf_Fliter} =    Catenate    x2ap.X2AP_PDU == 1 and x2ap.procedureCode == 30
#     ${SgNBModif_Conf} =    filter_packets_by_expression    filter_expression=${SgNBModif_Conf_Fliter}
#     ${SgNBModif_Conf_Value} =    get_field_value_by_xpath    pdml_list=${SgNBModif_Conf}    xpath=.//x2ap.procedureCode
#     should be equal    ${SgNBModif_Conf_Value[0]}    30
#     ${SgNBModif_Req_Fliter} =    Catenate    x2ap.X2AP_PDU == 0 and x2ap.procedureCode == 30
#     ${SgNBModif_Req} =    filter_packets_by_expression    filter_expression=${SgNBModif_Req_Fliter}
#     ${pci_value} =    get_field_value_by_xpath    pdml_list=${SgNBModif_Req}    xpath=.//nr-rrc.physCellId
#     should be equal    ${pci_value[0]}    80
#     ${t304_value} =    get_field_value_by_xpath    pdml_list=${SgNBModif_Req}    xpath=.//nr-rrc.t304
#     should be equal    ${t304_value[0]}    6
#     ${recoverPDCP_value} =    get_field_value_by_xpath    pdml_list=${SgNBModif_Req}    xpath=.//nr-rrc.recoverPDCP
#     should be equal    ${recoverPDCP_value[0]}    0
#     ${reestablishRLC_value} =    get_field_value_by_xpath    pdml_list=${SgNBModif_Req}    xpath=.//nr-rrc.reestablishRLC
#     should be equal    ${reestablishRLC_value[0]}    0
#     ${reestablishPDCP_value} =    get_field_value_by_xpath    pdml_list=${SgNBModif_Req}    xpath=.//nr-rrc.reestablishPDCP
#     should be empty    ${reestablishPDCP_value}
#     ${CRNTI_cell1_02} =    get_field_value_by_xpath    pdml_list=${SgNBModif_Req}    xpath=.//nr-rrc.newUE_Identity
#     should not be empty    ${CRNTI_cell1_02}
#     ${SgNBaddition_Ack_Fliter} =    Catenate    x2ap.X2AP_PDU == 1 and x2ap.procedureCode == 27
#     ${SgNBaddition_Ack} =    filter_packets_by_expression    filter_expression=${SgNBaddition_Ack_Fliter}
#     should not be equal    ${CRNTI_cell1_02}    ${CRNTI_cell1}
#     should not be equal    ${CRNTI_cell1_02}    ${CRNTI_cell2}
#     ${SgNBRelease_Required_Fliter} =  Catenate    x2ap.X2AP_PDU == 0 and x2ap.procedureCode == 32
#     ${SgNBRelease_Required} =    filter_packets_by_expression    filter_expression=${SgNBRelease_Required_Fliter}
#     ${SgNBRelease_Required_value} =    get_field_value_by_xpath    pdml_list=${SgNBRelease_Required}    xpath=.//x2ap.procedureCode
#     should be empty     ${SgNBRelease_Required_value}
#     ${UEContext_Release_fliter} =  Catenate    x2ap.X2AP_PDU == 0 and x2ap.procedureCode == 5
#     ${UEContext_Release} =    filter_packets_by_expression    filter_expression=${UEContext_Release_fliter}
#     ${UEContext_Release_Value} =    get_field_value_by_xpath    pdml_list=${UEContext_Release}    xpath=.//x2ap.procedureCode
#     should be empty    ${UEContext_Release_Value}
# 
# Modify scf file for case016
#     run keyword and continue on failure     commissioning.Modify Scf    input_scf=${tl_scf_dir_path}${tl_scf_filename}
#     ...            output_scf=${epc_log_path}${tl_scf_filename}    parameters_lists=${PARAMS_TO_MODIFY_FEATURE016_REG}

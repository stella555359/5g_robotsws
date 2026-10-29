# # #*** Settings ***
# # #Force Tags    PY36
# # #Documentation     author: yayun zhang
# # #...                 contact: yayun.zhang@nokia-sbell.com
# # #...                 squad group: SG_03
# # #...                 feature : CB006112
# # #
# # #Resource     ./../CB006112/Resources/CB006112_common_keywords.robot
# # #
# # #Suite Setup    Run Keywords
# # #...            Set automatic rotation on UEs                         AND
# # #...            Setup for SA Env cell on-air on gnb2                  AND
# # #...            Run Keyword And Ignore Error    Lock The First gNB    AND
# # #...            Run Keyword And Ignore Error    locked LTE cell
# # #
# # #Suite Teardown    Run Keywords
# # #...            Run Keyword And Ignore Error    Unlock The First gNB      AND
# # #...            run keyword and ignore error    unlocked LTE cell
# # #
# # #
# # #*** Variables ***
# # #${SCF_path}    /opt/workspace/CRT/Master/SCF_file/
# # ##${SCF_file_name}    gNB2_6112_A_14.xml
# # #${SCF_file_name_2}       gNB2_6112_A_13.xml
# # ##${tl_scf_dir_path}    /home/ute/TAF/zyy/
# # #${epc_log_path}       /tmp/
# # ##${tl_scf_file_name}      gNB2_6112_A_13.xml
# # #${interface1}    any
# # #${nglogname1}    6112_A_13_UE2_attach.pcap
# # #${nglogname2}    6112_A_13_UE2_VONR.pcap
# # #${enb_instance}    ${tl.enbs[0].instance_id}
# # #${gnb_filter2}    ngap.procedureCode == 26 and ngap.fiveQI == 1
# # #${gnb_filter3}    nr-rrc.sn_FieldLength == 0 and f1ap.procedureCode == 7 and nr-rrc.drx_Config == 0
# # #${value3}    0
# # #${gnb_filter4}    e1ap.procedureCode == 9 and e1ap.dRB_Inactivity_Timer == 15
# # #${value4}    15
# # #
# # #*** Test Cases ***
# # #[1]CB006112-A_13_Successful_setup_of_VoNR_call_with_FDD_support_short_RLC_SN_by_AES_ciphering
# # #    [Documentation]    Test case description the gNB behaviour for the successful setup of Voice over NR call with FDD by AMR-WB codec
# # #    [Tags]                CRT_22R2    CB006112-A
# # #    [Setup]
# # #    Check UE device exist    ue_index=${1}
# # #    Prepare env with UE      ue_index=${1}
# # #    Start Capture Wireshark Logs on gNB2     nglogname=${nglogname1}    interface=${interface1}
# # #    Check phone attach successfully on SA env    gnb_index=1    ue_index=${1}
# # #    sleep    2s
# # #    Stop Capture Wireshark Logs on gNB2    nglogname=${nglogname1}
# # #    Start Capture Wireshark Logs on gNB2    nglogname=${nglogname2}    interface=${interface1}
# # #    Make a VoNR call(+6688)    ue_index=${1}
# # #    hang up VoNR call    ue_index=${1}
# # #    sleep    2s
# # #    Stop Capture Wireshark Logs on gNB2    nglogname=${nglogname2}
# # #    TL UE detach    ue_index=${1}
# # #    Check IE wireshark log for VONR setup      logname=${nglogname2}    message_filter=${gnb_filter2}
# # #    Check IE wireshark log for F1 configure    logname=${nglogname2}    message_filter=${gnb_filter3}     value=${value3}
# # #    Check IE wireshark log for E1_dRB_Inactivity configure    logname=${nglogname2}    message_filter=${gnb_filter4}     value=${value4}
# # #    [Teardown]     Run Keywords
# # #    ...    Run Keyword And Ignore Error    Stop Capture Wireshark Logs on gNB2   nglogname=${nglogname1}      AND
# # #    ...    Run Keyword And Ignore Error    Stop Capture Wireshark Logs on gNB2    nglogname=${nglogname2}      AND
# # #    ...    Run Keyword And Ignore Error    CI_interface.Common Case Teardown
# # #
# # #*** Keywords ***
# # #Check IE wireshark log for F1 configure
# # #    [Arguments]    ${logname}    ${message_filter}   ${value}
# # #    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}
# # #    ${filter_expression}=     Catenate    ${message_filter}
# # #    ${filtered_packets}=    cap.filter_packets_by_expression    filter_expression=${filter_expression}
# # #    ${nr_rrc_sn_FieldLength}=     cap.get_field_value_by_xpath    pdml_list=${filtered_packets}
# # #    ...                                                xpath=.//nr-rrc.sn_FieldLength
# # #    should be equal    ${nr_rrc_sn_FieldLength[0]}    0
# # #
# # #Check IE wireshark log for E1_dRB_Inactivity configure
# # #    [Arguments]    ${logname}    ${message_filter}   ${value}
# # #    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}
# # #    ${filter_expression}=     Catenate    ${message_filter}
# # #    ${filtered_packets}=    cap.filter_packets_by_expression    filter_expression=${filter_expression}
# # #    ${e1ap_dRB_Inactivity_Timer}=     cap.get_field_value_by_xpath    pdml_list=${filtered_packets}
# # #    ...                                                xpath=.//e1ap.dRB_Inactivity_Timer
# # #    should be equal    ${e1ap_dRB_Inactivity_Timer[0]}    15
# # #
# # #Check IE wireshark log for E1 configure
# # #    [Arguments]    ${logname}    ${message_filter}    ${message_filter1}    ${message_filter2}   ${value}    ${value1}    ${value2}
# # #    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}
# # #    ${filter_expression}=     Catenate    ${message_filter}
# # #    ${filtered_packets}=    cap.filter_packets_by_expression    filter_expression=${filter_expression}
# # #    ${e1ap_pDCP_SN_Size_UL}=     cap.get_field_value_by_xpath    pdml_list=${filtered_packets}
# # #    ...                                                xpath=.//e1ap.pDCP_SN_Size_UL
# # #    should be equal    ${e1ap_pDCP_SN_Size_UL[0]}    1
# # #    ${filter_expression}=     Catenate    ${message_filter1}
# # #    ${filtered_packets}=    cap.filter_packets_by_expression    filter_expression=${filter_expression}
# # #    ${e1ap_pDCP_SN_Size_DL}=     cap.get_field_value_by_xpath    pdml_list=${filtered_packets}
# # #    ...                                                xpath=.//e1ap.pDCP_SN_Size_DL
# # #    should be equal    ${e1ap_pDCP_SN_Size_DL[0]}    1
# # #    ${filter_expression}=     Catenate    ${message_filter2}
# # #    ${filtered_packets}=    cap.filter_packets_by_expression    filter_expression=${filter_expression}
# # #    ${e1ap_dRB_Inactivity_Timer}=     cap.get_field_value_by_xpath    pdml_list=${filtered_packets}
# # #    ...                                                xpath=.//e1ap.dRB_Inactivity_Timer
# # #    should be equal    ${e1ap_dRB_Inactivity_Timer[0]}    15
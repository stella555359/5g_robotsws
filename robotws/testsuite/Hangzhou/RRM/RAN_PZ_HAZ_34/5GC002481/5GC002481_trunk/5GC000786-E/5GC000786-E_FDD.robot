*** Settings ***
Documentation     author: Jack zeng
...                 contact: jack.zeng@nokia-sbell.com
...                 squad group: SG_03
...                 feature : 5GC000786

Force Tags    CA_5G_RRM
...    PY36
Suite Setup    Run Keywords
...            robot_common_operations.Common Suite Setup    AND
...            Run Keyword And Ignore Error    Common Suite Setup for COAM    AND
...            5GC002481_common_keyword.Prepare env with UEs    AND
...            Get gnb release info   AND
...            Run Keyword And Ignore Error    locked LTE cell    LNcell_id=${0}    AND
...            SCF load and commission

Suite Teardown    Run Keywords
...               robot_common_operations.Common Suite Teardown    AND
...               Run Keyword If Any Tests Failed    Run Keyword And Ignore Error
...               5GC002481_common_keyword.Common Suite Teardown for COAM    gnb_index=${1}

Resource    ../../Resources/5GC002481_common_keyword.robot


*** Variables ***


${nglogname1_1}    786E01_01.pcap
${nglogname1_2}    786E01_02.pcap
${nglogname3_1}    786E03_01.pcap
${nglogname3_2}    786E03_02.pcap
${nglogname7_1}    786E07_01.pcap
${nglogname7_2}    786E07_02.pcap
${nglogname11_1}    786E11_01.pcap
${nglogname11_2}    786E11_02.pcap
${nglogname15_1}    786E15_01.pcap
${nglogname15_2}    786E15_02.pcap

${Null_ciphering}    Null ciphering algorithm
${SNOW_3G-based}    SNOW 3G-based algorithm
${AES-based}    AES-based algorithm
${ZUC-based}    ZUC-based algorithm
${nullFallback_accepted}    Null ciphering algorithm fallback accepted

${phone_number_TL351_2}    18001006429
${phone_number_TL351_1}    17001006254
${gnb_path}           /tmp
${tshark_path}      /usr/bin/tshark
${tl_scf_file_name}    golden_FDD.xml
${tl_scf_file_24R1}    golden_FDD_23R4.xml
${enb_path}    /tmp
${ngap_filter}    ngap
${s1ap_filter}    s1ap
@{allow_fault_list}    7311

*** Test Cases ***
[1]5GC002481_5GC000786_E_007_Release_of_FDD_Video_over_NR_call_5QI-1_and_5QI-2_adding_together_only_5QI-2_removal
    [Documentation]
    ...    This user scenarios describe the gNB behavior to remove the 5QI-2 QoS flow of a Video over NR call with FDD.
    ...    This Video over NR call will be downgraded to a Voice over NR Call.
    [Tags]    SBTS00    QC_57069    CIT_TRUNK    5GC002481
    [Timeout]    1 hour
    [Setup]    robot_common_operations.Common Case Setup
    AlarmWatchdog.add_allow_alarms    fault_id=${allow_fault_list}
    wait until keyword succeeds    3x   10s    Check E_007 test case result status
    [Teardown]    Run Keywords
    ...    Common Case Teardown for COAM    AND
    ...    sleep    1m    AND    5GC002481_common_keyword.hang up VoNR call    AND
    ...    786 UEs detach    AND
    ...    Run Keyword And Ignore Error    5GC002481_common_keyword.Stop Capture Wireshark Logs on gNB
    ...     nglogname=${nglogname7_1}    gnb_index=${1}    AND
    ...    Run Keyword And Ignore Error    5GC002481_common_keyword.Stop Capture Wireshark Logs on gNB
    ...    nglogname=${nglogname7_2}    gnb_index=${1}


#[1]5GC002481_5GC000786_E_011_Release_of_FDD_Video_over_NR_call_5QI-1_and_5QI-2_adding_together_both_5QI-1_and_5QI-2_removal
#    [Documentation]
#    ...    This user scenario describes the gNB behavior for the release of Video over NR call with FDD.
#    ...    Both 5QI-1 and 5QI-2 QoS flows will be removed.
#    [Tags]    SBTS00    QC_57070        5GC002481
#    [Timeout]    1 hour
#    [Setup]
#    5GC002481_common_keyword.Adjust eNB1_RU Attenuation to 120 for trunk
#    5GC002481_common_keyword.Adjust gNB1_RU HBTE Attenuation to 120
#    run keyword and ignore error    5GC002481_common_keyword.Check UE exist
#    5GC002481_common_keyword.Start Capture Wireshark Logs on gNB    nglogname=${nglogname11_1}    interface=any    gnb_index=${1}
#    5GC002481_common_keyword.786 UEs attach    gnb_index=${1}
#    5GC002481_common_keyword.Stop Capture Wireshark Logs on gNB    nglogname=${nglogname11_1}    gnb_index=${1}
#    5GC002481_common_keyword.Make a VoNR and ViNR call together    phone_number=${phone_number_TL351_2}
#    sleep     5s
#    5GC002481_common_keyword.Start Capture Wireshark Logs on gNB    nglogname=${nglogname11_2}    interface=any    gnb_index=${1}
#    sleep     5s
#    5GC002481_common_keyword.hang up VoNR and ViNR call
#    sleep     5s
#    5GC002481_common_keyword.Stop Capture Wireshark Logs on gNB    nglogname=${nglogname11_2}    gnb_index=${1}
#    Analysis wireshark log for case 786E11_02
#    Analysis wireshark log for case 786E11_01
#    [Teardown]    Run Keywords    sleep    1m    AND    5GC002481_common_keyword.hang up VoNR and ViNR call    AND
#    ...    786 UEs detach    AND
#    ...    Run Keyword And Ignore Error    5GC002481_common_keyword.Stop Capture Wireshark Logs on gNB
#    ...    nglogname=${nglogname11_1}    gnb_index=${1}    AND
#    ...    Run Keyword And Ignore Error    5GC002481_common_keyword.Stop Capture Wireshark Logs on gNB
#    ...     nglogname=${nglogname11_2}    gnb_index=${1}

*** Keywords ***
SCF load and commission
   Run Keyword if    '${release_info}' == '${branch}[1]'
   ...   Prepare gNB with cell on air    gnb_index=${1}    tl_scf_file_name=${tl_scf_file_24R1}
   ...   ELSE    Prepare gNB with cell on air    gnb_index=${1}    tl_scf_file_name=${tl_scf_file_name}

Check E_007 test case result status
    5GC002481_common_keyword.Adjust eNB1_RU Attenuation to 120 for trunk
    5GC002481_common_keyword.Adjust gNB1_RU HBTE Attenuation to 120
    run keyword and ignore error    5GC002481_common_keyword.Check UE exist
    5GC002481_common_keyword.Start Capture Wireshark Logs on gNB    nglogname=${nglogname7_1}    interface=any    gnb_index=${1}
    5GC002481_common_keyword.786 UEs attach    gnb_index=${1}
    5GC002481_common_keyword.Stop Capture Wireshark Logs on gNB    nglogname=${nglogname7_1}    gnb_index=${1}
    5GC002481_common_keyword.Make a VoNR and ViNR call together    phone_number=${phone_number_TL351_2}
    sleep     5s
    5GC002481_common_keyword.Start Capture Wireshark Logs on gNB    nglogname=${nglogname7_2}    interface=any    gnb_index=${1}
    sleep     5s
    switch ViNR to VoNR call
    sleep     5s
    5GC002481_common_keyword.Stop Capture Wireshark Logs on gNB    nglogname=${nglogname7_2}    gnb_index=${1}
    5GC002481_common_keyword.hang up VoNR call
    Analysis wireshark log for case 786E07_02
    Analysis wireshark log for case 786E07_01
    [Teardown]    run keyword and ignore error    Test case recover

Test case recover
    Run Keyword And Ignore Error    5GC002481_common_keyword.hang up VoNR call
    786 UEs detach

786 UEs detach
    power_ue.UE Detach    ue_type=huawei
    power_ue.UE Detach    ue_type=huawei    ue_index=${1}

switch ViNR to VoNR call
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
    sleep   5s
    csn.send_command    command=adb -s ${serial_number} shell input tap ${trigger_button}    connection=cygwin${ue_index}
    sleep    1s
    csn.send_command    command=adb -s ${serial_number} shell input tap ${switch_to_VoNR}    connection=cygwin${ue_index}

check points with ViNR call release
    [Arguments]    ${logname}
    ${all_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}

    ${PDUSessionResourceModifyRequest} =    Catenate    ngap.NGAP_PDU == 0 and ngap.procedureCode == 26
    Log To Console    check release value on PDUSessionResourceModifyRequest message
    ${PDUSessionResourceModifyRequest_status} =    run_keyword_and_return_status
    ...    parser.filter_packets_by_expression    filter_expression=${PDUSessionResourceModifyRequest}
    should be equal    ${PDUSessionResourceModifyRequest_status}    ${True}
    ${filtered_packets}=    parser.filter_packets_by_expression
    ...    filter_expression=${PDUSessionResourceModifyRequest}
    ${ngap_nas}=    parser.get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...    xpath=.//ngap.nas
    Should Contain    ${ngap_nas}    0

    ${BearerContextModificationRequest} =    Catenate    e1ap.E1AP_PDU == 0 and e1ap.procedureCode == 9
    Log To Console    check release BearerContextModificationRequest message
    ${BearerContextModificationRequest_status} =    run_keyword_and_return_status
    ...    parser.filter_packets_by_expression    filter_expression=${BearerContextModificationRequest}
    should be equal    ${BearerContextModificationRequest_status}    ${True}
    ${filtered_packets}=    parser.filter_packets_by_expression
    ...    filter_expression=${BearerContextModificationRequest}
    ${e1ap_dRB_To_Remove_List_NG_RAN}=    parser.get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...    xpath=.//e1ap.dRB_To_Remove_List_NG_RAN
    Should Contain    ${e1ap_dRB_To_Remove_List_NG_RAN}    1
    ${e1ap_dRB_ID}=    parser.get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...    xpath=.//e1ap.dRB_ID
#    Should Not Contain    ${e1ap_dRB_ID}    6
#    Should Contain    ${e1ap_dRB_ID}    7

    ${BearerContextModificationResponse} =    Catenate    e1ap.E1AP_PDU == 1 and e1ap.procedureCode == 9
    Log To Console    check release BearerContextModificationResponse message
    ${BearerContextModificationResponse_status} =    run_keyword_and_return_status
    ...    parser.filter_packets_by_expression    filter_expression=${BearerContextModificationResponse}
    should be equal    ${BearerContextModificationResponse_status}    ${True}

    ${UEContextModificationRequest} =    Catenate    f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 7
    Log To Console    check value on release UEContextModificationRequest message
    ${UEContextModificationRequest_status} =    run_keyword_and_return_status
    ...    parser.filter_packets_by_expression    filter_expression=${UEContextModificationRequest}
    should be equal    ${UEContextModificationRequest_status}    ${True}
    ${filtered_packets}=    parser.filter_packets_by_expression
    ...    filter_expression=${UEContextModificationRequest}
    ${f1ap_DRBs_ToBeReleased_List}=    parser.get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...    xpath=.//f1ap.DRBs_ToBeReleased_List
    Should Contain    ${f1ap_DRBs_ToBeReleased_List}    1

    ${UEContextModificationResponse} =    Catenate    f1ap.F1AP_PDU == 1 and f1ap.procedureCode == 7
    Log To Console    check value on release UEContextModificationResponse message
    ${UEContextModificationResponse_status} =    run_keyword_and_return_status
    ...    parser.filter_packets_by_expression    filter_expression=${UEContextModificationResponse}
    should be equal    ${UEContextModificationResponse_status}    ${True}

    ${DLRRCMessageTransfer} =    Catenate    f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 12
    Log To Console    check release DLRRCMessageTransfer message
    ${DLRRCMessageTransfer_status} =    run_keyword_and_return_status
    ...    parser.filter_packets_by_expression    filter_expression=${DLRRCMessageTransfer}
    should be equal    ${DLRRCMessageTransfer_status}    ${True}

    ${ULRRCMessageTransfer} =    Catenate    f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 13
    Log To Console    check release ULRRCMessageTransfer message
    ${ULRRCMessageTransfer_status} =    run_keyword_and_return_status
    ...    parser.filter_packets_by_expression    filter_expression=${ULRRCMessageTransfer}
    should be equal    ${ULRRCMessageTransfer_status}    ${True}

    ${PDUSessionResourceModifyResponse} =    Catenate    ngap.NGAP_PDU == 1 and ngap.procedureCode == 26
    Log To Console    check release value on PDUSessionResourceModifyResponse
    ${PDUSessionResourceModifyResponse_status} =    run_keyword_and_return_status
    ...    parser.filter_packets_by_expression    filter_expression=${PDUSessionResourceModifyResponse}
    should be equal    ${PDUSessionResourceModifyResponse_status}    ${True}
    ${filtered_packets}=    parser.filter_packets_by_expression
    ...    filter_expression=${PDUSessionResourceModifyResponse}
    ${ngap_pDUSessionResourceModifyResponseTransfer} =    parser.get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...    xpath=.//ngap.pDUSessionResourceModifyResponseTransfer
    Should Contain    ${ngap_pDUSessionResourceModifyResponseTransfer}    00


check voiceOverNR support
    [Arguments]    ${logname}
    ${all_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}

    ${UERadioCapabilityInfoIndication} =    Catenate    ngap.NGAP_PDU == 0 and ngap.procedureCode == 44
    Log To Console    check voiceOverNR value on UERadioCapabilityInfoIndication message
    ${UERadioCapabilityInfoIndication_status} =    run_keyword_and_return_status
    ...    parser.filter_packets_by_expression    filter_expression=${UERadioCapabilityInfoIndication}
    should be equal    ${UERadioCapabilityInfoIndication_status}    ${True}
    ${filtered_packets}=    parser.filter_packets_by_expression
    ...    filter_expression=${UERadioCapabilityInfoIndication}
    ${nr_rrc_voiceOverNR}=    parser.get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...    xpath=.//nr-rrc.voiceOverNR
    Should Be Equal    ${nr_rrc_voiceOverNR[0]}    0

check Algorithm value
    [Arguments]    ${logname}    ${Algorithm_value}=2
    ${all_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}

    ${BearerContextSetupRequest} =    Catenate    e1ap.E1AP_PDU == 0 and e1ap.procedureCode == 8
    Log To Console    check cipheringAlgorithm value on BearerContextSetupRequest message
    ${BearerContextSetupRequest_status} =    run_keyword_and_return_status
    ...    parser.filter_packets_by_expression    filter_expression=${BearerContextSetupRequest}
    should be equal    ${BearerContextSetupRequest_status}    ${True}
    ${filtered_packets}=    parser.filter_packets_by_expression
    ...    filter_expression=${BearerContextSetupRequest}
    ${e1ap_cipheringAlgorithm}=    parser.get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...    xpath=.//e1ap.cipheringAlgorithm
    Should Be Equal    ${e1ap_cipheringAlgorithm[0]}    ${Algorithm_value}

lock diff gnb cell
    run keyword if    '${enb_instance}'=='5395'    lock TL351 gnb cell2

lock TL351 gnb cell2
    Lock_gnb2_Cell    url=${WEBUI_COAM}    cell_id=2    bts_host=${asik_addr}

unlock diff gnb cell
    run keyword if    '${enb_instance}'=='5395'    unlock TL351 gnb cell2

unlock TL351 gnb cell2
    unLock_gnb2_Cell    url=${WEBUI_COAM}    cell_id=2    bts_host=${asik_addr}

pre-check paramaters for E_01
    check value of parameter actVoNR
    check value of parameter algorithm

pre-check paramaters for E_03
    check value of parameter actVoNR
    check value of parameter algorithm    value1=0    value3=9

pre-check paramaters for E_07
    check value of parameter actVoNR
    check value of parameter algorithm

pre-check paramaters for E_11
    check value of parameter actVoNR
    check value of parameter algorithm

Analysis wireshark log for case 786E01_01
    check voiceOverNR support    logname=${nglogname1_1}
    check Algorithm value    logname=${nglogname1_1}

Analysis wireshark log for case 786E01_02
    check points with VoNR and ViNR call together    logname=${nglogname1_2}

Analysis wireshark log for case 786E03_01
    check voiceOverNR support    logname=${nglogname3_1}
    check Algorithm value    logname=${nglogname3_1}    Algorithm_value=2

Analysis wireshark log for case 786E03_02
    check points with VoNR and ViNR call together    logname=${nglogname3_2}

Analysis wireshark log for case 786E07_01
    check voiceOverNR support    logname=${nglogname7_1}
    check Algorithm value    logname=${nglogname7_1}

Analysis wireshark log for case 786E07_02
    check points with ViNR call release     logname=${nglogname7_2}

Analysis wireshark log for case 786E11_01
    check voiceOverNR support    logname=${nglogname11_1}
    check Algorithm value    logname=${nglogname11_1}

check points with VoNR and ViNR call release together
    [Arguments]    ${logname}
    ${all_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}

    ${PDUSessionResourceModifyRequest} =    Catenate    ngap.NGAP_PDU == 0 and ngap.procedureCode == 26
    Log To Console    check release value on PDUSessionResourceModifyRequest message
    ${PDUSessionResourceModifyRequest_status} =    run_keyword_and_return_status
    ...    parser.filter_packets_by_expression    filter_expression=${PDUSessionResourceModifyRequest}
    should be equal    ${PDUSessionResourceModifyRequest_status}    ${True}
    ${filtered_packets}=    parser.filter_packets_by_expression
    ...    filter_expression=${PDUSessionResourceModifyRequest}
    ${ngap_nas}=    parser.get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...    xpath=.//ngap.nas
    Should Contain    ${ngap_nas}    0

    ${BearerContextModificationRequest} =    Catenate    e1ap.E1AP_PDU == 0 and e1ap.procedureCode == 9
    Log To Console    check release BearerContextModificationRequest message
    ${BearerContextModificationRequest_status} =    run_keyword_and_return_status
    ...    parser.filter_packets_by_expression    filter_expression=${BearerContextModificationRequest}
    should be equal    ${BearerContextModificationRequest_status}    ${True}
    ${filtered_packets}=    parser.filter_packets_by_expression
    ...    filter_expression=${BearerContextModificationRequest}
    ${e1ap_dRB_To_Remove_List_NG_RAN}=    parser.get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...    xpath=.//e1ap.dRB_To_Remove_List_NG_RAN
    Should Contain    ${e1ap_dRB_To_Remove_List_NG_RAN}    2
    ${e1ap_dRB_ID}=    parser.get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...    xpath=.//e1ap.dRB_ID
    Should Contain    ${e1ap_dRB_ID}    6
    Should Contain    ${e1ap_dRB_ID}    7
    ${BearerContextModificationResponse} =    Catenate    e1ap.E1AP_PDU == 1 and e1ap.procedureCode == 9
    Log To Console    check release BearerContextModificationResponse message
    ${BearerContextModificationResponse_status} =    run_keyword_and_return_status
    ...    parser.filter_packets_by_expression    filter_expression=${BearerContextModificationResponse}
    should be equal    ${BearerContextModificationResponse_status}    ${True}
    ${UEContextModificationRequest} =    Catenate    f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 7
    Log To Console    check value on release UEContextModificationRequest message
    ${UEContextModificationRequest_status} =    run_keyword_and_return_status
    ...    parser.filter_packets_by_expression    filter_expression=${UEContextModificationRequest}
    should be equal    ${UEContextModificationRequest_status}    ${True}
    ${filtered_packets}=    parser.filter_packets_by_expression
    ...    filter_expression=${UEContextModificationRequest}
    ${f1ap_DRBs_ToBeReleased_List}=    parser.get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...    xpath=.//f1ap.DRBs_ToBeReleased_List
    Should Contain    ${f1ap_DRBs_ToBeReleased_List}    2
    ${UEContextModificationResponse} =    Catenate    f1ap.F1AP_PDU == 1 and f1ap.procedureCode == 7
    Log To Console    check value on release UEContextModificationResponse message
    ${UEContextModificationResponse_status} =    run_keyword_and_return_status
    ...    parser.filter_packets_by_expression    filter_expression=${UEContextModificationResponse}
    should be equal    ${UEContextModificationResponse_status}    ${True}
    ${filtered_packets}=    parser.filter_packets_by_expression
    ...    filter_expression=${UEContextModificationResponse}
    ${nr_rrc_drx_Config}=    parser.get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...    xpath=.//nr-rrc.drx_Config
#    Should Contain    ${nr_rrc_drx_Config}    1
    ${DLRRCMessageTransfer} =    Catenate    f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 12
    Log To Console    check release DLRRCMessageTransfer message
    ${DLRRCMessageTransfer_status} =    run_keyword_and_return_status
    ...    parser.filter_packets_by_expression    filter_expression=${DLRRCMessageTransfer}
    should be equal    ${DLRRCMessageTransfer_status}    ${True}

    ${ULRRCMessageTransfer} =    Catenate    f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 13
    Log To Console    check release ULRRCMessageTransfer message
    ${ULRRCMessageTransfer_status} =    run_keyword_and_return_status
    ...    parser.filter_packets_by_expression    filter_expression=${ULRRCMessageTransfer}
    should be equal    ${ULRRCMessageTransfer_status}    ${True}

    ${PDUSessionResourceModifyResponse} =    Catenate    ngap.NGAP_PDU == 1 and ngap.procedureCode == 26
    Log To Console    check release value on PDUSessionResourceModifyResponse
    ${PDUSessionResourceModifyResponse_status} =    run_keyword_and_return_status
    ...    parser.filter_packets_by_expression    filter_expression=${PDUSessionResourceModifyResponse}
    should be equal    ${PDUSessionResourceModifyResponse_status}    ${True}
    ${filtered_packets}=    parser.filter_packets_by_expression
    ...    filter_expression=${PDUSessionResourceModifyResponse}
    ${ngap_pDUSessionResourceModifyResponseTransfer} =    parser.get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...    xpath=.//ngap.pDUSessionResourceModifyResponseTransfer
    Should Contain    ${ngap_pDUSessionResourceModifyResponseTransfer}    00

Analysis wireshark log for case 786E11_02
    check points with VoNR and ViNR call release together    logname=${nglogname11_2}

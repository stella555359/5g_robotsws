# # #*** Settings ***
# # #Force Tags    PY36
# # #Documentation     author: bella chen
# # #...                 contact: bella.chen@nokia-sbell.com
# # #...                 squad group: SG_03
# # #...                 feature : CB007326_6112
# # #
# # #Resource     Resources/CB007326_6112_common_keywords.robot
# # #Variables    ./Resources/variables_7326.py
# # #
# # #Suite Setup    Run Keywords
# # #...            Run Keyword And Ignore Error       Common Suite Setup for COAM    AND
# # #...            Set automatic rotation on UEs    AND
# # #...            Update the swconfig file     localFilePath=${localFilePath_swconfig_6112}      AND
# # #...            Setup for SA Env cell on-air on gnb2
# # #
# # #
# # #Suite Teardown    Run Keyword And Ignore Error    Common Suite Teardown for COAM
# # #
# # #*** Variables ***
# # #${SCF_path}    /opt/workspace/CRT/Master/SCF_file/
# # #${SCF_file_name_2}       7326_784_SCF.xml
# # ##${epc_log_path}       /tmp/
# # #${localFilePath_swconfig_6112}    /opt/workspace/CRT/Master/SCF_file/swconfig.txt
# # #${interface1}    any
# # #${nglogname1}    6112_C20_attach.pcap
# # #${nglogname2}    6112_C20_VONR.pcap
# # #${nglogname3}    6112_C20_InterRAT.pcap
# # #${att_good}    ${0}
# # #${att_bad}    ${127}
# # #${ul_throughput2}    2M
# # #${dl_throughput2}    10M
# # #${inter_rat_target_value}    ${31}
# # #
# # #*** Test Cases ***
# # #[1]CB007326_5G_A_CB006112-C_20_Successful_InerRAT_handover_based_on_B2_measurements_with_5QI1_5QI5
# # #    [Documentation]
# # #    ...    This user scenario describes the gNB behaviour, when a UE for which A2 measurement report has been received
# # #    ...    is configured with required B2 inter-RAT measurements while the UE has been configured with 5QI-1 and 5QI-5
# # #    ...    and optionally 5QI-2 bearers.
# # #    [Tags]            classical    CRT_TRUNK    CRT_22R2
# # #    [Setup]    Adjust gNB_RU Attenuation
# # #    Modify the COAM parameter with admin API    parameters=${parameter_CB006112_C_20}
# # #    Run Keyword If    '${gnb_instance}'=='${gnb_id[0]}'    Locked LTE cell
# # #    ...    ELSE    Locked LTE cell tl388
# # #    Set Suite Variable    ${ue_type}    xiaomi
# # #    Check UE device exist
# # #    Prepare env with UE
# # #    Run Keyword If    '${gnb_instance}'=='${gnb_id[0]}'    Get all xiaomi11 pointer variable
# # #    ...    ELSE IF    '${gnb_instance}'=='${gnb_id[2]}'    Get all xiaomi11 pointer variable tl388
# # #    ...    ELSE    Get all xiaomi11 pointer variable tl377
# # ###  1.1 UE1 attach to gnb
# # #    Start Capture Wireshark Logs on gNB2    nglogname=${nglogname1}    interface=${interface1}
# # #    Power UE Attach and Verify attach
# # #    Stop Capture Wireshark Logs on gNB2    nglogname=${nglogname1}
# # ###  1.2 UE1 make a VoNR
# # #    Start Capture Wireshark Logs on gNB2    nglogname=${nglogname2}    interface=${interface1}
# # #    Start a VONR call
# # #    sleep    5s
# # #    Stop Capture Wireshark Logs on gNB2   nglogname=${nglogname2}
# # #    Run Keyword If    '${gnb_instance}'=='${gnb_id[0]}'    Unlocked LTE cell
# # #    ...    ELSE    Unlocked LTE cell 388
# # #    Start DL and UL data transfer    dl_throughput=${dl_throughput2}    ul_throughput=${ul_throughput2}
# # ###    triger InterRAT HO 5Gcell1->LTE cell
# # #    Start Capture Wireshark Logs on gNB2    nglogname=${nglogname3}    interface=${interface1}
# # #    Adjust gNB_RU Attenuation for 1db    att_pmax=${inter_rat_target_value}
# # #    Stop Capture Wireshark Logs on gNB2   nglogname=${nglogname3}
# # #    sleep    5s
# # #    hang up VoNR call
# # #    sleep    5s
# # #    check point with B2 event of Inter_RAT HO    logname=${nglogname3}
# # #    [Teardown]     Run Keywords
# # #    ...    Run Keyword And Ignore Error    coam.teardown    connection=GNB_OAM    AND
# # #    ...    Run Keyword And Ignore Error    TL UE detach    AND
# # #    ...    Run Keyword And Ignore Error    Unlocked LTE cell
# # #
# # #
# # #
# # #*** Keywords ***
# # #
# # #check point with B2 event of Inter_RAT HO
# # #    [Arguments]    ${logname}
# # #    ${all_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}
# # #    ${HandoverRequired} =    Catenate    ngap.NGAP_PDU == 0 and ngap.procedureCode == 12
# # #    Log To Console    check radioNetwork value on HandoverRequired message
# # #    ${HandoverRequired_status} =    run_keyword_and_return_status
# # #    ...    parser.filter_packets_by_expression    filter_expression=${HandoverRequired}
# # #    should be equal    ${HandoverRequired_status}    ${True}
# # #    ${filtered_packets}=    parser.filter_packets_by_expression
# # #    ...    filter_expression=${HandoverRequired}
# # #    ${ngap_radioNetwork}=    parser.get_field_value_by_xpath    pdml_list=${filtered_packets}
# # #    ...    xpath=.//ngap.radioNetwork
# # #    Should Contain    ${ngap_radioNetwork}    32
# # #    ${s1ap_e_RAB_ID}=    parser.get_field_value_by_xpath    pdml_list=${filtered_packets}
# # #    ...    xpath=.//s1ap.e_RAB_ID
# # #    Should Not Contain    ${s1ap_e_RAB_ID}    7
# # #    Should Not Contain    ${s1ap_e_RAB_ID}    8
# # #
# # #    ${HandoverCommand} =    Catenate    ngap.NGAP_PDU == 1 and ngap.procedureCode == 12
# # #    Log To Console    check HandoverType value on HandoverCommand message
# # #    ${HandoverCommand_status} =    run_keyword_and_return_status
# # #    ...    parser.filter_packets_by_expression    filter_expression=${HandoverCommand}
# # #    should be equal    ${HandoverCommand_status}    ${True}
# # #    ${filtered_packets}=    parser.filter_packets_by_expression
# # #    ...    filter_expression=${HandoverCommand}
# # #    ${ngap_HandoverType}=    parser.get_field_value_by_xpath    pdml_list=${filtered_packets}
# # #    ...    xpath=.//ngap.HandoverType
# # #    Should Contain    ${ngap_HandoverType}    1
# # #
# # #    ${UEContextReleaseCommand} =    Catenate    ngap.NGAP_PDU == 0 and ngap.procedureCode == 41
# # #    Log To Console    check radioNetwork value on UEContextReleaseCommand message
# # #    ${UEContextReleaseCommand_status} =    run_keyword_and_return_status
# # #    ...    parser.filter_packets_by_expression    filter_expression=${UEContextReleaseCommand}
# # #    should be equal    ${UEContextReleaseCommand_status}    ${True}
# # #    ${filtered_packets}=    parser.filter_packets_by_expression
# # #    ...    filter_expression=${UEContextReleaseCommand}
# # #    ${ngap_radioNetwork}=    parser.get_field_value_by_xpath    pdml_list=${filtered_packets}
# # #    ...    xpath=.//ngap.radioNetwork
# # #    Should Contain    ${ngap_radioNetwork}    2
# # #
# # #    ${UEContextReleaseComplete} =    Catenate    ngap.NGAP_PDU == 1 and ngap.procedureCode == 41
# # #    Log To Console    check UEContextReleaseComplete message
# # #    ${UEContextReleaseComplete_status} =    run_keyword_and_return_status
# # #    ...    parser.filter_packets_by_expression    filter_expression=${UEContextReleaseComplete}
# # #    should be equal    ${UEContextReleaseComplete_status}    ${True}

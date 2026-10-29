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
# # #${nglogname1}    6112_C14_attach.pcap
# # #${nglogname2}    6112_C14_VONR.pcap
# # #${nglogname3}    6112_C14_interHO.pcap
# # #${att_good}    ${0}
# # #${att_bad}    ${127}
# # #${att_HO}    ${10}
# # #${att_HO_377}    ${30}
# # #${att_HO_388}    ${35}
# # #
# # #*** Test Cases ***
# # #[1]CB007326_5G_A_CB006112-C_14_Successful_TDD_InterFreq_IntraDU_handover_based_on_A3_measurements_with_5QI1_5QI5
# # #    [Documentation]    This user scenario describes the gNB behaviour, when a UE for which Inter-frequency A3
# # #    ...     measurements have been configured sends a Inter-frequency A3 measurement report and gNB performs
# # #    ...     handover based on the measurement report to a cell in the same gNB-DU.
# # #    [Tags]            classical    CRT_TRUNK    CRT_22R2
# # #    [Setup]    Adjust gNB_RU Attenuation
# # #    Modify the COAM parameter with admin API    parameters=${parameter_CB006112_C_14}
# # #    Check Gnb cell on air
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
# # #    Stop Capture Wireshark Logs on gNB2   nglogname=${nglogname2}
# # #
# # ##    triger Intergnb HO   cell1->cell2
# # #    Start Capture Wireshark Logs on gNB2    nglogname=${nglogname3}    interface=${interface1}
# # #    Run Keyword If    '${gnb_instance}'=='${gnb_id[0]}'
# # #    ...    Adjust the tl HBTE attenuation value    tl=${376}    value1=${att_good_388}    value2=${att_HO}
# # #    ...    ELSE IF    '${gnb_instance}'=='${gnb_id[2]}'
# # #    ...    Adjust the tl HBTE attenuation value    tl=${388}    value1=${att_HO}    value2=${att_good}
# # #    ...    ELSE    Adjust the tl HBTE attenuation value    tl=${377}    value1=${att_HO}    value2=${att_good}
# # #    sleep    5s
# # #    Stop Capture Wireshark Logs on gNB2   nglogname=${nglogname3}
# # #    sleep    5s
# # #    hang up VoNR call
# # #    sleep    5s
# # #
# # #    Check interHO sucessful with VoNR    logname=${nglogname3}
# # #    Check point with A1 and A3 event with VoNR specific    logname=${nglogname3}
# # #    [Teardown]     Run Keywords
# # #    ...    Run Keyword And Ignore Error    coam.teardown    connection=GNB_OAM    AND
# # #    ...    Run Keyword And Ignore Error    TL UE detach    AND
# # #    ...    Run Keyword And Ignore Error    Unlocked LTE cell
# # #
# # #
# # #*** Keywords ***
# # #Check interHO sucessful with VoNR
# # #    [Arguments]    ${logname}
# # #    ${all_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}
# # #    ${RRC_Reconfiguration} =    Catenate
# # #    ...    f1ap.procedureCode == 7 and nr-rrc.c1 == 0
# # #    Log To Console    check handoverpreparation message on RRC Reconfiguration message
# # #    ${RRC_Reconfiguration_status} =    run_keyword_and_return_status
# # #    ...    parser.filter_packets_by_expression    filter_expression=${RRC_Reconfiguration}
# # #    should be equal    ${RRC_Reconfiguration_status}    ${True}
# # #    ${filtered_packets}=    parser.filter_packets_by_expression
# # #    ...    filter_expression=${RRC_Reconfiguration}
# # #    ${rrc_eventId}=    parser.get_field_value_by_xpath    pdml_list=${filtered_packets}
# # #    ...    xpath=.//nr-rrc.eventId
# # #    Should Contain    ${rrc_eventId}    2
# # #    ${UEContextmodificationResponse} =    Catenate
# # #    ...    f1ap.procedureCode == 7
# # #    Log To Console    check reconfigurationwithSync message with target cellid
# # #    ${filtered_packets_1}=    parser.filter_packets_by_expression
# # #    ...    filter_expression=${UEContextmodificationResponse}
# # #    ${rrc_physCellId}=    parser.get_field_value_by_xpath    pdml_list=${filtered_packets_1}
# # #    ...    xpath=.//nr-rrc.physCellId
# # #    run keyword if    '${gnb_instance}'=='${gnb_id[0]}'    Should Contain    ${rrc_physCellId}    378
# # #    ...    ELSE IF    '${gnb_instance}'=='${gnb_id[2]}'    Should Contain    ${rrc_physCellId}    498
# # #    ...    ELSE    Should Contain    ${rrc_physCellId}    322
# # #    Log To Console    check no UE contextrelease unusual
# # #    ${UE_contextreleasereq_filter}=     Catenate    ngap.procedureCode == 42 and ngap.radioNetwork == 0
# # #    ${UE_contextreleasereq_packets}=    parser.filter_packets_by_expression
# # #    ...    filter_expression=${UE_contextreleasereq_filter}
# # #    ${UE_contextreleasereq}=     parser.get_field_value_by_xpath    pdml_list=${UE_contextreleasereq_packets}
# # #    ...                                                xpath=.//ngap.radioNetwork
# # #    should not contain    ${UE_contextreleasereq}    0
# # #
# # #Check point with A1 and A3 event with VoNR specific
# # #    [Arguments]    ${logname}
# # #    ${all_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}
# # #    ${UEContextmodificationResquest} =    Catenate
# # #    ...    f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 7 and nr-rrc.eventId == 2
# # #    Log To Console    check A1/A3 event on UEContextmodificationResquest message
# # #    ${filtered_packets}=    parser.filter_packets_by_expression
# # #    ...    filter_expression=${UEContextmodificationResquest}
# # #    ${rrc_timeToTrigger}=    parser.get_field_value_by_xpath    pdml_list=${filtered_packets}
# # #    ...    xpath=.//nr-rrc.timeToTrigger
# # #    Should Contain    ${rrc_timeToTrigger}    9
# # #    ${rrc_eventId}=    parser.get_field_value_by_xpath    pdml_list=${filtered_packets}
# # #    ...    xpath=.//nr-rrc.eventId
# # #    Should Contain    ${rrc_eventId}    0

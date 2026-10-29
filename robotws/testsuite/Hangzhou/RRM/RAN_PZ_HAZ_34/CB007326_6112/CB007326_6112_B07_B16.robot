# #*** Settings ***
# #Force Tags    PY36
# #Documentation     author: bella chen
# #...                 contact: bella.chen@nokia-sbell.com
# #...                 squad group: SG_03
# #...                 feature : CB007327_6112
# #
# #Resource     Resources/CB007326_6112_common_keywords.robot
# #Variables    ./Resources/variables_7326.py
# #
# #Suite Setup    Run Keywords
# #...            robot_common_operations.Common Suite Setup    AND
# #...            Run Keyword And Ignore Error       Common Suite Setup for COAM    AND
# #...            Set automatic rotation on UEs    AND
# #...            Update the swconfig file     localFilePath=${localFilePath_swconfig_6112}      AND
# #...            Setup for SA Env cell on-air on gnb2
# #
# #
# #Suite Teardown    Run Keywords
# #...            robot_common_operations.Common Suite Teardown    AND
# #...            Run Keyword And Ignore Error    Common Suite Teardown for COAM
# #
# #*** Variables ***
# #${SCF_path}    /opt/workspace/CRT/Master/SCF_file/
# #${SCF_file_name_2}    7326_784_SCF.xml
# #${epc_log_path}       /tmp/
# #${localFilePath_swconfig_6112}    /opt/workspace/CRT/Master/SCF_file/swconfig.txt
# #${interface1}    any
# #${nglogname1}    6112_B07_attach.pcap
# #${nglogname2}    6612_B07_VONR.pcap
# #${nglogname3}    6112_B07_intraHO.pcap
# #${nglogname4}    6112_B16_attch_and_VONR.pcap
# #${nglogname5}    6112_B16_VONR.pcap
# #
# #@{gnb_filter2}      f1ap.procedureCode == 7 and nr-rrc.milliSeconds == 8
# #             ...    f1ap.procedureCode == 7 and nr-rrc.drx_InactivityTimer == 9
# #             ...    f1ap.procedureCode == 7 and f1ap.longDRXCycleLength == 3
# #@{value2}     8    9    3
# #
# #@{gnb_filter3}      f1ap.procedureCode == 7 and nr-rrc.milliSeconds == 7
# #             ...    f1ap.procedureCode == 7 and nr-rrc.drx_InactivityTimer == 8
# #             ...    f1ap.procedureCode == 7 and f1ap.longDRXCycleLength == 1
# #@{value3}     7    8    1
# #
# #@{gnb_filter4}      e1ap.procedureCode == 8 and e1ap.transportLayerAddressIPv6 and e1ap.E1AP_PDU == 1 and e1ap.transportLayerAddressIPv4
# #             ...    e1ap.procedureCode == 9 and e1ap.transportLayerAddressIPv6 and e1ap.E1AP_PDU == 1 and e1ap.transportLayerAddressIPv4
# #${gnb_filter5}      e1ap.procedureCode == 9 and e1ap.transportLayerAddressIPv6 and !(e1ap.transportLayerAddressIPv4)
# #${value1}    0
# #${gnb_filter6}    ngap.procedureCode == 14
# #
# #${att_good}    ${0}
# #${att_bad}    ${127}
# #${att_HO}     ${10}
# #${att_good_376}    ${6}
# #${att_HO_388}    ${20}
# #@{value_5QI}    1    0
# #@{value2_IMS}    0    1
# #@{value_attach}    ${value_5QI}    ${value2_IMS}
# #
# #*** Test Cases ***
# #[1]CB007326_5G_A_CB006112-B_16_Prioritization_of_5QI-1_and_5QI-5_traffic
# #    [Documentation]    The user scenario introduces function of Prioritization of 5QI-1 and 5QI-5 bearer traffic
# #    ...     by allocating 5QI-1 and 5QI-5 DRBs in separate bearer group.
# #    [Tags]            classical    CIT_TRUNK
# #    [Setup]    robot_common_operations.Common Case Setup
# #    Adjust gNB_RU Attenuation
# #    Locked LTE cell
# #    Set Suite Variable    ${ue_type}    xiaomi
# #    Check UE device exist
# #    Prepare env with UE
# #    Get all xiaomi11 pointer variable tl377
# ###  1.1 UE1 attach to gnb，check bearer groupID Config
# #    Start Capture Wireshark Logs on gNB2    nglogname=${nglogname4}    interface=${interface1}
# #    #Power UE Attach and Verify attach
# #    Check phone attach successfully    4g_check=False
# ###  1.2 UE1 make a VoNR，check VoNR bearer groupID Config
# #    sleep    150s
# #    Start a VONR call
# #    Stop Capture Wireshark Logs on gNB2   nglogname=${nglogname4}
# #    sleep    5s
# #    hang up VoNR call
# #    sleep    5s
# #    Check IE wireshark log for UE1 attach bearer groupID    logname=${nglogname4}    message_filter1=@{gnb_filter4}[0]
# #    ...    message_filter2=@{gnb_filter4}[1]    message_filter3=${gnb_filter5}
# #    [Teardown]     Run Keywords
# #    ...    robot_common_operations.Common Case Teardown    AND
# #    ...    Run Keyword And Ignore Error    TL UE detach    AND
# #    ...    Check hanging resource for gnb    gnb_ips=${gnb_ips}    AND
# #    ...    Run Keyword And Ignore Error    coam.teardown    connection=GNB_OAM    AND
# #    ...    Run Keyword And Ignore Error    Unlocked LTE cell
# 
# 
# #[1]CB007326_5G_A_CB006112-B_07_Successful_INTRA_gNB_HO_setup_TDD_of_VoNR_call_with_enable_different_VoNR_DRX_profile
# #    [Documentation]    Test case description the gNB behaviour for inter gnb HO with DRX configuration
# #    [Tags]            classical    CRT_TRUNK    CRT_22R2
# #    [Setup]    Adjust gNB_RU Attenuation
# #    Modify the COAM parameter with admin API    parameters=${parameter_CB006112_B_07}
# #    Run Keyword If    '${gnb_instance}'=='${gnb_id[0]}'    Locked LTE cell
# #    ...    ELSE    Locked LTE cell tl388
# #    Set Suite Variable    ${ue_type}    xiaomi
# #    Check UE device exist
# #    Prepare env with UE
# #    Run Keyword If    '${gnb_instance}'=='${gnb_id[0]}'    Get all xiaomi11 pointer variable
# #    ...    ELSE IF    '${gnb_instance}'=='${gnb_id[2]}'    Get all xiaomi11 pointer variable tl388
# #    ...    ELSE    Get all xiaomi11 pointer variable tl377
# ###  1.1 UE1 attach to gnb
# #    Start Capture Wireshark Logs on gNB2    nglogname=${nglogname1}    interface=${interface1}
# #    Power UE Attach and Verify attach
# #    Stop Capture Wireshark Logs on gNB2    nglogname=${nglogname1}
# ###  1.2 UE1 make a VoNR
# #    Start Capture Wireshark Logs on gNB2    nglogname=${nglogname2}    interface=${interface1}
# #    Start a VONR call
# #    Stop Capture Wireshark Logs on gNB2   nglogname=${nglogname2}
# #
# ##    triger Intragnb HO
# #    Start Capture Wireshark Logs on gNB2    nglogname=${nglogname3}    interface=${interface1}
# #    Run Keyword If    '${gnb_instance}'=='${gnb_id[0]}'
# #    ...    Adjust the tl HBTE attenuation value    tl=${376}    value1=${att_good}    value2=${att_good_376}
# #    ...    ELSE IF    '${gnb_instance}'=='${gnb_id[2]}'
# #    ...    Adjust the tl HBTE attenuation value    tl=${388}    value1=${att_HO}    value2=${att_good}
# #    ...    ELSE    Adjust the tl HBTE attenuation value    tl=${377}    value1=${att_HO}    value2=${att_good}
# #    sleep    5s
# #    Stop Capture Wireshark Logs on gNB2   nglogname=${nglogname3}
# #    sleep    5s
# #    hang up VoNR call
# #    sleep    5s
# #    Check IE wireshark log for VONR CDRX config    logname=${nglogname2}    message_filter1=@{gnb_filter2}[0]    message_filter2=@{gnb_filter2}[1]
# #    ...    message_filter3=@{gnb_filter2}[2]    value1=@{value2}[0]    value2=@{value2}[1]    value3=@{value2}[2]
# #    Check IE wireshark log for VONR CDRX config    logname=${nglogname3}    message_filter1=@{gnb_filter3}[0]    message_filter2=@{gnb_filter3}[1]
# #    ...    message_filter3=@{gnb_filter3}[2]    value1=@{value3}[0]    value2=@{value3}[1]    value3=@{value3}[2]
# #    [Teardown]     Run Keywords
# #    ...    Run Keyword And Ignore Error    TL UE detach    AND
# #    ...    Run Keyword And Ignore Error    coam.teardown    connection=GNB_OAM    AND
# #    ...    Run Keyword And Ignore Error    Unlocked LTE cell
# 
# #*** Keywords ***
# #Check IE wireshark log for VONR CDRX config
# #    [Arguments]    ${logname}    ${message_filter1}    ${message_filter2}    ${message_filter3}    ${value1}    ${value2}    ${value3}
# #    Check IE wireshark log for drx_onDurationTimer     logname=${logname}    message_filter=${message_filter1}     value=${value1}
# #    Check IE wireshark log for drx_InactivityTimer     logname=${logname}    message_filter=${message_filter2}     value=${value2}
# #    Check IE wireshark log for longDRXCycleLength      logname=${logname}    message_filter=${message_filter3}     value=${value3}
# #
# #Check IE wireshark log for drx_onDurationTimer
# #    [Arguments]    ${logname}    ${message_filter}    ${value}
# #    ${all_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}${logname}
# #    ${filter_expression}=     Catenate    ${message_filter}
# #    ${filtered_packets}=    parser.filter_packets_by_expression    filter_expression=${filter_expression}
# #    ${drx_onDurationTimer}=     parser.get_field_value_by_xpath    pdml_list=${filtered_packets}
# #    ...                                                xpath=.//nr-rrc.milliSeconds
# #    should be equal    ${drx_onDurationTimer[0]}    ${value}
# #
# #Check IE wireshark log for drx_InactivityTimer
# #    [Arguments]    ${logname}    ${message_filter}    ${value}
# #    ${all_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}${logname}
# #    ${filter_expression}=     Catenate    ${message_filter}
# #    ${filtered_packets}=    parser.filter_packets_by_expression    filter_expression=${filter_expression}
# #    ${drx_InactivityTimer}=     parser.get_field_value_by_xpath    pdml_list=${filtered_packets}
# #    ...                                                xpath=.//nr-rrc.drx_InactivityTimer
# #    should be equal    ${drx_InactivityTimer[0]}    ${value}
# #
# #Check IE wireshark log for longDRXCycleLength
# #    [Arguments]    ${logname}    ${message_filter}    ${value}
# #    ${all_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}${logname}
# #    ${filter_expression}=     Catenate    ${message_filter}
# #    ${filtered_packets}=    parser.filter_packets_by_expression    filter_expression=${filter_expression}
# #    ${f1ap_longDRXCycleLength}=     parser.get_field_value_by_xpath    pdml_list=${filtered_packets}
# #    ...                                                xpath=.//f1ap.longDRXCycleLength
# #    should be equal    ${f1ap_longDRXCycleLength[0]}    ${value}
# #
# #Check IE wireshark log for UE1 attach bearer groupID
# #    [Arguments]    ${logname}    ${message_filter1}    ${message_filter2}   ${message_filter3}
# #    ${time1} =    Get UE1 attach message value    logname=${logname}    message_filter=${message_filter1}
# #    ${time2} =    Get UE1 attach message value    logname=${logname}    message_filter=${message_filter2}
# #     ${time3} =    Get UE1 attach message value    logname=${logname}    message_filter=${message_filter3}
# #    Should Not Be Equal   ${time1}  ${time2}
# #    List Should Contain Sub List    @{value_attach}    ${time1}
# #    List Should Contain Sub List    @{value_attach}    ${time2}
# #    Should be equal    ${time3[0]}    0
# #
# #Get UE1 attach message value
# #    [Arguments]    ${logname}    ${message_filter}
# #    ${all_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}/${logname}
# #    ${filter_expression}=     Catenate    ${message_filter}
# #    ${filtered_packets}=    parser.filter_packets_by_expression    filter_expression=${filter_expression}
# #    ${e1ap_transportLayerAddress}=     parser.get_field_value_by_xpath    pdml_list=${filtered_packets}
# #    ...                                                xpath=.//e1ap.transportLayerAddress
# #    ${length}    Get Length    ${e1ap_transportLayerAddress}
# #    @{IPV6}    Create List
# #    FOR    ${index}    IN RANGE    ${length}
# #       Run keyword If    ${index}%2==1
# #       ...    Append to List    ${IPV6}    ${e1ap_transportLayerAddress[${index}][1]}
# #    END
# #    [Return]    ${IPV6}
# #
# #Check IE wireshark log for VONR 5QI1_bearer groupID
# #    [Arguments]    ${logname}    ${message_filter}    ${value}
# #    ${time1} =    Get UE1 UE2 VONR message value    logname=${logname}    message_filter=${message_filter}
# #    Should Be Equal As Strings    ${time1}  ${value}
# #
# #Get UE1 UE2 VONR message value
# #    [Arguments]    ${logname}    ${message_filter}
# #    ${all_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}/${logname}
# #    ${filter_expression}=     Catenate    ${message_filter}
# #    ${filtered_packets}=    parser.filter_packets_by_expression    filter_expression=${filter_expression}
# #    ${e1ap_transportLayerAddressIPv6}=     parser.get_field_value_by_xpath    pdml_list=${filtered_packets}
# #    ...                                                xpath=.//e1ap.transportLayerAddress
# #    ${string}    Convert To String    ${e1ap_transportLayerAddressIPv6}[-1]
# #    ${list_0} =    Evaluate    ${string[1]}
# #    [Return]    ${list_0}
# #
# #Get UE1 5QI message value
# #    [Arguments]    ${logname}    ${message_filter}
# #    ${all_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}/${logname}
# #    ${filter_expression}=     Catenate    ${message_filter}
# #    ${filtered_packets}=    parser.filter_packets_by_expression    filter_expression=${filter_expression}
# #    ${ngap_fiveOI}=     parser.get_field_value_by_xpath    pdml_list=${filtered_packets}
# #    ...                                                xpath=.//ngap.fiveQI
# #    ${string}    Convert To String    ${ngap_fiveOI}[0]
# #    [Return]    ${string}
# #
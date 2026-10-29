*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO, VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE
...             RAN_5G_FDD    RAN_5G    5G_RAN_FDD    5G_RAN     SBTS00   CONFIGURED

Documentation
...
...             author       : megha.dm@nokia.com
...             maintainer   : megha.dm@nokia.com
...             Test Set Name: CB010686 Multi UE Session and UE-Context Setup Resource Release due to detected GTP error
...             Testing Split: A#B1
...             Contacts     : I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>

Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Library          Collections
Library           ta5g_enb


Resource         ./CB010686_resource.robot


Suite Setup         Run keywords    Run Keyword and Ignore Error      Suite setup from scratch
...                 AND     Update bsr package
...                 AND     sleep    60
...                 AND     Perform SCF Delta Commissioning with A_B1.json
...                 AND     sleep    60
...                 AND     gnb.Perform gNB reboot
...                 AND     sleep    60
...                 AND     OperatingSystem.Run    sudo ip addr add 10.0.1.101/24 dev eth3
...                 AND     sleep    6
...                 AND     OperatingSystem.Run    sudo ip addr add 10.0.1.102/24 dev eth3
...                 AND     sleep    6
...                 AND     Load CFG and verify cell status   ${wts_cfg_file}   1   1


Suite Teardown      Run Keywords
...                 Log To console  Suiteteardown
...                 AND     Run Keyword and Ignore Error     Stop Log      btslog     cprt


#Test Setup       Start_capture_testcase_default_logging
Test Teardown    Run Keywords       Log To console   Teardown_started
...                 AND     Dump RMOD BBMOD And Cell Status
...                 AND     Stop Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}

*** Variables ***
${NG_FLOW_REL_AMF_OTHER_5QI1}       M55125C09513
${NNGCC_PDU_SES_NOTIFY_REL_SENT}        M55125C05515
${NG_FLOW_REL_AMF_OTHER}       M55125C09020
${wts_cfg_file}    ${CURDIR}/config/wts/basic_setup_b1.cfg
${wts_cfg_file1}    ${CURDIR}/config/wts/config.cfg
${WTS_DIR}          /opt/iphy/latest
${start_ue_id}        1
${end_ue_id}        1
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${QFI_ID}    1
${TRF_ID}    1
${TRF_ID2}    2
${epc_log_path}    /tmp/
${TEST_NAME}            Cell_setup
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${nw_id}    1
${ue_id}    1
${EXPECTED_IP}    fc00:8a00:a000:117c::a44:7e7b
${EXPECTED_IP1}    10.0.1.101
${EXPECTED_IP2}    10.0.1.4
${EXPECTED_gNBID_PLMN1}      Xn-C (MCC,MNC,GnbId): (311,489,4);
${EXPECTED_gNBID_PLMN2}      Xn-C (MCC,MNC,GnbId): (311,489,4)
${EXPECTED_gNBID_PLMN3}      Xn-C (MCC,MNC,GnbId): (311,489,3);

*** Test Cases ***
[1.0] CB010686 Multi UE Session and UE-Context Setup Resource Release due to detected GTP error
     Wait until the next Measurement Period starts
     ${crnti}    MultiUE Register should be Successful     ${1}    ${1}
     ADD Multi PDU Session      2     3
     Multi PDU Traffic    1     3     70     150
     sleep  5s
     ${crnti}    MultiUE Register should be Successful     ${2}    ${2}
     sleep   5s
     Inject PDU Error   ${1}    ${1}    2
     sleep   1s
     Inject PDU Error   ${2}    ${2}    1
     sleep   1s
     Verify Specific PDU Traffic   1   1
     Verify Specific PDU Traffic   1   3
     UE state should be active   ${1}    ${2}

     ${crnti}    MultiUE Register should be Successful     ${3}    ${3}
     Set Global Variable  ${start_ue_id}  3
     Set Global Variable  ${endue_id}  3
     ADD Multi PDU Session      2     2
     Multi PDU Traffic    1     2     20     50
     sleep  2s
     Inject PDU Error   ${3}    ${3}    1
     Modify PDU Session     ${3}    2
     sleep  1s
     ${status}       Run keyword and Return Status   Modify PDU Session     ${3}    1
     Should Be Equal As Strings          ${status}                False
     MultiUE Deregister should be Successful   ${1}    ${3}

    ${crnti}    MultiUE Register should be Successful     ${4}    ${4}
     Set Global Variable  ${start_ue_id}  4
     Set Global Variable  ${endue_id}  4
     sleep  2s
     Modify PDU Session     ${4}    1
     sleep  1s
     PDU Release by AMF     ${4}    1
     sleep   2s
     Verify counter PDU release by AMF    0
     MultiUE Deregister should be Successful   ${4}    ${4}

    [Teardown]    Link SCOUT SCF to Configuration ID for Reporting

[1.0] CB010686 PDU Session detected GTP Error for all the PDU session
     Start Log      btslog     cprt
     Set Global Variable  ${start_ue_id}  1
     Set Global Variable  ${endue_id}  1

     ${crnti}    MultiUE Register should be Successful     ${1}    ${1}
     sleep   5s
     ADD Multi PDU Session      2    15
     sleep   5s
     Multi PDU Traffic    1     15     2     5
     Inject Multiple PDU Error      1    15
     sleep   5s
     Verify counters    0  0
     UE state should be active   ${1}    ${1}
     MultiUE Deregister should be Successful   ${1}    ${1}
     ${scen1}     Stop Log      btslog     cprt
     Validate error msg in syslog   file=${scen1}[btslog]/gnb_syslog.log
    [Teardown]    Link SCOUT SCF to Configuration ID for Reporting

[1]CB013992-A_EC3_TC2_SCTP_association_failure_detected_on_Xn-C_interface_fault_7306
     [Documentation]   This test case checks alarms 7306, 7307, and 7311 and verifies the alarm destination IP and supplementary information
    Perform SCF Delta Commissioning with CB013992_intergNB.json
    sleep    10
    gnb.Perform gNB reboot
    sleep    60
    OperatingSystem.Run    sudo ip -6 addr add fc00:8a00:a000:117c::a44:7e7b/122 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.101/24 dev eth3
    OperatingSystem.Run    sudo ip addr add 10.0.1.102/24 dev eth3
    sleep    6
    Load CFG and verify cell status   ${wts_cfg_file1}   1   1
    sleep   300
    CB010686_resource.Establish Xn Link To gNB${3}
    sleep   5
    CB010686_resource.Establish Xn Link To gNB${4}

    FOR    ${i}    IN RANGE    1    5
    Drop Xn Link    4
   ${alarm_output}    Check If Alarm Appeared    7306   7311
    ${matched_fault1}=    Get From List    ${alarm_output}    1
    ${actual_ip}=    Get From Dictionary    ${matched_fault1}    destinationIP
    Should Be Equal As Strings    ${actual_ip}    ${EXPECTED_IP}

    ${supp_info}=    Get From Dictionary    ${alarm_output[1]}    supplementaryInfo

    ${match_found}=    Evaluate
    ...    """${EXPECTED_gNBID_PLMN1}""" in """${supp_info}""" or """${EXPECTED_gNBID_PLMN2}""" in """${supp_info}"""

    Should Be True    ${match_found}    gNBId pattern not found in alarm output

    Sleep    15s
    CB010686_resource.Establish Xn Link To gNB${4}
    END

    FOR    ${i}    IN RANGE    1   5
    Perform SCF Delta Commissioning with AdminitrativeState.json
    ${output}=     Run    sshpass -p oZPS0POrRieRtu ssh -q toor4nsn@192.168.255.129 ip6tables -A INPUT -p sctp --dport 38422 -j DROP
    Perform SCF Delta Commissioning with AdminitrativeState_Unlock.json
    sleep   300
    ${alarm_output1}    Check If Alarm Appeared      7307   7311
    ${matched_fault1}=    Get From List    ${alarm_output1}    1
    ${actual_ip}=    Get From Dictionary    ${matched_fault1}    destinationIP
#    Should Be Equal As Strings    ${actual_ip}    ${EXPECTED_IP}    or      ${EXPECTED_IP1}
    Run Keyword Unless    '${actual_ip}' == '${EXPECTED_IP}' or '${actual_ip}' == '${EXPECTED_IP1}' or '${actual_ip}' == '${EXPECTED_IP2}'
    ...    Fail    Actual IP (${actual_ip}) does not match expected values: ${EXPECTED_IP} or ${EXPECTED_IP1} or ${EXPECTED_IP2}
    ${supp_info}=    Get From Dictionary    ${alarm_output1[1]}    supplementaryInfo
#    ${match_found}=    Evaluate
#    ...    """${EXPECTED_gNBID_PLMN1}""" in """${supp_info}""" or """${EXPECTED_gNBID_PLMN2}""" in """${supp_info}""" or
#    ...    """${EXPECTED_gNBID_PLMN3}""" in """${supp_info}"""
    ${match_found}=    Evaluate
    ...    "${EXPECTED_gNBID_PLMN1}" in "${supp_info}" or "${EXPECTED_gNBID_PLMN2}" in "${supp_info}" or "${EXPECTED_gNBID_PLMN3}" in "${supp_info}"
   Should Be True    ${match_found}    gNBId pattern not found in alarm output
    Sleep    15s

    ${output}=     Run    sshpass -p oZPS0POrRieRtu ssh -q toor4nsn@192.168.255.129 ip6tables -I INPUT -p sctp --dport 38422 -j ACCEPT
    sleep   2
    CB010686_resource.Establish Xn Link To gNB${4}
    END

    FOR    ${i}    IN RANGE    1    5
#    Perform SCF Delta Commissioning with AdminitrativeState.json
    sleep   2
    ${output}=     Run
    ...   sshpass -p oZPS0POrRieRtu ssh -q toor4nsn@192.168.255.129 ip -6 route add fc00:8a00:a000:117c::a44:7e7b via fc00:8a00:a000:117c::a44:7e7c
#    sleep   2
#    Perform SCF Delta Commissioning with AdminitrativeState_Unlock.json
    sleep   30
    ${alarm_output2}    Check If Alarm Appeared      7311   7307
    ${matched_fault1}=    Get From List    ${alarm_output2}    1
    ${actual_ip}=    Get From Dictionary    ${matched_fault1}    destinationIP
#    Should Be Equal As Strings    ${actual_ip}    ${EXPECTED_IP1}
     Run Keyword Unless    '${actual_ip}' == '${EXPECTED_IP}' or '${actual_ip}' == '${EXPECTED_IP1}' or '${actual_ip}' == '${EXPECTED_IP2}'
     ...    Fail    Actual IP (${actual_ip}) does not match expected values: ${EXPECTED_IP} or ${EXPECTED_IP1} or '${EXPECTED_IP2}
    ${supp_info}=    Get From Dictionary    ${alarm_output2[1]}    supplementaryInfo
    ${match_found}=    Evaluate
    ...    """${EXPECTED_gNBID_PLMN2}""" in """${supp_info}""" or """${EXPECTED_gNBID_PLMN3}""" in """${supp_info}"""
    Should Be True    ${match_found}    gNBId pattern not found in alarm output
    Sleep    15s
    ${output}=     Run    sshpass -p oZPS0POrRieRtu ssh -q toor4nsn@192.168.255.129 ip -6 route del fc00:8a00:a000:117c::a44:7e7b
    END
    [Teardown]    Link SCOUT SCF to Configuration ID for Reporting

*** keywords ***

PDU Release by AMF
    [Arguments]    ${ue_id}  ${pdu_id}
    Execute Egate Command   cmd=ue_pdu_session_release ue=${ue_id} pdu=${pdu_id} by=amf


Verify counter PDU release by AMF
    [Arguments]     ${expected_output3}
    Wait until the next Measurement Period starts
    ${PM_dir_1}=     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
    Run Keyword And Continue on Failure     Validate PM Counters as per expected value    PM_dir=${PM_dir_1}
    ...    PM_counter=${NG_FLOW_REL_AMF_OTHER_5QI1}     expected_value=${expected_output3}    moc=MRBTS-1/NRBTS-1/NRCELL-1

Validate PM Counters as per expected value
    [Arguments]    ${PM_dir}     ${PM_counter}    ${expected_value}    ${moc}
    PM_Counters.Check PM counter value equal    expected_value=${expected_value}   pm_files_location=${PM_dir}
    ...  pi_id=${PM_counter}    moc=${moc}


Modify PDU Session
    [Arguments]    ${ue_id}  ${pdu_id}
    ${command}    Set Variable    ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_add=2 by=amf
    ${output_0}    Execute Egate Command And Wait For Data
    ...    ${command}
    ...    pass_regexp=UE${ue_id}: Ue ${ue_id} PduId ${pdu_id} Created FiveQi:Qfi mapping fiveQi 5
    ...    timeout=80
    sleep   3s
    ${command}    Set Variable    ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_add=3 by=amf
    ${output_1}    Execute Egate Command And Wait For Data
    ...    ${command}
    ...    pass_regexp=UE${ue_id}: Ue ${ue_id} PduId ${pdu_id} Created FiveQi:Qfi mapping fiveQi 1
    ...    timeout=80

Verify counters
    [Arguments]     ${expected_output1}     ${expected_output2}
    Wait until the next Measurement Period starts
    ${PM_dir_1}=     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
    Run Keyword And Continue on Failure     Validate PM Counters is non zero    PM_dir=${PM_dir_1}
    ...    PM_counter=${NNGCC_PDU_SES_NOTIFY_REL_SENT}     expected_value=${expected_output1}    moc=MRBTS-1/NRBTS-1/NRCELL-1
    Run Keyword And Continue on Failure     Validate PM Counters is Zero    PM_dir=${PM_dir_1}
    ...    PM_counter=${NG_FLOW_REL_AMF_OTHER}    expected_value=${expected_output2}    moc=MRBTS-1/NRBTS-1/NRCELL-1

Validate PM Counters is Zero
    [Arguments]    ${PM_dir}     ${PM_counter}    ${expected_value}    ${moc}
    PM_Counters.Check PM counter value equal    expected_value=${expected_value}   pm_files_location=${PM_dir}
    ...  pi_id=${PM_counter}    moc=${moc}

Validate PM Counters is non zero
    [Arguments]    ${PM_dir}     ${PM_counter}    ${expected_value}    ${moc}
    PM_Counters.Check PM counter value bigger than      expected_value=${expected_value}   pm_files_location=${PM_dir}
    ...  pi_id=${PM_counter}    moc=${moc}


Check If Alarm Appeared
    [Documentation]    This keyword checks if at least one of the specified fault IDs appeared and fetches additional information.
    [Arguments]    ${fault_id1}    ${fault_id2}

    COAM.Setup Admin    timeout=120    bts_host=192.168.255.129
    @{alarm_history}=    COAM.Get Active Alarms

    ${found_fault}=    Set Variable    ${False}
    ${matched_fault_info}=    Create Dictionary

    FOR    ${alarm}    IN    @{alarm_history}
        ${alarm_fault_id}=    Get From Dictionary    ${alarm}    faultId

        IF    '${alarm_fault_id}' == '${fault_id1}' or '${alarm_fault_id}' == '${fault_id2}'
            Set Variable    ${found_fault}    ${True}
            Set To Dictionary    ${matched_fault_info}
            ...    faultId=${alarm_fault_id}
            ...    destinationIP=${alarm['destinationIPAddr']}
            ...    supplementaryInfo=${alarm['supplAlarmInfo']}
            Log To Console    Found Fault ID: ${alarm_fault_id}, Destination IP: ${alarm['destinationIPAddr']}, Supl Info: ${alarm['supplAlarmInfo']}
            Exit For Loop
        END
    END

    Run Keyword Unless    ${found_fault}    Log To Console    Neither Fault ID ${fault_id1} nor ${fault_id2} found in alarm history.

    Run Keyword If    ${found_fault}    Should Not Be Empty    ${matched_fault_info['destinationIP']}
    Run Keyword If    ${found_fault}    Should Not Be Empty    ${matched_fault_info['supplementaryInfo']}

    ${alarm_output}=    Create List    ${found_fault}    ${matched_fault_info}
    [Return]    ${alarm_output}

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
${NNGCC_PDU_SES_NOTIFY_REL_SENT}        M55125C05515
${NG_FLOW_REL_AMF_OTHER}       M55125C09020
${wts_cfg_file}    ${CURDIR}/config/wts/basic_setup_b1.cfg
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


*** Test Cases ***
[1.0] CB010686 Multi UE Session and UE-Context Setup Resource Release due to detected GTP error
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


*** keywords ***

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
    ...    PM_counter=${NNGCC_PDU_SES_NOTIFY_REL_SENT}     expected_value=${expected_output1}    moc=NRCELL-1
    Run Keyword And Continue on Failure     Validate PM Counters is Zero    PM_dir=${PM_dir_1}
    ...    PM_counter=${NG_FLOW_REL_AMF_OTHER}    expected_value=${expected_output2}    moc=NRCELL-1

Validate PM Counters is Zero
    [Arguments]    ${PM_dir}     ${PM_counter}    ${expected_value}    ${moc}
    PM_Counters.Check PM counter value equal    expected_value=${expected_value}   pm_files_location=${PM_dir}
    ...  pi_id=${PM_counter}    moc=${moc}

Validate PM Counters is non zero
    [Arguments]    ${PM_dir}     ${PM_counter}    ${expected_value}    ${moc}
    PM_Counters.Check PM counter value bigger than      expected_value=${expected_value}   pm_files_location=${PM_dir}
    ...  pi_id=${PM_counter}    moc=${moc}


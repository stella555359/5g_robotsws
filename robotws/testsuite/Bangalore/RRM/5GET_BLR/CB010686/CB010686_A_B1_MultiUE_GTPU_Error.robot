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
...                 AND     Load CFG and verify cell status   ${wts_cfg_file}   1   1


Suite Teardown      Run Keywords
...                 Log To console  Suiteteardown
...                 AND     Run Keyword and Ignore Error     Stop Log      btslog     cprt


Test Setup       Start_capture_testcase_default_logging
Test Teardown    Run Keywords       Log To console   Teardown_started
...                 AND     Dump RMOD BBMOD And Cell Status
...                 AND     Stop Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}

*** Variables ***

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
     MultiUE Deregister should be Successful   ${3}    ${3}

    [Teardown]    Link SCOUT SCF to Configuration ID for Reporting



*** keywords ***

Modify PDU Session
    [Arguments]    ${ue_id}  ${pdu_id}
    ${command}    Set Variable    ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_add=2 by=amf
    ${output_0}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    ${command}
    ...    pass_regexp=UE${ue_id}: Ue ${ue_id} PduId ${pdu_id} Created FiveQi:Qfi mapping fiveQi 5
    ...    timeout=80
    sleep   3s
    ${command}    Set Variable    ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_add=3 by=amf
    ${output_1}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    ${command}
    ...    pass_regexp=UE${ue_id}: Ue ${ue_id} PduId ${pdu_id} Created FiveQi:Qfi mapping fiveQi 1
    ...    timeout=80


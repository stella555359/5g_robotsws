*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO, VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE
...             RAN_5G_FDD    RAN_5G    5G_RAN_FDD    5G_RAN     SBTS00   CONFIGURED

Documentation
...
...             author       : megha.dm@nokia.com
...             maintainer   : megha.dm@nokia.com
...             Test Set Name: CB010686 PDU Session detected GTP Error for all the PDU session
...             Testing Split: A#B4
...             Contacts     : I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             Requirement ID  : 5G_RAN_USR_RRM_26338
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
...                 AND     Run Keyword and Ignore Error    Get Snapshot

*** Variables ***
${wts_cfg_file}      ${CURDIR}/config/wts/basic_setup_15bearer.cfg
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
${NNGCC_PDU_SES_NOTIFY_REL_SENT}        M55125C05515
${NG_FLOW_REL_AMF_OTHER}       M55125C09020
*** Test Cases ***
[1.0] CB010686 PDU Session detected GTP Error for all the PDU session
     Start Log      btslog     cprt
     ${crnti}    MultiUE Register should be Successful     ${1}    ${1}
     sleep   5s
     ADD Multi PDU Session      2    15
     sleep   5s
     Multi PDU Traffic    1     15     2     5
     Inject Multiple PDU Error      1    15
#     sleep   5s
     Verify counters    15  0
     UE state should be active   ${1}    ${1}
     MultiUE Deregister should be Successful   ${1}    ${1}
     ${scen1}     Stop Log      btslog     cprt
     Validate error msg in syslog   file=${scen1}[btslog]/gnb_syslog.log
    [Teardown]    Link SCOUT SCF to Configuration ID for Reporting


*** Keywords ***

Verify counters
    [Arguments]     ${expected_output1}     ${expected_output2}
    Wait until the next Measurement Period starts
    ${PM_dir_1}=     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
    Run Keyword And Continue on Failure     Validate PM Counters as per expected value    PM_dir=${PM_dir_1}
    ...    PM_counter=${NNGCC_PDU_SES_NOTIFY_REL_SENT}     expected_value=${expected_output1}    moc=NRCELL-1
    Run Keyword And Continue on Failure     Validate PM Counters is Zero    PM_dir=${PM_dir_1}
    ...    PM_counter=${NG_FLOW_REL_AMF_OTHER}    expected_value=${expected_output2}    moc=NRCELL-1

Validate PM Counters as per expected value
    [Arguments]    ${PM_dir}     ${PM_counter}    ${expected_value}    ${moc}
    PM_Counters.Check PM counter value equal    expected_value=${expected_value}   pm_files_location=${PM_dir}
    ...  pi_id=${PM_counter}    moc=${moc}


Validate PM Counters is Zero
    [Arguments]    ${PM_dir}     ${PM_counter}    ${expected_value}    ${moc}
    PM_Counters.Check PM counter value equal    expected_value=${expected_value}   pm_files_location=${PM_dir}
    ...  pi_id=${PM_counter}    moc=${moc}


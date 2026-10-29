*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO, VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE
...             CRT    RAN_5G_FDD    RAN_5G    5G_RAN_FDD    5G_RAN     SBTS00    CONFIGURED

Documentation
...
...             author:            Ishan
...             maintainer:        ishan.sharma@nokia.com
...
...             INTRODUCTION:     Perform SA data call on 40MHZ FDD with 40 30 20 BWP PRofiles
...             TEST SET NAME:    CB008954_H_IWK.3_2_GBR_admision_control_for_second_dedicated_BWP_FDD
...             TESTING SPLIT:    Refer CB008954 Test Plan
...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:       CB008954 CFAM
...             RequirementID: 5G_RAN_USR_RRM_21488

Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Library          Collections
Library           ta5g_enb


Resource         ./CB008954_resource.robot

#Suite Setup         Run keywords
#...                 Log To console  SuiteSetup
#...                 AND     Prepare TL with all config files
#...                 AND    Run Keyword and Ignore Error      Suite setup from scratch

Suite Setup         Run keywords    Run Keyword and Ignore Error      Suite setup from scratch
...                 AND     Modify IPHY File And Send to Airphone Custom     ${IPHY_FILE}
...                 AND     ssh_cmd.Gnb Ap Reboot
...                 AND     sleep   600s
...                 AND     Perform SCF Delta Commissioning with ASOH_H_3_2_GBR_10_30_40_FDD.json
...                 AND     sleep   180s
...                 AND     gnb.Perform gNB reboot
...                 AND    Sleep   250s    reason=wait for RMOD to comeup
...                 AND    Start WTS Using WTS_Runner      ${wts_cfg_file}
...                 AND    sleep  60s   reason=wait for mib sib

Suite Teardown      Run Keywords
...                 Log To console  Suitetardown
...                 AND     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
...                 AND     Run Keyword and Ignore Error    Stop Log     snapshot    sosreport

Test Setup       Start_capture_testcase_default_logging

Test Teardown    Run Keywords       Log To console   Teardown_started
...                 AND     Stop Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}

*** Variables ***
${SCFC}=        ${CURDIR}/config/SBTS24R2/ASOH_H_3_2_GBR_10_30_40_FDD.xml
${wts_cfg_file}     ${CURDIR}/config/wts/ASOH_H_3_2_GBR_10_30_40_FDD.cfg
${AP_XML}    ${CURDIR}/config/wts/ASOH_H_3_2_GBR_iphy.xml
${IPHY_FILE}    ${CURDIR}/config/wts/ASOH_H_3_2_GBR_iphy.xml
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}          /opt/iphy/latest
${UE_ID}        1
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${QFI_ID}    1
${TRF_ID}    1
${TRF_ID2}    2
${largebwp_id}   1
${smallbwp_id}   3
${psbwp_id}     2
${epc_log_path}    /tmp/
${TEST_NAME}            CB008954_H_3_2_GBR_FDD

*** Test Cases ***
[1][1.0] CB008954_H_IWK.3_2_GBR_admision_control_for_second_dedicated_BWP_FDD.
    [Documentation]   This scenario is to verify the cell setup with 3 dedicated BWPS 10,30,40 MHZ

    Log To console  TestCasestarted
    start log     cprt

    MultiUE Register should be Successful     ${1}    ${1}
    UE PDU Modfication should be Successful     ${1}    pdu_id=1    qosflows_to_add=2
    MultiUE Trigger UL Traffic for SA    ${1}  ${1}  Traffic_rate=mbps     ul_rate=1   pdu_id=1   trf_id=1   qfi_id=2
    MultiUE Trigger DL Traffic for SA    ${1}  ${1}  Traffic_rate=mbps     dl_rate=1   pdu_id=1   trf_id=1   qfi_id=2

    UE PDU Modfication should be Successful     ${1}    pdu_id=1    qosflows_to_add=3
    Trigger VoNR DL Traffic for SA    ${1}    pdu_id=1     trf_id=1     qfi_id=3    rtp_codec=custom
    Trigger VoNR UL Traffic for SA    ${1}    pdu_id=1     trf_id=1     qfi_id=3    rtp_codec=custom

    UE PDU Modfication should be Successful     ${1}    pdu_id=1    qosflows_to_add=4
    MultiUE Trigger UL Traffic for SA    ${1}  ${1}  Traffic_rate=mbps     ul_rate=30   pdu_id=1   trf_id=2   qfi_id=4
    MultiUE Trigger DL Traffic for SA    ${1}  ${1}  Traffic_rate=mbps     dl_rate=50   pdu_id=1   trf_id=2   qfi_id=4


    MultiUE Register should be Successful     ${4}    ${4}
    UE PDU Modfication should be Successful     ${4}    pdu_id=1    qosflows_to_add=2
    MultiUE Trigger UL Traffic for SA    ${4}  ${4}  Traffic_rate=mbps     ul_rate=1   pdu_id=1   trf_id=1   qfi_id=2
    MultiUE Trigger DL Traffic for SA    ${4}  ${4}  Traffic_rate=mbps     dl_rate=1   pdu_id=1   trf_id=1   qfi_id=2

    UE PDU Modfication should be Successful     ${4}    pdu_id=1    qosflows_to_add=3
    Trigger VoNR DL Traffic for SA    ${4}    pdu_id=1     trf_id=1     qfi_id=3    rtp_codec=custom
    Trigger VoNR UL Traffic for SA    ${4}    pdu_id=1     trf_id=1     qfi_id=3    rtp_codec=custom

    UE PDU Modfication should be Successful     ${4}    pdu_id=1    qosflows_to_add=4
    MultiUE Trigger UL Traffic for SA    ${4}  ${4}  Traffic_rate=mbps     ul_rate=30   pdu_id=1   trf_id=2   qfi_id=4
    MultiUE Trigger DL Traffic for SA    ${4}  ${4}  Traffic_rate=mbps     dl_rate=50   pdu_id=1   trf_id=2   qfi_id=4


    MultiUE Register should be Successful     ${7}    ${7}
    UE PDU Modfication should be Successful     ${7}    pdu_id=1    qosflows_to_add=2
    MultiUE Trigger UL Traffic for SA    ${7}  ${7}  Traffic_rate=mbps     ul_rate=1   pdu_id=1   trf_id=1   qfi_id=2
    MultiUE Trigger DL Traffic for SA    ${7}  ${7}  Traffic_rate=mbps     dl_rate=1   pdu_id=1   trf_id=1   qfi_id=2

#    UE PDU Modfication should be Successful     ${7}    pdu_id=1    qosflows_to_add=3
#    Trigger VoNR DL Traffic for SA    ${7}    pdu_id=1     trf_id=1     qfi_id=3    rtp_codec=custom
#    Trigger VoNR UL Traffic for SA    ${7}    pdu_id=1     trf_id=1     qfi_id=3    rtp_codec=custom

    UE PDU Modfication should be Successful Gbr Congession     ${7}    pdu_id=1    qosflows_to_add=3

#    UE PDU Modfication should be Successful     ${7}    pdu_id=1    qosflows_to_add=4
#    MultiUE Trigger UL Traffic for SA    ${7}  ${7}  Traffic_rate=mbps     ul_rate=30   pdu_id=1   trf_id=2   qfi_id=4
#    MultiUE Trigger DL Traffic for SA    ${7}  ${7}  Traffic_rate=mbps     dl_rate=50   pdu_id=1   trf_id=2   qfi_id=4


    MultiUE Register should be Successful     ${8}    ${8}
    UE PDU Modfication should be Successful     ${8}    pdu_id=1    qosflows_to_add=2
    MultiUE Trigger UL Traffic for SA    ${8}  ${8}  Traffic_rate=mbps     ul_rate=1   pdu_id=1   trf_id=1   qfi_id=2
    MultiUE Trigger DL Traffic for SA    ${8}  ${8}  Traffic_rate=mbps     dl_rate=1   pdu_id=1   trf_id=1   qfi_id=2

    UE PDU Modfication should be Successful Gbr Congession     ${8}    pdu_id=1    qosflows_to_add=3

#    UE PDU Modfication should be Successful     ${8}    pdu_id=1    qosflows_to_add=3
#    Trigger VoNR DL Traffic for SA    ${8}    pdu_id=1     trf_id=1     qfi_id=3    rtp_codec=custom
#    Trigger VoNR UL Traffic for SA    ${8}    pdu_id=1     trf_id=1     qfi_id=3    rtp_codec=custom
#
#    UE PDU Modfication should be Successful Gbr Congession     ${8}    pdu_id=1    qosflows_to_add=4

    MultiUE Register should be Successful     ${2}    ${2}
    UE PDU Modfication should be Successful     ${2}    pdu_id=1    qosflows_to_add=2
    MultiUE Trigger UL Traffic for SA    ${2}  ${2}  Traffic_rate=mbps     ul_rate=1   pdu_id=1   trf_id=1   qfi_id=2
    MultiUE Trigger DL Traffic for SA    ${2}  ${2}  Traffic_rate=mbps     dl_rate=1   pdu_id=1   trf_id=1   qfi_id=2

    UE PDU Modfication should be Successful Gbr Congession     ${2}    pdu_id=1    qosflows_to_add=3

#    UE PDU Modfication should be Successful     ${2}    pdu_id=1    qosflows_to_add=3
#    Trigger VoNR DL Traffic for SA    ${2}    pdu_id=1     trf_id=1     qfi_id=3    rtp_codec=custom
#    Trigger VoNR UL Traffic for SA    ${2}    pdu_id=1     trf_id=1     qfi_id=3    rtp_codec=custom

#    UE PDU Modfication should be Successful     ${2}    pdu_id=1    qosflows_to_add=4
#    MultiUE Trigger UL Traffic for SA    ${2}  ${2}  Traffic_rate=mbps     ul_rate=30   pdu_id=1   trf_id=2   qfi_id=4
#    MultiUE Trigger DL Traffic for SA    ${2}  ${2}  Traffic_rate=mbps     dl_rate=50   pdu_id=1   trf_id=2   qfi_id=4


    MultiUE Register should be Successful     ${5}    ${5}
    UE PDU Modfication should be Successful     ${5}    pdu_id=1    qosflows_to_add=2
    MultiUE Trigger UL Traffic for SA    ${5}  ${5}  Traffic_rate=mbps     ul_rate=1   pdu_id=1   trf_id=1   qfi_id=2
    MultiUE Trigger DL Traffic for SA    ${5}  ${5}  Traffic_rate=mbps     dl_rate=1   pdu_id=1   trf_id=1   qfi_id=2

    UE PDU Modfication should be Successful Gbr Congession     ${5}    pdu_id=1    qosflows_to_add=3

#    UE PDU Modfication should be Successful     ${5}    pdu_id=1    qosflows_to_add=3
#    Trigger VoNR DL Traffic for SA    ${5}    pdu_id=1     trf_id=1     qfi_id=3    rtp_codec=custom
#    Trigger VoNR UL Traffic for SA    ${5}    pdu_id=1     trf_id=1     qfi_id=3    rtp_codec=custom
#
#    UE PDU Modfication should be Successful Gbr Congession     ${5}    pdu_id=1    qosflows_to_add=4


    ${path_traceCPRT_UEs}    Stop log      cprt    test_scenario=TraceCPRT1

    [Teardown]    Link SCOUT SCF to Configuration ID for Reporting

*** Keywords ***
Start_capture_testcase_default_logging
    ${TEST_NAME}      replace string   ${TEST_NAME}      ${SPACE}        _
    set suite variable      ${TEST_NAME}
    Start Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}

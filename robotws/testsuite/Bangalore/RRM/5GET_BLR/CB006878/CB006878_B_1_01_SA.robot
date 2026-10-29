*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS00    SBTS23R1    CONFIGURED

Documentation
...
...             author:            Mohan
...             maintainer:        mohanavel.p@nokia.com
...
...             INTRODUCTION:     CB006878_B#1_01_LongPucch_SA_multiBWP_100MHz_slotRatio3_7_csiReportPeriodicity_slots320_1UE_ecpri
...             TESTING SPLIT:    Refer CB006878 Test Plan
...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:       CB006878 CFAM
...             Requirement ID:   5G_RAN_USR_RRM_16315

Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Resource         resources/CB006878_Keywords.robot
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         ../resources/robot/Setup_Env.robot
Resource         ../resources/robot/Airphone.robot
Resource         ../resources/robot/WTS_Runner_Keywords.robot
Resource         ../resources/robot/PM_Counters.robot
Library          ../resources/python/BIP_Capture.py
Library          ../resources/python/CPRT_Capture.py

Suite Setup         Run keywords    Run Keyword and Ignore Error      Suite setup from scratch
...                 AND     Update GSCN in AP Iphy Xml     gscn=7867
...                 AND     Check and active the BTS l2ps DBG log
...                 AND    Modify IPHY File And Send to Airphone Custom    ${IPHY_FILE}
...                 AND    Find Scfc And Fix And Send Full Commissioning
...                           scfc_filename=CB006878_B_01_01_LongPucch.xml
...                 AND    Sleep   180s
...                 AND    Start Default Logging    output_dirpath=${LOG_PATH}
...                 AND    Load CFG Config And Verify BWP-List During cell setup in Capture CPRT Traces    ${wts_cfg_file}   ${no_of_cells}
...                 AND     Check gNB Bulid

Suite Teardown    Run Keywords     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
...                 AND     Run Keyword and Ignore Error    Get Snapshot
#...                 AND     Run Keyword and Ignore Error    Get Sos Report
#...                 AND     Run Keyword and Ignore Error    Stop Default Processes And Gather Logs And Compress Logs
#Suite Teardown    Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner

#Test Setup       Start_capture_testcase_default_logging
Test Teardown    Run Keywords    Stop Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}
...                 AND     Run Keyword and Ignore Error    MultiUE Deregister should be Successful   1   4

*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/basic_setup_APoABIO_MultiUe_VONR_tdd.cfg
${IPHY_FILE}                    ${CURDIR}/config/APoABIO_MultiUe_VONR_tdd_iphy.xml
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}          /opt/iphy/latest
${UE_ID}        1
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${QFI_ID}    1
${TRF_ID}    1
${TRF_ID2}    2
${epc_log_path}    /tmp/
${Large_BWP}      bwp:.*1\\sfd
${PS_BWP}      bwp:.*2\\sfd
@{syslog_regex_bwp}     DCI11   DCI01
@{syslog_regex_csi}     CSI-RS sending   PER-CSI-PUCCH receiving
${no_of_cells}   2

*** Test Cases ***
[1]CB006878_B#1_01_LongPucch_SA_multiBWP_100MHz_1UE_ecpri
#CB006878_B_1_01_LongPucch_SA_multiBWP_100MHz_slotRatio3_7_csiReportPeriodicity_slots320_1UE_ecpri
    #Starting CPRT Trace Capturing
    ${LOG_PATH}  Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
    log to console   UE attach trigerring now...
    Start Collecting Syslog     NAME=ue_attach_TC13
    Start CPRT Trace Capturing
    Start L2 BIP Trace Capturing
    #Bip Mon Start AP ASIK ABIL
    UE Register should be Successful     ue_id=${UE_ID}
    Trigger DL Traffic for SA    ue_id=${UE_ID}    Traffic_rate=kbps     dl_rate=15       pdu_id=1      trf_id=1      qfi_id=${QFI_ID}
    sleep   2s
    UE PDU Addition should be Successful      ue_id=1    nw_id=1    pdu_id=2    gw_id=2

    #UE MOVING FROM LARGE  BWP PROFILE TO POWER SAVING BWP PROFILE
    Trigger UL Traffic for SA    ue_id=${UE_ID}    Traffic_rate=kbps     ul_rate=15       pdu_id=1      trf_id=1      qfi_id=${QFI_ID}
    sleep   5s
    Trigger DL Traffic for SA    ue_id=${UE_ID}    Traffic_rate=kbps     dl_rate=15       pdu_id=2      trf_id=1      qfi_id=${QFI_ID}
    sleep   5s
    Trigger UL Traffic for SA    ue_id=${UE_ID}    Traffic_rate=kbps     ul_rate=15       pdu_id=2      trf_id=1      qfi_id=${QFI_ID}
    sleep   5s    reason=Wait for successful BWP switch
    Stop L1L2 capture  ${CaptureL1L2}
    #Bip Mon Stop AP ASIK ABIL   ${LOG_PATH}
    Stop CPRT capture   ${CaptureCPRT}
    Stop Collecting Syslog       NAME=ue_attach_TC13
    Move File    ${LOG_PATH}/NODECPRT_GNB.pcap    ${LOG_PATH}/NODECPRT_GNB_UE_Attach_TC13.pcap
    Move File    ${LOG_PATH}/L1L2_GNB_FS_LO.pcap    ${LOG_PATH}/BIP_UE_Attach_L1L2_GNB_TC13.pcap
    ${bwpid}    Create List     2
    ${crnti_list}     Create List
    Capture TTI Traces and Validate UE bwpid    ${LOG_PATH}    lowdata    ${crnti_list}     ${bwpid}    ${Branch_22R1}
    Run Keyword And Continue on Failure    Syslog should contain CSI Reports in syslogs    NAME=ue_attach_TC13      csi_regex=${syslog_regex_csi}
    Validate DL Traffic For SA   ue_id=${UE_ID}     dl_rate=0.015     pdu_id=1    qfi_id=${QFI_ID}
    Validate UL Traffic For SA   ue_id=${UE_ID}     ul_rate=0.015     pdu_id=1    qfi_id=${QFI_ID}
    Validate DL Traffic For SA   ue_id=${UE_ID}     dl_rate=0.015     pdu_id=2    qfi_id=${QFI_ID}
    Validate UL Traffic For SA   ue_id=${UE_ID}     ul_rate=0.015     pdu_id=2    qfi_id=${QFI_ID}

    #UE MOVING FROM POWER SAVING BWP PROFILE TO LARGE  BWP PROFILE
    Start Collecting Syslog     NAME=ue_dci_switch2LGBWP_TC13
    Start L2 BIP Trace Capturing
    Trigger DL Traffic for SA    ue_id=${UE_ID}    Traffic_rate=mbps     dl_rate=2      pdu_id=1     trf_id=${TRF_ID2}      qfi_id=${QFI_ID}
    wtsrunner.bearer_stats_clear     ue=${UE_ID}    pdu=${Pdu_session_ID}
    sleep   3s      reason=Wait for successful BWP switch
    Stop L1L2 capture  ${CaptureL1L2}
    Move File    ${LOG_PATH}/L1L2_GNB_FS_LO.pcap    ${LOG_PATH}/BIP_L1L2_GNB_switch2LGBWP_TC13.pcap
    Sleep  20s
    Stop Collecting Syslog       NAME=ue_dci_switch2LGBWP_TC13
    ${bwpid}    Create List     1
    Capture TTI Traces and Validate UE bwpid    ${LOG_PATH}    highdata    ${crnti_list}     ${bwpid}    ${Branch_22R1}
    Run Keyword And Continue on Failure    Syslog should contain CSI Reports in syslogs    NAME=ue_dci_switch2LGBWP_TC13      
    ...     csi_regex=${syslog_regex_csi}
    Validate UL Traffic For SA   ue_id=${UE_ID}     pdu_id=1    ul_rate=0.015        qfi_id=${QFI_ID}
    Validate DL Traffic For SA   ue_id=${UE_ID}     pdu_id=1    dl_rate=2           qfi_id=${QFI_ID}
    Validate DL Traffic For SA   ue_id=${UE_ID}     pdu_id=2    dl_rate=0.015       qfi_id=${QFI_ID}
    Validate UL Traffic For SA   ue_id=${UE_ID}     pdu_id=2    ul_rate=0.015       qfi_id=${QFI_ID}
    Stop Data Traffic for SA     ue_id=${UE_ID}
    UE Deregister should be Successful   ue_id=${UE_ID}

*** Keywords ***
Start_capture_testcase_default_logging
    ${TEST_NAME}=       replace string  ${TEST_NAME}      ${SPACE}        _
    set suite variable      ${TEST_NAME}
    Start Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}

*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO      VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE
...             CRT    RAN_5G    5G_RAN     SBTS00     CONFIGURED

Documentation    :copyright: Nokia
...              :authors: Chaithanya,Mary,Ganesha
...              :contact: mary.thomas@nokia.com
...
...  Purpose of this test is to verify the successful SCell change procedure from FDD Scell configured with small BWP to TDD Scell configured
...  with small BWP.This scenario is applied only when one FDD P(S)Cell has both FDD SCells and FR1 TDD SCells and the SCell addition method
...  is A1 measurement(P(S)Cell) based. CA UE is not supporting full carrier bandwidth of FDD Scell nor TDD SCell.
...  CA UE which support both F-F and F-T CA will select FDD SCell based on reported A1 measurement report. Small BWP is used in FDD SCell.
...  Once UE is moved to coverage of TDD SCell. SCell reselection is triggered and if the new SCell candidates is better than current SCell.
...  SCell change will be triggered and Small BWP will be used in TDD SCells.
...  UE is attached to NRCELL-2 (FDD,n25,largeBWP:30MHz, smallBWP:20MHz)
...  NRCELL-3 is scellA and is configured with FDD,n66,largeBWP:30MHz, smallBWP:20MHz
...  NRCELL-1 is scellB and is configured with TDD,n78,largeBWP:90MHz, smallBWP:60MHz
...  UE supports band combinations: 2CC n25A-n66A and 2CC n25A-n78A with small BWP support

Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Library          Collections
Resource         resources/CB008541_Keywords.robot
Resource         CB008541_A_B101_6_SA_FDD_TDD_TDD_3CC.robot


Suite Teardown    Run Keywords     Run Keyword and Ignore Error    Get Snapshot
...                 AND     Run Keyword and Ignore Error    Get Sos Report

*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/basic_setup_scellchange.cfg
${wts_cfg_file1}     ${CURDIR}/config/basic_setup_3CC.cfg
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}          /opt/iphy/latest
${UE_ID}        1
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${QFI_ID}    1
${TRF_ID}    1
${TRF_ID2}    2
${TRF_ID3}    3
${TRF_ID4}    4
${epc_log_path}    /tmp/
${phycell_id}  51
${PM_PCELL_COUNTER1}    M55167C00001
${PM_PCELL_COUNTER2}    M55167C00002
${PM_PCELL_COUNTER3}    M55139C04001
${PM_SCELL_COUNTER1}    M55308C28001
${PM_SCELL_COUNTER2}    M55308C28002
${EXPECTED_PCELL_VALUE1}    300
${EXPECTED_PCELL_VALUE2}    300
${EXPECTED_PCELL_VALUE3}    1
${EXPECTED_SCELL_VALUE1}    27000
${EXPECTED_SCELL_VALUE2}    1

*** Test Cases ***
[1]CB008541_A_B501_1_SA_UEsupporting_Pcell_SBWP_SCellA_SBWP_SCellB_SBWP_ScellChange_for_FDD_FDD_TDD_3CC_CA
    [Tags]   TC01
    [Documentation]    In this testcase verify that CB008541_A_B101_6_SA_UEsupporting_Pcell_SBWP_SCellA_SBWP_SCellB_SBWP_for_FDD_TDD_TDD_3CC_CA
    ...     In this testcase verify that SCell change procedure is successful for 5G NR UE configured with small BWP
    ...     UE is attached to Pcell and Start High Data
    ...     Trigger A1meas and Verify scell activation and counters
    ...     Trigger A1meas for scell change and verify scell change activation
    ...     Trigger low data and verify scell deactivation
    [Setup]        Run Keywords   Set Suite Variable    ${SCFC}          Bangalore/RRM/ET/CB008541/8541_A_B501_1_scellchange_scf.xml
    ...     AND   Set Suite Variable   ${AP_XML}         Bangalore/RRM/ET/CB008541/8541_A_B501_1_scellchange_iphy.xml
    ...                 AND     Prepare TL with all config files
    ...                 AND     Run Keyword and Ignore Error      Suite setup from scratch
    ...                 AND     Load CFG Config And Verify BWP-List During cell setup in Capture CPRT Traces      ${wts_cfg_file}
    ...                 AND     Check gNB Bulid
    ...                 AND      Start_capture_testcase_default_logging
    ${LOG_PATH}  Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
    Register UE And Verify Scell Addition With A1 Measurement On High Data Traffic
    Verify Scell Change is Successfull
    Verify Scell Deactivation On Low Data Traffic
    [Teardown]    Run Keywords     Stop Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}
    ...                 AND     Link SCOUT SCF to Configuration ID for Reporting
    ...                 AND      Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner

[1]CB008541_A_B101_6_SA_UEsupporting_Pcell_SBWP_SCellA_SBWP_SCellB_SBWP_for_FDD_TDD_TDD_3CC_CA
    [Tags]   TC02
    [Documentation]   in this testcase verify that CB008541_A_B101_6_SA_UEsupporting_Pcell_SBWP_SCellA_SBWP_SCellB_SBWP_for_FDD_TDD_TDD_3CC_CA
    [Setup]   Run Keywords   Set Suite Variable    ${SCFC}         Bangalore/RRM/ET/CB008541/8541_A_B5101_6_3CC_scf.xml
    ...   AND   Set Suite Variable   ${AP_XML}                Bangalore/RRM/ET/CB008541/8541_A_B5101_6_3CC_iphy.xml
    ...                 AND     Prepare TL with all config files
    ...                 AND     Run Keyword and Ignore Error      Suite setup from scratch
    ...                 AND     Load CFG Config And Verify BWP-List During cell setup in Capture CPRT Traces      ${wts_cfg_file1}
    ...                 AND     Check gNB Bulid
    ...                 AND      Start_capture_testcase_default_logging
    ${LOG_PATH}  Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
    CB008541_A_B101_6_SA_UEsupporting_Pcell_SBWP_SCellA_SBWP_SCellB_SBWP_for_FDD_TDD_TDD_3CC_CA
    [Teardown]    Run Keywords     Stop Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}
    ...                 AND     Link SCOUT SCF to Configuration ID for Reporting
    ...                 AND      Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner

*** Keywords ***
Register UE And Verify Scell Addition With A1 Measurement On High Data Traffic
    Run Keyword and Ignore Error    Start Collecting Syslog     NAME=scell_add
    Start CPRT Trace Capturing
    #Start L2 BIP Trace Capturing
    log to console   UE attach trigerring now...
    UE Register should be Successful     ue_id=${UE_ID}
    Start 700 Mbps Big DL Data Transfer And Check SCell Activation for 3CC
	Trigger A1 Measurement and verify Scell added successfully    1    3    28875
    #Stop L1L2 capture  ${CaptureL1L2}
    Stop CPRT capture   ${CaptureCPRT}
    Run Keyword And Ignore Error   Move File    ${LOG_PATH}/NODECPRT_GNB.pcap    ${LOG_PATH}/NODECPRT_GNB_scell_add.pcap
    Run Keyword And Ignore Error   Move File    ${LOG_PATH}/L1L2_GNB_L1B_BO.pcap    ${LOG_PATH}/BIP_scell_add.pcap
    sleep   10s    reason=Wait for traffic to become stable
    Validate DL Traffic For SA for high data   ue_id=${UE_ID}     dl_rate=395     qfi_id=${QFI_ID}
    Verify Counters_scellchange M55139C04001     1
    Verify DL Tput For 2CC
	Verify Counters_scellchange    300    300     27000    1
    log to console    Collecting PM counter...
    Stop Collecting Syslog       NAME=scell_add

Verify Scell Change is Successfull
    log to console   Triggering scellChange now...
    Run Keyword and Ignore Error    Start Collecting Syslog     NAME=scell_change
    Start CPRT Trace Capturing
    #Start L2 BIP Trace Capturing
	Trigger A1 Measurement and verify Scell change successfully    1    4    phycell_id=${phycell_id}   loc_BW=31624
    Stop CPRT capture     ${CaptureCPRT}
    #Stop L1L2 capture     ${CaptureL1L2}
    Run Keyword And Ignore Error   Move File    ${LOG_PATH}/NODECPRT_GNB.pcap    ${LOG_PATH}/NODECPRT_GNB_scell_change.pcap
    Run Keyword And Ignore Error   Move File    ${LOG_PATH}/L1L2_GNB_L1B_BO.pcap    ${LOG_PATH}/BIP_scellchange.pcap
    Stop Collecting Syslog       NAME=scell_change
    sleep   10s    reason=Wait for traffic to become stable
    Validate DL Traffic For SA for high data   ue_id=${UE_ID}     dl_rate=1060     qfi_id=${QFI_ID}
    Verify DL Tput For 2CC_scellchange

Verify Scell Deactivation On Low Data Traffic
    Run Keyword and Ignore Error    Start Collecting Syslog     NAME=scell_deactivate
    Start CPRT Trace Capturing
    #Start L2 BIP Trace Capturing
    Start Low Data Traffic And Check Scell Deactivation
    Run Keyword And Continue on Failure     wtsrunner.read_wtsemu_output
    Run Keyword And Continue on Failure     wtsrunner.read_wtsemu_output_until_prompt    timeout=10
    Verify Low Data Traffic
    Stop CPRT capture     ${CaptureCPRT}
    #Stop L1L2 capture     ${CaptureL1L2}
    Run Keyword And Ignore Error   Move File    ${LOG_PATH}/NODECPRT_GNB.pcap    ${LOG_PATH}/NODECPRT_GNB_scell_change.pcap
    Run Keyword And Ignore Error   Move File    ${LOG_PATH}/L1L2_GNB_L1B_BO.pcap    ${LOG_PATH}/BIP_scellchange.pcap
    Validate DL Traffic For SA for high data      ue_id=${UE_ID}     dl_rate=0.010     qfi_id=${QFI_ID}
    Validate UL Traffic For SA   ue_id=${UE_ID}     ul_rate=0.010     qfi_id=${QFI_ID}
    Stop Data Traffic for SA     ue_id=${UE_ID}
    UE Deregister should be Successful   ue_id=${UE_ID}
    Stop Collecting Syslog       NAME=scell_deactivate
    log to console    Collecting PM counter...
    Run keyword and continue on failure   Verify Counters_scelldeact    300    0    0    0    0

Start 700 Mbps Big DL Data Transfer And Check SCell Activation for 3CC
    Trigger DL Data Traffic for SA    ue_id=${UE_ID}    Traffic_rate=mbps     dl_rate=170       trf_id=1
    sleep   5s
    Trigger DL Data Traffic for SA    ue_id=${UE_ID}    Traffic_rate=mbps     dl_rate=170       trf_id=2
    sleep   5s    reason=Wait for successful traffic start
    Trigger DL Data Traffic for SA    ue_id=${UE_ID}    Traffic_rate=mbps     dl_rate=170       trf_id=3
    sleep   5s
    Trigger DL Data Traffic for SA    ue_id=${UE_ID}    Traffic_rate=mbps     dl_rate=170       trf_id=4
    sleep   5s    reason=Wait for successful traffic start
    Trigger DL Data Traffic for SA    ue_id=${UE_ID}    Traffic_rate=mbps     dl_rate=170       trf_id=5
    sleep   5s    reason=Wait for successful traffic start
    Trigger DL Data Traffic for SA    ue_id=${UE_ID}    Traffic_rate=mbps     dl_rate=170       trf_id=6
    sleep   5s
    Trigger DL Data Traffic for SA    ue_id=${UE_ID}    Traffic_rate=mbps     dl_rate=170       trf_id=7
    sleep   5s    reason=Wait for successful traffic start
    Trigger DL Data Traffic for SA    ue_id=${UE_ID}    Traffic_rate=mbps     dl_rate=170       trf_id=8
    sleep   5s    reason=Wait for successful traffic start


Start Low Data Traffic And Check Scell Deactivation
    Trigger DL Traffic for SA    ue_id=${UE_ID}    Traffic_rate=kbps     dl_rate=10       trf_id=7      qfi_id=${QFI_ID}
    sleep   5s
    Trigger UL Traffic for SA    ue_id=${UE_ID}    Traffic_rate=kbps     ul_rate=10       trf_id=7      qfi_id=${QFI_ID}
    sleep   5s    reason=Wait for successful traffic start
    TRF Data Stop for SA    ue_id=${UE_ID}    trf_id=1    dir=dl     pdu_id=${Pdu_session_ID}
    TRF Data Stop for SA    ue_id=${UE_ID}    trf_id=2    dir=dl     pdu_id=${Pdu_session_ID}
    TRF Data Stop for SA    ue_id=${UE_ID}    trf_id=3    dir=dl     pdu_id=${Pdu_session_ID}
    TRF Data Stop for SA    ue_id=${UE_ID}    trf_id=4    dir=dl     pdu_id=${Pdu_session_ID}
    TRF Data Stop for SA    ue_id=${UE_ID}    trf_id=5    dir=dl     pdu_id=${Pdu_session_ID}
    TRF Data Stop for SA    ue_id=${UE_ID}    trf_id=6    dir=dl     pdu_id=${Pdu_session_ID}
    TRF Data Stop for SA    ue_id=${UE_ID}    trf_id=8    dir=dl     pdu_id=${Pdu_session_ID}
    sleep   10s    reason=Wait for successful traffic stop

Verify DL Tput For 2CC_scellchange
    ${pcell_tput}=    Get AVG DL DATA TRAFFIC For Given CC    ue_id=${UE_ID}    scell_idx=0    unit=Mbps
    ${scell_tput}=    Get AVG DL DATA TRAFFIC For Given CC    ue_id=${UE_ID}    scell_idx=2    unit=Mbps
    Should Be True    ${pcell_tput} > ${130}
    Should Be True    ${scell_tput} > ${330}

Verify Counters_scellchange
    [Arguments]    ${EXPECTED_PCELL_VALUE1}    ${EXPECTED_PCELL_VALUE2}      ${EXPECTED_SCELL_VALUE1}    ${EXPECTED_SCELL_VALUE2}
    Wait until the next Measurement Period starts
    ${PM_dir_1}=     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
    Validate PM Counters_scellchange   PM_dir=${PM_dir_1}   PM_counter=${PM_PCELL_COUNTER1}   expected_value=${EXPECTED_PCELL_VALUE1}   moc=NRCELL-3
    Validate PM Counters_scellchange   PM_dir=${PM_dir_1}   PM_counter=${PM_PCELL_COUNTER2}   expected_value=${EXPECTED_PCELL_VALUE2}   moc=NRCELL-3
    Validate PM Counters bigger than_scell    PM_dir=${PM_dir_1}    PM_counter=${PM_SCELL_COUNTER1}    expected_value=${EXPECTED_SCELL_VALUE1}
    Validate PM Counters_scellchange   PM_dir=${PM_dir_1}   PM_counter=${PM_SCELL_COUNTER2}   expected_value=${EXPECTED_SCELL_VALUE2}   moc=NRCELL-4

Verify Counters_scelldeact
    [Arguments]   ${EXPECTED_PCELL_VALUE1}  ${EXPECTED_PCELL_VALUE2}   ${EXPECTED_PCELL_VALUE3}   ${EXPECTED_SCELL_VALUE1}   ${EXPECTED_SCELL_VALUE2}
    Wait until the next Measurement Period starts
    Wait until the next Measurement Period starts
    Wait until the next Measurement Period starts
    ${PM_dir_1}=     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
    Validate PM Counters_scellchange   PM_dir=${PM_dir_1}   PM_counter=${PM_PCELL_COUNTER1}   expected_value=${EXPECTED_PCELL_VALUE1}   moc=NRCELL-3
    Validate PM Counters_scellchange   PM_dir=${PM_dir_1}   PM_counter=${PM_PCELL_COUNTER2}   expected_value=${EXPECTED_PCELL_VALUE2}   moc=NRCELL-3
    Validate PM Counters_scellchange    PM_dir=${PM_dir_1}    PM_counter=${PM_PCELL_COUNTER3}
    ...   	expected_value=${EXPECTED_PCELL_VALUE3}    moc=NRCELL-3
    Validate PM Counters_scellchange   PM_dir=${PM_dir_1}   PM_counter=${PM_SCELL_COUNTER1}   expected_value=${EXPECTED_SCELL_VALUE1}   moc=NRCELL-4
    Validate PM Counters_scellchange   PM_dir=${PM_dir_1}   PM_counter=${PM_SCELL_COUNTER2}   expected_value=${EXPECTED_SCELL_VALUE2}   moc=NRCELL-4


Validate PM Counters_scellchange
    [Arguments]    ${PM_dir}     ${PM_counter}    ${expected_value}    ${moc}
    PM_Counters.Check PM counter value equal    expected_value=${expected_value}   pm_files_location=${PM_dir}
    ...  pi_id=${PM_counter}    moc=${moc}

Validate PM Counters bigger than_scell
    [Arguments]    ${PM_dir}     ${PM_counter}    ${expected_value}
    PM_Counters.Check PM counter value bigger than    expected_value=${expected_value}   pm_files_location=${PM_dir}
    ...  pi_id=${PM_counter}    moc=NRCELL-4

Verify Counters_scellchange M55139C04001
    [Arguments]     ${EXPECTED_PCELL_VALUE3}
    Wait until the next Measurement Period starts
    ${PM_dir_1}=     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
    Run Keyword And Continue on Failure     Validate PM Counters_scellchange    PM_dir=${PM_dir_1}    PM_counter=${PM_PCELL_COUNTER3}
    ...  	expected_value=${EXPECTED_PCELL_VALUE3}    moc=NRCELL-3
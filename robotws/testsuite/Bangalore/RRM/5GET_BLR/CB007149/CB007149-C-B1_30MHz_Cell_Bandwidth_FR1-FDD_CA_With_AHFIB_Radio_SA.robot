*** Settings ***
Force Tags      CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD
...             CONFIGS_Bangalore/RRM/ET/CB007149/CB007149_AHFIB_CA_SA.yml
...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS00    SBTS23R1    CONFIGURED

Documentation    :copyright: Nokia
...              :authors: Nagesh
...              :contact: nagesh.k_v@nokia.com
...             INTRODUCTION:     Use case of the Test case is to verify that cell is coming ON AIR with band n3 AHFIB
...             TEST SET NAME:    CB007149-A-B1_30MHz_Cell_Bandwidth_FR1-FDD_Cell_Setup_With_AHFIB_Radio_NSA
...                               This user scenario describes successful cell onAir gNB behavior for NR cell FR1-FDD
...                               bandwidth 30Mhz with DL/UL traffic with AHFIB Radio
...             TESTING SPLIT:    See CB007149 testplan
...             CONTACTS:         I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:       CB007149 CFAM
...             Requirement ID:   5G_RAN_USR_RRM_15590

Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Resource         resources/robot/CB007149_CA_SA_Keywords.robot
Library          ../resources/python/avg_dl_data.py

Suite Setup         Run keywords    Suite setup from scratch
...                 AND     Load CFG Config And Verify BWP-List During cell setup in Capture CPRT Traces      ${wts_cfg_file}
...                 AND     Check gNB Bulid

Suite Teardown    Run Keywords    Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
...                 AND     Run Keyword and Ignore Error    Get Snapshot
...                 AND     Run Keyword and Ignore Error    Get Sos Report

Test Setup       Start_capture_testcase_default_logging
Test Teardown    Stop Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}

*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/wts/CB007149_CA_SA.cfg
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}          /opt/iphy/latest
${UE_ID}        3
${nwslice_ID}   1
${gw_ID}     3
${Pdu_session_ID}       1
${QFI_ID}    1
${TRF_ID}    1
${TRF_ID2}    2

*** Test Cases ***
[1]CB007149-C-B1_30MHz_Cell_Bandwidth_FR1-FDD_CA_With_AHFIB_Radio_SA
    [Documentation]   in this testcase verify SA carrier aggregation Scell selection after inter gNB Handover,
	...               for TDD Pcell and FDD SCell selection. UE supporting large BWP in Pcell and small BWP in Scell.
	...               UE attach with gNBSim PcellA with the NR capabilities for band combination.
	...               UE sends RRC: A3 Measurement report to the gNB PcellA for inter gnb HO.
	...               UE sends RRC: A1 Measurement report to the gNB for Scell Addition.
	...               Send high dl/ul traffic for ue
    [Tags]     QC_201835    QC_193381     QCD_MN_RAN    QCP_RAN_ET

	${LOG_PATH}  Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
	Establish Xn Link To gNB3
    Register UE
	Start Big DL data and verify Scell activation through A1 measurement based
	Start low DL data and verify Scell deactivation
	Stop Data Traffic for SA     ue_id=${UE_ID}
    UE Deregister should be Successful   ue_id=${UE_ID}

*** Keywords ***
Start_capture_testcase_default_logging
    ${TEST_NAME}=       replace string  ${TEST_NAME}      ${SPACE}        _
    set suite variable      ${TEST_NAME}
    Start Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}

Register UE
    log to console   UE attach trigerring now...
    Run keyword and ignore error    Start Collecting Syslog     NAME=syslog_ue_attach
    Start CPRT Trace Capturing
    UE Register should be Successful     ${UE_ID}
    Sleep    10s
    Run keyword and ignore error    Stop Collecting Syslog       NAME=syslog_ue_attach
    Run Keyword And Ignore Error     Stop CPRT capture   ${CaptureCPRT}
    Run Keyword And Ignore Error     Move File    ${LOG_PATH}/NODECPRT_GNB.pcap   ${LOG_PATH}/UE_attach_cprt.pcap

Trigger InterGnb HO
    log to console   Trigger InterGnb HO...
#    Run keyword and ignore error    Start Collecting Syslog       NAME=scell_afterHO
#    Start CPRT Trace Capturing
#Start L2 BIP Trace Capturing
    Get Configured Measurements of UE${UE_ID}
    Trigger A3 RsrpAndRsrq Measurement from real gnb to simulated gNB     3     1     52
    Wait until the next Measurement Period starts
    Trigger A3 RsrpAndRsrq Measurement from simulated gnb to real gNB     3      1    50
    Get Configured Measurements of UE${UE_ID}
	Trigger A1 Measurement and verify Scell added successfully     3     6    28875
#Run Keyword And Ignore Error    Stop L1L2 capture  ${CaptureL1L2}
#   Run Keyword And Ignore Error     Stop CPRT capture   ${CaptureCPRT}
#   Run keyword and ignore error    Stop Collecting Syslog       NAME=scell_afterHO
#Run Keyword And Ignore Error    Move File    ${LOG_PATH}/L1L2_GNB_L1B_BO.pcap    ${LOG_PATH}/BIP_scell_afterHO_highdata.pcap
#   Run Keyword And Ignore Error     Move File    ${LOG_PATH}/NODECPRT_GNB.pcap   ${LOG_PATH}/scell_afterHO_highdata_cprt.pcap
    Run Keyword And Continue on Failure    Validate DL Traffic For SA for high data   ue_id=${UE_ID}     dl_rate=620     qfi_id=${QFI_ID}
    Verify DL Tput For 2CC TDD FDD CA

Start Big DL data and verify Scell activation through A1 measurement based
    log to console   verify Scell activation...
#   Run keyword and ignore error    Start Collecting Syslog       NAME=scell_add
    Start 700 Mbps Big DL Data Transfer And Check SCell Activation for 2CC
    sleep    5s
    Run Keyword And Continue on Failure    Validate DL Traffic For SA for high data   ue_id=${UE_ID}     dl_rate=510     qfi_id=${QFI_ID}
    Get Configured Measurements of UE${UE_ID}
#   Start CPRT Trace Capturing
#   Start L2 BIP Trace Capturing
    Trigger A1 Measurement and verify Scell added successfully     3     2     28875
#   Run Keyword And Ignore Error    Stop L1L2 capture  ${CaptureL1L2}
#   Run Keyword And Ignore Error     Stop CPRT capture   ${CaptureCPRT}
#   Run keyword and ignore error    Stop Collecting Syslog       NAME=scell_add
#    Run Keyword And Ignore Error    Move File    ${LOG_PATH}/L1L2_GNB_L1B_BO.pcap    ${LOG_PATH}/BIP_Scell_activation_highdata.pcap
#   Run Keyword And Ignore Error     Move File    ${LOG_PATH}/NODECPRT_GNB.pcap   ${LOG_PATH}/Scell_activation_highdata_cprt.pcap
     Run Keyword And Ignore Error     Validate DL Traffic For SA for high data   ue_id=${UE_ID}     dl_rate=600     qfi_id=${QFI_ID}
     Run Keyword And Continue on Failure    Verify DL Tput For 2CC TDD FDD CA

Start low DL data and verify Scell deactivation
    log to console   verify Scell deactivation...
#    Run keyword and ignore error    Start Collecting Syslog     NAME=scell_remove
#   Start CPRT Trace Capturing
#    Start L2 BIP Trace Capturing
	Start Low Data Traffic And Check Scell Deactivation
    sleep    5s
#	Stop CPRT capture   ${CaptureCPRT}
#    Stop L1L2 capture  ${CaptureL1L2}
#   Run keyword and ignore error    Stop Collecting Syslog       NAME=scell_remove
#   Move File    ${LOG_PATH}/NODECPRT_GNB.pcap    ${LOG_PATH}/NODECPRT_GNB_scell_remove.pcap
#    Move File    ${LOG_PATH}/L1L2_GNB_L1B_BO.pcap    ${LOG_PATH}/BIP_scellremove.pcap
    Verify Low Data Traffic
    Run Keyword And Continue on Failure    Validate DL Traffic For SA for high data   ue_id=${UE_ID}     dl_rate=0.010    qfi_id=${QFI_ID}

Start 700 Mbps Big DL Data Transfer And Check SCell Activation for 2CC
    Trigger DL Data Traffic for SA    ue_id=${UE_ID}    Traffic_rate=mbps     dl_rate=150       trf_id=1
    sleep   5s
    Trigger DL Data Traffic for SA    ue_id=${UE_ID}    Traffic_rate=mbps     dl_rate=150       trf_id=2
    sleep   5s    reason=Wait for successful traffic start
    Trigger DL Data Traffic for SA    ue_id=${UE_ID}    Traffic_rate=mbps     dl_rate=150       trf_id=3
    sleep   5s
    Trigger DL Data Traffic for SA    ue_id=${UE_ID}    Traffic_rate=mbps     dl_rate=150       trf_id=4
    sleep   5s    reason=Wait for successful traffic start
    Trigger DL Data Traffic for SA    ue_id=${UE_ID}    Traffic_rate=mbps     dl_rate=100       trf_id=5
    sleep   5s

Start Low Data Traffic And Check Scell Deactivation
	Trigger DL Traffic for SA    ue_id=${UE_ID}    Traffic_rate=kbps     dl_rate=10       trf_id=7      qfi_id=${QFI_ID}
    sleep   5s
    Trigger UL Traffic for SA    ue_id=${UE_ID}    Traffic_rate=kbps     ul_rate=10       trf_id=7      qfi_id=${QFI_ID}
    sleep   5s    reason=Wait for successful traffic start
	TRF Data Stop for SA    ue_id=${UE_ID}    trf_id=1    dir=dl     pdu_id=${Pdu_session_ID}
	Sleep  2s
	TRF Data Stop for SA    ue_id=${UE_ID}    trf_id=2    dir=dl     pdu_id=${Pdu_session_ID}
	Sleep  2s
	TRF Data Stop for SA    ue_id=${UE_ID}    trf_id=3    dir=dl     pdu_id=${Pdu_session_ID}
	Sleep  2s
	TRF Data Stop for SA    ue_id=${UE_ID}    trf_id=4    dir=dl     pdu_id=${Pdu_session_ID}
	Sleep  2s
	TRF Data Stop for SA    ue_id=${UE_ID}    trf_id=5    dir=dl     pdu_id=${Pdu_session_ID}

Verify Counters incrementing Inter GNB HO
    [Arguments]    ${EXPECTED_PCELL_VALUE1}    ${EXPECTED_PCELL_VALUE2}      ${EXPECTED_SCELL_VALUE1}    ${EXPECTED_SCELL_VALUE2}
    Wait until the next Measurement Period starts
    ${PM_dir_1}=     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
    Validate PM Counters_scell   PM_dir=${PM_dir_1}   PM_counter=${PM_PCELL_COUNTER1}   expected_value=${EXPECTED_PCELL_VALUE1}   moc=NRCELL-1
    Validate PM Counters_scell   PM_dir=${PM_dir_1}   PM_counter=${PM_PCELL_COUNTER2}   expected_value=${EXPECTED_PCELL_VALUE2}   moc=NRCELL-1
    Validate PM Counters bigger than_scell    PM_dir=${PM_dir_1}    PM_counter=${PM_SCELL_COUNTER1}    expected_value=${EXPECTED_SCELL_VALUE1}
    Validate PM Counters_scell   PM_dir=${PM_dir_1}   PM_counter=${PM_SCELL_COUNTER2}   expected_value=${EXPECTED_SCELL_VALUE2}   moc=NRCELL-2

Verify Counters decrementing Inter GNB HO
    [Arguments]   ${EXPECTED_PCELL_VALUE1}  ${EXPECTED_PCELL_VALUE2}   ${EXPECTED_PCELL_VALUE3}   ${EXPECTED_SCELL_VALUE1}   ${EXPECTED_SCELL_VALUE2}
    Wait until the next Measurement Period starts
    Wait until the next Measurement Period starts
    ${PM_dir_1}=     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
    Validate PM Counters_scell   PM_dir=${PM_dir_1}   PM_counter=${PM_PCELL_COUNTER1}   expected_value=${EXPECTED_PCELL_VALUE1}   moc=NRCELL-1
    Validate PM Counters_scell   PM_dir=${PM_dir_1}   PM_counter=${PM_PCELL_COUNTER2}   expected_value=${EXPECTED_PCELL_VALUE2}   moc=NRCELL-1
    Run Keyword And Continue on Failure     Validate PM Counters_scell    PM_dir=${PM_dir_1}    PM_counter=${PM_PCELL_COUNTER3}
    ...   	expected_value=${EXPECTED_PCELL_VALUE3}    moc=NRCELL-1
    Validate PM Counters_scell   PM_dir=${PM_dir_1}   PM_counter=${PM_SCELL_COUNTER1}   expected_value=${EXPECTED_SCELL_VALUE1}   moc=NRCELL-2
    Validate PM Counters_scell   PM_dir=${PM_dir_1}   PM_counter=${PM_SCELL_COUNTER2}   expected_value=${EXPECTED_SCELL_VALUE2}   moc=NRCELL-2


Validate PM Counters_scell
    [Arguments]    ${PM_dir}     ${PM_counter}    ${expected_value}    ${moc}
    PM_Counters.Check PM counter value equal    expected_value=${expected_value}   pm_files_location=${PM_dir}
    ...  pi_id=${PM_counter}    moc=${moc}

Validate PM Counters bigger than_scell
    [Arguments]    ${PM_dir}     ${PM_counter}    ${expected_value}
    PM_Counters.Check PM counter value bigger than    expected_value=${expected_value}   pm_files_location=${PM_dir}
    ...  pi_id=${PM_counter}    moc=NRCELL-2

Verify Counters incrementing Inter GNB HO M55139C04001
    [Arguments]     ${EXPECTED_PCELL_VALUE3}
    Wait until the next Measurement Period starts
    ${PM_dir_1}=     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
    Run Keyword And Continue on Failure     Validate PM Counters_scell    PM_dir=${PM_dir_1}    PM_counter=${PM_PCELL_COUNTER3}
    ...  	expected_value=${EXPECTED_PCELL_VALUE3}    moc=NRCELL-1

Verify DL Tput For 2CC TDD FDD CA
    ${pcell_tput}=    Get AVG DL DATA TRAFFIC For Given CC    ue_id=${UE_ID}    scell_idx=0    unit=Mbps
    ${scell_tput}=    Get AVG DL DATA TRAFFIC For Given CC    ue_id=${UE_ID}    scell_idx=1    unit=Mbps
    Should Be True    ${pcell_tput} > ${350}
    Should Be True    ${scell_tput} > ${90}

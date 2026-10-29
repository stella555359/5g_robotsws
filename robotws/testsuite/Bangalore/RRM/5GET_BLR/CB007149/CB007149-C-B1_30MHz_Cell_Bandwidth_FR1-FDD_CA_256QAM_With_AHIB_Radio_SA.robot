*** Settings ***
Force Tags      CLOUD_5G_I_LPP_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD
...             CONFIGS_Bangalore/RRM/ET/CB007149/CB007149_AHIB_CA_SA_256QAM.yml
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
...           AND     Reboot gNB System Module from Console and check Airscale is ready
...           AND     Load CFG Config And Verify BWP-List During cell setup in Capture CPRT Traces      ${wts_cfg_file}
...           AND     Check gNB Bulid

Suite Teardown    Run Keywords     Kill WTS processes Using WTS_Runner
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
${PM_PCELL_COUNTER1}     M55118C05505
${PM_PCELL_COUNTER2}     M55118C05506
${PM_SCELL_COUNTER1}     M55316C09000
${PM_tput_COUNTER_dl}    M55310C01006
${PM_tput_COUNTER_ul}    M55310C03006

*** Test Cases ***
[1]CB007149-C-B1_30MHz_Cell_Bandwidth_FR1-FDD_CA_256QAM_With_AHIB_Radio_SA
    [Documentation]   in this testcase verify SA carrier aggregation Scell selection after inter gNB Handover,
	...               for TDD Pcell and FDD SCell selection. UE supporting large BWP in Pcell and small BWP in Scell.
	...               UE attach with gNBSim PcellA with the NR capabilities for band combination.
	...               UE sends RRC: A3 Measurement report to the gNB PcellA for inter gnb HO.
	...               UE sends RRC: A1 Measurement report to the gNB for Scell Addition.
	...               Send high dl/ul traffic for ue

	${LOG_PATH}  Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
    X2AP Link Should be UP
    Wait until the next Measurement Period starts
    Register UE
	Start Big DL data and verify Scell activation through A1 measurement based
	Start UL Data Transfer for 2CC
	Stop Data Traffic for SA     ue_id=${UE_ID}
    UE Deregister should be Successful   ue_id=${UE_ID}
    sleep       300s
    Wait until the current Measurement Period stops
    Verify Counters 2CC_FDD_TDD_CA      1     0

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

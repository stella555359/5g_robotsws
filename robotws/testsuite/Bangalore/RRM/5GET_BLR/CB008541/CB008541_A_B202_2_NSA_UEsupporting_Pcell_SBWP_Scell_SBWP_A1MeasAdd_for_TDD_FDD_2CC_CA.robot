*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE
...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS00     SBTS23R1   CONFIGURED

Documentation    :copyright: Nokia
...              :authors: Madhu
...              :contact: madhusudhan.y@nokia.com
...         The aim of the 5GC000937 feature is to allow power savings for UE with small throughput traffic.
...         The scope of the feature is limited to FR1 TDD for UEs in SA mode.
...         The strategy for UE power savings is based on the possibility of dynamic switch between a BWP with large bandwidth size
...         (often configured with full carrier
...         bandwidth size) and a "power saving BWP" with a narrow bandwidth size.
...         The feature is considered as being efficient when the power saving BWP bandwidth size is a small
...         fraction of the large BWP bandwidth size.
...         A typical example is for carrier bandwidth size 100Mhz, the large BWP covers the full carrier Bw and the
...         power saving BWP bandwidth size is 20Mhz.
...         The dynamic decision for which BWP to use is based on some configurable criteria including UL/DL data rate and
...         UL/DL buffer length.
...         Some mechanism prevents ping-pong effect.
...         A NIDD parameter limits the number of UEs simultaneously in the power saving BWP.

Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Library          Collections
Resource         resources/CB008541_Keywords.robot
Resource         ../resources/robot/common_log_collection.robot

Suite Setup         Run keywords    Run Keyword and Ignore Error    Suite setup from scratch
...                 AND     5GC000937_Keywords.Perform SCF Delta Commissioning with B202_2_NSA_FDD_TDD.json
...                 AND     Prepare TL with IPHY file change
...                 AND     Load CFG Config And Verify BWP-List During cell setup in Capture CPRT Traces      ${wts_cfg_file}
...                 AND     Check gNB Bulid

Suite Teardown    Run Keywords     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
...                 AND     Run Keyword and Ignore Error    Get Snapshot
...                 AND     Run Keyword and Ignore Error    Get Sos Report
#...                 AND     Run Keyword and Ignore Error    Stop Default Processes And Gather Logs And Compress Logs


Test Teardown      Link SCOUT SCF to Configuration ID for Reporting

*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/egate_TMOUS.cfg
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}          /opt/iphy/latest
${UE_ID}        51
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${QFI_ID}    1
${TRF_ID}    1
${TRF_ID2}    2
${TRF_ID3}    3
${TRF_ID4}    4
${a1meas_id}   4
${Target_Cells}    2
${epc_log_path}    /tmp/
${PM_PCELL_COUNTER1}    M55167C00001
${PM_PCELL_COUNTER2}    M55167C00002
${PM_PCELL_COUNTER3}    M55115C03001
${PM_SCELL_COUNTER1}    M55308C28001
${PM_SCELL_COUNTER2}    M55308C28002

${EXPECTED_PCELL_VALUE1}   300
${EXPECTED_PCELL_VALUE2}   300
${EXPECTED_PCELL_VALUE3}   1
${EXPECTED_SCELL_VALUE1}   27000
${EXPECTED_SCELL_VALUE2}   1
${AP_XML}   ${CURDIR}/config/CB008541_A_B202_2_iphy.xml

*** Test Cases ***
[1]CB008541_A_B202_2_NSA_UEsupporting_Pcell_SBWP_Scell_SBWP_A1MeasAdd_for_TDD_FDD_2CC_CA
    [Documentation]  CB008541_A_B202_2_NSA_UEsupporting_Pcell_SBWP_Scell_SBWP_A1MeasAdd_for_TDD_FDD_2CC_CA

    ${LOG_PATH}  Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
    Attach UE
    Start Big Data and trigger A1 for scell addition
    Start Low Data Traffic And Check Scell Deactivation

*** Keywords ***
Attach UE
    Start Collecting Syslog     NAME=scell_add
    Start CPRT Trace Capturing
    Start L2 BIP Trace Capturing
    X2AP Link Should be UP
    LTE Attach should be Successful    ${UE_ID}
    UE Attach should be Successful    ${UE_ID}
    Get Configured Measurements of UE${UE_ID}

Start Big Data and trigger A1 for scell addition
    Start Big DL Data Transfer And Check SCell Activation for 2CC NSA
    Trigger A1 Measurement and verify Scell added successfully   ${UE_ID}    ${a1meas_id}    28875
    Change CQI Number   1   14   15   3   8
    Change CQI Number   2   14   15   1   9
    Run Keyword And Continue on Failure    Validate DL Traffic For NSA for Maximum high data   ue_id=${UE_ID}     dl_rate=290
    Run Keyword and Continue on Failure    Verify DL Tput For 2CC NSA TDD FDD
    Run Keyword and Ignore error   Stop Collecting Syslog      NAME=scell_add
    Run Keyword and Ignore error   Stop L1L2 capture  ${CaptureL1L2}
    Run Keyword and Ignore error   Stop CPRT capture   ${CaptureCPRT}
    Run Keyword and Ignore error   Move File    ${LOG_PATH}/NODECPRT_GNB.pcap    ${LOG_PATH}/NODECPRT_GNB_scell_add.pcap
    Run Keyword and continue on failure    Verify Counters_scelladd M55115C03001     1
    Run Keyword and continue on failure    Verify Counters_scelladd    300    300     27000    1

Start Low Data Traffic And Check Scell Deactivation
    Start Collecting Syslog     NAME=scell_remove
    Start CPRT Trace Capturing
    Start L2 BIP Trace Capturing
    Run keyword and ignore error    TRF Data Stop for NSA     ue_id=${UE_ID}     Bearer_ID=${Bearer_ID}     trf_id=1     dir=dl
    TRF Data Stop for NSA     ue_id=${UE_ID}     Bearer_ID=${Bearer_ID}     trf_id=2     dir=dl
    TRF Data Stop for NSA     ue_id=${UE_ID}     Bearer_ID=${Bearer_ID}     trf_id=3     dir=dl
    TRF Data Stop for NSA     ue_id=${UE_ID}     Bearer_ID=${Bearer_ID}     trf_id=4     dir=dl
    Sleep    5s
    Trigger DL Traffic for NSA     ue_id=${UE_ID}     Traffic_rate=kbps     dl_rate=10     trf_id=1
    sleep    5s
    Trigger UL Traffic for NSA     ue_id=${UE_ID}     Traffic_rate=kbps     ul_rate=10     trf_id=1
    sleep    5s     reason=Wait for successful traffic start
    Run Keyword And Continue on Failure    wtsrunner.read_wtsemu_output_until_prompt    timeout=10
    Run Keyword and continue on failure   Verify Low Data Traffic NSA
    Run Keyword and Ignore error    Stop CPRT capture   ${CaptureCPRT}
    Run Keyword and Ignore error    Stop Collecting Syslog      NAME=scell_remove
    Run Keyword and Ignore error    Stop L1L2 capture  ${CaptureL1L2}
    Run Keyword and Ignore error    Move File    ${LOG_PATH}/NODECPRT_GNB.pcap    ${LOG_PATH}/NODECPRT_GNB_scell_add.pcap
    Run Keyword and continue on failure    Validate DL Traffic For NSA   ue_id=${UE_ID}     dl_rate=0.010
    UE Detach should be Successful
    Run Keyword and continue on failure    Verify Counters_scelldeact    300    0    0    0    0


Verify Counters_scelladd
    [Arguments]    ${EXPECTED_PCELL_VALUE1}    ${EXPECTED_PCELL_VALUE2}      ${EXPECTED_SCELL_VALUE1}    ${EXPECTED_SCELL_VALUE2}
    Wait until the next Measurement Period starts
    ${PM_dir_1}=     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
    Validate PM Counters_scell   PM_dir=${PM_dir_1}   PM_counter=${PM_PCELL_COUNTER1}   expected_value=${EXPECTED_PCELL_VALUE1}   moc=NRCELL-1
    Validate PM Counters_scell   PM_dir=${PM_dir_1}   PM_counter=${PM_PCELL_COUNTER2}   expected_value=${EXPECTED_PCELL_VALUE2}   moc=NRCELL-1
    Validate PM Counters bigger than_scell    PM_dir=${PM_dir_1}    PM_counter=${PM_SCELL_COUNTER1}    expected_value=${EXPECTED_SCELL_VALUE1}
    Validate PM Counters_scell   PM_dir=${PM_dir_1}   PM_counter=${PM_SCELL_COUNTER2}   expected_value=${EXPECTED_SCELL_VALUE2}   moc=NRCELL-2

Verify Counters_scelldeact
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

Verify Counters_scelladd M55115C03001
    [Arguments]     ${EXPECTED_PCELL_VALUE3}
    Wait until the next Measurement Period starts
    ${PM_dir_1}=     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
    Run Keyword And Continue on Failure     Validate PM Counters_scell    PM_dir=${PM_dir_1}    PM_counter=${PM_PCELL_COUNTER3}
    ...  	expected_value=${EXPECTED_PCELL_VALUE3}    moc=NRCELL-1

Verify DL Tput For 2CC NSA TDD FDD
    ${pcell_tput}=    Get AVG DL DATA TRAFFIC For Given CC    ue_id=${UE_ID}    scell_idx=8    unit=Mbps
    ${scell_tput}=    Get AVG DL DATA TRAFFIC For Given CC    ue_id=${UE_ID}    scell_idx=9    unit=Mbps
    Should Be True    ${pcell_tput} > ${190}
    Should Be True    ${scell_tput} > ${80}

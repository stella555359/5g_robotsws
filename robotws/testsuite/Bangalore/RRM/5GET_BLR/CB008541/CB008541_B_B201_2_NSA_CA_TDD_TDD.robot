*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO      VARIANT_SANSA_FS_ECPRI_CMWV_TDD
...           CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD     5G_RAN     SBTS00     CONFIGURED

Documentation    :copyright: Nokia
...              :authors: Chaithanya
...              :contact: Chaithanya.h_s@nokia.com
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
...         This user scenario describes the common gNB behavior with regards to CA UE context setup when UE supporting
...         small BWP for Pcell and small BWP for Scell.
...         dedicated BWP profiles linked to the P(S)Cell.
...         large BWP with bandwidth equal to the cell bandwidth.
...         small BWP with bandwidth equal or higher than half of the cell bandwidth and lower than the large BWP.
...         "small", "large"  BWP profiles  linked to the PCell  have configured different PDCCH setings for User
...         Specific search space and have different coreset.
...         dedicated BWP profiles linked to the SCell.
...         large BWP with bandwidth equal to the cell bandwidth.
...         small BWP with bandwidth equal or higher than half of the cell bandwidth and lower than the large BWP.
...         "small", "large"BWP profiles  linked to the SCell  have configured different PDCCH setings for
...         User Specific search space and have different coreset.


Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Resource         resources/CB008541_Keywords.robot
Library          ../resources/python/avg_dl_data.py

Suite Setup         Run keywords    Prepare TL with all config files
...                 AND     Suite setup from scratch
...                 AND     Check and active the BTS l2ps DBG log
...                 AND     Load CFG Config And Verify BWP-List During cell setup in Capture CPRT Traces      ${wts_cfg_file}
...                 AND     Check gNB Bulid

Suite Teardown    Run Keywords     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
...                 AND     Run Keyword and Ignore Error    Get Snapshot
...                 AND     Run Keyword and Ignore Error    Get Sos Report
#...                 AND     Run Keyword and Ignore Error    Stop Default Processes And Gather Logs And Compress Logs

#Suite Teardown    Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner

Test Setup       Start_capture_testcase_default_logging
Test Teardown     Run keywords   Stop Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}
...                 AND     Link SCOUT SCF to Configuration ID for Reporting

*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/basic_setup_nsa_diff_coreset_APoverABIO.cfg
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}          /opt/iphy/latest
${UE_ID}    12
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${QFI_ID}    1
${TRF_ID}    1
${TRF_ID2}    2
${TRF_ID3}    3
${TRF_ID4}    4
${epc_log_path}    /tmp/
${Bearer_ID}    2
${PM_PCELL_COUNTER1}    M55167C00001
${PM_PCELL_COUNTER2}    M55167C00002
${PM_PCELL_COUNTER3}    M55115C03001
${PM_SCELL_COUNTER1}    M55308C28001
${PM_SCELL_COUNTER2}    M55308C28002
${SCFC}=                   Bangalore/RRM/ET/CB008541/8541_B_B201_2_APoverABIO_scf.xml
${AP_XML}=                 Bangalore/RRM/ET/CB008541/8541_B_B201_2_APoverABIO_iphy.xml


*** Test Cases ***
[1]CB008541_5G_B_B201_2_NSA_UE_supports_SBWP_TDD_TDD_Scell_addition_with_differerent_coreset_7552_8541-A_enabled
    [Documentation]    In this testcase common gNB behavior with regards to CA UE context setup
     ...        when UE supporting small BWP for Pcell and small BWP for Scell

    ${LOG_PATH}  Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
    Regiter UE And Verify Scell Addition On High Data Traffic
	Verify Scell Deactivation On Low Data Traffic

*** Keywords ***
Regiter UE And Verify Scell Addition On High Data Traffic
#    Start Collecting Syslog     NAME=scell_add
#   Start CPRT Trace Capturing
#   Start L2 BIP Trace Capturing
    X2AP Link Should be UP
    LTE Attach should be Successful    NSA_UE_ID=${UE_ID}
    UE Attach should be Successful   NSA_UE_ID=${UE_ID}
    Trigger DL Traffic for NSA    ue_id=${UE_ID}    Traffic_rate=mbps     dl_rate=170       trf_id=1
    sleep   5s
    Trigger DL Traffic for NSA    ue_id=${UE_ID}    Traffic_rate=mbps     dl_rate=170       trf_id=2
    sleep   5s    reason=Wait for successful traffic start
	Get Configured Measurements of UE${UE_ID}
	Trigger A1 Measurement and verify Scell added successfully    12    1    31624
    Trigger DL Traffic for NSA    ue_id=${UE_ID}    Traffic_rate=mbps     dl_rate=170       trf_id=3
    sleep   5s
    Trigger DL Traffic for NSA    ue_id=${UE_ID}    Traffic_rate=mbps     dl_rate=170       trf_id=4
    sleep   5s    reason=Wait for successful traffic start
    Trigger DL Traffic for NSA    ue_id=${UE_ID}    Traffic_rate=mbps     dl_rate=170       trf_id=5
    sleep   5s
    Trigger DL Traffic for NSA    ue_id=${UE_ID}    Traffic_rate=mbps     dl_rate=170       trf_id=6
    sleep   5s    reason=Wait for successful traffic start
#   Stop L1L2 capture  ${CaptureL1L2}
#   Stop CPRT capture   ${CaptureCPRT}
#   Stop Collecting Syslog       NAME=scell_add
#   Move File    ${LOG_PATH}/NODECPRT_GNB.pcap    ${LOG_PATH}/NODECPRT_GNB_scell_add.pcap
#   Move File    ${LOG_PATH}/L1L2_GNB_FS_LO.pcap    ${LOG_PATH}/BIP_scell_add.pcap
    Validate DL Traffic For NSA for high data   ue_id=${UE_ID}     dl_rate=570
	Verify DL Tput For 2CC NSA
    Run Keyword And Continue on Failure    Verify 8541 Counters incrementing

Verify Scell Deactivation On Low Data Traffic
#   Start Collecting Syslog     NAME=scell_remove
#   Start CPRT Trace Capturing
#   Start L2 BIP Trace Capturing
    Start Low Data Traffic And Check Scell Deactivation
    Run Keyword And Continue on Failure    wtsrunner.read_wtsemu_output_until_prompt    timeout=10
    Verify Low Data Traffic NSA
#   Stop CPRT capture   ${CaptureCPRT}
#   Stop L1L2 capture  ${CaptureL1L2}
#   Stop Collecting Syslog       NAME=scell_remove
#   Move File    ${LOG_PATH}/NODECPRT_GNB.pcap    ${LOG_PATH}/NODECPRT_GNB_scell_remove.pcap
#   Move File    ${LOG_PATH}/L1L2_GNB_FS_LO.pcap    ${LOG_PATH}/BIP_scell_add.pcap
	Validate DL Traffic For NSA   ue_id=${UE_ID}     dl_rate=0.010
    Validate UL Traffic For NSA   ue_id=${UE_ID}     ul_rate=0.010
    UE Detach should be Successful
    Run Keyword And Continue on Failure    Verify 8541 Counters decrementing

Start Low Data Traffic And Check Scell Deactivation
    Run Keyword and Ignore Error    TRF Data Stop for NSA    ue_id=${UE_ID}    Bearer_ID=${Bearer_ID}    trf_id=1    dir=dl
    TRF Data Stop for NSA    ue_id=${UE_ID}    Bearer_ID=${Bearer_ID}    trf_id=2    dir=dl
    TRF Data Stop for NSA    ue_id=${UE_ID}    Bearer_ID=${Bearer_ID}    trf_id=3    dir=dl
    TRF Data Stop for NSA    ue_id=${UE_ID}    Bearer_ID=${Bearer_ID}    trf_id=4    dir=dl
    TRF Data Stop for NSA    ue_id=${UE_ID}    Bearer_ID=${Bearer_ID}    trf_id=5    dir=dl
    TRF Data Stop for NSA    ue_id=${UE_ID}    Bearer_ID=${Bearer_ID}    trf_id=6    dir=dl
    Trigger DL Traffic for NSA    ue_id=${UE_ID}    Traffic_rate=kbps     dl_rate=10       trf_id=1
    sleep   5s
    Trigger UL Traffic for NSA    ue_id=${UE_ID}    Traffic_rate=kbps     ul_rate=10       trf_id=1
    sleep   5s    reason=Wait for successful traffic start

Verify 8541 Counters incrementing
    Wait until the next Measurement Period starts
    ${PM_dir_1}=     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
    Validate PM Counters    PM_dir=${PM_dir_1}    PM_counter=${PM_PCELL_COUNTER3}    expected_value=1

    Wait until the next Measurement Period starts
    ${PM_dir_1}=     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
    Validate PM Counters    PM_dir=${PM_dir_1}    PM_counter=${PM_PCELL_COUNTER1}    expected_value=300
    Validate PM Counters     PM_dir=${PM_dir_1}    PM_counter=${PM_PCELL_COUNTER2}    expected_value=300
    Validate PM Counters bigger than     PM_dir=${PM_dir_1}    PM_counter=${PM_SCELL_COUNTER1}    expected_value=1000
    Validate PM Counters    PM_dir=${PM_dir_1}    PM_counter=${PM_SCELL_COUNTER2}    expected_value=1

Verify 8541 Counters decrementing
    Wait until the next Measurement Period starts
    Wait until the next Measurement Period starts
    ${PM_dir_1}=     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
    Validate PM Counters    PM_dir=${PM_dir_1}    PM_counter=${PM_PCELL_COUNTER1}    expected_value=300
    Validate PM Counters     PM_dir=${PM_dir_1}    PM_counter=${PM_PCELL_COUNTER2}    expected_value=0
    Validate PM Counters    PM_dir=${PM_dir_1}    PM_counter=${PM_PCELL_COUNTER3}    expected_value=0
    Validate PM Counters     PM_dir=${PM_dir_1}    PM_counter=${PM_SCELL_COUNTER1}    expected_value=0
    Validate PM Counters    PM_dir=${PM_dir_1}    PM_counter=${PM_SCELL_COUNTER2}    expected_value=0





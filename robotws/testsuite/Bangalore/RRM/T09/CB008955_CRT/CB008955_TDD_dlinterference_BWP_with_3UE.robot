*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...             CONFIGS_Bangalore/RRM/ET/CB008541/CB008541_5G_B_B002_1_APoverABIO.yml
...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS00     SBTS22R3    CONFIGURED

Documentation    :copyright: Nokia
...              :authors: Ganesha
...              :contact: Ganesha.u@nokia.com
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
Resource         resources/CB008955_BWP_Keywords.robot

Suite Setup         Run keywords    Run Keyword and Ignore Error      Suite setup from scratch
...                 AND     Check and active the BTS l2ps DBG log
...                 AND     Load CFG Config And Verify BWP-List During cell setup in Capture CPRT Traces      ${wts_cfg_file}
...                 AND     Check gNB Bulid

Suite Teardown      Run keywords  Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
...                 AND     Run Keyword and Ignore Error    Get Snapshot
...                 AND     Run Keyword and Ignore Error    Get Sos Report

Test Setup       Start_capture_testcase_default_logging
Test Teardown    Stop Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}

*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/basic_setup_intrafreq.cfg
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
${smallbwp_id}   2
${psbwp_id}     3
${epc_log_path}    /tmp/

*** Test Cases ***
[1]CB008541_5G_B_B002_1_Verify_SA_TDD_UE_supports_bandwidth_switching_of_LBWP_and_PSBWP_for_nonVoNR_UE
    [Documentation]   in this testcase verify that 5G NR powerSaving BWP cabable  UE configured with small BWP and
    ...         Power Saving BWP during UE context setup. in the beginning when successful DL/UL data transfer initiated
    ...         verify that data transfer happens in the powersaving BWP,

	${LOG_PATH}   Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
    Register UE and verify initial bwp through tti trace
    Start low DL data and verify psbwp through tti trace
    Run Keyword and Continue On Failure  Verify 8541 counters incrementing
    Start High DL data and verify smallbwp through ttitrace
    Run Keyword and Continue On Failure  Verify 8541 counters decrementing
	Stop Data Traffic for SA     ue_id=${UE_ID}
    UE Deregister should be Successful   ue_id=${UE_ID}

*** Keywords ***
Start_capture_testcase_default_logging
    ${TEST_NAME}      replace string   ${TEST_NAME}      ${SPACE}        _
    set suite variable      ${TEST_NAME}
    Start Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}

Register UE and verify initial bwp through tti trace
    log to console   UE attach trigerring now...
    Start Collecting Syslog     NAME=syslog_ue_attach
    Start CPRT Trace Capturing
    UE Register should be Successful     ${UE_ID}
    Sleep    10s
    Stop Collecting Syslog       NAME=syslog_ue_attach
    Run Keyword And Ignore Error     Stop CPRT capture   ${CaptureCPRT}
    Run Keyword And Ignore Error     Move File    ${LOG_PATH}/NODECPRT_GNB.pcap   ${LOG_PATH}/UE_attach_cprt.pcap
    ${bwpid}    Create List     ${psbwp_id}
    ${crnti_list}     Create List
    Capture TTI Traces and Validate UE bwpid    ${LOG_PATH}   initial   ${crnti_list}     ${bwpid}    ${Branch_22R1}

Start low DL data and verify psbwp through tti trace
    Start Collecting Syslog       NAME=lowdata
    Start CPRT Trace Capturing
    Start L2 BIP Trace Capturing
    Trigger DL Traffic for SA    ue_id=${UE_ID}    Traffic_rate=kbps     dl_rate=10       trf_id=${TRF_ID}      qfi_id=${QFI_ID}
    sleep   5s
    Trigger UL Traffic for SA    ue_id=${UE_ID}    Traffic_rate=kbps     ul_rate=10       trf_id=${TRF_ID2}      qfi_id=${QFI_ID}
    sleep   5s    reason=Wait for successful BWP switch
    Run Keyword And Ignore Error    Stop L1L2 capture  ${CaptureL1L2}
    Run Keyword And Ignore Error    Move File    ${LOG_PATH}/L1L2_GNB_FS_LO.pcap    ${LOG_PATH}/BIP_lowdata.pcap
    Run Keyword And Ignore Error     Stop CPRT capture   ${CaptureCPRT}
    Run Keyword And Ignore Error     Move File    ${LOG_PATH}/NODECPRT_GNB.pcap   ${LOG_PATH}/lowdata_cprt.pcap
    Stop Collecting Syslog       NAME=lowdata
    Validate DL Traffic For SA   ue_id=${UE_ID}     dl_rate=0.010     qfi_id=${QFI_ID}
    ${bwpid}    Create List     ${psbwp_id}
    ${crnti_list}     Create List
    Capture TTI Traces and Validate UE bwpid    ${LOG_PATH}    lowdata    ${crnti_list}     ${bwpid}    ${Branch_22R1}

Start High DL data and verify smallbwp through ttitrace
    Start Collecting Syslog       NAME=highdata
    Start CPRT Trace Capturing
    Start L2 BIP Trace Capturing
    Trigger DL Traffic for SA    ue_id=${UE_ID}    Traffic_rate=mbps     dl_rate=1      trf_id=${TRF_ID}      qfi_id=${QFI_ID}
    sleep   5s
    Trigger UL Traffic for SA    ue_id=${UE_ID}    Traffic_rate=mbps     ul_rate=1       trf_id=${TRF_ID2}      qfi_id=${QFI_ID}
    sleep   5s    reason=Wait for successful BWP switch
    Run Keyword And Ignore Error    Stop L1L2 capture  ${CaptureL1L2}
    Run Keyword And Ignore Error    Move File    ${LOG_PATH}/L1L2_GNB_FS_LO.pcap    ${LOG_PATH}/BIP_lowdata.pcap
    Run Keyword And Ignore Error     Stop CPRT capture   ${CaptureCPRT}
    Run Keyword And Ignore Error     Move File    ${LOG_PATH}/NODECPRT_GNB.pcap   ${LOG_PATH}/lowdata_cprt.pcap
    Stop Collecting Syslog       NAME=highdata
    Validate DL Traffic For SA   ue_id=${UE_ID}     dl_rate=1     qfi_id=${QFI_ID}
    ${bwpid}    Create List     ${smallbwp_id}
    ${crnti_list}     Create List
    Capture TTI Traces and Validate UE bwpid    ${LOG_PATH}    highdata    ${crnti_list}     ${bwpid}    ${Branch_22R1}


Verify 8541 counters incrementing
    Wait until the next Measurement Period starts
    Wait until the next Measurement Period starts
    ${PM_dir1}=     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
    Validate PM Counters    PM_dir=${PM_dir1}    PM_counter=M55351C01001    expected_value=1
    Validate PM Counters    PM_dir=${PM_dir1}    PM_counter=M55351C01002    expected_value=1
    Validate PM Counters    PM_dir=${PM_dir1}    PM_counter=M55351C00001    expected_value=1
    Validate PM Counters    PM_dir=${PM_dir1}    PM_counter=M55351C00002    expected_value=1
    Validate PM Counters bigger than    PM_dir=${PM_dir1}    PM_counter=M55308C28009    expected_value=200
    Validate PM Counters    PM_dir=${PM_dir1}    PM_counter=M55308C28010    expected_value=1
    Validate PM Counters bigger than    PM_dir=${PM_dir1}    PM_counter=M55308C28011    expected_value=200
    Validate PM Counters    PM_dir=${PM_dir1}    PM_counter=M55308C28012    expected_value=1
    Validate PM Counters bigger than    PM_dir=${PM_dir1}    PM_counter=M55308C29005    expected_value=200
    Validate PM Counters bigger than    PM_dir=${PM_dir1}    PM_counter=M55308C29006    expected_value=200

Verify 8541 counters decrementing
    Wait until the next Measurement Period starts
    Wait until the next Measurement Period starts
    ${PM_dir1}=     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
    Validate PM Counters    PM_dir=${PM_dir1}    PM_counter=M55351C01001    expected_value=1
    Validate PM Counters    PM_dir=${PM_dir1}    PM_counter=M55351C01002    expected_value=1
    Validate PM Counters    PM_dir=${PM_dir1}    PM_counter=M55351C00001    expected_value=0
    Validate PM Counters    PM_dir=${PM_dir1}    PM_counter=M55351C00002    expected_value=0
    Validate PM Counters    PM_dir=${PM_dir1}    PM_counter=M55308C28009    expected_value=0
    Validate PM Counters    PM_dir=${PM_dir1}    PM_counter=M55308C28010    expected_value=0
    Validate PM Counters    PM_dir=${PM_dir1}    PM_counter=M55308C28011    expected_value=0
    Validate PM Counters    PM_dir=${PM_dir1}    PM_counter=M55308C28012    expected_value=0
    Validate PM Counters    PM_dir=${PM_dir1}    PM_counter=M55308C29005    expected_value=0
    Validate PM Counters    PM_dir=${PM_dir1}    PM_counter=M55308C29006    expected_value=0

*** Settings ***
#Force Tags      CLOUD_5G_I_LO_AP_LO    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE
#...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS00     SBTS23R1   CONFIGURED

Documentation    :copyright: Nokia
...              :authors: Madhu,Sowrabha
...              :contact: madhusudhan.y@nokia.com,sowrabha.s_m@nokia.com
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

Resource         resources/CB008541_Keywords.robot
Resource         ../../../resources/robot/WTS_Runner_BF_CA_HO_Keywords.robot
Resource         ../../../resources/robot/common_log_collection.robot

*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/egate_TMOUS_Clubbing_B202_2_B201_1_B004_2.cfg
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}          /opt/iphy/latest
${UE_ID}        1
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${QFI_ID}    1
${TRF_ID}    1
${TRF_ID2}    2
${largebwp_id}     1
${smallbwp_id}     2
${psbwp_id}        3
${epc_log_path}    /tmp/
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
${AP_XML}   ${CURDIR}/config/CB008541_A_B201_1_iphy.xml


*** Keywords ***
Run CB008541_5G_B_B201_1_SA_TDD+FDD_UE_Scell_addition_successful_Scell_deactivate_when_UE_moves_to_PS_BWP_937_7552_8541-A_enabled
	${LOG_PATH}  Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
    Register UE and verify initial bwp through tti trace
    Start Big DL data and verify Scell activation and LBWP through tti trace
    Start Low DL data and verify Scell deactivation and PSBWP through tti trace
    Start 300 Mbps Big DL Data Transfer And Check SCell Activation for 2CC
    Stop Data Traffic for SA     ue_id=${UE_ID}
    UE Deregister should be Successful   ue_id=${UE_ID}
    log to console   Waiting for counter verification_Lowdata
    Verify Counters_B201_scelldeact    300    0    0    0    0

*** Keywords ***
Start_capture_testcase_default_logging
    ${TEST_NAME}=       replace string  ${TEST_NAME}      ${SPACE}        _
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
    Capture TTI Traces and Validate UE bwpid    ${LOG_PATH}   initial    ${crnti_list}     ${bwpid}    ${Branch_22R1}

Start Big DL data and verify Scell activation and LBWP through tti trace
    Start Collecting Syslog       NAME=scell_add
    Start CPRT Trace Capturing
    #Start L2 BIP Trace Capturing
    Start 700 Mbps Big DL Data Transfer And Check SCell Activation for 2CC
    Sleep    10s
    Trigger A1 Measurement and verify Scell added successfully    4    1    28875
    #Run Keyword And Ignore Error    Stop L1L2 capture  ${CaptureL1L2}
    Run Keyword And Ignore Error     Stop CPRT capture   ${CaptureCPRT}
    #Run Keyword And Ignore Error    Move File    ${LOG_PATH}/L1L2_GNB_FS_KL.pcap    ${LOG_PATH}/L1L2_GNB_FS_KL_Scell_activation_highdata.pcap
    Run Keyword And Ignore Error     Move File    ${LOG_PATH}/NODECPRT_GNB.pcap   ${LOG_PATH}/Scell_activation_highdata_cprt.pcap
    Stop Collecting Syslog       NAME=scell_add
    Sleep    10s
    Validate DL Traffic For SA for high data   ue_id=${UE_ID}     dl_rate=430     qfi_id=${QFI_ID}
    Run Keyword and continue on failure    Verify Counters_B201 M55139C04001     1
    Verify DL Tput For 2CC_T_F
    ${bwpid}    Create List     ${smallbwp_id}
    ${crnti_list}     Create List
    Capture TTI Traces and Validate UE bwpid    ${LOG_PATH}    highdata    ${crnti_list}     ${bwpid}    ${Branch_22R1}
    log to console   Waiting for counter verification_Highdata
    Verify Counters_B201    300    300     27000    1

Start Low DL data and verify Scell deactivation and PSBWP through tti trace
    Start Collecting Syslog       NAME=scell_deactivate
    Start CPRT Trace Capturing
    #Start L2 BIP Trace Capturing
    Start Low Data Traffic And Check Scell Deactivation
    Run Keyword And Continue on Failure    wtsrunner.read_wtsemu_output_until_prompt    timeout=10
    #Run Keyword And Ignore Error    Stop L1L2 capture  ${CaptureL1L2}
    Run Keyword And Ignore Error     Stop CPRT capture   ${CaptureCPRT}
    #Run Keyword And Ignore Error    Move File    ${LOG_PATH}/L1L2_GNB_FS_KL.pcap    ${LOG_PATH}/L1L2_GNB_FS_KL_Scell_deactivation_lowdata.pcap
    Run Keyword And Ignore Error     Move File    ${LOG_PATH}/NODECPRT_GNB.pcap   ${LOG_PATH}/Scell_deactivation_lowdata_cprt.pcap
    Stop Collecting Syslog       NAME=scell_deactivate
    Validate DL Traffic For SA for high data   ue_id=${UE_ID}     dl_rate=0.010     qfi_id=${QFI_ID}
    Verify Low Data Traffic
    ${bwpid}    Create List     ${psbwp_id}
    ${crnti_list}     Create List
    Capture TTI Traces and Validate UE bwpid    ${LOG_PATH}    lowdata    ${crnti_list}     ${bwpid}    ${Branch_22R1}
    Verify Counters_B201_PSBWP

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
Start 300 Mbps Big DL Data Transfer And Check SCell Activation for 2CC
    Trigger DL Data Traffic for SA    ue_id=${UE_ID}    Traffic_rate=mbps     dl_rate=150       trf_id=1
    sleep   5s
    Trigger DL Data Traffic for SA    ue_id=${UE_ID}    Traffic_rate=mbps     dl_rate=150       trf_id=2
    sleep   5s    reason=Wait for successful traffic start
    ${output2}   wtsrunner.read_wtsemu_output_until_re    expected=.*CellIndex.*  timeout=15
    Get Lines Matching Regexp    ${output2}    CellIndex \\d+ activated successfully  partial_match=${TRUE}
    sleep   5s
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
    sleep   30s    reason=Wait for successful traffic stop

Verify DL Tput For 2CC_T_F
    ${pcell_tput}=    Get AVG DL DATA TRAFFIC For Given CC    ue_id=${UE_ID}    scell_idx=0    unit=Mbps
    ${scell_tput}=    Get AVG DL DATA TRAFFIC For Given CC    ue_id=${UE_ID}    scell_idx=1    unit=Mbps
    Should Be True    ${pcell_tput} > ${275}
    Should Be True    ${scell_tput} > ${150}

Verify Counters_B201
    [Arguments]    ${EXPECTED_PCELL_VALUE1}    ${EXPECTED_PCELL_VALUE2}      ${EXPECTED_SCELL_VALUE1}    ${EXPECTED_SCELL_VALUE2}
    Wait until the next Measurement Period starts
    ${PM_dir_1}=     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
    Validate PM Counters_B201   PM_dir=${PM_dir_1}   PM_counter=${PM_PCELL_COUNTER1}   expected_value=${EXPECTED_PCELL_VALUE1}   moc=NRCELL-4
    Validate PM Counters_B201   PM_dir=${PM_dir_1}   PM_counter=${PM_PCELL_COUNTER2}   expected_value=${EXPECTED_PCELL_VALUE2}   moc=NRCELL-4
    Validate PM Counters bigger than_scell    PM_dir=${PM_dir_1}    PM_counter=${PM_SCELL_COUNTER1}    expected_value=${EXPECTED_SCELL_VALUE1}
    Validate PM Counters_B201   PM_dir=${PM_dir_1}   PM_counter=${PM_SCELL_COUNTER2}   expected_value=${EXPECTED_SCELL_VALUE2}   moc=NRCELL-8

Verify Counters_B201_scelldeact
    [Arguments]   ${EXPECTED_PCELL_VALUE1}  ${EXPECTED_PCELL_VALUE2}   ${EXPECTED_PCELL_VALUE3}   ${EXPECTED_SCELL_VALUE1}   ${EXPECTED_SCELL_VALUE2}
    Wait until the next Measurement Period starts
    Wait until the next Measurement Period starts
    Wait until the next Measurement Period starts
    ${PM_dir_1}=     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
    Validate PM Counters_B201   PM_dir=${PM_dir_1}   PM_counter=${PM_PCELL_COUNTER1}
    ...    expected_value=${EXPECTED_PCELL_VALUE1}   moc=NRCELL-4
    Validate PM Counters_B201   PM_dir=${PM_dir_1}
    ...    PM_counter=${PM_PCELL_COUNTER2}   expected_value=${EXPECTED_PCELL_VALUE2}   moc=NRCELL-4
    Validate PM Counters_B201    PM_dir=${PM_dir_1}
    ...    PM_counter=${PM_PCELL_COUNTER3}
    ...    expected_value=${EXPECTED_PCELL_VALUE3}    moc=NRCELL-4
    Validate PM Counters_B201   PM_dir=${PM_dir_1}
    ...    PM_counter=${PM_SCELL_COUNTER1}   expected_value=${EXPECTED_SCELL_VALUE1}   moc=NRCELL-8
    Validate PM Counters_B201   PM_dir=${PM_dir_1}   PM_counter=${PM_SCELL_COUNTER2}
    ...    expected_value=${EXPECTED_SCELL_VALUE2}   moc=NRCELL-8

Validate PM Counters_B201
    [Arguments]    ${PM_dir}     ${PM_counter}    ${expected_value}    ${moc}
    PM_Counters.Check PM counter value equal    expected_value=${expected_value}   pm_files_location=${PM_dir}
    ...  pi_id=${PM_counter}    moc=${moc}

Validate PM Counters bigger than_scell
    [Arguments]    ${PM_dir}     ${PM_counter}    ${expected_value}
    PM_Counters.Check PM counter value bigger than    expected_value=${expected_value}   pm_files_location=${PM_dir}
    ...  pi_id=${PM_counter}    moc=NRCELL-8

Verify Counters_B201 M55139C04001
    [Arguments]     ${EXPECTED_PCELL_VALUE3}
    Wait until the next Measurement Period starts
    ${PM_dir_1}=     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
    Validate PM Counters_B201    PM_dir=${PM_dir_1}    PM_counter=${PM_PCELL_COUNTER3}
    ...     expected_value=${EXPECTED_PCELL_VALUE3}    moc=NRCELL-4

Verify Counters_B201_PSBWP
    Wait until the next Measurement Period starts
    Wait until the next Measurement Period starts
    Wait until the next Measurement Period starts
    ${PM_dir_1}=     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
    Validate PM Counters bigger than    PM_dir=${PM_dir1}    PM_counter=M55308C28009    expected_value=10000
    Validate PM Counters    PM_dir=${PM_dir1}    PM_counter=M55308C28010    expected_value=1
    Validate PM Counters bigger than    PM_dir=${PM_dir1}    PM_counter=M55308C28011    expected_value=7000
    Validate PM Counters    PM_dir=${PM_dir1}    PM_counter=M55308C28012    expected_value=1
    Validate PM Counters bigger than    PM_dir=${PM_dir1}    PM_counter=M55308C29005    expected_value=50000
    Validate PM Counters bigger than    PM_dir=${PM_dir1}    PM_counter=M55308C29006    expected_value=30000

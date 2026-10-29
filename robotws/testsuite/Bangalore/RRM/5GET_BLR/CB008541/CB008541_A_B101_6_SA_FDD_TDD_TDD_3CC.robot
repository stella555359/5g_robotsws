*** Settings ***
#Force Tags      CLOUD_5G_I_LO_AP_LO      VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE
#...             CRT    RAN_5G    5G_RAN     SBTS00     CONFIGURED


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
Resource         resources/CB008541_Keywords.robot


*** Variables ***
#${wts_cfg_file}     /opt/iphy/latest/basic_setup_3CC.cfg
${wts_cfg_file}     ${CURDIR}/config/basic_setup_3CC.cfg
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
${PM_PCELL_COUNTER1}    M55167C00001
${PM_PCELL_COUNTER2}    M55167C00002
${PM_PCELL_COUNTER3}    M55139C04001
${PM_SCELL_COUNTER1}    M55308C28001
${PM_SCELL_COUNTER2}    M55308C28002
${EXPECTED_PCELL_VALUE1}
${EXPECTED_PCELL_VALUE2}
${EXPECTED_PCELL_VALUE3}
${EXPECTED_SCELL_VALUE1}
${EXPECTED_SCELL_VALUE2}


*** Keywords ***
CB008541_A_B101_6_SA_UEsupporting_Pcell_SBWP_SCellA_SBWP_SCellB_SBWP_for_FDD_TDD_TDD_3CC_CA
    Regiter UE And Verify Scell Addition On High Data Traffic
    Verify Scell Deactivation On Low Data Traffic A_B101_6

Regiter UE And Verify Scell Addition On High Data Traffic
    Run Keyword and Ignore Error    Start Collecting Syslog     NAME=scell_add
    Start CPRT Trace Capturing
#    Start L2 BIP Trace Capturing
    log to console    Triggering UE attach...
    UE Register should be Successful     ue_id=${UE_ID}
    Start 700 Mbps Big DL Data Transfer And Check SCell Activation for 3CC
    sleep   20s
#    Stop L1L2 capture  ${CaptureL1L2}
    Stop CPRT capture   ${CaptureCPRT}
    Verify Counters_3CC M55139C04001     1
    Move File    ${LOG_PATH}/NODECPRT_GNB.pcap    ${LOG_PATH}/NODECPRT_GNB_scell_add.pcap
#    Run Keyword and Ignore Error    Move File    ${LOG_PATH}/L1L2_GNB_L1B_BO.pcap    ${LOG_PATH}/BIP_scell_add.pcap
    Validate DL Traffic For SA for high data   ue_id=${UE_ID}     dl_rate=680     qfi_id=${QFI_ID}
    CB008541_Keywords.Verify DL Tput For 3CC
	Stop Collecting Syslog       NAME=scell_add
    log to console    Collecting PM counter...
    Verify Counters_3CC    300    300     380000    1

Verify Scell Deactivation On Low Data Traffic A_B101_6
    Run Keyword and Ignore Error    Start Collecting Syslog     NAME=scell_remove
    Start CPRT Trace Capturing
#    Start L2 BIP Trace Capturing
    Start Low Data Traffic And Check Scell Deactivation A_B101_6
    sleep    30s
	Verify Low Data Traffic
    Stop CPRT capture   ${CaptureCPRT}
#    Stop L1L2 capture  ${CaptureL1L2}
    Move File    ${LOG_PATH}/NODECPRT_GNB.pcap    ${LOG_PATH}/NODECPRT_GNB_scell_remove.pcap
	Validate DL Traffic For SA for high data    ue_id=${UE_ID}     dl_rate=0.010     qfi_id=${QFI_ID}
    Validate UL Traffic For SA   ue_id=${UE_ID}     ul_rate=0.010     qfi_id=${QFI_ID}
	Stop Data Traffic for SA     ue_id=${UE_ID}
    UE Deregister should be Successful   ue_id=${UE_ID}
    Stop Collecting Syslog       NAME=scell_remove
    log to console    Collecting PM counter...
    Verify Counters_scelldeact_3CC A_B101_6     300    0    0    0    0

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
    sleep   10s    reason=Wait for successful traffic start


Start Low Data Traffic And Check Scell Deactivation A_B101_6
    Trigger DL Traffic for SA    ue_id=${UE_ID}    Traffic_rate=kbps     dl_rate=10       trf_id=7      qfi_id=${QFI_ID}
    sleep   5s
    Trigger UL Traffic for SA    ue_id=${UE_ID}    Traffic_rate=kbps     ul_rate=10       trf_id=7      qfi_id=${QFI_ID}
    sleep   5s    reason=Wait for successful traffic start
    TRF Data Stop for SA    ue_id=${UE_ID}    trf_id=1    dir=dl     pdu_id=${Pdu_session_ID}
    TRF Data Stop for SA    ue_id=${UE_ID}    trf_id=2    dir=dl     pdu_id=${Pdu_session_ID}
    TRF Data Stop for SA    ue_id=${UE_ID}    trf_id=3    dir=dl     pdu_id=${Pdu_session_ID}
    TRF Data Stop for SA    ue_id=${UE_ID}    trf_id=4    dir=dl     pdu_id=${Pdu_session_ID}
    TRF Data Stop for SA    ue_id=${UE_ID}    trf_id=5    dir=dl     pdu_id=${Pdu_session_ID}
    sleep   5s    reason=Wait for successful traffic start

Verify Counters_3CC
    [Arguments]    ${EXPECTED_PCELL_VALUE1}    ${EXPECTED_PCELL_VALUE2}      ${EXPECTED_SCELL_VALUE1}    ${EXPECTED_SCELL_VALUE2}
    Wait until the next Measurement Period starts
    ${PM_dir_1}=     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
    Validate PM Counters_3CC   PM_dir=${PM_dir_1}   PM_counter=${PM_PCELL_COUNTER1}   expected_value=${EXPECTED_PCELL_VALUE1}   moc=NRCELL-3
    Validate PM Counters_3CC   PM_dir=${PM_dir_1}   PM_counter=${PM_PCELL_COUNTER2}   expected_value=${EXPECTED_PCELL_VALUE2}   moc=NRCELL-3
    Validate PM Counters bigger thanvalue    PM_dir=${PM_dir_1}    PM_counter=${PM_SCELL_COUNTER1}    expected_value=${EXPECTED_SCELL_VALUE1}
    Validate PM Counters_3CC   PM_dir=${PM_dir_1}   PM_counter=${PM_SCELL_COUNTER2}   expected_value=${EXPECTED_SCELL_VALUE2}   moc=NRCELL-1
    Validate PM Counters_3CC   PM_dir=${PM_dir_1}   PM_counter=${PM_SCELL_COUNTER2}   expected_value=${EXPECTED_SCELL_VALUE2}   moc=NRCELL-2
Validate PM Counters_3CC
    [Arguments]    ${PM_dir}     ${PM_counter}    ${expected_value}    ${moc}
    PM_Counters.Check PM counter value equal    expected_value=${expected_value}   pm_files_location=${PM_dir}
    ...  pi_id=${PM_counter}    moc=${moc}
Validate PM Counters bigger thanvalue
    [Arguments]    ${PM_dir}     ${PM_counter}    ${expected_value}
    PM_Counters.Check PM counter value bigger than    expected_value=${expected_value}   pm_files_location=${PM_dir}
    ...  pi_id=${PM_counter}    moc=NRCELL-1
    PM_Counters.Check PM counter value bigger than    expected_value=${expected_value}   pm_files_location=${PM_dir}
    ...  pi_id=${PM_counter}    moc=NRCELL-2
Verify Counters_3CC M55139C04001
    [Arguments]     ${EXPECTED_PCELL_VALUE3}
    Wait until the next Measurement Period starts
    ${PM_dir_1}=     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
    Validate PM Counters_3CC    PM_dir=${PM_dir_1}    PM_counter=${PM_PCELL_COUNTER3}
    ...     expected_value=${EXPECTED_PCELL_VALUE3}    moc=NRCELL-3
Verify Counters_scelldeact_3CC A_B101_6
    [Arguments]   ${EXPECTED_PCELL_VALUE1}  ${EXPECTED_PCELL_VALUE2}   ${EXPECTED_PCELL_VALUE3}   ${EXPECTED_SCELL_VALUE1}   ${EXPECTED_SCELL_VALUE2}
    Wait until the next Measurement Period starts
    Wait until the next Measurement Period starts
    Wait until the next Measurement Period starts
    ${PM_dir_1}=     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
    Validate PM Counters_3CC   PM_dir=${PM_dir_1}   PM_counter=${PM_PCELL_COUNTER1}   expected_value=${EXPECTED_PCELL_VALUE1}   moc=NRCELL-3
    Validate PM Counters_3CC   PM_dir=${PM_dir_1}   PM_counter=${PM_PCELL_COUNTER2}   expected_value=${EXPECTED_PCELL_VALUE2}   moc=NRCELL-3
    Validate PM Counters_3CC    PM_dir=${PM_dir_1}    PM_counter=${PM_PCELL_COUNTER3}
    ...     expected_value=${EXPECTED_PCELL_VALUE3}    moc=NRCELL-3
    Validate PM Counters_3CC   PM_dir=${PM_dir_1}   PM_counter=${PM_SCELL_COUNTER1}   expected_value=${EXPECTED_SCELL_VALUE1}   moc=NRCELL-1
    Validate PM Counters_3CC   PM_dir=${PM_dir_1}   PM_counter=${PM_SCELL_COUNTER2}   expected_value=${EXPECTED_SCELL_VALUE2}   moc=NRCELL-1
    Validate PM Counters_3CC   PM_dir=${PM_dir_1}   PM_counter=${PM_SCELL_COUNTER1}   expected_value=${EXPECTED_SCELL_VALUE1}   moc=NRCELL-2
    Validate PM Counters_3CC   PM_dir=${PM_dir_1}   PM_counter=${PM_SCELL_COUNTER2}   expected_value=${EXPECTED_SCELL_VALUE2}   moc=NRCELL-2
Verify DL Tput For3CC
    ${pcell_tput}=    Get AVG DL DATA TRAFFIC For Given CC    ue_id=${UE_ID}    scell_idx=0    unit=Mbps
    ${scell_tput}=    Get AVG DL DATA TRAFFIC For Given CC    ue_id=${UE_ID}    scell_idx=1    unit=Mbps
    ${scell_tput1}=    Get AVG DL DATA TRAFFIC For Given CC    ue_id=${UE_ID}    scell_idx=2    unit=Mbps
    Should Be True    ${pcell_tput} > ${130}
    Should Be True    ${scell_tput} > ${200}
    Should Be True    ${scell_tput1} > ${310}

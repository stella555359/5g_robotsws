*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO   CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS00    CONFIGURED

Documentation    :copyright: Nokia
...              :authors: Madhu
...                        Lavanya P
...              :contact: mohanavel.p@nokia.com/ madhusudhan.y@nokia.com
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
...         The use case is verified with CB006878 enable and verify the pCSI, SR, HARQ A/N resource allocation
...             TESTING SPLIT:     See CB0076878 testplan
...             CONTACTS:          I_MN_RAN_L2_5G_BLR_ET_ALL_GMS <I_MN_RAN_L2_5G_BLR_ET_ALL@internal.nsn.com>
...             REFERENCES:        CB006878 CFAM
...             Requirement ID:     5G_RAN_USR_RRM_16315

Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
#Resource         ./../CB008541/resources/CB008541_Keywords.robot
Resource         resources/CB006878_Keywords.robot
Resource         ../resources/robot/WTS_Runner_Keywords.robot
Resource         ../resources/robot/WTS_Runner_BF_CA_HO_Keywords.robot
Resource         ../resources/robot/PM_Counters.robot
Library          ../resources/python/avg_dl_data.py
Resource         ../resources/robot/configuration_id.robot

Suite Setup         Run keywords    Run Keyword and Ignore Error      Suite setup from scratch
...                 AND     Check and active the BTS l2ps DBG log
...                 AND    Modify IPHY File And Send to Airphone Custom    ${IPHY_FILE}
...                 AND    Find Scfc And Fix And Send Full Commissioning
...                           scfc_filename=CB006878_B_1_04_CA_T_T_SA_SCF.xml
...                 AND    Start Default Logging    output_dirpath=${LOG_PATH}
...                 AND    Load CFG Config And Verify BWP-List During cell setup in Capture CPRT Traces   ${wts_cfg_file}   ${no_of_cells}
...                 AND     Check gNB Bulid

Suite Teardown      Run Keywords     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
...                 AND     Run Keyword and Ignore Error    Get Snapshot

Test Teardown    Stop Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}

*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/basic_setup_CA_SA_RRE.cfg
${IPHY_FILE}                    ${CURDIR}/config/CB006878_B_1_04_CA_T_T_SA_iphy.xml
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}          /opt/iphy/latest
${UE_ID}        5
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
${no_of_cells}   2


*** Test Cases ***
#[1]CB008541_A_B301_4_SA_UEsupporting_Pcell_LBWP_SCell_SBWP_UEReestablish_for_TDD_TDD_2CC_CA
CB006878_B#1_04_LongPucch_SA_multiBWP_PSBWP_and_largeBWP_switching_with_CA_T_T_2CC_1UE_eCPRI
    [Documentation]  CB008541_A_B201_4_SA_UEsupporting_Pcell_LBWP_SCell_SBWP_UEReestablish_for_TDD_FDD_2CC_CA

    ${LOG_PATH}  Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
    Regiter UE And Verify Scell Addition On High Data Traffic
    Verify RRC Reestablishment is Successfull
    Run keyword and continue on failure     Verify Counters incrementing RRE     300    200    1     25000    1
    Verify Scell Deactivation On Low Data Traffic
    Run keyword and continue on failure     Verify Counters decrementing RRE    300     0    0     0     0
    [Teardown]    Link SCOUT SCF to Configuration ID for Reporting

*** Keywords ***
Regiter UE And Verify Scell Addition On High Data Traffic
#   Run Keyword and Ignore Error    Start Collecting Syslog     NAME=scell_add
#   Start CPRT Trace Capturing
#   Start L2 BIP Trace Capturing
    UE Register should be Successful     ue_id=${UE_ID}
    Start 700 Mbps Big DL Data Transfer And Check SCell Activation for 2CC
    Get Configured Measurements of UE${UE_ID}
    Trigger A1 Measurement and verify Scell added successfully    5    1    31624
    Trigger UL Data Traffic for SA    ue_id=${UE_ID}    Traffic_rate=mbps     ul_rate=110       trf_id=1
    sleep   5s
	Run Keyword And Continue on Failure    Validate DL Traffic For SA for high data   ue_id=${UE_ID}     dl_rate=650       qfi_id=${QFI_ID}
	Run Keyword And Continue on Failure    Verify DL Tput For 2CC T_F
#   Stop L1L2 capture  ${CaptureL1L2}
#   Stop CPRT capture   ${CaptureCPRT}
#   Stop Collecting Syslog       NAME=scell_add
#   Run Keyword And Ignore Error   Move File    ${LOG_PATH}/NODECPRT_GNB.pcap    ${LOG_PATH}/NODECPRT_GNB_scell_add.pcap
#   Run Keyword And Ignore Error   Move File    ${LOG_PATH}/L1L2_GNB_FS_LO.pcap    ${LOG_PATH}/BIP_scell_add.pcap

Verify DL Tput For 2CC T_F
    ${pcell_tput}=    Get AVG DL DATA TRAFFIC For Given CC    ue_id=${UE_ID}    scell_idx=0    unit=Mbps
    ${scell_tput}=    Get AVG DL DATA TRAFFIC For Given CC    ue_id=${UE_ID}    scell_idx=1    unit=Mbps
    Should Be True    ${pcell_tput} > ${140}
    Should Be True    ${scell_tput} > ${140}

Verify RRC Reestablishment is Successfull
    Wait until the next Measurement Period starts
#   Run Keyword and Ignore Error    Start Collecting Syslog     NAME=rrc_reestablish
#   Start CPRT Trace Capturing
#   Start L2 BIP Trace Capturing
    Trigger RRC Reestablishment   ue_id=${UE_ID}
    Get Configured Measurements of UE${UE_ID}
    Trigger A1 Measurement and verify Scell added successfully    5    2    31624
#   Stop L1L2 capture  ${CaptureL1L2}
#   Stop CPRT capture   ${CaptureCPRT}
#   Stop Collecting Syslog       NAME=rrc_reestablish
#   Run Keyword And Ignore Error   Move File    ${LOG_PATH}/NODECPRT_GNB.pcap    ${LOG_PATH}/NODECPRT_GNB_scell_add.pcap
#   Run Keyword And Ignore Error   Move File    ${LOG_PATH}/L1L2_GNB_FS_LO.pcap    ${LOG_PATH}/BIP_scell_add.pcap

Verify Scell Deactivation On Low Data Traffic
#   Run Keyword and Ignore Error    Start Collecting Syslog     NAME=scell_remove
#   Start CPRT Trace Capturing
#   Start L2 BIP Trace Capturing
    Start Low Data Traffic And Check Scell Deactivation
    Run Keyword And Continue on Failure    wtsrunner.read_wtsemu_output_until_prompt    timeout=10
    sleep     60s
# 	Stop CPRT capture   ${CaptureCPRT}
#   Stop L1L2 capture   ${CaptureL1L2}
#   Stop Collecting Syslog       NAME=scell_remove
#   Run Keyword And Ignore Error   Move File    ${LOG_PATH}/NODECPRT_GNB.pcap    ${LOG_PATH}/NODECPRT_GNB_scell_remove.pcap
#   Run Keyword And Ignore Error   Move File    ${LOG_PATH}/L1L2_GNB_FS_LO.pcap    ${LOG_PATH}/BIP_scell_add.pcap
	Run Keyword And Continue on Failure     Validate DL Traffic For SA for high data   ue_id=${UE_ID}     dl_rate=0.010     qfi_id=${QFI_ID}
    UE Deregister should be Successful   ue_id=${UE_ID}

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

Verify Counters incrementing RRE
    [arguments]     ${EXP_PCELL_VALUE1}      ${EXP_PCELL_VALUE2}     ${EXP_PCELL_VALUE3}      ${EXP_SCELL_VALUE1}     ${EXP_SCELL_VALUE2}
    Wait until the next Measurement Period starts
    ${PM_dir_1}=     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
    Run Keyword And Continue on Failure    Validate PM Counters T_F    PM_dir=${PM_dir_1}    PM_counter=${PM_PCELL_COUNTER1}
    ...   	expected_value=${EXP_PCELL_VALUE1}   moc=NRCELL-1
    Run Keyword And Continue on Failure    Validate PM Counters bigger than T_F    PM_dir=${PM_dir_1}    PM_counter=${PM_PCELL_COUNTER2}
    ...     expected_value=${EXP_PCELL_VALUE2}   moc=NRCELL-1
    Run Keyword And Continue on Failure    Validate PM Counters T_F    PM_dir=${PM_dir_1}    PM_counter=${PM_PCELL_COUNTER3}
    ...   	expected_value=${EXP_PCELL_VALUE3}   moc=NRCELL-1
    ${PM_dir_2}=     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
    Run Keyword And Continue on Failure    Validate PM Counters bigger than T_F    PM_dir=${PM_dir_2}    PM_counter=${PM_SCELL_COUNTER1}
    ...   	expected_value=${EXP_SCELL_VALUE1}   moc=NRCELL-2
    Run Keyword And Continue on Failure    Validate PM Counters T_F    PM_dir=${PM_dir_2}    PM_counter=${PM_SCELL_COUNTER2}
    ...  	expected_value=${EXP_SCELL_VALUE2}  moc=NRCELL-2

Verify Counters decrementing RRE
    [arguments]     ${EXP_PCELL_VALUE1}      ${EXP_PCELL_VALUE2}     ${EXP_PCELL_VALUE3}      ${EXP_SCELL_VALUE1}     ${EXP_SCELL_VALUE2}
    Wait until the next Measurement Period starts
    Wait until the next Measurement Period starts
    ${PM_dir_1}=     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
    Run Keyword And Continue on Failure    Validate PM Counters T_F    PM_dir=${PM_dir_1}    PM_counter=${PM_PCELL_COUNTER1}
    ... 	expected_value=${EXP_PCELL_VALUE1}   moc=NRCELL-1
    Run Keyword And Continue on Failure    Validate PM Counters T_F    PM_dir=${PM_dir_1}    PM_counter=${PM_PCELL_COUNTER2}
    ...  	expected_value=${EXP_PCELL_VALUE2}  moc=NRCELL-1
    Run Keyword And Continue on Failure    Validate PM Counters T_F    PM_dir=${PM_dir_1}    PM_counter=${PM_PCELL_COUNTER3}
    ...  	expected_value=${EXP_PCELL_VALUE3}   moc=NRCELL-1
    ${PM_dir_2}=     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
    Run Keyword And Continue on Failure    Validate PM Counters T_F     PM_dir=${PM_dir_2}    PM_counter=${PM_SCELL_COUNTER1}
    ...  	expected_value=${EXP_SCELL_VALUE1}   moc=NRCELL-2
    Run Keyword And Continue on Failure    Validate PM Counters T_F    PM_dir=${PM_dir_2}    PM_counter=${PM_SCELL_COUNTER2}
    ...  	expected_value=${EXP_SCELL_VALUE2}    moc=NRCELL-2

Validate PM Counters T_F
    [Arguments]    ${PM_dir}     ${PM_counter}    ${expected_value}   ${moc}
    PM_Counters.Check PM counter value equal    expected_value=${expected_value}   pm_files_location=${PM_dir}
    ...  pi_id=${PM_counter}    moc=${moc}

Validate PM Counters bigger than T_F
    [Arguments]    ${PM_dir}     ${PM_counter}    ${expected_value}   ${moc}
    PM_Counters.Check PM counter value bigger than    expected_value=${expected_value}   pm_files_location=${PM_dir}
    ...  pi_id=${PM_counter}    moc=${moc}

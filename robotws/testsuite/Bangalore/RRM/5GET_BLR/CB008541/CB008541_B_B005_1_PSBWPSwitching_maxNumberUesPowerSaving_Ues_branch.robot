*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO     VARIANT_SANSA_FS_ECPRI_CMWV_TDD
#...             CONFIGS_Bangalore/RRM/ET/CB008541/8541_B_B005_psbwp_multiUE.yml
...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS00     CONFIGURED

Documentation    :copyright: Nokia
...              :authors: Sowrabha
...              :contact: sowrabha.s_m@nokia.com
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
...         This feature CB008541-B user scenario describes the common gNB behavior with regards to UE context setup when
...         UE supporting large BWP with active 5GC000937 UE Power Saving: Dynamic BWP Adaptation feature for
...         NonVONR_PS_BWP_switching_allowed_only_upto_maxNumberUesPowerSaving_UEs
...         2 dedicated BWP profiles linked to the PCell
...         large BWP with bandwidth equal to the cell bandwidth
...         small BWP with bandwidth equal or higher than half of the cell bandwidth and lower than the large BWP
...         "small" and "large" BWP profiles have configured different PDCCH setings for User Specific search space and have different coreset.
...         1 power saving BWP profile linked to the PCell with bandwidth smaller than small BWP
...         "small", "large" and "power saving" BWP profiles have configured different PDCCH setings for User Specific search space
...         and have different coreset.
...         As part of PR675869 we have modified the carrier bandwidth size to 40Mhz, LBWP is 40Mhz, SBWP is 30Mhz and PSBWP is 20Mhz.
...         The UE-capabilities also have been modified accordingly.


Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Library          Collections
Resource         resources/CB008541_Keywords.robot
Resource         ../resources/robot/PM_Counters.robot
Resource         ../resources/robot/common_log_collection.robot
Library          taf.sw.scout    WITH NAME     scout

Suite Setup         Run keywords     Prepare TL with all config files
...                 AND     Run Keyword and Ignore Error      Suite setup from scratch
...                 AND     Update GSCN in AP Iphy Xml     gscn=7874
...                 AND     Check and active the BTS l2ps DBG log
...                 AND     Load CFG Config And Verify BWP-List During cell setup in Capture CPRT Traces      ${wts_cfg_file}
...                 AND     Check gNB Bulid


Suite Teardown    Run Keywords     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
...                 AND     Run Keyword and Ignore Error    Get Snapshot
...                 AND     Run Keyword and Ignore Error    Get Sos Report
#...                 AND     Run Keyword and Ignore Error    Stop Default Processes And Gather Logs And Compress Logs

#Suite Teardown    Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner

Test Setup         Start_capture_testcase_default_logging
Test Teardown       Link SCOUT SCF to Configuration ID for Reporting



*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/basic_setup_b005.cfg
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}          /opt/iphy/latest
${UE_ID}        3
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${QFI_ID}    1
${TRF_ID}    1
${TRF_ID2}    2
${TRF_ID3}    3
${TRF_ID4}    4
${epc_log_path}    /tmp/
${largebwp_id}     1
${smallbwp_id}     2
${psbwp_id}        3
${PM_dir1}
${PM_dir2}
${counter_value_cell1}
${SCFC}=                   Bangalore/RRM/ET/CB008541/8541_B_B005_psbwp_multiUE_40_30_20_scfc.xml
${AP_XML}=                 Bangalore/RRM/ET/CB008541/8541_B_B005_psbwp_multiUE_iphy.xml
${Large_UE_Counter}     M55308C28006
${Small_UE_Counter}     M55308C28002

*** Test Cases ***
[1]CB008541_5G_B_B101_1_Verify_NonVONR_PS_BWP_switching_allowed_only_upto_maxNumberUesPowerSaving_Ues_7552_937_enabled
    [Documentation]
    Register 4 nonVONR UEs and send low data and verify the psbwp through tti trace
    Deregister one nonVONR UE1 which is in PSBWP and verify UE4 enters to PSBWP through tti trace
	Attach new nonVONR UE5 and send low data and verify lbwp through tti trace
	Increase the data of UE2 which is in PSBWP and verify UE5 enters to PSBWP through tti trace
    Run Keyword and Continue On Failure  	Verify 8541 counters incrementing
	Increase the data of all UE and verify moved to dedicated BWP through tti trace
	Run Keyword and Continue On Failure     Verify 8541 counters decrementing
    Deregister all Ues
	Resgister LargeUe and Verify SSB and TRS PDSCH counters
	Resgister SmallUe and Verify SSB and TRS PDSCH counters

*** Keywords ***
Register 4 nonVONR UEs and send low data and verify the psbwp through tti trace
    ${LOG_PATH}  Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
    Run Keyword and Ignore Error    Start Collecting Syslog     NAME=lowdata_4UE
    Start CPRT Trace Capturing
    Start L2 BIP Trace Capturing
    ${NonVONR_UEs_crnti}=    MultiUE Register should be Successful    1  3
	set test variable      ${NonVONR_UEs_crnti}
    ${NonVONR_UEs123_crnti}=   Create List     ${NonVONR_UEs_crnti[0]}    ${NonVONR_UEs_crnti[1]}    ${NonVONR_UEs_crnti[2]}
    ${NonVONR_UEs1_crnti}=   Create List     ${NonVONR_UEs_crnti[0]}
    ${NonVONR_UEs2_crnti}=   Create List     ${NonVONR_UEs_crnti[1]}
    ${NonVONR_UE3_crnti}=   Create List     ${NonVONR_UEs_crnti[2]}
    set test variable      ${NonVONR_UEs123_crnti}
    set test variable      ${NonVONR_UEs2_crnti}
    set test variable      ${NonVONR_UE3_crnti}
    set test variable      ${NonVONR_UEs1_crnti}
    MultiUE Trigger DL Traffic for SA    1    3    Traffic_rate=kbps     dl_rate=15      trf_id=${TRF_ID}
    MultiUE Trigger UL Traffic for SA    1    3    Traffic_rate=kbps     ul_rate=15      trf_id=${TRF_ID}
    ${bwpid}    Create List     ${psbwp_id}    ${psbwp_id}    ${psbwp_id}
    Capture TTI Traces and Validate UE bwpid    ${LOG_PATH}    lowdata_3UE    ${NonVONR_UEs123_crnti}    ${bwpid}    ${Branch_22R1}
    ${crnti_value_UE4}=   UE Register should be Successful And Fetch RNTI    4    1    1    4
    Set test variable     ${crnti_value_UE4}
    Trigger DL Traffic for SA    4    Traffic_rate=kbps     dl_rate=15    pdu_id=1    trf_id=1       qfi_id=1
    Trigger UL Traffic for SA    4    Traffic_rate=kbps     ul_rate=15    pdu_id=1    trf_id=1       qfi_id=1
    Stop L1L2 capture  ${CaptureL1L2}
    Stop CPRT capture   ${CaptureCPRT}
    Move File    ${LOG_PATH}/NODECPRT_GNB.pcap    ${LOG_PATH}/NODECPRT_GNB_low_data.pcap
    Run Keyword and Ignore Error    Move File    ${LOG_PATH}/L1L2_GNB_FS_LO.pcap    ${LOG_PATH}/BIP_low_data.pcap
    Run Keyword and Ignore Error    Stop Collecting Syslog       NAME=lowdata_4UE
    Validate DL Traffic For MultiUE for SA    1   4     dl_rate=0.015
    Validate UL Traffic For MultiUE for SA    1   4     ul_rate=0.015
	${bwpid}    Create List     ${smallbwp_id}
	${crnti_UE4}    Create List     ${crnti_value_UE4}
	set test variable     ${crnti_UE4}
    Capture TTI Traces and Validate UE bwpid    ${LOG_PATH}    lowdata_4UE    ${crnti_UE4}    ${bwpid}    ${Branch_22R1}

Attach new nonVONR UE5 and send low data and verify lbwp through tti trace
    Run Keyword and Ignore Error    Start Collecting Syslog     NAME=Attach_UE5
    Start CPRT Trace Capturing
    Start L2 BIP Trace Capturing
    ${crnti_value_UE5}=   UE Register should be Successful And Fetch RNTI    5    1    1    5
    Set test variable     ${crnti_value_UE5}
    Trigger DL Traffic for SA    5    Traffic_rate=kbps     dl_rate=15    pdu_id=1    trf_id=1       qfi_id=1
    Trigger UL Traffic for SA    5    Traffic_rate=kbps     ul_rate=15    pdu_id=1    trf_id=1       qfi_id=1
    Stop L1L2 capture  ${CaptureL1L2}
    Stop CPRT capture   ${CaptureCPRT}
    Move File    ${LOG_PATH}/NODECPRT_GNB.pcap    ${LOG_PATH}/NODECPRT_GNB_UE5.pcap
    Run Keyword and Ignore Error    Move File    ${LOG_PATH}/L1L2_GNB_FS_LO.pcap    ${LOG_PATH}/BIP_UE5.pcap
    Run Keyword and Ignore Error    Stop Collecting Syslog     NAME=Attach_UE5
    Validate DL Traffic For SA   ue_id=5     dl_rate=0.015     qfi_id=${QFI_ID}
    Validate UL Traffic For SA   ue_id=5     ul_rate=0.015     qfi_id=${QFI_ID}
	${bwpid}    Create List    ${largebwp_id}
	${crnti_UE5}    Create List    ${crnti_value_UE5}
    Capture TTI Traces and Validate UE bwpid    ${LOG_PATH}    new_UE5   ${crnti_UE5}     ${bwpid}    ${Branch_22R1}

Deregister one nonVONR UE1 which is in PSBWP and verify UE4 enters to PSBWP through tti trace
    Run Keyword and Ignore Error    Start Collecting Syslog     NAME=deregister_UE1
    Start CPRT Trace Capturing
    Start L2 BIP Trace Capturing
    UE Deregister should be Successful   ue_id=1
    Stop L1L2 capture  ${CaptureL1L2}
    Stop CPRT capture   ${CaptureCPRT}
    Move File    ${LOG_PATH}/NODECPRT_GNB.pcap    ${LOG_PATH}/NODECPRT_GNB_deregister_UE1.pcap
    Run Keyword and Ignore Error    Move File    ${LOG_PATH}/L1L2_GNB_FS_LO.pcap    ${LOG_PATH}/BIP_deregister_UE1.pcap
    Sleep   60s
    Run Keyword and Ignore Error    Stop Collecting Syslog     NAME=highdata_lbwp
    Validate DL Traffic For SA   ue_id=4     dl_rate=0.015     qfi_id=${QFI_ID}
    Validate UL Traffic For SA   ue_id=4     ul_rate=0.015     qfi_id=${QFI_ID}
	${bwpid}    Create List    ${psbwp_id}
    Capture TTI Traces and Validate UE bwpid    ${LOG_PATH}    deregister_UE1   ${crnti_UE4}    ${bwpid}    ${Branch_22R1}

Increase the data of UE2 which is in PSBWP and verify UE5 enters to PSBWP through tti trace
    Run Keyword and Ignore Error    Start Collecting Syslog     NAME=largedata_UE2
    Start CPRT Trace Capturing
    Start L2 BIP Trace Capturing
    Trigger DL Traffic for SA    2    Traffic_rate=mbps     dl_rate=1    pdu_id=1    trf_id=1       qfi_id=1
    Trigger UL Traffic for SA    2    Traffic_rate=mbps     ul_rate=1    pdu_id=1    trf_id=1       qfi_id=1
    Stop L1L2 capture  ${CaptureL1L2}
    Stop CPRT capture   ${CaptureCPRT}
    Move File    ${LOG_PATH}/NODECPRT_GNB.pcap    ${LOG_PATH}/NODECPRT_GNB_largedata_UE2.pcap
    Run Keyword and Ignore Error    Move File    ${LOG_PATH}/L1L2_GNB_FS_LO.pcap    ${LOG_PATH}/BIP_largedata_UE2.pcap
    Validate DL Traffic For SA   ue_id=2     dl_rate=1    qfi_id=${QFI_ID}
    Validate UL Traffic For SA   ue_id=2     ul_rate=1   qfi_id=${QFI_ID}
	${bwpid}    Create List    ${smallbwp_id}     ${psbwp_id}
	Append To List    ${NonVONR_UEs2_crnti}     ${crnti_value_UE5}
	Set Test Variable     ${rnti_UE2_UE5}     ${NonVONR_UEs2_crnti}
    Capture TTI Traces and Validate UE bwpid    ${LOG_PATH}    largedata_UE2   ${rnti_UE2_UE5}     ${bwpid}    ${Branch_22R1}
#    Sleep    300s
    Run Keyword and Ignore Error    Stop Collecting Syslog     NAME=largedata_UE2
#    Run Keyword and Ignore Error    Get Snapshot


Increase the data of all UE and verify moved to dedicated BWP through tti trace
    Run Keyword and Ignore Error    Start Collecting Syslog     NAME=largedata_allUE
    Start CPRT Trace Capturing
    Start L2 BIP Trace Capturing
    MultiUE Trigger DL Traffic for SA    3    5    Traffic_rate=mbps     dl_rate=1      trf_id=${TRF_ID}
    MultiUE Trigger UL Traffic for SA    3    5    Traffic_rate=mbps     ul_rate=1      trf_id=${TRF_ID}
    Stop L1L2 capture  ${CaptureL1L2}
    Stop CPRT capture   ${CaptureCPRT}
    Move File    ${LOG_PATH}/NODECPRT_GNB.pcap    ${LOG_PATH}/NODECPRT_GNB_largedata_allUE.pcap
    Run Keyword and Ignore Error    Move File    ${LOG_PATH}/L1L2_GNB_FS_LO.pcap    ${LOG_PATH}/BIP_largedata_allUE.pcap
    Run Keyword and Ignore Error    Stop Collecting Syslog     NAME=largedata_allUE
    Validate DL Traffic For MultiUE for SA    3   5     dl_rate=1
    Validate UL Traffic For MultiUE for SA    3   5     ul_rate=1
	${bwpid}    Create List    ${largebwp_id}     ${smallbwp_id}    ${largebwp_id}
    ${crnti_UE3_UE4}     Combine Lists     ${NonVONR_UE3_crnti}     ${crnti_UE4}
	Append To List    ${crnti_UE3_UE4}     ${crnti_value_UE5}
	Set Test Variable    ${rnti_UE3_UE4_UE5}    ${crnti_UE3_UE4}
    Capture TTI Traces and Validate UE bwpid    ${LOG_PATH}    largedata_allUE   ${rnti_UE3_UE4_UE5}      ${bwpid}    ${Branch_22R1}

Verify 8541 counters incrementing
    Wait until the next Measurement Period starts
#    Wait until the next Measurement Period starts
    ${PM_dir1}=     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
    Validate PM Counters    PM_dir=${PM_dir1}    PM_counter=M55351C01001    expected_value=4
    Validate PM Counters    PM_dir=${PM_dir1}    PM_counter=M55351C01002    expected_value=4
    Run Keyword and Continue On Failure  	Validate PM Counters    PM_dir=${PM_dir1}    PM_counter=M55351C00001    expected_value=3
    Run Keyword and Continue On Failure  	Validate PM Counters    PM_dir=${PM_dir1}    PM_counter=M55351C00002    expected_value=3
    Validate PM Counters bigger than    PM_dir=${PM_dir1}    PM_counter=M55308C28009    expected_value=2000
    Validate PM Counters equal or bigger than    PM_dir=${PM_dir1}    PM_counter=M55308C28010    expected_value=2
    Validate PM Counters bigger than    PM_dir=${PM_dir1}    PM_counter=M55308C28011    expected_value=2000
    Validate PM Counters equal or bigger than    PM_dir=${PM_dir1}    PM_counter=M55308C28012    expected_value=2
    Validate PM Counters bigger than    PM_dir=${PM_dir1}    PM_counter=M55308C29005    expected_value=2000
    Validate PM Counters bigger than    PM_dir=${PM_dir1}    PM_counter=M55308C29006    expected_value=2000

Verify 8541 counters decrementing
    Wait until the next Measurement Period starts
    Wait until the next Measurement Period starts
    ${PM_dir1}=     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
    Validate PM Counters    PM_dir=${PM_dir1}    PM_counter=M55351C01001    expected_value=4
    Validate PM Counters    PM_dir=${PM_dir1}    PM_counter=M55351C01002    expected_value=4
    Validate PM Counters    PM_dir=${PM_dir1}    PM_counter=M55351C00001    expected_value=0
    Validate PM Counters    PM_dir=${PM_dir1}    PM_counter=M55351C00002    expected_value=0
    Validate PM Counters    PM_dir=${PM_dir1}    PM_counter=M55308C28009    expected_value=0
    Validate PM Counters    PM_dir=${PM_dir1}    PM_counter=M55308C28010    expected_value=0
    Validate PM Counters    PM_dir=${PM_dir1}    PM_counter=M55308C28011    expected_value=0
    Validate PM Counters    PM_dir=${PM_dir1}    PM_counter=M55308C28012    expected_value=0
    Validate PM Counters    PM_dir=${PM_dir1}    PM_counter=M55308C29005    expected_value=0
    Validate PM Counters    PM_dir=${PM_dir1}    PM_counter=M55308C29006    expected_value=0

Collect SSB_SLOT_PDSCH counter verify
    Wait until the next Measurement Period starts
    ${PM_dir1}=     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
    ${counter_value_cell1}=    Get PM counter value    ${PM_dir1}    pi_id=M55308C00015    moc=NRCELL-1
    Should be true      ${counter_value_cell1} != 0

Deregister all Ues
    FOR    ${UE}   IN RANGE    ${2}     ${6}
        UE Deregister should be Successful    ${UE}
    END

Verify SSB_SLOT_PDSCH and TRS_SLOT_PDSCH counter
    [Arguments]     ${UE_Counter}
    Wait until the next Measurement Period starts
    Wait until the next Measurement Period starts
    ${PM_dir1}=     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
    ${Counter_UE}=    Get PM counter value    ${PM_dir1}    pi_id=${UE_Counter}    moc=NRCELL-1
    Should be true      ${Counter_UE} == 1
    ${counter_value_cell1_ssb}=    Get PM counter value    ${PM_dir1}    pi_id=M55308C00015    moc=NRCELL-1
    ${counter_value_cell1_ssb_slots}=    Get PM counter value    ${PM_dir1}    pi_id=M55308C00003    moc=NRCELL-1
    Should be true      ${counter_value_cell1_ssb} == ${counter_value_cell1_ssb_slots}
    ${counter_value_cell1_trs}=    Get PM counter value    ${PM_dir1}    pi_id=M55308C00017    moc=NRCELL-1
    ${counter_value_cell1_trs_slots}=    Get PM counter value    ${PM_dir1}    pi_id=M55308C00046    moc=NRCELL-1
    Should be true      ${counter_value_cell1_trs} == ${counter_value_cell1_trs_slots}

Resgister LargeUe and Verify SSB and TRS PDSCH counters
    Run Keyword and Ignore Error    Start Collecting Syslog     NAME=onlylarge
    Start CPRT Trace Capturing
    Start L2 BIP Trace Capturing
    ${Large_ue}=    MultiUE Register should be Successful   1    1
    Trigger DL Data Traffic for SA    ue_id=1    Traffic_rate=mbps     dl_rate=150       trf_id=1
    Trigger DL Data Traffic for SA    ue_id=1    Traffic_rate=mbps     dl_rate=150       trf_id=2
    Stop L1L2 capture  ${CaptureL1L2}
    Stop CPRT capture   ${CaptureCPRT}
    Move File    ${LOG_PATH}/NODECPRT_GNB.pcap    ${LOG_PATH}/onlylarge.pcap
    Run Keyword and Ignore Error    Move File    ${LOG_PATH}/L1L2_GNB_FS_LO.pcap    ${LOG_PATH}/BIP_onlylarge.pcap
    Run Keyword and Ignore Error    Stop Collecting Syslog     NAME=onlylarge
    sleep  20s
    ${bwpid}    Create List    ${largebwp_id}
    Run Keyword and continue on failure   Capture TTI Traces and Validate UE bwpid    ${LOG_PATH}    only_largeue   ${Large_ue}
    ...          ${bwpid}    ${Branch_22R1}
    Run Keyword and continue on failure   Verify SSB_SLOT_PDSCH and TRS_SLOT_PDSCH counter    UE_Counter=${Large_UE_Counter}
    UE Deregister should be Successful    1

Resgister SmallUe and Verify SSB and TRS PDSCH counters
    Run Keyword and Ignore Error    Start Collecting Syslog     NAME=onlysmall
    Start CPRT Trace Capturing
    Start L2 BIP Trace Capturing
    ${small_ue}=    MultiUE Register should be Successful   2    2
    Trigger DL Data Traffic for SA    ue_id=2    Traffic_rate=mbps     dl_rate=150       trf_id=1
    Trigger DL Data Traffic for SA    ue_id=2    Traffic_rate=mbps     dl_rate=150       trf_id=2
    Stop L1L2 capture  ${CaptureL1L2}
    Stop CPRT capture   ${CaptureCPRT}
    Move File    ${LOG_PATH}/NODECPRT_GNB.pcap    ${LOG_PATH}/onlysmall.pcap
    Run Keyword and Ignore Error    Move File    ${LOG_PATH}/L1L2_GNB_FS_LO.pcap    ${LOG_PATH}/BIP_onlysmall.pcap
    Run Keyword and Ignore Error    Stop Collecting Syslog     NAME=onlysmall
    sleep  20s
    ${bwpid}    Create List    ${smallbwp_id}
    Run Keyword and continue on failure    Capture TTI Traces and Validate UE bwpid    ${LOG_PATH}    only_smallue   ${small_ue}
    ...           ${bwpid}    ${Branch_22R1}
    Run Keyword and continue on failure    Verify SSB_SLOT_PDSCH and TRS_SLOT_PDSCH counter    UE_Counter=${Small_UE_Counter}
    UE Deregister should be Successful    2

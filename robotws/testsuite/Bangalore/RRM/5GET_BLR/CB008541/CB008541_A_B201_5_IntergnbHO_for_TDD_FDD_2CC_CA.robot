*** Settings ***

Force Tags        CLOUD_5G_I_LO_AP_LO     VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE
...               RAN_5G_TDD    RAN_5G      5G_RAN     SBTS00    CONFIGURED   CRT


Documentation    :copyright: Nokia
...              :authors: Chaithanya H S
...              :contact: chaithanya.h_s@nokia.com
...              New PM counters  are introduced for Carrier Aggregration and HO.
...                 1.	SCell Activation and Deactivation Success Rate.
...                 2.	SA CA SCell Addition Delay.
...                 3.  HO counters are introduced to monitor Intra-gNB Intra-DU SA handovers per neighbor relation.

Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Resource         resources/CB008541_Keywords.robot
Library          ../resources/python/avg_dl_data.py
Resource         ../resources/robot/common_log_collection.robot
Resource         ../5GC000937/resources/5GC000937_Keywords.robot
Library          ta5g_pm_counters
Library          taf.sw.scout    WITH NAME     scout


Suite Setup         Run keywords     Prepare TL with all config files
...                 AND     Perform SCF Delta Commissioning with Counters_C.json
...                 AND     gnb.Perform gNB reboot
...                 AND     Sleep   500s    reason=wait for RMOD- to comeup
...                 AND     Suite setup from scratch
...                 AND     Load CFG Config And Verify BWP-List During cell setup in Capture CPRT Traces      ${wts_cfg_file}
...                 AND     Check gNB Bulid

Suite Teardown    Run Keywords    Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
...                 AND     Run Keyword and Ignore Error    Get Snapshot
...                 AND     Run Keyword and Ignore Error    Get Sos Report

Test Setup       Start_capture_testcase_default_logging
Test Teardown   Run Keywords   Stop Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}
...      AND   Link SCOUT SCF to Configuration ID for Reporting

*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/basic_setup_CA_SA_IntergNBHO.cfg
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}          /opt/iphy/latest
${UE_ID}        3
${UE_ID_intra}        1
${nwslice_ID}   1
${gw_ID}     3
${Pdu_session_ID}       1
${QFI_ID}    1
${TRF_ID}    1
${TRF_ID2}    2
${PM_PCELL_COUNTER1}    M55167C00001
${PM_PCELL_COUNTER2}    M55167C00002
${PM_PCELL_COUNTER3}    M55139C04001
${PM_SCELL_COUNTER1}    M55308C28001
${PM_SCELL_COUNTER2}    M55308C28002
${SCFC}=                   Bangalore/RRM/ET/CB008541/8541_A_B201_5_CA_IntergNB_HO.xml
${AP_XML}=                 Bangalore/RRM/ET/CB008541/8541_A_B201_5_CA_IntergNB_HO_iphy.xml

*** Test Cases ***
[1]CB008541_A_B201_5_SA_UEsupporting_Pcell_LBWP_SCell_SBWP_IntergnbHO_for_TDD_FDD_2CC_CA
    [Documentation]  This user scenario provides the breakdown of the SCell configuration procedure.
        ...              Providing separate counters for the gNB internal time and the time required over
        ...              the Air interface for SCell successful configuation.
        ...              For the intra-frequency Intra-gNB Intra-DU handover execution time for SA new Counters are introduced.
        ...              for NR PMQAP(QCI, 5QI, ARP, PLMN, Slice Ids) service, in profile level.
        ...              for the inter-frequency Intra-gNB Intra-DU handover execution time for SA for every service type, in non-profile level.

	${LOG_PATH}  Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
	Establish Xn Link To gNB3
    Register UE Inter-gnb
    Check BandCombination Counters  nrcell=NRCELL-1
	Start Big DL data and verify Scell activation through A1 measurement based
	Trigger InterGnb HO
	Run keyword and continue on failure     Verify Counters incrementing Inter GNB HO M55139C04001    1
    Run keyword and continue on failure     Verify Counters incrementing Inter GNB HO     300    300    25000    1
    Start low DL data and verify Scell deactivation
    Verify Scelldeactivation Counters
	Register UE Intra-gnb
    Start 700 Mbps Big DL Data Transfer And Trigger Intra-Gnb HO
    Stop Data Traffic for SA    ue_id=${UE_ID_intra}
	Stop Data Traffic for SA    ue_id=${UE_ID}
    UE Deregister should be Successful   ue_id=${UE_ID}
    UE Deregister should be Successful   ue_id=${UE_ID_intra}
	Run keyword and continue on failure     Verify Counters decrementing Inter GNB HO    300     0    0     0     0

*** Keywords ***
Start_capture_testcase_default_logging
    ${TEST_NAME}=       replace string  ${TEST_NAME}      ${SPACE}        _
    set suite variable      ${TEST_NAME}
    Start Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}

Register UE Inter-gnb
    log to console   UE attach trigerring now...
    Run keyword and ignore error    Start Collecting Syslog     NAME=syslog_ue_attach
    Start CPRT Trace Capturing
    UE Register should be Successful     ${UE_ID}
    Sleep    10s
    Trigger DL Data Traffic for SA    ue_id=${UE_ID}    Traffic_rate=mbps     dl_rate=1       trf_id=1
    Run keyword and ignore error     Stop Collecting Syslog       NAME=syslog_ue_attach
    Run Keyword And Ignore Error     Stop CPRT capture   ${CaptureCPRT}
    Run Keyword And Ignore Error     Move File    ${LOG_PATH}/NODECPRT_GNB.pcap   ${LOG_PATH}/UE_attach_cprt.pcap

Trigger InterGnb HO
    log to console   Trigger InterGnb HO...
    Get Configured Measurements of UE${UE_ID}
    Trigger A3 RsrpAndRsrq Measurement from real gnb to simulated gNB     3     1     52
    Verify inter-gnb HOandCA Counters
    Trigger A3 RsrpAndRsrq Measurement from simulated gnb to real gNB     3      1    50
    sleep  3s
    Get Configured Measurements of UE${UE_ID}
	Trigger A1 Measurement and verify Scell added successfully     3     6    28875
    sleep   10s  reason=wait for data to stable
    Verify DL Tput For 2CC TDD FDD CA

Start Big DL data and verify Scell activation through A1 measurement based
    log to console   verify Scell activation...
    Start 700 Mbps Big DL Data Transfer And Check SCell Activation for 2CC
    sleep    5s
    Run Keyword And Continue on Failure    Validate DL Traffic For SA for high data   ue_id=${UE_ID}     dl_rate=510     qfi_id=${QFI_ID}
    Get Configured Measurements of UE${UE_ID}
    Trigger A1 Measurement and verify Scell added successfully     3     2     28875
    sleep  10s   reason=stable data
    Run Keyword And Continue on Failure    Verify DL Tput For 2CC TDD FDD CA

Start low DL data and verify Scell deactivation
    log to console   verify Scell deactivation...
	Start Low Data Traffic And Check Scell Deactivation
    sleep    5s
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

Register UE Intra-gnb
    log to console   UE attach trigerring now...
    Run keyword and ignore error    Start Collecting Syslog     NAME=syslog_ue_attach
    Start CPRT Trace Capturing
    UE Register should be Successful     ${UE_ID_intra}
    Sleep    10s
    Run keyword and ignore error     Stop Collecting Syslog       NAME=syslog_ue_attach
    Run Keyword And Ignore Error     Stop CPRT capture   ${CaptureCPRT}
    Run Keyword And Ignore Error     Move File    ${LOG_PATH}/NODECPRT_GNB.pcap   ${LOG_PATH}/UE_attach_cprt.pcap


Start 700 Mbps Big DL Data Transfer And Trigger Intra-Gnb HO
    Trigger DL Data Traffic for SA    ue_id=${UE_ID_intra}    Traffic_rate=mbps     dl_rate=150       trf_id=1
    sleep   5s
    Trigger DL Data Traffic for SA    ue_id=${UE_ID_intra}    Traffic_rate=mbps     dl_rate=150       trf_id=2
    sleep   5s    reason=Wait for successful traffic start
    Trigger DL Data Traffic for SA    ue_id=${UE_ID_intra}    Traffic_rate=mbps     dl_rate=150       trf_id=3
    sleep   5s
    Trigger DL Data Traffic for SA    ue_id=${UE_ID_intra}    Traffic_rate=mbps     dl_rate=150       trf_id=4
    sleep   5s    reason=Wait for successful traffic start
    Trigger DL Data Traffic for SA    ue_id=${UE_ID_intra}    Traffic_rate=mbps     dl_rate=100       trf_id=5
    sleep   5s
    log to console   Trigger IntraGnb HO...
    Get Configured Measurements of UE${UE_ID_intra}
    Trigger A3 RsrpAndRsrq Measurement for intragnb HO    1    1    53
    Verify intra-gnb HO Counters
    Check BandCombination Counters  nrcell=NRCELL-3
    Trigger A3 RsrpAndRsrq Measurement for intragnb HO    1    1    51
    Verify intra-gnb HO Nrcell3 Counters

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

Verify inter-gnb HOandCA Counters
    Wait For Next Full Pm Interval
    ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55316C00033    1     MACCE_SENT_SCELL_ACT_SA
    ...     M55316C00034    1     MACCE_HARQ_ACK_SCELL_ACT_SA
	...     M55118C00097    >20   SCELL_CONFIG_RRC_RECNFG_DUR_SA
    ...     M55118C00098    >20   SCELL_CONFIG_DUR_SA
	...     M55153C00001    1     ATT_HO_NRREL
    ...     M55153C00002    1     SUCC_HO_NRREL
    ...     M55185C00009    1     IAF_XN_HO_PR_ATT_SRC_PMQAP
	...     M55185C00010    1     IAF_XN_HO_EX_ATT_SRC_PMQAP
    ...     M55185C00011    1     IAF_XN_HO_EX_SUC_SRC_PMQAP
	...     M55185C00012    >10   AVG_TIME_IAF_XN_HO_EX_PMQAP
	...     M55185C00014    >10   MAX_TIME_IAF_XN_HO_EX_PMQAP
	...     M55153C00003    0     FAIL_HO_NRREL_PREP
	...     local_moid=MRBTS-1/NRBTS-1/NRCELL-1
    ...     file_path=${pm_counter_file}

Verify intra-gnb HO Counters
    Wait For Next Full Pm Interval
    ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55153C00001    1     ATT_HO_NRREL
    ...     M55153C00002    1     SUCC_HO_NRREL
    ...     M55184C00015    1     IAF_IADU_HO_EX_ATT_SA_PMQAP
    ...     M55184C00016    1     IAF_IADU_HO_EX_SUC_SA_PMQAP
	...     M55184C00025    10-150     AVG_TIME_IAF_IADU_HO_EX_PMQAP
	...     M55184C00027    10-150     MAX_TIME_IAF_IADU_HO_EX_PMQAP
	...     M55153C00003    0     FAIL_HO_NRREL_PREP
    ...     local_moid=MRBTS-1/NRBTS-1/NRCELL-2
    ...     file_path=${pm_counter_file}

Verify intra-gnb HO Nrcell3 Counters
    Wait For Next Full Pm Interval
    ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55153C00001    1     ATT_HO_NRREL
    ...     M55153C00002    1     SUCC_HO_NRREL
    ...     M55184C00015    1     IAF_IADU_HO_EX_ATT_SA_PMQAP
    ...     M55184C00016    1     IAF_IADU_HO_EX_SUC_SA_PMQAP
    ...     M55184C00025    10-150     AVG_TIME_IAF_IADU_HO_EX_PMQAP
    ...     M55184C00027    10-150     MAX_TIME_IAF_IADU_HO_EX_PMQAP
    ...     M55153C00003    0     FAIL_HO_NRREL_PREP
    ...     local_moid=MRBTS-1/NRBTS-1/NRCELL-3
    ...     file_path=${pm_counter_file}


Verify Scelldeactivation Counters
    Wait For Next Full Pm Interval
    ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...    M55316C00035    1    MACCE_SENT_SCELL_DEACT_SA
    ...    M55316C00036    1    MACCE_HARQ_ACK_SCELL_DEACT_SA
    ...     local_moid=MRBTS-1/NRBTS-1/NRCELL-1
    ...     file_path=${pm_counter_file}

Check BandCombination Counters
    [Arguments]  ${nrcell}=NRCELL-1
    Wait For Next Full Pm Interval
    Wait For Next Full Pm Interval
    ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
    ${PEAK_NUM_OF_CAP_UE_NRCABM}  ta5g_pm_counters.get_pm_counter_value   M55204C00001   MRBTS-1/NRBTS-1/${nrcell}   ${pm_counter_file}
    Should be Equal  ${PEAK_NUM_OF_CAP_UE_NRCABM}[0]   ${1}
    Should be Equal  ${PEAK_NUM_OF_CAP_UE_NRCABM}[1]   ${0}
    ${PEAK_NUM_OF_CAP_UE_NRCABM}  ta5g_pm_counters.get_pm_counter_value   M55203C00001   MRBTS-1/NRBTS-1/${nrcell}    ${pm_counter_file}
    Should be Equal   ${PEAK_NUM_OF_CAP_UE_NRCABM}[0]    ${300}
    Should be Equal   ${PEAK_NUM_OF_CAP_UE_NRCABM}[1]    ${0}
    ${AVG_NUM_OF_CAP_UE_DENOM_NRCABM}  ta5g_pm_counters.get_pm_counter_value   M55203C00002   MRBTS-1/NRBTS-1/${nrcell}   ${pm_counter_file}
    Should be Equal   ${AVG_NUM_OF_CAP_UE_DENOM_NRCABM}[0]   ${300}
    Should be Equal   ${AVG_NUM_OF_CAP_UE_DENOM_NRCABM}[1]   ${300}
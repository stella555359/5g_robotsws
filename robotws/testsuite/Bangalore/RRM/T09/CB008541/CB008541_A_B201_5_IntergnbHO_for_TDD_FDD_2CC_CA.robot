*** Settings ***

Force Tags        CLOUD_5G_I_LOO_AP_LOOO     VARIANT_SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_TMO_65
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
Library          ../../../resources/python/avg_dl_data.py
Resource         ../../../resources/robot/common_log_collection.robot
Resource         ../5GC000937/resources/5GC000937_Keywords.robot
Library          ta5g_pm_counters
Library          taf.sw.scout    WITH NAME     scout

Suite Setup         Run keywords    Suite setup from scratch
...                 AND     5GC000937_Keywords.Perform SCF Delta Commissioning with Inter_GNB_B201.json
...                 AND     Sleep     100s
...                 AND     5GC000937_Keywords.Perform SCF Delta Commissioning with FDD_TDD.json
...                 AND     Sleep     100s
...                 AND     5GC000937_Keywords.Perform SCF Delta Commissioning with Counters_C.json
...                 AND     Sleep     100s
...                 AND     5GC000937_Keywords.Perform SCF Delta Commissioning with Intra_GNB.json
...                 AND     Sleep     100s
...                 AND     Prepare TL with IPHY file change
...                 AND     Reboot gNB System Module from Console and check Airscale is ready
...                 AND     Check and active the BTS l2ps DBG log
...                 AND     Load CFG Config And Verify BWP-List During cell setup in Capture CPRT Traces      ${wts_cfg_file}
...                 AND     Check gNB Bulid

Suite Teardown    Run Keywords    Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
...                 AND     Run Keyword and Ignore Error    Get Snapshot
...                 AND     Run Keyword and Ignore Error    Get Sos Report

Test Setup       Start_capture_testcase_default_logging
Test Teardown   Run Keywords   Stop Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}
...      AND   Link SCOUT SCF to Configuration ID for Reporting

*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/basic_201_5_TMOUS.cfg
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}          /opt/iphy/latest
${UE_ID}        1
${UE_ID_intra}        4
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${QFI_ID}    1
${TRF_ID}    1
${TRF_ID2}    2
${epc_log_path}    /tmp/
${AP_XML}=                 ${CURDIR}/config/iphy.xml

*** Test Cases ***
[1]CB008541_A_B201_5_SA_UEsupporting_Pcell_LBWP_SCell_SBWP_IntergnbHO_for_TDD_FDD_2CC_CA
    [Documentation]   in this testcase verify SA carrier aggregation Scell selection after inter gNB Handover,
	...               for TDD Pcell and FDD SCell selection. UE supporting large BWP in Pcell and small BWP in Scell.
	...               UE attach with gNBSim PcellA with the NR capabilities for band combination.
	...               UE sends RRC: A3 Measurement report to the gNB PcellA for inter gnb HO.
	...               UE sends RRC: A1 Measurement report to the gNB for Scell Addition.
	...               Send high dl/ul traffic for ue

	${LOG_PATH}  Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
	Establish Xn Link To gNB3
    Register UE Inter-gnb
    Check BandCombination Counters  nrcell=NRCELL-4
	Start Big DL data and verify Scell activation through A1 measurement based
	Trigger InterGnb HO
    Start low DL data and verify Scell deactivation
    Verify Scelldeactivation Counters
	Register UE Intra-gnb
    Start 700 Mbps Big DL Data Transfer And Trigger Intra-Gnb HO
    Stop Data Traffic for SA    ue_id=${UE_ID_intra}
	Stop Data Traffic for SA    ue_id=${UE_ID}
    UE Deregister should be Successful   ue_id=${UE_ID}
    UE Deregister should be Successful   ue_id=${UE_ID_intra}
    Verify 8541 counters decrementing

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
    Verify 8541 counters incrementing initial
    Run keyword and ignore error     Stop Collecting Syslog       NAME=syslog_ue_attach
    Run Keyword And Ignore Error     Stop CPRT capture   ${CaptureCPRT}
    Run Keyword And Ignore Error     Move File    ${LOG_PATH}/NODECPRT_GNB.pcap   ${LOG_PATH}/UE_attach_cprt.pcap

Trigger InterGnb HO
    log to console   Trigger InterGnb HO...
    Get Configured Measurements of UE${UE_ID}
    Trigger A3 RsrpAndRsrq Measurement from real gnb to simulated gNB     1     2     63
    Verify inter-gnb HO Counters
    Trigger A3 RsrpAndRsrq Measurement from simulated gnb to real gNB     1     5     54
    sleep  3s
    Get Configured Measurements of UE${UE_ID}
	Trigger A1 Measurement and verify Scell added successfully     1     16    28875
    sleep   10s  reason=wait for data to stable
    Run Keyword And Continue on Failure    Verify DL Tput For 2CC TDD FDD CA

Start Big DL data and verify Scell activation through A1 measurement based
    log to console   verify Scell activation...
    Start 700 Mbps Big DL Data Transfer And Check SCell Activation for 2CC
    sleep    5s
    Run Keyword And Continue on Failure    Validate DL Traffic For SA for high data   ue_id=${UE_ID}     dl_rate=695     qfi_id=${QFI_ID}
    Get Configured Measurements of UE${UE_ID}
    Trigger A1 Measurement and verify Scell added successfully     1     4     28875
    sleep  10s   reason=stable data
    Run Keyword And Continue on Failure    Verify DL Tput For 2CC TDD FDD CA
    Verify 8541 counters incrementing SCELL SUCC
    Verify 8541 counters incrementing

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
    Trigger DL Data Traffic for SA    ue_id=${UE_ID}    Traffic_rate=mbps     dl_rate=150       trf_id=5
    sleep   5s
    Trigger DL Data Traffic for SA    ue_id=${UE_ID}    Traffic_rate=mbps     dl_rate=150       trf_id=6
    sleep   5s
    Trigger DL Data Traffic for SA    ue_id=${UE_ID}    Traffic_rate=mbps     dl_rate=150       trf_id=7
    sleep   5s
    Trigger DL Data Traffic for SA    ue_id=${UE_ID}    Traffic_rate=mbps     dl_rate=150       trf_id=8
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
    Trigger DL Data Traffic for SA    ue_id=${UE_ID_intra}    Traffic_rate=mbps     dl_rate=150       trf_id=5
    sleep   5s
    Trigger DL Data Traffic for SA    ue_id=${UE_ID_intra}    Traffic_rate=mbps     dl_rate=150       trf_id=6
    sleep   5s
    Trigger DL Data Traffic for SA    ue_id=${UE_ID_intra}    Traffic_rate=mbps     dl_rate=150       trf_id=7
    sleep   5s
    Trigger DL Data Traffic for SA    ue_id=${UE_ID_intra}    Traffic_rate=mbps     dl_rate=150       trf_id=8
    sleep   5s
    log to console   Trigger IntraGnb HO...
    Get Configured Measurements of UE${UE_ID_intra}
    Trigger A3 RsrpAndRsrq Measurement for intragnb HO    4    3    53
    Verify intra-gnb HO Counters
    Trigger A3 RsrpAndRsrq Measurement for intragnb HO    4    3    51
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

Verify DL Tput For 2CC TDD FDD CA
    ${pcell_tput}=    Get AVG DL DATA TRAFFIC For Given CC    ue_id=${UE_ID}    scell_idx=0    unit=Mbps
    ${scell_tput}=    Get AVG DL DATA TRAFFIC For Given CC    ue_id=${UE_ID}    scell_idx=1    unit=Mbps
    Should Be True    ${pcell_tput} > ${350}
    Should Be True    ${scell_tput} > ${90}

Perform SCF Delta Commissioning with ${delta_commissioning_file_json}
    Find Scfc And Send Delta Commissioning      scfc_filename=${delta_commissioning_file_json}    skip_relation_errors=False

Verify inter-gnb HO Counters
    Wait For Next Full Pm Interval
    ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
	...     M55153C00001    1     ATT_HO_NRREL
    ...     M55153C00002    1     SUCC_HO_NRREL
    ...     M55185C00009    1     IAF_XN_HO_PR_ATT_SRC_PMQAP
	...     M55185C00010    1     IAF_XN_HO_EX_ATT_SRC_PMQAP
    ...     M55185C00011    1     IAF_XN_HO_EX_SUC_SRC_PMQAP
	...     M55185C00012    >10   AVG_TIME_IAF_XN_HO_EX_PMQAP
	...     M55185C00014    >10   MAX_TIME_IAF_XN_HO_EX_PMQAP
	...     M55153C00003    0     FAIL_HO_NRREL_PREP
	...     local_moid=MRBTS-1/NRBTS-1/NRCELL-4
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
    ...     local_moid=MRBTS-1/NRBTS-1/NRCELL-1
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
    ...     local_moid=MRBTS-1/NRBTS-1/NRCELL-4
    ...     file_path=${pm_counter_file}

Check BandCombination Counters
    [Arguments]  ${nrcell}=NRCELL-4
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

Verify 8541 counters incrementing SCELL SUCC
    Wait For Next Full Pm Interval
    ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55139C04001    1    GNB_DU_SCELL_ADM_S_BWP_SUCC
    ...     M55316C00033    1     MACCE_SENT_SCELL_ACT_SA
    ...     M55316C00034    1     MACCE_HARQ_ACK_SCELL_ACT_SA
    ...     M55118C00097    >20   SCELL_CONFIG_RRC_RECNFG_DUR_SA
    ...     M55118C00098    >20   SCELL_CONFIG_DUR_SA
    ...     local_moid=MRBTS-1/NRBTS-1/NRCELL-4
    ...     file_path=${pm_counter_file}

Verify 8541 counters incrementing initial
    Wait For Next Full Pm Interval
    ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55308C28001    >0    ACC_UE_DL_SCH_SLOT_BWP1
    ...     M55308C28002    1    MAX_UE_DL_SCH_SLOT_BWP1
    ...     local_moid=MRBTS-1/NRBTS-1/NRCELL-4
    ...     file_path=${pm_counter_file}

Verify 8541 counters incrementing
    Wait For Next Full Pm Interval
    ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55167C00001    300    SAMPLES_BWP_UE_AMOUNTS
    ...     M55167C00002    >250    SUM_UE_SCELL_CONF_S_BWP
    ...     local_moid=MRBTS-1/NRBTS-1/NRCELL-4
    ...     file_path=${pm_counter_file}

Verify 8541 counters decrementing
    Wait For Next Full Pm Interval
    Wait For Next Full Pm Interval
    ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
	...     M55167C00001    300    SAMPLES_BWP_UE_AMOUNTS
    ...     M55167C00002    0    SUM_UE_SCELL_CONF_S_BWP
    ...     M55308C28001    0    ACC_UE_DL_SCH_SLOT_BWP1
    ...     M55308C28002    0    MAX_UE_DL_SCH_SLOT_BWP1
    ...     local_moid=MRBTS-1/NRBTS-1/NRCELL-4
	...     file_path=${pm_counter_file}



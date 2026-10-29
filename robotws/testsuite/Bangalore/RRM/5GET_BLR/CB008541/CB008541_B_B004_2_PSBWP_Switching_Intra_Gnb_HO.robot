*** Settings ***
#Force Tags      CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
#...             CONFIGS_Bangalore/RRM/ET/CB008541/8541_B_B004_2_APoverABIO.yml
#...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS00     SBTS23R1    #CONFIGURED

Force Tags        CLOUD_5G_I_LO_AP_LO     VARIANT_SANSA_FS_ECPRI_CMWV_TDD
...               RAN_5G_TDD    RAN_5G      5G_RAN     SBTS00    CONFIGURED   CRT

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

Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Library          Collections
Resource         resources/CB008541_Keywords.robot
Resource         ../resources/robot/common_log_collection.robot
Library          taf.sw.scout    WITH NAME     scout
Library          ta5g_pm_counters

Suite Setup         Run keywords    Suite setup from scratch
...                 AND     Perform SCF Delta Commissioning with B_B004_2_TMO.json
...                 AND     Reboot gNB System Module from Console and check Airscale is ready
#...                 AND     Check and active the BTS l2ps DBG log
...                 AND     Load CFG Config And Verify BWP-List During cell setup in Capture CPRT Traces      ${wts_cfg_file}
...                 AND     Check gNB Bulid

Suite Teardown      Run keywords  Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
...                 AND     Run Keyword and Ignore Error    Get Snapshot
...                 AND     Run Keyword and Ignore Error    Get Sos Report
...                 AND     Run Keyword and Ignore Error    Stop Default Processes And Gather Logs And Compress Logs

Test Setup       Start_capture_testcase_default_logging
Test Teardown    Run Keywords   Stop Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}
...    AND       Link SCOUT SCF to Configuration ID for Reporting

*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/basic_setup_intrafreq.cfg
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}          /opt/iphy/latest
${iphy_file_path}      ${CURDIR}/config/iphy_B004.xml
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
@{pysical_cell_ids}    51
@{pysical_cell_ids1}    53
${SCFC}=                   Bangalore/RRM/ET/CB008541/8541_B_B004_2_APoverABIO_scf.xml
${AP_XML}=                 Bangalore/RRM/ET/CB008541/8541_B_B004_2_APoverABIO_iphy.xml

*** Test Cases ***
[1]CB008541_5G_B_B004_2_Verify_UE_Connects_From_Cell_With_Configured_PS_BWP_To_Cell_Without_Configured_PS_BWP_Via_Intra_Gnb_HO
    [Documentation]   in this testcase verify that 5G NR powerSaving BWP cabable  UE configured with large BWP, small BWP and
    ...         Power Saving BWP during UE context setup. in the beginning when successful DL/UL data transfer initiated
    ...         verify that data transfer happens in the large BWP,
    ...        DCI switch to PS BWP happens using DCI format 1_1, when data rates are less than thresholds.
    ...        DCI switch to large BWP happens, when DL data rate is more than the thresholds.
    ...        Verify ScellA is deactivated and not used for UL/DL data transmissions when using power saving BWP. Data is switched back to Pcell.
    ...         Verify ScellA is activated and data transmission is on small BWP.
	${LOG_PATH}   Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
    Register UE and verify initial bwp through tti trace
    Start low DL data and verify psbwp through tti trace
    Run Keyword and Continue On Failure  Verify 8541 counters incrementing
    Trigger A3 measurement for Intragnb HO and verify UE moves to smallBWP using tti trace
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
    Capture TTI Traces and Validate UE bwpid Per Cell    ${LOG_PATH}   initial   ${crnti_list}     ${bwpid}    ${Branch_22R1}
    ...    pysical_cell_ids=${pysical_cell_ids}

Start low DL data and verify psbwp through tti trace
    Start Collecting Syslog       NAME=lowdata
    Start CPRT Trace Capturing
    Start L2 BIP Trace Capturing
    Trigger DL Data Traffic for SA    ue_id=${UE_ID}    Traffic_rate=kbps     dl_rate=10
    sleep   5s
    Trigger UL Data Traffic for SA    ue_id=${UE_ID}    Traffic_rate=kbps     ul_rate=10
    sleep   5s    reason=Wait for successful BWP switch
    Run Keyword And Ignore Error    Stop L1L2 capture  ${CaptureL1L2}
    Run Keyword And Ignore Error    Move File    ${LOG_PATH}/L1L2_GNB_FS_LO.pcap    ${LOG_PATH}/BIP_lowdata.pcap
    Run Keyword And Ignore Error     Stop CPRT capture   ${CaptureCPRT}
    Run Keyword And Ignore Error     Move File    ${LOG_PATH}/NODECPRT_GNB.pcap   ${LOG_PATH}/lowdata_cprt.pcap
    Stop Collecting Syslog       NAME=lowdata
    Validate DL Traffic For SA   ue_id=${UE_ID}     dl_rate=0.010     qfi_id=${QFI_ID}
    ${bwpid}    Create List     ${psbwp_id}
    ${crnti_list}     Create List
    Capture TTI Traces and Validate UE bwpid Per Cell    ${LOG_PATH}   lowdata   ${crnti_list}     ${bwpid}    ${Branch_22R1}
    ...    pysical_cell_ids=${pysical_cell_ids}

Trigger A3 measurement for Intragnb HO and verify UE moves to smallBWP using tti trace
    Start Collecting Syslog       NAME=IntragnbHO
    Start CPRT Trace Capturing
    Start L2 BIP Trace Capturing
   	Get Configured Measurements of UE${UE_ID}
	Trigger A3 RsrpAndRsrq Measurement for intragnb HO    ${UE_ID}    2    53
    Run Keyword And Ignore Error    Stop L1L2 capture  ${CaptureL1L2}
    Run Keyword And Ignore Error    Move File    ${LOG_PATH}/L1L2_GNB_FS_LO.pcap    ${LOG_PATH}/BIP_IntragnbHO.pcap
    Run Keyword And Ignore Error     Stop CPRT capture   ${CaptureCPRT}
    Run Keyword And Ignore Error     Move File    ${LOG_PATH}/NODECPRT_GNB.pcap   ${LOG_PATH}/IntragnbHOcprt.pcap
    Stop Collecting Syslog       NAME=IntragnbHO
    Validate DL Traffic For SA   ue_id=${UE_ID}     dl_rate=0.010     qfi_id=${QFI_ID}
    ${bwpid}    Create List     ${smallbwp_id}
    ${crnti_list}     Create List
    Capture TTI Traces and Validate UE bwpid Per Cell    ${LOG_PATH}   IntragnbHO   ${crnti_list}     ${bwpid}    ${Branch_22R1}
    ...    pysical_cell_ids=${pysical_cell_ids1}

Verify 8541 counters incrementing
    Wait For Next Full Pm Interval
    ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55351C01001    1    MAX_UE_CONFIG_2BWP
    ...     M55351C01002    1    AVG_UE_CONFIG_2BWP
    ...     M55351C00001    1    MAX_UE_ACTIVE_PWR_SAVING_BWP
    ...     M55351C00002    1    AVG_UE_ACTIVE_PWR_SAVING_BWP
    ...     M55308C28009    >200    ACC_UE_DL_SCH_SLOT_BWP_PS
    ...     M55308C28010    1    MAX_UE_DL_SCH_SLOT_BWP_PS
    ...     M55308C28011    >200    ACC_UE_UL_SCH_SLOT_BWP_PS
    ...     M55308C28012    1    MAX_UE_UL_SCH_SLOT_BWP_PS
    ...     M55308C29005    >200    PRB_USED_PDSCH_BWP_PS
    ...     M55308C29006    >200    PRB_USED_PUSCH_BWP_PS
    ...     local_moid=MRBTS-1/NRBTS-1/NRCELL-1
    ...     file_path=${pm_counter_file}

Verify 8541 counters decrementing
    Wait For Next Full Pm Interval
	Wait For Next Full Pm Interval
    ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55351C01001    0    MAX_UE_CONFIG_2BWP
    ...     M55351C01002    0    AVG_UE_CONFIG_2BWP
    ...     M55351C00001    0    MAX_UE_ACTIVE_PWR_SAVING_BWP
    ...     M55351C00002    0    AVG_UE_ACTIVE_PWR_SAVING_BWP
    ...     M55308C28009    0    ACC_UE_DL_SCH_SLOT_BWP_PS
    ...     M55308C28010    0    MAX_UE_DL_SCH_SLOT_BWP_PS
    ...     M55308C28011    0    ACC_UE_UL_SCH_SLOT_BWP_PS
    ...     M55308C28012    0    MAX_UE_UL_SCH_SLOT_BWP_PS
    ...     M55308C29005    0    PRB_USED_PDSCH_BWP_PS
    ...     M55308C29006    0    PRB_USED_PUSCH_BWP_PS
    ...     local_moid=MRBTS-1/NRBTS-1/NRCELL-1
    ...     file_path=${pm_counter_file}

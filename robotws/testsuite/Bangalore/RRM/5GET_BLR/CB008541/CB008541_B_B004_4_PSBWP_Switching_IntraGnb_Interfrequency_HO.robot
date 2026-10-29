*** Settings ***
#Force Tags      CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
#...             CONFIGS_Bangalore/RRM/ET/CB008541/8541_B_B004_4_APoverABIO.yml
#...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS00     SBTS23R1    CONFIGURED

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
Library          ta5g_enb
Library          ta5g_pm_counters

Suite Setup         Run keywords    Suite setup from scratch
...                 AND    Perform SCF Delta Commissioning with B_B004_4_1_TMO.json
...                 AND    Perform SCF Delta Commissioning with B_B004_4_2_TMO.json
...                 AND    Sleep     100s
...                 AND    Perform SCF Delta Commissioning with A_B102_5.json
...                 AND    Sleep     100s
...                 AND    Prepare TL with IPHY file change
...                 AND    gnb.Perform gNB reboot
...                 AND    Sleep   200s    reason=wait for RMOD- to comeup
...                 AND    5GC000937_Keywords.Configure UTE ETH3 IPs
...                 AND     Load CFG Config And Verify BWP-List During cell setup in Capture CPRT Traces      ${wts_cfg_file}
...                 AND     Check gNB Bulid

Suite Teardown      Run keywords   Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
...                 AND     Run Keyword and Ignore Error    Get Snapshot
...                 AND     Run Keyword and Ignore Error    Get Sos Report
...                 AND     Run Keyword and Ignore Error    Stop Default Processes And Gather Logs And Compress Logs

#Test Setup       Start_capture_testcase_default_logging
#Test Teardown     Run keyword    Link SCOUT SCF to Configuration ID for Reporting

*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/egate_TMOUS_1.cfg
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}          /opt/iphy/latest
${UE_ID}        1
${UE_ID_1}        101
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${QFI_ID}    1
${TRF_ID}    1
${TRF_ID2}    2
${TRF_ID3}    3
${TRF_ID4}    4
${a3meas_id}   1
${a1meas_id}   5
${Target_Cells}    7
${largebwp_id}   1
${smallbwp_id}   2
${psbwp_id}     3
${epc_log_path}    /tmp/
${SCFC}=                   Bangalore/RRM/ET/CB008541/8541_B_B004_4_APoverABIO_scf.xml
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
${AP_XML}   ${CURDIR}/config/A_B102_5.xml
@{pysical_cell_ids}    53
@{pysical_cell_ids1}   51

*** Test Cases ***
[1]CB008541_5G_B_B004_4_Verify_UE_Connects_From_cell_Without_PS_BWP_To_cell_With_Configured_PS_BWP_Via_IntraGnb_Interfrequency_HO
    [Documentation]   in this testcase verify that 5G NR powerSaving BWP cabable  UE configured with large BWP, small BWP and
    ...         Power Saving BWP during UE context setup. in the beginning when successful DL/UL data transfer initiated
    ...         verify that data transfer happens in the large BWP,
    ...        DCI switch to PS BWP happens using DCI format 1_1, when data rates are less than thresholds.
    ...        DCI switch to large BWP happens, when DL data rate is more than the thresholds.
    ...        Verify ScellA is deactivated and not used for UL/DL data transmissions when using power saving BWP. Data is switched back to Pcell.
    ...         Verify ScellA is activated and data transmission is on small BWP.

    [Tags]    TC01
	${LOG_PATH}  Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
    X2AP Link Should be UP
    Register UE and verify initial bwp through tti trace
    Trigger A2 A3 measurement for Intragnb HO and verify UE moves to psbwp using tti trace
    Start low DL data and verify psbwp through tti trace
    Run Keyword and Continue on failure  Verify 8541 PM counters incrementing
    Start high DL data and verify smallbwp through tti trace
    Run Keyword and Continue on failure   Verify 8541 PM counters decrementing
	Stop Data Traffic for SA     ue_id=${UE_ID}
    UE Deregister should be Successful   ue_id=${UE_ID}
    [Teardown]   Run Keyword   Link SCOUT SCF to Configuration ID for Reporting

[1]CB008541_A_B102_5_NSA_UEsupporting_Pcell_SBWP_SCell_SBWP_IntragnbHO_for_FDD_TDD_2CC_CA
    [Documentation]  CB008541_A_B102_5_NSA_UEsupporting_Pcell_SBWP_SCell_SBWP_IntragnbHO_for_FDD_TDD_2CC_CA

    [Tags]    TC02
    ${LOG_PATH}  Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
    Attach UE and Trigger A3 Measurement
    Start Big Data and trigger A1 for scell addition
    Start Low Data Traffic And Check Scell Deactivation
    [Teardown]   Run Keyword   Link SCOUT SCF to Configuration ID for Reporting

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
    ${bwpid}    Create List     ${smallbwp_id}
    ${crnti_list}     Create List
    Run keyword and continue on failure    Capture TTI Traces and Validate UE bwpid Per Cell   ${LOG_PATH}    intial    ${crnti_list}
    ...     ${bwpid}    ${Branch_22R1}     pysical_cell_ids=${pysical_cell_ids}
    Trigger DL Traffic for SA    ue_id=${UE_ID}    Traffic_rate=kbps     dl_rate=10       trf_id=${TRF_ID}      qfi_id=${QFI_ID}
    sleep   5s
    Trigger UL Traffic for SA    ue_id=${UE_ID}    Traffic_rate=kbps     ul_rate=10       trf_id=${TRF_ID2}      qfi_id=${QFI_ID}
    sleep   5s
    Run keyword and continue on failure    Capture TTI Traces and Validate UE bwpid Per Cell   ${LOG_PATH}    intiallowdata    ${crnti_list}
    ...     ${bwpid}    ${Branch_22R1}     pysical_cell_ids=${pysical_cell_ids}

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
    Run keyword and continue on failure    Capture TTI Traces and Validate UE bwpid Per Cell   ${LOG_PATH}    lowdata    ${crnti_list}
    ...     ${bwpid}    ${Branch_22R1}     pysical_cell_ids=${pysical_cell_ids}
Start high DL data and verify smallbwp through tti trace
    Start Collecting Syslog       NAME=highdata
    Start CPRT Trace Capturing
    Start L2 BIP Trace Capturing
    Trigger DL Traffic for SA    ue_id=${UE_ID}    Traffic_rate=mbps     dl_rate=1       trf_id=${TRF_ID}      qfi_id=${QFI_ID}
    sleep   5s
    Trigger UL Traffic for SA    ue_id=${UE_ID}    Traffic_rate=mbps     ul_rate=1       trf_id=${TRF_ID2}      qfi_id=${QFI_ID}
    sleep   5s    reason=Wait for successful BWP switch
    Run Keyword And Ignore Error    Stop L1L2 capture  ${CaptureL1L2}
    Run Keyword And Ignore Error    Move File    ${LOG_PATH}/L1L2_GNB_FS_LO.pcap    ${LOG_PATH}/BIP_highdata.pcap
    Run Keyword And Ignore Error     Stop CPRT capture   ${CaptureCPRT}
    Run Keyword And Ignore Error     Move File    ${LOG_PATH}/NODECPRT_GNB.pcap   ${LOG_PATH}/highdata_cprt.pcap
    Sleep    60s
    Stop Collecting Syslog       NAME=highdata
    Validate DL Traffic For SA   ue_id=${UE_ID}     dl_rate=1     qfi_id=${QFI_ID}
    ${bwpid}    Create List     ${smallbwp_id}
    ${crnti_list}     Create List
    Run keyword and continue on failure    Capture TTI Traces and Validate UE bwpid Per Cell   ${LOG_PATH}    highdata    ${crnti_list}
    ...     ${bwpid}    ${Branch_22R1}     pysical_cell_ids=${pysical_cell_ids}

Trigger A2 A3 measurement for Intragnb HO and verify UE moves to psbwp using tti trace
    Start Collecting Syslog       NAME=IntragnbHO
    Start CPRT Trace Capturing
    Start L2 BIP Trace Capturing
   	Get Configured Measurements of UE${UE_ID}
    Trigger A2 Measurement    ${UE_ID}   1
	Get Configured Measurements of UE${UE_ID}
	Trigger A3 RsrpAndRsrq Measurement for intragnb HO    ${UE_ID}    6    51
    Run Keyword And Ignore Error    Stop L1L2 capture  ${CaptureL1L2}
    Run Keyword And Ignore Error    Move File    ${LOG_PATH}/L1L2_GNB_FS_LO.pcap    ${LOG_PATH}/BIP_IntragnbHO.pcap
    Run Keyword And Ignore Error     Stop CPRT capture   ${CaptureCPRT}
    Run Keyword And Ignore Error     Move File    ${LOG_PATH}/NODECPRT_GNB.pcap   ${LOG_PATH}/IntragnbHO_cprt.pcap
    Stop Collecting Syslog       NAME=IntragnbHO
    Validate DL Traffic For SA   ue_id=${UE_ID}     dl_rate=0.010     qfi_id=${QFI_ID}
    ${bwpid}    Create List    ${psbwp_id}
    ${crnti_list}     Create List
    Run keyword and continue on failure    Capture TTI Traces and Validate UE bwpid Per Cell   ${LOG_PATH}    intragnbho    ${crnti_list}
    ...     ${bwpid}    ${Branch_22R1}     pysical_cell_ids=${pysical_cell_ids1}



Verify 8541 counters incrementing
    Wait until the next Measurement Period starts
    ${PM_dir1}=     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
    Validate PM Counters Cell2   PM_dir=${PM_dir1}    PM_counter=M55351C01001    expected_value=1
    Validate PM Counters Cell2    PM_dir=${PM_dir1}    PM_counter=M55351C01002    expected_value=1
    Validate PM Counters Cell2    PM_dir=${PM_dir1}    PM_counter=M55351C00001    expected_value=1
    Validate PM Counters Cell2    PM_dir=${PM_dir1}    PM_counter=M55351C00002    expected_value=1
    Cell2 Validate PM Counters bigger than    PM_dir=${PM_dir1}    PM_counter=M55308C28009    expected_value=200
    Validate PM Counters Cell2    PM_dir=${PM_dir1}    PM_counter=M55308C28010    expected_value=1
    Cell2 Validate PM Counters bigger than    PM_dir=${PM_dir1}    PM_counter=M55308C28011    expected_value=200
    Validate PM Counters Cell2   PM_dir=${PM_dir1}    PM_counter=M55308C28012    expected_value=1
    Cell2 Validate PM Counters bigger than    PM_dir=${PM_dir1}    PM_counter=M55308C29005    expected_value=200
    Cell2 Validate PM Counters bigger than    PM_dir=${PM_dir1}    PM_counter=M55308C29006    expected_value=200

Verify 8541 counters decrementing
    Wait until the next Measurement Period starts
    Wait until the next Measurement Period starts
    ${PM_dir1}=     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
    Validate PM Counters Cell2    PM_dir=${PM_dir1}    PM_counter=M55351C01001    expected_value=1
    Validate PM Counters Cell2    PM_dir=${PM_dir1}    PM_counter=M55351C01002    expected_value=1
    Validate PM Counters Cell2    PM_dir=${PM_dir1}    PM_counter=M55351C00001    expected_value=0
    Validate PM Counters Cell2    PM_dir=${PM_dir1}    PM_counter=M55351C00002    expected_value=0
    Validate PM Counters Cell2    PM_dir=${PM_dir1}    PM_counter=M55308C28009    expected_value=0
    Validate PM Counters Cell2    PM_dir=${PM_dir1}    PM_counter=M55308C28010    expected_value=0
    Validate PM Counters Cell2    PM_dir=${PM_dir1}    PM_counter=M55308C28011    expected_value=0
    Validate PM Counters Cell2    PM_dir=${PM_dir1}    PM_counter=M55308C28012    expected_value=0
    Validate PM Counters Cell2    PM_dir=${PM_dir1}    PM_counter=M55308C29005    expected_value=0
    Validate PM Counters Cell2    PM_dir=${PM_dir1}    PM_counter=M55308C29006    expected_value=0

Verify 8541 PM counters decrementing
    Wait For Next Full Pm Interval
    Wait For Next Full Pm Interval
    ${pm_counters}    Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...    M55351C01001    1      MAX_UE_CONFIG_2BWP
    ...    M55351C01002    1      AVG_UE_CONFIG_2BWP
    ...    M55351C00001    0      MAX_UE_ACTIVE_PWR_SAVING_BWP
    ...    M55351C00002    0      AVG_UE_ACTIVE_PWR_SAVING_BWP
    ...    M55308C28009    0      ACC_UE_DL_SCH_SLOT_BWP_PS
    ...    M55308C28010    0      MAX_UE_DL_SCH_SLOT_BWP_PS
    ...    M55308C28011    0      ACC_UE_UL_SCH_SLOT_BWP_PS
    ...    M55308C28012    0      MAX_UE_UL_SCH_SLOT_BWP_PS
    ...    M55308C29005    0      PRB_USED_PDSCH_BWP_PS
    ...    M55308C29006    0      PRB_USED_PUSCH_BWP_PS
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counters}

Verify 8541 PM counters incrementing
    Wait For Next Full Pm Interval
    ${pm_counters}    Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...    M55351C01001    1      MAX_UE_CONFIG_2BWP
    ...    M55351C01002    1      AVG_UE_CONFIG_2BWP
    ...    M55351C00001    1      MAX_UE_ACTIVE_PWR_SAVING_BWP
    ...    M55351C00002    1      AVG_UE_ACTIVE_PWR_SAVING_BWP
    ...    M55308C28009    >200      ACC_UE_DL_SCH_SLOT_BWP_PS
    ...    M55308C28010    1      MAX_UE_DL_SCH_SLOT_BWP_PS
    ...    M55308C28011    >200      ACC_UE_UL_SCH_SLOT_BWP_PS
    ...    M55308C28012    1      MAX_UE_UL_SCH_SLOT_BWP_PS
    ...    M55308C29005    >200      PRB_USED_PDSCH_BWP_PS
    ...    M55308C29006    >200      PRB_USED_PUSCH_BWP_PS
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...    file_path=${pm_counters}

Validate PM Counters Cell2
    [Arguments]    ${PM_dir}     ${PM_counter}
    log to console    ${PM_dir}     ${PM_counter}


Attach UE and Trigger A3 Measurement
    Start Collecting Syslog     NAME=scell_add
    X2AP Link Should be UP
    LTE Attach should be Successful    ${UE_ID_1}
    sleep     10s
    UE Attach should be Successful    ${UE_ID_1}     ${Target_Cells}
    Get Configured Measurements of UE${UE_ID_1}
    sleep      30s
    Run Keyword and Ignore error     Trigger A3 RsrpAndRsrq Measurement for intragnb HO_1   ${UE_ID_1}    ${a3meas_id}   58

Trigger A3 RsrpAndRsrq Measurement for intragnb HO_1
    [Arguments]     ${ue_id}    ${meas_id}    ${phycell_id}=50
    wtsrunner.ue_measurement_send_nr    id=${ue_id}    meas_id=${meas_id}    event=A3    srsrp_nr=1    srsrq_nr=1    phycell_id=${phycell_id}
    ...   nrsrp_nr=30    nrsrq_nr=20
	${output}   wtsrunner.read_wtsemu_output_until_re    expected=ReconfigurationComplete   timeout=15
    ${output}         Get Lines Matching Regexp    ${output}    ReconfigurationComplete   partial_match=${TRUE}
    Log to Console    ${output}


Start Big Data and trigger A1 for scell addition
    Start Big DL Data Transfer And Check SCell Activation for 2CC NSA_1
    Trigger A1 Measurement and verify Scell added successfully_1   ${UE_ID_1}    ${a1meas_id}
    sleep    10s
    Run Keyword and Ignore error    Validate DL Traffic For NSA for Maximum high data   ue_id=${UE_ID_1}     dl_rate=450
    UE Detach should be Successful
    LTE Attach should be Successful    ${UE_ID_1}
    UE Attach should be Successful    ${UE_ID_1}     8
    Get Configured Measurements of UE${UE_ID_1}
    Start Big DL Data Transfer And Check SCell Activation for 2CC NSA_1
    Trigger DL Traffic for NSA    ue_id=${UE_ID_1}    Traffic_rate=mbps     dl_rate=170       trf_id=5
    sleep   5s
    Trigger DL Traffic for NSA    ue_id=${UE_ID_1}    Traffic_rate=mbps     dl_rate=170       trf_id=6
    sleep   5s
    Trigger DL Traffic for NSA    ue_id=${UE_ID_1}    Traffic_rate=mbps     dl_rate=170       trf_id=7
    Sleep   5s
    Trigger DL Traffic for NSA    ue_id=${UE_ID_1}    Traffic_rate=mbps     dl_rate=170       trf_id=8
    Sleep   10s
    Trigger A1 Measurement and verify Scell added successfully_1   ${UE_ID_1}    ${a1meas_id}
    sleep    100s
    Run Keyword and Ignore error   Stop Collecting Syslog      NAME=scell_add
    Run Keyword and continue on failure    Verify Counters_scelladd_M55115C03002    2
    Run Keyword and continue on failure    Verify Counters_scelladdition    300    300     27000    1

Start Big DL Data Transfer And Check SCell Activation for 2CC NSA_1
    Trigger DL Traffic for NSA    ue_id=${UE_ID_1}    Traffic_rate=mbps     dl_rate=170       trf_id=${TRF_ID}
    sleep   5s
    Trigger DL Traffic for NSA    ue_id=${UE_ID_1}    Traffic_rate=mbps     dl_rate=170       trf_id=${TRF_ID2}
    sleep   5s
    Trigger DL Traffic for NSA    ue_id=${UE_ID_1}    Traffic_rate=mbps     dl_rate=170       trf_id=${TRF_ID3}
    Sleep   5s
    Trigger DL Traffic for NSA    ue_id=${UE_ID_1}    Traffic_rate=mbps     dl_rate=170       trf_id=${TRF_ID4}
    sleep   15s    reason=Wait for successful traffic start

Trigger A1 Measurement and verify Scell added successfully_1
    [Arguments]     ${ue_id}    ${meas_id}     ${loc_BW}=
    wtsrunner.ue_measurement_send_nr    id=${ue_id}    meas_id=${meas_id}     event=A1     srsrp_nr=80      srsrq_nr=20
	${output}   wtsrunner.read_wtsemu_output_until_re    expected=.*activated successfully.*  timeout=100
    Get Lines Matching Regexp    ${output}    CellIndex \\d+ activated successfully  partial_match=${TRUE}
#    Run Keyword and Continue on failure     BuiltIn.Should Match Regexp     ${output}    locationAndBandwidth\\s${loc_BW}
    Run Keyword and Continue on failure     BuiltIn.Should Match Regexp     ${output}
    ...     sCellConfigDedicated.*\\n.*\\n.*\\n.*\\n.*\\n.*\\n.*\\n.*\\n.*\\n.*\\n.*locationAndBandwidth\\s${loc_BW}
    Log to Console    ${output}

Start Low Data Traffic And Check Scell Deactivation
    Start Collecting Syslog     NAME=scell_remove
    TRF Data Stop for NSA     ue_id=${UE_ID_1}     Bearer_ID=${Bearer_ID}     trf_id=1     dir=dl
    TRF Data Stop for NSA     ue_id=${UE_ID_1}     Bearer_ID=${Bearer_ID}     trf_id=2     dir=dl
    TRF Data Stop for NSA     ue_id=${UE_ID_1}     Bearer_ID=${Bearer_ID}     trf_id=3     dir=dl
    TRF Data Stop for NSA     ue_id=${UE_ID_1}     Bearer_ID=${Bearer_ID}     trf_id=4     dir=dl
    TRF Data Stop for NSA     ue_id=${UE_ID_1}     Bearer_ID=${Bearer_ID}     trf_id=5     dir=dl
    TRF Data Stop for NSA     ue_id=${UE_ID_1}     Bearer_ID=${Bearer_ID}     trf_id=6     dir=dl
    TRF Data Stop for NSA     ue_id=${UE_ID_1}     Bearer_ID=${Bearer_ID}     trf_id=7     dir=dl
    TRF Data Stop for NSA     ue_id=${UE_ID_1}     Bearer_ID=${Bearer_ID}     trf_id=8     dir=dl
    Trigger DL Traffic for NSA     ue_id=${UE_ID_1}     Traffic_rate=kbps     dl_rate=10     trf_id=1
    sleep    5s
    Trigger UL Traffic for NSA     ue_id=${UE_ID_1}     Traffic_rate=kbps     ul_rate=10     trf_id=1
    sleep    5s     reason=Wait for successful traffic start
    Run Keyword And Continue on Failure    wtsrunner.read_wtsemu_output_until_prompt    timeout=10
    Run Keyword and Ignore error   Verify Low Data Traffic NSA
    Run Keyword and Ignore error    Stop Collecting Syslog      NAME=scell_remove
    Validate DL Traffic For NSA   ue_id=${UE_ID_1}     dl_rate=0.010
    UE Detach should be Successful
    Run Keyword and Ignore error    Verify Counters_scelldeactivation    300    0    0    0    0


Verify Counters_scelladdition
    [Arguments]    ${EXPECTED_PCELL_VALUE1}    ${EXPECTED_PCELL_VALUE2}      ${EXPECTED_SCELL_VALUE1}    ${EXPECTED_SCELL_VALUE2}
    Wait For Next Full Pm Interval
    ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55167C00001   ${EXPECTED_PCELL_VALUE1}    SAMPLES_BWP_UE_AMOUNTS
    ...     M55308C28001    >${EXPECTED_SCELL_VALUE1}    ACC_UE_DL_SCH_SLOT_BWP1
	...     local_moid=MRBTS-1/NRBTS-1/NRCELL-8
    ...     file_path=${pm_counter_file}
    Verify Last Counters In File
    ...     M55167C00003    ${EXPECTED_PCELL_VALUE2}    SUM_UE_SCELL_CONF_L_BWP
    ...     M55308C28002    ${EXPECTED_SCELL_VALUE2}    MAX_UE_DL_SCH_SLOT_BWP1
	...     local_moid=MRBTS-1/NRBTS-1/NRCELL-8
    ...     file_path=${pm_counter_file}


Verify Counters_scelldeactivation
    [Arguments]    ${EXPECTED_PCELL_VALUE1}    ${EXPECTED_PCELL_VALUE2}      ${EXPECTED_PCELL_VALUE3}      ${EXPECTED_SCELL_VALUE1}
    ...       ${EXPECTED_SCELL_VALUE2}
    Wait For Next Full Pm Interval
    ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55167C00001   ${EXPECTED_PCELL_VALUE1}    SAMPLES_BWP_UE_AMOUNTS
	...     local_moid=MRBTS-1/NRBTS-1/NRCELL-2
    ...     file_path=${pm_counter_file}
    Verify Last Counters In File
    ...     M55167C00002    ${EXPECTED_PCELL_VALUE2}    SUM_UE_SCELL_CONF_S_BWP
    ...     M55115C03001    ${EXPECTED_PCELL_VALUE3}    SGNB_DU_SCELL_ADM_S_BWP_SUCC
    ...     M55308C28001    ${EXPECTED_SCELL_VALUE1}    SAMPLES_BWP_UE_AMOUNTS
    ...     M55308C28002    ${EXPECTED_SCELL_VALUE2}    MAX_UE_DL_SCH_SLOT_BWP1
	...     local_moid=MRBTS-1/NRBTS-1/NRCELL-8
    ...     file_path=${pm_counter_file}


Validate PM Counters_scell
    [Arguments]    ${PM_dir}     ${PM_counter}    ${expected_value}    ${moc}
    PM_Counters.Check PM counter value equal    expected_value=${expected_value}   pm_files_location=${PM_dir}
    ...  pi_id=${PM_counter}    moc=${moc}

Validate PM Counters bigger than_scell
    [Arguments]    ${PM_dir}     ${PM_counter}    ${expected_value}      ${moc}
    PM_Counters.Check PM counter value bigger than    expected_value=${expected_value}   pm_files_location=${PM_dir}
    ...  pi_id=${PM_counter}    moc=${moc}



Verify Counters incrementing Inter GNB HO M55139C04001
    [Arguments]     ${EXPECTED_PCELL_VALUE3}
    Wait For Next Full Pm Interval
    ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55139C04001    ${EXPECTED_PCELL_VALUE3}     GNB_DU_SCELL_ADM_S_BWP_SUCC
	...     local_moid=MRBTS-1/NRBTS-1/NRCELL-8
    ...     file_path=${pm_counter_file}


Verify Counters_scelladd_M55115C03002
    [Arguments]     ${EXPECTED_PCELL_VALUE3}
    Wait For Next Full Pm Interval
    ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55115C03002    ${EXPECTED_PCELL_VALUE3}     GNB_DU_SCELL_ADM_L_BWP_SUCC
	...     local_moid=MRBTS-1/NRBTS-1/NRCELL-8
    ...     file_path=${pm_counter_file}

#CB008541 TMO migration



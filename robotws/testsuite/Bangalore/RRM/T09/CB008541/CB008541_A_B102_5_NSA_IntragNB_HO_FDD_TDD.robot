*** Settings ***
Force Tags      CLOUD_5G_I_LO_AP_LO    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_AEQE_GMC

...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS00    CONFIGURED

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
Library          Collections
Resource         resources/CB008541_Keywords.robot
Library          ta5g_pm_counters
Library          taf.sw.scout    WITH NAME     scout



Suite Setup         Run keywords    Suite setup from scratch
...                 AND     Check gNB Bulid
...                 AND    Perform SCF Delta Commissioning with A_B102_5.json
...                 AND     Prepare TL with IPHY file change
...                 AND     Load CFG Config And Verify BWP-List During cell setup in Capture CPRT Traces      ${wts_cfg_file}
...                 AND     Sleep    100s


Suite Teardown      Run keywords   Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
...                 AND     Run Keyword and Ignore Error    Get Snapshot
...                 AND     Run Keyword and Ignore Error    Get Sos Report
...                 AND     Run Keyword and Ignore Error    Stop Default Processes And Gather Logs And Compress Logs

Test Setup       Start_capture_testcase_default_logging
Test Teardown    Run Keywords     Stop Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}
...                 AND     Link SCOUT SCF to Configuration ID for Reporting

*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/egate_TMOUS_1.cfg
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}          /opt/iphy/latest
${UE_ID}        101
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
${epc_log_path}    /tmp/
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

*** Test Cases ***
[1]CB008541_A_B102_5_NSA_UEsupporting_Pcell_SBWP_SCell_SBWP_IntragnbHO_for_FDD_TDD_2CC_CA
    [Documentation]  CB008541_A_B102_5_NSA_UEsupporting_Pcell_SBWP_SCell_SBWP_IntragnbHO_for_FDD_TDD_2CC_CA

    ${LOG_PATH}  Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
    Attach UE and Trigger A3 Measurement
    Start Big Data and trigger A1 for scell addition
    Start Low Data Traffic And Check Scell Deactivation

*** Keywords ***
Attach UE and Trigger A3 Measurement
    Start Collecting Syslog     NAME=scell_add
    X2AP Link Should be UP
    LTE Attach should be Successful    ${UE_ID}
    sleep     10s
    UE Attach should be Successful    ${UE_ID}     ${Target_Cells}
    Get Configured Measurements of UE${UE_ID}
    sleep      30s
    Run Keyword and Ignore error     Trigger A3 RsrpAndRsrq Measurement for intragnb HO_1   ${UE_ID}    ${a3meas_id}   58

Trigger A3 RsrpAndRsrq Measurement for intragnb HO_1
    [Arguments]     ${ue_id}    ${meas_id}    ${phycell_id}=50
    wtsrunner.ue_measurement_send_nr    id=${ue_id}    meas_id=${meas_id}    event=A3    srsrp_nr=1    srsrq_nr=1    phycell_id=${phycell_id}
    ...   nrsrp_nr=30    nrsrq_nr=20
	${output}   wtsrunner.read_wtsemu_output_until_re    expected=ReconfigurationComplete   timeout=15
    ${output}         Get Lines Matching Regexp    ${output}    ReconfigurationComplete   partial_match=${TRUE}
    Log to Console    ${output}


Start Big Data and trigger A1 for scell addition
    Start Big DL Data Transfer And Check SCell Activation for 2CC NSA
    Trigger A1 Measurement and verify Scell added successfully_1   ${UE_ID}    ${a1meas_id}
    sleep    10s
    Run Keyword and Ignore error    Validate DL Traffic For NSA for Maximum high data   ue_id=${UE_ID}     dl_rate=450
    UE Detach should be Successful
    LTE Attach should be Successful    ${UE_ID}
    UE Attach should be Successful    ${UE_ID}     8
    Get Configured Measurements of UE${UE_ID}
    Start Big DL Data Transfer And Check SCell Activation for 2CC NSA
    Trigger DL Traffic for NSA    ue_id=${UE_ID}    Traffic_rate=mbps     dl_rate=170       trf_id=5
    sleep   5s
    Trigger DL Traffic for NSA    ue_id=${UE_ID}    Traffic_rate=mbps     dl_rate=170       trf_id=6
    sleep   5s
    Trigger DL Traffic for NSA    ue_id=${UE_ID}    Traffic_rate=mbps     dl_rate=170       trf_id=7
    Sleep   5s
    Trigger DL Traffic for NSA    ue_id=${UE_ID}    Traffic_rate=mbps     dl_rate=170       trf_id=8
    Sleep   10s
    Trigger A1 Measurement and verify Scell added successfully_1   ${UE_ID}    ${a1meas_id}
    sleep    100s
    Run Keyword and Ignore error   Stop Collecting Syslog      NAME=scell_add
    Run Keyword and continue on failure    Verify Counters_scelladd_M55115C03002    2
    Run Keyword and continue on failure    Verify Counters_scelladdition    300    300     27000    1

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
    TRF Data Stop for NSA     ue_id=${UE_ID}     Bearer_ID=${Bearer_ID}     trf_id=1     dir=dl
    TRF Data Stop for NSA     ue_id=${UE_ID}     Bearer_ID=${Bearer_ID}     trf_id=2     dir=dl
    TRF Data Stop for NSA     ue_id=${UE_ID}     Bearer_ID=${Bearer_ID}     trf_id=3     dir=dl
    TRF Data Stop for NSA     ue_id=${UE_ID}     Bearer_ID=${Bearer_ID}     trf_id=4     dir=dl
    TRF Data Stop for NSA     ue_id=${UE_ID}     Bearer_ID=${Bearer_ID}     trf_id=5     dir=dl
    TRF Data Stop for NSA     ue_id=${UE_ID}     Bearer_ID=${Bearer_ID}     trf_id=6     dir=dl
    TRF Data Stop for NSA     ue_id=${UE_ID}     Bearer_ID=${Bearer_ID}     trf_id=7     dir=dl
    TRF Data Stop for NSA     ue_id=${UE_ID}     Bearer_ID=${Bearer_ID}     trf_id=8     dir=dl
    Trigger DL Traffic for NSA     ue_id=${UE_ID}     Traffic_rate=kbps     dl_rate=10     trf_id=1
    sleep    5s
    Trigger UL Traffic for NSA     ue_id=${UE_ID}     Traffic_rate=kbps     ul_rate=10     trf_id=1
    sleep    5s     reason=Wait for successful traffic start
    Run Keyword And Continue on Failure    wtsrunner.read_wtsemu_output_until_prompt    timeout=10
    Run Keyword and Ignore error   Verify Low Data Traffic NSA      ue_id=${UE_ID}
    Run Keyword and Ignore error    Stop Collecting Syslog      NAME=scell_remove
    Validate DL Traffic For NSA   ue_id=${UE_ID}     dl_rate=0.010
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

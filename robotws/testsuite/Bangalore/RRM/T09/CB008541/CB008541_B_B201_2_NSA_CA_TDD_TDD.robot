*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO      VARIANT_SANSA_FS_ECPRI_CMWV_TDD
...           CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD     5G_RAN     SBTS00     CONFIGURED

Documentation    :copyright: Nokia
...              :authors: Chaithanya
...              :contact: Chaithanya.h_s@nokia.com
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
...         This user scenario describes the common gNB behavior with regards to CA UE context setup when UE supporting
...         small BWP for Pcell and small BWP for Scell.
...         dedicated BWP profiles linked to the P(S)Cell.
...         large BWP with bandwidth equal to the cell bandwidth.
...         small BWP with bandwidth equal or higher than half of the cell bandwidth and lower than the large BWP.
...         "small", "large"  BWP profiles  linked to the PCell  have configured different PDCCH setings for User
...         Specific search space and have different coreset.
...         dedicated BWP profiles linked to the SCell.
...         large BWP with bandwidth equal to the cell bandwidth.
...         small BWP with bandwidth equal or higher than half of the cell bandwidth and lower than the large BWP.
...         "small", "large"BWP profiles  linked to the SCell  have configured different PDCCH setings for
...         User Specific search space and have different coreset.


Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Resource         resources/CB008541_Keywords.robot
Library          resources/avg_dl_data.py
Library          ta5g_pm_counters
Resource         CB008541_A_B301_4_ABIN_SA_RRE_CA_TDD_TDD.robot

Suite Setup         Run keywords   Suite setup from scratch
...                 AND     5GC000937_Keywords.Perform SCF Delta Commissioning with Delta_CB008541_B_B201_2_NSA.json
...                 AND     Sleep     120s
...                 AND     5GC000937_Keywords.Perform SCF Delta Commissioning with Delta_CB008541_A_301_RRE_TMO.json
...                 AND     Sleep     120s
...                 AND     Prepare TL with IPHY file change
...                 AND     Reboot gNB System Module from Console and check Airscale is ready
...                 AND     Check and active the BTS l2ps DBG log
...                 AND     Load CFG Config And Verify BWP-List During cell setup in Capture CPRT Traces      ${wts_cfg_file}
...                 AND     Check gNB Bulid

Suite Teardown    Run Keywords     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
...                 AND     Run Keyword and Ignore Error    Get Snapshot
...                 AND     Run Keyword and Ignore Error    Get Sos Report
...                 AND     Run Keyword and Ignore Error    Stop Default Processes And Gather Logs And Compress Logs


Test Setup       Start_capture_testcase_default_logging
Test Teardown     Run keywords   Stop Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}
...                 AND     Link SCOUT SCF to Configuration ID for Reporting

*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/egate_TMOUS_b201_b301.cfg
&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
${WTS_DIR}          /opt/iphy/latest
${UE_ID_NSA}    101
${UE_ID_NSA_1}    102
${nwslice_ID}   1
${gw_ID}     1
${Pdu_session_ID}       1
${QFI_ID}    1
${TRF_ID}    1
${TRF_ID2}    2
${TRF_ID3}    3
${TRF_ID4}    4
${epc_log_path}    /tmp/
${Bearer_ID}    2
${PM_PCELL_COUNTER1}    M55167C00001
${PM_PCELL_COUNTER2}    M55167C00002
${PM_PCELL_COUNTER3}    M55115C03001
${PM_SCELL_COUNTER1}    M55308C28001
${PM_SCELL_COUNTER2}    M55308C28002
${AP_XML}=                 ${CURDIR}/config/iphy_B201.xml


*** Test Cases ***
[1]CB008541_5G_B_B201_2_NSA_UE_supports_SBWP_TDD_TDD_Scell_addition_with_differerent_coreset_7552_8541-A_enabled
    [Documentation]    In this testcase common gNB behavior with regards to CA UE context setup
     ...        when UE supporting small BWP for Pcell and small BWP for Scell
    [Setup]       Start_capture_testcase_default_logging
	[Tags]  TC01
    ${LOG_PATH}  Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
    Regiter UE And Verify Scell Addition On High Data Traffic
	Verify Scell Deactivation On Low Data Traffic    101
    Verify Scell Deactivation On Low Data Traffic    102
    Run Keyword And Continue on Failure    Verify 8541 counters decrementing
	[Teardown]    Run Keywords   Stop Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}
    ...                 AND     Check resource hanging
    ...    AND       Link SCOUT SCF to Configuration ID for Reporting

[1]CB008541_A_B301_4_SA_UEsupporting_Pcell_LBWP_SCell_SBWP_UEReestablish_for_TDD_TDD_2CC_CA
    [Documentation]  CB008541_A_B201_4_SA_UEsupporting_Pcell_LBWP_SCell_SBWP_UEReestablish_for_TDD_FDD_2CC_CA
    [Setup]       Start_capture_testcase_default_logging
    [Tags]  TC02
    Set Test Variable  ${UE_ID}  5
    Run CB008541_A_B301_4_SA_UEsupporting_Pcell_LBWP_SCell_SBWP_UEReestablish_for_TDD_TDD_2CC_CA
    [Teardown]    Run Keywords   Stop Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}
    ...    AND       Link SCOUT SCF to Configuration ID for Reporting

*** Keywords ***
Regiter UE And Verify Scell Addition On High Data Traffic
    X2AP Link Should be UP
    NSA Ue Attach Should Be Successful cell    101    102
	Get Configured Measurements of UE${UE_ID_NSA}
	Trigger A1 Measurement and verify Scell added successfully    101    4    31624
    Trigger DL Traffic for NSA    ue_id=101    Traffic_rate=mbps     dl_rate=170       trf_id=3
    sleep   5s    reason=Wait for successful traffic start
    Trigger DL Traffic for NSA    ue_id=101    Traffic_rate=mbps     dl_rate=170       trf_id=4
    sleep   5s
    Trigger DL Traffic for NSA    ue_id=101    Traffic_rate=mbps     dl_rate=170       trf_id=5
    sleep   5s    reason=Wait for successful traffic start

    Trigger DL Traffic for NSA    ue_id=102    Traffic_rate=mbps     dl_rate=170       trf_id=2
    sleep   5s
    Get Configured Measurements of UE${UE_ID_NSA_1}
    Trigger A1 Measurement and verify Scell added successfully    102    4    31624
    Trigger DL Traffic for NSA    ue_id=102    Traffic_rate=mbps     dl_rate=170       trf_id=3
    Trigger DL Traffic for NSA    ue_id=102    Traffic_rate=mbps     dl_rate=170       trf_id=4
    sleep   5s
    Trigger DL Traffic for NSA    ue_id=102    Traffic_rate=mbps     dl_rate=170       trf_id=5
    sleep   5s    reason=Wait for successful traffic start
    Validate DL Traffic For NSA for high data   ue_id=${UE_ID_NSA}     dl_rate=219
    Verify DL Tput For 2CC NSA    101
    Verify DL Tput For 2CC NSA    102
    Run Keyword And Continue on Failure    Verify 8541 counters incrementing

NSA Ue Attach Should Be Successful cell
    [Arguments]     ${Start_ue_nsa}    ${End_ue_nsa}
    FOR   ${UE}    IN RANGE    ${Start_ue_nsa}    ${End_ue_nsa}+1
    LTE Attach should be Successful    ${UE}
    END
    FOR   ${UE}    IN RANGE    ${Start_ue_nsa}    ${End_ue_nsa}+1
    UE Attach should be Successful    ${UE}
    END
    Trigger DL Traffic for NSA    ue_id=101    Traffic_rate=mbps     dl_rate=170       trf_id=1
    sleep   5s
    Trigger DL Traffic for NSA    ue_id=101    Traffic_rate=mbps     dl_rate=170       trf_id=2
    sleep   5s
    Trigger DL Traffic for NSA    ue_id=102    Traffic_rate=mbps     dl_rate=170       trf_id=1
    sleep   5s

Verify Scell Deactivation On Low Data Traffic
    [Arguments]    ${UE_ID}
    Start Low Data Traffic And Check Scell Deactivation    ${UE_ID}
    Run Keyword And Continue on Failure    wtsrunner.read_wtsemu_output_until_prompt    timeout=10
    Verify Low Data Traffic NSA    ${UE_ID}
	Run Keyword and Ignore Error    Validate DL Traffic For NSA   ue_id=${UE_ID}     dl_rate=0.010
    Run Keyword and Ignore Error    Validate UL Traffic For NSA   ue_id=${UE_ID}     ul_rate=0.010
    UE Detach should be Successful    ${UE_ID}

Start Low Data Traffic And Check Scell Deactivation
    [Arguments]    ${UE_ID}
    Run Keyword and Ignore Error    TRF Data Stop for NSA    ue_id=${UE_ID}    Bearer_ID=${Bearer_ID}    trf_id=1    dir=dl
    TRF Data Stop for NSA    ue_id=${UE_ID}    Bearer_ID=${Bearer_ID}    trf_id=2    dir=dl
    TRF Data Stop for NSA    ue_id=${UE_ID}    Bearer_ID=${Bearer_ID}    trf_id=3    dir=dl
    TRF Data Stop for NSA    ue_id=${UE_ID}    Bearer_ID=${Bearer_ID}    trf_id=4    dir=dl
    TRF Data Stop for NSA    ue_id=${UE_ID}    Bearer_ID=${Bearer_ID}    trf_id=5    dir=dl
    Trigger DL Traffic for NSA    ue_id=${UE_ID}    Traffic_rate=kbps     dl_rate=10       trf_id=1
    sleep   5s
    Trigger UL Traffic for NSA    ue_id=${UE_ID}    Traffic_rate=kbps     ul_rate=10       trf_id=1
    sleep   5s    reason=Wait for successful traffic start

Verify 8541 counters incrementing SCELL SUCC
    Wait For Next Full Pm Interval
    ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55115C03001    1    SGNB_DU_SCELL_ADM_S_BWP_SUCC
    ...     local_moid=MRBTS-1/NRBTS-1/NRCELL-1
    ...     file_path=${pm_counter_file}

Verify 8541 counters incrementing
    Wait For Next Full Pm Interval
    ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55115C03001    2    SGNB_DU_SCELL_ADM_S_BWP_SUCC
    ...     M55167C00001    300    SAMPLES_BWP_UE_AMOUNTS
    ...     M55167C00002    >200    SUM_UE_SCELL_CONF_S_BWP
    ...     M55308C28001    >10000    ACC_UE_DL_SCH_SLOT_BWP1
    ...     M55308C28002    2    MAX_UE_DL_SCH_SLOT_BWP1
    ...     local_moid=MRBTS-1/NRBTS-1/NRCELL-1
    ...     file_path=${pm_counter_file}

Verify 8541 counters decrementing
    Wait For Next Full Pm Interval
    Wait For Next Full Pm Interval
    ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55115C03001    0    SGNB_DU_SCELL_ADM_S_BWP_SUCC
	...     M55167C00001    300    SAMPLES_BWP_UE_AMOUNTS
    ...     M55167C00002    0    SUM_UE_SCELL_CONF_S_BWP
    ...     M55308C28001    0    ACC_UE_DL_SCH_SLOT_BWP1
    ...     M55308C28002    0    MAX_UE_DL_SCH_SLOT_BWP1
    ...     local_moid=MRBTS-1/NRBTS-1/NRCELL-1
	...     file_path=${pm_counter_file}

Check resource hanging
    [Documentation]  Ask on AAshell resources usages, after end of TC it is expected to have no user resources usage
    ${rc}  ${output} =  Run and Return RC and Output  python /home/ute/robotws/testsuite/Bangalore/resources/python/hanging.py ${OUTPUT_DIR}
    log to console  Resource hanging: ${output}
    run keyword if  '${rc}'=='1'  log to console  /!\ Warning /!\ It seems resources are hanging. Check for ghost CRNTI



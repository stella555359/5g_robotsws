*** Settings ***
Force Tags      CLOUD_5G_I_LOO_AP_LOOO    SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD_TMO_65
...             CRT    RAN_5G_TDD    RAN_5G    5G_RAN_TDD    5G_RAN     SBTS00    TOOLS_PROFILE_TTI_LEGACY

Documentation    :copyright: Nokia
...              :author: Ganesha, Sowrabha, Sunil
...              :contact:
...         The aim of the 5GC000937 feature is to allow power savings for UE with small throughput traffic.
...         The scope of the feature is limited to FR1 TDD for UEs in SA mode.
...         The strategy for UE power savings is based on the possibility of dynamic switch between a BWP with large bandwidth size
...         (often configured with full carrier bandwidth size)
...         and a "power saving BWP" with a narrow bandwidth size.
...         The feature is considered as being efficient when the powersavingBWP bandwidth size is a small fraction of the largeBWP bandwidth size.
...         A typical example is for carrier bandwidth size 100Mhz, the large BWP covers the full carrier Bw and the
...         power saving BWP bandwidth size is 20Mhz.
...         The dynamic decision for which BWP to use is based on some configurable criteria including UL/DL data rate and UL/DL buffer length.
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
...         This suite covers-
...         [1]CB008541_5G_B_B002_5_Verify_SA_TDD_UE_supports_bandwidth_switching_of_SBWP_and_PSBWP_using_1116_Framestructure
...         [1]CB008541_5G_B_B004_3_Verify_UE_Connects_From_gnb_With_Configured_PS_BWP_To_gnb_Without_Configured_PS_BWP_Via_Inter_Gnb_HO
...         [1]CB008541_5G_B_B101_1_Verify_NonVONR_PS_BWP_switching_allowed_only_upto_maxNumberUesPowerSaving_Ues_7552_937_enabled

Resource         resources/CB008541_Keywords.robot
Resource         ../../../resources/robot/common_log_collection.robot
Library          taf.sw.scout    WITH NAME     scout
Library          ta5g_pm_counters
Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Library          Collections
Resource         ./CB008541_B_B002_5_PSBWP_Switching_1116_framestructure_BF.robot
Resource         ./CB008541_B_B004_3_PSBWP_Switching_Inter_Gnb_HO.robot

Suite Setup         Run keywords    Run Keyword and Ignore Error    Suite setup from scratch
...                 AND     Perform SCF Delta Commissioning with Inter_GNB.json
...                 AND     Perform SCF Delta Commissioning with B_B004_3_inter_gNB_HO_TMO.json
...                 AND     Sleep     120s
...                 AND     Prepare TL with IPHY file change
...                 AND     Reboot gNB System Module from Console and check Airscale is ready
#...                 AND     Check and active the BTS l2ps DBG log
...                 AND     Load CFG Config And Verify BWP-List During cell setup in Capture CPRT Traces      ${wts_cfg_file}
...                 AND     Check gNB Bulid

#Suite Teardown    Run Keywords     Run Keyword and Ignore Error    Kill WTS processes Using WTS_Runner
#...                 AND     Run Keyword and Ignore Error    Get Snapshot
#...                 AND     Run Keyword and Ignore Error    Get Sos Report
#...                 AND     Run Keyword and Ignore Error   Stop Default Processes And Gather Logs And Compress Logs


Test Setup       Start_capture_testcase_default_logging
Test Teardown    Stop Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}

*** Variables ***
${wts_cfg_file}     ${CURDIR}/config/basic_setup_MaxUE_Beamswitch_XnHO.cfg
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
${largebwp_id}     1
${smallbwp_id}     2
${psbwp_id_3}         3
@{pysical_cell_ids}    53
@{pysical_cell_ids1}    51
${counter_value_cell1}
${AP_XML}=                 ${CURDIR}/config/8541_B_B004_3_TMO_iphy.xml
${Large_UE}     M55308C28006
${Small_UE}     M55308C28002

*** Test Cases ***
[1]CB008541_5G_B_B002_5_Verify_SA_TDD_UE_supports_bandwidth_switching_of_SBWP_and_PSBWP_using_1116_Framestructure
    [Tags]    TC01
    [Documentation]   in this testcase verify that 5G NR powerSaving BWP capable UE configured with large BWP and Power
     ...        Saving BWP during UE context setup with cell bw of 100Mhz. In the beginning when successful DL/UL data transfer
     ...        initiated verify that data transfer happens in the large BWP,
     ...        DCI switch to PS BWP happens using DCI format 1_1, when data rates are less than thresholds.
     ...        DCI switch to large BWP happens, when DL data rate is more than the thresholds.
    [Setup]       Start_capture_testcase_default_logging
    ${LOG_PATH}  Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
    Run Scenario B_B002_5_Verify_SA_TDD_UE_supports_bandwidth_switching_of_SBWP_and_PSBWP_using_1116_Framestructure
    [Teardown]    Run keywords    Stop Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}
	...           AND     Run Keyword And Ignore Error    Run Keyword If Test Failed    Stop Log    cprt    biptaf   test_scenario=TC1_Failed
    ...           AND     Link SCOUT SCF to Configuration ID for Reporting

[1]CB008541_5G_B_B004_3_Verify_UE_Connects_From_gnb_With_Configured_PS_BWP_To_gnb_Without_Configured_PS_BWP_Via_Inter_Gnb_HO
    [Documentation]   in this testcase verify that 5G NR powerSaving BWP cabable  UE configured with large BWP, small BWP and
    ...         Power Saving BWP during UE context setup. in the beginning when successful DL/UL data transfer initiated
    ...         verify that data transfer happens in the large BWP,
    ...        DCI switch to PS BWP happens using DCI format 1_1, when data rates are less than thresholds.
    ...        DCI switch to large BWP happens, when DL data rate is more than the thresholds.
    ...        Verify ScellA is deactivated and not used for UL/DL data transmissions when using power saving BWP. Data is switched back to Pcell.
    ...         Verify ScellA is activated and data transmission is on small BWP.
    [Tags]    TC02
	set test variable      ${LOG_PATH}
    Run Scenario B_B004_3_Verify_UE_Connects_From_gnb_With_Configured_PS_BWP_To_gnb_Without_Configured_PS_BWP_Via_Inter_Gnb_HO
    [Teardown]    Run keywords    Stop Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}
	...       AND     Run Keyword And Ignore Error    Run Keyword If Test Failed    Stop Log    btslog   cprt    biptaf   test_scenario=TC2_Failed
    ...       AND     Link SCOUT SCF to Configuration ID for Reporting

[1]CB008541_5G_B_B101_1_Verify_NonVONR_PS_BWP_switching_allowed_only_upto_maxNumberUesPowerSaving_Ues_7552_937_enabled
    [Tags]    TC03
    [Documentation]     CB008541_5G_B_B101_1_Verify_NonVONR_PS_BWP_switching_allowed_only_upto_maxNumberUesPowerSaving_Ues_7552_937_enabled
    [Setup]       Start_capture_testcase_default_logging
    Register 4 nonVONR UEs and send low data and verify the psbwp through tti trace
    Deregister one nonVONR UE1 which is in PSBWP and verify UE4 enters to PSBWP through tti trace
	Attach new nonVONR UE5 and send low data and verify lbwp through tti trace
	Increase the data of UE2 which is in PSBWP and verify UE5 enters to PSBWP through tti trace
    Run Keyword and Continue On Failure  	Verify 8541 counters incrementing
	Increase the data of all UE and verify moved to dedicated BWP through tti trace
	Run Keyword and Continue On Failure     Verify 8541 counters decrementing
    Deregister all Ues
    Resgister SmallUe and Verify SSB and TRS PDSCH counters
	Resgister LargeUe and Verify SSB and TRS PDSCH counters
	[Teardown]    Run keywords    Stop Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}
    ...       AND     Run Keyword And Ignore Error    Run Keyword If Test Failed    Stop Log    btslog    cprt    biptaf   test_scenario=TC3_Failed
    ...       AND     Link SCOUT SCF to Configuration ID for Reporting

*** Keywords ***
Register 4 nonVONR UEs and send low data and verify the psbwp through tti trace
    ${LOG_PATH}  Set Variable     ${LOG_PATH}/${TEST_NAME}
    set test variable      ${LOG_PATH}
    Start Log    btslog   cprt
    ${NonVONR_UEs_crnti}=    MultiUE Register should be Successful    2    4
	set test variable      ${NonVONR_UEs_crnti}
    ${NonVONR_UEs123_crnti}=   Create List     ${NonVONR_UEs_crnti[0]}    ${NonVONR_UEs_crnti[1]}    ${NonVONR_UEs_crnti[2]}
    ${NonVONR_UEs1_crnti}=   Create List     ${NonVONR_UEs_crnti[0]}
    ${NonVONR_UEs2_crnti}=   Create List     ${NonVONR_UEs_crnti[1]}
    ${NonVONR_UE3_crnti}=   Create List     ${NonVONR_UEs_crnti[2]}
    set test variable      ${NonVONR_UEs123_crnti}
    set test variable      ${NonVONR_UEs2_crnti}
    set test variable      ${NonVONR_UE3_crnti}
    set test variable      ${NonVONR_UEs1_crnti}
    MultiUE Trigger DL Traffic for SA    2    4    Traffic_rate=kbps     dl_rate=15      trf_id=${TRF_ID}
    MultiUE Trigger UL Traffic for SA    2    4    Traffic_rate=kbps     ul_rate=15      trf_id=${TRF_ID}
    ${bwpid}    Create List     ${psbwp_id_3}     ${psbwp_id_3}     ${psbwp_id_3}
    Capture TTI Traces and Validate UE bwpid Per Cell    ${LOG_PATH}    lowdata_3UE    ${NonVONR_UEs123_crnti}    ${bwpid}    ${Branch_22R1}
    ...    pysical_cell_ids=${pysical_cell_ids}
    ${crnti_value_UE4}=   UE Register should be Successful And Fetch RNTI    5    1    1    5
    Set test variable     ${crnti_value_UE4}
    MultiUE Trigger DL Traffic for SA    5    5    Traffic_rate=kbps     dl_rate=15      trf_id=${TRF_ID}
    MultiUE Trigger UL Traffic for SA    5    5    Traffic_rate=kbps     ul_rate=15      trf_id=${TRF_ID}
    ${TC3}    Stop Log    btslog   cprt      test_scenario=TC3_lowdata_4UE
    sleep  10s   reason=data to stable
    Validate DL Traffic For MultiUE for SA    2   5     dl_rate=0.015
    Validate UL Traffic For MultiUE for SA    2   5     ul_rate=0.015
	${bwpid}    Create List     ${smallbwp_id}
	${crnti_UE4}    Create List     ${crnti_value_UE4}
	set test variable     ${crnti_UE4}
    Capture TTI Traces and Validate UE bwpid Per Cell   ${LOG_PATH}    lowdata_4UE    ${crnti_UE4}    ${bwpid}    ${Branch_22R1}
    ...    pysical_cell_ids=${pysical_cell_ids}


Attach new nonVONR UE5 and send low data and verify lbwp through tti trace
    Run Keyword and Ignore Error    Start Collecting Syslog     NAME=Attach_UE5
    Start Log    btslog   cprt
    ${crnti_value_UE5}=   UE Register should be Successful And Fetch RNTI    6    1    1    6
    Set test variable     ${crnti_value_UE5}
    MultiUE Trigger DL Traffic for SA    6    6    Traffic_rate=kbps     dl_rate=15      trf_id=${TRF_ID}
    MultiUE Trigger UL Traffic for SA    6    6    Traffic_rate=kbps     ul_rate=15      trf_id=${TRF_ID}
    ${TC3}    Stop Log    btslog   cprt       test_scenario=TC3_Attach_UE5
    sleep  10s   reason=data to stable
    Validate DL Traffic For SA   ue_id=5     dl_rate=0.015     qfi_id=${QFI_ID}
    Validate UL Traffic For SA   ue_id=5     ul_rate=0.015     qfi_id=${QFI_ID}
	${bwpid}    Create List    ${largebwp_id}
	${crnti_UE5}    Create List    ${crnti_value_UE5}
    Capture TTI Traces and Validate UE bwpid Per Cell   ${LOG_PATH}    new_UE5   ${crnti_UE5}     ${bwpid}    ${Branch_22R1}
    ...    pysical_cell_ids=${pysical_cell_ids}

Deregister one nonVONR UE1 which is in PSBWP and verify UE4 enters to PSBWP through tti trace
    Run Keyword and Ignore Error    Start Collecting Syslog     NAME=deregister_UE1
    Start Log    btslog   cprt
    UE Deregister should be Successful   ue_id=2
    ${TC3}    Stop Log    btslog   cprt       test_scenario=TC3_highdata_lbwp
	${bwpid}    Create List    ${psbwp_id_3}
    Capture TTI Traces and Validate UE bwpid Per Cell    ${LOG_PATH}    deregister_UE1   ${crnti_UE4}    ${bwpid}    ${Branch_22R1}
    ...    pysical_cell_ids=${pysical_cell_ids}

Increase the data of UE2 which is in PSBWP and verify UE5 enters to PSBWP through tti trace
    Run Keyword and Ignore Error    Start Collecting Syslog     NAME=largedata_UE2
    Start Log    btslog   cprt
    MultiUE Trigger DL Traffic for SA    3    3    Traffic_rate=mbps     dl_rate=1      trf_id=${TRF_ID}
    MultiUE Trigger UL Traffic for SA    3    3    Traffic_rate=mbps     ul_rate=1      trf_id=${TRF_ID}
    ${TC3}    Stop Log    btslog   cprt     test_scenario=TC3_largedata_UE2.pcap
    sleep  10s   reason=data to stable
    Validate DL Traffic For SA   ue_id=3     dl_rate=1    qfi_id=${QFI_ID}
    Validate UL Traffic For SA   ue_id=3     ul_rate=1    qfi_id=${QFI_ID}
	${bwpid}    Create List    2     3
	Append To List    ${NonVONR_UEs2_crnti}     ${crnti_value_UE5}
	Set Test Variable     ${rnti_UE2_UE5}     ${NonVONR_UEs2_crnti}
    Capture TTI Traces and Validate UE bwpid Per Cell    ${LOG_PATH}    largedata_UE2   ${rnti_UE2_UE5}     ${bwpid}    ${Branch_22R1}
    ...    pysical_cell_ids=${pysical_cell_ids}

Increase the data of all UE and verify moved to dedicated BWP through tti trace
    Run Keyword and Ignore Error    Start Collecting Syslog     NAME=largedata_allUE
    Start Log    btslog   cprt
    MultiUE Trigger DL Traffic for SA    4    6    Traffic_rate=mbps     dl_rate=1      trf_id=${TRF_ID}
    MultiUE Trigger UL Traffic for SA    4    6    Traffic_rate=mbps     ul_rate=1      trf_id=${TRF_ID}
    ${TC3}    Stop Log    btslog   cprt     test_scenario=TC3_largedata_allUE
    sleep  15s   reason=data to stable
    Validate DL Traffic For MultiUE for SA    4   6     dl_rate=1
    Validate UL Traffic For MultiUE for SA    4   6     ul_rate=1
	${bwpid}    Create List    ${largebwp_id}     ${smallbwp_id}    ${largebwp_id}
    ${crnti_UE3_UE4}     Combine Lists     ${NonVONR_UE3_crnti}     ${crnti_UE4}
	Append To List    ${crnti_UE3_UE4}     ${crnti_value_UE5}
	Set Test Variable    ${rnti_UE3_UE4_UE5}    ${crnti_UE3_UE4}
    Capture TTI Traces and Validate UE bwpid Per Cell    ${LOG_PATH}    largedata_allUE   ${rnti_UE3_UE4_UE5}      ${bwpid}    ${Branch_22R1}
    ...    pysical_cell_ids=${pysical_cell_ids}

Verify 8541 counters incrementing
    Wait For Next Full Pm Interval
    ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55351C01001    4    MAX_UE_CONFIG_2BWP
    ...     M55351C01002    4    AVG_UE_CONFIG_2BWP
    ...     M55351C00001    3    MAX_UE_ACTIVE_PWR_SAVING_BWP
    ...     M55351C00002    3    AVG_UE_ACTIVE_PWR_SAVING_BWP
    ...     M55308C28009    >200    ACC_UE_DL_SCH_SLOT_BWP_PS
    ...     M55308C28010    3    MAX_UE_DL_SCH_SLOT_BWP_PS
    ...     M55308C28011    >200    ACC_UE_UL_SCH_SLOT_BWP_PS
    ...     M55308C28012    3    MAX_UE_UL_SCH_SLOT_BWP_PS
    ...     M55308C29005    >200    PRB_USED_PDSCH_BWP_PS
    ...     M55308C29006    >200    PRB_USED_PUSCH_BWP_PS
    ...     local_moid=MRBTS-1/NRBTS-1/NRCELL-3
    ...     file_path=${pm_counter_file}

Verify 8541 counters decrementing
    Wait For Next Full Pm Interval
    Wait For Next Full Pm Interval
    ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55351C01001    4    MAX_UE_CONFIG_2BWP
    ...     M55351C01002    4    AVG_UE_CONFIG_2BWP
    ...     M55351C00001    0    MAX_UE_ACTIVE_PWR_SAVING_BWP
    ...     M55351C00002    0    AVG_UE_ACTIVE_PWR_SAVING_BWP
    ...     M55308C28009    0    ACC_UE_DL_SCH_SLOT_BWP_PS
    ...     M55308C28010    0    MAX_UE_DL_SCH_SLOT_BWP_PS
    ...     M55308C28011    0    ACC_UE_UL_SCH_SLOT_BWP_PS
    ...     M55308C28012    0    MAX_UE_UL_SCH_SLOT_BWP_PS
    ...     M55308C29005    0    PRB_USED_PDSCH_BWP_PS
    ...     M55308C29006    0    PRB_USED_PUSCH_BWP_PS
    ...     local_moid=MRBTS-1/NRBTS-1/NRCELL-3
    ...     file_path=${pm_counter_file}

Deregister all Ues
    FOR    ${UE}   IN RANGE    ${3}     ${7}
        UE Deregister should be Successful    ${UE}
    END

Verify SSB_SLOT_PDSCH and TRS_SLOT_PDSCH counter
    [Arguments]     ${UE_Counter}
    Wait For Next Full Pm Interval
    Wait For Next Full Pm Interval
    ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
    ${Counter_UE}    ta5g_pm_counters.get_pm_counter_value    ${UE_Counter}    MRBTS-1/NRBTS-1/NRCELL-3    ${pm_counter_file}
    ${counter_value_cell1_ssb}    ta5g_pm_counters.get_pm_counter_value   M55308C00015    MRBTS-1/NRBTS-1/NRCELL-3    ${pm_counter_file}
    ${counter_value_cell1_ssb_slots}    ta5g_pm_counters.get_pm_counter_value   M55308C00003    MRBTS-1/NRBTS-1/NRCELL-3    ${pm_counter_file}
    ${counter_value_cell1_trs}    ta5g_pm_counters.get_pm_counter_value   M55308C00017    MRBTS-1/NRBTS-1/NRCELL-3    ${pm_counter_file}
    ${counter_value_cell1_trs_slots}    ta5g_pm_counters.get_pm_counter_value   M55308C00046    MRBTS-1/NRBTS-1/NRCELL-3    ${pm_counter_file}
    Run Keyword and Continue on Failure   Should be true      ${counter_value_cell1_ssb}[0] > ${40000}
    Run Keyword and Continue on Failure   Should be true      ${counter_value_cell1_trs}[0] > ${14000}
    Should be true      ${Counter_UE}[0] == 1

Resgister LargeUe and Verify SSB and TRS PDSCH counters
    UE Register should be Successful     2
    Trigger DL Data Traffic for SA    ue_id=2    Traffic_rate=mbps     dl_rate=170       trf_id=1
    Trigger DL Data Traffic for SA    ue_id=2    Traffic_rate=mbps     dl_rate=170       trf_id=2
    Trigger DL Data Traffic for SA    ue_id=2    Traffic_rate=mbps     dl_rate=170       trf_id=3
    Trigger DL Data Traffic for SA    ue_id=2    Traffic_rate=mbps     dl_rate=170       trf_id=4
    Trigger DL Data Traffic for SA    ue_id=2    Traffic_rate=mbps     dl_rate=170       trf_id=5
    Trigger DL Data Traffic for SA    ue_id=2    Traffic_rate=mbps     dl_rate=170       trf_id=6
    Trigger DL Data Traffic for SA    ue_id=2    Traffic_rate=mbps     dl_rate=170       trf_id=7
    Verify SSB_SLOT_PDSCH and TRS_SLOT_PDSCH counter    UE_Counter=${Large_UE}
    Run Keyword and Continue on failure   UE Deregister should be Successful    2

Resgister SmallUe and Verify SSB and TRS PDSCH counters
    UE Register should be Successful     3
    Trigger DL Data Traffic for SA    ue_id=3    Traffic_rate=mbps     dl_rate=150       trf_id=1
    Trigger DL Data Traffic for SA    ue_id=3    Traffic_rate=mbps     dl_rate=150       trf_id=2
    Trigger DL Data Traffic for SA    ue_id=3    Traffic_rate=mbps     dl_rate=150       trf_id=3
    Trigger DL Data Traffic for SA    ue_id=3    Traffic_rate=mbps     dl_rate=150       trf_id=4
    Trigger DL Data Traffic for SA    ue_id=3    Traffic_rate=mbps     dl_rate=150       trf_id=5
    Verify SSB_SLOT_PDSCH and TRS_SLOT_PDSCH counter    UE_Counter=${Small_UE}
    Run Keyword and Continue on failure   UE Deregister should be Successful    3
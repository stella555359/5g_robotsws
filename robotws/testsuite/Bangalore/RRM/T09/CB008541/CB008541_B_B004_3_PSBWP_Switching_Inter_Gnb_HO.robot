*** Settings ***

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
Resource         ../../../resources/robot/common_log_collection.robot
Library          ta5g_pm_counters

*** Variables ***
${UE_ID_7}        7
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
${physical_cell_id}     54

*** Keywords ***

Run Scenario B_B004_3_Verify_UE_Connects_From_gnb_With_Configured_PS_BWP_To_gnb_Without_Configured_PS_BWP_Via_Inter_Gnb_HO
    Establish Xn Link To gNB3
    Register UE and verify initial bwp through tti trace
    Start low DL data and verify psbwp through tti trace
    Get Configured Measurements of UE${UE_ID_7}
    Trigger A3 RsrpAndRsrq Measurement from real gnb to simulated gNB    1    2    63
    Trigger A3 RsrpAndRsrq Measurement from simulated gnb to real gNB    1    2    54
    Verify psbwp through tti trace after HO
    Verify 8541 counters incrementing
    Start high DL data and verify smallbwp through tti trace
    Verify 8541 counters decrementing
    Stop Data Traffic for SA     ue_id=${UE_ID_7}
    UE Deregister should be Successful   ue_id=${UE_ID_7}

Register UE and verify initial bwp through tti trace
    log to console   UE attach trigerring now...
    Start Log    btslog   cprt    biptaf
    UE Register should be Successful     ${UE_ID_7}
    Sleep    10s
    ${TC2}    Stop Log    btslog   cprt    biptaf    test_scenario=TC2_UE_attach
    ${bwpid}    Create List     ${psbwp_id}
    ${crnti_list}     Create List
    Capture TTI Traces and Validate UE bwpid Per Cell    ${LOG_PATH}   initial   ${crnti_list}     ${bwpid}    ${Branch_22R1}
    ...    pysical_cell_ids=${physical_cell_id}

Start low DL data and verify psbwp through tti trace
    Start Log    btslog   cprt    biptaf
    Trigger DL Data Traffic for SA    ue_id=${UE_ID_7}    Traffic_rate=kbps     dl_rate=10
    sleep   5s
    Trigger UL Data Traffic for SA    ue_id=${UE_ID_7}    Traffic_rate=kbps     ul_rate=10
    sleep   5s    reason=Wait for successful BWP switch
    ${TC2}    Stop Log    btslog   cprt    biptaf    test_scenario=TC2_lowdata
    Validate DL Traffic For SA   ue_id=${UE_ID_7}     dl_rate=0.010     qfi_id=${QFI_ID}
    ${bwpid}    Create List     ${psbwp_id}
    ${crnti_list}     Create List
    Capture TTI Traces and Validate UE bwpid Per Cell    ${LOG_PATH}    lowdata    ${crnti_list}     ${bwpid}    ${Branch_22R1}
    ...    pysical_cell_ids=${physical_cell_id}

Verify psbwp through tti trace after HO
    Validate DL Traffic For SA   ue_id=${UE_ID_7}     dl_rate=0.010     qfi_id=${QFI_ID}
    ${bwpid}    Create List     ${psbwp_id}
    ${crnti_list}     Create List
    Capture TTI Traces and Validate UE bwpid Per Cell    ${LOG_PATH}    IntergnbHOlowdata    ${crnti_list}     ${bwpid}    ${Branch_22R1}
    ...    pysical_cell_ids=${physical_cell_id}

Verify 8541 counters incrementing
    Wait For Next Full Pm Interval
    ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55351C01001    2    MAX_UE_CONFIG_2BWP
    ...     M55351C01002    1    AVG_UE_CONFIG_2BWP
    ...     M55351C00001    1    MAX_UE_ACTIVE_PWR_SAVING_BWP
    ...     M55351C00002    1    AVG_UE_ACTIVE_PWR_SAVING_BWP
    ...     M55308C28009    >200    ACC_UE_DL_SCH_SLOT_BWP_PS
    ...     M55308C28010    1    MAX_UE_DL_SCH_SLOT_BWP_PS
    ...     M55308C28011    >200    ACC_UE_UL_SCH_SLOT_BWP_PS
    ...     M55308C28012    1    MAX_UE_UL_SCH_SLOT_BWP_PS
    ...     M55308C29005    >200    PRB_USED_PDSCH_BWP_PS
    ...     M55308C29006    >200    PRB_USED_PUSCH_BWP_PS
    ...     local_moid=MRBTS-1/NRBTS-1/NRCELL-4
    ...     file_path=${pm_counter_file}

Verify 8541 counters decrementing
    Wait For Next Full Pm Interval
    Wait For Next Full Pm Interval
    ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55351C01001    1    MAX_UE_CONFIG_2BWP
    ...     M55351C01002    1    AVG_UE_CONFIG_2BWP
    ...     M55351C00001    0    MAX_UE_ACTIVE_PWR_SAVING_BWP
    ...     M55351C00002    0    AVG_UE_ACTIVE_PWR_SAVING_BWP
    ...     M55308C28009    0    ACC_UE_DL_SCH_SLOT_BWP_PS
    ...     M55308C28010    0    MAX_UE_DL_SCH_SLOT_BWP_PS
    ...     M55308C28011    0    ACC_UE_UL_SCH_SLOT_BWP_PS
    ...     M55308C28012    0    MAX_UE_UL_SCH_SLOT_BWP_PS
    ...     M55308C29005    0    PRB_USED_PDSCH_BWP_PS
    ...     M55308C29006    0    PRB_USED_PUSCH_BWP_PS
    ...     local_moid=MRBTS-1/NRBTS-1/NRCELL-4
    ...     file_path=${pm_counter_file}

Start high DL data and verify smallbwp through tti trace
    Start Log    btslog   cprt    biptaf
    Trigger DL Traffic for SA    ue_id=${UE_ID_7}    Traffic_rate=mbps     dl_rate=1       trf_id=${TRF_ID}      qfi_id=${QFI_ID}
    sleep   5s
    Trigger UL Traffic for SA    ue_id=${UE_ID_7}    Traffic_rate=mbps     ul_rate=1       trf_id=${TRF_ID2}      qfi_id=${QFI_ID}
    sleep   5s    reason=Wait for successful BWP switch
    ${TC2}    Stop Log    btslog   cprt    biptaf    test_scenario=TC2_highdata
    Validate DL Traffic For SA   ue_id=${UE_ID_7}     dl_rate=1     qfi_id=${QFI_ID}
    ${bwpid}    Create List     ${smallbwp_id}
    ${crnti_list}     Create List
    Capture TTI Traces and Validate UE bwpid Per Cell   ${LOG_PATH}    highdata    ${crnti_list}     ${bwpid}    ${Branch_22R1}
    ...     pysical_cell_ids=${physical_cell_id}


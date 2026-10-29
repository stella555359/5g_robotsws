*** Settings ***
Resource    ./../Resources/CB010630_keywords.robot

Documentation    Suite description
...    author: Liu Zheng
...    contact: zheng.4.liu@nokia-sbell.com
...    squad group: I_NSB_MN_RAN_RD_VRF_HAZ3_01_S1_GMS
...    Feature CB010630

Suite Setup  9823 Suite preparation multiGNB
Suite Teardown  run keyword and ignore error    Common suite recovery

*** Variables ***
${DL_TPUT}         1000M
${UL_TPUT}         200M

*** Test Cases ***
CB010630_SR_E_TC_6_CB012719_RIM_RS_based_DL_muting_fw_0_cell_load_change_after_max_RIM_power_reduction_timer_expired_1116_0_4GP_60M
    [Tags]    CRT_TRUNK
    [Documentation]
    ...    precondition:  1116_0ms_6GP_60MHz BWP ID 8,73, framework-1
    ...    SCF is same as CB009823-SR-F_TC301_RIM-RS_transmission_and_detection_for_all_subfeatures_100MHz_100MHz-100MHz_overlap_
    ...    100MHz_1116-0ms-4GP_numRbForRs-48_Loki
    ...    manualFrameTimingAdjustment=536us about 15 symbols
    ...    then enable CB012719
    ...    lock aggressor cell in case setup.
    ...    dlMutingFallbackTimer=300min，windowDurationForCellLoadAvg=10s, cellLoadThreshForRimMitigation=50, miNrRim=5min
    ...    actRimPowerReduction=true, actRimSoftDlMuting=false, highPrioRbTransInMutedSlots=false update in case setup.
    ...    actRimPdcchMutingOnSpecialSlot is false in base_scf, in this case, it is still false.
    ...    power reduction profile configured in base scf
    ...    Step1: UE attach and start traffic, check UL/DL TP peak
    ...    Step2: unlock aggressor cell，UE attach and start DL traffic with high cell load(higher than cellLoadThreshForRimMitigation)
    ...    Step2_1: check there are fault 7525 and fault 7527, and no fault 7535.-->change to check via CM
    ...    Step2_2: check DL mute counters(M55194C00281) not updated, PWR counters(M55194C00285) updated.
    ...    M55194C00003 and M55194C00287 not update due to 1116_0ms_6GP and actRimPdcchMutingOnSpecialSlot=false
    ...    M55194C00282 and M55194C00286 no update due to rimDlMutingMaxRange-DL+special slots
    ...    Step2_3: collect BIP(only used for manual debug) and syslogs(check reduced power in syslog) for debug, this step only for debug.
    ...    Step3: decrease the DL TP to make it less than cellLoadThreshForRimMitigation
    ...    Step3_1: check DL mute counters(M55194C00281) updated, PWR counters(M55194C00285) not updated.
    ...    M55194C00003 and M55194C00287 not update due to 1116_0ms_6GP and actRimPdcchMutingOnSpecialSlot=false
    ...    M55194C00282 and M55194C00286 no update due to rimDlMutingMaxRange-DL+special slots
    ...    Step3_2: check the special slot and DL slot preceding the special slot are muted in BIP log.
    ...    Step4: update NIDD cellLoadThreshForRimMitigation to 0 to make TP higer than cellLoadThreshForRimMitigation
    ...    Step4_1: check DL mute counters(M55194C00281) not updated, PWR counters(M55194C00285) updated.
    ...    M55194C00003 and M55194C00287 not update due to 1116_0ms_6GP and actRimPdcchMutingOnSpecialSlot=false
    ...    M55194C00282 and M55194C00286 no update due to rimDlMutingMaxRange-DL+special slots
    ...    Step5: update actRimPowerReduction=false to make dlMutingFallbackTimer disabled，then
    ...           update dlMutingFallbackTimer=1min and actRimPowerReduction=true to make new dlMutingFallbackTimer(1min) take effect.
    ...    Step5_1: wait dlMutingFallbackTimer(1min) expired，
    ...             check DL mute counters(M55194C00281) updated, PWR counters(M55194C00285) not updated.
    ...    M55194C00003 and M55194C00287 not update due to 1116_0ms_6GP and actRimPdcchMutingOnSpecialSlot=false
    ...    M55194C00282 and M55194C00286 no update due to rimDlMutingMaxRange-DL+special slots
    ...    Step6_stop RI and check fault 7525 7527 canceled and DL mitigation stopped
   [Setup]     10630 case setup     frame_bw=60M_1116_0ms_6GP
    Set case variable
    TC_06_step1_Make_L3_call_and_Check_no_DL_Mitigation_before_RI
    TC_06_step2_power_reduction_when_high_cell_load
    TC_06_step3_decrease_DL_tp_and_check_DL_muting_when_low_cell_load
    TC_06_step4_update_cellLoadThreshForRimMitigation_to_0_and_check_power_reduction_when_high_cell_load
    TC_06_step5_update_dlMutingFallbackTimer_to_1min_and_make_it_take_effect_and_check_counters_after_dlMutingFallbackTimer_expired
    TC_06_Step6_stop RI and check fault 7525 7527 canceled and DL mitigation stopped
    [Teardown]    run keyword and ignore error    9823 case teardown    unlock_cell=${True}

*** Keywords ***
Set case variable
    [Documentation]    Set variables for 10630
    ...    Author: Liu Zheng
    @{SPECIAL_SLOT_LIST}    set variable    ${SPECIAL_SLOT_LIST_1116_0}
    @{MUTE_SLOT_LIST}    Set Variable    ${PRECED_DL_SLOT_LIST_1116_0}
    set test variable    @{SPECIAL_SLOT_LIST}
    set test variable    @{MUTE_SLOT_LIST}
    set test variable    ${TDD_DL_EXP_TPUT}     ${TDD_DL_EXP_TPUT_60M}
    set test variable    ${TDD_UL_EXP_TPUT}     ${TDD_UL_EXP_TPUT_60M}
    set test variable    ${transmission_window}     6min
    set test variable    ${frameStructureBW}     1116_0ms_6gp_60MHZ
    set test variable    ${DLMUTESLOTSSTR}     ${1DL_MUTING}
    ${exp_dl_tput_gap}   evaluate    ${TDD_DL_EXP_TPUT}*0.03
    ${exp_ul_tput_gap}   evaluate    ${TDD_UL_EXP_TPUT}*0.03
    set test variable    ${exp_dl_tput_gap}
    set test variable    ${exp_ul_tput_gap}
    set test variable    ${UL_SLOT_LIST}    ${UL_SLOT_LIST_1116_0}
    set test variable    ${CELL_LOAD_THRESHOLD_FOR_RIM_MITIGATION}    50

TC_06_step1_Make_L3_call_and_Check_no_DL_Mitigation_before_RI
    [Documentation]    Before RI, DL throughput can reach to peak;
    log to console    step1: Make_L3_call_and_Check_no_DL_Mitigation_before_RI
    run keyword and continue on failure     Steps Make L3 call and Check no DL Mitigation before RI
    ...    check_bip_needed=${False}      before_ri=${True}

TC_06_step2_power_reduction_when_high_cell_load
    [Documentation]
    ...    Step2: unlock aggressor cell，UE attach and start DL traffic with high cell load(higher than cellLoadThreshForRimMitigation 50%)
    ...    Step2_1: check there are fault 7525 and fault 7527, and no fault 7535.-->change to check via CM, all set to CM_ON
    ...    Step2_2: check DL mute counters(M55194C00003, M55194C00281, M55194C00282) not updated, PWR counters(M55194C00285) updated.
    ...             M55194C00287 is not updated due to 6GP(there is no PDSCH on special slots) and actRimPdcchMutingOnSpecialSlot is False.
    ...             M55194C00286 no update due to rimDlMutingMaxRange-DL+special slots
    ...    Step2_3: collect BIP(only used for manual debug) and syslogs(check reduced power in syslog) for debug, this step only for debug.
    log to console    step2.1: start to trigger RI, and check status before high cell load, all set to CM_ON, FM_OFF
    Unlock cells    lock_cell_list=@{CELL_LIST_GNB1}   lock_cell_connection=${connection_GNB_aggressor}
    Set aggressor targetTotalLoad via restAPI     paras=${RESTAPI_MODIFY_TARGET_TOTAL_LOAD}
    run keyword and continue on failure     Wait and Get NRRIMINFO via WEBEM and Check NRRIMINFO Value is as Expected
    ...    time_interval=30s    riState=${RI_DETECTED}    rimRsSetIdType1=11160    rimRsSetIdType2=11160
    ...    pdschMutingStatus=${DLMUTESLOTSSTR}    pdcchMutingStatus=${None}

    L3 call and Start Traffic    dl_tput=${DL_TPUT}     ul_tput=${UL_TPUT}    duration=10000
                                                ...    data_transfer_direction=dl    prepare_ue_needed=${False}
    ${cell_load_threshold}    evaluate    ${CELL_LOAD_THRESHOLD_FOR_RIM_MITIGATION}/100
    ${start_time}    Prepare for counter log

    log to console    step2.2: check DL muting status changed to no muting and power reduction when high cell load
    run keyword and continue on failure     Wait and Get NRRIMINFO via WEBEM and Check NRRIMINFO Value is as Expected
    ...    riState=${RI_DETECTED}    rimRsSetIdType1=11160    rimRsSetIdType2=11160    pdschMutingStatus=${NO_MUTING}
    ...    pdcchMutingStatus=${None}

    ${pm_files_local_path}    Wait for PM file generated and download    starting_log_timestamp=${start_time['log_generator_timestamp']}
    Check PM counters for soft muting or power reduction    pm_files_local_path=${pm_files_local_path}
                                                 ...    Check_Mitigation=${True}
                                                 ...    is_sl_update_soft_mute=${False}
                                                 ...    is_1st_dl_update_soft_mute=${False}
                                                 ...    is_2nd_dl_update_soft_mute=${False}
                                                 ...    check_PWR=${True}
                                                 ...    is_sl_update_pwr=${False}
                                                 ...    is_1st_dl_update_pwr=${True}
                                                 ...    is_2nd_dl_update_pwr=${False}
                                                 ...    check_cell_load=${True}
                                                 ...    is_high_cell_load=${True}
                                                 ...    cell_load_threshold_for_rim_mitigation=${cell_load_threshold}
                                                 ...    Check_high_priority_data=${True}
                                                 ...    is_high_prio_data_enabled=${False}

    # Run Keyword And Ignore Error    collect bip syslog ttitrace logs for manual debug
    [Teardown]    run keyword and continue on failure    Stop data transfer and detach UE  data_transfer_direction=dl

collect bip syslog ttitrace logs for manual debug
    [Arguments]    ${bip_target_file_name}=step2_high_cell_load_L1L2_bip_log    ${syslog_log_name}=step2_high_cell_load_syslog
    ...    ${mirroring_filter}=SpecificL1L2Messages
    Connect to Common Unit Master
    ${specific_message_ids}    Catenate    ${MESSAGE_ID_PDSCH_SEND_REQ},    ${MESSAGE_ID_PDCCH_SEND_REQ},
                                                ...    ${MESSAGE_ID_RIM_RECEIVE_REQ},    ${MESSAGE_ID_RIM_RECEIVE_RSPS},
                                                ...    ${MESSAGE_ID_RIM_SENT_REQ},    ${MESSAGE_ID_SRS_RECEIVE_REQ}
    ${bip_log}    Collect Bip logs and Return Files Path    target_file_name=${bip_target_file_name}   capture_time=5s
                                                ...    mirroring_filter=${mirroring_filter}
                                                ...    specific_message_ids=${specific_message_ids}
                                                ...    gnb_index=0
    ${syslog_log_tmp}    Capturing Aasyslog with duration    log_name=${syslog_log_name}    type=MCU
                                                ...    filter=${EMPTY}    duration=30s

    ${syslog_path}    copy file    source=${syslog_log_tmp}    destination=${TS_CASE_LOG_PATH}/

TC_06_step3_decrease_DL_tp_and_check_DL_muting_when_low_cell_load
    [Documentation]
    ...    Step3: decrease the DL TP to make it less than cellLoadThreshForRimMitigation
    ...    Step3_1: check DL mute counters(M55194C00281) updated, PWR counters(M55194C00285,M55194C00286,M55194C00287) not updated.
    ...             M55194C00003 not updated  due to 6GP(there is no PDSCH on special slots) and actRimPdcchMutingOnSpecialSlot is False.
    ...             M55194C00282 no update due to rimDlMutingMaxRange-DL+special slots
    ...    Step3_2: check the special slot and DL slot preceding the special slot are muted in BIP log.
    [Arguments]      ${pdsch_slot_list}=${MUTE_SLOT_LIST}    ${capture_time}=3 sec
    log to console    step3.1: decrease_DL_tp_and_check_DL_muting_when_low_cell_load
    L3 call and Start Traffic    dl_tput=50M    ul_tput=${UL_TPUT}    duration=10000
        ...    data_transfer_direction=dl    prepare_ue_needed=${False}

    run keyword and continue on failure     Wait and Get NRRIMINFO via WEBEM and Check NRRIMINFO Value is as Expected
    ...    riState=${RI_DETECTED}    asymmetricState=${ASYMMETRIC}    rimRsSetIdType1=11160    rimRsSetIdType2=11160
    ...    pdschMutingStatus=${DLMUTESLOTSSTR}    pdcchMutingStatus=${None}

    ${cell_load_threshold}    evaluate    ${CELL_LOAD_THRESHOLD_FOR_RIM_MITIGATION}/100
    ${start_time}    Prepare for counter log

    log to console    step3.2 check the special slot and DL slot preceding the special slot are muted in BIP log.
    run keyword and continue on failure     check slot scheculed info
                                                 ...    pdsch_slot_list=${pdsch_slot_list}
                                                 ...    capture_time=${capture_time}
                                                 ...    is_pdsch_scheduled_on_related_slot=${False}
                                                 ...    mirroring_filter=SpecificL1L2Messages
                                                 ...    target_file_name=step3_bip_log_low_cell_load_dl_soft_muting

    log to console  step3.3 check DL mute counter_M55194C00281 updated, PWR counters(M55194C00285,M55194C00286,M55194C00287) not updated.
    ${pm_files_local_path}    Wait for PM file generated and download    starting_log_timestamp=${start_time['log_generator_timestamp']}
    Check PM counters for soft muting or power reduction    pm_files_local_path=${pm_files_local_path}
                                                 ...    Check_Mitigation=${True}
                                                 ...    is_sl_update_soft_mute=${False}
                                                 ...    is_1st_dl_update_soft_mute=${True}
                                                 ...    is_2nd_dl_update_soft_mute=${False}
                                                 ...    check_PWR=${True}
                                                 ...    is_sl_update_pwr=${False}
                                                 ...    is_1st_dl_update_pwr=${False}
                                                 ...    is_2nd_dl_update_pwr=${False}
                                                 ...    check_cell_load=${True}
                                                 ...    is_high_cell_load=${False}
                                                 ...    cell_load_threshold_for_rim_mitigation=${cell_load_threshold}
                                                 ...    Check_high_priority_data=${True}
                                                 ...    is_high_prio_data_enabled=${False}

TC_06_step4_update_cellLoadThreshForRimMitigation_to_0_and_check_power_reduction_when_high_cell_load
    [Documentation]
    ...    Step4: update NIDD cellLoadThreshForRimMitigation to 0 to make TP higer than cellLoadThreshForRimMitigation
    ...    Step4_1 check DL mute counters(M55194C00003, M55194C00281, M55194C00282) not updated, PWR counters(M55194C00285) updated.
    log to console    step4: update_cellLoadThreshForRimMitigation_to_0_and_check_power_reduction_when_high_cell_load
    coam_gnb_classical.COAM Update several parameters via rest api
                                                 ...    parameters_to_update_via_api=${UPDATE_CELLLOADTHRESHFORRIMMITIGATION_TO_0_API_VICTIM}
                                                 ...    skip_parameter_relation_errors=${False}
                                                 ...    connection=${connection_GNB_victim}
    ${start_time}    Prepare for counter log
    ${pm_files_local_path}    Wait for PM file generated and download    starting_log_timestamp=${start_time['log_generator_timestamp']}
    Check PM counters for soft muting or power reduction    pm_files_local_path=${pm_files_local_path}
                                                 ...    Check_Mitigation=${True}
                                                 ...    is_sl_update_soft_mute=${False}
                                                 ...    is_1st_dl_update_soft_mute=${False}
                                                 ...    is_2nd_dl_update_soft_mute=${False}
                                                 ...    check_PWR=${True}
                                                 ...    is_sl_update_pwr=${False}
                                                 ...    is_1st_dl_update_pwr=${True}
                                                 ...    is_2nd_dl_update_pwr=${False}
                                                 ...    check_cell_load=${True}
                                                 ...    is_high_cell_load=${True}
                                                 ...    cell_load_threshold_for_rim_mitigation=0
                                                 ...    Check_high_priority_data=${True}
                                                 ...    is_high_prio_data_enabled=${False}

TC_06_step5_update_dlMutingFallbackTimer_to_1min_and_make_it_take_effect_and_check_counters_after_dlMutingFallbackTimer_expired
    [Documentation]
    ...    Step5: update actRimPowerReduction=false to make dlMutingFallbackTimer disabled，then
    ...           update dlMutingFallbackTimer=1min and actRimPowerReduction=true to make new dlMutingFallbackTimer(1min) take effect.
    ...    Step5_1: wait dlMutingFallbackTimer(1min) expired，
    ...             check DL mute counters(M55194C00281) updated, PWR counters(M55194C00285) not updated.
    # [Arguments]      ${pdsch_slot_list}=${MUTE_SLOT_LIST}    ${capture_time}=3 sec
    log to console    step5: update_dlMutingFallbackTimer_to_1min_and_make_it_take_effect_and_check_counters_after_dlMutingFallbackTimer_expired
    # disable actRimPowerReduction first
    coam_gnb_classical.COAM Update several parameters via rest api
                                                 ...    parameters_to_update_via_api=${DISABLE_12719_API_VICTIM}
                                                 ...    skip_parameter_relation_errors=${False}
                                                 ...    connection=${connection_GNB_victim}
    run keyword and continue on failure     Wait and Get NRRIMINFO via WEBEM and Check NRRIMINFO Value is as Expected
    ...    riState=${RI_DETECTED}    asymmetricState=${ASYMMETRIC}    rimRsSetIdType1=11160    rimRsSetIdType2=11160
    ...    pdschMutingStatus=${DLMUTESLOTSSTR}    pdcchMutingStatus=${None}

    # update dlMutingFallbackTimer to 1min and enable actRimPowerReduction
    coam_gnb_classical.COAM Update several parameters via rest api
                                                  ...    parameters_to_update_via_api=${UPDATE_DLMUTINGFALLBACKTIMER_TO_1_API_VICTIM}
                                                  ...    skip_parameter_relation_errors=${False}
                                                  ...    connection=${connection_GNB_victim}
    coam_gnb_classical.COAM Update several parameters via rest api
                                                  ...    parameters_to_update_via_api=${ENABLE_12719_API_VICTIM}
                                                  ...    skip_parameter_relation_errors=${False}
                                                  ...    connection=${connection_GNB_victim}
    # wait for dlMutingFallbackTimer expired
    sleep    1min
    ${start_time}    Prepare for counter log

    run keyword and continue on failure     Wait and Get NRRIMINFO via WEBEM and Check NRRIMINFO Value is as Expected
    ...    riState=${RI_DETECTED}    asymmetricState=${ASYMMETRIC}    rimRsSetIdType1=11160    rimRsSetIdType2=11160
    ...    pdschMutingStatus=${DLMUTESLOTSSTR}    pdcchMutingStatus=${None}

    # run keyword and continue on failure     check slot scheculed info
    #                                              ...    pdsch_slot_list=${pdsch_slot_list}
    #                                              ...    capture_time=${capture_time}
    #                                              ...    is_pdsch_scheduled_on_related_slot=${False}
    #                                              ...    mirroring_filter=SpecificL1L2Messages
    #                                              ...    target_file_name=step5_bip_log_dlMutingFallbackTimer_expired

    ${pm_files_local_path}    Wait for PM file generated and download    starting_log_timestamp=${start_time['log_generator_timestamp']}
    Check PM counters for soft muting or power reduction    pm_files_local_path=${pm_files_local_path}
                                                  ...    Check_Mitigation=${True}
                                                  ...    is_sl_update_soft_mute=${False}
                                                  ...    is_1st_dl_update_soft_mute=${True}
                                                  ...    is_2nd_dl_update_soft_mute=${False}
                                                  ...    is_sl_update_pwr=${False}
                                                  ...    check_PWR=${True}
                                                  ...    is_1st_dl_update_pwr=${False}
                                                  ...    is_2nd_dl_update_pwr=${False}
                                                  ...    check_cell_load=${True}
                                                  ...    is_high_cell_load=${True}
                                                  ...    cell_load_threshold_for_rim_mitigation=0
                                                  ...    Check_high_priority_data=${True}
                                                  ...    is_high_prio_data_enabled=${False}
    [Teardown]    run keyword and continue on failure    Stop data transfer and detach UE  data_transfer_direction=dl

TC_06_Step6_stop RI and check fault 7525 7527 canceled and DL mitigation stopped
    [Arguments]    ${exp_dl_tput_gap}=5    ${exp_ul_tput_gap}=3
    log to console    Step6: stop RI and check fault 7525 7527 canceled and DL mitigation stopped
    Trigger RI Disappear and Check Fault 7525 7527 canceled and DL Mitigation stopped
                                                ...    SetId_Aggressor=${CONFIGS_GNB1["rsSetId"]}
                                                ...    dlMuteSlotsStr=${DLMUTESLOTSSTR}
                                                ...    feature=9823
                                                ...    after_ri=${True}
                                                ...    exp_dl_tput_gap=${exp_dl_tput_gap}
                                                ...    exp_ul_tput_gap=${exp_ul_tput_gap}
                                                ...    setId_show_in_fault=${True}
                                                ...    check_pcmd_setid_removed=${False}
                                                ...    7525_check_history=${False}
                                                ...    7527_check_history=${False}
                                                ...    7535_check=${False}
                                                ...    riState=${NO_RI}
                                                ...    asymmetricState=${NOT_ASYMMETRIC}
                                                ...    rimRsSetIdType1=${None}
                                                ...    rimRsSetIdType2=${None}
                                                ...    pdschMutingStatus=${NO_MUTING}
                                                ...    pdcchMutingStatus=${None}





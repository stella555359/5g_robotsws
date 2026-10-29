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
${DL_TPUT}         600M
${UL_TPUT}         100M

*** Test Cases ***
CB010630-SR-E_TC_02_CB013350_RI_based_DL_muting_with_cell_load_switch_from_high_to_low_frame_1208_50M
    [Tags]    CRT_TRUNK
    [Documentation]
    ...    precondition:   case real configuration: 1208_40M，BWP ID 5,51, CB009823(framework-1),
    ...    DDDSUDDDSU, specialslot:3,8,13,18
    ...    SCF is basicly same as CB009823-SR-B_TC401_Start_DL-Mitigation_by-rimDLMitigationManualTrigger_regardlessOf-RI-and-
    ...    RS_Detection_r2_1208-70MHz_on-Loki
    ...    manualFrameTimingAdjustment=536us about 15 symbols
    ...    then set actNrRim=RI detection and mitigation, actRiDetectTriggerDlMitigation=true
    ...    dlMutingFallbackTimer=300min, windowDurationForCellLoadAvg=10s, cellLoadThreshForRimMitigation=40, miNrRim=5min
    ...    actRimPowerReduction=false, actRimSoftDlMuting=true update in case setup.
    ...    lock aggressor cell in case setup.
    ...    Step1: UE attach and start traffic, check UL/DL TP peak
    ...    Step2: unlock aggressor cell，update targetTotalLoad to 100 on aggressor.
    ...    UE attach and start DL traffic with high cell load(higher than cellLoadThreshForRimMitigation) on victim.
    ...    Step2_1: check there is fault 7525 and no fault 7527, 7535.
    ...    Step2_2: check DL mute counters(M55194C00003, M55194C00281) not updated.
    ...    Step2_3: check the special slot and DL slot preceding the special slot are not muted in BIP log.
    ...    Step3: decrease the DL TP to make it less than cellLoadThreshForRimMitigation
    ...    Step3_1: check DL mute counters(M55194C00003, M55194C00281) updated
    ...    Step3_2: check the special slot and DL slot preceding the special slot are muted in BIP log.
    ...    Step4:  update cellLoadThreshForRimMitigation=1 to make TP higher than cellLoadThreshForRimMitigation
    ...    Step4_1: check DL mute counters(M55194C00003, M55194C00281) not updated.
    ...    Step5: update actRimSoftDlMuting=false
    ...    Step5_1: check fault 7525 not disappear and fault 7535 reported, no fault 7527.
    ...    Step5_2: check DL mute counters(M55194C00003, M55194C00281) updated.
    ...    Step5_3: check the special slot and DL slot preceding the special slot are muted in BIP log.
    ...    Step6_stop RI and check fault 7525 canceled and DL mitigation stopped
   [Setup]     10630 case setup     frame_bw=40M_1208
   Set case variable
   TC_02_step1_Make L3 call and Check no DL Mitigation before RI
   TC_02_step2_NO DL muting when high cell load
   TC_02_step3_decrease DL tp and check DL muting when low cell load
   TC_02_step4_update cellLoadThreshForRimMitigation to 1 and check no DL muting when high cell load
   TC_02_step5_disable CB013350 and check alarm counter and slot schedule info
   TC_02_Step6_stop RI and check fault 7525 7527 canceled and DL mitigation stopped
   [Teardown]  run keyword and ignore error    9823 case teardown      unlock_cell=${True}

*** Keywords ***
Set case variable
    [Documentation]    Set variables for 10630
    ...    Author: Liu Zheng
    @{SPECIAL_SLOT_LIST}    set variable    ${SPECIAL_SLOT_LIST_1208}
    @{MUTE_SLOT_LIST}    set variable    ${SPECIAL_SLOT_LIST_1208}
    @{RI_MONITOR_S_SLOT_LIST}    set variable    ${RI_MONITOR_S_SLOT_LIST_1208_V2}
    @{RI_MONITOR_UL_SLOT_LIST}    set variable    ${RI_MONITOR_UL_SLOT_LIST_1208_V2}
    set test variable    @{SPECIAL_SLOT_LIST}
    set test variable    @{MUTE_SLOT_LIST}
    set test variable    @{RI_MONITOR_S_SLOT_LIST}
    set test variable    @{RI_MONITOR_UL_SLOT_LIST}
    set test variable    ${TDD_DL_EXP_TPUT}     ${TDD_DL_EXP_TPUT_40M_1208}
    set test variable    ${TDD_UL_EXP_TPUT}     ${TDD_UL_EXP_TPUT_40M_1208}
    set test variable    ${TRANSMISSION_WINDOW}     6min
    set test variable    ${frameStructureBW}     1208_2gp_40mhz
    set test variable    ${DLMUTESLOTSSTR}     ${DL_MUTE_SLOTS_SPECIAL}
    set test variable    ${DLMUTESLOTSSTR_CM}     ${S_MUTING}
    set test variable    ${CELL_LOAD_THRESHOLD_FOR_RIM_MITIGATION}    40


TC_02_step1_Make L3 call and Check no DL Mitigation before RI
    [Documentation]    Before RI, DL throughput can reach to peak;
    log to console    step1:Make L3 call and Check no DL Mitigation before RI
    run keyword and continue on failure     Steps Make L3 call and Check no DL Mitigation before RI
    ...    check_bip_needed=${False}

TC_02_step2_NO DL muting when high cell load
    [documentation]    check alarm counter and slot schedule info in BIP Log
    ...    cellLoadThreshForRimMitigation is set to 40 in case setup.
    [Arguments]    ${connection_GNB_aggressor}=${OAM_ALIAS_GNB1}
    log to console    step2.1: check status before high cell load, ri set to "CM_OFF, FM_ON", muting set to "CM_ON, FM_OFF"
    Unlock cells    lock_cell_list=@{CELL_LIST_GNB1}   lock_cell_connection=${connection_GNB_aggressor}
    Set aggressor targetTotalLoad via restAPI     paras=${RESTAPI_MODIFY_TARGET_TOTAL_LOAD}
    AlarmWatchdog.add_allow_alarms    fault_id=7525
    Check there is fault 7525 no fault 7527 fault 7535
    run keyword and continue on failure     Wait and Get NRRIMINFO via WEBEM and Check NRRIMINFO Value is as Expected
    ...    riState=${None}    asymmetricState=${None}    rimRsSetIdType1=${None}    rimRsSetIdType2=${None}
    ...    pdschMutingStatus=${DLMUTESLOTSSTR_CM}    pdcchMutingStatus=${None}

    L3 call and Start Traffic    dl_tput=${DL_TPUT}     ul_tput=${UL_TPUT}    duration=10000
        ...    data_transfer_direction=dl    prepare_ue_needed=${False}

    ${cell_load_threshold}    evaluate    ${CELL_LOAD_THRESHOLD_FOR_RIM_MITIGATION}/100
    ${start_time}    Prepare for counter log
    log to console    step2.2: check no DL muting when high cell load
#    Check there is fault 7525 fault 7527 and no fault 7535
    Check there is fault 7525 no fault 7527 fault 7535
    run keyword and continue on failure     Wait and Get NRRIMINFO via WEBEM and Check NRRIMINFO Value is as Expected
    ...    riState=${None}    asymmetricState=${None}    rimRsSetIdType1=${None}    rimRsSetIdType2=${None}
    ...    pdschMutingStatus=${NO_MUTING}    pdcchMutingStatus=${None}
    Check the special slot and DL slot preceding the special slot are not muted in BIP log
                                                    ...    target_file_name=step2_bip_log_high_cell_load_no_dl_muting

    ${pm_files_local_path}    Wait for PM file generated and download    starting_log_timestamp=${start_time['log_generator_timestamp']}
    run keyword and continue on failure    Check PM counters for soft muting or power reduction
                                                    ...    pm_files_local_path=${pm_files_local_path}
                                                    ...    Check_Mitigation=${True}
                                                    ...    is_sl_update_soft_mute=${False}
                                                    ...    is_1st_dl_update_soft_mute=${False}
                                                    ...    is_2nd_dl_update_soft_mute=${False}
                                                    ...    check_PWR=${True}
                                                    ...    is_sl_update_pwr=${False}
                                                    ...    is_1st_dl_update_pwr=${False}
                                                    ...    is_2nd_dl_update_pwr=${False}
                                                    ...    check_cell_load=${True}
                                                    ...    is_high_cell_load=${True}
                                                    ...    cell_load_threshold_for_rim_mitigation=${cell_load_threshold}
                                                    ...    Check_high_priority_data=${True}
                                                    ...    is_high_prio_data_enabled=${False}
    [Teardown]    run keyword and continue on failure    Stop data transfer and detach UE  data_transfer_direction=dl

TC_02_step3_decrease DL tp and check DL muting when low cell load
    [Documentation]    Decrease the DL traffic to make it less than cellLoadThreshForRimMitigation.
    ...    cellLoadThreshForRimMitigation is set to 40 in case setup. also check the fault 7525,7527,7535
    ...    Step3_1: check DL mute counters(M55194C00003, M55194C00281) updated
    ...    Step3_2: check the special slot and DL slot preceding the special slot are muted in BIP log.
    log to console    step3: decrease DL tp and check DL muting when low cell load
    run keyword and continue on failure     L3 call and Start Traffic    dl_tput=100M    ul_tput=${UL_TPUT}    duration=10000
                                                        ...    data_transfer_direction=dl    prepare_ue_needed=${False}
    ${cell_load_threshold}    evaluate    ${CELL_LOAD_THRESHOLD_FOR_RIM_MITIGATION}/100

    run keyword and continue on failure     Check there is fault 7525 no fault 7527 fault 7535
    run keyword and continue on failure     Wait and Get NRRIMINFO via WEBEM and Check NRRIMINFO Value is as Expected
    ...    riState=${None}    asymmetricState=${None}    rimRsSetIdType1=${None}    rimRsSetIdType2=${None}
    ...    pdschMutingStatus=${DLMUTESLOTSSTR_CM}    pdcchMutingStatus=${None}

    ${start_time}    Prepare for counter log
    run keyword and continue on failure     check slot scheculed info      pdsch_slot_list=${MUTE_SLOT_LIST}     capture_time=3 sec
    ...    is_pdsch_scheduled_on_related_slot=${False}    mirroring_filter=SpecificL1L2Messages
    ...    target_file_name=step3_bip_log_low_cell_load_dl_muting

    ${pm_files_local_path}    Wait for PM file generated and download    starting_log_timestamp=${start_time['log_generator_timestamp']}
    run keyword and continue on failure    Check PM counters for soft muting or power reduction
                                                   ...    pm_files_local_path=${pm_files_local_path}
                                                   ...    Check_Mitigation=${True}
                                                   ...    is_sl_update_soft_mute=${True}
                                                   ...    is_1st_dl_update_soft_mute=${False}
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

TC_02_step4_update cellLoadThreshForRimMitigation to 1 and check no DL muting when high cell load
    [Documentation]    update cellLoadThreshForRimMitigation=1 to make TP higher than cellLoadThreshForRimMitigation
    ...    Step4_1: check DL mute counters(M55194C00003, M55194C00281) not updated.
    log to console    step4: update cellLoadThreshForRimMitigation to 1 and check no DL muting when high cell load
    coam_gnb_classical.COAM Update several parameters via rest api
    ...    parameters_to_update_via_api=${UPDATE_CELLLOADTHRESHFORRIMMITIGATION_TO_1_API_VICTIM}
    ...    skip_parameter_relation_errors=${False}
    ...    connection=${connection_GNB_victim}
    ${start_time}    Prepare for counter log
    ${pm_files_local_path}    Wait for PM file generated and download    starting_log_timestamp=${start_time['log_generator_timestamp']}
    run keyword and continue on failure    Check PM counters for soft muting or power reduction
                                                    ...    pm_files_local_path=${pm_files_local_path}
                                                    ...    Check_Mitigation=${True}
                                                    ...    is_sl_update_soft_mute=${False}
                                                    ...    is_1st_dl_update_soft_mute=${False}
                                                    ...    is_2nd_dl_update_soft_mute=${False}
                                                    ...    check_PWR=${True}
                                                    ...    is_sl_update_pwr=${False}
                                                    ...    is_1st_dl_update_pwr=${False}
                                                    ...    is_2nd_dl_update_pwr=${False}
                                                    ...    check_cell_load=${True}
                                                    ...    is_high_cell_load=${True}
                                                    ...    cell_load_threshold_for_rim_mitigation=0.1
                                                    ...    Check_high_priority_data=${True}
                                                    ...    is_high_prio_data_enabled=${False}

TC_02_step5_disable CB013350 and check alarm counter and slot schedule info
    [Documentation]    update actRimSoftDlMuting=false
    ...    Step5_1: check fault 7525 not disappear and fault 7535 reported.
    ...    Step5_2: check DL mute counters(M55194C00003, M55194C00281) updated.
    ...    Step5_3: check the special slot and DL slot preceding the special slot are muted in BIP log.
    [Arguments]    ${cell_list}=@{TDD_CELL_ID_LIST}    ${gnb_index}=0    ${connection_GNB_victim}=${OAM_ALIAS_GNB0}
    log to console    step5: disable CB013350 and check alarm counter and slot schedule info， change muting to "CM_OFF, FM_ON"
    AlarmWatchdog.add_allow_alarms    fault_id=7535
    coam_gnb_classical.COAM Update several parameters via rest api
    ...    parameters_to_update_via_api=${DISABLE_13350_MUTE_CM_API_VICTIM}
    ...    skip_parameter_relation_errors=${False}
    ...    connection=${connection_GNB_victim}
    ${start_time}    Prepare for counter log
    #Step5.1_check fault 7525 not disappear and fault 7535 reported and no fault 7527
    ${supplementary_7535}    Get Supplementary for Fault 7535    dlMuteSlotsStr=${DLMUTESLOTSSTR}
    run keyword and continue on failure     Expect Fault Present on Cells or not    cell_list=${cell_list}
                                                   ...    faultId=7525    alarmId=7115   present=${True}
                                                   ...    connection=${connection_GNB_victim}    gnb_index=${gnb_index}
    run keyword and continue on failure     Wait and Verify Fault Present on Cells    faultId=7535    alarm_check_timeout=1m
                                                   ...    alarm_check_interval=10sec
                                                   ...    supplementary=${supplementary_7535}
    run keyword and continue on failure     Expect Fault Present on Cells or not    cell_list=${cell_list}
                                        ...    faultId=7527    alarmId=7115   present=${False}
                                        ...    connection=${connection_GNB_victim}     gnb_index=${gnb_index}
    run keyword and continue on failure     Wait and Get NRRIMINFO via WEBEM and Check NRRIMINFO Value is as Expected
    ...    riState=${None}    asymmetricState=${None}    rimRsSetIdType1=${None}    rimRsSetIdType2=${None}
    ...    pdschMutingStatus=${None}    pdcchMutingStatus=${None}    wait_time=10sec

    #Step5.2_check the special slot and DL slot preceding the special slot are muted in BIP log
    run keyword and continue on failure     check slot scheculed info
                                                  ...    pdsch_slot_list=${MUTE_SLOT_LIST}
                                                  ...    capture_time=3sec
                                                  ...    is_pdsch_scheduled_on_related_slot=${False}
                                                  ...    mirroring_filter=SpecificL1L2Messages
                                                  ...    target_file_name=step5_bip_log_disable_13350_dl_muting

    #Step5.3_check DL mute counters M55194C00003 M55194C00281 updated
    ${pm_files_local_path}    Wait for PM file generated and download    starting_log_timestamp=${start_time['log_generator_timestamp']}
    run keyword and continue on failure    Check PM counters for soft muting or power reduction
                                                    ...    pm_files_local_path=${pm_files_local_path}
                                                    ...    Check_Mitigation=${True}
                                                    ...    is_sl_update_soft_mute=${True}
                                                    ...    is_1st_dl_update_soft_mute=${False}
                                                    ...    is_2nd_dl_update_soft_mute=${False}
                                                    ...    check_cell_load=${False}

TC_02_Step6_stop RI and check fault 7525 7527 canceled and DL mitigation stopped
    [Arguments]    ${exp_dl_tput_gap}=5    ${exp_ul_tput_gap}=3
    log to console    Step6: stop RI and check fault 7525 7527 canceled and DL mitigation stopped
    run keyword and ignore error    Stop data transfer and detach UE
    Trigger RI Disappear and Check Fault 7525 7527 canceled and DL Mitigation stopped
                                                ...    SetId_Aggressor=${CONFIGS_GNB1["rsSetId"]}
                                                ...    dlMuteSlotsStr=${DLMUTESLOTSSTR}
                                                ...    feature=9823
                                                ...    exp_dl_tput_gap=${exp_dl_tput_gap}
                                                ...    exp_ul_tput_gap=${exp_ul_tput_gap}
                                                ...    setId_show_in_fault=${True}
                                                ...    check_pcmd_setid_removed=${False}
                                                ...    should_7527_in_alarm_history=${False}
                                                ...    7535_check=${True}
                                                ...    riState=${None}
                                                ...    asymmetricState=${None}
                                                ...    rimRsSetIdType1=${None}
                                                ...    rimRsSetIdType2=${None}
                                                ...    pdschMutingStatus=${None}
                                                ...    pdcchMutingStatus=${None}
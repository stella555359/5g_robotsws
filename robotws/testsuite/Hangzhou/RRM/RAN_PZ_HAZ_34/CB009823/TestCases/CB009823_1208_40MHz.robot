*** Settings ***
Resource    ./../Resources/CB009823_keywords.robot

Documentation    Suite description
...    author:Fang Ludan
...    contact: ludan.fang@nokia-sbell.com
...    squad group: I_NSB_MN_RAN_RD_VRF_HAZ3_01_S1_GMS
...    Feature CB009823

Suite Setup  9823 Suite preparation multiGNB
Suite Teardown  run keyword and ignore error    Common suite recovery

*** Variables ***
${DL_TPUT}         600M
${UL_TPUT}         100M

*** Test Cases ***
[1]CB009823-SR-B_TC401_Start_DL-Mitigation_by-rimDLMitigationManualTrigger_regardlessOf-RI-and-RS_Detection_r2_1208-70MHz_on-Loki
    [Documentation]
    ...    UE-2 attach and start DL traffic for data over NAS/SA on gNB2.
    ...    set targetload=100, check alarm 7525 and 7527,rimDLMitigationManualTrigger=false
    ...    check RiMRS counter
    ...    set numDetectedSetIdForMitigation=2 ,check no mitigation
    ...    set numDetectedSetIdForMitigation=1 ,targetload=0 ,check 7525 cancle,7527 still exsit and mitigation ongoing
    ...    Set aggressor rsTransTrigger=ritrigger, check 7527 cancle
    ...    set rimDLMitigationManualTrigger=S ,check mitigation on S slot
    ...    set rimDLMitigationManualTrigger=S+D ,check mitigation on S+D slot
    [Setup]     9823 case setup    lock_cell=${False}  targetTotalLoad=${True}    frame_bw=40M_1208
    Set case variable
    log to console    Make L3 call and Check no DL Mitigation before RI, then Unlock aggressor cells
    Steps Make L3 call and Check no DL Mitigation before RI    target_file_name=1_bip_before_RI_no_mute

    run keyword and continue on failure    Unlock cells   lock_cell_list=@{CELL_LIST_GNB1}   lock_cell_connection=${OAM_ALIAS_GNB1}
    Set aggressor targetTotalLoad via restAPI   paras=${RESTAPI_MODIFY_TARGET_TOTAL_LOAD}

    log to console    Check fault 7525 raised and check RI from syslog, check RI info from PCMD log
    Steps Check Fault 7525 raised and RI PCMD When RI   framestructure=${frameStructureBW}
                                                ...    transmission_window=${transmission_window}
                                                ...    near_far=${CONFIGS_GNB0["rsNearFarConfig"]}
                                                ...    repetition=${CONFIGS_GNB0["repetitionRsType1"]}
                                                ...    ri_monitor_special_slot_list=${RI_MONITOR_S_SLOT_LIST}
                                                ...    ri_monitor_ul_slot_list=${RI_MONITOR_UL_SLOT_LIST}
                                                ...    check_ri_pcmd=${false}

    log to console    Check fault 7527 raised and RIMRS PCMD log, then make call and check DL mitigation from bip log
    Steps Check Fault 7527 raised and RIMRS PCMD and DL Mitigation started from Bip When RI   SetId_Aggressor=${CONFIGS_GNB1["rsSetId"]}
                                                ...    dlMuteSlotsStr=${dlMuteSlotsStr}
                                                ...    repetitionRsType1=${CONFIGS_GNB0["repetitionRsType1"]}
                                                ...    repetitionRsType2=${CONFIGS_GNB0["repetitionRsType2"]}
                                                ...    check_rimrs_pcmd=${False}
                                                ...    feature=9823
                                                ...    target_file_name=2_bip_during_RI
                                                ...    setId_show_in_fault=${True}
                                                ...    check_rimrs_detect_enable=${False}
                                                ...    check_bip_needed=${False}

    ${list_measurement_ids}    create list    M55194C00001    M55194C00002   M55194C00003   M55194C00004  M55194C00006  M55194C00008
    ...   M55194C00005    M55194C00007   M55194C00009    M55194C00010   M55194C00011   M55194C00012   M55194C00013   M55308C22008
    ...   M55194C00281    M55194C00282
    run keyword and continue on failure    Steps Check PM Counters for RI and RIMRS
                                                    ...    list_measurement_ids=${list_measurement_ids}
                                                    ...    ul_ri_symbols=${8}
                                                    ...    is_1st_dl_mute=${False}
                                                    ...    rimrs_setid_num=${1}
                                                    ...    RSSI_SB2=${False}
                                                    ...    RSSI_SB3=${False}
                                                    ...    RSSI_SB4=${False}
                                                    ...    Check_RIMRS_new_DET_EXP=${True}
                                                    ...    Check_RIMRS2=${True}

	Set victim numDetectedSetIdForMitigation via restAPI   paras=${RESTAPI_numDetectedSetIdForMitigation_victim_2}
	log to console     check mitigation not ongoing
	run keyword and continue on failure   Make L3 call then Check DL Mitigation and SRS Status
	                                              ...         is_pdsch_scheduled_on_s_d_slot=${true}
	                                              ...         pdsch_slot_list=${MUTE_SLOT_LIST}
	                                              ...         tput_check=${false}
	                                              ...         target_file_name=3_bip_during_RI_no_mute

	Set victim numDetectedSetIdForMitigation via restAPI   paras=${RESTAPI_numDetectedSetIdForMitigation_victim_1}
    Set aggressor targetTotalLoad via restAPI   paras=${RESTAPI_MODIFY_NO_TARGET_TOTAL_LOAD}

    log to console     check 7525 cancle and 7527 still present  and DL mitigation still ongoing
    Wait and Verify Fault 7525 not Present on Cells
	Steps Check Fault 7527 raised and RIMRS PCMD and DL Mitigation started from Bip When RI   SetId_Aggressor=${CONFIGS_GNB1["rsSetId"]}
                                                ...    dlMuteSlotsStr=${dlMuteSlotsStr}
                                                ...    repetitionRsType1=${CONFIGS_GNB0["repetitionRsType1"]}
                                                ...    repetitionRsType2=${CONFIGS_GNB0["repetitionRsType2"]}
                                                ...    check_rimrs_pcmd=${false}
                                                ...    feature=9823
                                                ...    target_file_name=4_bip_no_7525
                                                ...    check_rimrs_detect_enable=${False}
                                                ...    check_bip_needed=${False}
                                                ...    setId_show_in_fault=${True}

    Set aggressor rsTransTrigger via restAPI        paras=${MODIFY_rsTransTrigger_API_GNB1}
    log to console    check fault 7527 canceled
    Wait and Verify Fault 7527 not Present on Cells

	Set victim rimDLMitigationManualTrigger via restAPI   paras=${RESTAPI_rimDLMitigationManualTrigger_victim_S}
	log to console     check mitigation only on S slot
	run keyword and continue on failure     Make L3 call then Check DL Mitigation and SRS Status   is_pdsch_scheduled_on_s_d_slot=${false}
	                                              ...         pdsch_slot_list=${SPECIAL_SLOT_LIST_1208}
	                                              ...         target_file_name=5_bip_no_7527_manual_mute_S
	                                              ...         dl_exp=${TDD_DL_EXP_TPUT_40M_1208_mute_S}
	                                              ...         ul_exp=${TDD_UL_EXP_TPUT}
    run keyword and continue on failure    run keyword if   '${PROGRAM}'>='24R3'
    ...    Wait and Verify Fault 7535 not Present on Cells

	Set victim rimDLMitigationManualTrigger via restAPI   paras=${RESTAPI_rimDLMitigationManualTrigger_victim_S_D}
	log to console     check mitigation on S and D slot
	run keyword and continue on failure     Make L3 call then Check DL Mitigation and SRS Status   is_pdsch_scheduled_on_s_d_slot=${false}
	                                              ...         pdsch_slot_list=${MUTE_SLOT_LIST}
	                                              ...         target_file_name=6_bip_no_7527_manual_mute_S_D
	                                              ...         tput_check=${false}
	run keyword and continue on failure    run keyword if   '${PROGRAM}'>='24R3'
    ...    Wait and Verify Fault 7535 not Present on Cells

    [Teardown]  run keyword and ignore error    9823 case teardown   detach_ue=${True}   targetTotalLoad=${True}


*** Keywords ***
Set case variable
    [Documentation]    Set variables for 9823
    ...    Author: Fang Ludan
    @{SPECIAL_SLOT_LIST}    set variable    ${SPECIAL_SLOT_LIST_1208}
    @{MUTE_SLOT_LIST}    set variable    ${SPECIAL_SLOT_LIST_1208}
    @{RI_MONITOR_S_SLOT_LIST}    set variable if    '${PROGRAM}'<'25R1'    ${RI_MONITOR_S_SLOT_LIST_1208}    ${RI_MONITOR_S_SLOT_LIST_1208_V2}
    @{RI_MONITOR_UL_SLOT_LIST}    set variable if    '${PROGRAM}'<'25R1'    ${RI_MONITOR_UL_SLOT_LIST_1208}    ${RI_MONITOR_UL_SLOT_LIST_1208_V2}
    set test variable    @{SPECIAL_SLOT_LIST}
    set test variable    @{MUTE_SLOT_LIST}
    set test variable    @{RI_MONITOR_S_SLOT_LIST}
    set test variable    @{RI_MONITOR_UL_SLOT_LIST}
    set test variable    ${TDD_DL_EXP_TPUT}     ${TDD_DL_EXP_TPUT_40M_1208}
    set test variable    ${TDD_UL_EXP_TPUT}     ${TDD_UL_EXP_TPUT_40M_1208}
    set test variable    ${transmission_window}     6min
    set test variable    ${frameStructureBW}     1208_2gp_40mhz
    set test variable    ${dlMuteSlotsStr}     ${DL_MUTE_SLOTS_SPECIAL}

Set aggressor rsTransTrigger via restAPI
    [Documentation]    Set rsTransTrigger via restAPI
    ...    Author: Fang ludan
    [Arguments]    ${paras}
    coam_gnb_classical.COAM Update several parameters via rest api
    ...    parameters_to_update_via_api=${paras}
    ...    skip_parameter_relation_errors=${False}
    ...    connection=${OAM_ALIAS_GNB1}

Set victim numDetectedSetIdForMitigation via restAPI
    [Documentation]    Set rsTransTrigger via restAPI
    ...    Author: Fang ludan
    [Arguments]    ${paras}
    coam_gnb_classical.COAM Update several parameters via rest api
    ...    parameters_to_update_via_api=${paras}
    ...    skip_parameter_relation_errors=${False}
    ...    connection=${OAM_ALIAS_GNB0}

Set victim rimDLMitigationManualTrigger via restAPI
    [Documentation]    Set rsTransTrigger via restAPI
    ...    Author: Fang ludan
    [Arguments]    ${paras}
    coam_gnb_classical.COAM Update several parameters via rest api
    ...    parameters_to_update_via_api=${paras}
    ...    skip_parameter_relation_errors=${False}
    ...    connection=${OAM_ALIAS_GNB0}

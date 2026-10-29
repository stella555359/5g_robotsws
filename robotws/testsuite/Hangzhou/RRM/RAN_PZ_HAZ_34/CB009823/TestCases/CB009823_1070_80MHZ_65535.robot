*** Settings ***
Resource    ./../Resources/CB009823_keywords.robot

Documentation    Suite description
...    author: Fang ludan
...    contact: ludan.fang@nokia-sbell.com
...    squad group: I_NSB_MN_RAN_RD_VRF_HAZ3_01_S1_GMS
...    Feature CB009823

Suite Setup  9823 Suite preparation multiGNB
Suite Teardown  run keyword and ignore error    Common suite recovery

*** Variables ***
${DL_TPUT}         1400M
${UL_TPUT}         350M

*** Test Cases ***
[1]CB009823-SR-L_TC102_RIM-RS1_and_RS2_Transmission_NEAR-FAR_config2_r4_and_Detection_Slopping-Based_with_Framework-1_1070_80MHz_on-Loki
    [Documentation]
    ...    UE-2 attach and start DL traffic for data over NAS/SA on gNB2.
    ...    set targetload=100, check alarm 7525 and 7527
    ...    set repetitionRsType1=R2, check 7527 cancle and 7527 raise again
    ...    set repetitionRsType2=R2, check 7527 cancle and 7527 raise again
    [Setup]     9823 case setup    lock_cell=${True}  targetTotalLoad=${True}    frame_bw=80M_1070_65535
    Set case variable
    log to console    Make L3 call and Check no DL Mitigation before RI, then Unlock aggressor cells
    Steps Make L3 call and Check no DL Mitigation before RI    check_bip_needed=${False}

    run keyword and continue on failure    Unlock cells
    Set aggressor targetTotalLoad via restAPI   paras=${RESTAPI_MODIFY_TARGET_TOTAL_LOAD}

    log to console    Check fault 7525 raised and check RI from syslog, check RI info from PCMD log
    Steps Check Fault 7525 raised and RI PCMD When RI   framestructure=${frameStructureBW}
                                                ...    transmission_window=${transmission_window}
                                                ...    near_far=${CONFIGS_GNB0["rsNearFarConfig"]}
                                                ...    repetition=${CONFIGS_GNB0["repetitionRsType1"]}
                                                ...    ri_monitor_special_slot_list=${RI_MONITOR_S_SLOT_LIST}
                                                ...    ri_monitor_ul_slot_list=${RI_MONITOR_UL_SLOT_LIST}

    log to console    Check fault 7527 raised and RIMRS PCMD log, then make call and check DL mitigation from bip log
    Steps Check Fault 7527 raised and RIMRS PCMD and DL Mitigation started from Bip When RI   SetId_Aggressor=${CONFIGS_GNB1["rsSetId"]}
                                                ...    dlMuteSlotsStr=${dlMuteSlotsStr}
                                                ...    repetitionRsType1=${CONFIGS_GNB0["repetitionRsType1"]}
                                                ...    repetitionRsType2=${CONFIGS_GNB0["repetitionRsType2"]}
                                                ...    check_rimrs_pcmd=${True}
                                                ...    feature=9823
                                                ...    repetition1_no_check=${1}
                                                ...    repetition2_no_check=${1}
                                                ...    target_file_name=1_bip_during_RI
                                                ...    tcpdump_collector_name=1_CB0010437_PCMD_RIMRS_r4_r4
                                                ...    check_rimrs_detect_enable=${False}

    Set victim and aggressor repetitionRsType via restAPI   paras_gnb0=${RESTAPI_repetitionRsType1_victim}
                                                ...    paras_gnb1=${RESTAPI_repetitionRsType1_aggressor}
    log to console    check fault 7527 canceled
    run keyword and ignore error    Wait and Verify Fault 7527 not Present on Cells

    log to console    check fault 7527 raise
    Steps Check Fault 7527 raised and RIMRS PCMD and DL Mitigation started from Bip When RI   SetId_Aggressor=${CONFIGS_GNB1["rsSetId"]}
                                                ...    dlMuteSlotsStr=${dlMuteSlotsStr}
                                                ...    repetitionRsType1=r2
                                                ...    repetitionRsType2=${CONFIGS_GNB0["repetitionRsType2"]}
                                                ...    check_rimrs_pcmd=${True}
                                                ...    feature=9823
                                                ...    srs_check=not exist
                                                ...    repetition1_no_check=${1}
                                                ...    repetition2_no_check=${1}
                                                ...    target_file_name=2_bip_during_RI
                                                ...    tcpdump_collector_name=2_CB0010437_PCMD_RIMRS_r2_r4

    Set victim and aggressor repetitionRsType via restAPI   paras_gnb0=${RESTAPI_repetitionRsType2_victim}
                                                ...    paras_gnb1=${RESTAPI_repetitionRsType2_aggressor}
    log to console    check fault 7527 canceled
    run keyword and continue on failure    Wait and Verify Fault 7527 not Present on Cells

    log to console    check fault 7527 raise
    Steps Check Fault 7527 raised and RIMRS PCMD and DL Mitigation started from Bip When RI   SetId_Aggressor=${CONFIGS_GNB1["rsSetId"]}
                                                ...    dlMuteSlotsStr=${dlMuteSlotsStr}
                                                ...    repetitionRsType1=r2
                                                ...    repetitionRsType2=r2
                                                ...    check_rimrs_pcmd=${True}
                                                ...    feature=9823
                                                ...    repetition1_no_check=${1}
                                                ...    repetition2_no_check=${1}
                                                ...    target_file_name=3_bip_during_RI
                                                ...    tcpdump_collector_name=3_CB0010437_PCMD_RIMRS_r2_r2
                                                ...    check_rimrs_detect_enable=${False}

    log to console    start to set targetTotalload to 0 and check if alarm 7525 & 7527 canceled
    Steps Trigger RI Disappear and Check Fault 7525 7527 canceled and DL Mitigation stopped
                                                ...    SetId_Aggressor=${CONFIGS_GNB1["rsSetId"]}
                                                ...    dlMuteSlotsStr=${dlMuteSlotsStr}
                                                ...    feature=9823
                                                ...    srs_check=exist
                                                ...    lock_cell=${True}
                                                ...    targetTotalLoad=${True}

    [Teardown]  run keyword and ignore error    9823 case teardown   detach_ue=${True}  targetTotalLoad=${True}    unlock_cell=${True}


*** Keywords ***
Set case variable
    [Documentation]    Set variables for 9823
    ...    Author: Fang ludan
    @{SPECIAL_SLOT_LIST}    set variable    ${SPECIAL_SLOT_LIST_1070}
    @{MUTE_SLOT_LIST}    Combine Lists    ${SPECIAL_SLOT_LIST_1070}    ${PRECED_DL_SLOT_LIST_1070}
    @{RI_MONITOR_S_SLOT_LIST}    set variable if    '${PROGRAM}'<'25R1'    ${RI_MONITOR_S_SLOT_LIST_1070}    ${RI_MONITOR_S_SLOT_LIST_1070_V2}
    @{RI_MONITOR_UL_SLOT_LIST}    set variable if    '${PROGRAM}'<'25R1'    ${RI_MONITOR_UL_SLOT_LIST_1070}    ${RI_MONITOR_UL_SLOT_LIST_1070_V2}
    set test variable    @{SPECIAL_SLOT_LIST}
    set test variable    @{MUTE_SLOT_LIST}
    set test variable    @{RI_MONITOR_S_SLOT_LIST}
    set test variable    @{RI_MONITOR_UL_SLOT_LIST}
    set test variable    ${TDD_DL_EXP_TPUT}     ${TDD_DL_EXP_TPUT_100M_1070_65535}
    set test variable    ${TDD_UL_EXP_TPUT}     ${TDD_UL_EXP_TPUT_100M_1070_65535}
    set test variable    ${transmission_window}     6min
    set test variable    ${frameStructureBW}     1070_2gp_80mhz
    set test variable    ${dlMuteSlotsStr}     ${DL_MUTE_SLOTS_SPECIAL_PRECEDING}

Set victim and aggressor repetitionRsType via restAPI
    [Documentation]    Set repetitionRsType
    ...    Author: Fang Ludan
    [Arguments]    ${paras_gnb0}   ${paras_gnb1}
    coam_gnb_classical.COAM Update several parameters via rest api
    ...    parameters_to_update_via_api=${paras_gnb1}
    ...    skip_parameter_relation_errors=${False}
    ...    connection=${OAM_ALIAS_GNB1}
    coam_gnb_classical.COAM Update several parameters via rest api
    ...    parameters_to_update_via_api=${paras_gnb0}
    ...    skip_parameter_relation_errors=${False}
    ...    connection=${OAM_ALIAS_GNB0}

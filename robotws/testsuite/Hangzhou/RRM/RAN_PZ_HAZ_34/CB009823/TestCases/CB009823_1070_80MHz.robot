*** Settings ***
Resource    ./../Resources/CB009823_keywords.robot

Documentation    Suite description
...    author: Wang Yixiang
...    contact: yixiang.x.wang@nokia-sbell.com
...    squad group: I_NSB_MN_RAN_RD_VRF_HAZ3_01_S1_GMS
...    Feature CB009823

Suite Setup  9823 Suite preparation multiGNB
Suite Teardown  run keyword and ignore error    Common suite recovery

*** Variables ***
${DL_TPUT}         1200M
${UL_TPUT}         300M

*** Test Cases ***
CB009823-SR-B_TC301_Stop_RIM-RS1_and_RS2_Detection_afterRI-Disappeared_different-repetition_1070-80MHz_on-Loki
    [Tags]    CRT_TRUNK
    [Documentation]
    ...    UE-2 attach and start DL traffic for data over SA on gNB2.
    ...    unlock aggressor cell on gnb1, check alarm 7525 and 7527, setid, SRS stop and rimRsDetectionRequest=True of gNB2
    ...    lock aggressor cell on gnb1, check 7525 and 7527 disappear, SRS resume, check TPUT
    [Setup]     9823 case setup    lock_cell=${True}    targetTotalLoad=${False}    frame_bw=80M_1070
    Set case variable
    log to console    Make L3 call and Check no DL Mitigation before RI, then Unlock aggressor cells
    Steps Make L3 call and Check no DL Mitigation before RI    before_ri=${false}
    run keyword and continue on failure    Unlock cells   lock_cell_list=@{CELL_LIST_GNB1}   lock_cell_connection=${OAM_ALIAS_GNB1}
    Set aggressor targetTotalLoad via restAPI   paras=${RESTAPI_MODIFY_TARGET_TOTAL_LOAD}

    log to console    Check fault 7525 raised and check RI from syslog, check RI info from PCMD log
    Steps Check Fault 7525 raised and RI PCMD When RI   framestructure=${frameStructureBW}
                                                ...    transmission_window=${transmission_window}
                                                ...    near_far=${CONFIGS_GNB0["rsNearFarConfig"]}
                                                ...    repetition=${CONFIGS_GNB0["repetitionRsType1"]}
                                                ...    ri_monitor_special_slot_list=${RI_MONITOR_S_SLOT_LIST}
                                                ...    ri_monitor_ul_slot_list=${RI_MONITOR_UL_SLOT_LIST}
                                                ...    check_ri_pcmd=${False}

    log to console    Check fault 7527 raised and RIMRS PCMD log, then make call and check DL mitigation from bip log
    Steps Check Fault 7527 raised and RIMRS PCMD and DL Mitigation started from Bip When RI with update p0 if needed

    log to console    start to lock aggressor cell and check if alsrm 7525 & 7527 canceled
    Steps Trigger RI Disappear and Check Fault 7525 7527 canceled and DL Mitigation stopped
                                                ...    SetId_Aggressor=${CONFIGS_GNB1["rsSetId"]}
                                                ...    dlMuteSlotsStr=${dlMuteSlotsStr}
                                                ...    feature=9823
                                                ...    check_bip_needed=${True}
                                                ...    srs_check=exist
                                                ...    after_ri=${false}
                                                ...    check_rs_detect_false=${True}
                                                ...    exp_dl_tput_gap=${exp_dl_tput_gap}
                                                ...    exp_ul_tput_gap=${exp_ul_tput_gap}
                                                ...    setId_show_in_fault=${True}
                                                ...    check_pcmd_setid_removed=${True}
    [Teardown]  run keyword and ignore error    9823 case teardown   detach_ue=${True}
    ...    unlock_cell=${True}    targetTotalLoad=${True}

*** Keywords ***
Set case variable
    [Documentation]    Set variables for 9823
    ...    Author: Wang Yixiang
    @{SPECIAL_SLOT_LIST}    set variable    ${SPECIAL_SLOT_LIST_1070}
    @{MUTE_SLOT_LIST}    Combine Lists    ${SPECIAL_SLOT_LIST_1070}    ${PRECED_DL_SLOT_LIST_1070}
    @{RI_MONITOR_S_SLOT_LIST}    set variable if    '${PROGRAM}'<'25R1'    ${RI_MONITOR_S_SLOT_LIST_1070}    ${RI_MONITOR_S_SLOT_LIST_1070_V2}
    @{RI_MONITOR_UL_SLOT_LIST}    set variable if    '${PROGRAM}'<'25R1'    ${RI_MONITOR_UL_SLOT_LIST_1070}    ${RI_MONITOR_UL_SLOT_LIST_1070_V2}
    set test variable    @{SPECIAL_SLOT_LIST}
    set test variable    @{MUTE_SLOT_LIST}
    set test variable    @{RI_MONITOR_S_SLOT_LIST}
    set test variable    @{RI_MONITOR_UL_SLOT_LIST}
    set test variable    ${TDD_DL_EXP_TPUT}     ${TDD_DL_EXP_TPUT_80M_1070}
    set test variable    ${TDD_UL_EXP_TPUT}     ${TDD_UL_EXP_TPUT_80M_1070}
    set test variable    ${transmission_window}     6min
    set test variable    ${frameStructureBW}     1070_2gp_80mhz
    set test variable    ${dlMuteSlotsStr}     ${DL_MUTE_SLOTS_SPECIAL_PRECEDING}
    ${exp_dl_tput_gap}   evaluate    ${TDD_DL_EXP_TPUT}*0.03
    ${exp_ul_tput_gap}   evaluate    ${TDD_UL_EXP_TPUT}*0.03
    set test variable    ${exp_dl_tput_gap}
    set test variable    ${exp_ul_tput_gap}

Steps Check Fault 7527 raised and RIMRS PCMD and DL Mitigation started from Bip When RI with update p0 if needed
    run keyword if    '${tl.gnbs[0].instance_id}'=='4294967184'    coam_gnb_classical.COAM Update several parameters via rest api
                                                 ...    parameters_to_update_via_api=${RESTAPI_p0NominalPusch}
                                                 ...    skip_parameter_relation_errors=${False}
                                                 ...    connection=${OAM_ALIAS_GNB0}

    Steps Check Fault 7527 raised and RIMRS PCMD and DL Mitigation started from Bip When RI   SetId_Aggressor=${CONFIGS_GNB1["rsSetId"]}
                                                ...    dlMuteSlotsStr=${dlMuteSlotsStr}
                                                ...    repetitionRsType1=${CONFIGS_GNB0["repetitionRsType1"]}
                                                ...    repetitionRsType2=${CONFIGS_GNB0["repetitionRsType2"]}
                                                ...    check_rimrs_pcmd=${False}
                                                ...    feature=9823
                                                ...    srs_check=not exist
                                                ...    pcmd_log_time=5min
                                                ...    setId_show_in_fault=${True}

    [Teardown]    run keyword if   '${tl.gnbs[0].instance_id}'=='4294967184'   coam_gnb_classical.COAM Update several parameters via rest api
                                                 ...    parameters_to_update_via_api=${RESTAPI_p0NominalPusch_back}
                                                 ...    skip_parameter_relation_errors=${False}
                                                 ...    connection=${OAM_ALIAS_GNB0}

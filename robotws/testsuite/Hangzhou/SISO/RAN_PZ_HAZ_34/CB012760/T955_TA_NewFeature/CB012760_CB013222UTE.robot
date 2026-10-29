*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup           Run keywords    SG8 Common case Test Setup    AND    AlarmWatchdog.add_allow_alarms    fault_id=49
Test Teardown        Run keywords    AlarmWatchdog.remove_allow_alarms    fault_id=49     AND     SG8 Common case Test Teardown

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common_keywords.robot
Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/SG8_SISO_common_case/resources/SISO_common_case_keywords_SG8.robot
Variables   testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB012760/T955_TA_NewFeature/TestData/CB012760.py
Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB012760/T955_TA_NewFeature/resources/SISO_common_case_keywords_SG8_T955.robot


Documentation
...    Author:wangqingqing
...    contact:qingqing.wang@nokia-sbell.com
...    squad group:SG_08

Force Tags    RAN_5G_TDD    5G_RAN_TDD    RAN_5G    5G_RAN    CRT_UTE    STATE_SW_UPLOADED    SBTS00
...    PY36
...    CLOUD_5G_CLASSICAL_ANDROID_SA_ASIML_ABIPB1_AVNB

*** Variables ***
@{cell_id_common}    ${1}
${ui_version}    M40PUI1.1
@{cell_id_peak}    ${1}

*** Test Cases ***
[1][3.0] General_SiSo_Cell_block_and_unblock
    [Tags]    CRT_TRUNK
    General_SISO_Cell_Block_Unblock_SG08    tput_self_define=${tput_define_CB012760}    Max_loop=${1}    target_avg_percent=0.5
    ...    min_percent=0.4    cell_id=${cell_id_common}    duration=${120}    ui_version=${ui_version}

[1][2.0] Manual_SiSo_SM_RF_Module_lock_unlock
    [Tags]    CRT_TRUNK
    General_SISO_RU_Lock_Unlock_loop_With_Call_SG08    tput_self_define=${tput_define_CB012760}    Max_loop=${1}    target_avg_percent=0.4
    ...    min_percent=0.3    cell_id=${cell_id_common}    duration=${300}    ui_version=${ui_version}
    data_transfer_for_defined_nr_and_lte_cell    cell_id_nr=${3}    cell_id_lte=${0}    tput_define_nr=${tput_define_CB012760}
    ...    target_avg_percent_nr=0.5    min_percent_nr=0.3   target_avg_percent_lte=0.5    duration=${300}
    ...    ui_version=${ui_version}

[1][2.0] General_SiSo_RU_module_reset_from_GUI
    [Tags]    CRT_TRUNK
    General_SISO_RU_Reset_SG08    tput_self_define=${tput_define_CB012760}    Max_loop=${5}    target_avg_percent=0.4
    ...    min_percent=0.3    cell_id=${cell_id_common}    duration=${300}    ui_version=${ui_version}
    data_transfer_for_lte_cell      cell_id_lte=${0}        target_avg_percent_lte=0.7    duration=${300}

[1][2.0] Manual_SiSo_SM_BTS_Site_Reset
    [Tags]    CRT_TRUNK
    ${SCF_upload}    Replace String    ${Golden_SCF_Path}    .xml    _CB012760.xml
    COAM Commission with scf file    scf_file_path=${SCF_upload}    timeout=${600}
    Wait until keyword succeeds    15min    180s    Check all cells info should be onair
#    ${gNb_CuType}   Get gNB CU type
#    set test variable    ${gNb_CuType}
    ${cell_type}    ${cell_list_nr}    ${cell_list_lte}    Check cell type by cell ID
    Set Test Variable    ${cell_type}
    Set Test Variable    ${cell_list_nr}
    Set Test Variable    ${cell_list_lte}
    ${lnbtsID}    run keyword if    '${cell_type}' != 'nr_only'    Get lnbts ID via online SCF
    set test variable    ${lnbtsID}
    ${mrbtsID}    ${nrbtsID}   Get mrbtsID and nrbtsID via SCF for gNB    scf_path=${SCF_upload}
    set test variable    ${mrbtsID}
    set test variable    ${nrbtsID}
    log to console    ++++++++++++++++++++++++++++++++++++ ALl Rat Reset ++++++++++++++++++++++++++++++++++++
    Connect to gnb coam via ssl
    log to console    ---------------------------------------------------------------------------------------
    log to console    Step 1 Reset all rats
    log to console    ---------------------------------------------------------------------------------------
    Reset rat SG08
    sleep    20
    log to console    ---------------------------------------------------------------------------------------
    log to console    Step 2 All SMODs BBMODs RMODs and Cells onair
    log to console    ---------------------------------------------------------------------------------------
    All SMODs BBMODs RMODs and Cells should be onair
    Sleep    10
    csn.reset_cache

    log to console    ++++++++++++++++++++++++++++++++++ cell delete and add +++++++++++++++++++++++++++++++++++
     FOR    ${index}    IN RANGE    3
        log to console    ++++++++++++++++++++++++++++ cell delete and add ${index} ++++++++++++++++++++++++++++
        Online Cell addition deletion    addition_deletion_cell=${2}
    END

    log to console    ++++++++++++++++++++++++++++++++++++ Cell Lcok_Unlcok ++++++++++++++++++++++++++++++++++++
    log to console    ---------------------------------------------------------------------------------------
    log to console    Step 1 lock cells
    log to console    ---------------------------------------------------------------------------------------
    Connect to gnb coam via ssl
    Lock cells and check status via coam
    log to console    ---------------------------------------------------------------------------------------
    log to console    Step 2 unlock cells
    log to console    ---------------------------------------------------------------------------------------
    Unlock cells and check status via coam
    csn.reset_cache
    log to console    ++++++++++++++++++++++++++++++++++++ RU lock_unlcok ++++++++++++++++++++++++++++++++++++
    Connect to gnb coam via ssl
    log to console    ---------------------------------------------------------------------------------------
    log to console    Step 1 Lock all RMODs
    log to console    ---------------------------------------------------------------------------------------
    Lock all RMODs SG08
    sleep    20
    Check status after lock all RMODs
    sleep    30
    log to console    ---------------------------------------------------------------------------------------
    log to console    Step 2 unLock all RMODs
    log to console    ---------------------------------------------------------------------------------------
    Unlock all RMODs SG08
    sleep    10
    log to console    ---------------------------------------------------------------------------------------
    log to console    Step 3 All SMODs BBMODs RMODs and Cells onair
    log to console    ---------------------------------------------------------------------------------------
    All SMODs BBMODs RMODs and Cells should be onair
    Sleep    30
    csn.reset_cache
    log to console    ++++++++++++++++++++++++++++++++++++ All RAT blcok ++++++++++++++++++++++++++++++++++++
    AlarmWatchdog.add_allow_alarms    fault_id=4614
    Connect to gnb coam via ssl
    log to console    ---------------------------------------------------------------------------------------
    log to console    Step 1 Block all rats
    log to console    ---------------------------------------------------------------------------------------
    Block rat SG08
    sleep    10
    Check status after block all rats
    sleep    30
    log to console    ---------------------------------------------------------------------------------------
    log to console    Step 2 unBlock all rats
    log to console    ---------------------------------------------------------------------------------------
    UnBlock rat SG08
    sleep    10
    log to console    ---------------------------------------------------------------------------------------
    log to console    Step 3 All SMODs BBMODs RMODs and Cells onair
    log to console    ---------------------------------------------------------------------------------------
    All SMODs BBMODs RMODs and Cells should be onair
    Sleep    30
    csn.reset_cache
    AlarmWatchdog.remove_allow_alarms    fault_id=4616
    log to console    ++++++++++++++++++++++++++++++++++++ Lock BB ++++++++++++++++++++++++++++++++++++
    Connect to gnb coam via ssl
    Lock BB and check status via coam
    log to console    ++++++++++++++++++++++++++++++++++++ Unlock BB ++++++++++++++++++++++++++++++++++++
    Unlock BB and check status via coam
    csn.reset_cache
    General_SISO_Site_Reset_SG08    tput_self_define=${tput_define_CB012760}    Max_loop=${3}    target_avg_percent=0.98
    ...    min_percent=0.85    cell_id=${cell_id_peak}     duration=${300}    ui_version=${ui_version}
    data_transfer_for_lte_cell      cell_id_lte=${0}        target_avg_percent_lte=0.7    duration=${300}
    log to console    ++++++++++++++++++++++++++++++++++++ BB reset ++++++++++++++++++++++++++++++++++++
    &{fault_16}     Create Dictionary     faultId=${16}
    ${ALLOWED_FAULT}   Create List   @{ALLOWED_FAULT}   ${fault_16}
    set suite variable  ${ALLOWED_FAULT}
    &{fault_16}     Create Dictionary     faultId=${16}
    ${ALLOWED_HISTORY_FAULT}   Create List   @{ALLOWED_HISTORY_FAULT}   ${fault_16}
    set suite variable  ${ALLOWED_HISTORY_FAULT}
    AlarmWatchdog.add_allow_alarms    fault_id=16
    FOR    ${index}    IN RANGE    3
        log to console    ++++++++++++++++++++++++++++++++++++ BB reset ${index} +++++++++++++++++++++++++++++++++++
        Connect to gnb coam via ssl
        BB reset and check status via coam
        csn.reset_cache
    END
    AlarmWatchdog.remove_allow_alarms    fault_id=16


[1][1.0] General_SiSo_RAT_Reset
    [Tags]    CRT_TRUNK
    General_SISO_RAT_Reset_SG08    tput_self_define=${tput_define_CB012760}    Max_loop=${1}    target_avg_percent=0.5
    ...    min_percent=0.4    cell_id=${cell_id_common}    duration=${120}    ui_version=${ui_version}

[1]CB012091-SR-A_10 RU returning from PowerSaving Mode to normal operation due to change of EnergySavingMode
    [Tags]    CRT_TRUNK
    RU returning from PowerSaving Mode to normal operation due to change of EnergySavingMode







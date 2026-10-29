*** Settings ***

Documentation     author: Merin Varghese
...               contact: merin.varghese@nokia.com
...               Description: This feature tests ORAN FR2 scenarios with DCM IOT Profile 3.

Resource        ./DCM_Keywords.robot

Suite Setup       Common Suite Setup    feature_folder=DCM_FR2_profile3

*** Variables ***
${dl_tput}               5
${ul_tput}               5
@{NSA_UE_List}           1
@{NSA_UE_List_afterOAM}           2
#${capability_file}       capability.cfg
#${commands_file}         commands.lua
#${multi_ue_file}         multi_ue_sa_script_new
#${sansa_file}            sansa.lua

${TDD_NSA_DL_FR2_peak_TP_cfg}       ${CURDIR}/Config_Files/TDD_NSA_DL_FR2_profile3
&{TC1}    Cell_Count=1    NO_OF_CELLS=1    DIR=None       AMF_PAIR=1,1
   ...    AMF_COUNT=1    NO_REG=True    timer=1170
   ...    UEC_COUNT=6    LOOP_TIMES=1
   ...    NSA_CONFIGURATION=True   NSA_ENBX2_FUNC=NSA_x2_connections(1,1)    X2_LINK=True
   ...    NSA_UE_ID=1    OVERALL_DL=540
   ...    SIB_WAIT_TIME=60    test_entry=TC12_TDD_NSA_FR2_DL_peak_TP_with_DCM_IOT_Profile_3

${TDD_NSA_UL_FR2_peak_TP_cfg}       ${CURDIR}/Config_Files/TDD_NSA_UL_FR2_profile3
&{TC2}    Cell_Count=1    NO_OF_CELLS=1    DIR=UL
   ...    AMF_COUNT=5    NO_REG=True    timer=1170
   ...    NSA_CONFIGURATION=True   NSA_ENBX2_FUNC=NSA_x2_connections(1,1)    X2_LINK=True
   ...    UEC_COUNT=1    LOOP_TIMES=1    END_UE=1    OVERALL_UL=140
   ...    SIB_WAIT_TIME=60    test_entry=TC13_TDD_NSA_FR2_UL_peak_TP_with_DCM_IOT_Profile_3    timeout=120

${pdu_id}               2
${bearer_id}            2
${sib_validation}       False
${lane_distname}        MRBTS-1/EQM-1/APEQM-1/CABINET-1/BBMOD-1/SFP-1/LANE-1
${LOCK_UNLOCK_REPETITIONS}     1
${reset_repetitions}           1


*** Test Cases ***
TC1_Verify_peak_throughput in DL in FR2 NSA with DCM IOT Profile_3
    [Tags]    AP_REG    TDD_DL_FR2
    [Setup]    Test Setup for DCM    TC_dictionary=&{TC1}
    ...        feature=TDD_DL_FR2_peak_TP        custom_config=True
    ...    custom_config_folder=${TDD_NSA_DL_FR2_peak_TP_cfg}
    Initiate UE Register And Traffic
    Sleep    60s
    Run keyword And Continue On Failure
    ...    wait until keyword succeeds    2min    30s
    ...    Validate throughput from bearer stats for all UEs in DL only    ue_list=${NSA_UE_List}    expected_dl_tput=${OVERALL_DL}
    ...    mode=NSA    pdu_id=${pdu_id}
    Run Keyword And Continue On Failure    Stop Traffic and Detach NSA UEs    nsa_ue_list=${NSA_UE_List}    bearer_id=${bearer_id}
    [Teardown]    Simple Test Teardown    ${NSA_UE_List}

TC2_Verify_peak_throughput in UL in FR2 NSA with DCM IOT Profile_3
    [Tags]    AP_REG    TDD_UL_FR2
    [Setup]    Test Setup for DCM    TC_dictionary=&{TC2}
    ...        feature=TDD_UL_FR2_peak_TP        custom_config=True
    ...    custom_config_folder=${TDD_NSA_UL_FR2_peak_TP_cfg}
    Initiate UE Register And Traffic
    Sleep    60s
    Run keyword And Continue On Failure
    ...    wait until keyword succeeds    2min    30s
    ...    Validate throughput from bearer stats for all UEs in UL only    ue_list=${NSA_UE_List}
    ...    expected_ul_tput=${OVERALL_UL}    mode=NSA    pdu_id=${pdu_id}
    Run Keyword And Continue On Failure    Stop Traffic and Detach NSA UEs    nsa_ue_list=${NSA_UE_List}    bearer_id=${bearer_id}
    [Teardown]    Simple Test Teardown    ${NSA_UE_List}

TC3_Verify_lock_unlock_operations with DCM IOT Profile_3
    [Tags]    AP_REG    TDD_FR2_lock_unlock
    [Setup]    Test Setup for DCM    TC_dictionary=&{TC1}
    ...        feature=TDD_FR2_LockUnlock        custom_config=True
    ...    custom_config_folder=${TDD_NSA_DL_FR2_peak_TP_cfg}
    Initiate UE Register And Traffic
    Sleep    30s
    Run keyword And Continue On Failure
    ...    wait until keyword succeeds    2min    30s
    ...    Validate throughput from bearer stats for all UEs in DL only    ue_list=${NSA_UE_List}    expected_dl_tput=${OVERALL_DL}
    ...    mode=NSA    pdu_id=${pdu_id}
    Run Keyword And Continue On Failure    Stop Traffic and Detach NSA UEs    nsa_ue_list=${NSA_UE_List}    bearer_id=${bearer_id}
    ${fault_dict_before_oam}=    Run Keyword And Continue On Failure    Get Alarms
    Set Test Variable    ${fault_dict_before_oam}
    FOR    ${index}    IN RANGE    ${LOCK_UNLOCK_REPETITIONS}
        ${fault_dict_after_cell_lock}=    Perform Cell Lock Unlock With Validation
        ...    previous_fault_dict=${fault_dict_before_oam}    iteration_index=${index}
        ${fault_dict_after_rmod_lock}=    Perform RMOD Lock Unlock With Validation
        ...    previous_fault_dict=${fault_dict_after_cell_lock}    iteration_index=${index}
        ${fault_dict_after_lane_lock}=    Perform Lane lock unlock with alarm validation
        ...    previous_fault_dict=${fault_dict_after_rmod_lock}    lane_distname=${lane_distname}
    END
    Initiate UE Register And Traffic    expected_occurances=2
    Sleep    30s
    Run keyword And Continue On Failure
    ...    wait until keyword succeeds    2min    30s
    ...    Validate throughput from bearer stats for all UEs in DL only    ue_list=${NSA_UE_List_afterOAM}    expected_dl_tput=${OVERALL_DL}
    ...    mode=NSA    pdu_id=${pdu_id}
    Run Keyword And Continue On Failure    Stop Traffic and Detach NSA UEs    nsa_ue_list=${NSA_UE_List_afterOAM}    bearer_id=${bearer_id}
    [Teardown]    Simple Test Teardown    ${NSA_UE_List_afterOAM}

TC4_Verify_reset_operations with DCM IOT Profile_3
    [Tags]    AP_REG    TDD_FR2_reset
    [Setup]    Test Setup for DCM    TC_dictionary=&{TC1}
    ...        feature=TDD_FR2_reset        custom_config=True
    ...    custom_config_folder=${TDD_NSA_DL_FR2_peak_TP_cfg}
    Initiate UE Register And Traffic
    Sleep    30s
    Run keyword And Continue On Failure
    ...    wait until keyword succeeds    2min    30s
    ...    Validate throughput from bearer stats for all UEs in DL only    ue_list=${NSA_UE_List}    expected_dl_tput=${OVERALL_DL}
    ...    mode=NSA    pdu_id=${pdu_id}
    Run Keyword And Continue On Failure    Stop Traffic and Detach NSA UEs    nsa_ue_list=${NSA_UE_List}    bearer_id=${bearer_id}
    ${fault_dict_before_oam}=    Run Keyword And Continue On Failure    Get Alarms
    Set Test Variable    ${fault_dict_before_oam}
    FOR    ${index}    IN RANGE    ${reset_repetitions}
        ${fault_dict_after_ru_reset}=    Perform RU Reset With Validation
        ...    previous_fault_dict=${fault_dict_before_oam}    iteration_index=${index}
        ${fault_dict_after_bbmod_reset}=    Perform BBMOD Reset With Validation
        ...    previous_fault_dict=${fault_dict_after_ru_reset}    iteration_index=${index}
        ${fault_dict_after_site_reset}=    Perform Site Reset With Validation
        ...    previous_fault_dict=${fault_dict_after_bbmod_reset}    iteration_index=${index}
    END
    Initiate UE Register And Traffic     expected_occurances=2
    Sleep    30s
    Run keyword And Continue On Failure
    ...    wait until keyword succeeds    2min    30s
    ...    Validate throughput from bearer stats for all UEs in DL only    ue_list=${NSA_UE_List_afterOAM}    expected_dl_tput=${OVERALL_DL}
    ...    mode=NSA    pdu_id=${pdu_id}
    Run Keyword And Continue On Failure    Stop Traffic and Detach NSA UEs    nsa_ue_list=${NSA_UE_List_afterOAM}    bearer_id=${bearer_id}
    [Teardown]    Simple Test Teardown    ${NSA_UE_List_afterOAM}
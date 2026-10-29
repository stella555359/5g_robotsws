*** Settings ***
Documentation    CB006991 RIMRS
Resource     CB006991_variables.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/CA/Resources/case_keywords.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/common_resources.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/container_log_capturing.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/logs.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/nr_rim.robot
Library      ${CURDIR}/../TestData/6991_rim_rs.py

*** Keywords ***
6991 Suite common setup preparation
   [Documentation]    6991 Suite common setup preparation
    Connect to gnb coam via ssl
    ${cur_program}    gnb_classical_hangzhou.Get program version based on stream version
    set suite variable    ${PROGRAM}    ${cur_program}
    import variables    ${commissionings_path}/HGZ/${testline_name}/__init_6991__.py
    import variables    ${CURDIR}/../TestData/NIDD_modify_scf_6991_base.py
    import variables    ${CURDIR}/../TestData/NIDD_modify_scf_6991_rest_api.py
    set suite variable    @{RESTAPI_MODIFY_UL_MITIGATION_ONLY}
    set suite variable    @{RESTAPI_MODIFY_NO_MITIGATION}
    set suite variable    ${RI_TIMEOUT}
    ${CELL_MAPPING}    coam_gnb_classical.get_relation_mapping_between_cell_index_and_other_ids    connection_alias=${OAM_ALIAS_GNB0}
    Set suite variable    ${CELL_MAPPING}
    Rim suite common setup preparation   prepare_ue=${True}
   [Teardown]    run keyword and ignore error    COAM Teardown gnb connections

Set variables for 6991
   [Documentation]    Set variables for 6991
   ...    Author: Cheng Catherine
   [Arguments]     ${frame_bw}
    import variables    ${CURDIR}/../TestData/NIDD_modify_scf_6991_${frame_bw}.py
    set suite variable    ${PARAMS_TO_MODIFY_DIC}
    set suite variable    ${PARAMS_TO_ADD_DIC}
    set suite variable    ${PARAMS_TO_DELETE_DIC}


6991 case setup
    [Documentation]    6991 case setup
    ...    Author: Cheng Catherine
    [Arguments]    ${frame_bw}=${None}    ${NSA_SA}=${NSA_SA}    ${connection_Aggressor}=${OAM_ALIAS_GNB1}
    ...    ${gnb_index_Aggressor}=1    ${gnb_num}=${2}
    Set variables for 6991     ${frame_bw}
    ${scf_name_suffix}
    ...    set variable if   '${PROGRAM}'>='24R3' and '${frame_bw}'=='90M_1116_3ms_4GP' and '${testline_name}'=='7_5_UTE5G402T052'   _TMO   ${None}

    Case common setup multiGNB    NSA_SA=${NSA_SA}    gnb_num=${gnb_num}    scf_name_suffix=${scf_name_suffix}
    ...    allowed_faults_ids=${RIM_ALLOWED_FAULTS_IDS}

    log to console    start to lock aggressor cell in case setup
    Lock cells

    run keyword and ignore error    Download SCF file to log path    connection=${connection_Aggressor}
                                                            ...    gnb_index=${gnb_index_Aggressor}
                                                            ...    extended_name=Aggressor


Steps Change Rim Mitigation Scheme to UL Mitigation Only and Check no DL Mitigation When RI
    [Documentation]    Author: Cheng Catherine
    ...    Description:  Steps Change Rim Mitigation Scheme to UL Mitigation Only and Check no DL Mitigation When RI
    ...    1. change Rim Mitigation Scheme to UL Mitigation Only
    ...    2. Check no DL Mitigation from Fault When RI Happen
    [Arguments]   ${SetId_Aggressor}    ${dlMuteSlotsStr}    ${setId_show_in_fault}=${False}
    ${supplementary}    Get Supplementary for Fault 7527    SetId_Aggressor=${SetId_Aggressor}    setId_show_in_fault=${setId_show_in_fault}
    ${supplementary_7535}    Get Supplementary for Fault 7535    ${dlMuteSlotsStr}
    ${supplementary_not_contain}    Set Variable    DL muting in ${dlMuteSlotsStr}
    coam_gnb_classical.COAM Update several parameters via rest api
    ...    parameters_to_update_via_api=${RESTAPI_MODIFY_UL_MITIGATION_ONLY}
    ...    skip_parameter_relation_errors=${False}
    run keyword and continue on failure    Check no DL Mitigation from Fault When RI Happen
                                                    ...    supplementary=${supplementary}
                                                    ...    supplementary_not_contain=${supplementary_not_contain}
                                                    ...    supplementary_7535=${supplementary_7535}


Steps Change Rim Mitigation Scheme to no Mitigation and Check no DL Mitigation When RI
    [Documentation]    Author: Cheng Catherine
    ...    Description:  Steps Change Rim Mitigation Scheme to no Mitigation and Check no DL Mitigation When RI
    ...    1. change Rim Mitigation Scheme to no Mitigation
    ...    2. Check no DL Mitigation from Fault When RI Happen
    [Arguments]   ${SetId_Aggressor}    ${dlMuteSlotsStr}    ${setId_show_in_fault}=${False}
    ${supplementary}    Get Supplementary for Fault 7527    SetId_Aggressor=${SetId_Aggressor}    setId_show_in_fault=${setId_show_in_fault}
    ${supplementary_7535}    Get Supplementary for Fault 7535    ${dlMuteSlotsStr}
    ${supplementary_not_contain}    Set Variable    DL muting in ${dlMuteSlotsStr}
    coam_gnb_classical.COAM Update several parameters via rest api
    ...    parameters_to_update_via_api=${RESTAPI_MODIFY_NO_MITIGATION}
    ...    skip_parameter_relation_errors=${False}
    run keyword and continue on failure    Check no DL Mitigation from Fault When RI Happen
                                                    ...    supplementary=${supplementary}
                                                    ...    supplementary_not_contain=${supplementary_not_contain}
                                                    ...    supplementary_7535=${supplementary_7535}

6991 case teardown
    [Documentation]    6991 case teardown
    ...    Author: Cheng Catherine
    [Arguments]    ${gnb0_snapshot}=${True}    ${gnb1_snapshot}=${True}    ${detach_ue}=${True}
    ...    ${gnb_index}=1    ${connection_GNB1}=${OAM_ALIAS_GNB1}    ${unlock_cell}=${False}    ${targetTotalLoad}=${False}
    log to console    start to unlock aggressor(GNB1) cell in case teardown
    run keyword if   ${unlock_cell}   Unlock cells    lock_cell_list=@{CELL_LIST_GNB1}   lock_cell_connection=${connection_GNB1}
    run keyword if   ${targetTotalLoad}   Set aggressor targetTotalLoad via restAPI   paras=${RESTAPI_MODIFY_NO_TARGET_TOTAL_LOAD}
    run keyword and ignore error    Download SCF file to log path    connection=${connection_GNB1}
                                                            ...    gnb_index=${gnb_index}
                                                            ...    extended_name=case_teardown_GNB1
    Common case teardown multiGNB    gnb0_snapshot=${gnb0_snapshot}    gnb1_snapshot=${gnb1_snapshot}
    ...    detach_ue=${detach_ue}    is_btslog_required=${False}

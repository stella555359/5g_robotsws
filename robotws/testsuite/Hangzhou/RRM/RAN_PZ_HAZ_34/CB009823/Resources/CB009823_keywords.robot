*** Settings ***
Documentation    CB009823 RIMRS
Resource     CB009823_variables.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/CA/Resources/case_keywords.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/common_resources.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/container_log_capturing.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/logs.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/nr_rim.robot
Library     ${CURDIR}/../TestData/6991_rim_rs.py

*** Keywords ***
Set variables for 9823
   [Documentation]    Set variables for 9823
   ...    Author: Cheng Catherine
    Connect to gnb coam via ssl   connection=${OAM_ALIAS_GNB0}    gnb_index=${0}
    Connect to gnb coam via ssl   connection=${OAM_ALIAS_GNB1}    gnb_index=${1}
    ${cur_program}    gnb_classical_hangzhou.Get program version based on stream version
    set suite variable    ${PROGRAM}    ${cur_program}
    ${CELL_MAPPING}    coam_gnb_classical.get_relation_mapping_between_cell_index_and_other_ids    connection_alias=${OAM_ALIAS_GNB0}
    Set suite variable    ${CELL_MAPPING}
    import variables    ${commissionings_path}/HGZ/${testline_name}/__init_9823__.py
    import variables    ${CURDIR}/../TestData/NIDD_modify_scf_common.py
    import variables    ${CURDIR}/../TestData/NIDD_Modify_data_template.py
    import variables    ${CURDIR}/../TestData/NIDD_modify_scf_restapi.py
    set suite variable    ${RI_TIMEOUT}
    [Teardown]  Run keywords    COAM Teardown gnb connections    connection=${OAM_ALIAS_GNB0}   AND
    ...    COAM Teardown gnb connections    connection=${OAM_ALIAS_GNB1}

9823 Suite preparation multiGNB
    [Documentation]    9823 Suite preparation
    ...    Author: Wang Yixiang
    Set variables for 9823
    Rim suite common setup preparation   prepare_ue=${True}

9823 case setup
    [Documentation]    9823 case setup
    ...    Author: Wang Yixiang
    [Arguments]    ${frame_bw}=${None}    ${NSA_SA}=${NSA_SA}    ${connection_GNB1}=${OAM_ALIAS_GNB1}
    ...    ${lock_cell}=${False}    ${targetTotalLoad}=${False}
    ...    ${gnb_num}=${2}
    run keyword if    '${frame_bw}' !='${None}'    import variables    ${CURDIR}/../TestData/NIDD_modify_scf_${frame_bw}.py
    ${scf_name_suffix}
    ...    set variable if   '${PROGRAM}'>='24R3' and '${frame_bw}'=='90M_1116_3ms_4GP' and '${testline_name}'=='7_5_UTE5G402T052'   _TMO   ${None}

    Case common setup multiGNB    NSA_SA=${NSA_SA}    gnb_num=${gnb_num}    scf_name_suffix=${scf_name_suffix}
    ...    allowed_faults_ids=${RIM_ALLOWED_FAULTS_IDS}

    log to console    start to lock aggressor cell in case setup
    run keyword if   ${lock_cell}   Lock cells    lock_cell_list=@{CELL_LIST_GNB1}    lock_cell_connection=${connection_GNB1}
    run keyword if   ${targetTotalLoad}   Set aggressor targetTotalLoad via restAPI   paras=${RESTAPI_MODIFY_NO_TARGET_TOTAL_LOAD}

    run keyword and ignore error    Download SCF file to log path    connection=${connection_GNB1}
                                                            ...    gnb_index=${1}
                                                            ...    extended_name=case_setup_GNB1
    ${CONFIGS_GNB0}     Get Muti NIDD value via rest api    parameter=${GET_VALUE_FROM_GNB}
    ${CONFIGS_GNB1}     Get Muti NIDD value via rest api    parameter=${GET_VALUE_FROM_GNB1}   connection=${connection_GNB1}
    Set test variable    ${CONFIGS_GNB0}
    Set test variable    ${CONFIGS_GNB1}

9823 case teardown
    [Documentation]    9823 case teardown
    ...    Author: Wang Yixiang
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


Set victim rsDistanceThreshold via restAPI
    [Documentation]    Set rsDistanceThreshold via restAPI
    ...    Author: Cheng Catherine
    [Arguments]    ${paras}
    coam_gnb_classical.COAM Update several parameters via rest api
    ...    parameters_to_update_via_api=${paras}
    ...    skip_parameter_relation_errors=${False}
    ...    connection=${OAM_ALIAS_GNB0}

Set rsDetectionWindow via restAPI
    [Documentation]    Set rsDetectionWindow via restAPI
    ...    Author: Wang Yixiang
    [Arguments]    ${paras}
    coam_gnb_classical.COAM Update several parameters via rest api
    ...    parameters_to_update_via_api=${paras}
    ...    skip_parameter_relation_errors=${False}
    ...    connection=${OAM_ALIAS_GNB0}

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

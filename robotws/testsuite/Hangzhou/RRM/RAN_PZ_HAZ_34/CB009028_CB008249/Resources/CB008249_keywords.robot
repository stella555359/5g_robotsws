*** Settings ***
Documentation    this is CB008249 common kwywords
Resource     CB008249_variables.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/common_resources.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/nr_rim.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/CA/Resources/case_keywords.robot


*** Keywords ***
Set variables for 8249
   [Documentation]    Author: Jin Journey
   Connect to gnb coam via ssl
   ${DICT_Cell_IDS_TECH}    get_cell_ids_based_on_cell_technology
   set suite variable    ${DICT_Cell_IDS_TECH}
   set suite variable    ${TARGET_AVG_PERCENT}    0.9
   set suite variable    ${MIN_PERCENT}    0.8
   [Teardown]    run keyword and ignore error    COAM Teardown gnb connections

8249 Suite preparation
    [Documentation]    Author: Jin Journey
    [Arguments]    ${NSA_SA}=${NSA_SA}
    ...     ${swconfig_modify}=${None}
    Set variables for 8249
    Run keyword if    '${tl.attenuators}'!='[None]'
    ...    Initialize attenuator values for testline    pa_values_mapping=${INIT_PA_F_T}
    ...    NSA_SA=${NSA_SA}
    import variables    ${CURDIR}/../TestData/NIDD_modify_scf.py

    log to console    Start to commission aggressor gNB...
    ${scf_template_path}    Get scf template file with release considered    scf_template_file_path=${AGGRESSOR_GNB_SCF_DEFAULT_FILE_PATH}
    Preparation with swconfig modification and comissioning
    ...    swconfig_modify=${None}    swconfig_template_path=${AGGRESSOR_GNB_SWCONFIG_DEFAULT_FILE_PATH}
    ...    scf_modify=${MODIFY_SCF_DEFAULT_GNB1}    scf_template_path=${scf_template_path}
    ...    gnb_index=${1}    connection=${AGGRESSOR_GNB_OAM_ALIAS}    alias=${AGGRESSOR_GNB_ASIK_ALIAS}

    set suite variable    ${PARAMS_TO_MODIFY}    ${MODIFY_SCF_DEFAULT}
    log to console    Start to commission victim gNB...
    Suite common setup preparation    prepare_ue=${True}    NSA_SA=${NSA_SA}
    ...   swconfig_modify=${swconfig_modify}    is_pdl_checking_needed=${True}
    &{NR_CELL_ID_MAPPING}    coam_gnb_classical.get_relation_mapping_between_cell_index_and_other_ids
    Set suite variable    ${NR_CELL_ID_MAPPING}

8249 case setup
    [Documentation]    Author: Jin Journey
    [Arguments]    ${NSA_SA}=${NSA_SA}    ${connection}=${AGGRESSOR_GNB_OAM_ALIAS}    ${gnb_index}=1    ${cell_id}=${1}
    Common case setup    NSA_SA=${NSA_SA}    allowed_faults_ids=7525
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    Perform cell lock via rest api    cell_idx=${cell_id}    gnb_id=${gnb_index}    connection=${connection}
    Wait Until Keyword Succeeds    90 sec    3 sec    Cell Should Be Locked    cell_idx=${cell_id}    connection=${connection}

Add interference from aggressor gnb and check RI is detected
    [Documentation]    Author: Jin Journey
    ...    Description:check RI is detected by aasyslog and WEBEM with fault 7525
    [Arguments]    ${faultId}=7525    ${timeout}=900    ${connection}=${AGGRESSOR_GNB_OAM_ALIAS}    ${cell_idx}=${1}    ${gnb_id}=1
    Teardown the Aasyslog save progress
    Aasyslog precondition
    ${aasyslog_gnb_log_path}    Start the Aasyslog save progress    filter=rim    log_name=RI_status.txt    is_ssh_con_released=${False}
    Perform cell unlock via rest api    cell_idx=${cell_idx}    gnb_id=${gnb_id}    connection=${connection}
    Wait Until Keyword Succeeds    5 min    3 sec     Cell Should Be Unlocked    cell_idx=${cell_idx}    connection=${connection}
    coam_gnb_classical.COAM Update several parameters via rest api
    ...    parameters_to_update_via_api=${RESTAPI_MODIFY_TARGET_TOTAL_LOAD}
    ...    skip_parameter_relation_errors=${False}
    ...    connection=${connection}
    run keyword and continue on failure    Wait For Expect Fault Present    faultId=${faultId}   timeout=${timeout}
    ${ute_log_path}    run keyword and continue on failure    Teardown aasyslog with log downloaded to ute    gnb_log_path=${aasyslog_gnb_log_path}
    ...    ute_log_folder=${TS_CASE_LOG_PATH}
    run keyword and ignore error    Check RI state from aasyslog    log_path=${ute_log_path}
    [Teardown]    run keyword and ignore error    Teardown the Aasyslog save progress

Verify RI is disappear after stop interference
    [Documentation]    Author: Jin Journey
    [Arguments]    ${faultId}=7525    ${timeout}=300    ${connection}=${AGGRESSOR_GNB_OAM_ALIAS}    ${cell_idx}=${1}    ${gnb_id}=1
    Perform cell lock via rest api    cell_idx=${cell_idx}    gnb_id=${gnb_id}    connection=${connection}
    Wait Until Keyword Succeeds    90 sec    3 sec     Cell Should Be Locked    cell_idx=${cell_idx}    connection=${connection}
    Sleep    300 sec
    Wait For Expect Fault To Disappear    faultId=${faultId}   timeout=${timeout}
    AlarmWatchdog.remove_allow_alarms    fault_id=7525
    [Teardown]    run keyword and ignore error    Run keywords    Perform cell unlock via rest api
    ...    cell_idx=${cell_idx}    gnb_id=${gnb_id}    connection=${connection}    AND
    ...    Wait Until Keyword Succeeds    5 min    3 sec     Cell Should Be Unlocked    cell_idx=${cell_idx}    connection=${connection}

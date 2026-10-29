*** Settings ***
Documentation       Test case for xxx
...                 Author: xxx
...                 Contact: xxx.xx@nokia.com
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
${SRNCLAB}      SRNCLAB1019    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}
${PLAN_FILE_IMPORT_NAME1}    cm_plan_generated_for_nom_cell_lock_unlock_023.xml
${PLAN_FILE_IMPORT_NAME2}    cm_plan_generated_for_nom_rmod_reset_023.xml
${PLAN_FILE_IMPORT_CLEAN_SBTS}    cm_plan_remove_cmd_023.xml
${NE_CMLOCKING_PARAM_NAME}    administrativeState
${NE_CMRESETTING_PARAM_NAME}    cellResetRequest
${NE_CMLOCKING_LOCK_VALUE_NR}    Locked
${NE_CMLOCKING_UNLOCK_VALUE_NR}     Unlocked
${NE_CMLOCKING_LOCK_VALUE_LTE}     locked
${NE_CMLOCKING_UNLOCK_VALUE_LTE}    unlocked
${NE_CMLOCKING_LOCK_VALUE_RMOD}    Locked
${NE_CMLOCKING_UNLOCK_VALUE_RMOD}    Unlocked
${NE_CMRESETTING_ONGOING_VALUE}    disabled
${NE_CMRESETTING_FINISH_VALUE}    enabled
${PLAN_FILE_EXPROT_ACTUAL}    open_api_actuals_exported_023.xml
${TEST_DATA_PATH}     /home/ute/btsauto/hran_ta/config/${HW_LOCATION_CODE}/${TESTLINE_NAME}/testdata/TestDataNOM
${NEED_SCF_RECOVERY_FLAG}    False

*** Keywords ***
SyVe_CM_CB006292_023_SBTS_State_Management_From_NOM
    [Documentation]    [CASE LINK]: https://jira3.ext.net.nokia.com/browse/TAT-22269
    ...
    ...    *****************
    ...    Basic information
    ...    *****************
    ...    Test for performing provision cm plan to do CELL/RMOD state management from NOM
    ...
    ...    The main steps performed for the test are:
    ...     - Check initial BTS state
    ...     - CM Upload From NOM Open API
    ...     - Random Select And Lock One Cell From LTE
    ...     - Unlock Selected Cell From LTE
    ...     - Reset LTE Cell From NOM
    ...     - Random Select And Lock One Cell From NR
    ...     - Unlock Selected Cell From NR
    ...     - Random Select And Lock One RMOD
    ...     - Unlock Selected RMOD
    ...     - Reset RMOD From NOM
    ...     - Check final BTS state
    ...    Pass criteria: CELL/RMOD state management success from NOM by plan activation.
    ...
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 01.09.2022 - New Syve case to replace original NOM CB006292_023 case
    ...
    ...    *******************
    ...    Test case flowchart
    ...    *******************

    Set Tags    AUTHOR-lixin.kang@nokia-sbell.com    Maintainer–I_NSB_MN_RAN_PZ_1_HAZ_11@internal.nsn.com
    Step 1: Check initial BTS state
    Step 2: CM Upload From NOM Open API
    Step 3: Random Select And Lock One Cell From LTE
    Step 4: Unlock Selected Cell From LTE
    Step 5: Reset LTE Cell From NOM
    Step 6: Random Select And Lock One Cell From NR
    Step 7: Unlock Selected Cell From NR
    Step 8: Random Select And Lock One RMOD
    Step 9: Unlock Selected RMOD
    Step 10: Reset RMOD From NOM
    Step 11: Check final BTS state

Step ${index}: Random Select And Lock One Cell From ${rat_type}
    Log To Console      Step ${index}: Random Select And Lock One Cell From ${rat_type}
    ${all_cell_path}    Get ${rat_type} Config Id By cells
    ${selected_cell}    Evaluate    random.choice(${all_cell_path})    modules=random, sys
    Set Test Variable    ${selected_cell}
    Set Test Variable    ${selected_mo}    ${selected_cell}
    Set Test Variable    ${param_name}    ${NE_CMLOCKING_PARAM_NAME}
    Set Test Variable    ${status_value}    ${NE_CMLOCKING_LOCK_VALUE_${rat_type}}
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_xml}    L_XML.Parse xml    ${BTS_scf_initial}
    ${MO_items}    L_XML.Get Element Attributes    ${scf_xml}    .//managedObject[@distName="${selected_cell}"]
    Set Test Variable    ${meta_class}    ${MO_items['class']}
    Set Test Variable    ${meta_version}    ${MO_items['version']}
    Generate CM Plan With Timestamp from XML Template For NOM Open API    ${TEST_DATA_PATH}/${PLAN_FILE_IMPORT_NAME1}
    CM Plan Import NOM Open API    ${PLAN_FILE_IMPORT_PATH}    ${PLAN_FILE_GENERATED_NOM_OPEN_API_WITH_TIME}
    CM Plan Provision NOM Open API    ${PLAN_FILE_GENERATED_NOM_OPEN_API_WITH_TIME}
    Set Test Variable   ${NEED_SCF_RECOVERY_FLAG}    True
    Wait Until Keyword Succeeds    3x    10s    Check CM Parameter Value From NOM Actual Plan    ${NE_INTEGRATED_ID}
    ...    ${selected_cell}    ${NE_CMLOCKING_PARAM_NAME}=${status_value}

Step ${index}: Unlock Selected Cell From ${rat_type}
    Log To Console      Step ${index}: Unlock Selected Cell From ${rat_type}
    Set Test Variable    ${status_value}    ${NE_CMLOCKING_UNLOCK_VALUE_${rat_type}}
    Generate CM Plan With Timestamp from XML Template For NOM Open API    ${TEST_DATA_PATH}/${PLAN_FILE_IMPORT_NAME1}
    CM Plan Import NOM Open API    ${PLAN_FILE_IMPORT_PATH}    ${PLAN_FILE_GENERATED_NOM_OPEN_API_WITH_TIME}
    CM Plan Provision NOM Open API    ${PLAN_FILE_GENERATED_NOM_OPEN_API_WITH_TIME}
    Wait Until Keyword Succeeds    3x    10s    Check CM Parameter Value From NOM Actual Plan    ${NE_INTEGRATED_ID}
    ...    ${selected_cell}    ${NE_CMLOCKING_PARAM_NAME}=${status_value}
    Set Test Variable   ${NEED_SCF_RECOVERY_FLAG}    False

Step ${index}: Reset LTE Cell From NOM
    Log To Console      Step ${index}: Reset LTE Cell From NOM
    Set Test Variable    ${param_name}    ${NE_CMRESETTING_PARAM_NAME}
    ${yyyy}    ${mm}    ${dd}    ${hh}    ${min}    ${ss}    Get Time
    ...    format=year month day hour min sec    time_=NOW+3s
    Set Test Variable    ${status_value}    ${yyyy}${mm}${dd} ${hh}${min}${ss}
    Generate CM Plan With Timestamp from XML Template For NOM Open API    ${TEST_DATA_PATH}/${PLAN_FILE_IMPORT_NAME1}
    CM Plan Import NOM Open API    ${PLAN_FILE_IMPORT_PATH}    ${PLAN_FILE_GENERATED_NOM_OPEN_API_WITH_TIME}
    CM Plan Provision NOM Open API    ${PLAN_FILE_GENERATED_NOM_OPEN_API_WITH_TIME}
    Log To Console    "CM Reseting Finish For: ${selected_cell}"
    Wait Until Keyword Succeeds    3 min    10 sec    Check CM Parameter Value From NOM Actual Plan    ${NE_INTEGRATED_ID}
    ...    ${selected_cell}    operationalState=${NE_CMRESETTING_FINISH_VALUE}
    Wait Until Keyword Succeeds    3 min   10 sec    Check SBTS OnAir

Step ${index}: Random Select And Lock One RMOD
    Log To Console      Step ${index}: Random Select And Lock One RMOD
    ${all_rmod_path}    Get rmod Config Id By radioModules
    ${selected_rmod}    Evaluate    random.choice(${all_rmod_path})    modules=random, sys
    Set Test Variable    ${selected_rmod}
    Set Test Variable    ${selected_mo}    ${selected_rmod}
    Set Test Variable    ${status_value}    ${NE_CMLOCKING_LOCK_VALUE_RMOD}
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_xml}    L_XML.Parse xml    ${BTS_scf_initial}
    ${MO_items}    L_XML.Get Element Attributes    ${scf_xml}    .//managedObject[@distName="${selected_rmod}"]
    Set Test Variable    ${meta_class}    ${MO_items['class']}
    Set Test Variable    ${meta_version}    ${MO_items['version']}
    Generate CM Plan With Timestamp from XML Template For NOM Open API    ${TEST_DATA_PATH}/${PLAN_FILE_IMPORT_NAME1}
    CM Plan Import NOM Open API    ${PLAN_FILE_IMPORT_PATH}    ${PLAN_FILE_GENERATED_NOM_OPEN_API_WITH_TIME}
    CM Plan Provision NOM Open API    ${PLAN_FILE_GENERATED_NOM_OPEN_API_WITH_TIME}
    Set Test Variable   ${NEED_SCF_RECOVERY_FLAG}    True
    Wait Until Keyword Succeeds    3x    10s    Check CM Parameter Value From NOM Actual Plan    ${NE_INTEGRATED_ID}
    ...    ${selected_rmod}    ${NE_CMLOCKING_PARAM_NAME}=${NE_CMLOCKING_LOCK_VALUE_RMOD}

Step ${index}: Unlock Selected RMOD
    Log To Console      Step ${index}: Unlock Selected RMOD
    Set Test Variable    ${status_value}    ${NE_CMLOCKING_UNLOCK_VALUE_RMOD}
    Generate CM Plan With Timestamp from XML Template For NOM Open API    ${TEST_DATA_PATH}/${PLAN_FILE_IMPORT_NAME1}
    CM Plan Import NOM Open API    ${PLAN_FILE_IMPORT_PATH}    ${PLAN_FILE_GENERATED_NOM_OPEN_API_WITH_TIME}
    CM Plan Provision NOM Open API    ${PLAN_FILE_GENERATED_NOM_OPEN_API_WITH_TIME}
    Wait Until Keyword Succeeds    3x    10s    Check CM Parameter Value From NOM Actual Plan    ${NE_INTEGRATED_ID}
    ...    ${selected_rmod}    ${NE_CMLOCKING_PARAM_NAME}=${NE_CMLOCKING_UNLOCK_VALUE_RMOD}
    Wait Until Keyword Succeeds    3 min    10 sec   Check SBTS OnAir
    Set Test Variable   ${NEED_SCF_RECOVERY_FLAG}    False

Step ${index}: Reset RMOD From NOM
    Log To Console      Step ${index}: Reset RMOD From NOM
    ${selected_rmod_mapping}    Fetch ID Mapping From Admin For Module    ${selected_rmod}
    ${selected_rmod_runtime_id}    Get From Dictionary    ${selected_rmod_mapping}    runtime
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_xml}    L_XML.Parse xml    ${BTS_scf_initial}
    ${MO_items}    L_XML.Get Element Attributes    ${scf_xml}    .//managedObject[@distName="${CM_NE_ID}/MNL-1"]
    Set Test Variable    ${meta_class}    ${MO_items['class']}
    Set Test Variable    ${meta_version}    ${MO_items['version']}
    Generate CM Plan With Timestamp from XML Template For NOM Open API    ${TEST_DATA_PATH}/${PLAN_FILE_IMPORT_NAME2}
    CM Plan Import NOM Open API    ${PLAN_FILE_IMPORT_PATH}    ${PLAN_FILE_GENERATED_NOM_OPEN_API_WITH_TIME}
    CM Plan Provision NOM Open API    ${PLAN_FILE_GENERATED_NOM_OPEN_API_WITH_TIME}
    Wait Until Keyword Succeeds    5 min    10 sec    Check CM Parameter Value From NOM Actual Plan    ${NE_INTEGRATED_ID}
    ...    ${selected_rmod_runtime_id}    operationalState=${NE_CMRESETTING_ONGOING_VALUE}
    Log To Console    "CM Reseting Finish For: ${selected_rmod}"
    Wait Until Keyword Succeeds    3 min    10 sec    Check CM Parameter Value From NOM Actual Plan    ${NE_INTEGRATED_ID}
    ...    ${selected_rmod_runtime_id}    operationalState=${NE_CMRESETTING_FINISH_VALUE}
    Wait Until Keyword Succeeds    3 min    10 sec    Check SBTS OnAir


Step ${index}: Check ${when} BTS state
    [Documentation]    BTS each RAT procedural state is checked to be OnAir (at least one cell operational)
    ...    BTS State is checked according to ute_admin get parameters for all BTS. The JSON returned contains informations
    ...    such as btsName, btsId, btsProceduralstate
    ...    KW checks if BTS State is onAir. If not, it will fail with received state.
    Log    Step ${index}: Check ${when} BTS state    console=True
    Wait Until Keyword Succeeds    3 min    10 sec    Check BTS RAT Procedural State
    Admin Check Overall BTS Procedural State TAF

Step ${index}: CM Upload From NOM Open API
    Log To Console      Step ${index}: CM Upload From NOM Open API
    CM Parameter Upload NOM Open API    ${NE_INTEGRATED_ID}

Step ${index}: Provision Plan From NOM Open API
    Log To Console      Step ${index}: Provision Plan From NOM Open API
    CM Plan Provision NOM Open API    ${PLAN_FILE_GENERATED_NOM_OPEN_API_WITH_TIME}    True
    Log To Console    "Provision finished"

Check SBTS OnAir
    ${gsm_state}    Run Keyword If    ${GSM_cell_ids}    Check GSM RAT status
    ${wcdma_state}    Run Keyword If    ${WCDMA_cell_ids}    Check WCDMA RAT status
    ${lte_state}    Run Keyword If    ${LTE_cell_ids}    Check LTE RAT status
    ${nr_state}    Run Keyword If    ${NRBTS_cell_ids}    Check NR RAT status
    Run Keyword If    ${GSM_cell_ids}    Should Be Equal As Strings    ${gsm_state}    ALL_ENABLED
    Run Keyword If    ${WCDMA_cell_ids}    Should Be Equal As Strings    ${wcdma_state}    ALL_ENABLED
    Run Keyword If    ${LTE_cell_ids}    Should Be Equal As Strings    ${lte_state}    ALL_ENABLED
    Run Keyword If    ${NRBTS_cell_ids}    Should Be Equal As Strings    ${nr_state}    ALL_ENABLED

Check ${rat_techo} RAT status
    ${rat}    String.Convert To Lower Case    ${rat_techo}
    ${btsinfo_list}    coam.Get Bts Info
    ${rat_status}    set variable    ${btsinfo_list['ratState']['${rat}']}
    [Return]    ${rat_status}

Get ${type} Config Id By ${module}
    ${module_conf_list}    Create List
    ${module_id_mapping}    Create List
    ${bts_all_info}    coam.Get Bts Info
    ${module_info}    Get From Dictionary    ${bts_all_info}    ${module}
    ${rat_type}    Convert To Lowercase    ${type}
    ${module_info_list}    Get From Dictionary    ${module_info}    ${rat_type}
    FOR    ${item}    IN    @{module_info_list}
        ${ids}    Get From Dictionary    ${item}    id
        Append To List    ${module_id_mapping}    ${ids}
    END
    FOR    ${id}    IN    @{module_id_mapping}
        ${conf}=    Get From Dictionary    ${id}    configuration
        Append To List    ${module_conf_list}    ${conf}
    END
    [Return]     ${module_conf_list}

Clean Reset Request MO
    Generate CM Plan With Timestamp from XML Template For NOM Open API    ${TEST_DATA_PATH}/${PLAN_FILE_IMPORT_CLEAN_SBTS}
    CM Plan Import NOM Open API    ${PLAN_FILE_IMPORT_PATH}    ${PLAN_FILE_GENERATED_NOM_OPEN_API_WITH_TIME}
    CM Plan Provision NOM Open API    ${PLAN_FILE_GENERATED_NOM_OPEN_API_WITH_TIME}

TC Setup
    [Arguments]     ${reIntegrateNeFlag}=${FALSE}
    NOM Common Test Setup    ReIntegrateNE=${reIntegrateNeFlag}

TC Teardown
    &{param_EMPTY}    Create Dictionary
    ${existed_CMD}    Run Keyword And Return Status     Check CM Parameter Value From NOM Actual Plan
    ...    ${NE_INTEGRATED_ID}    ${CM_NE_ID}/MNL-1/CMD-1    &{param_EMPTY}
    ${status}    Run Keyword If    ${existed_CMD}    Run Keyword And Return Status    Clean Reset Request MO
    Run Keyword If    ${NEED_SCF_RECOVERY_FLAG} or '${status}'=='FAIL'   Run Keywords    Log
    ...    Parameters were not reset to initial values! Probably backup plan was not provisioned! Will perform commissioning with initial scf!
    ...    level=WARN
    ...    AND    coam.Perform Commissioning    bts_id=${mrbts_id}    scf_file=${BTS_scf_initial}
    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=400
    ...    AND    Wait Until Keyword Succeeds    20 min    30 sec    Check SBTS SMOD RMOD Cells Alarms
    NOM Common Test Teardown
*** Settings ***
Documentation    Suite description
...    Author:    Lisa Ding
...    Maintainer:    Lisa Ding

Library            OperatingSystem
Library            Collections
Library            taf/rfrl/csv4all/CSV4AllTestCases.py
Library            taf.sbts.oam.coam.admin    WITH NAME    coam_csv4all


*** Variables ***
&{5G_BTS11193}=        HW_ID=CB007605        site_mode=SA+NSA        ONAIR_TIME=30 min
...      peak_rate_config={"45":[1,1],"46":[1,1],"47":[1,1]}

${UPGRADE_TEST_ITERATION}            2
${SITE_RESET_TEST_ITERATION}         20
${RU_RESET_TEST_ITERATION}           20
${BBMOD_TEST_ITERATION}              20
${CELL_LOCK_TEST_ITERATION}          3
${COMMISSIONING_TEST_ITERATION}      1
${ITERATIONS}                        2

${REPORT}                     ${False}
${REPORT_COMMENT}=            ${None}
@{CUSTOMERS_LIST}             Optus
${QC_DOMAIN}=                 MN_RAN
${QC_PROJECT}=                RAN_VRF
${RP_CA}                      VRF_SiSo
${RP_LOCATION}                VRF_HAZ1
${RP_ORGANIZATION}            VRF_HAZ1_T05
${INITIAL_SW}                 SBTS00_ENB_9999_250416_000001
${TARGET_SW}                  SBTS00_ENB_9999_250506_000009

@{CUSTOM_ALLOWED_ALARMS}         4654    4655    61524    61652    61649    61030    61074
@{TEMPORARY_ALLOWED_FAULTS}      4589


&{NODE1}           testline_object=${tl.gnbs[0]}
...                source_sw=${INITIAL_SW}
...                target_sw=${TARGET_SW}
...                temporary_allowed_alarms=${TEMPORARY_ALLOWED_FAULTS}
...                custom_allowed_alarms=${CUSTOM_ALLOWED_ALARMS}
#...                hw_to_onair_timeout=${HW_TO_ONAIR_TIME}



@{NODES}           ${NODE1}

#${ONLINE_PARAMETER_DELTA}       ${CURDIR}${/}/online_parameter.json
#${SITE_RESET_DELTA}             ${CURDIR}${/}site_reset_parameter.json
#${NR_RAT_RESET_DELTA}           ${CURDIR}${/}rat_reset_parameter.json

*** Test Cases ***

E2E_TL_SW_Upgrade_OnlineRecom_SiteReset_Rollback
    [Timeout]   24h
    ${result}    Create List
    FOR    ${iteration}    IN RANGE    1      ${ITERATIONS}+${1}
        #upgrade
        Log to console    \n*************** Start ITERATIONS: ${iteration} ***************
        ${status}   ${output}   Run Keyword And Ignore Error    e2e_tl_upgrade_test
        ...          nodes_details=${NODES}
        ...          test_nodes_details=${NODES}
        ...		     iterations_per_node=1
        ...          customers_list=${CUSTOMERS_LIST}
        ...          report=${REPORT}
        ...          report_comment=${REPORT_COMMENT}
        ...          qc_project=${QC_PROJECT}
        ...          qc_domain=${QC_DOMAIN}
        ...          qc_id=72575
        Handle_Step_Logs      upgrade    ${iteration}
        Run Keyword IF    '${status}'=='FAIL'    Append To List    ${result}    upgrade_${iteration}_fail
        #Online Commissioning
        ${status}   ${output}   Run Keyword And Ignore Error    E2E TL DELTA COMMISSIONING WITH ONLINE PARAMETER MODIFICATION
        ...          nodes_details=${NODES}
        ...          test_nodes_details=${NODES}
    #    ...          delta=${ONLINE_PARAMETER_DELTA}
        ...		     iterations_per_node=1
        ...          customers_list=${CUSTOMERS_LIST}
        ...          report=${REPORT}
        ...          report_comment=${REPORT_COMMENT}
        ...          qc_project=${QC_PROJECT}
        ...          qc_domain=${QC_DOMAIN}
        Handle_Step_Logs      online_recom    ${iteration}
        Run Keyword IF    '${status}'=='FAIL'        Append To List    ${result}    conline_recom_${iteration}_fail
        #Site Reset
        ${status}   ${output}   Run Keyword And Ignore Error    E2E_TL_Site_Reset_with_OAM_KPI
        ...          nodes_details=${NODES}
        ...          test_nodes_details=${NODES}
        ...		     iterations_per_node=1
        ...          customers_list=${CUSTOMERS_LIST}
        ...          report=${REPORT}
        ...          report_comment=${REPORT_COMMENT}
        ...          qc_project=${QC_PROJECT}
        ...          qc_domain=${QC_DOMAIN}
        #...          qc_id=72571
        Handle_Step_Logs      sitereset    ${iteration}
        Set To Dictionary
        ...    ${NODE1}    source_sw=${TARGET_SW}
        Set To Dictionary
        ...    ${NODE1}    target_sw=${INITIAL_SW}
        Run Keyword IF    '${status}'=='FAIL'    Append To List    ${result}    sitereset_${iteration}_fail
        #Rollback
        ${status}   ${output}   Run Keyword And Ignore Error    e2e_tl_rollback_test
        ...          nodes_details=${NODES}
        ...          test_nodes_details=${NODES}
        ...		     iterations_per_node=1
        ...          customers_list=${CUSTOMERS_LIST}
        Set To Dictionary
        ...    ${NODE1}    source_sw=${INITIAL_SW}
        Set To Dictionary
        ...    ${NODE1}    target_sw=${TARGET_SW}
        Handle_Step_Logs      rollback    ${iteration}
        Run Keyword IF    '${status}'=='FAIL'    Append To List    ${result}    rollback_${iteration}_fail
    END
    Run Keyword IF    ${result}     log    Case failed status: ${result}
    Run Keyword IF    ${result}     FAIL


*** Keywords ***
Handle_Step_Logs
    [Arguments]    ${step_name}    ${iteration}
    ${Status_1}    ${output}    Run Keyword And Ignore Error    Check For Specific Named Folder
    ...      ${OUTPUTDIR}/${TEST_NAME}      ${step_name}_passed
    ${Status_2}    ${output}    Run Keyword And Ignore Error    Check For Specific Named Folder
    ...      ${OUTPUTDIR}/${TEST_NAME}      Iteration_1_passed_logs
    Run Keyword If    '${Status_1}' == 'FAIL' and '${Status_2}' == 'PASS'
    ...    Rename Log Folder    ${OUTPUTDIR}/${TEST_NAME}/Iteration_1_passed_logs
    ...    ${OUTPUTDIR}/${TEST_NAME}/Iteration_${iteration}_${step_name}_passed_logs
    Run Keyword If    '${Status_2}' == 'FAIL'
    ...    Rename Log Folder    ${OUTPUTDIR}/${TEST_NAME}/Iteration_1
    ...    ${OUTPUTDIR}/${TEST_NAME}/Iteration_${iteration}_${step_name}_failed_logs
    Run Keyword If    '${Status_1}' == 'PASS' and '${Status_2}' == 'PASS'
    ...    Remove Folder    ${OUTPUTDIR}/${TEST_NAME}/Iteration_1_passed_logs

Rename Log Folder
    [Documentation]
    [Arguments]    ${source}    ${destination}
    Check For Specific Named Folder      ${OUTPUTDIR}/${TEST_NAME}      passed_logs
    Directory Should Exist    ${source}
    Move Directory    ${source}    ${destination}
    Directory Should Exist    ${destination}

Check For Specific Named Folder
    [Arguments]    ${DIRECTORY}      ${TARGET_STRING}
    ${folders}=    List Directories In Directory    ${DIRECTORY}
    ${result}=     Evaluate    any('${TARGET_STRING}' in folder for folder in ${folders})
    Should Be True    ${result}

Remove Folder
    [Documentation]    remove folder
    [Arguments]    ${DIRECTORY}
    Remove Directory    ${DIRECTORY}    recursive=True
    Log    Folder ${DIRECTORY} has been removed successfully.
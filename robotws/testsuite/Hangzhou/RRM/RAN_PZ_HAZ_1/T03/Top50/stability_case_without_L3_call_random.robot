*** Settings ***
Documentation
...   author: winnie.he
...   contact: winnie.he@nokia-sbell.com
...   this is a robot case for UTE regression
Resource          ../Resources/common_resource.robot
Resource          ../Resources/csv4all_resource.robot
# Library           ute_ue
Suite Setup       Common MultiBTS Suite Setup For RRM
Suite Teardown      Common MutliBTS Suite Teardown For RRM
Test Setup    Run keywords    Common MultiBTS Test Setup For RRM    other_method=Return From Keyword
...    AND    Case Setup
Test Teardown     Run keywords    Case Teardown    AND    Common MultiBTS Test Teardown For RRM
Test Timeout            75h
*** Variables ***
${TEST_ITERATION}          1
${BTS_INDEX}               all
&{Stability_TEST_ITERATION}
...    OAM_Stability_Upgrade=1
...    OAM_Stability_RF_reset=1
...    OAM_Stability_BBMOD_reset=1
...    OAM_Stability_Cell_block_unblock=1
...    OAM_Stability_Site_reset=1
...    OAM_Stability_Delta_Commission=1
...    OAM_Stability_RF_block_unblock=1
...    OAM_Stability_Cold_reset=1
...    E2E_TL_Parallel_SW_Upgrade_Rollback_with_OAM_KPI=1
*** Test Cases ***
Commission Gloden For All Site
    [Tags]    SCF_${TESTLINE_NAME}
    Commission Golden SCF For All GNB

Upgrade
    Prepare Random Case Configuration
    UUF4ALL Set Base Variable    bts_index=${BTS_INDEX}
    ...    case_name=OAM_Stability_Upgrade
    OAM_Stability_Upgrade

Random Stability Case
    Random Stability Case Run ALL

*** Keywords ***
Case Setup
    Log to Console    start ${TEST NAME}
    Run Keyword And Ignore Error    Rewrite The passed_logs_gathered Variable

Case Teardown
    # TL Test Teardown
    Log To Console    TL Test Teardown
    Run Keyword And Ignore Error    Run Keyword If Test Passed    Delete Logs

Get All Cases From Iteration
    ${all_cases_list}     Create List
    FOR    ${case_name}    ${times}     IN    &{Stability_TEST_ITERATION}
        FOR   ${i}    IN RANGE    ${times}
            Append To List    ${all_cases_list}    ${case_name}
        END
    END
    [Return]    ${all_cases_list}

Random Choose Case
    Prepare Random Case Configuration
    ${all_cases_list}    Get All Cases From Iteration
    ${shuffled_list}    Evaluate    random.sample(${all_cases_list}, len(${all_cases_list}))    random
    [Return]    ${shuffled_list}

Call Stability Case
    ${stability_cases_by_module}    Create List
    ...    OAM_Stability_RF_reset
    ...    OAM_Stability_BBMOD_reset
    ...    OAM_Stability_Cell_block_unblock
    ...    OAM_Stability_Site_reset
    ...    OAM_Stability_RF_block_unblock
    ...    OAM_Stability_Cold_reset
    ...    OAM_Stability_Delta_Commission
    # ...    OAM_Stability_Upgrade
    [Return]    ${stability_cases_by_module}

Random Stability Case Run One
    [Arguments]   ${case_name}
    UUF4ALL Set Base Variable    bts_index=${BTS_INDEX}
    ...    case_name=${case_name}
    ${all_called_cases}    Call Stability Case
    Run Keyword If    '${case_name}' not in ${all_called_cases}
    ...    Log To Console    ${case_name} is not supported in random cases pool
    Return From Keyword If     '${case_name}' not in ${all_called_cases}
    Run Keyword    ${case_name}

Random Stability Case Run ALL
    ${shuffled_list}    Random Choose Case
    FOR    ${case_name}    IN    @{shuffled_list}
        Random Stability Case Run One     ${case_name}
    END

Prepare Random Case Configuration
    ${config_str}    OperatingSystem.Get File    ${CURDIR}/../Top50/stability_test_iteration_config.json
    ${config_str}    Replace String Using Regexp    ${config_str}    \n\s*    ${EMPTY}
    ${config}    Evaluate    json.loads('${config_str}')
    ${tl_config_keys}    Get Dictionary Keys    ${config}
    ${Stability_TEST_ITERATION}    Set Variable    ${config}[Default]
    ${testline_config}    Run Keyword If    '${TESTLINE_NAME}' in ${tl_config_keys}
    ...    Set Variable    ${config}[${TESTLINE_NAME}]
    ...    ELSE
    ...    Set Variable    ${config}[Default]
    ${Stability_TEST_ITERATION}    Set Variable    ${testline_config}
    Return From Keyword If    '${TESTLINE_NAME}' not in ${tl_config_keys}
    ${tl_config_testname_keys}    Get Dictionary Keys    ${testline_config}
    ${default_config_testname_keys}    Get Dictionary Keys    ${config}[Default]
    FOR    ${case_name}   IN    @{default_config_testname_keys}
        Continue For Loop If    '${case_name}' not in ${tl_config_testname_keys}
        ${one_case_info_keys}    Get Dictionary Keys    ${testline_config}[${case_name}]
        ${info}    Set Variable    ${config}[Default][${case_name}]
        Run Keyword If    'runtimes' not in ${one_case_info_keys}
        ...    Set To Dictionary    ${Stability_TEST_ITERATION}
        ...    ${case_name}=${info}[runtimes]
        ...    ELSE
        ...    Set To Dictionary    ${Stability_TEST_ITERATION}
        ...    ${case_name}=${testline_config}[${case_name}][runtimes]
    END
    Set Suite Variable    ${Stability_TEST_ITERATION}    ${Stability_TEST_ITERATION}

# stabilit cases part
OAM_Stability_Cell_block_unblock
    [Documentation]    Please input the BTSINDEX varialbe from input
    ...    like -v BTS_INDEX:0
    ${rat_types}    Run Keyword If    '${BTS_INDEX}'=='all'
    ...    Get RAT Type    bts_index=${0}
    ...    ELSE
    ...    Get RAT Type    bts_index=${0}
    FOR    ${bts}    IN     @{rat_types}
        Run Keyword    UUF4ALL_Cell_Block_Unblock_${bts}_with_OAM_KPI
        ...    test_iteration=${1}
        Run Keyword And Ignore Error    Login All Coam Admin
    END

OAM_Stability_Site_reset
    UUF4ALL_Site_Reset_without_HWF_with_OAM_KPI
    ...    test_iteration=${1}

OAM_Stability_Delta_Commission
    UUF4ALL_Delta_Commissioning_With_Site_Reset_Required
    ...    test_iteration=${1}

OAM_Stability_RF_block_unblock
    UUF4ALL_RU_Lock_Unlock_with_OAM_KPI
    ...    test_iteration=${1}

OAM_Stability_Cold_reset
    UUF4ALL_RU_Power_Reset_with_OAM_KPI
    ...    test_iteration=${1}

OAM_Stability_Upgrade
    SW_Upgrade_Rollback_with_OAM_KPI
    ...    test_iteration=${1}

E2E_TL_Parallel_SW_Upgrade_Rollback_with_OAM_KPI
    E2E_TL_Parallel_SW_Upgrade_Rollback_with_OAM_KPI
    ...    test_iteration=${1}

OAM_Stability_RF_reset
    UUF4ALL_RU_Reset_with_OAM_KPI
    ...    test_iteration=${1}

OAM_Stability_BBMOD_reset
    UUF4ALL_BBMOD_Reset_with_OAM_KPI
    ...    test_iteration=${1}
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

&{Init_Enviroment_6480}      IP=10.108.213.198
...                     USERNAME=root
...                     PASSWORD=uteadmin
...                     Reinstall_Script_Path=${/}root${/}scripts
...                     VM_Required_File=~/MN/UTE/robotws/requirements.cfg

&{Testline_KVM}         10_5_UTESRAN001T6480=${Init_Enviroment_6480}
${TEST_ITERATION}          1
${BTS_INDEX}               all
${OAM_Stability_Upgrade_times}    ${None}
${OAM_Stability_RF_reset_times}    ${None}
${OAM_Stability_BBMOD_reset_times}    ${None}
${OAM_Stability_Cell_block_unblock_times}    ${None}
${OAM_Stability_Site_reset_times}    ${None}
${OAM_Stability_Delta_Commission_times}    ${None}
${OAM_Stability_RF_block_unblock_times}    ${None}
${OAM_Stability_Cold_reset_times}    ${None}
${OAM_Stability_Activation_Reset_with_OAM_KPI_times}    ${None}
${OAM_Stability_Capacity_Module_Reset_with_OAM_KPI_times}    ${None}
${OAM_Stability_Capacity_Module_Lock_Unlock_times}    ${None}
${OAM_Stability_Cell_lock_unlock_times}    ${None}

&{Stability_TEST_ITERATION}
...    OAM_Stability_Upgrade=1
...    OAM_Stability_RF_reset=1
...    OAM_Stability_BBMOD_reset=1
...    OAM_Stability_Cell_block_unblock=1
...    OAM_Stability_Site_reset=1
...    OAM_Stability_Delta_Commission=1
...    OAM_Stability_RF_block_unblock=1
...    OAM_Stability_Cold_reset=1
...    e2e_tl_activation_reset_test=1
...    E2E_TL_Parallel_SW_Upgrade_Rollback_with_OAM_KPI=1
...    OAM_Stability_Activation_Reset_with_OAM_KPI=1
...    OAM_Stability_Capacity_Module_Reset_with_OAM_KPI=1
...    OAM_Stability_Capacity_Module_Lock_Unlock=1
...    OAM_Stability_Cell_lock_unlock=1
*** Test Cases ***
Reinstall Init Enviroment
    [Setup]    Common MultiBTS Test Setup For RRM    other_method=Return From Keyword
    ${config_testlines}    Get Dictionary Keys    dictionary=${Testline_KVM}
    Run Keyword If    '${TESTLINE_NAME}' in "@{config_testlines}"
    ...    Set Test Variable    ${Init_Enviroment}    ${Testline_KVM}[${TESTLINE_NAME}]
    Run Keyword If    '${TESTLINE_NAME}' in "@{config_testlines}"
    ...    ReInstall Vm    ${False}
    [Teardown]    Common MultiBTS Test Teardown For RRM

Commission Gloden For All Site
    [Tags]    SCF_${TESTLINE_NAME}
    [Setup]    Common MultiBTS Test Setup For RRM    other_method=Return From Keyword
    Commission Golden SCF For All GNB
    [Teardown]    Common MultiBTS Test Teardown For RRM

OAM_Stability_Upgrade
    [Documentation]    Please input the BTSINDEX varialbe from input
    ...    like -v BTS_INDEX:0
    UUF4ALL Set Base Variable    bts_index=${BTS_INDEX}
    Log To Console    iteration ${Stability_TEST_ITERATION}[${TEST NAME}]
    SW_Upgrade_Rollback_with_OAM_KPI

E2E_TL_Parallel_SW_Upgrade_Rollback_with_OAM_KPI
    [Documentation]    Please input the BTSINDEX varialbe from input
    ...    like -v BTS_INDEX:0
    UUF4ALL Set Base Variable    bts_index=${BTS_INDEX}
    Log To Console    iteration ${Stability_TEST_ITERATION}[${TEST NAME}]
    E2E_TL_Parallel_SW_Upgrade_Rollback_with_OAM_KPI
    ...    test_iteration=${Stability_TEST_ITERATION}[${TEST NAME}]

OAM_Stability_RF_reset
    [Documentation]    Please input the BTSINDEX varialbe from input
    ...    like -v BTS_INDEX:0
    Log To Console    iteration ${Stability_TEST_ITERATION}[${TEST NAME}]
    UUF4ALL Set Base Variable    bts_index=${BTS_INDEX}
    UUF4ALL_RU_Reset_with_OAM_KPI
    ...    test_iteration=${Stability_TEST_ITERATION}[${TEST NAME}]

OAM_Stability_BBMOD_reset
    [Documentation]    Please input the BTSINDEX varialbe from input
    ...    like -v BTS_INDEX:0
      Log To Console    iteration ${Stability_TEST_ITERATION}[${TEST NAME}]
    UUF4ALL Set Base Variable    bts_index=${BTS_INDEX}
    UUF4ALL_BBMOD_Reset_with_OAM_KPI
    ...    test_iteration=${Stability_TEST_ITERATION}[${TEST NAME}]

OAM_Stability_Cell_block_unblock
    [Documentation]    Please input the BTSINDEX varialbe from input
    ...    like -v BTS_INDEX:0
    ${rat_types}    Run Keyword If    '${BTS_INDEX}'=='all'
    ...    Get RAT Type    bts_index=${0}
    ...    ELSE
    ...    Get RAT Type    bts_index=${0}
    FOR    ${bts}    IN     @{rat_types}
        UUF4ALL Set Base Variable    bts_index=${BTS_INDEX}
        Run Keyword    UUF4ALL_Cell_Block_Unblock_${bts}_with_OAM_KPI
        ...    test_iteration=${Stability_TEST_ITERATION}[${TEST NAME}]
        Run Keyword And Ignore Error    Login All Coam Admin
    END

OAM_Stability_Site_reset
    [Documentation]    Please input the BTSINDEX varialbe from input
    ...    like -v BTS_INDEX:0
    Log To Console    iteration ${Stability_TEST_ITERATION}[${TEST NAME}]
    UUF4ALL Set Base Variable    bts_index=${BTS_INDEX}
    UUF4ALL_Site_Reset_without_HWF_with_OAM_KPI
    ...    test_iteration=${Stability_TEST_ITERATION}[${TEST NAME}]

OAM_Stability_Delta_Commission
    [Documentation]    Please input the BTSINDEX varialbe from input
    ...    like -v BTS_INDEX:0
    Log To Console    iteration ${Stability_TEST_ITERATION}[${TEST NAME}]
    UUF4ALL Set Base Variable    bts_index=${BTS_INDEX}
    UUF4ALL_Delta_Commissioning_With_Site_Reset_Required
    ...    test_iteration=${Stability_TEST_ITERATION}[${TEST NAME}]

OAM_Stability_RF_block_unblock
    [Documentation]    Please input the BTSINDEX varialbe from input
    ...    like -v BTS_INDEX:0
    UUF4ALL Set Base Variable    bts_index=${BTS_INDEX}
    UUF4ALL_RU_Lock_Unlock_with_OAM_KPI
    ...    test_iteration=${Stability_TEST_ITERATION}[${TEST NAME}]
    Run Keyword And Ignore Error    Login All Coam Admin

OAM_Stability_Cold_reset
    [Tags]    Capacity
    [Documentation]    Please input the BTSINDEX varialbe from input
    ...    like -v BTS_INDEX:0
    UUF4ALL Set Base Variable    bts_index=${BTS_INDEX}
    UUF4ALL_RU_Power_Reset_with_OAM_KPI
    ...    test_iteration=${Stability_TEST_ITERATION}[${TEST NAME}]

OAM_Stability_Activation_Reset_with_OAM_KPI
    [Tags]    Activation_Reset
    [Documentation]    Please input the BTSINDEX varialbe from input
    ...    like -v BTS_INDEX:0
    UUF4ALL Set Base Variable    bts_index=${BTS_INDEX}
    UUF4ALL_Activation_Reset_with_OAM_KPI
    ...    test_iteration=${Stability_TEST_ITERATION}[${TEST NAME}]

OAM_Stability_Cell_lock_unlock
    # [Tags]    Capacity
    [Documentation]    Please input the BTSINDEX varialbe from input
    ...    like -v BTS_INDEX:0
    ${rat_types}    Run Keyword If    '${BTS_INDEX}'=='all'
    ...    Get RAT Type    bts_index=${0}
    ...    ELSE
    ...    Get RAT Type    bts_index=${0}
    FOR    ${bts}    IN     @{rat_types}
        UUF4ALL Set Base Variable    bts_index=${BTS_INDEX}
        Run Keyword    UUF4ALL_Cell_lock_Unlock_${bts}_with_OAM_KPI
        ...    test_iteration=${Stability_TEST_ITERATION}[${TEST NAME}]
        Run Keyword And Ignore Error    Login All Coam Admin
    END

OAM_Stability_Capacity_Module_Reset_with_OAM_KPI
    # [Tags]    Capacity
    [Documentation]    Please input the BTSINDEX varialbe from input
    ...    like -v BTS_INDEX:0
    UUF4ALL Set Base Variable    bts_index=${BTS_INDEX}
    UUF4ALL_Capacity_Module_Reset_with_OAM_KPI
    ...    test_iteration=${Stability_TEST_ITERATION}[${TEST NAME}]

OAM_Stability_Capacity_Module_Lock_Unlock
    # [Tags]    Capacity
    [Documentation]    Please input the BTSINDEX varialbe from input
    ...    like -v BTS_INDEX:0
    UUF4ALL Set Base Variable    bts_index=${BTS_INDEX}
    UUF4ALL_Capacity_Module_Lock_Unlock
    ...    test_iteration=${Stability_TEST_ITERATION}[${TEST NAME}]

*** Keywords ***
Case Setup
    Log to Console    start ${TEST NAME}
    UUF4ALL Set Base Variable    bts_index=${BTS_INDEX}
    Run Keyword And Ignore Error    Rewrite The passed_logs_gathered Variable
    # UUF4ALL Send QC For Custom

Case Teardown
    # TL Test Teardown
    Log To Console    TL Test Teardown
    Run Keyword And Ignore Error    Run Keyword If Test Passed    Delete Logs
    # ${testcase_name}    UUF4ALL Get QC Test Case Name
    # TL Test Teardown    ${testcase_name}
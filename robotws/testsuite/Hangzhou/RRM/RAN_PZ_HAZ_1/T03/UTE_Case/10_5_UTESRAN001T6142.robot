*** Settings ***
Documentation
...   author: winnie.he
...   contact: winnie.he@nokia-sbell.com
...   this is a robot case for UTE regression
Resource          ../Resources/common_resource.robot
Resource          ../Resources/top50_resource.robot
Library           ute_ue
Suite Setup       Common MultiBTS Suite Setup For RRM
Suite Teardown      Run keywords     Common MutliBTS Suite Teardown For RRM    AND
...    Top50 Suite Teardown
Test Setup    Run keywords    Common MultiBTS Test Setup For RRM    other_method=Return From Keyword
...    AND    Case Setup
Test Teardown     Run keywords    Case Teardown    AND    Common MultiBTS Test Teardown For RRM
Force Tags
# ...                     CRT
...                     RAN_5G
...                     CLOUD_5G_CLASSICAL_ANDRIOD_RFS_ASIK_ABIL3_AHEGC3_AEQB3-ASIA_ABIA
...                     SBTS23R1
...                     SBTS00
...                     STATE_SKIP_AGENT
...                     CA_RAN_PZ_HAZ_1
...                     RAN_PZ_HAZ1_SG07_ST_RRM
...                     TA_LEVEL_22
Test Timeout            75h
*** Variables ***
${PA_MaxValue}    ${93}
${PA_NormalValue}    ${1}
${PA_MinValue}    ${0}
&{Init_Enviroment}      IP=10.108.233.149
...                     USERNAME=root
...                     PASSWORD=uteadmin
...                     Reinstall_Script_Path=${/}root${/}scripts
...                     VM_Required_File=~/MN/UTE/robotws/requirements.cfg

${TEST_ITERATION}       1
&{fault_6129}              faultId=${6129}
&{fault_6134}              faultId=${6134}
&{fault_4694}              faultId=${4694}
&{fault_8150}              faultId=${8150}
@{Ohter_Allow_Alarms}      &{fault_4694}    &{fault_6134}    &{fault_6129}
...    &{fault_8150}
&{fault_7512}              faultId=${7512}
&{fault_7509}              faultId=${7509}
&{fault_6133}              faultId=${6133}
@{DSS_Allow_Alarms}    &{fault_7512}    &{fault_7509}    &{fault_6133}
&{fault_7313}              faultId=${7313}
&{fault_1815}              faultId=${1815}
@{Mode_Allow_Alarms}    &{fault_7313}    &{fault_1815}
${BTS_INDEX}               ${0}
&{E2E_TL_SW_Upgrade_Rollback_with_OAM_KPI_WITH_L3_CALL}    SBTS00=284538    SBTS23R3=656903
...    testname=OAM_Stability_5G_Upgrade_SA_call
&{E2E_TL_Cell_Block_Unblock_NR_with_OAM_KPI_WITH_L3_CALL}    SBTS00=277721
...    testname=OAM_Stability_5G_Cell_block_unblock_SA_call
&{E2E_TL_RU_Lock_Unlock_WITH_L3_CALL}    SBTS00=277720
...    testname=OAM_Stability_5G_RF_block_unblock_SA_call
&{E2E_TL_Capacity_Module_Reset_with_OAM_KPI}    SBTS00=277718
...    testname=OAM_Stability_5G_BBMOD_reset_SA_call
&{E2E_TL_Site_Reset_without_HWF_with_OAM_KPI_WITH_L3_CALL}    SBTS00=261363    SBTS23R3=656901
...    testname=OAM_Stability_5G_Site_reset_SA_call
&{E2E_TL_RU_Reset_with_OAM_KPI_WITH_L3_CALL}    SBTS00=277719
...    testname=OAM_Stability_5G_RF_reset_SA_call
&{OAM_Stability_5G_Cold_reset_SA_call}    SBTS00=261362
...    testname=OAM_Stability_5G_Cold_reset_SA_call
&{UUF4ALL_CASE_QC_ID}
...    E2E_TL_SW_Upgrade_Rollback_with_OAM_KPI_WITH_L3_CALL=&{E2E_TL_SW_Upgrade_Rollback_with_OAM_KPI_WITH_L3_CALL}
...    E2E_TL_Capacity_Module_Reset_with_OAM_KPI=&{E2E_TL_Capacity_Module_Reset_with_OAM_KPI}
...    E2E_TL_Cell_Block_Unblock_NR_with_OAM_KPI_WITH_L3_CALL=&{E2E_TL_Cell_Block_Unblock_NR_with_OAM_KPI_WITH_L3_CALL}
...    E2E_TL_RU_Lock_Unlock_WITH_L3_CALL=&{E2E_TL_RU_Lock_Unlock_WITH_L3_CALL}
...    E2E_TL_RU_Reset_with_OAM_KPI_WITH_L3_CALL=&{E2E_TL_RU_Reset_with_OAM_KPI_WITH_L3_CALL}
...    E2E_TL_Site_Reset_without_HWF_with_OAM_KPI_WITH_L3_CALL=&{E2E_TL_Site_Reset_without_HWF_with_OAM_KPI_WITH_L3_CALL}
...    OAM_Stability_5G_Cold_reset_SA_call=&{OAM_Stability_5G_Cold_reset_SA_call}

&{Stability_TEST_ITERATION}
...    E2E_TL_SW_Upgrade_Rollback_with_OAM_KPI_WITH_L3_CALL=1
...    E2E_TL_Capacity_Module_Reset_with_OAM_KPI=1
...    E2E_TL_Cell_Block_Unblock_NR_with_OAM_KPI_WITH_L3_CALL=1
...    E2E_TL_Cell_Lock_Unlock_NR_with_OAM_KPI_WITH_L3_CALL=1
...    E2E_TL_RU_Lock_Unlock_WITH_L3_CALL=1
...    E2E_TL_Delta_Commissioning_With_Site_Reset_Required_WITH_L3_CALL=1
...    E2E_TL_RU_Reset_with_OAM_KPI_WITH_L3_CALL=1
...    E2E_TL_Site_Reset_without_HWF_with_OAM_KPI_WITH_L3_CALL=1
...    OAM_Stability_5G_Cold_reset_SA_call=1
...    E2E_TL_Delta_Commissioning_With_NR_Rat_Reset_WITH_L3_CALL=1
...    E2E_TL_Delta_Commissioning_With_LTE_Rat_Reset_WITH_L3_CALL=1
...    E2E_TL_Cell_Block_Unblock_LTE_with_OAM_KPI_WITH_L3_CALL=1

# ${DEBUG_MODE}    ${TRUE}
*** Test Cases ***
# Init Enviroment
#     ReInstall Vm
E2E_TL_SW_Upgrade_Rollback_with_OAM_KPI_WITH_L3_CALL
    [Tags]    5G
    [Documentation]    Please input the BTSINDEX varialbe from input
    ...    like -v BTS_INDEX:0
    # Log To Console    test
    SW_Upgrade_Rollback_with_OAM_KPI
    ...    test_iteration=${Stability_TEST_ITERATION}[${TEST NAME}]

E2E_TL_Capacity_Module_Reset_with_OAM_KPI
    [Tags]    5G
    [Documentation]    Please input the BTSINDEX varialbe from input
    ...    like -v BTS_INDEX:0
    # SA_Call    cell_used_in_test=${None}
    Append BBMOD Reset Allow Alarms
    UUF4ALL_BBMOD_Reset_with_OAM_KPI
    ...    L3_CALL_Kw=SA_Call
    ...    test_iteration=${Stability_TEST_ITERATION}[${TEST NAME}]

E2E_TL_Delta_Commissioning_With_NR_Rat_Reset_WITH_L3_CALL
    [Tags]    LTE
    [Documentation]    Please input the BTSINDEX varialbe from input
    ...    like -v BTS_INDEX:0
    # Log To Console    test
    UUF4ALL_RAT_Reset_with_OAM_KPI
    ...    L3_CALL_Kw=SA_Call
    ...    test_iteration=${Stability_TEST_ITERATION}[${TEST NAME}]
    ...    rat=NR

E2E_TL_Delta_Commissioning_With_LTE_Rat_Reset_WITH_L3_CALL
    [Tags]    LTE
    [Documentation]    Please input the BTSINDEX varialbe from input
    ...    like -v BTS_INDEX:0
    # SA_Call    ${None}
    # Log To Console    test
    UUF4ALL_RAT_Reset_with_OAM_KPI
    ...    L3_CALL_Kw=SA_Call
    ...    test_iteration=${Stability_TEST_ITERATION}[${TEST NAME}]
    ...    rat=LTE

E2E_TL_Cell_Lock_Unlock_NR_with_OAM_KPI_WITH_L3_CALL
    [Tags]    5G
    [Documentation]    Please input the BTSINDEX varialbe from input
    ...    like -v BTS_INDEX:0
    Append NR Block Allow Alarms
    UUF4ALL_Cell_Lock_Unlock_NR_with_OAM_KPI
    ...    L3_CALL_Kw=SA_Call
    ...    test_iteration=${Stability_TEST_ITERATION}[${TEST NAME}]

E2E_TL_Cell_Block_Unblock_LTE_with_OAM_KPI_WITH_L3_CALL
    [Tags]    5G
    [Documentation]    Please input the BTSINDEX varialbe from input
    ...    like -v BTS_INDEX:0
    Append LTE Block Allow Alarms
    UUF4ALL_Cell_Block_Unblock_LTE_with_OAM_KPI
    ...    L3_CALL_Kw=SA_Call
    ...    test_iteration=${Stability_TEST_ITERATION}[${TEST NAME}]

E2E_TL_Cell_Block_Unblock_NR_with_OAM_KPI_WITH_L3_CALL
    [Tags]    5G
    [Documentation]    Please input the BTSINDEX varialbe from input
    ...    like -v BTS_INDEX:0
    Append NR Block Allow Alarms
    UUF4ALL_Cell_Block_Unblock_NR_with_OAM_KPI
    ...    L3_CALL_Kw=SA_Call
    ...    test_iteration=${Stability_TEST_ITERATION}[${TEST NAME}]

E2E_TL_RU_Lock_Unlock_WITH_L3_CALL
    [Tags]    5G
    [Documentation]    Please input the BTSINDEX varialbe from input
    ...    like -v BTS_INDEX:0
    # SA_Call    cell_used_in_test=${None}
    # Log To Console    test
    UUF4ALL_RU_Lock_Unlock_with_OAM_KPI
    ...    L3_CALL_Kw=SA_Call
    ...    test_iteration=${Stability_TEST_ITERATION}[${TEST NAME}]

E2E_TL_Delta_Commissioning_With_Site_Reset_Required_WITH_L3_CALL
    [Documentation]    Please input the BTSINDEX varialbe from input
    ...    like -v BTS_INDEX:0
    # SA_Call    cell_used_in_test=${None}
    # Log To Console    test
    UUF4ALL_Delta_Commissioning_With_Site_Reset_Required
    ...    L3_CALL_Kw=SA_Call
    ...    test_iteration=${Stability_TEST_ITERATION}[${TEST NAME}]

E2E_TL_RU_Reset_with_OAM_KPI_WITH_L3_CALL
    [Tags]    5G
    [Documentation]    Please input the BTSINDEX varialbe from input
    ...    like -v BTS_INDEX:0
    # SA_Call    cell_used_in_test=${None}
    # Log To Console    test
    UUF4ALL_RU_Reset_with_OAM_KPI
    ...    L3_CALL_Kw=SA_Call
    ...    test_iteration=${Stability_TEST_ITERATION}[${TEST NAME}]

E2E_TL_Site_Reset_without_HWF_with_OAM_KPI_WITH_L3_CALL
    [Tags]    5G
    [Documentation]    Please input the BTSINDEX varialbe from input
    ...    like -v BTS_INDEX:0
    # SA_Call    cell_used_in_test=${None}
    # Log To Console    test
    UUF4ALL_Site_Reset_without_HWF_with_OAM_KPI
    ...    L3_CALL_Kw=SA_Call
    ...    test_iteration=${Stability_TEST_ITERATION}[${TEST NAME}]

OAM_Stability_5G_Cold_reset_SA_call
    [Tags]    5G
    [Documentation]    Please input the BTSINDEX varialbe from input
    ...    like -v BTS_INDEX:0
    # SA_Call    cell_used_in_test=${None}
    Combine Power Reset Alarms
    UUF4ALL_RU_Power_Reset_with_OAM_KPI
    ...    L3_CALL_Kw=SA_Call
    ...    test_iteration=${Stability_TEST_ITERATION}[${TEST NAME}]

*** Keywords ***
Append BBMOD Reset Allow Alarms
    Append To List    ${CUSTOM_ALARMS}     7313
    Append To List    ${CUSTOM_ALARMS}     7312
    Append To List    ${CUSTOM_ALARMS}     6134

Append NR Block Allow Alarms
    Append To List    ${CUSTOM_ALARMS}     6134

Append LTE Block Allow Alarms
    Append To List    ${CUSTOM_ALARMS}     7513

Combine DSS Alarms
    FOR    ${fault_Info}   IN    @{DSS_Allow_Alarms}
        Append To List    ${CUSTOM_ALARMS}     ${fault_Info}[faultId]
    END
    Set Test Variable    ${CUSTOM_ALARMS}    ${CUSTOM_ALARMS}

Combine Reset Alarms
    FOR    ${fault_Info}   IN    @{Mode_Allow_Alarms}
        Append To List    ${CUSTOM_ALARMS}     ${fault_Info}[faultId]
    END
    Set Test Variable    ${CUSTOM_ALARMS}    ${CUSTOM_ALARMS}

Remove Alarms
    ${CUSTOM_ALARMS}    Create List
    Set Test Variable    ${CUSTOM_ALARMS}    ${CUSTOM_ALARMS}

Case Setup
    UUF4ALL Set Base Variable    bts_index=${BTS_INDEX}
    UUF4ALL Send QC For Custom

Case Teardown
    Log to console    TL Test Teardown
    Run Keyword And Ignore Error    Remove Alarms
    Run Keyword And Ignore Error    Run Keyword If Test Passed    Delete Logs
    ${testcase_name}    UUF4ALL Get QC Test Case Name
    TL Test Teardown    ${testcase_name}

SA_Call
    [Arguments]    ${cell_used_in_test}    ${remote}=${USE_REMOTE_NODE}
    ...    ${bts_index}=${BTS_INDEX}
    L3 Call    cell_used_in_test=${cell_used_in_test}
    ...    remote=${remote}    bts_index=${bts_index}
    ...    mode=SA
    ...    pre_attach_kw=Lock Band

Lock Band
    AT.Lock Frequency    lock_parameter=1,1,0,627264,345,1,5078
    AT.Variable UE Set
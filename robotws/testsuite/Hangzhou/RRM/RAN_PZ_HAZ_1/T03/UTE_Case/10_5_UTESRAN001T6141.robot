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
...                     CLOUD_5G_CLASSICAL_ANDRIOD_RFS_ASIA_ABIA2-ASIK_ABIL3_AHEGC3_AEQB3
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
&{Init_Enviroment}      IP=10.56.198.140
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
${BTS_INDEX}               ${0}
&{E2E_TL_SW_Upgrade_Rollback_with_OAM_KPI}    SBTS00=284537    SBTS23R3=656902
...    testname=OAM_Stability_ 4G_Upgrade_ENDC_call
&{E2E_TL_Capacity_Module_Reset_with_OAM_KPI}    SBTS00=268295
...    testname=OAM_Stability_4G_BBMOD_reset_ENDC_call
&{E2E_TL_Cell_Block_Unblock_LTE_with_OAM_KPI}    SBTS00=268296
...    testname=OAM_Stability_4G_Cell_block_unblock_ENDC_call
&{E2E_TL_Site_Reset_without_HWF_with_OAM_KPI}    SBTS00=256752    SBTS23R3=656900
...    testname=OAM_Stability_4G_Cell_block_unblock_ENDC_call
&{OAM_Stability_4G_Cold_reset_ENDC_call}    SBTS00=256751
...    testname=OAM_Stability_4G_Cold_reset_ENDC_call
&{UUF4ALL_CASE_QC_ID}
...    E2E_TL_SW_Upgrade_Rollback_with_OAM_KPI=&{E2E_TL_SW_Upgrade_Rollback_with_OAM_KPI}
...    E2E_TL_Capacity_Module_Reset_with_OAM_KPI=&{E2E_TL_Capacity_Module_Reset_with_OAM_KPI}
...    E2E_TL_Cell_Block_Unblock_LTE_with_OAM_KPI=&{E2E_TL_Cell_Block_Unblock_LTE_with_OAM_KPI}
...    E2E_TL_Site_Reset_without_HWF_with_OAM_KPI=&{E2E_TL_Site_Reset_without_HWF_with_OAM_KPI}
...    OAM_Stability_4G_Cold_reset_ENDC_call=&{OAM_Stability_4G_Cold_reset_ENDC_call}

&{Stability_TEST_ITERATION}
...    E2E_TL_SW_Upgrade_Rollback_with_OAM_KPI=1
...    E2E_TL_Capacity_Module_Reset_with_OAM_KPI=1
...    E2E_TL_Cell_Block_Unblock_LTE_with_OAM_KPI=1
...    E2E_TL_Site_Reset_without_HWF_with_OAM_KPI=1
...    OAM_Stability_4G_RF_reset_ENDC_call=1
...    OAM_Stability_4G_RF_block_unblock_ENDC_call=1
...    E2E_TL_Delta_Commissioning_With_Site_Reset_Required=1
...    OAM_Stability_4G_Cold_reset_ENDC_call=1
...    OAM_Stability_4G_Delta_Commissioning_With_All_Rat_Reset_ENDC_call=1
...    E2E_TL_Cell_Block_Unblock_WCDMA_with_OAM_KPI=1
# ${DEBUG_MODE}    ${TRUE}
*** Test Cases ***
# Init Enviroment
#     ReInstall Vm
E2E_TL_SW_Upgrade_Rollback_with_OAM_KPI
    [Tags]    LTE
    [Documentation]    Please input the BTSINDEX varialbe from input
    ...    like -v BTS_INDEX:0
    # Log to Console    fix
    SW_Upgrade_Rollback_with_OAM_KPI
    ...    test_iteration=${Stability_TEST_ITERATION}[${TEST NAME}]

OAM_Stability_4G_RF_reset_ENDC_call
    [Tags]    LTE
    [Documentation]    Please input the BTSINDEX varialbe from input
    ...    like -v BTS_INDEX:0
    # Log to Console    fix
    UUF4ALL_RU_Reset_with_OAM_KPI
    ...    L3_CALL_Kw=ENDC_Call
    ...    test_iteration=${Stability_TEST_ITERATION}[${TEST NAME}]

E2E_TL_Capacity_Module_Reset_with_OAM_KPI
    [Tags]    LTE
    [Documentation]    Please input the BTSINDEX varialbe from input
    ...    like -v BTS_INDEX:0
    # Log to Console    fix
    UUF4ALL_BBMOD_Reset_with_OAM_KPI
    ...    L3_CALL_Kw=ENDC_Call
    ...    test_iteration=${Stability_TEST_ITERATION}[${TEST NAME}]

E2E_TL_Cell_Block_Unblock_LTE_with_OAM_KPI
    [Tags]    LTE
    [Documentation]    Please input the BTSINDEX varialbe from input
    ...    like -v BTS_INDEX:0
    ${rat_types}    Get RAT Type    bts_index=${BTS_INDEX}
    Combine DSS Alarms
    UUF4ALL_Cell_Block_Unblock_LTE_with_OAM_KPI
    ...    L3_CALL_Kw=ENDC_Call
    ...    test_iteration=${Stability_TEST_ITERATION}[${TEST NAME}]

E2E_TL_Cell_Block_Unblock_WCDMA_with_OAM_KPI
    [Tags]    LTE
    [Documentation]    Please input the BTSINDEX varialbe from input
    ...    like -v BTS_INDEX:0
    Combine DSS Alarms
    UUF4ALL_Cell_Block_Unblock_WCDMA_with_OAM_KPI
    ...    L3_CALL_Kw=ENDC_Call
    ...    test_iteration=${Stability_TEST_ITERATION}[${TEST NAME}]

OAM_Stability_4G_Delta_Commissioning_With_All_Rat_Reset_ENDC_call
    [Tags]    LTE
    [Documentation]    Please input the BTSINDEX varialbe from input
    ...    like -v BTS_INDEX:0
    # Log to Console    fix
    UUF4ALL_RAT_Reset_with_OAM_KPI
    ...    L3_CALL_Kw=ENDC_Call
    ...    test_iteration=${Stability_TEST_ITERATION}[${TEST NAME}]

E2E_TL_Site_Reset_without_HWF_with_OAM_KPI
    [Tags]    LTE
    [Documentation]    Please input the BTSINDEX varialbe from input
    ...    like -v BTS_INDEX:0
    # Log to Console    fix
    UUF4ALL_Site_Reset_without_HWF_with_OAM_KPI
    ...    L3_CALL_Kw=ENDC_Call
    ...    test_iteration=${Stability_TEST_ITERATION}[${TEST NAME}]

E2E_TL_Delta_Commissioning_With_Site_Reset_Required
    [Tags]    LTE
    [Documentation]    Please input the BTSINDEX varialbe from input
    ...    like -v BTS_INDEX:0
    # Log to Console    fix
    UUF4ALL_Delta_Commissioning_With_Site_Reset_Required
    ...    L3_CALL_Kw=ENDC_Call
    ...    test_iteration=${Stability_TEST_ITERATION}[${TEST NAME}]

OAM_Stability_4G_Cold_reset_ENDC_call
    [Tags]    5G
    [Documentation]    Please input the BTSINDEX varialbe from input
    ...    like -v BTS_INDEX:0
    Combine Power Reset Alarms
    UUF4ALL_RU_Power_Reset_with_OAM_KPI
    ...    L3_CALL_Kw=ENDC_Call
    ...    test_iteration=${Stability_TEST_ITERATION}[${TEST NAME}]


*** Keywords ***
Combine DSS Alarms
    FOR    ${fault_Info}   IN    @{DSS_Allow_Alarms}
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


ENDC_Call
    [Arguments]    ${cell_used_in_test}    ${remote}=${USE_REMOTE_NODE}
    ...    ${bts_index}=${BTS_INDEX}
    L3 Call    cell_used_in_test=${cell_used_in_test}
    ...    remote=${remote}    bts_index=${bts_index}
    ...    mode=NSA
    ...    remote_pa_change_kw=Enable 5G PA
    ...    pre_attach_kw=Unlock Band

Unlock Band
    AT.Lock Frequency    lock_parameter=0
    AT.Variable UE Set

Enable 5G PA
    Modify Attenuation For One RRU Of One Site
    ...    ru_id=${2}    gnb_id=${1}    value=${PA_NormalValue}
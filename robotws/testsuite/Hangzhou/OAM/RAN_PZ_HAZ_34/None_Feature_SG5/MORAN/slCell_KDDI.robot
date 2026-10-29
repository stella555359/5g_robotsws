*** Settings ***
Suite Setup        SISO Coam Suite Setup
Suite Teardown     SISO Coam Suite Teardown
Test Setup         SISO Coam Test Setup
Test Teardown      SISO Coam Test Teardown
Test Timeout       12 hours

Resource           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource           ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource           ${BASIC_PATH_5G}/General_Stability_Test_Case.robot
Resource           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot
Resource           ./resources/slCell_cases.robot
Resource           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/5G/Cell/E2E_SiSo_Cell_block_and_unblock_gNB.robot
Resource           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/5G/Cell/E2E_SiSo_Cell_lock_and_unlock_gNB.robot
Resource           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/5G/General_SiSo_RF_module_reset_from_GUI.robot
Resource           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/5G/Baseband_module_reset_via_WEBUI.robot
Documentation
...    author: annie.hu
...    contact: annie.hu@nokia-sbell.com
...    squad group: SG_05
...    Feature 'CS4.2 Sleeping Cell Case'

Force Tags      E2E_SBM    SG_05

*** Variables ***
${total_loops}                  ${3}
${if_commissioning}             True

*** Test Cases ***
[1]E2E_TL_Cell_Block_Unblock_NR_with_sleeping_cell_check
    [Tags]    E2E_slCell
    [Setup]    SISO Coam Test Setup
    Log To Console    \ntotal times:${total_loops}
    General_Stability_Test_Case    case_name=E2E_SiSo_Cell_block_and_unblock_gNB     with_call=${True}   times=${total_loops}    pass=${total_loops}
    ...    common_setup_each_time=${False}   run_total_times=${True}    with_recovery=${False}
    #[Teardown]    SISO Coam Test Teardown

[1]E2E_TL_Cell_Lock_Unlock_NR_with_sleeping_cell_check
    [Tags]    E2E_slCell
    [Setup]    SISO Coam Test Setup
    Log To Console    \ntotal times:${total_loops}
    General_Stability_Test_Case    case_name=E2E_SiSo_Cell_lock_and_unlock_gNB    with_call=${True}    times=${total_loops}    pass=${total_loops}
    ...    common_setup_each_time=${False}   run_total_times=${True}    with_recovery=${False}
    #[Teardown]    SISO Coam Test Teardown

[1]E2E_TL_RU_Reset_with_sleeping_cell_check
    [Tags]    E2E_slCell
    [Setup]    SISO Coam Test Setup
    Log To Console    \ntotal times:${total_loops}
    General_Stability_Test_Case    case_name=General_SiSo_RF_module_reset_from_GUI   with_call=${True}    times=${total_loops}    pass=${total_loops}
    ...    common_setup_each_time=${False}   run_total_times=${True}    with_recovery=${False}
    #[Teardown]    SISO Coam Test Teardown

[1]E2E_TL_Capacity_Module_Reset_with_sleeping_cell_check
    [Tags]    E2E_slCell
    [Setup]    SISO Coam Test Setup
    Log To Console    \ntotal times:${total_loops}
    General_Stability_Test_Case    case_name=Baseband_module_reset_via_WEBUI    with_call=${True}    times=${total_loops}    pass=${total_loops}
    ...    common_setup_each_time=${False}   run_total_times=${True}    with_recovery=${False}
    #[Teardown]    SISO Coam Test Teardown

[1]E2E_TL_Delta_Commissioning_With_Site_Reset_Required_sleeping_cell_check
    [Tags]    E2E_slCell
    [Setup]    SISO Coam Test Setup
    Log To Console    \ntotal times:${total_loops}
    General_Stability_Test_Case    case_name=slCell_Delta_Commissioning_With_Site_Reset_Required    times=${total_loops}
    ...    pass=${total_loops}    common_setup_each_time=${False}   run_total_times=${True}    with_recovery=${False}
    #[Teardown]    SISO Coam Test Teardown

[1]E2E_TL_Reset_with_HWF_deletion_sleeping_cell_check
    [Tags]    E2E_slCell
    [Setup]    SISO Coam Test Setup
    Log To Console    \ntotal times:${total_loops}
    General_Stability_Test_Case    case_name=slCell_Reset_with_HWF_deletion    times=${total_loops}    pass=${total_loops}
    ...    common_setup_each_time=${False}   run_total_times=${True}    with_recovery=${False}
    #[Teardown]    SISO Coam Test Teardown
    [Teardown]    Run Keywords    Recovery ENV after HWF reset

[1]E2E_TL_SW_upgrade_rollback_with_sleeping_cell_check
    [Tags]    E2E_slCell    SW_upgrade_rollback
    [Setup]    SISO Coam Test Setup
    Log To Console    \ntotal times:${total_loops}
    General_Stability_Test_Case    case_name=slCell_SW_upgrade_rollback    times=${total_loops}    pass=${total_loops}
    ...    common_setup_each_time=${False}   run_total_times=${True}    with_recovery=${False}
    #[Teardown]    SISO Coam Test Teardown

*** Keywords ***


*** Settings ***
Documentation
...   Test suite for regression testing of feature CB010970_D
...   author: Mateusz Bugaj, Daniel Kulaga, Pawel Grabania
...   contact: mateusz.bugaj@nokia.com, daniel.kulaga@nokia.com, pawel.grabania@nokia.com

Resource     ./resources/common_keywords.robot
Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource     testsuite/Krakow/resources/RAN_VRF_KRK5/robot/call_procedure/call_procedure_keywords.robot
Resource     testsuite/Krakow/resources/RAN_VRF_KRK5/robot/snapshot_validation/snapshot_validation_keywords.robot

Library      taf.ue     WITH NAME   ue

Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Variables    ./resources/common_variables.py

Force Tags    CA_VRF_KRK

Suite Setup       common_keywords.Common Suite Setup With OnAir Test Line Preparation
...               list_of_additional_allowed_alarms=${CUSTOM_ALLOWED_ALARMS_DURING_TL_PREPARATION}
...               swconfig_from_path=testsuite/Krakow/SISO/regression/RAN_PZ_KRK5/CB010970_D/resources/swconfig.txt
Suite Teardown    common_setups_and_teardowns.Common Suite Teardown
Test Setup        Custom Test Setup
Test Teardown     common_setups_and_teardowns.Common Postconditions With Restore Configuration If Test Failed

*** Variables ***
@{CellIDs}      NRCELL-1   NRCELL-2
@{SuperCellID}      NRCELL-1_S
${capabilities}      REAL_UE
${deviation}       20%
${IS_ASIR_CONFIGURATION}=   ${True}
@{CUSTOM_ALLOWED_ALARMS_DURING_TL_PREPARATION}      61673   61675
${test_config}   Supercell
${prefix_tag}   None

*** Test Cases ***

[1][1.0] CB010970_D3_ASiR-pRRH_discovery_by_ASiR-sHUB
    [Setup]    Actions before test      alarms_for_test=${ADDITIONAL_ALARMS_FOR_TESTS}[discovery]
    Configuration Reset Of The AsirWebEM
    [Teardown]    Actions after test

[1][1.0] CB010970_D3_General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
    [Setup]    Actions before test    alarms_for_test=${ADDITIONAL_ALARMS_FOR_TESTS}[Snapshot]
    Verify snapshot
    [Teardown]    Actions after test

[1][1.0] CB010970_D3_Manual_SiSo_CALL_L3_data_call
    [Setup]    Actions before test  alarms_for_test=${ADDITIONAL_ALARMS_FOR_TESTS}[L3_call]
    ${traffic_matrix}    Convert To Dictionary    ${TPUT_MATRIX}
    Call To Selected Cells    cells_list=${CellIDs}    duration=360s    traffic_matrix=${traffic_matrix}
    ...                       ue_capabilities=${capabilities}    deviation=5%  reboot_ue=${False}
    [Teardown]    Actions after test

[1][1.0] CB010970_D3_reset_pRRH_via_ASiR_Webem
    [Setup]    Actions before test    alarms_for_test=${ADDITIONAL_ALARMS_FOR_TESTS}[pRRH_Reset]
    SISO reset all pRRHs
    ${traffic_matrix}    Convert To Dictionary    ${TPUT_MATRIX}
    Call To Selected Cells    cells_list=@{SuperCellID}    duration=120s    traffic_matrix=${traffic_matrix}
    ...                       ue_capabilities=${capabilities}    deviation=20%  reboot_ue=${False}
    [Teardown]    Actions after test

[1][1.0] CB010970_D3_TDD FR1_50Mhz_configuration
    [Setup]    Actions before test    alarms_for_test=${ADDITIONAL_ALARMS_FOR_TESTS}[ASiR_HUB_lock]
    ${traffic_matrix}    Convert To Dictionary    ${TPUT_MATRIX}
    Call To Selected Cells    cells_list=@{CellIDs}    duration=120s    traffic_matrix=${traffic_matrix}
    ...                       ue_capabilities=${capabilities}    deviation=20%  reboot_ue=${False}
    [Teardown]    Actions after test

[1][1.0] CB010970_D3_TDD FR1_50Mhz_configuration_supercell
    [Setup]    Actions before test  alarms_for_test=${ADDITIONAL_ALARMS_FOR_TESTS}[supercell]
    Run Keyword If    '${prefix_tag}' == 'None'               Set Global Variable    ${current_config}    ${prefix_tag}
    common_setups_and_teardowns.Perform Full Commissioning and Wait for onAir   ${test_config}  asir_hub=${True}
    ${traffic_matrix}    Convert To Dictionary    ${TPUT_MATRIX}
    Call To Selected Cells    cells_list=@{SuperCellID}    duration=120s    traffic_matrix=${traffic_matrix}
    ...                       ue_capabilities=${capabilities}    deviation=20%  reboot_ue=${False}
    common_setups_and_teardowns.Perform Full Commissioning and Wait for onAir      prefix_tag=${prefix_tag}  asir_hub=${True}
    [Teardown]    Actions after test

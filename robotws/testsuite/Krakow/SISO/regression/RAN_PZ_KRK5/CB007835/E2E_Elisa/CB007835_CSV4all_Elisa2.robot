*** Settings ***
Documentation
...                 author: Krystian Zapotoczny
...                 contact: krystian.zapotoczny@nokia.com
...                 Test suite for Elisa CDRT Tests:

Library      String
Library      taf.rfrl.utilities.cloud_manager.artifacts
Library      taf/rfrl/csv4all/CSV4AllTestCases.py
Library      taf.ue   WITH NAME   ue
Library      testsuite/Krakow/resources/UUF/get_uuf_builds.py
Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource     testsuite/Krakow/resources/RAN_VRF_KRK5/robot/call_procedure/call_procedure_keywords.robot
Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Variables    testsuite/Krakow/SISO/regression/RAN_PZ_KRK5/CB007835/E2E_Elisa/resources/variables.py
Variables    ./resources/tput_variables.py

Force Tags    STATE_SW_UPLOADED    CDRT

Suite Setup       Custom Suite Setup
Suite Teardown    common_setups_and_teardowns.Common Suite Teardown

Test Setup        Custom Test Setup
Test Teardown     common_setups_and_teardowns.Common Postconditions With Restore Configuration If Test Failed


*** Variables ***
${SOURCE_SW}                                    ${None}
${TARGET_SW}                                    ${None}
${CUSTOMERS_LIST}    Elisa
${UPDATE_TEST_ITERATION}       5
${SITE_RESET_TEST_ITERATION}   30
@{CUSTOM_ALARMS}                                @{EMPTY}
${CUSTOM_ALLOWED_ALARMS_DURING_TL_PREPARATION}  7220
${SYSLOG_IGNORED_PRINTS}                        ${None}

${SHOULD_BE_REPORTED}      True

${RP_CA}                   VRF_SiSo
${RP_LOCATION}             VRF_KRK
${RP_ORGANIZATION}         VRF_KRK_T06


&{NODE1}                    testline_object=${tl.gnbs[0]}
...                         source_sw=${SOURCE_SW}
...                         target_sw=${TARGET_SW}
...                         custom_allowed_alarms=${CUSTOM_ALARMS}
...                         syslog_ignored_prints=${SYSLOG_IGNORED_PRINTS}
@{NODES}                    ${NODE1}

${ue_capabilities}      REAL_UE
@{CellIDs}      NRCELL-1_DL    NRCELL-1_UL

*** Test Cases ***

E2E_TL_SW_Upgrade_Rollback_with_OAM_KPI
    [Timeout]    96h

    Set To Dictionary    ${NODE1}    source_sw    ${SOURCE_SW}
    Set To Dictionary    ${NODE1}    target_sw    ${TARGET_SW}

    E2E TL SW UPGRADE ROLLBACK WITH OAM KPI    ${NODES}  ${NODE1}  ${UPDATE_TEST_ITERATION}
    ...         report=${SHOULD_BE_REPORTED}
    ...         customers_list=@{CUSTOMERS_LIST}
    ...         qc_domain=${kpi_qc_ids['qc_domain']}
    ...         qc_id=${kpi_qc_ids['qc_upgrade']}
    ...         qc_project=${kpi_qc_ids['qc_project']}
    ...         use_external_storage=False
    ...         download_path=/home/ute/UUF_SW
    ...         use_testpackage=False
    ...         restore_to_target_sw=True
    ...         sw_build=${TARGET_SW}
    [Teardown]    Custom Test Teardown

E2E_TL_Activation_Reset_with_OAM_KPI
    [Timeout]    96h

    gnbbbu.Disconnect
    E2E TL ACTIVATION RESET TEST    ${NODES}  ${NODE1}  ${SITE_RESET_TEST_ITERATION}
    ...          report=${SHOULD_BE_REPORTED}
    ...          qc_domain=${kpi_qc_ids['qc_domain']}
    ...          qc_project=${kpi_qc_ids['qc_project']}
    ...          qc_id=${kpi_qc_ids['qc_activation_reset']}
    ...          sw_build=${TARGET_SW}
    ...          customers_list=@{CUSTOMERS_LIST}
    ...          l3_call_method=L3_data_call

E2E_TL_Delta_Commissioning_With_NR_Rat_Reset
    [Timeout]   24h

    gnbbbu.Disconnect
    E2E TL DELTA COMMISSIONING WITH ONLINE PARAMETER MODIFICATION    ${NODES}  ${NODE1}  1
    ...          delta=${DELTA_5G}
    ...          report=${SHOULD_BE_REPORTED}
    ...          customers_list=@{CUSTOMERS_LIST}
    ...          qc_domain=${kpi_qc_ids['qc_domain']}
    ...          qc_id=${kpi_qc_ids['qc_comm_rat_reset']}
    ...          qc_project=${kpi_qc_ids['qc_project']}
    ...          sw_build=${TARGET_SW}

E2E_TL_Capacity_Module_Reset_with_OAM_KPI
    [Timeout]   24h

    gnbbbu.Disconnect
    E2E TL CAPACITY MODULE RESET WITH OAM KPI    ${NODES}  ${NODE1}  10
    ...          report=${SHOULD_BE_REPORTED}
    ...          customers_list=@{CUSTOMERS_LIST}
    ...          qc_domain=${kpi_qc_ids['qc_domain']}
    ...          qc_id=${kpi_qc_ids['qc_capacity_reset']}
    ...          qc_project=${kpi_qc_ids['qc_project']}
    ...          sw_build=${TARGET_SW}

E2E_TL_RU_Reset_with_OAM_KPI
    [Timeout]   24h

    gnbbbu.Disconnect
    E2E TL RU RESET WITH OAM KPI    ${NODES}  ${NODE1}  20
    ...          report=${SHOULD_BE_REPORTED}
    ...          customers_list=@{CUSTOMERS_LIST}
    ...          qc_domain=${kpi_qc_ids['qc_domain']}
    ...          qc_id=${kpi_qc_ids['qc_ru_reset']}
    ...          qc_project=${kpi_qc_ids['qc_project']}
    ...          sw_build=${TARGET_SW}

E2E_TL_Cell_Block_Unblock_NR_with_OAM_KPI
    [Timeout]   24h

    gnbbbu.Disconnect
    E2E TL CELL BLOCK UNBLOCK NR WITH OAM KPI    ${NODES}  ${NODE1}  5
    ...          report=${SHOULD_BE_REPORTED}
    ...          customers_list=@{CUSTOMERS_LIST}
    ...          qc_domain=${kpi_qc_ids['qc_domain']}
    ...          qc_id=${kpi_qc_ids['qc_cell_block_unblock']}
    ...          qc_project=${kpi_qc_ids['qc_project']}
    ...          sw_build=${TARGET_SW}

E2E_TL_Cell_Lock_Unlock_NR_with_OAM_KPI
    [Timeout]   24h

    gnbbbu.Disconnect
    E2E TL CELL LOCK UNLOCK NR WITH OAM KPI    ${NODES}  ${NODE1}  5
    ...          report=${SHOULD_BE_REPORTED}
    ...          customers_list=@{CUSTOMERS_LIST}
    ...          qc_domain=${kpi_qc_ids['qc_domain']}
    ...          qc_id=${kpi_qc_ids['qc_cell_lock_unlock']}
    ...          qc_project=${kpi_qc_ids['qc_project']}
    ...          sw_build=${TARGET_SW}

CB007834-5G-11_Commisioning_with_site_reset
    [Timeout]   24h

    gnbbbu.Disconnect
    E2E TL DELTA COMMISSIONING WITH SITE RESET REQUIRED    ${NODES}  ${NODE1}  1
    ...          report=${SHOULD_BE_REPORTED}
    ...          customers_list=@{CUSTOMERS_LIST}
    ...          qc_domain=${kpi_qc_ids['qc_domain']}
    ...          qc_id=${kpi_qc_ids['qc_comm_reset']}
    ...          qc_project=${kpi_qc_ids['qc_project']}
    ...          sw_build=${TARGET_SW}

CB007834-5G-12_Commisioning_online_change
    [Timeout]   24h

    gnbbbu.Disconnect
    E2E TL DELTA COMMISSIONING WITH ONLINE PARAMETER MODIFICATION    ${NODES}  ${NODE1}  1
    ...          report=${SHOULD_BE_REPORTED}
    ...          customers_list=@{CUSTOMERS_LIST}
    ...          qc_domain=${kpi_qc_ids['qc_domain']}
    ...          qc_id=${kpi_qc_ids['qc_comm_online_change']}
    ...          qc_project=${kpi_qc_ids['qc_project']}
    ...          sw_build=${TARGET_SW}

*** Keywords ***
Custom Suite Setup
    Common Suite Setup With OnAir Test Line Preparation
    ...                         increase_timeout_for_update_sw=${1800}
    ...                         list_of_additional_allowed_alarms=${CUSTOM_ALLOWED_ALARMS_DURING_TL_PREPARATION}

    ${SOURCE_SW} =          IF    '${SOURCE_SW}'=='${None}'         Get CM Source Build    ELSE    Set Variable  ${SOURCE_SW}
    ${TARGET_SW} =          IF    '${TARGET_SW}'=='${None}'         Get Target Build       ELSE    Set Variable  ${TARGET_SW}
    @{CUSTOMERS_LIST} =     IF    '${CUSTOMERS_LIST}'!='${None}'    Split String    ${CUSTOMERS_LIST}    ,    ELSE    Create List    Generic

    Set Global Variable  ${SOURCE_SW}
    Set Global Variable  ${TARGET_SW}
    Set Global Variable  @{CUSTOMERS_LIST}

Custom Test Setup
    common_setups_and_teardowns.Common Preconditions
    ...    collect_syslog=${False}
    ...    collect_ru_console_log=${False}
    Run Keyword And Ignore Error    Remove Directory         path=/home/ute/.ute-ca/cache/bts/    recursive=${True}
    Run Keyword And Ignore Error    Remove Directory         path=/home/ute/UUF_SW/    recursive=${True}

Custom Test Teardown
    gnbbbu.connect    force=${True}
    common_setups_and_teardowns.Common Postconditions With Restore Configuration If Test Failed
    ...    collect_snapshot_from_ru=${False}

Remove Dirs
    [Arguments]    @{directory_path}
    FOR    ${dir}    IN    @{directory_path}
        ${status}=    Run Keyword And Return Status    Directory Should Exist    ${dir}
        Run Keyword If    ${status}    Remove Directory    ${dir}    force=True
    END

L3_data_call
    [Arguments]    @{dummy}
    ${traffic_matrix}    Convert To Dictionary    ${TPUT_MATRIX}
    Call To Selected Cells    cells_list=${CellIDs}    duration=300s    deviation=5%    reboot_ue=${False}
    ...                       ue_capabilities=${ue_capabilities}    traffic_matrix=${traffic_matrix}

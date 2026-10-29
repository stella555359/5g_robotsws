*** Settings ***
Documentation
...                 author: Lukasz Klosinski
...                 contact: lukasz.klosinski@nokia.com
...                 Test suite for basic CSV4ALL Tests in loop:

Library             taf/rfrl/csv4all/CSV4AllTestCases.py
Resource            taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables           testsuite/Krakow/SISO/regression/RAN_PZ_KRK5/CB007835/E2E_Elisa/resources/variables.py

Suite Setup       Common Suite Setup With OnAir Test Line Preparation
...               increase_timeout_for_update_sw=3600
Suite Teardown    Common Suite Teardown

Test Setup        Common Preconditions
Test Teardown     Common Postconditions With Restore Configuration If Test Failed

*** Variables ***
@{CUSTOMERS_LIST}=      Elisa

${SOURCE_SW}               None
${TARGET_SW}                None
${UPDATE_TEST_ITERATION}            5
${SITE_RESET_TEST_ITERATION}        30

${SHOULD_BE_REPORTED}       True

${RP_CA}   VRF_SiSo
${RP_LOCATION}    VRF_KRK
${RP_ORGANIZATION}    VRF_KRK_T05

&{NODE1}                    testline_object=${tl.gnbs[0]}
...                         source_sw=${SOURCE_SW}
...                         target_sw=${TARGET_SW}
@{NODES}                    ${NODE1}

*** Test Cases ***
E2E_TL_SW_Upgrade_Rollback_with_OAM_KPI
    [Timeout]   96h
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

E2E_TL_Site_Reset_without_HWF_with_OAM_KPI
    [Timeout]   96h
    E2E TL SITE RESET WITHOUT HWF WITH OAM KPI    ${NODES}  ${NODE1}   ${SITE_RESET_TEST_ITERATION}
    ...         report=${SHOULD_BE_REPORTED}
    ...         customers_list=@{CUSTOMERS_LIST}
    ...         qc_domain=${kpi_qc_ids['qc_domain']}
    ...         qc_id=${kpi_qc_ids['qc_site_reset']}
    ...         qc_project=${kpi_qc_ids['qc_project']}

E2E_TL_Capacity_Module_Reset_with_OAM_KPI
    [Timeout]   24h
    E2E TL CAPACITY MODULE RESET WITH OAM KPI    ${NODES}  ${NODE1}  10
    ...         report=${SHOULD_BE_REPORTED}
    ...          customers_list=@{CUSTOMERS_LIST}
    ...          qc_domain=${kpi_qc_ids['qc_domain']}
    ...          qc_id=${kpi_qc_ids['qc_capacity_reset']}
    ...          qc_project=${kpi_qc_ids['qc_project']}

E2E_TL_RU_Reset_with_OAM_KPI
    [Timeout]   24h
    E2E TL RU RESET WITH OAM KPI    ${NODES}  ${NODE1}  20
    ...         report=${SHOULD_BE_REPORTED}
    ...          customers_list=@{CUSTOMERS_LIST}
    ...          qc_domain=${kpi_qc_ids['qc_domain']}
    ...          qc_id=${kpi_qc_ids['qc_ru_reset']}
    ...          qc_project=${kpi_qc_ids['qc_project']}

E2E_TL_Cell_Block_Unblock_NR_with_OAM_KPI
    [Timeout]   24h
    E2E TL CELL BLOCK UNBLOCK NR WITH OAM KPI    ${NODES}  ${NODE1}  5
    ...          report=${SHOULD_BE_REPORTED}
    ...          customers_list=@{CUSTOMERS_LIST}
    ...          qc_domain=${kpi_qc_ids['qc_domain']}
    ...          qc_id=${kpi_qc_ids['qc_cell_block_unblock']}
    ...          qc_project=${kpi_qc_ids['qc_project']}

E2E_TL_Cell_Lock_Unlock_NR_with_OAM_KPI
    [Timeout]   24h
    E2E TL CELL LOCK UNLOCK NR WITH OAM KPI    ${NODES}  ${NODE1}  5
    ...         report=${SHOULD_BE_REPORTED}
    ...          customers_list=@{CUSTOMERS_LIST}
    ...          qc_domain=${kpi_qc_ids['qc_domain']}
    ...          qc_id=${kpi_qc_ids['qc_cell_lock_unlock']}
    ...          qc_project=${kpi_qc_ids['qc_project']}

E2E_TL_Delta_Commissioning_With_NR_Rat_Reset
    [Timeout]   24h
    E2E TL DELTA COMMISSIONING WITH ONLINE PARAMETER MODIFICATION    ${NODES}  ${NODE1}  1
    ...          delta=${DELTA_5G}
    ...          report=${SHOULD_BE_REPORTED}
    ...          customers_list=@{CUSTOMERS_LIST}
    ...          qc_domain=${kpi_qc_ids['qc_domain']}
    ...          qc_id=${kpi_qc_ids['qc_comm_rat_reset']}
    ...          qc_project=${kpi_qc_ids['qc_project']}

E2E_TL_Delta_Commissioning_With_Site_Reset_Required
    [Timeout]   24h
    E2E TL DELTA COMMISSIONING WITH SITE RESET REQUIRED    ${NODES}  ${NODE1}  1
    ...          report=${SHOULD_BE_REPORTED}
    ...          customers_list=@{CUSTOMERS_LIST}
    ...          qc_domain=${kpi_qc_ids['qc_domain']}
    ...          qc_id=${kpi_qc_ids['qc_comm_reset']}
    ...          qc_project=${kpi_qc_ids['qc_project']}

E2E_TL_Delta_Commissioning_With_Online_Parameter_Modification
    [Timeout]   24h
    E2E TL DELTA COMMISSIONING WITH ONLINE PARAMETER MODIFICATION    ${NODES}  ${NODE1}  1
    ...          report=${SHOULD_BE_REPORTED}
    ...          customers_list=@{CUSTOMERS_LIST}
    ...          qc_domain=${kpi_qc_ids['qc_domain']}
    ...          qc_id=${kpi_qc_ids['qc_comm_online_change']}
    ...          qc_project=${kpi_qc_ids['qc_project']}

*** Settings ***
Documentation
...   Generic suite for  testing UUF
...   author: Wioleta Swies
...   contact: wioleta.swies@nokia.com

Library      String
Library      taf.rfrl.csv4all.CSV4AllTestCases
Library      taf.rfrl.utilities.cloud_manager.artifacts
Library      testsuite/Krakow/resources/UUF/get_uuf_builds.py
Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Resource     ./resources/keywords.robot

Suite Setup       Run Keywords    Common Suite Setup    AND   Add Scout Name
Suite Teardown    common_setups_and_teardowns.Common Suite Teardown

Test Setup        Custom Test Setup
Test Teardown     common_setups_and_teardowns.Common Postconditions With Restore Configuration If Test Failed

*** Variables ***
${SOURCE_SW}                        SBTS25R2_ENB_0000_000297_000069
${TARGET_SW}                        SBTS00_ENB_9999_250224_000011

@{additional_allowed_alarms}        ${61648}    ${4459}    ${8000}    ${8150}
@{CUSTOM_ALARMS}                    61648    7115    4420    4123    4125    8150    4459    8000    4459


&{NODE1}                            testline_object=${tl.gnbs[0]}
...                                 source_sw=${SOURCE_SW}
...                                 target_sw=${TARGET_SW}
...                                 custom_allowed_alarms=${CUSTOM_ALARMS}

@{NODES}                            ${NODE1}

${UPDATE_TEST_ITERATION}                     5
${ACTIVATION_RESET_TEST_ITERATION}           20
${SITE_RESET_TEST_ITERATION_25R3}            30
${SITE_RESET_TEST_INTERATION}                10
${BBMOD_RESET_TEST_ITERATION}                10
${SHUB_RESET_TEST_ITERATION}                 20
${CELL_LOCK_UNLOCK_TEST_ITERATION}           3
${CELL_BLOCK_UNBLOCK_TEST_ITERATION}         3
${Delta_Commissioning}                       1

@{CUSTOMERS_LIST}                   TMO US
${QC_DOMAIN}                        MN_RAN
${QC_PROJECT}                       RAN_VRF

${RP_CA}                            VRF_OAM
${RP_ORGANIZATION}                  VRF_KRK_T07
${RP_LOCATION}                      VRF_KRK


*** Test Cases ***
E2E_TL_SW_upgrade_rollback_with_OAM_KPI_LTE
    [Tags]    UUF4ALL    tc01
    ${QC_ID}=             bts_data.Get Qc Ids   ${TARGET_SW}
    E2E TL SW UPGRADE ROLLBACK WITH OAM KPI
    ...                                     nodes_details=${NODES}
    ...                                     test_nodes_details=${NODE1}
    ...                                     iterations_per_node=${UPDATE_TEST_ITERATION}
    ...                                     report=${True}
    ...                                     qc_domain=${QC_DOMAIN}
    ...                                     qc_project=${QC_PROJECT}
    ...                                     qc_id=${QC_ID['qc_upgrade']}
    ...                                     sw_build=${TARGET_SW}
    ...                                     customers_list=@{CUSTOMERS_LIST}
    ...                                     restore_to_target_sw=${True}
    [Teardown]    Custom Test Teardown

E2E_TL_Site_reset_without_HWF_with_OAM_KPI_LTE
    [Timeout]    96h
    [Tags]    UUF4ALL    25R3
    gnbbbu.Disconnect
    ${QC_ID}=                 bts_data.Get Qc Ids   ${TARGET_SW}
    E2E TL SITE RESET WITHOUT HWF WITH OAM KPI
    ...                                     nodes_details=${NODES}
    ...                                     test_nodes_details=${NODE1}
    ...                                     iterations_per_node=${SITE_RESET_TEST_ITERATION_25R3}
    ...                                     report=${True}
    ...                                     qc_domain=${QC_DOMAIN}
    ...                                     qc_project=${QC_PROJECT}
    ...                                     qc_id=${QC_ID['qc_site_reset']}
    ...                                     sw_build=${TARGET_SW}
    ...                                     customers_list=@{CUSTOMERS_LIST}

E2E_TL_Activation_Reset_with_OAM_KPI
    [Timeout]    96h
    [Tags]    uuf    activation_reset    26R1
    gnbbbu.Disconnect
    ${QC_ID}=                 bts_data.Get Qc Ids   ${TARGET_SW}
    E2E TL ACTIVATION RESET TEST
    ...                                     nodes_details=${NODES}
    ...                                     test_nodes_details=${NODE1}
    ...                                     iterations_per_node=${ACTIVATION_RESET_TEST_ITERATION}
    ...                                     report=${False}
    ...                                     qc_domain=${QC_DOMAIN}
    ...                                     qc_project=${QC_PROJECT}
    ...                                     qc_id=${QC_ID['qc_activation_reset']}
    ...                                     sw_build=${TARGET_SW}
    ...                                     customers_list=@{CUSTOMERS_LIST}

E2E_TL_Site_Reset_with_OAM_KPI_LTE
    [Timeout]    96h
    [Tags]    site_reset    26R1
    gnbbbu.Disconnect
    E2E TL SITE RESET WITH OAM KPI
    ...                                     nodes_details=${NODES}
    ...                                     test_nodes_details=${NODE1}
    ...                                     iterations_per_node=${SITE_RESET_TEST_ITERATION}
    ...                                     report=${False}
    ...                                     sw_build=${TARGET_SW}
    ...                                     customers_list=@{CUSTOMERS_LIST}

E2E_TL_RU_Reset_with_OAM_KPI_LTE
    [Tags]    tc03
    ${site_reset_results}    Run Reset Hub In Loop Via ASiR Cli    iterations=${1}
    ...                                                            target=${TARGETS}
    ...                                                            hub_id=${1}
    GnbAsir.Verify Only Allowed Alarms Are Active    allowed_alarms=${additional_allowed_alarms}

E2E_TL_Capacity_Module_Reset_with_OAM_KPI_LTE
    [Timeout]    96h
    [Tags]    tc04
    E2E TL CAPACITY MODULE RESET WITH OAM KPI
    ...                                     nodes_details=${NODES}
    ...                                     test_nodes_details=${NODE1}
    ...                                     iterations_per_node=${BBMOD_RESET_TEST_ITERATION}
    ...                                     report=${False}

E2E_TL_Cell_Lock_Unlock_LTE_with_OAM_KPI
    [Tags]    tc05
    E2E TL CELL LOCK UNLOCK LTE WITH OAM KPI
    ...                                     nodes_details=${NODES}
    ...                                     test_nodes_details=${NODE1}
    ...                                     iterations_per_node=${CELL_LOCK_UNLOCK_TEST_ITERATION}
    ...                                     report=${False}

E2E_TL_Cell_Block_Unblock_LTE_with_OAM_KPI
    [Timeout]   24h
    [Tags]    tc06
    E2E TL CELL BLOCK UNBLOCK LTE WITH OAM KPI
    ...                                     nodes_details=${NODES}
    ...                                     test_nodes_details=${NODE1}
    ...                                     iterations_per_node=${CELL_BLOCK_UNBLOCK_TEST_ITERATION}
    ...                                     report=${False}

E2E_TL_Delta_Commissioning_With_Online_Parameter_Modification
    [Tags]    tc07
    ${DELTA_PARAM}=    Get Online Parameters Delta
    E2E TL DELTA COMMISSIONING WITH ONLINE PARAMETER MODIFICATION
    ...                                     nodes_details=${NODES}
    ...                                     test_nodes_details=${NODE1}
    ...                                     iterations_per_node=${Delta_Commissioning}
    ...                                     delta=${DELTA_PARAM}
    ...                                     report=${False}

E2E_TL_Delta_Commissioning_With_Site_Reset_Required
    [Tags]    tc08
    ${DELTA_PARAM}=    Get Site Reset Delta
    E2E TL DELTA COMMISSIONING WITH SITE RESET REQUIRED
    ...                                     nodes_details=${NODES}
    ...                                     test_nodes_details=${NODE1}
    ...                                     iterations_per_node=${Delta_Commissioning}
    ...                                     delta=${DELTA_PARAM}
    ...                                     report=${False}

E2E_TL_Delta_Commissioning_With_LTE_Rat_Reset
    [Tags]    tc09
    ${DELTA_PARAM}=    Get LTE Rat Reset Delta
    E2E TL DELTA COMMISSIONING WITH ONLINE PARAMETER MODIFICATION
    ...                                     nodes_details=${NODES}
    ...                                     test_nodes_details=${NODE1}
    ...                                     iterations_per_node=${Delta_Commissioning}
    ...                                     delta=${DELTA_PARAM}
    ...                                     report=${False}

*** Keywords ***
Remove Dirs
    [Arguments]    @{directory_path}
    FOR    ${dir}    IN    @{directory_path}
        ${status}=    Run Keyword And Return Status    Directory Should Exist    ${dir}
        Run Keyword If    ${status}    Remove Directory    ${dir}    force=True
    END

Custom Test Setup
    common_setups_and_teardowns.Common Preconditions    collect_syslog=${False}
    Remove Dirs       directory_path=/home/ute/.ute-ca/cache/bts/

Custom Test Teardown
    gnbbbu.connect    force=${True}
    common_setups_and_teardowns.Common Postconditions With Restore Configuration If Test Failed

Add Scout Name
    ${TESTLINE_SCOUT_NAME}    Evaluate    bts_data.get_scout_bts_name()
    Set To Dictionary    ${NODE1}    testline_scout_name    ${TESTLINE_SCOUT_NAME}

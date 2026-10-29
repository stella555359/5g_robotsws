*** Settings ***
Documentation
...          author: Mateusz Iwankiewicz
...          maintainer: Matuesz Iwankiewicz
...          contact:  mateusz.iwankiewicz@nokia.com
...          description: Universal testsuite for CSV4ALL testcases.

Library      String
Library      DateTime
Library      OperatingSystem
Library      taf.rfrl.bts.commissioning     WITH NAME    commissioning
Library      testsuite/Krakow/resources/UUF/upgrade_and_commission_bts.py
Library      taf.rfrl.bts.devices.du.cell_operations.GnbCellOperations
...          WITH NAME    gnbcell
Library      taf.rfrl.bts.devices.ru.ru_operations.GnbRuOperations
...          WITH NAME    gnbru
Library      taf.rfrl.csv4all.CSV4AllTestCases
Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py

Force Tags    CA_VRF_KRK    QCD_MN_RAN    QCP_RAN_VRF

Suite Setup       Custom Suite Setup
Suite Teardown    common_setups_and_teardowns.Common Suite Teardown

Test Setup        Custom Test Setup
Test Teardown     common_setups_and_teardowns.Common Postconditions With Restore Configuration If Test Failed

*** Variables ***
############### OAM and UUF ###############
@{CUSTOMERS_LIST}              Generic
${QC_DOMAIN}                   MN_RAN
${QC_PROJECT}                  RAN_VRF
${QC_ID}                       ${None}
${TOPOLOGY}                    ${None}
${RUNS_OF_UUF_UPGRADE}         ${10}
${RUNS_OF_RESET}               ${30}
${RUNS_OF_DELTA}               ${10}
${TEST_ITERATION}              ${30}
${SOURCE_SW}                   ${None}
${TARGET_SW}                   ${None}
@{CUSTOM_ALARMS}               @{EMPTY}
@{CRITICAL_ALARMS}             0010  0016  1806  1868  4341  4352  4383
${SHOULD_BE_REPORTED}          ${True}
${EMAIL_RECIPIENTS}            ${None}
${RP_CA}                       VRF_SiSo
${RP_ORGANIZATION}             VRF_KRK_T08
${RP_LOCATION}                 VRF_KRK

&{NODE1}                       testline_object=${tl.gnbs[0]}
...                            source_sw=${SOURCE_SW}
...                            target_sw=${TARGET_SW}
...                            custom_allowed_alarms=@{CUSTOM_ALARMS}
...                            critical_alarms=@{CRITICAL_ALARMS}

@{NODES}                       ${NODE1}

########### Testline Preparation ###########
${RUN_SUITE_SETUP}                              ${True}
@{CUSTOM_ALLOWED_ALARMS_DURING_TL_PREPARATION}  Fault signature for crash or failure
...                                             BTS Reset Cause
...                                             No X2 link available
...                                             No X2 link available for a specific LTEENB
${SCF_PREFIX_TAG}                               ${None}
${SWCONFIG_PATH}                                ${None}

*** Test Cases ***
E2E_TL_SW_Upgrade_Rollback_with_OAM_KPI
    [Timeout]    96h
    E2E TL SW UPGRADE ROLLBACK WITH OAM KPI
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODE1}
    ...    topology=${TOPOLOGY}
    ...    iterations_per_node=${RUNS_OF_UUF_UPGRADE}
    ...    customers_list=@{CUSTOMERS_LIST}
    ...    sw_build=${TARGET_SW}
    ...    restore_to_target_sw=${True}
    ...    report=${SHOULD_BE_REPORTED}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_project=${QC_PROJECT}
    ...    qc_id=${QC_ID}

E2E_TL_Capacity_Module_Reset_with_OAM_KPI
    [Timeout]    96h
    E2E TL CAPACITY MODULE RESET WITH OAM KPI
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODE1}
    ...    topology=${TOPOLOGY}
    ...    iterations_per_node=${TEST_ITERATION}
    ...    customers_list=@{CUSTOMERS_LIST}
    ...    report=${SHOULD_BE_REPORTED}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_project=${QC_PROJECT}
    ...    qc_id=${QC_ID}

E2E_TL_Capacity_Module_Lock_Unlock
    [Timeout]    96h
    E2E TL CAPACITY MODULE LOCK UNLOCK
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODE1}
    ...    topology=${TOPOLOGY}
    ...    iterations_per_node=${TEST_ITERATION}
    ...    customers_list=@{CUSTOMERS_LIST}
    ...    report=${SHOULD_BE_REPORTED}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_project=${QC_PROJECT}
    ...    qc_id=${QC_ID}

E2E_TL_RU_Reset_with_OAM_KPI
    [Timeout]    96h
    E2E TL RU RESET WITH OAM KPI
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODE1}
    ...    topology=${TOPOLOGY}
    ...    iterations_per_node=${TEST_ITERATION}
    ...    customers_list=@{CUSTOMERS_LIST}
    ...    report=${SHOULD_BE_REPORTED}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_project=${QC_PROJECT}
    ...    qc_id=${QC_ID}

E2E_TL_RU_Lock_Unlock
    [Timeout]    96h
    E2E TL RU LOCK UNLOCK
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODE1}
    ...    topology=${TOPOLOGY}
    ...    iterations_per_node=${TEST_ITERATION}
    ...    customers_list=@{CUSTOMERS_LIST}
    ...    report=${SHOULD_BE_REPORTED}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_project=${QC_PROJECT}
    ...    qc_id=${QC_ID}

E2E_TL_Cell_Lock_Unlock_NR_with_OAM_KPI
    [Timeout]    96h
    E2E TL CELL LOCK UNLOCK NR WITH OAM KPI
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODE1}
    ...    topology=${TOPOLOGY}
    ...    iterations_per_node=${TEST_ITERATION}
    ...    customers_list=@{CUSTOMERS_LIST}
    ...    report=${SHOULD_BE_REPORTED}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_project=${QC_PROJECT}
    ...    qc_id=${QC_ID}

E2E_TL_Cell_Lock_Unlock_LTE_with_OAM_KPI
    [Timeout]    96h
    E2E TL CELL LOCK UNLOCK LTE WITH OAM KPI
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODE1}
    ...    topology=${TOPOLOGY}
    ...    iterations_per_node=${TEST_ITERATION}
    ...    customers_list=@{CUSTOMERS_LIST}
    ...    report=${SHOULD_BE_REPORTED}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_project=${QC_PROJECT}
    ...    qc_id=${QC_ID}

E2E_TL_Cell_Block_Unblock_LTE_with_OAM_KPI
    [Timeout]    96h
    E2E TL CELL BLOCK UNBLOCK LTE WITH OAM KPI
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODE1}
    ...    topology=${TOPOLOGY}
    ...    iterations_per_node=${TEST_ITERATION}
    ...    customers_list=@{CUSTOMERS_LIST}
    ...    report=${SHOULD_BE_REPORTED}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_project=${QC_PROJECT}
    ...    qc_id=${QC_ID}

E2E_TL_Cell_Block_Unblock_NR_with_OAM_KPI
    [Timeout]    96h
    E2E TL CELL BLOCK UNBLOCK NR WITH OAM KPI
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODE1}
    ...    topology=${TOPOLOGY}
    ...    iterations_per_node=${TEST_ITERATION}
    ...    customers_list=@{CUSTOMERS_LIST}
    ...    report=${SHOULD_BE_REPORTED}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_project=${QC_PROJECT}
    ...    qc_id=${QC_ID}

E2E_TL_Delta_Commissioning_With_Online_Parameter_Modification
    [Timeout]    96h
    E2E TL DELTA COMMISSIONING WITH ONLINE PARAMETER MODIFICATION
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODE1}
    ...    topology=${TOPOLOGY}
    ...    iterations_per_node=${RUNS_OF_DELTA}
    ...    customers_list=@{CUSTOMERS_LIST}
    ...    report=${SHOULD_BE_REPORTED}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_project=${QC_PROJECT}
    ...    qc_id=${QC_ID}

E2E_TL_Delta_Commissioning_With_Site_Reset_Required
    [Timeout]    96h
    E2E TL DELTA COMMISSIONING WITH SITE RESET REQUIRED
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODE1}
    ...    topology=${TOPOLOGY}
    ...    iterations_per_node=${RUNS_OF_DELTA}
    ...    customers_list=@{CUSTOMERS_LIST}
    ...    report=${SHOULD_BE_REPORTED}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_project=${QC_PROJECT}
    ...    qc_id=${QC_ID}

E2E_TL_BTS_Block_Unblock
    [Timeout]    96h
    E2E TL BTS BLOCK UNBLOCK
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODE1}
    ...    topology=${TOPOLOGY}
    ...    iterations_per_node=${TEST_ITERATION}
    ...    customers_list=@{CUSTOMERS_LIST}
    ...    report=${SHOULD_BE_REPORTED}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_project=${QC_PROJECT}
    ...    qc_id=${QC_ID}

E2E_TL_Site_reset_without_HWF_with_OAM_KPI
    [Timeout]    96h
    E2E TL SITE RESET WITH OAM KPI
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODE1}
    ...    topology=${TOPOLOGY}
    ...    iterations_per_node=${RUNS_OF_RESET}
    ...    customers_list=@{CUSTOMERS_LIST}
    ...    report=${SHOULD_BE_REPORTED}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_project=${QC_PROJECT}
    ...    qc_id=${QC_ID}

E2E_TL_Activation_Reset_with_OAM_KPI
    [Timeout]    96h
    E2E TL ACTIVATION RESET TEST
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODE1}
    ...    topology=${TOPOLOGY}
    ...    iterations_per_node=${RUNS_OF_RESET}
    ...    customers_list=@{CUSTOMERS_LIST}
    ...    report=${SHOULD_BE_REPORTED}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_project=${QC_PROJECT}
    ...    qc_id=${QC_ID}

*** Keywords ***
Custom Suite Setup
    Set Global Variable    ${TARGET_SW}    ${ENB_BUILD}
    Log to console    ********************************************
    Log to console    \n---- Source Software Set to: ${SOURCE_SW} ----
    Log to console    ---- Target Software Set to: ${TARGET_SW} ----
    ${CurrentDate}    Get Current Date    result_format=%H:%M:%S
    Log to console    \n${CurrentDate}
    Log to console    ---- Preparing TestLine for testing ----
    Run Keyword If    '${RUN_SUITE_SETUP}' == 'True'    Common Suite Setup With OnAir Test Line Preparation
    ...    prefix_tag=${SCF_PREFIX_TAG}
    ...    increase_timeout_for_update_sw=1800
    ...    increase_time_for_checking_bbmod=1800
    ...    increase_time_for_checking_radios=1800
    ...    increase_time_for_checking_cells=800
    ...    list_of_additional_allowed_alarms=@{CUSTOM_ALLOWED_ALARMS_DURING_TL_PREPARATION}
    ...    swconfig_from_path=${SWCONFIG_PATH}
    ...    ELSE    Log to console    \n---- Test Setup not needed ----
    Run Keyword If    '${RUN_SUITE_SETUP}' == 'False'    Run Keywords    Log to console
    ...    \n---- Uploading SWconfig on gNB ----\n
    ...    AND    commissioning.Upload Swconfig On Classical Gnb
    ...    sw_config_path=${SWCONFIG_PATH}
    ...    reboot_after_upload=${True}
    ...    AND    Wait For RMOD Offline On GNB
    ...    AND    Wait until keyword succeeds    1200 sec    30 sec    gnbcell.Verify All Cells Are Onair
    ...    AND    Log to console    ---- SWconfig has been uploaded ----\n
    ...    AND    Log to console    ---- Collecting snapshot to remove Diagnostic Files Collected alarm ----\n
    ...    AND    Collect Snapshot From gNB    log_dir=${OUTPUT_DIR}/${SUITE_NAME}
    ...    AND    Log to console    ---- Snapshot has been collected ----
    ${CurrentDate}    Get Current Date    result_format=%H:%M:%S
    Log to console    \n${CurrentDate}
    Log to console    ---- TestLine has been prepared for testing ----
    Log to console    \n********************************************\n

Custom Test Setup
    ${CurrentDate}    Get Current Date    result_format=%H:%M:%S
    Log to console    \n\n${CurrentDate}
    Log to console    ---- Start Test Setup ----\n
    common_setups_and_teardowns.Common Preconditions
    ...    collect_syslog=${False}
    ...    collect_ru_console_log=${False}
    Run Keyword And Ignore Error    Remove Directory         path=/home/ute/.ute-ca/cache/bts/    recursive=${True}
    ${CurrentDate}    Get Current Date    result_format=%H:%M:%S
    Log to console    \n${CurrentDate}
    Log to console    ---- Test Setup Done ----\n

Wait For RMOD Offline On GNB
    [Arguments]    ${id}=${1}
    Wait Until Keyword Succeeds  10min  20s  gnbru.verify_radio_unit_statuses  ru_id=${id}  availability_status=offline

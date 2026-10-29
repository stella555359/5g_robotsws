*** Settings ***
Documentation
...                author: Lukasz Klosinski
...                modify: Michal Kubicki
...                maintainer: Michal Kubicki
...                contact: michal.kubicki@nokia.com
...                Test suite for basic UUF OAM reset wo HWF tests in the 4g configuration:

Library             taf/rfrl/csv4all/CSV4AllTestCases.py
Library             OperatingSystem
Library             testsuite/Wroclaw/RRM/resources/common/mount_netdrive.py
Library             testsuite/Wroclaw/RRM//resources/csv4all_helpers.py
Library             qc_config.py

Suite Setup    Mount Netdrive
Test Setup     Kill All Btslog Processes
Test Teardown  Run Keyword If Test Passed   Find Suspicious Prints In Passed Test

*** Variables ***
@{CUSTOMERS}                            Korean Telecom
${SOURCE_SW2}                           SBTS25R1_ENB_0000_000592_000004
${TARGET_SW2}                           SBTS25R1_ENB_0000_000877_000000

${SOURCE_SW}                            SBTS00_ENB_9999_251027_000019
${TARGET_SW}                            SBTS00_ENB_9999_251028_000009
${target_sw_path}                       /home/ute/Downloads/SBTS00_ENB_9999_250127_1297513_release_BTSSM_downloadable_A54.zip
${SCOUT_HOSTNAME}                       10_16_55041-45041_45041
${Wyrownanie}                           1
${UPDATE_TEST_ITERATION1}               3
${Activation_Reset}                     20
${SITE_RESET_TEST_ITERATION}            20
${BTS_BLOCK_TEST_ITERATION}             1
${BBMOD_RESET_TEST_ITERATION}           20
${BBMOD_LOCK_TEST_ITERATION}            1
${RMOD_RESET_TEST_ITERATION}            1
${RMOD_LOCK_TEST_ITERATION}             1
${CELL_LOCK_TEST_ITERATION}             1
${LTE_CELL_LOCK_UNLOCK_ITERATIONS}      1
${LTE_BLOCK_UNBLOCK_ITERATIONS}         1

${ENABLE_SYSLOG_CHECK}                  ${False}
${STOP_TEST_AFTER_FAIL}                 ${False}
${TEST_ON_NODE}                         ${None}
${REPORT}                               ${True}
@{NODES_SW1}                            ${ENB1}
@{TEST_NODES_SW1}                       ${ENB1}
@{NODES_SW2}                            ${ENB1_SW2}
@{TEST_NODES_SW2}                       ${ENB1_SW2}
${QC_DOMAIN}=                           MN_RAN
${QC_PROJECT}                           RAN_VRF
${RP_CA}                                VRF_RRM
${RP_LOCATION}                          VRF_WRO2
${RP_ORGANIZATION}                      VRF_WRO2_T08_02
${EMAIL_RECIPIENTS}                     michal.kubicki@nokia.com
@{CUSTOM_ALARMS}               8150  7307  4740  7115  61631  7306  4011  1898  8000  7116  7115  7300  4268  7312  4203  6261
@{CRITICAL_ALARMS}             1900

&{ENB1}     node_alias=4G               testline_object=${tl.enbs[0]}
...         source_sw=${SOURCE_SW}      target_sw=${TARGET_SW}
...         target_sw_path=${target_sw_path}
...         custom_allowed_alarms=@{CUSTOM_ALARMS}
...         critical_alarms=@{CRITICAL_ALARMS}
...         testline_scout_name=${SCOUT_HOSTNAME}
...         verify_syslog=${ENABLE_SYSLOG_CHECK}


&{ENB1_SW2}     node_alias=4G               testline_object=${tl.enbs[0]}
...         source_sw=${SOURCE_SW2}      target_sw=${TARGET_SW2}
...         custom_allowed_alarms=@{CUSTOM_ALARMS}
...         critical_alarms=@{CRITICAL_ALARMS}
...         testline_scout_name=${SCOUT_HOSTNAME}
...         verify_syslog=${ENABLE_SYSLOG_CHECK}



*** Test Cases ***
E2E_TL_SW_Upgrade_Rollback_with_OAM_KPI
    ${TEST_QC_ID}=  Set Test ID  ${TARGET_SW}
    E2E TL SW UPGRADE ROLLBACK WITH OAM KPI  ${NODES_SW1}  ${TEST_NODES_SW1}  ${UPDATE_TEST_ITERATION1}
    ...     customers_list=${CUSTOMERS}
    ...     report=${REPORT}
    ...     use_external_storage=${True}
    ...     download_path=/home/ute/Desktop/UUF
    ...     qc_domain=${QC_DOMAIN}
    ...     qc_project=${QC_PROJECT}
    ...     qc_id=${TEST_QC_ID}

E2E_TL_Site_Reset_with_OAM_KPI
    ${TEST_QC_ID}=  Set Test ID
    E2E TL SITE RESET WITH OAM KPI  ${NODES_SW1}  ${TEST_NODES_SW1}   ${SITE_RESET_TEST_ITERATION}
    ...     customers_list=${CUSTOMERS}
    ...     report=${REPORT}
    ...     qc_domain=${QC_DOMAIN}
    ...     qc_project=${QC_PROJECT}
    ...     qc_id=${TEST_QC_ID}
    ...     stop_test_after_fail=${STOP_TEST_AFTER_FAIL}

E2E_TL_Activation_Reset_with_OAM_KPI
    ${TEST_QC_ID}=  Set Test ID    ${TARGET_SW}
    E2E TL ACTIVATION RESET TEST    ${NODES_SW1}  ${TEST_NODES_SW1}   ${Activation_Reset}
    ...     customers_list=${CUSTOMERS}
    ...     report=${REPORT}
    ...     use_external_storage=${True}
    ...     qc_domain=${QC_DOMAIN}
    ...     qc_project=${QC_PROJECT}
    ...     qc_id=${TEST_QC_ID}

E2E_TL_RU_Reset_with_OAM_KPI
    ${TEST_QC_ID}=  Set Test ID
    E2E TL RU RESET WITH OAM KPI  ${NODES_SW1}  ${TEST_NODES_SW1}  ${RMOD_RESET_TEST_ITERATION}
    ...     customers_list=${CUSTOMERS}
    ...     report=${REPORT}
    ...     qc_domain=${QC_DOMAIN}
    ...     qc_project=${QC_PROJECT}
    ...     qc_id=${TEST_QC_ID}
    ...     stop_test_after_fail=${STOP_TEST_AFTER_FAIL}

E2E_TL_Capacity_Module_Reset_with_OAM_KPI
    ${TEST_QC_ID}=  Set Test ID
    E2E TL CAPACITY MODULE RESET WITH OAM KPI  ${NODES_SW1}  ${TEST_NODES_SW1}  ${BBMOD_RESET_TEST_ITERATION}
    ...     customers_list=${CUSTOMERS}
    ...     report=${REPORT}
    ...     qc_domain=${QC_DOMAIN}
    ...     qc_project=${QC_PROJECT}
    ...     qc_id=${TEST_QC_ID}
    ...     stop_test_after_fail=${STOP_TEST_AFTER_FAIL}

E2E_TL_Cell_Lock_Unlock_LTE_with_OAM_KPI
    ${TEST_QC_ID}=  Set Test ID
    E2E TL CELL LOCK UNLOCK LTE WITH OAM KPI    ${NODES_SW1}  ${TEST_NODES_SW1}  ${LTE_CELL_LOCK_UNLOCK_ITERATIONS}
    ...     customers_list=${CUSTOMERS}
    ...     report=${REPORT}
    ...     qc_domain=${QC_DOMAIN}
    ...     qc_project=${QC_PROJECT}
    ...     qc_id=${TEST_QC_ID}
    ...     stop_test_after_fail=${STOP_TEST_AFTER_FAIL}

E2E_TL_BTS_Block_Unblock
    ${TEST_QC_ID}=  Set Test ID
    E2E TL BTS BLOCK UNBLOCK  ${NODES_SW1}  ${TEST_NODES_SW1}  ${BTS_BLOCK_TEST_ITERATION}
    ...     customers_list=${CUSTOMERS}
    ...     report=${REPORT}
    ...     qc_domain=${QC_DOMAIN}
    ...     qc_project=${QC_PROJECT}
    ...     qc_id=${TEST_QC_ID}
    ...     stop_test_after_fail=${STOP_TEST_AFTER_FAIL}

E2E_TL_Cell_Block_Unblock_LTE_with_OAM_KPI
    ${TEST_QC_ID}=  Set Test ID
    E2E TL CELL BLOCK UNBLOCK LTE WITH OAM KPI    ${NODES_SW1}  ${TEST_NODES_SW1}  ${LTE_BLOCK_UNBLOCK_ITERATIONS}
    ...     customers_list=${CUSTOMERS}
    ...     report=${REPORT}
    ...     qc_domain=${QC_DOMAIN}
    ...     qc_project=${QC_PROJECT}
    ...     qc_id=${TEST_QC_ID}
    ...     stop_test_after_fail=${STOP_TEST_AFTER_FAIL}

E2E_TL_RU_Lock_Unlock
    ${TEST_QC_ID}=  Set Test ID
    E2E TL RU LOCK UNLOCK  ${NODES_SW1}  ${TEST_NODES_SW1}  ${RMOD_LOCK_TEST_ITERATION}
    ...     customers_list=${CUSTOMERS}
    ...     report=${REPORT}
    ...     qc_domain=${QC_DOMAIN}
    ...     qc_project=${QC_PROJECT}
    ...     qc_id=${TEST_QC_ID}
    ...     stop_test_after_fail=${STOP_TEST_AFTER_FAIL}

E2E_TL_Capacity_Module_Lock_Unlock
    ${TEST_QC_ID}=  Set Test ID
    E2E TL CAPACITY MODULE LOCK UNLOCK  ${NODES_SW1}  ${TEST_NODES_SW1}  ${BBMOD_LOCK_TEST_ITERATION}
    ...     customers_list=${CUSTOMERS}
    ...     report=${REPORT}
    ...     qc_domain=${QC_DOMAIN}
    ...     qc_project=${QC_PROJECT}
    ...     qc_id=${TEST_QC_ID}
    ...     stop_test_after_fail=${STOP_TEST_AFTER_FAIL}

*** Keywords ***
Kill All Btslog Processes
    Run     sudo lsof | grep -i btslog | awk '{print $3}' | grep -v ute | grep -v pycharm | uniq | xargs kill
    ${rc}	${stdout} =    	Run and Return RC and Output    sudo lsof | grep -i btslog
    Log To Console    Active BtsLog Processes: ${stdout}

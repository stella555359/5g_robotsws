*** Settings ***
Documentation      Test suite for basic UUF OAM reset wo HWF tests in the 5g configuration
...                author: Lukasz Klosinski
...                modify: Michal Kubicki
...                maintainer: Michal Kubicki
...                contact: michal.kubicki@nokia.com

Library            taf/rfrl/csv4all/CSV4AllTestCases.py
Library            qc_config.py
Library            testsuite/Wroclaw/RRM/resources/common/mount_netdrive.py
Library            testsuite/Wroclaw/RRM//resources/csv4all_helpers.py
Library            OperatingSystem

Suite Setup        Mount Netdrive
Test Teardown      Run Keyword If Test Passed   Find Suspicious Prints In Passed Test

*** Variables ***
@{CUSTOMERS}                            LGU+
${SOURCE_SW}                            SBTS25R2_ENB_0000_000231_000016
${TARGET_SW}                            SBTS25R3_ENB_0000_000618_000000
${SCOUT_HOSTNAME}                       10_16_50804-40803_MRBTS-50804
${EXPLORATORY}                                   1
${UPDATE_TEST_ITERATION}                         3
${ACTIVATION_RESET_TEST_ITERATION}               20
${SITE_RESET_TEST_ITERATION}                     20
${BTS_BLOCK_TEST_ITERATION}                      10
${BBMOD_RESET_TEST_ITERATION}                    20
${BBMOD_LOCK_TEST_ITERATION}                     1
${RMOD_RESET_TEST_ITERATION}                     12
${RMOD_LOCK_TEST_ITERATION}                      12
${CELL_LOCK_TEST_ITERATION}                      12
${CELL_BLOCK_UNBLOCK_NR_ITERATIONS}              12
${COMMISSIONING_ONLINE_ITERATIONS}               3
${Commissioning_With_Site_Reset_ITERATIONS}           3
${Commissioning_With_NR_Rat_Reset_ITERATIONS}    3
${ENABLE_SYSLOG_CHECK}                  ${False}
${STOP_TEST_AFTER_FAIL}                 ${False}
${TEST_ON_NODE}                         ${None}
${REPORT}                               ${True}
@{NODES_SW}                            ${GNB}
@{TEST_NODES_SW}                       ${GNB}

${QC_DOMAIN}=                           MN_RAN
${QC_PROJECT}                           RAN_VRF
${RP_CA}                                VRF_RRM
${RP_LOCATION}                          VRF_WRO2
${RP_ORGANIZATION}                      VRF_WRO2_T08_02
${EMAIL_RECIPIENTS}                     michal.kubicki@nokia.com
@{CUSTOM_ALARMS}               8150  7307  4740  61631  7306  4011  1898  8000  7300  4268  7312
@{CRITICAL_ALARMS}             1907    1911    7506



&{GNB}     node_alias=5G                testline_object=${tl.gnbs[0]}
...         source_sw=${SOURCE_SW}      target_sw=${TARGET_SW}
...         custom_allowed_alarms=@{CUSTOM_ALARMS}
...         critical_alarms=@{CRITICAL_ALARMS}
...         testline_scout_name=${SCOUT_HOSTNAME}
...         verify_syslog=${ENABLE_SYSLOG_CHECK}

*** Test Cases ***
MRBTS-50804_OAM_UUF_Exploratory_Robustness_Test_Case
    ${TEST_QC_ID}=  Set Test ID  ${TARGET_SW}
    E2E TL SW UPGRADE ROLLBACK WITH OAM KPI  ${NODES_SW}  ${TEST_NODES_SW}  ${EXPLORATORY}
    ...     restore_to_target_sw=${False}
    ...     customers_list=${CUSTOMERS}
    ...     report=${REPORT}
    ...     use_external_storage=${True}
    ...     download_path=/mnt/UUF_SW/
    ...     qc_domain=${QC_DOMAIN}
    ...     qc_project=${QC_PROJECT}
    ...     qc_id=${TEST_QC_ID}
##
E2E_TL_SW_Upgrade_Rollback_with_OAM_KPI
    ${TEST_QC_ID}=  Set Test ID  ${TARGET_SW}
    E2E TL SW UPGRADE ROLLBACK WITH OAM KPI  ${NODES_SW}  ${TEST_NODES_SW}  ${UPDATE_TEST_ITERATION}
    ...     customers_list=${CUSTOMERS}
    ...     report=${REPORT}
    ...     use_external_storage=${True}
    ...     download_path=/home/ute/Desktop/UUF
    ...     qc_domain=${QC_DOMAIN}
    ...     qc_project=${QC_PROJECT}
    ...     qc_id=${TEST_QC_ID}

E2E_TL_Activation_Reset_with_OAM_KPI
    ${TEST_QC_ID}=  Set Test ID
    E2E TL ACTIVATION RESET TEST    ${NODES_SW}  ${TEST_NODES_SW}  ${ACTIVATION_RESET_TEST_ITERATION}
    ...     customers_list=${CUSTOMERS}
    ...     report=${REPORT}
    ...     use_external_storage=${True}
    ...     download_path=/mnt/burak1/99_Users/pz28/Logs/SFE/LGU/10_16_MRBTS-50804
    ...     download_path=/home/ute/Downloads
    ...     qc_domain=${QC_DOMAIN}
    ...     qc_project=${QC_PROJECT}
    ...     qc_id=${TEST_QC_ID}

E2E_TL_Site_Reset_with_OAM_KPI
    ${TEST_QC_ID}=  Set Test ID
    E2E TL SITE RESET WITH OAM KPI  ${NODES_SW}  ${TEST_NODES_SW}   ${SITE_RESET_TEST_ITERATION}
    ...     customers_list=${CUSTOMERS}
    ...     report=${REPORT}
    ...     qc_domain=${QC_DOMAIN}
    ...     qc_project=${QC_PROJECT}
    ...     qc_id=${TEST_QC_ID}

E2E_TL_RU_Reset_with_OAM_KPI
    ${TEST_QC_ID}=  Set Test ID
    E2E TL RU RESET WITH OAM KPI  ${NODES_SW}  ${TEST_NODES_SW}  ${RMOD_RESET_TEST_ITERATION}
    ...     customers_list=${CUSTOMERS}
    ...     report=${REPORT}
    ...     qc_domain=${QC_DOMAIN}
    ...     qc_project=${QC_PROJECT}
    ...     qc_id=${TEST_QC_ID}

E2E_TL_Capacity_Module_Reset_with_OAM_KPI
    ${TEST_QC_ID}=  Set Test ID
    E2E TL CAPACITY MODULE RESET WITH OAM KPI  ${NODES_SW}  ${TEST_NODES_SW}  ${BBMOD_RESET_TEST_ITERATION}
    ...     customers_list=${CUSTOMERS}
    ...     report=${REPORT}
    ...     qc_domain=${QC_DOMAIN}
    ...     qc_project=${QC_PROJECT}
    ...     qc_id=${TEST_QC_ID}

E2E_TL_Cell_Lock_Unlock_NR_with_OAM_KPI
    ${TEST_QC_ID}=  Set Test ID
    E2E TL CELL LOCK UNLOCK NR WITH OAM KPI  ${NODES_SW}  ${TEST_NODES_SW}  ${CELL_LOCK_TEST_ITERATION}
    ...     customers_list=${CUSTOMERS}
    ...     report=${REPORT}
    ...     qc_domain=${QC_DOMAIN}
    ...     qc_project=${QC_PROJECT}
    ...     qc_id=${TEST_QC_ID}

E2E_TL_Cell_Block_Unblock_NR_with_OAM_KPI
    ${TEST_QC_ID}=  Set Test ID
    E2E TL CELL BLOCK UNBLOCK NR WITH OAM KPI    ${NODES_SW}  ${TEST_NODES_SW}  ${CELL_BLOCK_UNBLOCK_NR_ITERATIONS}
    ...     customers_list=${CUSTOMERS}
    ...     report=${REPORT}
    ...     qc_domain=${QC_DOMAIN}
    ...     qc_project=${QC_PROJECT}
    ...     qc_id=${TEST_QC_ID}

E2E_TL_Delta_Commissioning_With_Online_Parameter_Modification
    ${TEST_QC_ID}=  Set Test ID
    E2E TL DELTA COMMISSIONING WITH ONLINE PARAMETER MODIFICATION    ${NODES_SW}  ${TEST_NODES_SW}  ${COMMISSIONING_ONLINE_ITERATIONS}
    ...     customers_list=${CUSTOMERS}
    ...     report=${REPORT}
    ...     qc_domain=${QC_DOMAIN}
    ...     qc_project=${QC_PROJECT}
    ...     qc_id=${TEST_QC_ID}

E2E_TL_Delta_Commissioning_With_Site_Reset_Required
    ${TEST_QC_ID}=  Set Test ID
    E2E TL DELTA COMMISSIONING WITH SITE RESET REQUIRED    ${NODES_SW}  ${TEST_NODES_SW}  ${Commissioning_With_Site_Reset_ITERATIONS}
    ...     customers_list=${CUSTOMERS}
    ...     report=${REPORT}
    ...     qc_domain=${QC_DOMAIN}
    ...     qc_project=${QC_PROJECT}
    ...     qc_id=${TEST_QC_ID}

E2E_TL_Delta_Commissioning_With_NR_Rat_Reset
    ${TEST_QC_ID}=  Set Test ID
    E2E TL DELTA COMMISSIONING WITH NR RAT RESET    ${NODES_SW}  ${TEST_NODES_SW}   ${Commissioning_With_NR_Rat_Reset_ITERATIONS}
    ...     customers_list=${CUSTOMERS}
    ...     report=${REPORT}
    ...     qc_domain=${QC_DOMAIN}
    ...     qc_project=${QC_PROJECT}
    ...     qc_id=${TEST_QC_ID}
    ...     delta=testsuite/Wroclaw/RRM/VRF_WRO2_T08/integration/MRBTS_50804/delta_files/nr_rat_reset.json

E2E_TL_BTS_Block_Unblock
    ${TEST_QC_ID}=  Set Test ID
    E2E TL BTS BLOCK UNBLOCK  ${NODES_SW}  ${TEST_NODES_SW}  ${BTS_BLOCK_TEST_ITERATION}
    ...     customers_list=${CUSTOMERS}
    ...     report=${REPORT}
    ...     qc_domain=${QC_DOMAIN}
    ...     qc_project=${QC_PROJECT}
    ...     qc_id=${TEST_QC_ID}

E2E_TL_RU_Lock_Unlock
    ${TEST_QC_ID}=  Set Test ID
    E2E TL RU LOCK UNLOCK  ${NODES_SW}  ${TEST_NODES_SW}  ${RMOD_LOCK_TEST_ITERATION}
    ...     customers_list=${CUSTOMERS}
    ...     report=${REPORT}
    ...     qc_domain=${QC_DOMAIN}
    ...     qc_project=${QC_PROJECT}
    ...     qc_id=${TEST_QC_ID}

E2E_TL_Capacity_Module_Lock_Unlock
    ${TEST_QC_ID}=  Set Test ID
    E2E TL CAPACITY MODULE LOCK UNLOCK  ${NODES_SW}  ${TEST_NODES_SW}  ${BBMOD_LOCK_TEST_ITERATION}
    ...     customers_list=${CUSTOMERS}
    ...     report=${REPORT}
    ...     qc_domain=${QC_DOMAIN}
    ...     qc_project=${QC_PROJECT}
    ...     qc_id=${TEST_QC_ID}

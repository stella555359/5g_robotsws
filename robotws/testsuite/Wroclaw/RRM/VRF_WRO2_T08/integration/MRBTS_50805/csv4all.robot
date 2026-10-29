*** Settings ***
Documentation
...                author: Tomasz Sobania
...                modify: Michal Gradowski-Nowak
...                maintainer: Michal Gradowski-Nowak
...                contact: michal.gradowski-nowak@nokia.com
...                Test suite for basic UUF OAM reset wo HWF tests in the 5g configuration:

Library            OperatingSystem
Library            taf/rfrl/csv4all/CSV4AllTestCases.py
Library            testsuite/Wroclaw/RRM/resources/common/mount_netdrive.py
Library            testsuite/Wroclaw/RRM//resources/csv4all_helpers.py
Library            qc_config.py

Suite Setup        Run Keywords    Mount Netdrive    AND    Remove Environment Variable    CM_EXECUTION_ID
Test Teardown      Run Keyword If Test Passed   Find Suspicious Prints In Passed Test

*** Variables ***
${UPDATE_TEST_ITERATION}       	    	3
${SITE_RESET_TEST_ITERATION}   	    	10
${BBMOD_RESET_TEST_ITERATION}           20
${RMOD_RESET_TEST_ITERATION}     	    20
${CELL_LOCK_TEST_ITERATION}   		    3
${COMMISSIONING_TEST_ITERATION}        	3
${BTS_BLOCK_TEST_ITERATION}             10
${CELL_BLOCK_UNBLOCK_TEST_ITERATION}    3
${ACTIVATION_RESET_TEST_ITERATION}      10

${SOURCE_SW}                            SBTS25R3_ENB_0000_000715_000013
${TARGET_SW}                            SBTS00_ENB_9999_260319_000002
${HOSTNAME}                             10_16_50805-40860_MRBTS-50805
${QC_DOMAIN}                            MN_RAN
${QC_PROJECT}                           RAN_VRF
${RP_CA}                                VRF_RRM
${RP_LOCATION}                          VRF_WRO2
${RP_ORGANIZATION}                      VRF_WRO2_T08_02
@{EMAIL_RECIPIENTS}
...    michal.boczon@nokia.com,michal.gradowski-nowak@nokia.com,i_mi_mn_ran_rd_vrf_wro2_8_sfe@internal.nsn.com,i_mi_mn_ran_rd_vrf_wro2_8@nokia.com
@{CUSTOMERS}                            LGU+
${ENABLE_SYSLOG_CHECK}                  ${False}
${STOP_TEST_AFTER_FAIL}                 ${False}
${TEST_ON_NODE}                         ${None}
${USE_EXTERNAL_STORAGE}                 ${True}
${REPORT}                               ${True}
@{NODES}                                ${GNB1}
@{TEST_NODES}                           ${GNB1}

@{CUSTOM_ALARMS}                        8150  7307  4740  7115  61631  7306  4011  1898  8000  7116
...                                     7115  7300  4268  7312  4681   4122
@{CRITICAL_FAULTS}                      10

&{GNB1}     node_alias=5G               testline_object=${tl.gnbs[0]}
...         source_sw=${SOURCE_SW}      target_sw=${TARGET_SW}
...         custom_allowed_alarms=${CUSTOM_ALARMS}
...         critical_alarms=${CRITICAL_FAULTS}
...         testline_scout_name=${HOSTNAME}
...         verify_syslog=${ENABLE_SYSLOG_CHECK}


*** Test Cases ***
E2E_TL_SW_Upgrade_Rollback_with_OAM_KPI
    [Timeout]   24h
    ${TEST_QC_ID}=    Set Test ID   ${TARGET_SW}
    E2E TL SW UPGRADE ROLLBACK WITH OAM KPI  ${NODES}  ${TEST_NODES}  ${UPDATE_TEST_ITERATION}
    ...     use_external_storage=${USE_EXTERNAL_STORAGE}
    ...     download_path=/mnt/UUF_SW/
    ...     customers_list=${CUSTOMERS}
    ...     report=${REPORT}
    ...     qc_domain=${QC_DOMAIN}
    ...     qc_id=${TEST_QC_ID}
    ...     qc_project=${QC_PROJECT}

E2E_TL_Site_Reset_with_OAM_KPI
    [Timeout]   24h
    ${TEST_QC_ID}=    Set Test ID   ${TARGET_SW}
    E2E TL SITE RESET WITH OAM KPI
    ...     nodes_details=${NODES}
    ...     test_nodes_details=${TEST_NODES}
    ...     iterations_per_node=${SITE_RESET_TEST_ITERATION}
    ...     customers_list=${CUSTOMERS}
    ...     report=${REPORT}
    ...     qc_domain=${QC_DOMAIN}
    ...     qc_id=${TEST_QC_ID}
    ...     qc_project=${QC_PROJECT}

E2E_TL_Capacity_Module_Reset_with_OAM_KPI
    [Timeout]   24h
    ${TEST_QC_ID}=    Set Test ID   ${TARGET_SW}
    E2E TL CAPACITY MODULE RESET WITH OAM KPI
    ...     nodes_details=${NODES}
    ...     test_nodes_details=${TEST_NODES}
    ...     iterations_per_node=${BBMOD_RESET_TEST_ITERATION}
    ...     customers_list=${CUSTOMERS}
    ...     report=${REPORT}
    ...     qc_domain=${QC_DOMAIN}
    ...     qc_id=${TEST_QC_ID}
    ...     qc_project=${QC_PROJECT}

E2E_TL_RU_Reset_with_OAM_KPI
    [Timeout]   24h
    ${TEST_QC_ID}=    Set Test ID   ${TARGET_SW}
    E2E TL RU RESET WITH OAM KPI
    ...     nodes_details=${NODES}
    ...     test_nodes_details=${TEST_NODES}
    ...     iterations_per_node=${RMOD_RESET_TEST_ITERATION}
    ...     customers_list=${CUSTOMERS}
    ...     report=${REPORT}
    ...     qc_domain=${QC_DOMAIN}
    ...     qc_id=${TEST_QC_ID}
    ...     qc_project=${QC_PROJECT}

E2E_TL_Cell_Lock_Unlock_NR_with_OAM_KPI
    [Timeout]   24h
    ${TEST_QC_ID}=    Set Test ID   ${TARGET_SW}
    E2E TL CELL LOCK UNLOCK NR WITH OAM KPI
    ...     nodes_details=${NODES}
    ...     test_nodes_details=${TEST_NODES}
    ...     iterations_per_node=${CELL_LOCK_TEST_ITERATION}
    ...     customers_list=${CUSTOMERS}
    ...     report=${REPORT}
    ...     qc_domain=${QC_DOMAIN}
    ...     qc_id=${TEST_QC_ID}
    ...     qc_project=${QC_PROJECT}

E2E_TL_Delta_Commissioning_With_Online_Parameter_Modification
    [Timeout]   24h
    ${TEST_QC_ID}=    Set Test ID   ${TARGET_SW}
    E2E TL DELTA COMMISSIONING WITH ONLINE PARAMETER MODIFICATION
    ...     nodes_details=${NODES}
    ...     test_nodes_details=${TEST_NODES}
    ...     iterations_per_node=${COMMISSIONING_TEST_ITERATION}
    ...     customers_list=${CUSTOMERS}
    ...     report=${REPORT}
    ...     qc_domain=${QC_DOMAIN}
    ...     qc_id=${TEST_QC_ID}
    ...     qc_project=${QC_PROJECT}
    ...     delta=testsuite/Wroclaw/RRM/VRF_WRO2_T08/integration/MRBTS_50805/delta_files/online_parameter.json

E2E_TL_Delta_Commissioning_With_NR_RAT_Reset
    [Timeout]   24h
    ${TEST_QC_ID}=    Set Test ID   ${TARGET_SW}
    E2E TL DELTA COMMISSIONING WITH NR RAT RESET
    ...     nodes_details=${NODES}
    ...     test_nodes_details=${TEST_NODES}
    ...     iterations_per_node=${COMMISSIONING_TEST_ITERATION}
    ...     customers_list=${CUSTOMERS}
    ...     report=${REPORT}
    ...     qc_domain=${QC_DOMAIN}
    ...     qc_id=${TEST_QC_ID}
    ...     qc_project=${QC_PROJECT}
    ...     delta=testsuite/Wroclaw/RRM/VRF_WRO2_T08/integration/MRBTS_50805/delta_files/nr_rat_reset.json

E2E_TL_Delta_Commissioning_With_Site_Reset_Required
    [Timeout]   24h
    ${TEST_QC_ID}=    Set Test ID   ${TARGET_SW}
    E2E TL DELTA COMMISSIONING WITH SITE RESET REQUIRED
    ...     nodes_details=${NODES}
    ...     test_nodes_details=${TEST_NODES}
    ...     iterations_per_node=${COMMISSIONING_TEST_ITERATION}
    ...     customers_list=${CUSTOMERS}
    ...     report=${REPORT}
    ...     qc_domain=${QC_DOMAIN}
    ...     qc_id=${TEST_QC_ID}
    ...     qc_project=${QC_PROJECT}
    ...     delta=testsuite/Wroclaw/RRM/VRF_WRO2_T08/integration/MRBTS_50805/delta_files/site_reset_parameter.json

E2E_TL_Cell_Block_Unblock_NR_with_OAM_KPI
    [Timeout]   24h
    ${TEST_QC_ID}=    Set Test ID   ${TARGET_SW}
    E2E TL CELL BLOCK UNBLOCK NR WITH OAM KPI
    ...     nodes_details=${NODES}
    ...     test_nodes_details=${TEST_NODES}
    ...     iterations_per_node=${CELL_BLOCK_UNBLOCK_TEST_ITERATION}
    ...     customers_list=${CUSTOMERS}
    ...     report=${REPORT}
    ...     qc_domain=${QC_DOMAIN}
    ...     qc_id=${TEST_QC_ID}
    ...     qc_project=${QC_PROJECT}

E2E_TL_Activation_Reset_with_OAM_KPI
    [Timeout]   24h
    ${TEST_QC_ID}=    Set Test ID   ${TARGET_SW}
    E2E TL ACTIVATION RESET TEST
    ...     nodes_details=${NODES}
    ...     test_nodes_details=${TEST_NODES}
    ...     iterations_per_node=${ACTIVATION_RESET_TEST_ITERATION}
    ...     use_external_storage=${USE_EXTERNAL_STORAGE}
    ...     download_path=/mnt/UUF_SW/
    ...     customers_list=${CUSTOMERS}
    ...     report=${REPORT}
    ...     qc_domain=${QC_DOMAIN}
    ...     qc_id=${TEST_QC_ID}
    ...     qc_project=${QC_PROJECT}

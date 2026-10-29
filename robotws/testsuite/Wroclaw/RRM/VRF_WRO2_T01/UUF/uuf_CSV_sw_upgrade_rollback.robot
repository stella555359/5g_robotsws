*** Settings ***
Documentation
...   author: Tomasz Mozola
...   contact: tomasz.mozola@nokia.com
...   Description:   Default testline type TL_type=SA if you need to change testline type add i.e. flag: -v TL_type:NSA
...   example: robot -v TL_type:NSA -v TEST_ITERATION:1 -v TEST_ITERATION2:1
...   for SA: -v TL_type:SA    for LTE: -v TL_type:LTE  for MRAT: -v TL_type:MRAT


Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/UUF/resources/keywords.resource
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T01/UUF/resources/keywords.py
Library         taf/rfrl/csv4all/CSV4AllTestCases.py

Force Tags       CA_VRF_WRO2

Test Setup     Run keywords
...             Set Tester Name                                    AND
...             Check current testline setup     ${TL_type}        AND
...             check_and_update_flag


*** Variables ***
${TL_type}                            SA
${UPGRADE_ITERATION}                  5
${RP_CA}                              VRF_RRM
${RP_LOCATION}                        VRF_WRO2
${RP_ORGANIZATION}                    VRF_WRO2_T01
@{customers_list}                     General
@{CRITICAL_FAULTS}                    10
@{custom_alarms}                      4681  2002
${rep_comment}                        VRF_WRO2_T01_01
${SHOULD_BE_REPORTED}                 True
${CALCULATE_KPI}                      ${True}
${USE_DCAP}                           ${False}
${LABEL}                              ${None}
${USE_BUILDS_STORAGE}                 ${False}
${DOWNLOAD_PATH}                      ${None}
${USE_TEST_PACKAGES}                  ${False}
${RESTORE_TARGET_SW}                  ${True}
${STOP_TEST_AFTER_FAIL}               ${False}
${SYNCHRONIZE_SOFTWARE_ON_PASSIVE}    ${False}
@{CUSTOM_ALARMS_LTE_LOCK}             61631  7509  6351  6134  4011  7513  8150  7511  8000
${tester_name}                        ${None}
${domain}                             MN_RAN
${project}                            RAN_VRF
${q_id}                               ${None}
${INITIAL_SW}                         ${None}
${TARGET_SW}                          ${None}

&{NODE1}                    testline_object=${tl.gnbs[0]}
...                         source_sw=${INITIAL_SW}
...                         target_sw=${TARGET_SW}
...                         custom_allowed_alarms=${custom_alarms}

&{NODE2}                    testline_object=${tl.enbs[0]}
...                         source_sw=${INITIAL_SW}
...                         target_sw=${TARGET_SW}
...                         custom_allowed_alarms=${CUSTOM_ALARMS_LTE_LOCK}

&{NODE_MRAT}                node_vm=${tl.test_pcs[0].default_ssh_connection_details.addr}
...                         secondary_vm=${tl.test_pcs[1].default_ssh_connection_details.addr}
...                         source_sw=${INITIAL_SW}
...                         target_sw=${TARGET_SW}

@{NODES_NSA}             ${NODE1}    ${NODE2}            # NODE1=5g + NODE2=LTE
@{NODES_MRAT}            ${NODE_MRAT}                    # NODE_MRAT=MRAT/fullrack
@{NODES_SA}              ${NODE1}                        # NODE1=5g
@{NODES_LTE}             ${NODE2}                        # NODE2=LTE

@{FINALNODES}            ${NODES_SA}                     # default=5g+4g

*** Test Cases ***
[1]UUF_E2E_TL_SW_Upgrade_Rollback_with_OAM_kpi_SINGLE_node_upgrade
    [Timeout]  48h
    e2e_tl_sw_upgrade_rollback_with_oam_kpi
    ...  nodes_details=${FINALNODES}
    ...  test_nodes_details=${FINALNODES}
    ...  iterations_per_node=${UPGRADE_ITERATION}
    ...  report=${SHOULD_BE_REPORTED}
    ...  calculate_kpi=${CALCULATE_KPI}
    ...  use_dcap=${USE_DCAP}
    ...  qc_domain=${domain}
    ...  qc_id=${q_id}
    ...  qc_project=${domain}
    ...  customers_list=${customers_list}
    ...  report_comment=${rep_comment}
    ...  topology=${LABEL}
    ...  use_external_storage=${USE_BUILDS_STORAGE}
    ...  download_path=${DOWNLOAD_PATH}
    ...  use_testpackage=${USE_TEST_PACKAGES}
    ...  restore_to_target_sw=${RESTORE_TARGET_SW}
    ...  stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    ...  l3_call_method=${None}
    ...  synchronize_software_on_passive=${SYNCHRONIZE_SOFTWARE_ON_PASSIVE}

[1]UUF_E2E_TL_SW_Upgrade_Rollback_with_OAM_kpi_MULTIPLE_node_upgrade
    [Documentation]
    ...    test_nodes_details set as NONE for generic run, for specyfic fullrack testline i.e. TL177
    ...    provide additional flag: -v test_nodes_details:${NODE177}
    [Timeout]  48h
    e2e_tl_sw_upgrade_rollback_with_oam_kpi
    ...  nodes_details=${FINALNODES}
    ...  test_nodes_details=${FINALNODES}
    ...  iterations_per_node=${UPGRADE_ITERATION}
    ...  report=${SHOULD_BE_REPORTED}
    ...  calculate_kpi=${CALCULATE_KPI}
    ...  use_dcap=${USE_DCAP}
    ...  qc_domain=${domain}
    ...  qc_id=${q_id}
    ...  qc_project=${domain}
    ...  customers_list=${customers_list}
    ...  report_comment=${rep_comment}
    ...  topology=${LABEL}
    ...  use_external_storage=${USE_BUILDS_STORAGE}
    ...  download_path=${DOWNLOAD_PATH}
    ...  use_testpackage=${USE_TEST_PACKAGES}
    ...  restore_to_target_sw=${RESTORE_TARGET_SW}
    ...  stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    ...  l3_call_method=${None}
    ...  synchronize_software_on_passive=${SYNCHRONIZE_SOFTWARE_ON_PASSIVE}

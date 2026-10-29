*** Settings ***
Documentation
...   author: Jaroslaw Wojczyszyn, Wiktor Jarosinski
...   contact: jaroslaw.wojczyszyn@nokia.com, wiktor.jarosinski@nokia.com
...   Description: Robustness tests for TMO TOL [eNB site].

Resource                    testsuite/Wroclaw/RRM/VRF_WRO2_T01/UUF/resources/keywords.resource
Library                     testsuite/Wroclaw/RRM/VRF_WRO2_T01/UUF/resources/keywords.py
Library                     taf/rfrl/csv4all/CSV4AllTestCases.py

Force Tags                  CA_VRF_WRO2

Test Setup                  Run keywords
...                         Set Tester Name                                    AND
...                         check_and_update_flag

*** Variables ***
${TL_TYPE}                  SA
${TEST_ITERATION}           1
${RP_CA}                    VRF_RRM
${RP_LOCATION}              VRF_WRO2
${RP_ORGANIZATION}          VRF_WRO2_T01
@{customers_list}           General
@{CRITICAL_FAULTS}          10
@{custom_alarms}            4681    2002
${rep_comment}              VRF_WRO2_T01_01
${tester_name}              ${None}
${domain}                   MN_RAN
${project}                  RAN_VRF
${q_id}                     ${None}
${INITIAL_SW}               ${None}
${TARGET_SW}                ${None}

@{SMOD_ENB_TARGET}          MRBTS-8816/EQM-1/APEQM-1/CABINET-1/SMOD-1   # ASIB  [eNB]

&{NODE}                     testline_object=${tl.enbs[0]}
...                         source_sw=${INITIAL_SW}
...                         target_sw=${TARGET_SW}
...                         custom_allowed_alarms=${custom_alarms}
...                         modules_for_test=${SMOD_ENB_TARGET}

@{NODES}                    ${NODE}

*** Test Cases ***
Upgrade_and_Rollback_ASIB_Webem
    [Documentation]    OAM_4 Upgrade_ASIB_Webem, OAM_10 Rollback_ASIB_Webem
    e2e_tl_sw_upgrade_rollback_with_oam_kpi
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODES}
    ...    iterations_per_node=${TEST_ITERATION}
    ...    qc_domain=${domain}
    ...    qc_id=${q_id}
    ...    qc_project=${project}
    ...    customers_list=${customers_list}
    ...    report_comment=${rep_comment}

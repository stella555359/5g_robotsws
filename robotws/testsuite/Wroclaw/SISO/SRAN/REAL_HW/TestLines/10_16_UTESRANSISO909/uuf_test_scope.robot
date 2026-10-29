*** Settings ***
Documentation    This file needs documentation
Resource    ../../Resources/Setup/setup_and_teardown.robot
#Resource    ../../hran_ta/testsuite/SBTS/test_resources/STATE/STATE__Site_reset.robot
#Resource    ../../hran_ta/testsuite/SBTS/test_resources/STATE/STATE__LTE_RAT_reset_from_ADMIN.robot
#Resource    ../../hran_ta/testsuite/SBTS/test_resources/STATE/STATE__Radio_module_reset_from_admin.robot
Library  taf/rfrl/csv4all/resources/utilities/utilities.py


Library  taf.sbts.oam.coam.admin  WITH NAME  admin
Library  taf.hw.pdu  WITH NAME  pdu
Library  taf/rfrl/csv4all/CSV4AllTestCases.py

Suite Setup       Suite Precondition
Suite Teardown    Suite Postcondition
*** Variables ***

${CUSTOM_SWITCH_PERFORM_SNAPSHOT}=  Failed  # possible settings : Failed, Always, None
${CUSTOM_SWITCH_PERFORM_HW_SETUP}=  True  # to disable hardware reconfiguration ( PDU and Optical part ) set value False

${CUSTOM_LIVE_MODE_MASTER_NODE_IP}=    #10.42.165.45
@{CUSTOM_LIVE_MODE_AUXILLARY_NODES_IPS_LIST}=


${CUSTOM_MPLANE_MODE_PRIMARY_NODE_IP}=    #10.42.106.133
@{CUSTOM_MODE_AUXILLARY_NODES_IPS_LIST}=

${CUSTOM_FILE_MODE_MASTER_NODE_IP}
@{CUSTOM_FILE_MODE_AUXILLARY_NODES_IPS_LIST}

${CUSTOM_MANUAL_MODE_SCF_PATH}=   /home/ute/scf_files/
@{CUSTOM_ALLOWED_ALARMS}=    4655    2403    61524    61649    61652    4654    61649    7112

#${INITIAL_SW}               SBTS00_ENB_9999_240503_000014
#${TARGET_SW}                SBTS00_ENB_9999_240507_000007
${ITERATIONS}               1
&{NODE1}                    testline_object=${tl.enbs[0]}
#...                         source_sw=${INITIAL_SW}
#...                         target_sw=${TARGET_SW}
...                         custom_allowed_alarms=${CUSTOM_ALLOWED_ALARMS}
#&{NODE2}                    testline_object=${tl.gnbs[1]}
#...                         source_sw=${INITIAL_SW}
#...                         target_sw=${TARGET_SW}
#&{NODE3}                    testline_object=${tl.enbs[0]}
#...                         source_sw=${INITIAL_SW}
#...                         target_sw=${TARGET_SW}
@{NODES}                    ${NODE1}    #${NODE2}    ${NODE3}

${CUSTOMERS}=   Generic
${TESTLINE_NAME}=    10_16_UTESRANSISO909


${ADDITIONAL_IGNORED_ALARMS}=  2403  7112



*** Test Cases ***

[1][0.1] e2e_tl_upgrade_test
    [Tags]  Siso SRAN Site Reset
    [Timeout]    14400
    [Setup]  Configuration Precondition    CN=REF_10_16_UTESRANSISO909
    Set Initial And Candidate
    e2e_tl_upgrade_test  ${NODES}  ${NODE1}  ${ITERATIONS}  customers_list=${CUSTOMERS}  report=${False}
    [Teardown]    Configuration Postcondition

#
#[1][0.1] Siso SRAN Site Reset
#    [Tags]  Siso SRAN Site Reset
#    [Setup]  Run Keywords
#    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO909
#    ...  AND  Set Test Variable    ${RESTORE_TIMEOUT}    10
#    ...    AND    Set Library Search Order    STATE__Site_reset  admin_im  hran_frame_sbts_siso  taf.sw.scout  coam
#    ...    AND    Set Test Variable  ${COMMISSIONING_PATH}   ${CFG['NODES']['${CFG.primary_node_bts_id}']['scf_file_path']}
#    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    False
#    ...    AND    Set Test Variable    ${ENABLE_TRUCK_ROLL_FLAG}    ${False}
#    ...    AND    STATE__Site_reset.TC Setup
#    TC__STATE__Site_reset
#    [Teardown]    Run Keywords
#    ...  STATE__Site_reset.TC Teardown
#    ...  AND  Configuration Postcondition  status=${TEST_STATUS}
#
#
#[1][0.1] STATE__LTE_RAT_reset_from_ADMIN
#    [Tags]  Siso SRAN Site Reset
#    [Timeout]    14400
#    [Setup]  Run Keywords
#    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO909
#    ...    AND    Set Library Search Order    STATE__Site_reset  admin_im  hran_frame_sbts_siso  taf.sw.scout  coam
#    ...  AND  Set Test Variable    ${RESTORE_TIMEOUT}    10
#    ...    AND    Set Test Variable  ${COMMISSIONING_PATH}   ${CFG['NODES']['${CFG.primary_node_bts_id}']['scf_file_path']}
#    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    False
#    ...    AND    Set Test Variable    ${ENABLE_TRUCK_ROLL_FLAG}    ${False}
#    ...    AND    STATE__LTE_RAT_reset_from_ADMIN.TC Setup
#    TC__STATE__LTE_RAT_reset_from_ADMIN
#    [Teardown]    Run Keywords
#    ...  STATE__LTE_RAT_reset_from_ADMIN.TC Teardown
#    ...  AND  Configuration Postcondition  status=${TEST_STATUS}
#
#
#[1][0.1] TC__STATE__Radio_module_reset_from_admin
#    [Tags]  Siso SRAN Site Reset
#    [Timeout]    14400
#    [Setup]  Run Keywords
#    ...  Configuration Precondition    CN=REF_10_16_UTESRANSISO909
#    ...    AND    Set Library Search Order    STATE__Site_reset  admin_im  hran_frame_sbts_siso  taf.sw.scout  coam
#    ...  AND  Set Test Variable    ${RESTORE_TIMEOUT}    10
#    ...    AND    Set Test Variable  ${COMMISSIONING_PATH}   ${CFG['NODES']['${CFG.primary_node_bts_id}']['scf_file_path']}
#    ...    AND    Set Test Variable    ${GENERATE_JSON_KPI}    False
#    ...    AND    Set Test Variable    ${ENABLE_TRUCK_ROLL_FLAG}    ${False}
#    ...    AND    STATE__Radio_module_reset_from_admin.TC Setup
#    TC__STATE__Radio_module_reset_from_admin
#    [Teardown]    Run Keywords
#    ...  STATE__Radio_module_reset_from_admin.TC Teardown
#    ...  AND  Configuration Postcondition  status=${TEST_STATUS}



*** Keywords ***
Set Initial And Candidate
    ${initial_sw}        Get Source SW
    ${candidate_sw}      Get Target SW
    Set to dictionary    ${NODE1}    source_sw=${initial_sw}    target_sw=${candidate_sw}


*** Settings ***
Documentation       Test suite for basic CSV4ALL Tests in loop
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia.com

Library             taf/rfrl/csv4all/CSV4AllTestCases.py
Resource            ../../test_resources/CM/TA_Call_For_Top50_Module.robot
Resource            ../../test_resources/CM/Report_To_Reporting_Portal_With_ConfigID.robot

*** Variables ***
${SHOULD_BE_REPORTED}           True
${RP_CA}                        VRF_OAM
${RP_LOCATION}                  VRF_HAZ1
${RP_ORGANIZATION}              VRF_HAZ1_T04
${INITIAL_SW}                   SBTS24R3_ENB_0000_000912_000019
${TARGET_SW}                    SBTS25R1_ENB_0000_001113_000000
${UPDATE_TEST_ITERATION}        3
${SITE_RESET_TEST_ITERATION}    20
${RU_RESET_TEST_ITERATION}      20
${BBMOD_RESET_TEST_ITERATION}   10
${CELL_LOCK_TEST_ITERATION}     5
${TEST_ITERATION}               3
${USE_TEST_PACKAGES}            True
${RESTORE_TO_TARGET_SW}         False

# Email recipients for notifications (use nokia.com or internal.nsn.com domains)
# Multiple emails can be defined by separating them with commas
# Notifications include test start/end and failures
${EMAIL_RECIPIENTS}         yuyan.xu@nokia.com


# Node definitions for the test configuration
# Single BTS or fullrack (dualcore, including Airscale + FSM3) configurations require one node
# 4G5G configurations require two nodes
# Define nodes based on logical BTS count
# Node information includes mainly VM IP and software versions; other details are fetched automatically

# UTE testline initialization (VM definition in init must have a Connection object linking VM to BTS)
@{CUSTOM_ALLOWED}    3456  4567    7220  62003  7509  61510  61618  61074  4654  4655  61649  61524
    ...    61652    4298    6322    4681    4592    6134    61510    1300    4298    4639    61074
@{CRITICAL_ALARMS}

&{NODE1}                    testline_object=${tl.enbs[0]}
...                         source_sw=${INITIAL_SW}
...                         target_sw=${TARGET_SW}
...                         custom_allowed_alarms=${CUSTOM_ALLOWED}
...                         critical_alarms=${CRITICAL_ALARMS}
...                         testline_scout_name=10_5_5G-1906-4G-1907_MRBTS-1906

@{NODES}                    ${NODE1}    #${NODE2}    ${NODE3}
@{UPGRADE_NODES}            ${NODE1}    #${NODE1}    ${NODE3}
@{customers}                Optus

*** Test Cases ***
E2E_TL_SW_Upgrade_Rollback_with_OAM_KPI_single_node_upgrade
    # This testcase will upgrade and rollback only node1 in configuration consisting of 3 nodes (defined in NODES variable)
    # Nodes which are not currently upgraded will still be monitored for any impacting faults
    [Timeout]   24h
    [Tags]   upgrade
    E2E TL SW UPGRADE ROLLBACK WITH OAM KPI    ${NODES}  ${NODE1}  ${UPDATE_TEST_ITERATION}
    ...    report=${SHOULD_BE_REPORTED}
    ...    qc_domain=MN_RAN
    ...    qc_id=102823
    ...    qc_project=RAN_VRF
    ...    topology=CLOUD_SRAN_N_1906_1ASIL_2ABIO_3AQQY_3AHPDA_3AENB_3AHEGHA
    ...    customers_list=${customers}
    #...    download_path=/home/ute/Downloads
    ...    use_testpackage=${USE_TEST_PACKAGES}
    ...    restore_to_target_sw=${RESTORE_TO_TARGET_SW}
    #Top50_TA_Call    SBTS_ID=1906

E2E_TL_Activation_Reset_with_OAM_KPI
    [Timeout]   24h
    [Tags]   reset
    E2E TL ACTIVATION RESET TEST    ${NODES}  ${NODE1}   ${SITE_RESET_TEST_ITERATION}
    ...    report=${SHOULD_BE_REPORTED}
    ...    qc_domain=MN_RAN
    ...    qc_id=102824
    ...    qc_project=RAN_VRF
    ...    topology=CLOUD_SRAN_N_1906_1ASIL_2ABIO_3AQQY_3AHPDA_3AENB_3AHEGHA
    ...    customers_list=${customers}
    #Top50_TA_Call    SBTS_ID=1906

E2E_TL_RU_Reset_with_OAM_KPI
    [Timeout]   24h
    [Tags]   rmod
    E2E TL RU RESET WITH OAM KPI    ${NODES}  ${NODE1}  ${RU_RESET_TEST_ITERATION}
    ...    report=${SHOULD_BE_REPORTED}
    ...    qc_domain=MN_RAN
    ...    qc_id=102826
    ...    qc_project=RAN_VRF
    ...    topology=CLOUD_SRAN_N_1906_1ASIL_2ABIO_3AQQY_3AHPDA_3AENB_3AHEGHA
    ...    customers_list=${customers}

E2E_TL_Capacity_Module_Reset_with_OAM_KPI
    [Timeout]   24h
    [Tags]   bbmod
    E2E TL CAPACITY MODULE RESET WITH OAM KPI    ${NODES}  ${NODE1}  ${BBMOD_RESET_TEST_ITERATION}
    ...    report=${SHOULD_BE_REPORTED}
    ...    qc_domain=MN_RAN
    ...    qc_id=102825
    ...    qc_project=RAN_VRF
    ...    topology=CLOUD_SRAN_N_1906_1ASIL_2ABIO_3AQQY_3AHPDA_3AENB_3AHEGHA
    ...    customers_list=${customers}

E2E_TL_Cell_Lock_Unlock_NR_with_OAM_KPI
    [Timeout]   24h
    [Tags]   cell
    E2E TL CELL LOCK UNLOCK NR WITH OAM KPI    ${NODES}  ${NODE1}  ${CELL_LOCK_TEST_ITERATION}
    ...    report=${SHOULD_BE_REPORTED}
    ...    qc_domain=MN_RAN
    ...    qc_id=102827
    ...    qc_project=RAN_VRF
    ...    topology=CLOUD_SRAN_N_1906_1ASIL_2ABIO_3AQQY_3AHPDA_3AENB_3AHEGHA
    ...    customers_list=${customers}

E2E_TL_Delta_Commissioning_With_Online_Parameter_Modification
    [Timeout]   24h
    [Tags]   online
    E2E TL DELTA COMMISSIONING WITH ONLINE PARAMETER MODIFICATION    ${NODES}  ${NODE1}  ${TEST_ITERATION}
    ...    report=${SHOULD_BE_REPORTED}
    ...    qc_domain=MN_RAN
    ...    qc_id=102828
    ...    qc_project=RAN_VRF
    ...    topology=CLOUD_SRAN_N_1906_1ASIL_2ABIO_3AQQY_3AHPDA_3AENB_3AHEGHA
    ...    customers_list=${customers}

E2E_TL_Delta_Commissioning_With_Site_Reset_Required
    [Timeout]   24h
    [Tags]   sitereset
    E2E TL DELTA COMMISSIONING WITH SITE RESET REQUIRED    ${NODES}  ${NODE1}  ${TEST_ITERATION}
    ...    report=${SHOULD_BE_REPORTED}
    ...    qc_domain=MN_RAN
    ...    qc_id=102829
    ...    qc_project=RAN_VRF
    ...    topology=CLOUD_SRAN_N_1906_1ASIL_2ABIO_3AQQY_3AHPDA_3AENB_3AHEGHA
    ...    customers_list=${customers}

E2E_TL_call_with_OAM_KPI
    [Tags]   call
    Top50_TA_Call    SBTS_ID=1906
    Run Keyword If  ${SHOULD_BE_REPORTED}    Report To Rep
    ...          case_name=E2E_TL_L3Call_After_UUF
    ...          qc_id=XXX
    ...          build=${TARGET_SW}
    ...          parameter_1=${TARGET_SW}
    ...          testline=10_5_UTESRAN1906
    ...          status=passed

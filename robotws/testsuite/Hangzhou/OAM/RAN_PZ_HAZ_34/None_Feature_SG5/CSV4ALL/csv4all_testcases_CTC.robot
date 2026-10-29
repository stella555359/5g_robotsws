*** Settings ***
Suite Setup         UUF4ALL Suite Setup
Documentation       Test suite for basic CSV4ALL Tests in loop
...                 Author: Yue 2. Liu (NSB)
...                 Contact: yue.2.liu@nokia-sbell.com

Resource            testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/None_Feature_SG5/CSV4ALL/Resource/csv4all_kw.robot
Resource            taf/rfrl/uuf4all/uuf4all_keywords.robot
Library             taf/rfrl/csv4all/CSV4AllTestCases.py

*** Variables ***
${RP_CA}              VRF_OAM
${RP_LOCATION}        VRF_HAZ4
${RP_ORGANIZATION}    VRF_HAZ4_T05
${EMAIL_RECIPIENTS}   None
${target_version}     None
${ITERATIONS}         1
#@{gnb0_CUSTOM_ALLOWED_ALARMS}       ${EMPTY}
#@{gnb0_TEMPORARY_ALLOWED_ALARMS}    ${EMPTY}

*** Test Cases ***
########## CTC_TL673 ##########
[1][1.0] E2E_TL_SW_upgrade_rollback_with_OAM_KPI
    # This testcase will upgrade and rollback only node1 in configuration consisting of 3 nodes (defined in NODES variable)
    # Nodes which are not currently upgraded will still be monitored for any impacting faults
    [Tags]    CTC_TL673
    [Timeout]   24h
    E2E TL SW UPGRADE ROLLBACK WITH OAM KPI
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODE1}
    ...    iterations_per_node=${ITERATIONS}
    ...    report=${False}
#    ...    calculate_kpi=${True}
#    ...    qc_domain=MN_RAN
#    ...    qc_project=RAN_VRF
#    ...    customers_list=None
#    ...    report_comment=None
#    ...    topology=None
#    ...    stop_test_after_fail=${False}

[1][1.0] E2E_TL_Site_reset_without_HWF_with_OAM_KPI
    [Tags]    CTC_TL673
    [Timeout]   24h
    E2E TL SITE RESET WITHOUT HWF WITH OAM KPI
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODE1}
    ...    iterations_per_node=${ITERATIONS}
    ...    report=${False}

[1][1.0] E2E_TL_RU_Reset_with_OAM_KPI
    [Tags]    CTC_TL673
    [Timeout]   24h
    E2E TL RU RESET WITH OAM KPI
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODE1}
    ...    iterations_per_node=${ITERATIONS}
    ...    report=${False}

[1][1.0] E2E_TL_Capacity_Module_Reset_with_OAM_KPI
    [Tags]    CTC_TL673
    [Timeout]   24h
    E2E TL CAPACITY MODULE RESET WITH OAM KPI
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODE1}
    ...    iterations_per_node=${ITERATIONS}
    ...    report=${False}

[1][1.0] E2E_TL_Cell_Lock_Unlock_NR_with_OAM_KPI
    [Tags]    CTC_TL673
    [Timeout]   24h
    E2E TL CELL LOCK UNLOCK NR WITH OAM KPI
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODE1}
    ...    iterations_per_node=${ITERATIONS}
    ...    report=${False}

[1][1.0] E2E_TL_Cell_Block_Unblock_NR_with_OAM_KPI
    [Tags]    CTC_TL673
    [Timeout]   24h
    E2E TL CELL BLOCK UNBLOCK NR WITH OAM KPI
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODE1}
    ...    iterations_per_node=${ITERATIONS}
    ...    report=${False}

[1][1.0] E2E_TL_Delta_Commissioning_With_Site_Reset_Required
    [Tags]    CTC_TL673
    [Timeout]   24h
    E2E TL DELTA COMMISSIONING WITH SITE RESET REQUIRED
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODE1}
    ...    iterations_per_node=${ITERATIONS}
    ...    report=${False}
#    ...    delta=None

########## CTC_TL674 ##########
[2][1.0] E2E_TL_SW_upgrade_rollback_with_OAM_KPI
    # This testcase will upgrade and rollback only node1 in configuration consisting of 3 nodes (defined in NODES variable)
    # Nodes which are not currently upgraded will still be monitored for any impacting faults
    [Tags]    CTC_TL674
    [Timeout]   24h
    E2E TL SW UPGRADE ROLLBACK WITH OAM KPI
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODE1}
    ...    iterations_per_node=${ITERATIONS}
    ...    report=${False}
#    ...    calculate_kpi=${True}
#    ...    qc_domain=MN_RAN
#    ...    qc_project=RAN_VRF
#    ...    customers_list=None
#    ...    report_comment=None
#    ...    topology=None
#    ...    stop_test_after_fail=${False}

[2][1.0] E2E_TL_Site_reset_without_HWF_with_OAM_KPI
    [Tags]    CTC_TL673
    [Timeout]   24h
    E2E TL SITE RESET WITHOUT HWF WITH OAM KPI
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODE1}
    ...    iterations_per_node=${ITERATIONS}
    ...    report=${False}

[2][1.0] E2E_TL_RU_Reset_with_OAM_KPI
    [Tags]    CTC_TL673
    [Timeout]   24h
    E2E TL RU RESET WITH OAM KPI
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODE1}
    ...    iterations_per_node=${ITERATIONS}
    ...    report=${False}

[2][1.0] E2E_TL_Capacity_Module_Reset_with_OAM_KPI
    [Tags]    CTC_TL673
    [Timeout]   24h
    E2E TL CAPACITY MODULE RESET WITH OAM KPI
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODE1}
    ...    iterations_per_node=${ITERATIONS}
    ...    report=${False}

[2][1.0] E2E_TL_Cell_Lock_Unlock_NR_with_OAM_KPI
    [Tags]    CTC_TL673
    [Timeout]   24h
    E2E TL CELL LOCK UNLOCK NR WITH OAM KPI
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODE1}
    ...    iterations_per_node=${ITERATIONS}
    ...    report=${False}

[2][1.0] E2E_TL_Cell_Block_Unblock_NR_with_OAM_KPI
    [Tags]    CTC_TL673
    [Timeout]   24h
    E2E TL CELL BLOCK UNBLOCK NR WITH OAM KPI
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODE1}
    ...    iterations_per_node=${ITERATIONS}
    ...    report=${False}

[2][1.0] E2E_TL_Delta_Commissioning_With_Site_Reset_Required
    [Tags]    CTC_TL673
    [Timeout]   24h
    E2E TL DELTA COMMISSIONING WITH SITE RESET REQUIRED
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODE1}
    ...    iterations_per_node=${ITERATIONS}
    ...    report=${False}
#    ...    delta=None

*** Settings ***
Suite Setup         UUF4ALL Suite Setup
Documentation       Test suite for basic CSV4ALL Tests in loop
...                 Author: Yue 2. Liu (NSB)
...                 Contact: yue.2.liu@nokia-sbell.com

Resource            testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource            testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource            testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/None_Feature_SG5/CSV4ALL/Resource/csv4all_kw.robot
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
[1]CB011088_E2E_TL_SW_Upgrade_Rollback_with_OAM_KPI
    # This testcase will upgrade and rollback only node1 in configuration consisting of 3 nodes (defined in NODES variable)
    # Nodes which are not currently upgraded will still be monitored for any impacting faults
    [Timeout]   24h
    [Setup]    robot_common_operations.Common Case Setup
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
    [Teardown]    Run Keywords    robot_common_operations.Common Case Teardown
    ...    AND    CI_interface.Common Case Teardown

#[1]CB011088_E2E_TL_Site_Reset_without_HWF_with_OAM_KPI
#    [Timeout]   24h
#    [Setup]    robot_common_operations.Common Case Setup
#    E2E TL SITE RESET WITHOUT HWF WITH OAM KPI
#    ...    nodes_details=${NODES}
#    ...    test_nodes_details=${NODE1}
#    ...    iterations_per_node=${ITERATIONS}
#    ...    report=${False}

[1]CB011088_E2E_TL_Activation_Reset_with_OAM_KPI
    [Timeout]   24h
    [Setup]    robot_common_operations.Common Case Setup
    E2E TL ACTIVATION RESET TEST
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODE1}
    ...    iterations_per_node=${2}
    ...    report=${False}
    [Teardown]    Run Keywords    robot_common_operations.Common Case Teardown
    ...    AND    CI_interface.Common Case Teardown

[1]CB012196_E2E_TL_SW_Upgrade_Rollback_with_OAM_KPI
    [Timeout]   24h
    [Setup]    robot_common_operations.Common Case Setup
    E2E TL SW UPGRADE ROLLBACK WITH OAM KPI
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODE1}
    ...    iterations_per_node=${ITERATIONS}
    ...    report=${False}
    [Teardown]    Run Keywords    robot_common_operations.Common Case Teardown
    ...    AND    CI_interface.Common Case Teardown

#E2E_TL_RU_Reset_with_OAM_KPI
#    [Timeout]   24h
#    E2E TL RU RESET WITH OAM KPI    ${NODES}  ${NODE1}  ${ITERATIONS}
#
#E2E_TL_Capacity_Module_Reset_with_OAM_KPI
#    [Timeout]   24h
#    E2E TL CAPACITY MODULE RESET WITH OAM KPI    ${NODES}  ${NODE1}  ${ITERATIONS}
#
#E2E_TL_Cell_Lock_Unlock_NR_with_OAM_KPI
#    [Timeout]   24h
#    E2E TL CELL LOCK UNLOCK NR WITH OAM KPI    ${NODES}  ${NODE1}  ${ITERATIONS}
#
#E2E_TL_Cell_Lock_Unlock_LTE_with_OAM_KPI
#    [Timeout]   24h
#    E2E TL CELL LOCK UNLOCK LTE WITH OAM KPI    ${NODES}  ${NODE1}  ${ITERATIONS}
#
#E2E_TL_Cell_Block_Unblock_LTE_with_OAM_KPI
#    [Timeout]   24h
#    E2E TL CELL BLOCK UNBLOCK LTE WITH OAM KPI    ${NODES}  ${NODE1}  ${ITERATIONS}
#
#E2E_TL_Cell_Block_Unblock_NR_with_OAM_KPI
#    [Timeout]   24h
#    E2E TL CELL BLOCK UNBLOCK NR WITH OAM KPI    ${NODES}  ${NODE1}  ${ITERATIONS}
#
#E2E_TL_Cell_Block_Unblock_GSM_with_OAM_KPI
#    [Timeout]   24h
#    E2E TL CELL BLOCK UNBLOCK GSM WITH OAM KPI    ${NODES}  ${NODE1}  ${ITERATIONS}
#
#E2E_TL_Cell_Block_Unblock_WCDMA_with_OAM_KPI
#    [Timeout]   24h
#    E2E TL CELL BLOCK UNBLOCK WCDMA WITH OAM KPI    ${NODES}  ${NODE1}  ${ITERATIONS}
#
#E2E_TL_Delta_Commissioning_With_Online_Parameter_Modification
#    [Timeout]   24h
#    E2E TL DELTA COMMISSIONING WITH ONLINE PARAMETER MODIFICATION    ${NODES}  ${NODE1}  ${ITERATIONS}
#
#E2E_TL_Delta_Commissioning_With_Site_Reset_Required
#    [Timeout]   24h
#    E2E TL DELTA COMMISSIONING WITH SITE RESET REQUIRED    ${NODES}  ${NODE1}  ${ITERATIONS}
#
#E2E_TL_BTS_Block_Unblock
#    [Timeout]   24h
#    E2E TL BTS BLOCK UNBLOCK    ${NODES}  ${NODE1}  ${ITERATIONS}
#
#E2E_TL_RU_Lock_Unlock
#    [Timeout]   24h
#    E2E TL RU LOCK UNLOCK    ${NODES}  ${NODE1}  ${ITERATIONS}
#
#E2E_TL_RU_Power_Reset
#    [Timeout]   24h
#    E2E TL RU POWER RESET
#    ...    nodes_details=${NODES}
#    ...    test_nodes_details=${NODE1}
#    ...    iterations_per_node=${ITERATIONS}
#    ...    rmods_with_pdu_ports=${tl.gnbs[0].dus[0].rus[0].pdu_port.port_no}
#
#E2E_TL_Capacity_Module_Lock_Unlock
#    [Timeout]   24h
#    E2E TL CAPACITY MODULE LOCK UNLOCK    ${NODES}  ${NODE1}  ${ITERATIONS}

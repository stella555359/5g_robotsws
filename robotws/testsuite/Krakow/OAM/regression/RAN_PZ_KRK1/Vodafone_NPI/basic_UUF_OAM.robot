*** Settings ***
Documentation       Test suite for basic CSV4ALL Tests in loop - Vodafone NPI
...                 Maintainer: Agnieszka Bylica
...                 Contact: agnieszka.bylica@nokia.com

Library      taf/rfrl/csv4all/CSV4AllTestCases.py
Library      taf.rfrl.utilities.cloud_manager.artifacts       WITH NAME    artifacts
Library      testsuite.Krakow.resources.UUF.get_uuf_builds    WITH NAME    uuf_builds
Library      ./resources/helpers.py
Library      ./resources/deltas.py
Library      taf/rfrl/bts/parallel/operations.py
Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource     ./resources/common_keywords.robot
Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Variables    ./resources/variables.py

Suite Setup       Custom Suite Setup
Suite Teardown    common_setups_and_teardowns.Common Suite Teardown

Test Setup        Custom Test Setup
Test Teardown     Custom Test Teardown

# robot -L TRACE --outputdir /home/ute/logs/basic_UUF_OAM/test_run16 -V /home/ute/auto/testline_configuration/7_7_T01PY080/
# testsuite/Krakow/OAM/regression/RAN_PZ_KRK1/Vodafone_NPI/basic_UUF_OAM.robot
*** Variables ***
# Mandatory variables to send report to Reporting Portal
# Competence Area from Force Tags will be ignored
# Allowed values: ["VRF_OAM", "VRF_ORAN", "VRF_RRM", "VRF_SiSo", "VRF_TRS", "VRF_VNF", "CIS_*"]
${RP_CA}   VRF_SiSo

# Allowed values: ['VRF_BLR1', 'VRF_BLR2', 'VRF_WRO1', 'VRF_WRO2', 'VRF_WRO3', 'VRF_WRO4', 'VRF_HAZ1', 'VRF_HAZ2',
                  # 'VRF_HAZ3', 'VRF_HAZ4', 'VRF_KRK', 'VRF_NPS', 'VRF_DAL', 'VRF_ULM', 'VRF_TSR1', 'VRF_TSR2',
                  # 'VRF_ESP', 'CIS_NPI_GCHN', "CIS_*"]
${RP_LOCATION}    VRF_KRK

# Allowed values: ${RP_LOCATION} + Team prefix
${RP_ORGANIZATION}    VRF_KRK_T01

# Email recipients for notifications (use nokia.com or internal.nsn.com domains)
# Multiple emails can be defined by separating them with commas
# Notifications include test start/end and failures
${EMAIL_RECIPIENTS}         None

#Path to taf.hw.rf_diagnostic_card custom configuration yaml
${RDC_CONFIG}             /home/ute/config.yaml

# Software versions used in node definitions
${SOURCE_SW}                            ${None}
${TARGET_SW}                            ${None}
${INDEPENDENT_RU_SW_PACKAGE_NAME}       ${None}

# Test iteration count used in keyword call
${ITERATIONS}               1

# Name of the Netact LAB e.g. srnclab1044
${NETACT_NAME}              ${None}

${REPORT}                                           ${True}
${RESTORE_TO_TARGET_SW}                             ${True}
${SWCONFIG_PATH}                                    commissionings/Krakow/swconfig/default_swconfig.txt
${SCF_PREFIX_TAG}                                   ${None}
${BSR_CONFIG_FILE}                                  ${None}
${SHOULD_5G_NEIGHBOUR_BE_CHANGED}                   ${True}
${UPLOAD_SWCONFIG_TO_NEIGHBOUR}                     ${True}
@{PREP_ALLOWED_ALARMS}                              No connection to unit
...                                                 Not able to synchronize baseband bus
...                                                 Configuration mismatch between BSC and BTS
...                                                 OMU signaling connection failure in Abis interface
...                                                 EN DSS De-activated on partner side
@{COMMON_ALLOWED_ALARMS_DURING_TL_PREPARATION}      common_allowed_alarms._allowed_alarms_during_tl_preparation
@{CUSTOM_ALLOWED_ALARMS_DURING_TL_PREPARATION}      @{COMMON_ALLOWED_ALARMS_DURING_TL_PREPARATION}
...                                                 @{PREP_ALLOWED_ALARMS}

# Customer list separated by comma
${CUSTOMERS_LIST}                               ${None}

# Allowed alarms durring all tests
@{CUSTOM_ALLOWED}                 7116
...                               6353

# Certificates configuration - set only when appropriate YAML config file is present in testline_configuration
${CERTIFICATES_PREFIX_TAG}                                   ${None}


*** Test Cases ***
E2E_TL_SW_Upgrade_Rollback_with_OAM_KPI_single_node_upgrade
    # This testcase will upgrade and rollback only node1 in configuration consisting of 3 nodes (defined in NODES variable)
    # Nodes which are not currently upgraded will still be monitored for any impacting faults
    [Timeout]   24h
    E2E TL SW UPGRADE ROLLBACK WITH OAM KPI    ${NODES}  ${NODES}  ${ITERATIONS}    report=${False}

E2E_TL_SW_Upgrade_Rollback_with_OAM_KPI_multiple_node_upgrade
    # This testcase will upgrade and rollback all nodes in configuration consisting of 3 nodes (defined in NODES variable)
    # Nodes will be upgraded in sequence provided in the UPGRADE_NODES, by changing the sequence of the list you change the upgrade sequence
    # In this example: upgrade node2, upgrade node1, upgrade node3, rollback node2, rollback node1, rollback node3
    # Nodes which are not currently upgraded will still be monitored for any impacting faults
    [Tags]    CDRT
    [Timeout]   24h
    E2E TL SW UPGRADE ROLLBACK WITH OAM KPI    ${NODES}  ${UPGRADE_NODES}  ${cdrt_iterations}[SW Upgrade+Rollback]    report=${False}

E2E_TL_Activation_Reset_with_OAM_KPI
    # This testcase will activate sw in loops
    # Starting SW will be candidate software and will be activated alternately to candidate T1 software
    [Tags]    CDRT
    [Timeout]   24h
    E2E TL ACTIVATION RESET TEST    ${NODES}  ${NODES}   ${cdrt_iterations}[SW Activation Reset]    report=${False}

E2E_TL_Site_Reset_with_OAM_KPI
    [Tags]    CDRT
    [Timeout]   24h
    E2E TL SITE RESET WITH OAM KPI    ${NODES}  ${NODES}   ${cdrt_iterations}[Site Reset]    report=${False}

E2E_TL_Power_Site_Reset_with_OAM_KPI
    [Timeout]   24h
    E2E TL POWER SITE RESET WITH OAM KPI    ${NODES}  ${NODES}   ${ITERATIONS}
    ...                                     customers_list=${CUSTOMERS_LIST}    report=${False}

E2E_TL_RU_Reset_with_OAM_KPI
    [Tags]    CDRT
    [Timeout]   24h
    E2E TL RU RESET WITH OAM KPI    ${NODES}  ${NODES}  ${cdrt_iterations}[RU Reset]
    ...                             customers_list=${CUSTOMERS_LIST}    report=${False}

E2E_TL_Capacity_Module_Reset_with_OAM_KPI
    [Tags]    CDRT
    [Timeout]   24h
    E2E TL CAPACITY MODULE RESET WITH OAM KPI    ${NODES}  ${NODES}  ${cdrt_iterations}[BB Reset]
    ...                                          customers_list=${CUSTOMERS_LIST}    report=${False}

E2E_TL_Cell_Lock_Unlock_NR_with_OAM_KPI
    [Tags]    CDRT
    [Timeout]   24h
    E2E TL CELL LOCK UNLOCK NR WITH OAM KPI    ${NODES}  ${NODES}  ${cdrt_iterations}[Cell lock/unlock]
    ...                                        customers_list=${CUSTOMERS_LIST}    report=${False}

E2E_TL_Cell_Lock_Unlock_LTE_with_OAM_KPI
    [Tags]    CDRT
    [Timeout]   24h
    E2E TL CELL LOCK UNLOCK LTE WITH OAM KPI    ${NODES}  ${NODES}  ${cdrt_iterations}[Cell lock/unlock]    report=${False}

E2E_TL_Cell_Block_Unblock_LTE_with_OAM_KPI
    [Tags]    CDRT
    [Timeout]   24h
    E2E TL CELL BLOCK UNBLOCK LTE WITH OAM KPI    ${NODES}  ${NODES}  ${cdrt_iterations}[Cell block/unblock]    report=${False}

E2E_TL_Cell_Block_Unblock_NR_with_OAM_KPI
    [Tags]    CDRT
    [Timeout]   24h
    E2E TL CELL BLOCK UNBLOCK NR WITH OAM KPI    ${NODES}  ${NODES}  ${cdrt_iterations}[Cell block/unblock]    report=${False}

E2E_TL_Cell_Block_Unblock_GSM_with_OAM_KPI
    [Tags]    CDRT
    [Timeout]   24h
    E2E TL CELL BLOCK UNBLOCK GSM WITH OAM KPI    ${NODES}  ${NODE1}  ${cdrt_iterations}[Cell block/unblock]    report=${False}

E2E_TL_Delta_Commissioning_With_Online_Parameter_Modification
    [Tags]    CDRT
    [Timeout]   24h
    ${delta1}    get_delta_commissioning_with_online_parameter_modification    node=${NODE1}
    E2E TL DELTA COMMISSIONING WITH ONLINE PARAMETER MODIFICATION    ${NODES}  ${NODE1}
    ...                                                              ${cdrt_iterations}[Delta Commissioning with online parameter change]
    ...                                                              report=${False}
    ...                                                              delta=${delta1}
    ${delta2}    get_delta_commissioning_with_online_parameter_modification    node=${NODE2}
    E2E TL DELTA COMMISSIONING WITH ONLINE PARAMETER MODIFICATION    ${NODES}  ${NODE2}
    ...                                                              ${cdrt_iterations}[Delta Commissioning with online parameter change]
    ...                                                              report=${False}
    ...                                                              delta=${delta2}

E2E_TL_Delta_Commissioning_With_Site_Reset_Required
    [Tags]    CDRT
    [Timeout]   24h
    ${delta1}    get_delta_commissioning_with_site_reset_required    node=${NODE1}
    E2E TL DELTA COMMISSIONING WITH SITE RESET REQUIRED    ${NODES}  ${NODE1}
    ...                                                    ${cdrt_iterations}[Delta Commissioning with Site Reset]    report=${False}
    ...                                                    delta=${delta1}
    ${delta2}    get_delta_commissioning_with_site_reset_required    node=${NODE2}
    E2E TL DELTA COMMISSIONING WITH SITE RESET REQUIRED    ${NODES}  ${NODE2}
    ...                                                    ${cdrt_iterations}[Delta Commissioning with Site Reset]    report=${False}
    ...                                                    delta=${delta2}
E2E_TL_Delta_Commissioning_With_LTE_Rat_Reset
    [Tags]    CDRT
    [Timeout]   24h
    ${delta1}    get_delta_commissioning_with_lte_rat_reset    node=${NODE1}
    E2E TL DELTA COMMISSIONING WITH LTE RAT RESET    ${NODES}  ${NODE1}
    ...                                              ${cdrt_iterations}[Delta Commissioning with RAT reset]    report=${False}
    ...                                              delta=${delta1}
    ${delta2}    get_delta_commissioning_with_lte_rat_reset    node=${NODE2}
    E2E TL DELTA COMMISSIONING WITH LTE RAT RESET    ${NODES}  ${NODE2}
    ...                                              ${cdrt_iterations}[Delta Commissioning with RAT reset]    report=${False}
    ...                                              delta=${delta2}

E2E_TL_Delta_Commissioning_With_NR_Rat_Reset
    [Tags]    CDRT
    [Timeout]   24h
    ${delta1}    get_delta_commissioning_with_nr_rat_reset    node=${NODE1}
    E2E TL DELTA COMMISSIONING WITH NR RAT RESET    ${NODES}  ${NODE1}
    ...                                             ${cdrt_iterations}[Delta Commissioning with RAT reset]    report=${False}
    ...                                             delta=${delta1}
    ${delta2}    get_delta_commissioning_with_nr_rat_reset    node=${NODE2}
    E2E TL DELTA COMMISSIONING WITH NR RAT RESET    ${NODES}  ${NODE2}
    ...                                             ${cdrt_iterations}[Delta Commissioning with RAT reset]    report=${False}
    ...                                             delta=${delta2}

E2E_TL_Delta_Commissioning_With_GSM_Rat_Reset
    [Tags]    CDRT
    [Timeout]   24h
    ${delta1}    get_delta_commissioning_with_gsm_rat_reset    node=${NODE1}
    E2E TL DELTA COMMISSIONING WITH GSM RAT RESET    ${NODES}  ${NODE1}
    ...                                              ${cdrt_iterations}[Delta Commissioning with RAT reset]    report=${False}
    ...                                              delta=${delta1}

E2E_TL_BTS_Block_Unblock
    [Timeout]   24h
    E2E TL BTS BLOCK UNBLOCK    ${NODES}  ${NODES}  ${ITERATIONS}    report=${False}

E2E_TL_RU_Lock_Unlock
    [Timeout]   24h
    E2E TL RU LOCK UNLOCK    ${NODES}  ${NODES}  ${ITERATIONS}    report=${False}

E2E_TL_RU_Power_Reset
    [Timeout]   24h
    ${ru_pdu_mapping}    prepare_pdus_for_radios
    E2E TL RU POWER RESET    ${NODES}  ${NODES}  ${ITERATIONS}    report=${False}    rmods_with_pdu_ports=${ru_pdu_mapping}

E2E_TL_Capacity_Module_Lock_Unlock
    [Timeout]   24h
    E2E TL CAPACITY MODULE LOCK UNLOCK    ${NODES}  ${NODES}  ${ITERATIONS}    report=${False}

E2E_TL_SW_Download_Test
    [Timeout]   24h
    E2E TL SW DOWNLOAD TEST   ${NODES}  ${NODES}  ${ITERATIONS}    report=${False}

E2E_TL_Parallel_SW_Download_Test
    [Timeout]   24h
    E2E TL PARALLEL SW DOWNLOAD TEST    ${NODES}  ${NODES}  ${ITERATIONS}    report=${False}

E2E_TL_Mantaray_Upgrade_Rollback_Fallback_Test
    [Timeout]   24h
    log    ${NETACT_DICT}
    NETACT FEATURE TEST    ${NODES}  ${NODES}  ${ITERATIONS}    netact_dict=${NETACT_DICT}    report=${False}

*** Keywords ***
Collect Mandatory Logs
    [Arguments]    ${log_dir}=${None}    ${gnb_ids}=${None}    ${enb_ids}=${None}
    Custom Mandatory Logs Collection    log_dir=${log_dir}    gnb_ids=${gnb_ids}    enb_ids=${enb_ids}


Define Nodes
    # Node definitions for the test configuration
    # Single BTS or fullrack (dualcore, including Airscale + FSM3) configurations require one node
    # 4G5G configurations require two nodes
    # Define nodes based on logical BTS count
    # Node information includes mainly VM IP and software versions; other details are fetched automatically

    &{NODE1}                            Create Dictionary
    ...                                 testline_object=${tl.gnbs[0]}
    ...                                 source_sw=${SOURCE_SW}
    ...                                 target_sw=${TARGET_SW}
    ...                                 custom_allowed_alarms=${custom_allowed_alarms_node_1}
    ...                                 check_amf=${False}
    ...                                 admin_setup_timeout=${600}

    &{NODE2}                            Create Dictionary
    ...                                 testline_object=${tl.gnbs[1]}
    ...                                 source_sw=${SOURCE_SW}
    ...                                 target_sw=${TARGET_SW}
    ...                                 custom_allowed_alarms=${custom_allowed_alarms_node_2}
    ...                                 admin_setup_timeout=${600}

    # List of nodes passed to test keywords
    @{NODES}                    Create List    ${NODE1}    ${NODE2}
    @{UPGRADE_NODES}            Create List    ${NODE2}    ${NODE1}

    Set Global Variable     &{NODE1}
    Set Global Variable     &{NODE2}
    Set Global Variable     @{NODES}
    Set Global Variable     @{UPGRADE_NODES}

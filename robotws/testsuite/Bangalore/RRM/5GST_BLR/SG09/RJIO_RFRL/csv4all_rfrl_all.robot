*** Settings ***
Documentation       Test suite for basic CSV4ALL Tests in loop
...                 Author: Damian Pietrzyk
...                 Contact: damian.pietrzyk@nokia.com


Library             taf/rfrl/csv4all/CSV4AllTestCases.py

*** Variables ***
@{CUSTOM_ALARMS}=               4298  4694  6150  6351  7509  7513  8150  61631  4527  7307  62003  6450  7115  8000  4569
${ITERATIONS}                   3
${QC_REPORT}                    ${True}
${QC_DOMAIN}=                   MN_RAN
${QC_PROJECT}=                  RAN_VRF
${RP_CA}                        VRF_RRM
${RP_LOCATION}                  VRF_BLR1
${RP_ORGANIZATION}              VRF_BLR1_T08
@{CUSTOMERS_LIST}=              Reliance India
${INITIAL_SW}=                  SBTS24R3_ENB_0000_001040_000007
${TARGET_SW}=                   SBTS25R1_ENB_0000_000756_000000
${DOWNLOAD_PATH}=               /home/ute/UUF_SW/
&{NODE1}                        node_vm=10.58.238.158
...                             source_sw=${INITIAL_SW}
...                             target_sw=${TARGET_SW}
...                             temporary_allowed_alarms=${1234, 2345}
...                             custom_allowed_alarms=${CUSTOM_ALARMS}
${report}                       ${True}
@{NODES}                        ${NODE1}
@{UPGRADE_NODES}                ${NODE1}

*** Test Cases ***
E2E_TL_SW_Upgrade_Rollback_with_OAM_KPI_single_node_upgrade
    [Timeout]   24h
    Set Test Variable  &{OAM_KPI_TARGETS}     kpi2a=500
    ...                                       kpi2b=500
    ...                                       kpi2c=500
    ...                                       kpi2d=500
    Set Test Variable  ${ALARM_TIMEOUT}  180
    Set Test Variable  ${HARDWARE_CHECK_TIMEOUT}  900
    Set Test Variable  @{SYSLOG_IGNORED_PRINTS}  INF
    e2e_tl_sw_upgrade_rollback_with_oam_kpi
    ...          nodes_details=${NODES}
    ...          test_nodes_details=${NODE1}
    ...          iterations_per_node=${ITERATIONS}
    ...          report=${report}
    ...          calculate_kpi=${True}
    ...          customers_list=${CUSTOMERS_LIST}
    ...          use_dcap=${False}
    ...          download_path=${DOWNLOAD_PATH}
    ...          kpi_targets=${OAM_KPI_TARGETS}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=
    ...          qc_project=${QC_PROJECT}


E2E_TL_Site_Reset_without_HWF_with_OAM_KPI
    [Timeout]   24h
    Set Test Variable  &{OAM_KPI_TARGETS}     kpi1a=300    kpi1b=300    kpi1c=300
    CSV4AllTestCases.e2e_tl_site_reset_without_hwf_with_oam_kpi
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODE1}
    ...    iterations_per_node=10
    ...    customers_list=${CUSTOMERS_LIST}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_id=
    ...    qc_project=${QC_PROJECT}
    ...    report=${report}

E2E_TL_RU_Reset_with_OAM_KPI
    [Timeout]   24h
    Set Test Variable  &{OAM_KPI_TARGETS}     kpi51a=200    kpi51b=200
    CSV4AllTestCases.e2e_tl_ru_reset_with_oam_kpi
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODE1}
    ...    iterations_per_node=${ITERATIONS}
    ...    customers_list=${CUSTOMERS_LIST}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_id=
    ...    qc_project=${QC_PROJECT}
    ...    report=${report}

E2E_TL_Cell_Lock_Unlock_NR_with_OAM_KPI
    [Timeout]   24h
    Set Test Variable  &{OAM_KPI_TARGETS}     kpi16a=35    kpi16b=35
    CSV4AllTestCases.e2e_tl_cell_lock_unlock_nr_with_oam_kpi
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODE1}
    ...    iterations_per_node=${ITERATIONS}
    ...    customers_list=${CUSTOMERS_LIST}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_id=
    ...    qc_project=${QC_PROJECT}
    ...    report=${report}

E2E_TL_Cell_Block_Unblock_NR_with_OAM_KPI
    [Timeout]   24h
    Set Test Variable  &{OAM_KPI_TARGETS}     kpi17a=20    kpi17b=20
    CSV4AllTestCases.e2e_tl_cell_block_unblock_nr_with_oam_kpi
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODE1}
    ...    iterations_per_node=${ITERATIONS}
    ...    customers_list=${CUSTOMERS_LIST}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_id=
    ...    qc_project=${QC_PROJECT}
    ...    report=${report}

E2E_TL_Delta_Commissioning_With_Online_Parameter_Modification
    [Timeout]   24h
    CSV4AllTestCases.e2e_tl_delta_commissioning_with_online_parameter_modification
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODE1}
    ...    iterations_per_node=${ITERATIONS}
    ...    customers_list=${CUSTOMERS_LIST}
    ...    delta=${ONLINE_PARAMETER_DELTA}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_id=
    ...    qc_project=${QC_PROJECT}
    ...    report=${report}

E2E_TL_Delta_Commissioning_With_Site_Reset_Required
    [Timeout]   24h
    CSV4AllTestCases.e2e_tl_delta_commissioning_with_site_reset_required
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODE1}
    ...    iterations_per_node=${ITERATIONS}
    ...    customers_list=${CUSTOMERS_LIST}
    ...    delta=${SITE_RESET_DELTA}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_id=
    ...    qc_project=${QC_PROJECT}
    ...    report=${report}

E2E_TL_Delta_Commissioning_With_NR_Rat_Reset
    [Timeout]   24h
    CSV4AllTestCases.e2e_tl_delta_commissioning_with_nr_rat_reset
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODE1}
    ...    iterations_per_node=${ITERATIONS}
    ...    customers_list=${CUSTOMERS_LIST}
    ...    delta=${NR_RAT_RESET_DELTA}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_id=
    ...    qc_project=${QC_PROJECT}
    ...    report=${report}
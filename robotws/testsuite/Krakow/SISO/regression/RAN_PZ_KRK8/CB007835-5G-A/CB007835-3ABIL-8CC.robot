*** Settings ***
Documentation
...   Test suite for regression testing of feature CB007835-A
...   author: Mateusz Iwankiewicz
...   contact: mateusz.iwankiewicz@nokia.com

Library      String
Library      taf.rfrl.csv4all.CSV4AllTestCases
Library      ute_ue
Library      taf.rfrl.bts.devices.du.logs_collecting.btslog_collector.GnbBtslogCollector
...          WITH NAME    btslog_collector
Library      taf.rfrl.bts.devices.du.cell_operations.GnbCellOperations    WITH NAME    cell_operations
Library      ../../../regression/RAN_PZ_KRK1/CB007835/resources/resources.py
...          WITH NAME    imported_resources
Library      taf.rfrl.utilities.cloud_manager.artifacts
Library      taf/rfrl/procedures/resources/python/setups_and_teardowns_keywords.py
Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource     ./resources/keywords.robot
Variables    ./resources/variables.py
Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py

Test Timeout  96 hours
Force Tags    STATE_SW_UPLOADED    PY39    CLOUD_5G_CLASSICAL_ASIK_3xABIL_3xAEWB    CDRT    CRT
...    CA_VRF_KRK    QCD_MN_RAN    QCP_RAN_VRF

Suite Setup       Test Suite Setup
Suite Teardown    Test Suite Teardown

Test Setup        Custom Test Setup
Test Teardown     Custom Test Teardown

*** Variables ***
################## Call Processing ####################
${interval}                    15
${throughput_duration}         20min
${divisor}                     ${900000}

# single ue tput config ##################
${single_ue_tput_dl}           4000Mbits/sec
${single_ue_tput_ul}           250Mbits/sec

${min_single_ue_tput_dl}       3700Mbits/sec
${min_single_ue_tput_ul}       215Mbits/sec

# endc tput config #######################
${endc_tput_dl}                4200Mbits/sec
${min_endc_tput_dl_5G}         4000Mbits/sec
${min_endc_tput_dl_4G}         92000

${endc_tput_ul}                300Mbits/sec
${min_endc_tput_ul_5G}         240Mbits/sec
${min_endc_tput_ul_4G}         32000

# multi ue tput config ###################
${multi_ue_tput_dl}            3000Mbits/sec
${multi_ue_tput_ul}            125Mbits/sec

${min_multi_ue_tput_dl}        2000Mbits/sec
${min_multi_ue_tput_ul}        115Mbits/sec

############### OAM and UUF #########################
@{CUSTOMERS_LIST}              TMO US
${QC_DOMAIN}                   MN_RAN
${QC_PROJECT}                  RAN_VRF
${TOPOLOGY}                    CLOUD_5G_CLASSICAL_ASIK_3xABIL_3xAEWB
${runs_of_uuf_reset}           ${30}
${runs_of_activation_reset}    ${20}
${runs_of_uuf_upgrade}         ${5}
${runs_of_ru_reset}            ${20}
${runs_of_bb_reset}            ${10}
${test_iteration}              ${5}
${SOURCE_SW}                   ${None}
${TARGET_SW}                   ${None}
@{CUSTOM_ALARMS}               7308  7319  4125  4405  4153  4452  1898  4123  4298
@{IGNORED_PRINTS}              is not defined in SysinfoQuota.xml. Please contact the owner
${SHOULD_BE_REPORTED}          ${True}

&{NODE1}                       testline_object=${tl.gnbs[0]}
...                            source_sw=${SOURCE_SW}
...                            target_sw=${TARGET_SW}
...                            custom_allowed_alarms=${CUSTOM_ALARMS}
...                            syslog_ignored_prints=${IGNORED_PRINTS}

@{NODES}                       ${NODE1}

${RP_CA}                       VRF_RRM
${RP_ORGANIZATION}             VRF_KRK_T08
${RP_LOCATION}                 VRF_KRK

############### Test Setup ###############
${TARGET_DIR}                  /home/ute/Downloads
${SW_CONFIG_PATH}              commissionings/Krakow/7_7_UTE5GCLOUDT1SK043/swconfig.txt
${SCF_PREFIX}                  8CC_main_gnb

*** Test Cases ***
E2E_TL_SW_upgrade_rollback_with_OAM_KPI_and_L3_Call
    [Documentation]    Performs upgrade and rollback with L3CALL
    Set To Dictionary    ${NODE1}    source_sw    ${SOURCE_SW}
    Set To Dictionary    ${NODE1}    target_sw    ${TARGET_SW}

    Prepare Ue for L3 Call
    ...    capabilities=REAL_UE_2
    E2E TL SW UPGRADE ROLLBACK WITH OAM KPI
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODE1}
    ...    topology=${TOPOLOGY}
    ...    iterations_per_node=1
    ...    customers_list=@{CUSTOMERS_LIST}
    ...    sw_build=${TARGET_SW}
    ...    restore_to_target_sw=${False}
    ...    report=${SHOULD_BE_REPORTED}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_id=${kpi_qc_ids['qc_upgrade_l3call']}
    ...    qc_project=${QC_PROJECT}
    ...    l3_call_method=Simple L3 Call Test
    [Teardown]    Run Keyword And Ignore Error    setups_and_teardowns_keywords.Add Main BTS Metadata to Report

E2E_TL_SW_upgrade_rollback_with_OAM_KPI
    [Documentation]    Performs 5 iterations of upgrade and rollback and checks if no additional faults has appeared.
    Set To Dictionary    ${NODE1}    source_sw    ${SOURCE_SW}
    Set To Dictionary    ${NODE1}    target_sw    ${TARGET_SW}

    E2E TL SW UPGRADE ROLLBACK WITH OAM KPI
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODE1}
    ...    topology=${TOPOLOGY}
    ...    iterations_per_node=${runs_of_uuf_upgrade}
    ...    customers_list=@{CUSTOMERS_LIST}
    ...    sw_build=${TARGET_SW}
    ...    restore_to_target_sw=${True}
    ...    report=${SHOULD_BE_REPORTED}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_id=${kpi_qc_ids['qc_upgrade']}
    ...    qc_project=${QC_PROJECT}
    [Teardown]    Run Keyword And Ignore Error    setups_and_teardowns_keywords.Add Main BTS Metadata to Report

CB007835-5G-A_19_BiDir_TCP_SU_throughput_1S-2CC-2DL-2UL-6CC-2DL-0UL_sector_1
    [Documentation]    Performs bidirectional throughput test for single UE for 20 min.
    keywords.Prepare Ue    UE_1     REAL_UE_3
    imported_resources.Perform Bidirectional Throughput Test For Single Ue    ue_alias=UE_1    duration=20min
    ...    protocol=tcp    tput_dl=${single_ue_tput_dl}    tput_min_dl=${min_single_ue_tput_dl}
    ...    parallel_streams_dl=6    tput_ul=${single_ue_tput_ul}    tput_min_ul=${min_single_ue_tput_ul}
    ...    linux_congestion=reno    max_segment_size=1450    parallel_streams_ul=2
    [Teardown]    Run Keywords   Run Keyword And Ignore Error    setups_and_teardowns_keywords.Add Main BTS Metadata to Report
    ...    AND   ute_ue.Detach Ue    UE_1

CB007835-5G-A_25_Attach_tput_mix_3min_parallel
    [Documentation]    Performs 5 iterations of attach and L3 call for 4 minutes for single UE.
    Prepare Ue    UE_1    REAL_UE_3
    imported_resources.Attach Throughput Detach    UE_1    iteration=5    duration=4min    protocol=tcp
    ...    tput_ul=${single_ue_tput_ul}    tput_min_ul=180Mbits/sec   parallel_streams_ul=2
    ...    tput_dl=${single_ue_tput_dl}    tput_min_dl=3400Mbits/sec   parallel_streams_dl=6
    ...    max_segment_size=1450
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    setups_and_teardowns_keywords.Add Main BTS Metadata to Report
    ...    AND   ute_ue.Detach Ue    UE_1

CB007835-5G-A_26_20min_BiDir_UDP_TCP_2UE_throughput_8CC+2CCUL
    [Documentation]    Performs bidirectional throughput test for multi UE for 20 min.
    Prepare Ue    UE_1    REAL_UE_2
    Prepare Ue    UE_2    REAL_UE_3
    ${ue_aliases} = 	Create List 	UE_1 	UE_2
    imported_resources.Perform Bidirectional Throughput Test For Multi Ue    ${ue_aliases}    duration=20min
    ...    protocol=tcp    tput_ul=${multi_ue_tput_ul}    tput_dl=${multi_ue_tput_dl}
    ...    tput_min_ul=${min_multi_ue_tput_ul}    tput_min_dl=${min_multi_ue_tput_dl}
    ...    parallel_streams_dl=6    parallel_streams_ul=2
    ...    linux_congestion=reno   max_segment_size=1450
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    setups_and_teardowns_keywords.Add Main BTS Metadata to Report    AND
    ...    ute_ue.Detach Ue    UE_1    AND    ute_ue.Detach Ue    UE_2

CB007835-5G-A_26_20min_BiDir_UDP_TCP_2UE_delay_throughput_8CC+2CCUL
    [Documentation]    Performs bidirectional throughput test for multi UE with 1 min delay between for 20 min.
    Prepare Ue    UE_1    REAL_UE_2
    Prepare Ue    UE_2    REAL_UE_3
    ${ue_aliases} = 	Create List 	UE_1 	UE_2
    imported_resources.Perform Bidirectional Tcp Throughput Test For Multi Ue with Delay    ${ue_aliases}
    ...    duration=20min    tput_min_ul=${min_single_ue_tput_ul}    parallel_streams_ul=2
    ...    tput_min_dl=${min_single_ue_tput_dl}    parallel_streams_dl=6    delay=1min    max_segment_size=1450
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    setups_and_teardowns_keywords.Add Main BTS Metadata to Report    AND
    ...    ute_ue.Detach Ue    UE_1    AND    ute_ue.Detach Ue    UE_2

E2E_TL_Capacity_Module_Reset_with_OAM_KPI
    [Documentation]    Performs 10 iterations of baseband module reset and checks if no additional faults has appeared.
    E2E TL CAPACITY MODULE RESET WITH OAM KPI
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODE1}
    ...    iterations_per_node=${runs_of_bb_reset}
    ...    report=${SHOULD_BE_REPORTED}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_id=${kpi_qc_ids['qc_capacity_reset']}
    ...    qc_project=${QC_PROJECT}
    ...    customers_list=@{CUSTOMERS_LIST}
    ...    topology=${TOPOLOGY}
    [Teardown]    Run Keyword And Ignore Error    setups_and_teardowns_keywords.Add Main BTS Metadata to Report

E2E_TL_RU_Reset_with_OAM_KPI
    [Documentation]    Performs 20 iterations of radio module reset and checks if no additional faults has appeared.
    E2E TL RU RESET WITH OAM KPI
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODE1}
    ...    iterations_per_node=${runs_of_ru_reset}
    ...    report=${SHOULD_BE_REPORTED}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_id=${kpi_qc_ids['qc_ru_reset']}
    ...    qc_project=${QC_PROJECT}
    ...    customers_list=@{CUSTOMERS_LIST}
    ...    topology=${TOPOLOGY}
    [Teardown]    Run Keyword And Ignore Error    setups_and_teardowns_keywords.Add Main BTS Metadata to Report

E2E_TL_Cell_Lock_Unlock_NR_with_OAM_KPI
    [Documentation]    Performs 5 iterations of cell lock/unlock and checks if no additional faults has appeared.
    E2E TL CELL LOCK UNLOCK NR WITH OAM KPI
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODE1}
    ...    iterations_per_node=${test_iteration}
    ...    report=${SHOULD_BE_REPORTED}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_id=${kpi_qc_ids['qc_cell_lock_unlock']}
    ...    qc_project=${QC_PROJECT}
    ...    customers_list=@{CUSTOMERS_LIST}
    ...    topology=${TOPOLOGY}
    [Teardown]    Run Keyword And Ignore Error    setups_and_teardowns_keywords.Add Main BTS Metadata to Report

E2E_TL_Cell_Block_Unblock_NR_with_OAM_KPI
    [Documentation]    Performs 5 iterations of cell block/unblock and checks if no additional faults has appeared.
    E2E TL CELL BLOCK UNBLOCK NR WITH OAM KPI
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODE1}
    ...    iterations_per_node=${test_iteration}
    ...    report=${SHOULD_BE_REPORTED}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_id=${kpi_qc_ids['qc_cell_block_unblock_v2']}
    ...    qc_project=${QC_PROJECT}
    ...    customers_list=@{CUSTOMERS_LIST}
    ...    topology=${TOPOLOGY}
    [Teardown]    Run Keyword And Ignore Error    setups_and_teardowns_keywords.Add Main BTS Metadata to Report

E2E_TL_Delta_Commissioning_With_Online_Parameter_Modification
    [Documentation]    Performs recomissioning with online parameter modification and checks if no additional faults has appeared.
    E2E TL DELTA COMMISSIONING WITH ONLINE PARAMETER MODIFICATION
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODE1}
    ...    iterations_per_node=1
    ...    report=${SHOULD_BE_REPORTED}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_id=${kpi_qc_ids['commissioning_online']}
    ...    qc_project=${QC_PROJECT}
    ...    customers_list=@{CUSTOMERS_LIST}
    ...    topology=${TOPOLOGY}
    [Teardown]    Run Keyword And Ignore Error    setups_and_teardowns_keywords.Add Main BTS Metadata to Report

E2E_TL_Delta_Commissioning_With_Site_Reset_Required
    [Documentation]    Performs recomissioning with site reset and checks if no additional faults has appeared.
    E2E TL DELTA COMMISSIONING WITH SITE RESET REQUIRED
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODE1}
    ...    iterations_per_node=1
    ...    report=${SHOULD_BE_REPORTED}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_id=${kpi_qc_ids['commissioning_reset']}
    ...    qc_project=${QC_PROJECT}
    ...    customers_list=@{CUSTOMERS_LIST}
    ...    topology=${TOPOLOGY}
    [Teardown]    Run Keyword And Ignore Error    setups_and_teardowns_keywords.Add Main BTS Metadata to Report

E2E_TL_Delta_Commissioning_With_NR_Rat_Reset
    [Documentation]    Performs recomissioning with rat reset and checks if no additional faults has appeared.
    E2E TL DELTA COMMISSIONING WITH NR RAT RESET
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODE1}
    ...    iterations_per_node=1
    ...    report=${SHOULD_BE_REPORTED}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_id=${kpi_qc_ids['commissioning_rat']}
    ...    delta=testsuite/Krakow/SISO/regression/RAN_PZ_KRK8/CB007835-5G-A/resources/delta_rat.json
    ...    qc_project=${QC_PROJECT}
    ...    customers_list=@{CUSTOMERS_LIST}
    ...    topology=${TOPOLOGY}
    [Teardown]    Run Keyword And Ignore Error    setups_and_teardowns_keywords.Add Main BTS Metadata to Report

E2E_TL_Activation_Reset_with_OAM_KPI
    [Documentation]    Performs 20 iterations of activation reset and checks if no additional faults has appeared.
    E2E TL ACTIVATION RESET TEST
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODE1}
    ...    topology=${TOPOLOGY}
    ...    iterations_per_node=${runs_of_activation_reset}
    ...    customers_list=@{CUSTOMERS_LIST}
    ...    report=${SHOULD_BE_REPORTED}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_id=${kpi_qc_ids['qc_activation_reset']}
    ...    qc_project=${QC_PROJECT}
    [Teardown]    Run Keyword And Ignore Error    setups_and_teardowns_keywords.Add Main BTS Metadata to Report

E2E_TL_Site_Reset_with_OAM_KPI
    [Documentation]    Performs 30 iterations of site reset and checks if no additional faults has appeared.
    E2E TL SITE RESET WITH OAM KPI
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODE1}
    ...    topology=${TOPOLOGY}
    ...    iterations_per_node=${runs_of_uuf_reset}
    ...    customers_list=@{CUSTOMERS_LIST}
    ...    report=${SHOULD_BE_REPORTED}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_id=${kpi_qc_ids['qc_site_reset']}
    ...    qc_project=${QC_PROJECT}
    [Teardown]    Run Keyword And Ignore Error    setups_and_teardowns_keywords.Add Main BTS Metadata to Report

*** Keywords ***
Prepare Ue
    [Arguments]    ${ue_alias}    ${capability}
    ute_ue.Require Ue    ue_alias=${ue_alias}    capabilities=${capability}
    ute_ue.Detach Ue    ${ue_alias}
    Sleep    1s
    ute_ue.Attach Ue    ${ue_alias}
    Sleep    3s
    Check Signal Strength For Ue    ${ue_alias}



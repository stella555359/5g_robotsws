*** Settings ***
Documentation
...   Suite for Antina CSV regression testing
...   author: Maksymilian Wolek
...   contact: maksymilian.wolek@nokia.com

Library      taf.rfrl.csv4all.CSV4AllTestCases
Library      resources/keywords.py
Library      taf.rfrl.bts.devices.du.combined.cell_operations
Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource     resources/keywords.robot
Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Variables    resources/parameters.py

Force Tags    CA_VRF_KRK    QCD_MN_RAN    QCP_RAN_VRF


Suite Setup       Run Keywords     Custom Suite Setup    AND    Prepare QC Ids And UE Data For Test Cases
Suite Teardown    common_setups_and_teardowns.Common Suite Teardown


Test Setup        Custom Test Setup
Test Teardown     common_setups_and_teardowns.Common Postconditions With Restore Configuration If Test Failed

*** Variables ***
${SOURCE_SW}                         ${None}
${TARGET_SW}                         ${None}



${CUSTOMERS_LIST}                    Antina Pte
@{CUSTOM_ALLOWED_ALARMS}             4459    8000    7316    7317   7305
@{PREP_ALLOWED_ALARMS}               Dead Peer Detected
${REPORT}                            ${True}
${RESTORE_TO_TARGET_SW}              ${True}

${CA_1_PATH}=                        ${CURDIR}/resources/certs/ca_1_cert.pem
${CA_2_PATH}=                        ${CURDIR}/resources/certs/ca_2_cert.pem
${SWCONFIG_PATH}                     commissionings/Krakow/swconfig/default_swconfig.txt

${QC_DOMAIN}                         MN_RAN
${QC_PROJECT}                        RAN_VRF

${UPDATE_TEST_ITERATION}             2
${ACTIVATION_TEST_ITERATION}         10
${DELTA_COMMISSIONING_ITERATIONS}    1
${LOCK_UNLOCK_ITERATIONS}            6
${BBMOD_RESET_ITERATIONS}            10
${RU_RESET_ITERATIONS}               20
${BTS_POWER_ON_ITERATIONS}           5
${RU_POWER_RESET_ITERATIONS}         5
${SITE_RESET_ITERATIONS}             10
${BTS_POWER_CYCLE_ITERATIONS}        5

&{NODE1}                             testline_object=${tl.gnbs[0]}
...                                  source_sw=${SOURCE_SW}
...                                  target_sw=${TARGET_SW}
...                                  custom_allowed_alarms=${CUSTOM_ALLOWED_ALARMS}

@{NODES}                             ${NODE1}

${LOGS_PATH}                         /home/ute/test_results

${RP_CA}                             VRF_OAM
${RP_ORGANIZATION}                   VRF_KRK_T07
${RP_LOCATION}                       VRF_KRK

&{snmp_user}                         userName=administrator    authKey=password    privKey=password    authProtocol=MD5    privProtocol=AES
${PDU_HOST}                          pa05.mgt.krk-lab.nsn-rdnet.net

*** Test Cases ***

E2E_TL_SW_Upgrade_Rollback_with_OAM_KPI
    [Timeout]    96h
    [Tags]    UUF

    Set To Dictionary    ${NODE1}    source_sw    ${SOURCE_SW}
    Set To Dictionary    ${NODE1}    target_sw    ${TARGET_SW}

    E2E TL SW UPGRADE ROLLBACK WITH OAM KPI
    ...                                     nodes_details=${NODES}
    ...                                     test_nodes_details=${NODE1}
    ...                                     iterations_per_node=${UPDATE_TEST_ITERATION}
    ...                                     report=${REPORT}
    ...                                     qc_domain=${QC_DOMAIN}
    ...                                     qc_project=${QC_PROJECT}
    ...                                     qc_id=${QC_IDS['qc_upgrade']}
    ...                                     sw_build=${TARGET_SW}
    ...                                     customers_list=@{CUSTOMERS_LIST}
    ...                                     restore_to_target_sw=${RESTORE_TO_TARGET_SW}
    ...                                     l3_call_method=L3_call_test
    [Teardown]    Custom Test Teardown

E2E_TL_SW_Upgrade_Rollback_with_OAMKPI_and_L3_call
    Should Be Equal As Strings    ${PREV TEST STATUS}    PASS

Simultaneous_Single_UE_Bi_Directional_traffic_on_both_PLMNs
    Should Be Equal As Strings    ${PREV TEST STATUS}    PASS

Single_UE_Bi_Directional_traffic
    Should Be Equal As Strings    ${PREV TEST STATUS}    PASS

E2E_TL_Activation_Reset_Test
    [Timeout]    96h
    [Tags]    UUF

    gnbbbu.Disconnect
    E2E TL ACTIVATION RESET TEST
    ...                                     nodes_details=${NODES}
    ...                                     test_nodes_details=${NODE1}
    ...                                     iterations_per_node=${ACTIVATION_TEST_ITERATION}
    ...                                     report=${REPORT}
    ...                                     qc_domain=${QC_DOMAIN}
    ...                                     qc_project=${QC_PROJECT}
    ...                                     qc_id=${QC_IDS['qc_activation']}
    ...                                     sw_build=${TARGET_SW}
    ...                                     customers_list=@{CUSTOMERS_LIST}

Delta_Commissioning_With_Site_Reset_Required
    [Timeout]   24h
    E2E TL DELTA COMMISSIONING WITH SITE RESET REQUIRED    ${NODES}    ${NODE1}    ${DELTA_COMMISSIONING_ITERATIONS}
    ...                                                    customers_list=@{CUSTOMERS_LIST}
    ...                                                    report=${REPORT}
    ...                                                    qc_domain=${QC_DOMAIN}
    ...                                                    qc_project=${QC_PROJECT}
    ...                                                    qc_id=${QC_IDS['qc_delta_reset']}

Delta_Commissioning_With_Pmax_And_Backoffpower_Modification
    [Setup]    Common Preconditions With Watching Alarms    collect_syslog=${False}
    ...                                                     collect_ru_console_log=${False}

    ${bts_id}=    sg7keywords.get_mrbts_id
    Set Test Variable    ${MRBTS_ID}     ${bts_id}
    Check current [pMax] value from [MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1001]
    Set parameter [pMax] from [MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1001] to [160]
    Check current [lowerMcsPowerBackoff] value from [MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1001]
    Set parameter [lowerMcsPowerBackoff] from [MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1001] to [5]

    [Teardown]    Run Keywords    Restore [pMax] from [MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1001] to default value [360]
    ...    Restore [lowerMcsPowerBackoff] from [MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-1001] to default value [14]
    ...    Common Postconditions With Watching Alarms

Cell_Lock_Unlock_NR_with_OAM_KPI
    [Timeout]   24h
    E2E TL CELL LOCK UNLOCK NR WITH OAM KPI    ${NODES}  ${NODE1}  ${LOCK_UNLOCK_ITERATIONS}
    ...                                        customers_list=@{CUSTOMERS_LIST}
    ...                                        report=${REPORT}
    ...                                        qc_domain=${QC_DOMAIN}
    ...                                        qc_project=${QC_PROJECT}
    ...                                        qc_id=${QC_IDS['qc_cell_lock_unlock']}

BB_Module_Reset_with_OAM_KPI
    [Timeout]   24h
    E2E TL CAPACITY MODULE RESET WITH OAM KPI    ${NODES}  ${NODE1}  ${BBMOD_RESET_ITERATIONS}
    ...                                          customers_list=@{CUSTOMERS_LIST}
    ...                                          report=${REPORT}
    ...                                          qc_domain=${QC_DOMAIN}
    ...                                          qc_project=${QC_PROJECT}
    ...                                          qc_id=${QC_IDS['qc_bb_reset']}

RU_Reset_with_OAM_KPI
    [Timeout]   24h
    E2E TL RU RESET WITH OAM KPI    ${NODES}  ${NODE1}  ${RU_RESET_ITERATIONS}
    ...                             customers_list=@{CUSTOMERS_LIST}
    ...                             report=${REPORT}
    ...                             qc_domain=${QC_DOMAIN}
    ...                             qc_project=${QC_PROJECT}
    ...                             qc_id=${QC_IDS['qc_ru_reset']}

RU_Power_Reset
    [Timeout]   24h
    @{PDU_RMODS}=     Prepare Rmods With Pdu Ports
    E2E TL RU POWER RESET    ${NODES}  ${NODE1}  ${RU_POWER_RESET_ITERATIONS}
    ...                      customers_list=@{CUSTOMERS_LIST}
    ...                      report=${REPORT}
    ...                      qc_domain=${QC_DOMAIN}
    ...                      qc_project=${QC_PROJECT}
    ...                      qc_id=${QC_IDS['qc_ru_power_reset']}
    ...                      rmods_with_pdu_ports=${PDU_RMODS}
    ...                      l3_call_method=L3_call_test

RMOD_with_Cell_remove_and_add_with_L3_Call_both_PLMNs
    [Tags]  TC5
    Prepare Cell Before Test    cell_id_to_l3_call=1001
    Add New Cell Based On Existing Cell To Configuration    cell_parameters=${cell}[cell_parameters]
    ...                                                     cell_id_to_copy_from=${cell}[cell_id_to_copy_from]
    ...                                                     group_id=${cell}[group_id]
    ...                                                     nrcell_include_subobject=True
    ...                                                     activate_plan_despite_errors=True

    ${cell_added_successfully}=    Is Cell Added    ${cell}[cell_parameters][lcrId]
    Run Keyword If     ${cell_added_successfully}    Log to Console    Cell added successfully
    gnbcell.Wait For All Cells To Be Onair    timeout=300

    ${cycle}=   Get Ue Cycle By Name    tl_data=${UE_DATA}      cycle_name=cells_to_block_new_cell_n78

    UE Throughput Cycle    cells_to_block=${cycle['cells_to_block']}
        ...                    ue_data=${UE_DATA}
        ...                    ue_key=${cycle['ue_key']}
        ...                    ue_index=${cycle['ue_index']}

    Remove Cell From Configuration    cell_id=${cell}[cell_parameters][lcrId]
    ...                               cell_group_id=${cell}[group_id]

    ${cell_removed_successfully}=    Is Cell Removed    ${cell}[cell_parameters][lcrId]
    Run Keyword If    ${cell_removed_successfully}    Log to Console    Cell removed successfully
    gnbcell.Wait For All Cells To Be Onair    timeout=300
    [Teardown]    Teardown Cell Addition

E2E_TL_Site_Reset_with_OAM_KPI
    [Timeout]   24h
    E2E TL SITE RESET WITH OAM KPI    ${NODES}  ${NODE1}   ${SITE_RESET_ITERATIONS}
    ...                               customers_list=@{CUSTOMERS_LIST}
    ...                               report=${REPORT}
    ...                               qc_domain=${QC_DOMAIN}
    ...                               qc_project=${QC_PROJECT}
    ...                               qc_id=${QC_IDS['qc_site_reset']}

E2E_TL_Power_Site_Reset_with_OAM_KPI
    [Timeout]   24h
    E2E TL POWER SITE RESET WITH OAM KPI    ${NODES}  ${NODE1}   ${BTS_POWER_CYCLE_ITERATIONS}
    ...                                                    customers_list=@{CUSTOMERS_LIST}
    ...                                                    report=${REPORT}
    ...                                                    qc_domain=${QC_DOMAIN}
    ...                                                    qc_project=${QC_PROJECT}
    ...                                                    qc_id=${QC_IDS['bts_power_cycle']}

*** Settings ***
Documentation
...   Generic suite for  testing UUF

Library      String
Library      taf.rfrl.csv4all.CSV4AllTestCases
Library      taf.rfrl.utilities.cloud_manager.artifacts
Library      testsuite/Krakow/resources/UUF/get_uuf_builds.py
Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Resource     ./resources/keywords.robot

Suite Setup       Common Suite Setup
Suite Teardown    common_setups_and_teardowns.Common Suite Teardown

Test Setup        Custom Test Setup
Test Teardown     common_setups_and_teardowns.Common Postconditions With Restore Configuration If Test Failed

*** Variables ***
${SOURCE_SW}                        SBTS26R1_ENB_0000_000434_000051
${TARGET_SW}                        SBTS00_ENB_9999_260219_000016

@{CUSTOM_ALLOWED_ALARMS}            61648    7115    4420    4123    4125    8150    4459    8000    4728    61646
...                                 Failure in connection between BTS and 3rd party tool
...                                 LMP connectivity detected

&{NETACT_DICT}
...                                 name=${tl.netact_name}
...                                 username=${tl.nms.netact.ssh_connections_info.username}
...                                 password=${tl.nms.netact.ssh_connections_info.password}
...                                 ip_version=IPv4
...                                 security_mode=no TLS
...                                 netact_host_ip=${tl.nms.netact.ssh_connections_info.addr}

&{NODE1}                            testline_object=${tl.gnbs[0]}
...                                 source_sw=${SOURCE_SW}
...                                 target_sw=${TARGET_SW}
...                                 custom_allowed_alarms=${CUSTOM_ALLOWED_ALARMS}

&{NODE2}                            testline_object=${tl.enbs[0]}
...                                 node_alias=4gANCHOR
...                                 source_sw=${SOURCE_SW}
...                                 target_sw=${TARGET_SW}
...                                 custom_allowed_alarms=${CUSTOM_ALLOWED_ALARMS}
...                                 testline_scout_name=${SCOUT_HOSTNAME}

@{NODES}                            ${NODE1}
@{UPGRADE_NODES}                    ${NODE1}    ${NODE2}

${UPDATE_TEST_ITERATION}                     5
${ACTIVATION_RESET_TEST_ITERATION}           20
${SITE_RESET_TEST_ITERATION}                 10
${BBMOD_RESET_TEST_ITERATION}                10
${SHUB_RESET_TEST_ITERATION}                 20
${CELL_LOCK_UNLOCK_TEST_ITERATION}           3
${CELL_BLOCK_UNBLOCK_TEST_ITERATION}         3
${DELTA_WITH_NR_RAT_RESET_TEST_ITERATION}    1

@{CUSTOMERS_LIST}                   TMO US
${QC_DOMAIN}                        MN_RAN
${QC_PROJECT}                       RAN_VRF

${RP_CA}                            VRF_OAM
${RP_ORGANIZATION}                  VRF_KRK_T07
${RP_LOCATION}                      VRF_KRK

${SCOUT_HOSTNAME}                   7_7_UTE5GCLOUDT1SK114_113

*** Test Cases ***
#E2E_TL_SW_Upgrade_Rollback_with_OAM_KPI
#    [Timeout]    96h
#    [Tags]    uuf    upgrade
#    ${QC_ID}=             bts_data.Get Qc Ids   ${TARGET_SW}
#    E2E TL SW UPGRADE ROLLBACK WITH OAM KPI
#    # Upgrade ONLY 5G
##    ...                                     nodes_details=${NODES}
##    ...                                     test_nodes_details=${NODE1}
#
#    # Upgrade 5G + LTE
#    ...                                     nodes_details=${UPGRADE_NODES}
#    ...                                     test_nodes_details=${UPGRADE_NODES}
#
#    ...                                     iterations_per_node=${UPDATE_TEST_ITERATION}
#    ...                                     report=${True}
#    ...                                     qc_domain=${QC_DOMAIN}
#    ...                                     qc_project=${QC_PROJECT}
#    ...                                     qc_id=${QC_ID['qc_upgrade']}
#    ...                                     sw_build=${TARGET_SW}
#    ...                                     customers_list=@{CUSTOMERS_LIST}
#    ...                                     restore_to_target_sw=${True}
#    [Teardown]    Custom Test Teardown

E2E_TL_Mantaray_Upgrade_Rollback_Fallback_Test
    [Timeout]    24h
    [Tags]    netact    uuf    check
    ${QC_ID}=             bts_data.Get Qc Ids   ${TARGET_SW}
    NETACT FEATURE TEST
    # Upgrade ONLY 5G
    ...                                     nodes_details=${NODES}
    ...                                     test_nodes_details=${NODE1}

    # Upgrade 5G + LTE
#    ...                                     nodes_details=${UPGRADE_NODES}
#    ...                                     test_nodes_details=${UPGRADE_NODES}
    ...                                     netact_dict=${NETACT_DICT}
    ...                                     iterations_per_node=${UPDATE_TEST_ITERATION}
    ...                                     report=${True}
    ...                                     qc_domain=${QC_DOMAIN}
    ...                                     qc_project=${QC_PROJECT}
    ...                                     qc_id=${QC_ID['qc_upgrade']}
    ...                                     customers_list=@{CUSTOMERS_LIST}
    ...                                     restore_to_target_sw=${True}
    ...                                     rollback_reverse_order=${True}
    ...                                     deintegrate_after_test=${False}
    ...                                     integrate_before_test=${True}
    ...                                     cm_provision=${True}
    [Teardown]    Custom Test Teardown

E2E_TL_Activation_Reset_with_OAM_KPI
    [Timeout]    96h
    [Tags]    uuf    activation_reset    26R1
    gnbbbu.Disconnect
    ${QC_ID}=                 bts_data.Get Qc Ids   ${TARGET_SW}
    E2E TL ACTIVATION RESET TEST
    ...                                     nodes_details=${NODES}
    ...                                     test_nodes_details=${NODE1}
    ...                                     iterations_per_node=${ACTIVATION_RESET_TEST_ITERATION}
    ...                                     report=${False}
    ...                                     qc_domain=${QC_DOMAIN}
    ...                                     qc_project=${QC_PROJECT}
    ...                                     qc_id=${QC_ID['qc_activation_reset']}
    ...                                     sw_build=${TARGET_SW}
    ...                                     customers_list=@{CUSTOMERS_LIST}

E2E_TL_Site_Reset_with_OAM_KPI
    [Timeout]    96h
    [Tags]    site_reset    26R1    check
    gnbbbu.Disconnect
    E2E TL SITE RESET WITH OAM KPI
    ...                                     nodes_details=${NODES}
    ...                                     test_nodes_details=${NODE1}
    ...                                     iterations_per_node=${SITE_RESET_TEST_ITERATION}
    ...                                     report=${False}
    ...                                     sw_build=${TARGET_SW}
    ...                                     customers_list=@{CUSTOMERS_LIST}

CB007834_ASiR_TC11_DL_Tput_TCP_NR_2_minutes
    [Tags]    tput    25R2regresion
    [Setup]    Common Preconditions With Watching Alarms

    ### Commercial UE ###
#    Prepare Ue for L3 Call    capabilities=${capabilities}    reboot_ue=${reboot_ue}    timeout_reboot_ue=${timeout_reboot_ue}
#    Verify L3 Call Data Transfer DL&UL    duration=${duration}    tput_dl=${tput_dl}    tput_ul=${tput_ul}
#    ...    protocol=${protocol}    deviation_dl=${deviation_dl}    deviation_ul=${deviation_ul}
#    ...    parallel_streams_dl=${parallel_streams_dl}    parallel_streams_ul=${parallel_streams_ul}
#    ...    size_packet_dl=${size_packet_dl}    size_packet_ul=${size_packet_ul}    buffer_client_dl=${buffer_client_dl}
#    ...    buffer_server_dl=${buffer_server_dl}    buffer_client_ul=${buffer_client_ul}    buffer_server_ul=${buffer_server_ul}
#    ...    interval=${interval}    qci_dl=${qci}    qci_ul=${qci}    linux_congestion_dl=${linux_congestion}
#    ...    linux_congestion_ul=${linux_congestion}
    ###

    ### QUECTEL ###
    Verify L3 Call Quectel
    ###

    Verify Throughput on 5G and 4G
    [Teardown]    Common Postconditions With Watching Alarms

CB007834_ASiR_TC11_5G_Bi-Directional_ENDC_Throughput_TCP
    [Tags]    tput
    Should Be Equal As Strings    ${PREV TEST STATUS}    PASS

CB007834_ASiR_TC12_4G_Bi-Directional_ENDC_Throughput_TCP
    [Tags]    tput
    Should Be Equal As Strings    ${PREV TEST STATUS}    PASS

E2E_TL_SW_upgrade_rollback_with_OAM_KPI_and_L3_Call
    [Tags]    tput
    Should Be Equal As Strings    ${PREV TEST STATUS}    PASS

CB007834_ASIR_TC02_Reconfiguration_WebEM_with_-_without_site_reset
    [Tags]    tc02
    ${nrcell_dist_name}=    Prepare Random Nrcell Dist Name
    &{chBw_value_to_change}=    Create Dictionary    TDD=60MHz    FDD=40MHz
    Change Channel Bandwidth    nrcell_dist_name=${nrcell_dist_name}
    ...                         chBw_new_value=&{chBw_value_to_change}

    Wait Until Keyword Succeeds    600 sec    10 sec    Verify Setup Of All Cells

    sbts_keywords.Parameter Recommissioning    dist_name=${nrcell_dist_name}
    ...                                        parameter=gscnOrSsPbchArfcn
    ...                                        operation=update
    ...                                        value=0

    sbts_keywords.Parameter Recommissioning    dist_name=${nrcell_dist_name}
    ...                                        parameter=type0CoresetConfigurationIndex
    ...                                        operation=update
    ...                                        value=13

    Verify Allowed Alarms on gNB    allowed_alarms=${allowed_alarms}

    &{chBw_value_to_change}=    Create Dictionary    TDD=100MHz    FDD=20MHz
    Change Channel Bandwidth    nrcell_dist_name=${nrcell_dist_name}
    ...                         chBw_new_value=&{chBw_value_to_change}

    Wait Until Keyword Succeeds    600 sec    10 sec    Verify Setup Of All Cells

    sbts_keywords.Parameter Recommissioning    dist_name=${nrcell_dist_name}
    ...                                        parameter=gscnOrSsPbchArfcn
    ...                                        operation=update
    ...                                        value=1

    sbts_keywords.Parameter Recommissioning    dist_name=${nrcell_dist_name}
    ...                                        parameter=type0CoresetConfigurationIndex
    ...                                        operation=update
    ...                                        value=12

    Verify Allowed Alarms on gNB    allowed_alarms=${allowed_alarms}
    Wait Until Keyword Succeeds    60s    5s    Verify Setup Of All Cells
    [Teardown]    Common Postconditions

CB007834_ASiR_TC03_Reconfiguration_ASiR_WebEM_with_-_without_site_reset
    [Tags]    tc03
    &{ANTMOD_status}=    Create Dictionary    operationalState=enabled    localState=unblocked
    Set Test Variable    ${antmod_status}   &{ANTMOD_status}
    Change Asir Parameters Without Site Reset
    [Teardown]    Run Keywords    Restore Default Values    AND    Common Postconditions

CB007834_ASIR_TC05_Reset_BBmode
    [Tags]    tc05    bbmod_reset    rerun
    [Timeout]   24h
    E2E TL CAPACITY MODULE RESET WITH OAM KPI
    ...                                     nodes_details=${NODES}
    ...                                     test_nodes_details=${NODE1}
    ...                                     iterations_per_node=${BBMOD_RESET_TEST_ITERATION}
    ...                                     customers_list=@{CUSTOMERS_LIST}

CB007834_ASIR_TC06_Reset_sHUB_via_ASiR_WebEM
    [Tags]    tc06
    ${site_reset_results}    Run Reset Hub In Loop Via ASiR Cli    iterations=${SHUB_RESET_TEST_ITERATION}
    ...                                                            target=${TARGETS}
    GnbAsir.Verify Only Allowed Alarms Are Active    allowed_alarms=${CUSTOM_ALLOWED_ALARMS}

    ### Commercial UE ###
#    Verify 5G Attach
    ###

    ### QUECTEL ###
    Verify 5G Attach Quectel
    ###

CB007834_ASIR_TC07_Reset_pRRH
    [Tags]    tc07    rerun
    ${start_time}=    sbts_keywords.Get Current Time
    Log To Console    ===Start to reset ANT===
    &{ANTMOD_status}=    Create Dictionary    operationalState=enabled    localState=unblocked
    GnbAsir.Reset Antenna

    Log To Console    ===Waiting for ANT resume===
    Wait Until Keyword Succeeds    60s    5s    GnbAsir.Verify Antmod Status    expected_statuses=${ANTMOD_status}

    Log To Console    ===Waiting for gNB and eNB cells resume===
    Wait Until Keyword Succeeds    70s    5s    Verify Setup Of All Cells    cell_type=nr
    ...                                                                      administrative_state=Unlocked
    ...                                                                      operational_state=Enabled
    ...                                                                      availability_status=Online
    ...                                                                      blocking_state=Unblocked

    Verify Allowed Alarms on gNB    allowed_alarms=${allowed_alarms}
    Verify Alarm Appear In Alarm History    fault_id=4479    start_time=${start_time}
    GnbAsir.Verify Only Allowed Alarms Are Active    allowed_alarms=${allowed_alarms_fault_ids}

CB007834_ASIR_TC08_Block_and_unblock_pRRH_via_ASiR_WebEM
    [Tags]    tc08    rerun

    ${start_time}=    sbts_keywords.Get Current Time
    GnbAsir.Block Antenna
    &{ANTMOD_status}=    Create Dictionary    operationalState=disabled    localState=blocked
    @{cell_id}=    Get WEM Cell Id Of Ant
    Wait Until Keyword Succeeds    20s    5s    GnbAsir.Verify Antmod Status    expected_statuses=${ANTMOD_status}
    Wait Until Keyword Succeeds    30s    5s    GnbAsir.Verify Status Of Asir Cells    cell_ids=@{cell_id}
    ...                                                                                expected_asir_cell_status=failed
    Wait Until Keyword Succeeds    30s    5s    Verify Alarm is Active on gNB    fault_name=Failure detected on assigned antennas
    ...                                                                          fault_id=4479
    GnbAsir.Unblock Antenna
    &{ANTMOD_status}=    Create Dictionary    operationalState=enabled    localState=unblocked
    Wait Until Keyword Succeeds    360s    5s    Verify Setup Of All Cells
    Wait Until Keyword Succeeds    30s    5s    GnbAsir.Verify Antmod Status    expected_statuses=${ANTMOD_status}
    Wait Until Keyword Succeeds    30s    5s    GnbAsir.Verify Status Of Asir Cells    cell_ids=@{cell_id}
    ...                                                                                expected_asir_cell_status=operational
    Verify Allowed Alarms on gNB    allowed_alarms=${allowed_alarms}
    Verify Alarm Appear In Alarm History    fault_id=4479    start_time=${start_time}
    GnbAsir.Verify Only Allowed Alarms Are Active    allowed_alarms=${allowed_alarms_fault_ids}

    ### Commercial UE ###
#    Verify 5G Attach
    ###

    ### QUECTEL ###
    Verify 5G Attach Quectel
    ###

    [Teardown]    Run Keywords    Run Keyword If Test Failed    GnbAsir.Unblock Antenna    AND
    ...                           Common Postconditions

CB007834_ASIR_TC10_Lock_and_unlock_NR_Cell_via_WebEM
    [Tags]    tc10    rerun
    [Timeout]   24h
    E2E TL CELL LOCK UNLOCK NR WITH OAM KPI
    ...                                     nodes_details=${NODES}
    ...                                     test_nodes_details=${NODE1}
    ...                                     iterations_per_node=${CELL_LOCK_UNLOCK_TEST_ITERATION}
    ...                                     customers_list=@{CUSTOMERS_LIST}


E2E_TL_Cell_Block_Unblock_NR_with_OAM_KPI
    [Tags]    cell_block_unblock    rerun
    [Timeout]   24h
    E2E TL CELL BLOCK UNBLOCK NR WITH OAM KPI
    ...                                     nodes_details=${NODES}
    ...                                     test_nodes_details=${NODE1}
    ...                                     iterations_per_node=${CELL_BLOCK_UNBLOCK_TEST_ITERATION}
    ...                                     customers_list=@{CUSTOMERS_LIST}

E2E_TL_Delta_Commissioning_With_NR_Rat_Reset
    [Tags]    delta_nr_rat_reset    rerun
    [Timeout]   24h
    ${DELTA_PARAM}=    Get Nr Rat Reset Delta
    E2E TL DELTA COMMISSIONING WITH ONLINE PARAMETER MODIFICATION
    ...                                     nodes_details=${NODES}
    ...                                     test_nodes_details=${NODE1}
    ...                                     iterations_per_node=${DELTA_WITH_NR_RAT_RESET_TEST_ITERATION}
    ...                                     delta=${DELTA_PARAM}
    ...                                     customers_list=@{CUSTOMERS_LIST}

*** Keywords ***
Remove Dirs
    [Arguments]    @{directory_path}
    FOR    ${dir}    IN    @{directory_path}
        ${status}=    Run Keyword And Return Status    Directory Should Exist    ${dir}
        Run Keyword If    ${status}    Remove Directory    ${dir}    force=True
    END

Custom Test Setup
    common_setups_and_teardowns.Common Preconditions    collect_syslog=${False}
    Remove Dirs       directory_path=/home/ute/.ute-ca/cache/bts/

Custom Test Teardown
    gnbbbu.connect    force=${True}
    common_setups_and_teardowns.Common Postconditions With Restore Configuration If Test Failed

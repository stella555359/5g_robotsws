*** Settings ***
Documentation
...   Test suite for CB007834 E2E TMO
...   author: Dominik Wieczorek
...   contact: dominik.wieczorek@nokia.com

Library      String
Library      taf.rfrl.csv4all.CSV4AllTestCases
Library      taf.rfrl.utilities.cloud_manager.artifacts
Library      testsuite/Krakow/resources/UUF/get_uuf_builds.py
Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Resource     ./resources/keywords.robot

Suite Setup    Custom Suite Setup
Suite Teardown    Common Suite Teardown
Test Setup       Custom Preconditions With Watching Alarms
Test Teardown    Custom Postconditions With Watching Alarms

*** Variables ***
@{PREPARATION_ALARMS}       61510
...                         No connection to unit
...                         Cell problem due to associated X2 links and/or NG links and/or E1 link unavailability
...                         Failure detected on assigned antennas
...                         BTS Operator Certificate retrieval unsuccessful
...                         Automatic BTS Operator Certificate retrieval unsuccessful

@{CUSTOM_ALLOWED_ALARMS}    8000    6261    61510
...                         Failure in connection between BTS and 3rd party tool
...                         Failure in internal BTS connection or connection to 3rd party tool
...                         User Account has Default Password
...                         Cell problem due to associated X2 links and/or NG links and/or E1 link unavailability
...                         Failure detected on assigned antennas
...                         Cell blocked
...                         Setup of X2 connectivity to gNB failed
...                         No X2 link available for a specific LTEENB
...                         No X2 link available
...                         BTS Reset Cause
...                         Cell problem due to unavailability of associated links
...                         BTS Operator Certificate retrieval unsuccessful
...                         Automatic BTS Operator Certificate retrieval unsuccessful

@{ASIR_ALLOWED_ALARMS}      ${61648}

${SOURCE_SW}                ${None}
${TARGET_SW}                ${None}
${LTE_TARGET_SW}            ${None}

&{NETACT_DICT}
...                         name=${tl.netact_name}
...                         username=${tl.nms.netact.ssh_connections_info.username}
...                         password=${tl.nms.netact.ssh_connections_info.password}
...                         ip_version=IPv4
...                         security_mode=no TLS
...                         netact_host_ip=${tl.nms.netact.ssh_connections_info.addr}

&{NODE1}                    testline_object=${tl.gnbs[0]}
...                         source_sw=${SOURCE_SW}
...                         target_sw=${TARGET_SW}
...                         custom_allowed_alarms=${CUSTOM_ALLOWED_ALARMS}
...                         testline_scout_name=${SCOUT_HOSTNAME}

&{NODE2}                    testline_object=${tl.gnbs[1]}
...                         node_alias=4gANCHOR
...                         source_sw=${SOURCE_SW}
...                         target_sw=${LTE_TARGET_SW}
...                         custom_allowed_alarms=${CUSTOM_ALLOWED_ALARMS}
...                         testline_scout_name=${SCOUT_HOSTNAME_LTE}

${SCOUT_HOSTNAME}           ${None}
${SCOUT_HOSTNAME_LTE}       ${None}

@{NR_NODES}                 ${NODE1}
@{UPGRADE_NODES}            ${NODE1}    ${NODE2}

${MR_UPGRADE}               True
${LTE_UPGRADE}              True
${DEINTEGRATE}              True
${CM_PROVISION}             True
${SCF}                      True

${CUSTOMERS_LIST}           TMO US
${QC_DOMAIN}                MN_RAN
${QC_PROJECT}               RAN_VRF

${RP_CA}                    VRF_OAM
${RP_ORGANIZATION}          VRF_KRK_T07
${RP_LOCATION}              VRF_KRK

${UPDATE_TEST_ITERATION}                     5
${ACTIVATION_RESET_TEST_ITERATION}           20
${SITE_RESET_TEST_ITERATION}                 10
${BBMOD_RESET_TEST_ITERATION}                10
${SHUB_RESET_TEST_ITERATION}                 20
${CELL_LOCK_UNLOCK_TEST_ITERATION}           3
${CELL_BLOCK_UNBLOCK_TEST_ITERATION}         3
${DELTA_COMMISSIONING_TEST_ITERATION}        1

*** Test Cases ***
E2E_TL_SW_Upgrade_Rollback_with_OAM_KPI
    [Timeout]    96h
    [Tags]    uuf    upgrade
    ${QC_ID}=             bts_data.Get Qc Ids   ${TARGET_SW}
    Set To Dictionary    ${NODE1}    source_sw    ${SOURCE_SW}
    Set To Dictionary    ${NODE1}    target_sw    ${TARGET_SW}
    Set To Dictionary    ${NODE2}    source_sw    ${SOURCE_SW}
    Set To Dictionary    ${NODE2}    target_sw    ${LTE_TARGET_SW}

    IF    ${LTE_UPGRADE} == True
        @{NODES_DETAILS}=    Create List    ${NODE1}    ${NODE2}
    ELSE
        @{NODES_DETAILS}=    Create List    ${NODE1}
    END

    IF    ${MR_UPGRADE} == True
        NETACT FEATURE TEST
        ...                                     nodes_details=${NODES_DETAILS}
        ...                                     test_nodes_details=${NODES_DETAILS}
        ...                                     netact_dict=${NETACT_DICT}
        ...                                     iterations_per_node=${UPDATE_TEST_ITERATION}
        ...                                     report=${True}
        ...                                     qc_domain=${QC_DOMAIN}
        ...                                     qc_project=${QC_PROJECT}
        ...                                     qc_id=${QC_ID['qc_upgrade']}
        ...                                     customers_list=@{CUSTOMERS_LIST}
        ...                                     restore_to_target_sw=${True}
        ...                                     rollback_reverse_order=${True}
        ...                                     deintegrate_after_test=${DEINTEGRATE}
        ...                                     integrate_before_test=${True}
        ...                                     cm_provision=${CM_PROVISION}
    ELSE
        E2E TL SW UPGRADE ROLLBACK WITH OAM KPI
        ...                                     nodes_details=${NODES_DETAILS}
        ...                                     test_nodes_details=${NODES_DETAILS}
        ...                                     iterations_per_node=${UPDATE_TEST_ITERATION}
        ...                                     report=${True}
        ...                                     qc_domain=${QC_DOMAIN}
        ...                                     qc_project=${QC_PROJECT}
        ...                                     qc_id=${QC_ID['qc_upgrade']}
        ...                                     sw_build=${TARGET_SW}
        ...                                     customers_list=@{CUSTOMERS_LIST}
        ...                                     restore_to_target_sw=${True}
    END

    IF    ${SCF} == True
        Log To Console    SCF will be commissioned
        Custom Suite Setup
    ELSE
        Log To Console    No SCF commissioning
    END

[2][1.0] E2E_TL_Activation_Reset_with_OAM_KPI
    [Timeout]    96h
    [Tags]    uuf    activation_reset
    gnbbbu.Disconnect
    ${QC_ID}=                 bts_data.Get Qc Ids   ${TARGET_SW}
    E2E TL ACTIVATION RESET TEST
    ...                                     nodes_details=${NR_NODES}
    ...                                     test_nodes_details=${NODE1}
    ...                                     iterations_per_node=${ACTIVATION_RESET_TEST_ITERATION}
    ...                                     report=${True}
    ...                                     qc_domain=${QC_DOMAIN}
    ...                                     qc_project=${QC_PROJECT}
    ...                                     qc_id=${QC_ID['qc_activation_reset']}
    ...                                     sw_build=${TARGET_SW}
    ...                                     customers_list=@{CUSTOMERS_LIST}

E2E_TL_Site_Reset_with_OAM_KPI
    [Timeout]    96h
    [Tags]    uuf    site_reset
    gnbbbu.Disconnect
    ${QC_ID}=                 bts_data.Get Qc Ids   ${TARGET_SW}
    E2E TL SITE RESET WITH OAM KPI
    ...                                     nodes_details=${NR_NODES}
    ...                                     test_nodes_details=${NODE1}
    ...                                     iterations_per_node=${SITE_RESET_TEST_ITERATION}
    ...                                     report=${True}
    ...                                     qc_domain=${QC_DOMAIN}
    ...                                     qc_project=${QC_PROJECT}
    ...                                     qc_id=${QC_ID['qc_site_reset']}
    ...                                     sw_build=${TARGET_SW}
    ...                                     customers_list=@{CUSTOMERS_LIST}

E2E_TL_SW_upgrade_rollback_with_OAM_KPI_and_L3_Call
    [Tags]    tput
    [Setup]    Common Preconditions With Watching Alarms
    Verify L3 Call Quectel    ul_streams=8   dl_streams=100
    Verify Throughput on 5G and 4G
    [Teardown]    Common Postconditions With Watching Alarms

CB007834_ASiR_TC11_5G_Bi-Directional_ENDC_Throughput_TCP
    [Tags]    tput
    Should Be Equal As Strings    ${PREV TEST STATUS}    PASS

CB007834_ASiR_TC12_4G_Bi-Directional_ENDC_Throughput_TCP
    [Tags]    tput
    Should Be Equal As Strings    ${PREV TEST STATUS}    PASS

CB007834_ASIR_TC02_Reconfiguration_WebEM_with_-_without_site_reset
    [Tags]    nr    tc02
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

CB007834_ASiR_TC03_Reconfiguration_ASiR_WebEM_with_-_without_site_reset
    [Tags]    tc03
    &{ANTMOD_status}=    Create Dictionary    operationalState=enabled    localState=unblocked
    Set Test Variable    ${antmod_status}   &{ANTMOD_status}
    Change Asir Parameters Without Site Reset
    [Teardown]    Run Keywords    Restore Default Values    AND    Custom Postconditions With Watching Alarms

CB007834_ASIR_TC05_Reset_BBmode
    [Tags]    tc05    bbmod_reset
    [Timeout]   24h
    E2E TL CAPACITY MODULE RESET WITH OAM KPI
    ...                                     nodes_details=${NR_NODES}
    ...                                     test_nodes_details=${NODE1}
    ...                                     iterations_per_node=${BBMOD_RESET_TEST_ITERATION}
    ...                                     customers_list=@{CUSTOMERS_LIST}

CB007834_ASIR_TC06_Reset_sHUB_via_ASiR_WebEM
    [Tags]    tc06    ru_reset
    Reset Hub In Loop    iterations=${SHUB_RESET_TEST_ITERATION}
    ...                  allowed_alarms=@{ASIR_ALLOWED_ALARMS}
    Verify 5G Attach Quectel

CB007834_ASIR_TC07_Reset_pRRH
    [Tags]    tc07    prrh_reset
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
    [Tags]    tc08    prrh_block
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
    Verify 5G Attach Quectel

    [Teardown]    Run Keywords    Run Keyword If Test Failed    GnbAsir.Unblock Antenna    AND
    ...                           Custom Postconditions With Watching Alarms

CB007834_ASIR_TC10_Lock_and_unlock_NR_Cell_via_WebEM
    [Tags]    tc10    cell_lock
    [Timeout]   24h
    E2E TL CELL LOCK UNLOCK NR WITH OAM KPI
    ...                                     nodes_details=${NR_NODES}
    ...                                     test_nodes_details=${NODE1}
    ...                                     iterations_per_node=${CELL_LOCK_UNLOCK_TEST_ITERATION}
    ...                                     customers_list=@{CUSTOMERS_LIST}


E2E_TL_Cell_Block_Unblock_NR_with_OAM_KPI
    [Tags]    cell_block
    [Timeout]   24h
    E2E TL CELL BLOCK UNBLOCK NR WITH OAM KPI
    ...                                     nodes_details=${NR_NODES}
    ...                                     test_nodes_details=${NODE1}
    ...                                     iterations_per_node=${CELL_BLOCK_UNBLOCK_TEST_ITERATION}
    ...                                     customers_list=@{CUSTOMERS_LIST}

E2E_TL_Delta_Commissioning_With_NR_Rat_Reset
    [Tags]    delta_rat_reset    delta
    [Timeout]   24h
    ${DELTA_PARAM}=    Get Nr Rat Reset Delta
    E2E TL DELTA COMMISSIONING WITH ONLINE PARAMETER MODIFICATION
    ...                                     nodes_details=${NR_NODES}
    ...                                     test_nodes_details=${NODE1}
    ...                                     iterations_per_node=${DELTA_COMMISSIONING_TEST_ITERATION}
    ...                                     delta=${DELTA_PARAM}
    ...                                     customers_list=@{CUSTOMERS_LIST}

*** Keywords ***
Custom Suite Setup
    Run Keywords    Prepare gNB Neighbour
    ...      AND    Common Suite Setup With OnAir Test Line Preparation    should_5G_neighbour_be_changed=${False}
    ...                                                    swconfig_from_path=commissionings/Krakow/swconfig/default_swconfig.txt
    ...                                                    upload_swconfig_to_neighbour=${False}
    ...                                                    enable_sleeping_cell_detection=${False}
    ...                                                    list_of_additional_allowed_alarms=${PREPARATION_ALARMS}

    ${SOURCE_SW} =          IF    '${SOURCE_SW}'=='${None}'         Get CM Source Build    ELSE    Set Variable  ${SOURCE_SW}
    ${TARGET_SW} =          IF    '${TARGET_SW}'=='${None}'         Get Target Build       ELSE    Set Variable  ${TARGET_SW}
    ${LTE_TARGET_SW} =      IF    '${LTE_TARGET_SW}'=='${None}'     Get Target Build       ELSE    Set Variable  ${LTE_TARGET_SW}
    @{CUSTOMERS_LIST} =     IF    '${CUSTOMERS_LIST}'!='${None}'    Split String    ${CUSTOMERS_LIST}    ,    ELSE    Create List    Generic
    ${SCOUT_HOSTNAME} =     IF    '${SCOUT_HOSTNAME}'=='${None}'    bts_data.Get Scout BTS Name    ELSE    Set Variable    ${SCOUT_HOSTNAME}
    ${SCOUT_HOSTNAME_LTE} =     IF    '${SCOUT_HOSTNAME_LTE}'=='${None}'    bts_data.Get Scout BTS Name LTE
    ...                                                             ELSE    Set Variable    ${SCOUT_HOSTNAME_LTE}

    Set Global Variable  ${SOURCE_SW}
    Set Global Variable  ${TARGET_SW}
    Set Global Variable  ${LTE_TARGET_SW}
    Set Global Variable  @{CUSTOMERS_LIST}
    Set Global Variable  ${SCOUT_HOSTNAME}
    Set Global Variable  ${SCOUT_HOSTNAME_LTE}

Remove Dirs
    [Arguments]    @{directory_path}
    FOR    ${dir}    IN    @{directory_path}
        ${status}=    Run Keyword And Return Status    Directory Should Exist    ${dir}
        Run Keyword If    ${status}    Remove Directory    ${dir}    force=True
    END

Custom Preconditions With Watching Alarms
    Common Preconditions With Watching Alarms
    Remove Dirs       directory_path=/home/ute/.ute-ca/cache/bts/
    gnbalarm.Start watching alarms     bts_id=1    allowed_alarms=${allowed_alarms}
    gnbalarm.Watch Active Alarms and Collect Logs on Unexpected    bts_id=1

Custom Postconditions With Watching Alarms
    gnbbbu.connect    force=${True}
    Common Postconditions       collect_syslog=${True}

    [Teardown]    Run Keywords    gnb_alarm.Stop watching alarms
    ...                    AND    gnbalarm.Stop watching alarms    bts_id=1
    ...                    AND    Remove Custom Allowed Alarms If Defined

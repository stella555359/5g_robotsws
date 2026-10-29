*** Settings ***
Documentation
...    Author: Aleksandra Radziejewska, Michal Lys, Kamil Pielka
...    Maintainer: Kamil Pielka
...    Group in charge: I_5G_PZ_MMW_KRK_7SG_TEST_GMS
...    References: doors
...    Feature Description:5GC000955

Library     String
Library     taf.rfrl.csv4all.CSV4AllTestCases
Library     taf.rfrl.utilities.cloud_manager.artifacts
Library     testsuite/Krakow/resources/UUF/get_uuf_builds.py
Library     testsuite/Krakow/resources/RAN_PZ_KRK7/tools/keywords.py    WITH NAME    T07_keywords
Library     ./resources/leoni_switch.py
Resource    taf/rfrl/bts/robot/gnb.robot
Resource    resources/CommonKeywords_5GC000955.robot

Suite Setup    Custom Suite Setup
#Suite Setup       Common Suite Setup
Suite Teardown    common_setups_and_teardowns.Common Suite Teardown

Test Setup        Custom Test Setup
Test Teardown     common_setups_and_teardowns.Common Postconditions


*** Variables ***
@{PREPARATION_ALARMS}       No connection to unit
...                         Cell problem due to associated X2 links and/or NG links and/or E1 link unavailability
...                         Cell Activation timeout at gNB-DU
...                         Cell problem due to unavailability of associated links

${SOURCE_SW}                          ${None}
${TARGET_SW}                          ${None}

${CUSTOMERS_LIST}                     TMO US
@{CUSTOM_ALARMS}                      61648    7115    4420    4123    4125    8150    4459    8000    4689
@{CUSTOM_ALLOWED_ALARMS}              Cell problem due to associated X2 links and/or NG links and/or E1 link unavailability

&{NODE1}                              testline_object=${tl.gnbs[0]}
...                                   source_sw=${SOURCE_SW}
...                                   target_sw=${TARGET_SW}
...                                   custom_allowed_alarms=${CUSTOM_ALARMS}

@{NODES}                              ${NODE1}

${UPDATE_TEST_ITERATION}              5
${ACTIVATION_RESET_TEST_ITERATION}    20

${QC_DOMAIN}                          MN_RAN
${QC_PROJECT}                         RAN_VRF

${RP_CA}                              VRF_OAM
${RP_ORGANIZATION}                    VRF_KRK_T07
${RP_LOCATION}                        VRF_KRK

${QC_ID_UPGRADE}                      221137
${QC_ID_ACTIVATION_RESET}             221138


*** Test Cases ***
E2E_TL_SW_Upgrade_Rollback_with_OAM_KPI
    [Timeout]    96h
    [Tags]    uuf    upgrade

    Run Keyword If  '${QC_ID_UPGRADE}'!='${None}'    Set Tags    QC_${QC_ID_UPGRADE}
    Set To Dictionary    ${NODE1}    source_sw    ${SOURCE_SW}
    Set To Dictionary    ${NODE1}    target_sw    ${TARGET_SW}

    E2E TL SW UPGRADE ROLLBACK WITH OAM KPI
    ...                                     nodes_details=${NODES}
    ...                                     test_nodes_details=${NODE1}
    ...                                     iterations_per_node=${UPDATE_TEST_ITERATION}
    ...                                     report=${True}
    ...                                     qc_domain=${QC_DOMAIN}
    ...                                     qc_project=${QC_PROJECT}
    ...                                     qc_id=${QC_ID_UPGRADE}
    ...                                     sw_build=${TARGET_SW}
    ...                                     customers_list=@{CUSTOMERS_LIST}
    ...                                     restore_to_target_sw=${True}

    [Teardown]    Custom Test Teardown

E2E_TL_Activation_Reset_with_OAM_KPI
    [Timeout]    96h
    [Tags]    uuf    activation_reset
    Run Keyword If  '${QC_ID_ACTIVATION_RESET}'!='${None}'    Set Tags    QC_${QC_ID_ACTIVATION_RESET}
    gnbbbu.Disconnect
    E2E TL ACTIVATION RESET TEST
    ...                                     nodes_details=${NODES}
    ...                                     test_nodes_details=${NODE1}
    ...                                     iterations_per_node=${ACTIVATION_RESET_TEST_ITERATION}
    ...                                     report=${True}
    ...                                     qc_domain=${QC_DOMAIN}
    ...                                     qc_project=${QC_PROJECT}
    ...                                     qc_id=${QC_ID_ACTIVATION_RESET}
    ...                                     sw_build=${TARGET_SW}
    ...                                     customers_list=@{CUSTOMERS_LIST}

[1][1.0] 5GC000955_Lock_Unlock_SFP_BBMOD_with_site_reset
    [Tags]    sfp
    [Setup]    Run Keywords    Common Preconditions    AND
    ...                        Verify Setup Of All Cells    AND
    ...                        ADMIN CLI connection    AND
    ...                        Test preparation    sfpType=S
    5GC000955_Lock_Unlock_SFP_BBMOD_with_site_reset
    [Teardown]    Run Keywords    Remove all SFP objects    AND
    ...                           Wait Until Keyword Succeeds    60s    10s    Verify Setup Of All Cells    AND
    ...                           ADMIN CLI disconnection    AND
    ...                           Common Postconditions

Link_breaks_for_at_least_8_minutes_in_15-30_second_interval_using_Leoni_switch
    [Tags]    leoni
    leoni_switch.Link Brake While
    Wait Until Keyword Succeeds    5min    10s    gnbcell.Verify All Cells Are Onair

#[1][1.0] 5GC000955_Lock_Unlock_SFP_BBMOD
#    [Documentation]
#    ...  Lock_Unlock_SFP_BBMOD via WebEM
#    [Setup]    Run Keywords    Common Preconditions    AND
#    ...                        Verify Setup Of All Cells    AND
#    ...                        ADMIN CLI connection    AND
#     ...                       Test preparation    sfpType=S
#    5GC000955_Lock_Unlock_SFP_BBMOD_via_WebEM
#    [Teardown]    Run Keywords    Remove all SFP objects    AND
#    ...                           Wait Until Keyword Succeeds    60s    10s    Verify Setup Of All Cells    AND
#    ...                           ADMIN CLI disconnection    AND
#    ...                           Common Postconditions
#
#[2][1.0] 5GC000955_Lock_Unlock_SFP_BBMOD
#    [Documentation]
#    ...   Lock_Unlock_SFP_BBMOD via CLI
#    [Setup]    Run Keywords    Common Preconditions    AND
#    ...                        Verify Setup Of All Cells    AND
#    ...                        ADMIN CLI connection    AND
#     ...                       Test preparation    sfpType=S
#    5GC000955_Lock_Unlock_SFP_BBMOD_via_CLI
#    [Teardown]    Run Keywords    Remove all SFP objects    AND
#    ...                           Wait Until Keyword Succeeds    60s    10s    Verify Setup Of All Cells    AND
#    ...                           ADMIN CLI disconnection    AND
#    ...                           Common Postconditions
#
#[1][1.0] 5GC000955_Lock_Unlock_QSFP_BBMOD
#    [Documentation]
#    ...  Lock_Unlock_QSFP_BBMOD via WebEM
#    [Setup]    Run Keywords    Common Preconditions    AND
#    ...                        Verify Setup Of All Cells    AND
#    ...                        ADMIN CLI connection    AND
#     ...                       Test preparation    sfpType=Q
#    5GC000955_Lock_Unlock_QSFP_BBMOD_via_WebEM
#    [Teardown]    Run Keywords    Remove all SFP objects    AND
#    ...                           Wait Until Keyword Succeeds    60s    10s    Verify Setup Of All Cells    AND
#    ...                           ADMIN CLI disconnection    AND
#    ...                           Common Postconditions
#
#[2][1.0] 5GC000955_Lock_Unlock_QSFP_BBMOD
#    [Documentation]
#    ...  Lock_Unlock_QSFP_BBMOD via CLI
#    [Setup]    Run Keywords    Common Preconditions    AND
#    ...                        Verify Setup Of All Cells    AND
#    ...                        ADMIN CLI connection    AND
#     ...                       Test preparation    sfpType=Q
#    5GC000955_Lock_Unlock_QSFP_BBMOD_via_CLI
#    [Teardown]    Run Keywords    Remove all SFP objects    AND
#    ...                           Wait Until Keyword Succeeds    60s    10s    Verify Setup Of All Cells    AND
#    ...                           ADMIN CLI disconnection    AND
#    ...                           Common Postconditions
#
#[1][1.0] 5GC000955_Parameters_check_for_transmission
#    [Documentation]
#    ...  Parameters_check_for_transmission via WebEM
#    ...  The TC checks if ?maxTransmissionRate? parameter is invisible in CM for SFP port
#    [Setup]    Run Keywords    Common Preconditions    AND
#    ...                        Verify Setup Of All Cells    AND
#    ...                        ADMIN CLI connection    AND
#     ...                       Test preparation    sfpType=S
#    5GC000955_Parameters_check_for_transmission_via_WebEM
#    [Teardown]    Run Keywords    Remove all SFP objects    AND
#    ...                           Wait Until Keyword Succeeds    60s    10s    Verify Setup Of All Cells    AND
#    ...                           ADMIN CLI disconnection    AND
#    ...                           Common Postconditions
#
#[1][2.0] 5GC000955_Configure_QSFP_lanes_in_CM_object
#    [Setup]    Run Keywords    Common Preconditions    AND
#    ...                        Verify Setup Of All Cells    AND
#    ...                        ADMIN CLI connection    AND
#     ...                       Test preparation    sfpType=Q
#    5GC000955_Configure_QSFP_Lanes
#    Wait Until Keyword Succeeds    180s    10s    Verify Setup Of All Cells
#    [Teardown]    Run Keywords    Remove all SFP objects    AND
#    ...                           Wait Until Keyword Succeeds    60s    10s    Verify Setup Of All Cells    AND
#    ...                           ADMIN CLI disconnection    AND
#    ...                           Common Postconditions
#
#[1]5GC000955_Lock_Unlock_SFP_BBMOD_Success_rate
#    [Documentation]
#    ...  Robustnes test Lock_Unlock_SFP_BBMOD via WebEM
#    [Setup]    Run Keywords    Common Preconditions    AND
#    ...                        Verify Setup Of All Cells    AND
#    ...                        ADMIN CLI connection    AND
#    ...                        Test preparation    sfpType=S
#    Loop for robustness execution    5GC000955 Lock Unlock SFP BBMOD via WebEM    ${robustness_loop_amount}
#    [Teardown]    Run Keywords    Remove all SFP objects    AND
#    ...                           Wait Until Keyword Succeeds    60s    10s    Verify Setup Of All Cells    AND
#    ...                           ADMIN CLI disconnection    AND
#    ...                           Common Postconditions
#
#[1]5GC000955_Lock_Unlock_QSFP_BBMOD_Success_rate
#    [Documentation]
#    ...  Robustnes test Lock_Unlock_QSFP_BBMOD via WebEM
#    [Setup]    Run Keywords    Common Preconditions    AND
#    ...                        Verify Setup Of All Cells    AND
#    ...                        ADMIN CLI connection    AND
#    ...                        Test preparation    sfpType=Q
#    Loop for robustness execution    5GC000955 Lock Unlock QSFP BBMOD via WebEM    ${robustness_loop_amount}
#    [Teardown]    Run Keywords    Remove all SFP objects    AND
#    ...                           Wait Until Keyword Succeeds    60s    10s    Verify Setup Of All Cells    AND
#    ...                           ADMIN CLI disconnection    AND
#    ...                           Common Postconditions

#[1][1.0] 5GC000955_Lock_Unlock_SFP_BBMOD_with_abil_reset
#    [Setup]    Run Keywords    Common Preconditions    AND
#    ...                        Verify Setup Of All Cells    AND
#    ...                        ADMIN CLI connection    AND
#    ...                        Test preparation    sfpType=S
#    5GC000955_Lock_Unlock_SFP_BBMOD_with_abil_reset
#    [Teardown]    Run Keywords    Remove all SFP objects    AND
#    ...                           Wait Until Keyword Succeeds    60s    10s    Verify Setup Of All Cells    AND
#    ...                           ADMIN CLI disconnection    AND
#    ...                           Common Postconditions

#[1.0] 5GC000955_Lock_Unlock_all_SFP_QSFP_BBMOD
#    [Setup]    Run Keywords    Common Preconditions    AND
#    ...                        Verify Setup Of All Cells    AND
#    ...                        ADMIN CLI connection    AND
#    ...                        Test preparation    sfpType=S
#    ${BBMOD_RF_id_list}    Get all active SFP_QSFP
#    5GC000955_Lock_All_SFP_QSFP_BBMOD_via_CLI   ${BBMOD_RF_id_list}
#    5GC000955_Unlock_All_SFP_QSFP_BBMOD_via_CLI    ${BBMOD_RF_id_list}
#    [Teardown]    Run Keywords    Remove all SFP objects    AND
#    ...                           Wait Until Keyword Succeeds    60s    10s    Verify Setup Of All Cells    AND
#    ...                           ADMIN CLI disconnection    AND
#    ...                           Common Postconditions

*** Keywords ***
Custom Suite Setup
    Run Keywords    Run Keyword And Ignore Error    tl_prep.prepare_testline    should_LTE_neighbour_be_changed=${False}
    ...                                                              should_5G_neighbour_be_changed=${False}
    ...                                                              wait_for_on_air=${False}
    ...                                                              swconfig_from_path=commissionings/Krakow/swconfig/default_swconfig.txt
    ...                                      AND    Common Suite Setup With OnAir Test Line Preparation
    ...                                                              should_LTE_neighbour_be_changed=${True}
    ...                                                              swconfig_from_path=commissionings/Krakow/swconfig/default_swconfig.txt
    ...                                                              list_of_additional_allowed_alarms=${PREPARATION_ALARMS}


    ${SOURCE_SW} =          IF    '${SOURCE_SW}'=='${None}'         Get CM Source Build    ELSE    Set Variable  ${SOURCE_SW}
    ${TARGET_SW} =          IF    '${TARGET_SW}'=='${None}'         Get Target Build       ELSE    Set Variable  ${TARGET_SW}
    @{CUSTOMERS_LIST} =     IF    '${CUSTOMERS_LIST}'!='${None}'    Split String    ${CUSTOMERS_LIST}    ,    ELSE    Create List    Generic

    Set Global Variable  ${SOURCE_SW}
    Set Global Variable  ${TARGET_SW}
    Set Global Variable  @{CUSTOMERS_LIST}

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
    common_setups_and_teardowns.Common Postconditions
#    common_setups_and_teardowns.Common Postconditions With Restore Configuration If Test Failed

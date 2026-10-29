*** Settings ***
Documentation
...   Test suite for basic UUF testing in loop
...   author: Michal Chrzanowski
...   contact: michal.a.chrzanowski@nokia.com

Resource    ./resources/keywords.robot

Suite Setup       Custom Suite Setup
Suite Teardown    common_setups_and_teardowns.Common Suite Teardown

Test Setup        Custom Test Setup
Test Teardown     common_setups_and_teardowns.Common Postconditions With Restore Configuration If Test Failed

*** Variables ***
${SOURCE_SW}                        ${None}
${TARGET_SW}                        ${None}
${CUSTOMERS_LIST}                   Antina Pte
@{CUSTOM_ALLOWED_ALARMS}            61648    7115    4420    4123    4125    8150    4459    4479    4689    8000

&{NODE1}                            testline_object=${tl.gnbs[0]}
...                                 source_sw=${SOURCE_SW}
...                                 target_sw=${TARGET_SW}
...                                 custom_allowed_alarms=${CUSTOM_ALLOWED_ALARMS}

@{NODES}                            ${NODE1}

${UPDATE_TEST_ITERATION}                    3
${UPDATE_TEST_ITERATION_L3_CALL}            1
${SITE_RESET_TEST_ITERATION}                10
${ACTIVATION_SITE_RESET_TEST_ITERATION}     10
${RU_POWER_RESET_ITERATION}                 6
${LOCK_UNLOCK_ITERATION}                    6
${ONLINE_PARAM_CHANGE_ITERATION}            1
${SITE_RESET_PARAM_CHANGE_ITERATION}        1
${RAT_RESET_PARAM_CHANGE_ITERATION}         1
${RU_RESET_ITERATION}                       20
${REPORT}                                   ${True}

${CA_1_PATH}=                        ${CURDIR}/resources/certs/ca_1_cert.pem
${CA_2_PATH}=                        ${CURDIR}/resources/certs/ca_2_cert.pem

${QC_DOMAIN}                        MN_RAN
${QC_PROJECT}                       RAN_VRF

${RP_CA}                            VRF_OAM
${RP_ORGANIZATION}                  VRF_KRK_T07
${RP_LOCATION}                      VRF_KRK


*** Test Cases ***
E2E_TL_SW_Upgrade_Rollback_with_OAMKPI
    [Timeout]    96h
    [Tags]    skip
    Set To Dictionary    ${NODE1}    source_sw    ${SOURCE_SW}
    Set To Dictionary    ${NODE1}    target_sw    ${TARGET_SW}
    ${QC_ID}=             bts_data.Get Qc Ids   ${TARGET_SW}

    Sleep    2 minutes    reason=Waiting till scout connect to BTS(It is temporary WA)

    E2E TL SW UPGRADE ROLLBACK WITH OAM KPI
    ...                                     nodes_details=${NODES}
    ...                                     test_nodes_details=${NODE1}
    ...                                     iterations_per_node=${UPDATE_TEST_ITERATION}
    ...                                     report=${REPORT}
    ...                                     qc_domain=${QC_DOMAIN}
    ...                                     qc_project=${QC_PROJECT}
    ...                                     qc_id=${QC_ID['qc_upgrade']}
    ...                                     sw_build=${TARGET_SW}
    ...                                     customers_list=@{CUSTOMERS_LIST}
    ...                                     restore_to_target_sw=${True}

    [Teardown]    Custom Test Teardown

E2E_TL_SW_Upgrade_Rollback_with_OAMKPI_and_L3_call
    [Timeout]    96h
    [Tags]    skip
    Set To Dictionary    ${NODE1}    source_sw    ${SOURCE_SW}
    Set To Dictionary    ${NODE1}    target_sw    ${TARGET_SW}
    ${QC_ID}=             bts_data.Get Qc Ids   ${TARGET_SW}

    Sleep    2 minutes    reason=Waiting till scout connect to BTS(It is temporary WA)

    E2E TL SW UPGRADE ROLLBACK WITH OAM KPI
    ...                                     nodes_details=${NODES}
    ...                                     test_nodes_details=${NODE1}
    ...                                     iterations_per_node=${UPDATE_TEST_ITERATION_L3_CALL}
    ...                                     report=${REPORT}
    ...                                     qc_domain=${QC_DOMAIN}
    ...                                     qc_project=${QC_PROJECT}
    ...                                     qc_id=${QC_ID['qc_upgrade_l3_call']}
    ...                                     sw_build=${TARGET_SW}
    ...                                     customers_list=@{CUSTOMERS_LIST}
    ...                                     restore_to_target_sw=${True}
    ...                                     l3_call_method=L3_call_test

    [Teardown]    Custom Test Teardown

E2E_TL_Site_Reset_with_OAM_KPI
    [Timeout]    96h
    [Tags]    skip
    ${QC_ID}=             bts_data.Get Qc Ids   ${TARGET_SW}
    gnbbbu.Disconnect
    E2E TL SITE RESET WITH OAM KPI
    ...                                     nodes_details=${NODES}
    ...                                     test_nodes_details=${NODE1}
    ...                                     iterations_per_node=${SITE_RESET_TEST_ITERATION}
    ...                                     report=${REPORT}
    ...                                     qc_domain=${QC_DOMAIN}
    ...                                     qc_project=${QC_PROJECT}
    ...                                     qc_id=${QC_ID['qc_site_reset']}
    ...                                     sw_build=${TARGET_SW}
    ...                                     customers_list=@{CUSTOMERS_LIST}


E2E_TL_Activation_Reset_with_OAM_KPI
    [Timeout]    96h
    [Tags]    skip
    ${QC_ID}=             bts_data.Get Qc Ids   ${TARGET_SW}
    gnbbbu.Disconnect
    E2E TL ACTIVATION RESET TEST
    ...                                     nodes_details=${NODES}
    ...                                     test_nodes_details=${NODE1}
    ...                                     iterations_per_node=${ACTIVATION_SITE_RESET_TEST_ITERATION}
    ...                                     report=${REPORT}
    ...                                     qc_domain=${QC_DOMAIN}
    ...                                     qc_project=${QC_PROJECT}
    ...                                     qc_id=${QC_ID['qc_site_reset']}
    ...                                     sw_build=${TARGET_SW}
    ...                                     customers_list=@{CUSTOMERS_LIST}

E2E_TL_Cell_Lock_Unlock_NR_with_OAMKPI
    [Timeout]    24h
    ${QC_ID}=             bts_data.Get Qc Ids   ${TARGET_SW}
    E2E TL CELL LOCK UNLOCK NR WITH OAM KPI
    ...                                     nodes_details=${NODES}
    ...                                     test_nodes_details=${NODE1}
    ...                                     iterations_per_node=${LOCK_UNLOCK_ITERATION}
    ...                                     report=${REPORT}
    ...                                     qc_domain=${QC_DOMAIN}
    ...                                     qc_project=${QC_PROJECT}
    ...                                     qc_id=${QC_ID['qc_lock_unlock']}
    ...                                     sw_build=${TARGET_SW}
    ...                                     customers_list=@{CUSTOMERS_LIST}

E2E_TL_Delta_Commissioning_With_Online_Parameter_change
    [Timeout]   24h
    ${QC_ID}=             bts_data.Get Qc Ids   ${TARGET_SW}
    E2E TL DELTA COMMISSIONING WITH ONLINE PARAMETER MODIFICATION
    ...                                     nodes_details=${NODES}
    ...                                     test_nodes_details=${NODE1}
    ...                                     iterations_per_node=${ONLINE_PARAM_CHANGE_ITERATION}
    ...                                     report=${REPORT}
    ...                                     qc_domain=${QC_DOMAIN}
    ...                                     qc_project=${QC_PROJECT}
    ...                                     qc_id=${QC_ID['qc_delta_com_online']}
    ...                                     sw_build=${TARGET_SW}
    ...                                     customers_list=@{CUSTOMERS_LIST}

E2E_TL_Delta_Commissioning_With_Site_Reset
    [Timeout]   24h
    ${QC_ID}=             bts_data.Get Qc Ids   ${TARGET_SW}
    E2E TL DELTA COMMISSIONING WITH SITE RESET REQUIRED
    ...                                     nodes_details=${NODES}
    ...                                     test_nodes_details=${NODE1}
    ...                                     iterations_per_node=${SITE_RESET_PARAM_CHANGE_ITERATION}
    ...                                     report=${REPORT}
    ...                                     qc_domain=${QC_DOMAIN}
    ...                                     qc_project=${QC_PROJECT}
    ...                                     qc_id=${QC_ID['qc_delta_com_site_reset']}
    ...                                     sw_build=${TARGET_SW}
    ...                                     customers_list=@{CUSTOMERS_LIST}

E2E_TL_Delta_Commissioning_RAT_RESET
    [Timeout]   24h
    ${QC_ID}=             bts_data.Get Qc Ids   ${TARGET_SW}
    E2E TL DELTA COMMISSIONING WITH ONLINE PARAMETER MODIFICATION
    ...                                     nodes_details=${NODES}
    ...                                     test_nodes_details=${NODE1}
    ...                                     iterations_per_node=${RAT_RESET_PARAM_CHANGE_ITERATION}
    ...                                     report=${REPORT}
    ...                                     qc_domain=${QC_DOMAIN}
    ...                                     qc_project=${QC_PROJECT}
    ...                                     qc_id=${QC_ID['qc_delta_com_RAT_reset']}
    ...                                     sw_build=${TARGET_SW}
    ...                                     customers_list=@{CUSTOMERS_LIST}

E2E_TL_RU_Reset_with_OAMKPI
    [Timeout]    24h
    ${QC_ID}=             bts_data.Get Qc Ids   ${TARGET_SW}
    E2E TL RU RESET WITH OAM KPI
    ...                                     nodes_details=${NODES}
    ...                                     test_nodes_details=${NODE1}
    ...                                     iterations_per_node=${RU_RESET_ITERATION}
    ...                                     report=${REPORT}
    ...                                     qc_domain=${QC_DOMAIN}
    ...                                     qc_project=${QC_PROJECT}
    ...                                     qc_id=${QC_ID['qc_RU_reset']}
    ...                                     sw_build=${TARGET_SW}
    ...                                     customers_list=@{CUSTOMERS_LIST}

E2E_TL_RU_Power_Reset_with_L3_call
    [Timeout]    24h
    @{PDU_LIST}=    prepare rmods with pdu ports
    ${QC_ID}=             bts_data.Get Qc Ids   ${TARGET_SW}
    E2E TL RU POWER RESET
    ...                                     nodes_details=${NODES}
    ...                                     test_nodes_details=${NODE1}
    ...                                     rmods_with_pdu_ports=${PDU_LIST}
    ...                                     iterations_per_node=${RU_POWER_RESET_ITERATION}
    ...                                     report=${REPORT}
    ...                                     qc_domain=${QC_DOMAIN}
    ...                                     qc_project=${QC_PROJECT}
    ...                                     qc_id=${QC_ID['qc_ru_power_reset']}
    ...                                     sw_build=${TARGET_SW}
    ...                                     customers_list=@{CUSTOMERS_LIST}
    ...                                     l3_call_method=L3_call_test

E2E_TL_ASiR_Recommissioning_with_L3_call
    [Timeout]    24h
    E2E TL ASiR Recommissioning
    Full_bidrectional_L3_call_test    24408_N1=False


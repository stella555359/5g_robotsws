*** Settings ***
Documentation       Test suite for basic CSV4ALL Tests in loop
...                 Author: Damian Pietrzyk
...                 Modified: pawel.sniady@nokia.com

Library             Collections
Library             taf/rfrl/csv4all/CSV4AllTestCases.py

*** Variables ***
${INITIAL_SW}               SBTS00_ENB_9999_250721_000002
${TARGET_SW}                SBTS00_ENB_9999_250721_000010
${NIDD_ONLINE}              ${CURDIR}/../config/default/delta_csv4all_MRBTS-50894_online.json
${NIDD_RAT_RESET}           ${CURDIR}/../config/default/delta_csv4all_MRBTS-50894_rat_reset.json
${NIDD_SITE_RESET}          ${CURDIR}/../config/default/delta_csv4all_MRBTS-50894_site_reset.json

${ITERATIONS_UPGRADE}       10
${ITERATIONS_SCF}           10
${ITERATIONS_BTS_RESET}     20
${ITERATIONS_RU_RESET}      20
${ITERATIONS_BBMOD_RESET}   20
${ITERATIONS_BTS_LOCK}      20
${ITERATIONS_RU_LOCK}       20
${ITERATIONS_BBMOD_LOCK}    20

@{CUSTOM_ALLOWED}           4589
# @{TMP_ALLOWED}              1
# 4589: Unit power reset

${DN_PREFIX}                MRBTS-50894/EQM-1/APEQM-1
@{RMOD_DN}                  ${DN_PREFIX}/RMOD-1  ${DN_PREFIX}/RMOD-2  ${DN_PREFIX}/RMOD-3  ${DN_PREFIX}/RMOD-4
...                         ${DN_PREFIX}/RMOD-5  ${DN_PREFIX}/RMOD-6  ${DN_PREFIX}/RMOD-7  ${DN_PREFIX}/RMOD-8
...                         ${DN_PREFIX}/RMOD-9
@{BBMOD_DN}                 ${DN_PREFIX}/CABINET-1/BBMOD-1  ${DN_PREFIX}/CABINET-1/BBMOD-4
...                         ${DN_PREFIX}/CABINET-1/BBMOD-5

&{NODE1}                    testline_object=${tl.gnbs[0]}
...                         testline_scout_name=10_16_MRBTS-50894
...                         source_sw=${INITIAL_SW}
...                         target_sw=${TARGET_SW}
# ...                         temporary_allowed_alarms=${TMP_ALLOWED}
...                         custom_allowed_alarms=${CUSTOM_ALLOWED}
...                         modules_for_test=${RMOD_DN}

@{NODES}                    ${NODE1}
@{UPGRADE_NODES}            ${NODE1}

${RP_CA}                    VRF_RRM
${RP_LOCATION}              VRF_WRO2
${RP_ORGANIZATION}          VRF_WRO2_T05
${LABEL}                    VRF_WRO2_T05_Pawel_Sniady
@{CUSTOMERS}                TMO US
${REPORT}                   ${TRUE}

*** Test Cases ***
E2E_TL_SW_Upgrade_Rollback_with_OAM_KPI_single_node_upgrade
    E2E TL SW UPGRADE ROLLBACK WITH OAM KPI
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODE1}
    ...    iterations_per_node=${ITERATIONS_UPGRADE}
    ...    report=${REPORT}
    ...    customers_list=${CUSTOMERS}
    ...    topology=${LABEL}

E2E_TL_Site_Reset_with_OAM_KPI
    E2E TL SITE RESET WITH OAM KPI
     ...    nodes_details=${NODES}
     ...    test_nodes_details=${NODE1}
     ...    iterations_per_node=${ITERATIONS_BTS_RESET}
     ...    report=${REPORT}
     ...    customers_list=${CUSTOMERS}
     ...    topology=${LABEL}

E2E_TL_Power_Site_Reset_with_OAM_KPI
    E2E TL POWER SITE RESET WITH OAM KPI
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODE1}
    ...    iterations_per_node=${ITERATIONS_BTS_RESET}
    ...    report=${REPORT}
    ...    customers_list=${CUSTOMERS}
    ...    topology=${LABEL}

E2E_TL_RU_Reset_with_OAM_KPI
    E2E TL RU RESET WITH OAM KPI
     ...    nodes_details=${NODES}
     ...    test_nodes_details=${NODE1}
     ...    iterations_per_node=${ITERATIONS_RU_RESET}
     ...    report=${REPORT}
     ...    customers_list=${CUSTOMERS}
     ...    topology=${LABEL}

E2E_TL_Capacity_Module_Reset_with_OAM_KPI
    ${MOD_DICT}=    Create Dictionary    modules_for_test=${BBMOD_DN}
    ${NEW_NODE}    ${NEW_NODES}=    Modify Node    ${NODE1}    ${MOD_DICT}
    E2E TL CAPACITY MODULE RESET WITH OAM KPI
     ...    nodes_details=${NEW_NODES}
     ...    test_nodes_details=${NEW_NODE}
     ...    iterations_per_node=${ITERATIONS_BBMOD_RESET}
     ...    report=${REPORT}
     ...    customers_list=${CUSTOMERS}
     ...    topology=${LABEL}

E2E_TL_Cell_Lock_Unlock_NR_with_OAM_KPI
    E2E TL CELL LOCK UNLOCK NR WITH OAM KPI
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODE1}
    ...    iterations_per_node=${ITERATIONS_BTS_LOCK}
    ...    report=${REPORT}
    ...    customers_list=${CUSTOMERS}
    ...    topology=${LABEL}

E2E_TL_Delta_Commissioning_With_Online_Parameter_Modification
    E2E TL DELTA COMMISSIONING WITH ONLINE PARAMETER MODIFICATION
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODE1}
    ...    iterations_per_node=${ITERATIONS_SCF}
    ...    delta=${NIDD_ONLINE}
    ...    report=${REPORT}
    ...    customers_list=${CUSTOMERS}
    ...    topology=${LABEL}

E2E_TL_Delta_Commissioning_With_Site_Reset_Required
    E2E TL DELTA COMMISSIONING WITH SITE RESET REQUIRED
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODE1}
    ...    iterations_per_node=${ITERATIONS_SCF}
    ...    delta=${NIDD_SITE_RESET}
    ...    report=${REPORT}
    ...    customers_list=${CUSTOMERS}
    ...    topology=${LABEL}

E2E_TL_Delta_Commissioning_With_NR_Rat_Reset
    E2E TL DELTA COMMISSIONING WITH NR RAT RESET
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODE1}
    ...    iterations_per_node=${ITERATIONS_SCF}
    ...    delta=${NIDD_RAT_RESET}
    ...    report=${REPORT}
    ...    customers_list=${CUSTOMERS}
    ...    topology=${LABEL}

E2E_TL_BTS_Block_Unblock
    E2E TL BTS BLOCK UNBLOCK
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODE1}
    ...    iterations_per_node=${ITERATIONS_BTS_LOCK}
    ...    report=${REPORT}
    ...    customers_list=${CUSTOMERS}
    ...    topology=${LABEL}

E2E_TL_RU_Lock_Unlock
    E2E TL RU LOCK UNLOCK
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODE1}
    ...    iterations_per_node=${ITERATIONS_RU_LOCK}
    ...    report=${REPORT}
    ...    customers_list=${CUSTOMERS}
    ...    topology=${LABEL}

E2E_TL_RU_Power_Reset
    ${RMOD_LIST}=    Create RU to PDU mapping
    E2E TL RU POWER RESET
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODE1}
    ...    iterations_per_node=${ITERATIONS_RU_RESET}
    ...    rmods_with_pdu_ports=${RMOD_LIST}
    ...    report=${REPORT}
    ...    customers_list=${CUSTOMERS}
    ...    topology=${LABEL}

E2E_TL_Capacity_Module_Lock_Unlock
    ${MOD_DICT}=    Create Dictionary    modules_for_test=${BBMOD_DN}
    ${NEW_NODE}    ${NEW_NODES}=    Modify Node    ${NODE1}    ${MOD_DICT}
    E2E TL CAPACITY MODULE LOCK UNLOCK
    ...    nodes_details=${NEW_NODES}
    ...    test_nodes_details=${NEW_NODES}
    ...    iterations_per_node=${ITERATIONS_BBMOD_LOCK}
    ...    report=${REPORT}
    ...    customers_list=${CUSTOMERS}
    ...    topology=${LABEL}


*** Keywords ***
Create RU to PDU mapping
    ${RMOD_LIST}=    Create List
    FOR    ${RU}    IN    @{tl.gnbs[0].dus[0].rus}
        ${PDU}=    Create Dictionary
        ...    model=${ru.pdu_port.pdu.model}
        ...    host=${ru.pdu_port.pdu.addr}
        ...    port=${ru.pdu_port.port_no}
        ...    version=${ru.pdu_port.pdu.version}
        ${RMOD}=    Create Dictionary
        ...    ${ru.serial_number}    ${PDU}
        Append To List    ${RMOD_LIST}    ${RMOD}
    END
    [Return]    ${RMOD_LIST}

Modify Node
    [Arguments]    ${NODE}    ${MOD_DICT}
    ${NEW_NODE}=    Create Dictionary    &{NODE}
    Set To Dictionary    ${NEW_NODE}    &{MOD_DICT}
    ${NEW_NODES}=    Create List    ${NEW_NODE}
    [Return]    ${NEW_NODE}    ${NEW_NODES}

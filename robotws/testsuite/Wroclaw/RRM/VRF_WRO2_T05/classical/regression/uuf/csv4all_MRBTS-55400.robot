*** Settings ***
Documentation       Test suite for basic CSV4ALL Tests in loop
...                 Author: Damian Pietrzyk
...                 Modified: katarzyna.wisniewska@nokia.com

Library             taf/rfrl/csv4all/CSV4AllTestCases.py

Test Timeout        60h


*** Variables ***
${INITIAL_SW}               SBTS00_ENB_9999_251126_000011
${TARGET_SW}                SBTS00_ENB_9999_251211_000005

${ITERATIONS_UPGRADE}       10
${ITERATIONS_SITE_RESET}    20
${ITERATIONS_RU_RESET}      20
${ITERATIONS_BBMOD_RESET}   20
${ITERATIONS_BTS_LOCK}      20
${ITERATIONS_RU_LOCK}       20

@{CUSTOM_ALLOWED}           7307  7311  7331  62002  62003
#@{TMP_ALLOWED}              7307  7311
#7307    Xn SCTP setup fail
#7311    No Xn link available
#7331    Inter-gNB CA Xp communication failure
#62002   XP connection setup failure - No response
#62003   Transport layer connection lost in XP interface

&{vm}                       host=10.44.75.230
...                         user=ute
...                         password=UTE.debian12

@{BBMOD_LIST}               MRBTS-55400/EQM-1/APEQM-1/CABINET-1/BBMOD-1
...                         MRBTS-55400/EQM-1/APEQM-1/CABINET-1/BBMOD-2

@{RMOD_LIST}                MRBTS-55400/EQM-1/APEQM-1/RMOD-1
...                         MRBTS-55400/EQM-1/APEQM-1/RMOD-3

&{NODE1}                    node_vm=${vm}
...                         source_sw=${INITIAL_SW}
...                         target_sw=${TARGET_SW}
...                         testline_scout_name=10_16_MRBTS-55400
#...                         temporary_allowed_alarms=${TMP_ALLOWED}
...                         custom_allowed_alarms=${CUSTOM_ALLOWED}
...                         modules_for_test=${BBMOD_LIST}

&{RMOD_1_PDU}               host=10.44.200.57    port=5    model=GUDE    version=8220-1
&{RMOD_3_PDU}               host=10.44.200.57    port=4    model=GUDE    version=8220-1


&{AEHC}                     L1204708726=${RMOD_1_PDU}
&{AHFII}                    BL2242N433B=${RMOD_3_PDU}


@{PDU}                      ${AHFII}  ${AEHC}
@{NODES}                    ${NODE1}
@{UPGRADE_NODES}            ${NODE1}

${RP_CA}                    VRF_RRM
${RP_LOCATION}              VRF_WRO2
${RP_ORGANIZATION}          VRF_WRO2_T05
${LABEL}                    VRF_WRO2_T05_Katarzyna_Wisniewska
@{CUSTOMERS}                Generic
${REPORT}                   ${TRUE}


*** Test Cases ***
E2E_TL_SW_Upgrade_Rollback_with_OAM_KPI
    E2E TL SW UPGRADE ROLLBACK WITH OAM KPI
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODES}
    ...    iterations_per_node=${ITERATIONS_UPGRADE}
    ...    report=${REPORT}
    ...    customers_list=${CUSTOMERS}
    ...    topology=${LABEL}

E2E_TL_Site_Reset_with_OAM_KPI
    E2E TL SITE RESET WITH OAM KPI
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODES}
    ...    iterations_per_node=${ITERATIONS_SITE_RESET}
    ...    report=${REPORT}
    ...    customers_list=${CUSTOMERS}
    ...    topology=${LABEL}

E2E_TL_RU_Reset_with_OAM_KPI
    E2E TL RU RESET WITH OAM KPI
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODES}
    ...    iterations_per_node=${ITERATIONS_RU_RESET}
    ...    report=${REPORT}
    ...    customers_list=${CUSTOMERS}
    ...    topology=${LABEL}

E2E_TL_Capacity_Module_Reset_with_OAM_KPI
    E2E TL CAPACITY MODULE RESET WITH OAM KPI
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODES}
    ...    iterations_per_node=${ITERATIONS_BBMOD_RESET}
    ...    report=${REPORT}
    ...    customers_list=${CUSTOMERS}
    ...    topology=${LABEL}

E2E_TL_BTS_Block_Unblock
    E2E TL BTS BLOCK UNBLOCK
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODES}
    ...    iterations_per_node=${ITERATIONS_BTS_LOCK}
    ...    report=${REPORT}
    ...    customers_list=${CUSTOMERS}
    ...    topology=${LABEL}

E2E_TL_RU_Lock_Unlock
    E2E TL RU LOCK UNLOCK
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODES}
    ...    iterations_per_node=${ITERATIONS_RU_LOCK}
    ...    report=${REPORT}
    ...    customers_list=${CUSTOMERS}
    ...    topology=${LABEL}

E2E_TL_RU_Power_Reset
    E2E TL RU POWER RESET
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODES}
    ...    iterations_per_node=${ITERATIONS_RU_RESET}
    ...    rmods_with_pdu_ports=${PDU}
    ...    report=${REPORT}
    ...    customers_list=${CUSTOMERS}
    ...    topology=${LABEL}

*** Settings ***
Documentation
...    Maintainer: karol.lapczyk@nokia.com, damian.sarna@nokia.com
...    Description: Tests covering main features of AMX Colombia configuration from E2E project. QC: CB007825-5G-A
...    Team in charge: MN 5G&SC mmW&SC VRF KRK 3 SG


Library         taf/rfrl/csv4all/CSV4AllTestCases.py                                                WITH NAME      CSV4ALL
Resource        taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource        taf/rfrl/ue/robot/REAL_UE.robot
Variables       resources/AMX_Colombia_KPI_Report_5G.py

Force Tags    CA_VRF_KRK

Suite Setup       common_setups_and_teardowns.Common Suite Setup With OnAir Test Line Preparation
                  ...       swconfig_from_path=commissionings/Krakow/7_7_T01PY055/swconfig.txt
Suite Teardown    common_setups_and_teardowns.Common Suite Teardown

*** Variables ***
@{CUSTOMERS_LIST}                   Claro Colombia
${QC_DOMAIN}                        MN_RAN
${QC_PROJECT}                       RAN_VRF
${SCOUT_HOSTNAME}                   7_7_T01PY055
${SHOULD_BE_REPORTED}               True
${RDC_CONFIG}                       /home/ute/auto/testline_configuration/7_7_T01PY055/mumin.yaml

${RP_CA}                            VRF_OAM
${RP_LOCATION}                      VRF_KRK
${RP_ORGANIZATION}                  VRF_KRK_T03

${ITERATIONS_UPGRADE}               ${5}
${ITERATIONS_RESET}                 ${10}
${ITERATIONS_ACTIVATION_RESET}      ${100}
${5G_SOURCE_SW}                     SBTS00_ENB_9999_250810_000003
${5G_TARGET_SW}                     SBTS00_ENB_9999_250811_000004


@{CUSTOM_ALARMS}                    7107        7319        7300        7308
@{CRITICAL_ALARMS}                  10

&{NODE1}                            testline_object=${tl.gnbs[0]}
...                                 source_sw=${5G_SOURCE_SW}
...                                 target_sw=${5G_TARGET_SW}
...                                 custom_allowed_alarms=${CUSTOM_ALARMS}
...                                 verify_syslog=${True}
@{NODES}                            ${NODE1}

${tput_dl}                              1 Gbits/sec
${tput_ul}                              140 Mbits/sec
${parallel_streams_ul}                  4
${parallel_streams_dl}                  4
${protocol}                             tcp
${deviation}                            8%
${size_packet_dl}                       1436B
${capabilities}                         REAL_UE
${duration}                             1200s
${reboot_ue}                            True
${current_config}                       None
${COLLECT_LOGS_DURING_DATA_TRANSFER}    False

*** Test Cases ***
E2E_TL_SW_upgrade_rollback_with_OAM_KPI_and_L3_Call
    [Documentation]    Performs upgrade and rollback with L3CALL. It is mandatory that the 5G_SOURCE_SW is a current BTS
    ...   build when executing the test.
    Prepare Ue for L3 Call
    CSV4ALL.E2E TL SW UPGRADE ROLLBACK WITH OAM KPI
    ...                                     nodes_details=${NODES}
    ...                                     test_nodes_details=${NODE1}
    ...                                     iterations_per_node=1
    ...                                     report=${SHOULD_BE_REPORTED}
    ...                                     qc_domain=${QC_DOMAIN}
    ...                                     qc_project=${QC_PROJECT}
    ...                                     qc_id=${kpi_qc_ids['qc_upgrade_l3call']}
    ...                                     sw_build=${5G_TARGET_SW}
    ...                                     customers_list=@{CUSTOMERS_LIST}
    ...                                     restore_to_target_sw=${False}
    ...                                     l3_call_method=Simple L3 Call Test

E2E_TL_SW_upgrade_rollback_with_OAM_KPI
    [Timeout]    96h
    [Documentation]    Performs 5 upgrades and rollbacks in a row. It is mandatory that the 5G_SOURCE_SW is a current BTS
    ...   build when executing the test.
    CSV4ALL.E2E TL SW UPGRADE ROLLBACK WITH OAM KPI
    ...                                     nodes_details=${NODES}
    ...                                     test_nodes_details=${NODE1}
    ...                                     iterations_per_node=${ITERATIONS_UPGRADE}
    ...                                     report=${SHOULD_BE_REPORTED}
    ...                                     qc_domain=${QC_DOMAIN}
    ...                                     qc_project=${QC_PROJECT}
    ...                                     qc_id=${kpi_qc_ids['qc_upgrade']}
    ...                                     sw_build=${5G_TARGET_SW}
    ...                                     customers_list=@{CUSTOMERS_LIST}
    ...                                     restore_to_target_sw=${True}

E2E_TL_Activation_Reset_with_OAM_KPI
    [Timeout]    96h
    [Documentation]    Performs 20 site resets in a row and checks if executed with no additional faults.
    CSV4ALL.E2E TL ACTIVATION RESET TEST
    ...                                     nodes_details=${NODES}
    ...                                     test_nodes_details=${NODE1}
    ...                                     iterations_per_node=${ITERATIONS_ACTIVATION_RESET}
    ...                                     report=${SHOULD_BE_REPORTED}
    ...                                     qc_domain=${QC_DOMAIN}
    ...                                     qc_project=${QC_PROJECT}
    ...                                     qc_id=${kpi_qc_ids['qc_activation_reset']}
    ...                                     customers_list=@{CUSTOMERS_LIST}

E2E_TL_Site_Reset_with_OAM_KPI
    [Timeout]    96h
    [Documentation]    Performs 20 site resets in a row and checks if executed with no additional faults.
    CSV4ALL.E2E TL SITE RESET WITH OAM KPI
    ...                                     nodes_details=${NODES}
    ...                                     test_nodes_details=${NODE1}
    ...                                     iterations_per_node=${ITERATIONS_RESET}
    ...                                     report=${SHOULD_BE_REPORTED}
    ...                                     qc_domain=${QC_DOMAIN}
    ...                                     qc_project=${QC_PROJECT}
    ...                                     qc_id=${kpi_qc_ids['qc_site_reset']}
    ...                                     customers_list=@{CUSTOMERS_LIST}

L3_call_stability
    [Documentation]      The objective of the case is to verify the stability of the set system during long duration run
    ...                 and test for possible throughput and latency degradation or unit overheating.
    Prepare Ue for L3 Call
    Verify L3 Call Data Transfer DL&UL
    ...                                     duration=${duration}
    ...                                     tput_dl=${tput_dl}
    ...                                     tput_ul=${tput_ul}
    ...                                     protocol=${protocol}
    ...                                     deviation=${deviation}
    ...                                     size_packet=${size_packet_dl}
    ...                                     parallel_streams_dl=${parallel_streams_dl}
    ...                                     parallel_streams_ul=${parallel_streams_ul}
    ...                                     interval=1

*** Keywords ***
Simple L3 Call Test
    [Arguments]                             ${cell_used_in_test}
    Log                                     ${cell_used_in_test}
    Verify L3 Call One Way Data Transfer
    ...                                     direction=dl
    ...                                     duration=120s
    ...                                     tput=400 Mbits/sec

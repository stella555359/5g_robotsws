*** Settings ***
Documentation
...   Test suite for regression testing of feature CB007834_CB007835 For TL 11SK058
...   author: Malgorzata Pietka
...   contact: malgorzata.pietka@nokia.com

Library      String
Library      taf.rfrl.csv4all.CSV4AllTestCases
Library      OperatingSystem
Library      taf.rfrl.utilities.cloud_manager.artifacts
Library      testsuite/Krakow/resources/UUF/get_uuf_builds.py
Library      taf.sbts.oam.coam.admin
Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource     ../resources/robot/tput.robot
Resource     ../resources/robot/common.robot
Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Variables    ./resources/variables_Bharti_11sk058.py


Suite Setup       Common Suite Setup With OnAir Test Line Preparation
...               list_of_additional_allowed_alarms=${additional_allowed_alarms}

Suite Teardown    Common Suite Teardown

Test Setup        Custom Test Setup
Test Teardown     common_setups_and_teardowns.Common Postconditions With Restore Configuration If Test Failed   collect_syslog=${False}



Force Tags    CA_VRF_KRK


*** Variables ***
${REPORT}                                       True
${CALCULATE_KPI}                                True
@{CUSTOMERS_LIST}                               Bharti     # Customer list separated by comma
${QC_DOMAIN}                                    MN_RAN
${QC_PROJECT}                                   RAN_VRF
${RP_CA}                                        VRF_OAM
${RP_ORGANIZATION}                              VRF_KRK_T01
${RP_LOCATION}                                  VRF_KRK

${SOURCE_SW}                                    ${None}
${TARGET_SW}                                    ${None}

@{CUSTOM_ALARMS}                                7316
${CUSTOM_ALLOWED_ALARMS_DURING_TL_PREPARATION}  ${None}
${SYSLOG_IGNORED_PRINTS}                        ${None}     # String separated by |
${RESTORE_TO_TARGET_SW}                         ${True}
${STOP_TEST_AFTER_FAIL}                         False

&{NODE1}                                        testline_object=${tl.gnbs[0]}
...                                             source_sw=${SOURCE_SW}
...                                             target_sw=${TARGET_SW}
...                                             custom_allowed_alarms=${CUSTOM_ALARMS}
...                                             syslog_ignored_prints=${SYSLOG_IGNORED_PRINTS}
@{NODES}                                        ${NODE1}

#delta with parameters to change
${ONLINE_PARAMETER_DELTA}               testsuite/Krakow/SISO/regression/RAN_PZ_KRK1/CB007834/resources/delta/online_delta_gNB_TL11sk058.json
${COMMISIONING_SITE_RESET_DELTA}        testsuite/Krakow/SISO/regression/RAN_PZ_KRK1/CB007834/resources/delta/site_reset_delta_gNB_TL11sk058.json
${GSM_RAT_RESET_DELTA}                  testsuite/Krakow/SISO/regression/RAN_PZ_KRK1/CB007834/resources/delta/GSM_RAT_reset_TL11sk058.json
${LTE_RAT_RESET_DELTA}                  testsuite/Krakow/SISO/regression/RAN_PZ_KRK1/CB007834/resources/delta/LTE_RAT_reset_TL11sk058.json
${NR_RAT_RESET_DELTA}                   testsuite/Krakow/SISO/regression/RAN_PZ_KRK1/CB007834/resources/delta/NR_RAT_reset_TL11sk058.json

# ${prefix_tag} requires setting of CONFIGURATION variable e.g.: -v CONFIGURATION:Krakow.7_7_UTE5GCLOUDT8SK134
${prefix_tag}                           CB007834_11sk058
${prefix_tag_L3_call}                   CB007834_11sk058_L3_call
${prefix_tag_L3_call_selected_cells}    CB007834_11sk058_L3_call_selected_cells
# ${current_config} to remove after TL preparation added; to skip commissioning set equal to ${prefix_tag}
${current_config}                       ${None}

#no of iteration
${UPDATE_TEST_ITERATION}                    2
${SITE_RESET_TEST_ITERATION}                10
${SITE_RESET_OAM_KPI_TEST_ITERATION}        10

#QC ID tests
${QC_ID_RESET}                              218738
${QC_ID_RU_RESET}                           218796
${QC_ID_UPGRADE}                            218797
${QC_ID_BBMOD_RESET}                        218798
${QC_ID_LOCK_UNLOCK_NR}                     218799
${QC_ID_LOCK_UNLOCK_LTE_TRUNK}              218800
${QC_ID_DELTA_COMMISIONING_SITE_RESET}      218801
${QC_ID_DEL_NR_RAT_RST_TRUNK}               218802
${QC_ID_DEL_LTE_RAT_RST_TRUNK}              218803
${QC_ID_DEL_GSM_RAT_RST_TRUNK}              218804
${QC_ID_DEL_ONLNE_PAR_MOD}                  218805
${QC_ID_BLCK_UNBLCK_NR_TRUNK}               218806
${QC_ID_BLOCK_UNBLOCK_LTE}                  218807
${QC_ID_BLOCK_UNBLOCK_GSM}                  219357
${QC_ID_RESET_WITH_OAM}                     222724

#tput
${reboot_ue}                                False
${capabilities}                             REAL_UE
${duration}                                 180s
${parallel_streams_dl}                      4
${parallel_streams_ul}                      4
${size_packet}                              1400B
${deviation}                                20%
${size_packet_dl}                           1400B
${size_packet_ul}                           1400B
${interval}                                 1
${omit}                                     5
${alias}                                    UE
${COLLECT_LOGS_DURING_DATA_TRANSFER}        False
${ENABLE_RACH_OBSERVER}                     False

#attach
${timeout_reboot_ue}                        100


*** Test Cases ***
[1][1.0] E2E_TL_SW_upgrade_rollback_with_OAM_KPI
    [Timeout]    96h
    [Tags]    UUF
    Set Test Variable  &{OAM_KPI_TARGETS}    kpi2c=600    kpi2d=600
    Set Test Variable  ${ALARM_TIMEOUT}  180
    Set Test Variable  ${HARDWARE_CHECK_TIMEOUT}  600
    Set Test Variable  @{SYSLOG_IGNORED_PRINTS}  INF

    ${SOURCE_SW} =    IF    '${SOURCE_SW}'=='${None}'  Get CM Source Build    ELSE    Set Variable  ${SOURCE_SW}
    ${TARGET_SW} =    IF    '${TARGET_SW}'=='${None}'  Get Target Build   ELSE    Set Variable  ${TARGET_SW}
    Set To Dictionary    ${NODE1}    source_sw    ${SOURCE_SW}
    Set To Dictionary    ${NODE1}    target_sw    ${TARGET_SW}

    Sleep    18 minutes    reason=Waiting till scout connect to BTS(It is temporary WA)

    ${upgrade_result}=     Run Keyword And Return Status   E2E TL SW UPGRADE ROLLBACK WITH OAM KPI
    ...                                     nodes_details=${NODES}
    ...                                     test_nodes_details=${NODE1}
    ...                                     iterations_per_node=${UPDATE_TEST_ITERATION}
    ...                                     report=${REPORT}
    ...                                     qc_domain=${QC_DOMAIN}
    ...                                     qc_project=${QC_PROJECT}
    ...                                     qc_id=${QC_ID_UPGRADE}
    ...                                     sw_build=${TARGET_SW}
    ...                                     customers_list=@{CUSTOMERS_LIST}
    ...                                     restore_to_target_sw=${RESTORE_TO_TARGET_SW}
   Set Suite Variable   ${UPGRADE_TEST_PASSED}     ${upgrade_result}
   Run Keyword If      '${UPGRADE_TEST_PASSED}' == '${False}'      Fail    "UUF test failed - one of the iterations failed, please check the logs"
    [Teardown]    Custom Test Teardown

[1][1.0] E2E_TL_Activation_Reset_with_OAM_KPI
    [Timeout]    96h
    [Tags]    SITE_RESET

    Set Test Variable   &{OAM_KPI_TARGETS}     kpi2c=600
    gnbbbu.Disconnect
    E2E TL ACTIVATION RESET TEST
    ...                                     nodes_details=${NODES}
    ...                                     test_nodes_details=${NODE1}
    ...                                     iterations_per_node=${SITE_RESET_TEST_ITERATION}
    ...                                     report=${REPORT}
    ...                                     qc_domain=${QC_DOMAIN}
    ...                                     qc_project=${QC_PROJECT}
    ...                                     qc_id=${QC_ID_RESET}
    ...                                     sw_build=${TARGET_SW}
    ...                                     customers_list=@{CUSTOMERS_LIST}

[1][1.0] E2E_TL_Site_Reset_with_OAM_KPI
    Log To Console     *** TEST PASS ***
    [Timeout]   24h
	[Tags]    	site_reset
	Set Test Variable  &{OAM_KPI_TARGETS}     kpi1a=525		kpi1b=525	kpi1c=525
    E2E TL SITE RESET WITH OAM KPI    ${NODES}    ${NODE1}
    ...          iterations_per_node=${SITE_RESET_OAM_KPI_TEST_ITERATION}
    ...          report=${REPORT}
    ...          customers_list=${CUSTOMERS_LIST}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=${QC_ID_RESET_WITH_OAM}
    ...          qc_project=${QC_PROJECT}
	...			 kpi_targets=${OAM_KPI_TARGETS}

[1][1.0] E2E_TL_RU_Reset_with_OAM_KPI
    [Timeout]   24h
    [Tags]   Remaining
    Set Test Variable  &{OAM_KPI_TARGETS_RU_RESET}     kpi51a=235     kpi51b=235	kpi51c=135
    E2E TL RU RESET WITH OAM KPI    ${NODES}     ${NODE1}
    ...          iterations_per_node=1
    ...          report=${REPORT}
    ...          customers_list=${CUSTOMERS_LIST}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=${QC_ID_RU_RESET}
    ...          qc_project=${QC_PROJECT}

[1][1.0] E2E_TL_Capacity_Module_Reset_with_OAM_KPI
    [Timeout]    24h
    [Tags]       BBmod
    Set Test Variable  &{OAM_KPI_TARGETS_BB_RESET}     kpi5=350
    e2e_tl_capacity_module_reset_with_oam_kpi      ${NODES}  ${NODE1}
    ...    iterations_per_node=1
    ...    report=${REPORT}
    ...    calculate_kpi=${CALCULATE_KPI}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_id=${QC_ID_BBMOD_RESET}
    ...    qc_project=${QC_PROJECT}
    ...    customers_list=${CUSTOMERS_LIST}
    ...    stop_test_after_fail=${STOP_TEST_AFTER_FAIL}

[1][1.0] E2E_TL_Cell_Lock_Unlock_NR_with_OAM_KPI
    [Timeout]   24h
    [Tags]	Remaining
    Set Test Variable  &{OAM_KPI_TARGETS}     kpi16a=55     kpi16b=55

    E2E TL CELL LOCK UNLOCK NR WITH OAM KPI    ${NODES}  ${NODE1}
    ...          iterations_per_node=1
    ...          report=${REPORT}
    ...          customers_list=${CUSTOMERS_LIST}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=${QC_ID_LOCK_UNLOCK_NR}
    ...          qc_project=${QC_PROJECT}

[1][1.0] E2E_TL_Cell_Lock_Unlock_LTE_with_OAM_KPI
    [Timeout]   24h
    [Tags]   Remaining
    Set Test Variable  &{OAM_KPI_TARGETS}     kpi16a=55    kpi16b=55
    E2E TL CELL LOCK UNLOCK LTE WITH OAM KPI    ${NODES}  ${NODE1}
    ...          iterations_per_node=1
    ...          report=${REPORT}
    ...          customers_list=${CUSTOMERS_LIST}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=${QC_ID_LOCK_UNLOCK_LTE_TRUNK}
    ...          qc_project=${QC_PROJECT}

[1][3.0] E2E_TL_Cell_Block_Unblock_GSM_with_OAM_KPI
    [Timeout]   24h
    [Tags]   Remaining
    Set Test Variable  &{OAM_KPI_TARGETS}     kpi17a=20    kpi17b=20

    E2E TL CELL BLOCK UNBLOCK GSM WITH OAM KPI    ${NODES}  ${NODE1}
    ...          iterations_per_node=1
    ...          report=${REPORT}
    ...          customers_list=${CUSTOMERS_LIST}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=${QC_ID_BLOCK_UNBLOCK_GSM}
    ...          qc_project=${QC_PROJECT}

[1][1.0] E2E_TL_Cell_Block_Unblock_LTE_with_OAM_KPI
    [Timeout]   24h
    [Tags]	Remaining
    Set Test Variable  &{OAM_KPI_TARGETS}     kpi17a=20    kpi17b=10

    E2E TL CELL BLOCK UNBLOCK LTE WITH OAM KPI    ${NODES}  ${NODE1}
    ...          iterations_per_node=1
    ...          report=${REPORT}
    ...          customers_list=${CUSTOMERS_LIST}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=${QC_ID_BLOCK_UNBLOCK_LTE}
    ...          qc_project=${QC_PROJECT}

[1][1.0] E2E_TL_Cell_Block_Unblock_NR_with_OAM_KPI
    [Timeout]   24h
    [Tags]   Remaining
    Set Test Variable  &{OAM_KPI_TARGETS}     kpi17a=20    kpi17b=20
    E2E TL CELL BLOCK UNBLOCK NR WITH OAM KPI    ${NODES}  ${NODE1}
    ...          iterations_per_node=1
    ...          report=${REPORT}
    ...          customers_list=${CUSTOMERS_LIST}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=${QC_ID_BLCK_UNBLCK_NR_TRUNK}
    ...          qc_project=${QC_PROJECT}

[1][1.0] E2E_TL_Delta_Commissioning_With_Online_Parameter_Modification
    [Timeout]   24h
    [Tags]	Remaining
    E2E TL DELTA COMMISSIONING WITH ONLINE PARAMETER MODIFICATION    ${NODES}    ${NODE1}
    ...          iterations_per_node=1
    ...          delta=${ONLINE_PARAMETER_DELTA}
    ...          report=${REPORT}
    ...          customers_list=${CUSTOMERS_LIST}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=${QC_ID_DEL_ONLNE_PAR_MOD}
    ...          qc_project=${QC_PROJECT}

[1][1.0] E2E_TL_Delta_Commissioning_With_Site_Reset_Required
    [Timeout]   24h
    [Tags]   setreset
    e2e_tl_delta_commissioning_with_site_reset_required    ${NODES}  ${NODE1}
    ...    iterations_per_node=1
    ...    report=${REPORT}
    ...    calculate_kpi=${CALCULATE_KPI}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_id=${QC_ID_DELTA_COMMISIONING_SITE_RESET}
    ...    qc_project=${QC_PROJECT}
    ...    customers_list=${CUSTOMERS_LIST}
    ...    stop_test_after_fail=${STOP_TEST_AFTER_FAIL}

[1][1.0] E2E_TL_Delta_Commissioning_With_GSM_Rat_Reset
    [Timeout]   24h
    [Tags]   Remaining
    E2E TL DELTA COMMISSIONING WITH GSM RAT RESET    ${NODES}  ${NODE1}
    ...          iterations_per_node=1
    ...          delta=${GSM_RAT_RESET_DELTA}
    ...          report=${REPORT}
    ...          customers_list=${CUSTOMERS_LIST}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=${QC_ID_DEL_GSM_RAT_RST_TRUNK}
    ...          qc_project=${QC_PROJECT}

[1][1.0] E2E_TL_Delta_Commissioning_With_LTE_Rat_Reset
    [Timeout]   24h
    [Tags]   Remaining
	E2E TL DELTA COMMISSIONING WITH LTE RAT RESET    ${NODES}  ${NODE1}
    ...          iterations_per_node=1
    ...          delta=${LTE_RAT_RESET_DELTA}
    ...          report=${REPORT}
    ...          customers_list=${CUSTOMERS_LIST}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=${QC_ID_DEL_LTE_RAT_RST_TRUNK}
    ...          qc_project=${QC_PROJECT}

[1][1.0] E2E_TL_Delta_Commissioning_With_NR_Rat_Reset
    [Timeout]   24h
    [Tags]   Remaining
    E2E TL DELTA COMMISSIONING WITH NR RAT RESET    ${NODES}  ${NODE1}
    ...          iterations_per_node=1
    ...          delta=${NR_RAT_RESET_DELTA}
    ...          report=${REPORT}
    ...          customers_list=${CUSTOMERS_LIST}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=${QC_ID_DEL_NR_RAT_RST_TRUNK}
    ...          qc_project=${QC_PROJECT}

*** Keywords ***
Custom Test Setup
    common_setups_and_teardowns.Common Preconditions        collect_syslog=${False}
    Run Keyword And Ignore Error    Remove Directory         path=/home/ute/.ute-ca/cache/bts/    recursive=${True}

Custom Test Teardown
    gnbbbu.connect    force=${True}
    common_setups_and_teardowns.Common Postconditions With Restore Configuration If Test Failed
    ...    collect_snapshot_from_ru=${False}

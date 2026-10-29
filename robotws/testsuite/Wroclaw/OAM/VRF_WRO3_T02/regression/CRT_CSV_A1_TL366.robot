*** Settings ***
Documentation
...   author: Daniel Grzesik
...   modified: Daniel Grzesik
...   Test suite for basic UUF OAM Tests in loop
...
...             !! to start use flag '-v TECHNOLOGY:{ALL,ONLY_4G,ONLY_5G}' :: example below
...             EXAMPLE :::   robot --timestampoutputs -V /home/ute/testline_configuration/10_16_UTESRAN366/__init__.py -v TECHNOLOGY:ALL
...             -L TRACE -b debug.log -d results /home/ute/robotws/testsuite/Wroclaw/OAM/VRF_WRO3_T02/regression/CRT_CSV_A1_TL366.robot


Library         taf.sw.scout    WITH NAME   scout
Library         taf/rfrl/csv4all/CSV4AllTestCases.py
Resource        taf/rfrl/scrambling_logs_collector/Keywords.robot
Resource        ../common_resources/scout/scout_operations.robot
Variables       ../common_resources/qc_id_csv/qc_id_functions.py


*** Variables ***
${RP_CA}   VRF_OAM
${RP_LOCATION}    VRF_WRO3
${RP_ORGANIZATION}    VRF_WRO3_T02
${QC_DOMAIN}=               MN_RAN
${QC_PROJECT}=              RAN_VRF

${UPGRADE_ITERATIONS}=               3
${ACTIVATION_RESET_ITERATION}=       20
${SITE_RESET_ITERATION}=             20
${RMOD_RESET_ITERATION}=             20
${BBMOD_RESET_ITERATION}=            10
${DELTA_COMMISSIONING_ITERATION}=    1
${CELL_OPERATION_ITERATION}=         5
@{CUSTOM_ALARMS}=                    4110  4003  6134  6351  61510  7300  7312  7509  7511  7513  8000  6150
@{CRITICAL_ALARMS}=                  10  16  1806  1868  4341  4352  4383
${SOURCE_SW}=                        SBTS24R2_ENB_0000_000933_000000
${TARGET_SW}=                        SBTS25R1_ENB_0000_000509_000000
${TARGET_SW_PATH}                    ${None}
${RESTORE_TO_TARGET_SW}              ${True}
@{USER_SUSPICIOUS_PRINTS}            @{EMPTY}
${DISABLE_SYSLOG_CHECK}=             ${False}
${ALARM_TIMEOUT}=                    60
${HARDWARE_CHECK_TIMEOUT}=           1000
@{SYSLOG_IGNORED_PRINTS}=            INF
${SHOULD_BE_REPORTED}=               True
@{CUSTOMERS_LIST}=                   A1 Austria
${FINAL_CHECK}=                      True
${PERFORM_UBOOT_DOWNGRADE}           ${False}
${USE_EXTERNAL_STORAGE}=             ${False}
${BTS_ID}                            ${tl.gnbs[0].instance_id}
${SITE_RESET_DELTA}=                 ${CURDIR}/../features/CSV/Resources/MRBTS-${BTS_ID}/site_reset_parameter.json
${ONLINE_PARAMETER_DELTA}=           ${CURDIR}/../features/CSV/Resources/MRBTS-${BTS_ID}/online_parameter.json
${NR_RAT_RESET_DELTA}=               ${CURDIR}/../features/CSV/Resources/MRBTS-${BTS_ID}/delta_nr_rat_reset.json
${LTE_RAT_RESET_DELTA}=              ${CURDIR}/../features/CSV/Resources/MRBTS-${BTS_ID}/delta_lte_rat_reset.json
${WCDMA_RAT_RESET_DELTA}=            ${CURDIR}/../features/CSV/Resources/MRBTS-${BTS_ID}/delta_wcdma_rat_reset.json

@{NODES}                            ${GNB1}
@{TEST_NODES}                       ${GNB1}

&{GNB1}     node_alias=5G               testline_object=${tl.gnbs[0]}
...         source_sw=${SOURCE_SW}      target_sw=${TARGET_SW}
...         hw_to_onair_timeout=${HARDWARE_CHECK_TIMEOUT}
...         critical_alarms=@{CRITICAL_ALARMS}
...         alarm_timer=${ALARM_TIMEOUT}
...         custom_allowed_alarms=@{CUSTOM_ALARMS}
...         syslog_ignored_prints=@{SYSLOG_IGNORED_PRINTS}


*** Test Cases ***

E2E_TL_SW_upgrade_rollback_with_OAM_KPI
    [Timeout]   72h
    run keyword if  '${TECHNOLOGY}'=='ALL'
    ...         E2E TL SW UPGRADE ROLLBACK WITH OAM KPI    ${NODES}    ${GNB1}    ${UPGRADE_ITERATIONS}
    ...         customers_list=@{CUSTOMERS_LIST}
    ...         report=${SHOULD_BE_REPORTED}
    ...         restore_to_target_sw=${RESTORE_TO_TARGET_SW}
    ...         use_external_storage=${USE_EXTERNAL_STORAGE}
    ...         download_path=${TARGET_SW_PATH}
    ...         qc_domain=${QC_DOMAIN}
    ...         qc_project=${QC_PROJECT}
    ...         qc_id=${qc_ids['366_qc_upgrade']}
    [Teardown]      Run keyword and ignore error     Collect and send logs for scrambling verification
    ...                                              team_name=PZ3WRO2
    ...                                              input_logs_dir=${NONE}

E2E_TL_Activation_Reset_with_OAM_KPI
    [Timeout]   72h
    run keyword if  '${TECHNOLOGY}'=='ALL' or '${TECHNOLOGY}'=='5G_W_O_UPGRADE'
    ...         E2E TL ACTIVATION RESET TEST  ${NODES}    ${GNB1}    ${ACTIVATION_RESET_ITERATION}
    ...         customers_list=@{CUSTOMERS_LIST}
    ...         report=${SHOULD_BE_REPORTED}
    ...         qc_domain=${QC_DOMAIN}
    ...         qc_project=${QC_PROJECT}
    ...         qc_id=${qc_ids['366_qc_activation_reset']}
    ...         use_external_storage=${USE_EXTERNAL_STORAGE}

E2E_TL_Site_Reset_with_OAM_KPI
    [Timeout]   72h
    run keyword if  '${TECHNOLOGY}'=='ALL' or '${TECHNOLOGY}'=='5G_W_O_UPGRADE'
    ...         E2E TL SITE RESET WITH OAM KPI  ${NODES}    ${GNB1}    ${SITE_RESET_ITERATION}
    ...         customers_list=@{CUSTOMERS_LIST}
    ...         report=${SHOULD_BE_REPORTED}
    ...         qc_domain=${QC_DOMAIN}
    ...         qc_project=${QC_PROJECT}
    ...         qc_id=${qc_ids['366_qc_site_reset']}

E2E_TL_Capacity_Module_Reset_with_OAM_KPI
    [Timeout]   72h
    run keyword if  '${TECHNOLOGY}'=='ALL' or '${TECHNOLOGY}'=='5G_W_O_UPGRADE'
    ...         E2E TL CAPACITY MODULE RESET WITH OAM KPI  ${NODES}    ${GNB1}    ${BBMOD_RESET_ITERATION}
    ...         customers_list=@{CUSTOMERS_LIST}
    ...         report=${SHOULD_BE_REPORTED}
    ...         qc_domain=${QC_DOMAIN}
    ...         qc_project=${QC_PROJECT}
    ...         qc_id=${qc_ids['366_qc_bbmod_reset']}

E2E_TL_RU_Reset_with_OAM_KPI
    [Timeout]   72h
    run keyword if  '${TECHNOLOGY}'=='ALL' or '${TECHNOLOGY}'=='5G_W_O_UPGRADE'
    ...         E2E TL RU RESET WITH OAM KPI    ${NODES}    ${GNB1}    ${RMOD_RESET_ITERATION}
    ...         customers_list=@{CUSTOMERS_LIST}
    ...         report=${SHOULD_BE_REPORTED}
    ...         qc_domain=${QC_DOMAIN}
    ...         qc_project=${QC_PROJECT}
    ...         qc_id=${qc_ids['366_qc_ru_reset']}

E2E_TL_Cell_Lock_Unlock_NR_with_OAM_KPI
    [Timeout]   24h
    run keyword if  '${TECHNOLOGY}'=='ALL' or '${TECHNOLOGY}'=='5G_W_O_UPGRADE'
    ...         E2E TL CELL LOCK UNLOCK NR WITH OAM KPI     ${NODES}    ${GNB1}    ${CELL_OPERATION_ITERATION}
    ...         customers_list=@{CUSTOMERS_LIST}
    ...         report=${SHOULD_BE_REPORTED}
    ...         qc_domain=${QC_DOMAIN}
    ...         qc_project=${QC_PROJECT}
    ...         qc_id=${qc_ids['366_qc_cell_lock_nr']}

E2E_TL_Cell_Lock_Unlock_LTE_with_OAM_KPI
    [Timeout]   24h
    run keyword if  '${TECHNOLOGY}'=='ALL' or '${TECHNOLOGY}'=='5G_W_O_UPGRADE'
    ...         E2E TL CELL LOCK UNLOCK LTE WITH OAM KPI    ${NODES}    ${GNB1}    ${CELL_OPERATION_ITERATION}
    ...         customers_list=@{CUSTOMERS_LIST}
    ...         report=${SHOULD_BE_REPORTED}
    ...         qc_domain=${QC_DOMAIN}
    ...         qc_project=${QC_PROJECT}
    ...         qc_id=${qc_ids['366_qc_cell_lock_lte']}

E2E_TL_Cell_Block_Unblock_NR_with_OAM_KPI
    [Timeout]   24h
    run keyword if  '${TECHNOLOGY}'=='ALL' or '${TECHNOLOGY}'=='5G_W_O_UPGRADE'
    ...         E2E TL CELL BLOCK UNBLOCK NR WITH OAM KPI    ${NODES}    ${GNB1}    ${CELL_OPERATION_ITERATION}
    ...         customers_list=@{CUSTOMERS_LIST}
    ...         report=${SHOULD_BE_REPORTED}
    ...         qc_domain=${QC_DOMAIN}
    ...         qc_project=${QC_PROJECT}
    ...         qc_id=${qc_ids['366_qc_cell_block_nr']}

E2E_TL_Cell_Block_Unblock_LTE_with_OAM_KPI
    [Timeout]   24h
    run keyword if  '${TECHNOLOGY}'=='ALL' or '${TECHNOLOGY}'=='5G_W_O_UPGRADE'
    ...         E2E TL CELL BLOCK UNBLOCK LTE WITH OAM KPI    ${NODES}    ${GNB1}    ${CELL_OPERATION_ITERATION}
    ...         customers_list=@{CUSTOMERS_LIST}
    ...         report=${SHOULD_BE_REPORTED}
    ...         qc_domain=${QC_DOMAIN}
    ...         qc_project=${QC_PROJECT}
    ...         qc_id=${qc_ids['366_qc_cell_block_lte']}

E2E_TL_Cell_Block_Unblock_WCDMA_with_OAM_KPI
    [Timeout]   24h
    run keyword if  '${TECHNOLOGY}'=='ALL' or '${TECHNOLOGY}'=='5G_W_O_UPGRADE'
    ...         E2E TL CELL BLOCK UNBLOCK WCDMA WITH OAM KPI    ${NODES}    ${GNB1}    ${CELL_OPERATION_ITERATION}
    ...         customers_list=@{CUSTOMERS_LIST}
    ...         report=${SHOULD_BE_REPORTED}
    ...         qc_domain=${QC_DOMAIN}
    ...         qc_project=${QC_PROJECT}
    ...         qc_id=${qc_ids['366_qc_cell_block_wcdma']}

E2E_TL_Delta_Commissioning_With_Site_Reset_Required
    [Timeout]   24h
    run keyword if  '${TECHNOLOGY}'=='ALL' or '${TECHNOLOGY}'=='5G_W_O_UPGRADE'
    ...         E2E TL DELTA COMMISSIONING WITH SITE RESET REQUIRED     ${NODES}    ${GNB1}    ${DELTA_COMMISSIONING_ITERATION}
    ...         customers_list=@{CUSTOMERS_LIST}
    ...         report=${SHOULD_BE_REPORTED}
    ...         delta=${SITE_RESET_DELTA}
    ...         qc_domain=${QC_DOMAIN}
    ...         qc_project=${QC_PROJECT}
    ...         qc_id=${qc_ids['366_qc_delta_reset']}

E2E_TL_Delta_Commissioning_With_Online_Parameter_Modification
    [Timeout]   24h
    run keyword if  '${TECHNOLOGY}'=='ALL' or '${TECHNOLOGY}'=='5G_W_O_UPGRADE'
    ...         E2E TL DELTA COMMISSIONING WITH ONLINE PARAMETER MODIFICATION       ${NODES}    ${GNB1}    ${DELTA_COMMISSIONING_ITERATION}
    ...         customers_list=@{CUSTOMERS_LIST}
    ...         report=${SHOULD_BE_REPORTED}
    ...         delta=${ONLINE_PARAMETER_DELTA}
    ...         qc_domain=${QC_DOMAIN}
    ...         qc_project=${QC_PROJECT}
    ...         qc_id=${qc_ids['366_qc_delta_online']}

E2E_TL_Delta_Commissioning_With_NR_Rat_Reset
    [Timeout]   24h
    run keyword if  '${TECHNOLOGY}'=='ALL' or '${TECHNOLOGY}'=='5G_W_O_UPGRADE'
    ...         E2E TL DELTA COMMISSIONING WITH ONLINE PARAMETER MODIFICATION       ${NODES}    ${GNB1}    ${DELTA_COMMISSIONING_ITERATION}
    ...         customers_list=@{CUSTOMERS_LIST}
    ...         report=${SHOULD_BE_REPORTED}
    ...         delta=${NR_RAT_RESET_DELTA}
    ...         qc_domain=${QC_DOMAIN}
    ...         qc_project=${QC_PROJECT}
    ...         qc_id=${qc_ids['366_qc_delta_nr']}

E2E_TL_Delta_Commissioning_With_LTE_Rat_Reset
    [Timeout]   24h
    run keyword if  '${TECHNOLOGY}'=='ALL' or '${TECHNOLOGY}'=='5G_W_O_UPGRADE'
    ...         E2E TL DELTA COMMISSIONING WITH ONLINE PARAMETER MODIFICATION       ${NODES}    ${GNB1}    ${DELTA_COMMISSIONING_ITERATION}
    ...         customers_list=@{CUSTOMERS_LIST}
    ...         report=${SHOULD_BE_REPORTED}
    ...         delta=${LTE_RAT_RESET_DELTA}
    ...         qc_domain=${QC_DOMAIN}
    ...         qc_project=${QC_PROJECT}
    ...         qc_id=${qc_ids['366_qc_delta_lte']}

E2E_TL_Delta_Commissioning_With_WCDMA_Rat_Reset
    [Timeout]   24h
    run keyword if  '${TECHNOLOGY}'=='ALL' or '${TECHNOLOGY}'=='5G_W_O_UPGRADE'
    ...         E2E TL DELTA COMMISSIONING WITH ONLINE PARAMETER MODIFICATION       ${NODES}    ${GNB1}    ${DELTA_COMMISSIONING_ITERATION}
    ...         customers_list=@{CUSTOMERS_LIST}
    ...         report=${SHOULD_BE_REPORTED}
    ...         delta=${WCDMA_RAT_RESET_DELTA}
    ...         qc_domain=${QC_DOMAIN}
    ...         qc_project=${QC_PROJECT}
    ...         qc_id=${qc_ids['366_qc_delta_wcdma']}


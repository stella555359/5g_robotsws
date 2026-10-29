*** Settings ***
Documentation   Suite for E2E CRT regression
...             Author: Daniel Grzesik
...             daniel.grzesik@nokia.com
...             Maintainter: Daniel Grzesik
...
...             !! to start use flag '-v TECHNOLOGY:{ALL,ONLY_4G,ONLY_5G}' :: example below
...             EXAMPLE :::   robot --timestampoutputs -V /home/ute/testline_configuration/10_16_UTESRAN361/__init__.py -v TECHNOLOGY:ALL
...             -L TRACE -b debug.log -d results /home/ute/robotws/testsuite/Wroclaw/OAM/VRF_WRO3_T02/regression/CSV_VDF_TL_365.robot

Library         taf.sbts.oam.coam.admin  WITH NAME   coam_admin
Library         taf.sw.scout             WITH NAME   scout
Library         ute_ue
Library         ../features/CSV/Resources/uuf_attach_test.py
Library         taf/rfrl/csv4all/CSV4AllTestCases.py


Resource        ../common_resources/scf/scf_sender.robot
Resource        ../common_resources/scout/scout_operations.robot
Resource        taf/rfrl/scrambling_logs_collector/Keywords.robot
Resource        ../features/CB007442/TestCases/CB007442-Suite.robot
Resource        ../common_resources/alarms/alarm.robot
Variables       ../common_resources/qc_id_csv/qc_id_functions.py


Force Tags      CA_VRF_WRO3    RAN_5G
...             STATE_SW_UPLOADED
...             CLOUD_5G_CLASSICAL_ASIA_ASIB_ABIL_ABIO_ARGA_FXED_FHRC
...             AVG_EXE_TIME=
...             RESPONSIBLE_TESTER=grzesik


*** Variables ***
${RP_CA}   VRF_OAM
${RP_LOCATION}    VRF_WRO3
${RP_ORGANIZATION}    VRF_WRO3_T02
${QC_DOMAIN}=               MN_RAN
${QC_PROJECT}=              RAN_VRF

${UPGRADE_ITERATIONS_5G}=            3
${UPGRADE_ITERATIONS_4G}=            3
${ACTIVATION_RESET_ITERATION_5G}=    20
${ACTIVATION_RESET_ITERATION_4G}=    20
${SITE_RESET_ITERATION_5G}=          20
${SITE_RESET_ITERATION_4G}=          20
${RMOD_RESET_ITERATION_5G}=          10
${RMOD_RESET_ITERATION_4G}=          10
${BBMOD_RESET_ITERATION_5G}=         10
${BBMOD_RESET_ITERATION_4G}=         10
${DELTA_COMMISSIONING_ITERATION}=    1
${CELL_OPERATION_ITERATION}=         5
@{CUSTOM_ALARMS_ALL_5G}=             7307  62003  1898  7115  61510  7509  61011  61618  6134  6150  7513  7107  7319  7300
@{CUSTOM_ALARMS_ALL_4G}=             7307  62003  1898  7115  61510  7509  61011  61618  6327  6150  6134  6202  6129
@{TEMPORARY_ALARMS_4G}=              10  1815  1898  4220  4773  6134  6327  62003  6129  6202  4773  4110  4003
@{TEMPORARY_ALARMS_5G}=              10  1815  7107  7300  7319  7509  7519  62003  7511  4773  4110  4003
@{CRITICAL_ALARMS}=                  10  16  1806  1868  4341  4352  4383
${SOURCE_SW}=                        SBTS24R2_ENB_0000_000933_000000
${SOURCE_SW_4G}=                     SBTS24R2_ENB_0000_000933_000000
${TARGET_SW}=                        SBTS00_ENB_9999_241217_000007
${TARGET_SW_PATH}=                   ${None}
${RESTORE_TO_TARGET_SW}=             ${True}
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
${BTS_ID_5G}                         ${tl.gnbs[0].instance_id}
${BTS_ID_4G}                         ${tl.enbs[0].instance_id}

${SITE_RESET_DELTA_5G}=                ${CURDIR}/../features/CSV/Resources/MRBTS-${BTS_ID_5G}/site_reset_parameter.json
${ONLINE_PARAMETER_DELTA_5G}=          ${CURDIR}/../features/CSV/Resources/MRBTS-${BTS_ID_5G}/online_parameter.json
${NR_RAT_RESET_DELTA_5G}=              ${CURDIR}/../features/CSV/Resources/MRBTS-${BTS_ID_5G}/delta_nr_rat_reset.json
${LTE_RAT_RESET_DELTA_5G}=             ${CURDIR}/../features/CSV/Resources/MRBTS-${BTS_ID_5G}/delta_lte_rat_reset.json
${GSM_RAT_RESET_DELTA_5G}=             ${CURDIR}/../features/CSV/Resources/MRBTS-${BTS_ID_5G}/delta_gsm_rat_reset.json
${SITE_RESET_DELTA_4G}=                ${CURDIR}/../features/CSV/Resources/MRBTS-${BTS_ID_4G}/site_reset_parameter.json
${ONLINE_PARAMETER_DELTA_4G}=          ${CURDIR}/../features/CSV/Resources/MRBTS-${BTS_ID_4G}/online_parameter.json
${NR_RAT_RESET_DELTA_4G}=              ${CURDIR}/../features/CSV/Resources/MRBTS-${BTS_ID_4G}/delta_nr_rat_reset.json
${LTE_RAT_RESET_DELTA_4G}=             ${CURDIR}/../features/CSV/Resources/MRBTS-${BTS_ID_4G}/delta_lte_rat_reset.json
${WCDMA_RAT_RESET_DELTA_4G}=           ${CURDIR}/../features/CSV/Resources/MRBTS-${BTS_ID_4G}/delta_wcdma_rat_reset.json

@{NODES}                            ${GNB1}    ${ENB1}
@{TEST_NODES}                       ${GNB1}    ${ENB1}

&{GNB1}     node_alias=5G               testline_object=${tl.gnbs[0]}
...         source_sw=${SOURCE_SW}      target_sw=${TARGET_SW}
...         hw_to_onair_timeout=${HARDWARE_CHECK_TIMEOUT}
...         critical_alarms=@{CRITICAL_ALARMS}
...         alarm_timer=${ALARM_TIMEOUT}
...         custom_allowed_alarms=@{CUSTOM_ALARMS_ALL_5G}
...         temporary_allowed_alarms==@{TEMPORARY_ALARMS_4G}



&{ENB1}     node_alias=4G               node_vm=10.44.156.94
...         source_sw=${SOURCE_SW_4G}      target_sw=${TARGET_SW}
...         hw_to_onair_timeout=${HARDWARE_CHECK_TIMEOUT}
...         critical_alarms=@{CRITICAL_ALARMS}
...         alarm_timer=${ALARM_TIMEOUT}
...         custom_allowed_alarms=@{CUSTOM_ALARMS_ALL_4G}
...         temporary_allowed_alarms=@{TEMPORARY_ALARMS_5G}


*** Test Cases ***

E2E_TL_SW_Upgrade_Rollback_with_OAM_KPI
    [Timeout]   72h
    [Tags]    E2E_TL_SW_upgrade_rollback_with_OAM_KPI
    Run Keyword And Continue On Failure  run keyword if  '${TECHNOLOGY}'=='ONLY_5G' or '${TECHNOLOGY}'=='ALL'
    ...         E2E TL SW UPGRADE ROLLBACK WITH OAM KPI    ${NODES}    ${GNB1}    ${UPGRADE_ITERATIONS_5G}
    ...         customers_list=@{CUSTOMERS_LIST}
    ...         report=${SHOULD_BE_REPORTED}
    ...         restore_to_target_sw=${RESTORE_TO_TARGET_SW}
    ...         use_external_storage=${USE_EXTERNAL_STORAGE}
    ...         download_path=${TARGET_SW_PATH}
    ...         qc_domain=${QC_DOMAIN}
    ...         qc_project=${QC_PROJECT}
    ...         qc_id=${qc_ids['362_qc_upgrade']}
    [Teardown]      Run keyword and ignore error     Collect and send logs for scrambling verification
    ...                                              team_name=PZ3WRO2
    ...                                              input_logs_dir=${NONE}
    run keyword if  '${TECHNOLOGY}'=='ONLY_4G' or '${TECHNOLOGY}'=='ALL'
    ...         E2E TL SW UPGRADE ROLLBACK WITH OAM KPI    ${NODES}    ${ENB1}    ${UPGRADE_ITERATIONS_4G}
    ...         customers_list=@{CUSTOMERS_LIST}
    ...         report=${SHOULD_BE_REPORTED}
    ...         restore_to_target_sw=${RESTORE_TO_TARGET_SW}
    ...         use_external_storage=${USE_EXTERNAL_STORAGE}
    ...         download_path=${TARGET_SW_PATH}
    ...         qc_domain=${QC_DOMAIN}
    ...         qc_project=${QC_PROJECT}
    ...         qc_id=${qc_ids['361_qc_upgrade']}

E2E_TL_Activation_Reset_with_OAM_KPI
    [Timeout]   72h
    [Tags]    E2E_TL_Activation_Reset_Test
    Run Keyword And Continue On Failure  run keyword if  '${TECHNOLOGY}'=='ONLY_5G' or '${TECHNOLOGY}'=='ALL' or '${TECHNOLOGY}'=='5G_W_O_UPGRADE'
    ...         E2E TL ACTIVATION RESET TEST  ${NODES}    ${GNB1}    ${ACTIVATION_RESET_ITERATION_5G}
    ...         customers_list=@{CUSTOMERS_LIST}
    ...         report=${SHOULD_BE_REPORTED}
    ...         qc_domain=${QC_DOMAIN}
    ...         qc_project=${QC_PROJECT}
    ...         qc_id=${qc_ids['362_qc_activation_reset']}
    ...         use_external_storage=${USE_EXTERNAL_STORAGE}
    run keyword if  '${TECHNOLOGY}'=='ONLY_4G' or '${TECHNOLOGY}'=='ALL'
    ...         E2E TL ACTIVATION RESET TEST  ${NODES}    ${ENB1}    ${ACTIVATION_RESET_ITERATION_4G}
    ...         customers_list=@{CUSTOMERS_LIST}
    ...         report=${SHOULD_BE_REPORTED}
    ...         qc_domain=${QC_DOMAIN}
    ...         qc_project=${QC_PROJECT}
    ...         qc_id=${qc_ids['361_qc_activation_reset']}
    ...         use_external_storage=${USE_EXTERNAL_STORAGE}

E2E_TL_Site_Reset_with_OAM_KPI
    [Timeout]   72h
    [Tags]    E2E_TL_Site_Reset_with_OAM_KPI
    Run Keyword And Continue On Failure  run keyword if  '${TECHNOLOGY}'=='ONLY_5G' or '${TECHNOLOGY}'=='ALL' or '${TECHNOLOGY}'=='5G_W_O_UPGRADE'
    ...         E2E TL SITE RESET WITH OAM KPI  ${NODES}    ${GNB1}    ${SITE_RESET_ITERATION_5G}
    ...         customers_list=@{CUSTOMERS_LIST}
    ...         report=${SHOULD_BE_REPORTED}
    ...         qc_domain=${QC_DOMAIN}
    ...         qc_project=${QC_PROJECT}
    ...         qc_id=${qc_ids['362_qc_site_reset']}
    run keyword if  '${TECHNOLOGY}'=='ONLY_4G' or '${TECHNOLOGY}'=='ALL'
    ...         E2E TL SITE RESET WITH OAM KPI  ${NODES}    ${ENB1}    ${SITE_RESET_ITERATION_4G}
    ...         customers_list=@{CUSTOMERS_LIST}
    ...         report=${SHOULD_BE_REPORTED}
    ...         qc_domain=${QC_DOMAIN}
    ...         qc_project=${QC_PROJECT}
    ...         qc_id=${qc_ids['361_qc_site_reset']}

E2E_TL_Capacity_Module_Reset_with_OAM_KPI
    [Timeout]   72h
    [Tags]    E2E_TL_Capacity_Module_Reset_with_OAM_KPI
    Run Keyword And Continue On Failure  run keyword if  '${TECHNOLOGY}'=='ONLY_5G' or '${TECHNOLOGY}'=='ALL' or '${TECHNOLOGY}'=='5G_W_O_UPGRADE'
    ...         E2E TL CAPACITY MODULE RESET WITH OAM KPI  ${NODES}    ${GNB1}    ${BBMOD_RESET_ITERATION_5G}
    ...         customers_list=@{CUSTOMERS_LIST}
    ...         report=${SHOULD_BE_REPORTED}
    ...         qc_domain=${QC_DOMAIN}
    ...         qc_project=${QC_PROJECT}
    ...         qc_id=${qc_ids['362_qc_bbmod_reset']}
    run keyword if  '${TECHNOLOGY}'=='ONLY_4G' or '${TECHNOLOGY}'=='ALL'
    ...         E2E TL CAPACITY MODULE RESET WITH OAM KPI  ${NODES}    ${ENB1}    ${BBMOD_RESET_ITERATION_4G}
    ...         customers_list=@{CUSTOMERS_LIST}
    ...         report=${SHOULD_BE_REPORTED}
    ...         qc_domain=${QC_DOMAIN}
    ...         qc_project=${QC_PROJECT}
    ...         qc_id=${qc_ids['361_qc_bbmod_reset']}

E2E_TL_RU_Reset_with_OAM_KPI
    [Timeout]   72h
    [Tags]    E2E_TL_RU_Reset_with_OAM_KPI
    Run Keyword And Continue On Failure  run keyword if  '${TECHNOLOGY}'=='ONLY_5G' or '${TECHNOLOGY}'=='ALL' or '${TECHNOLOGY}'=='5G_W_O_UPGRADE'
    ...         E2E TL RU RESET WITH OAM KPI    ${NODES}    ${GNB1}    ${RMOD_RESET_ITERATION_5G}
    ...         customers_list=@{CUSTOMERS_LIST}
    ...         report=${SHOULD_BE_REPORTED}
    ...         qc_domain=${QC_DOMAIN}
    ...         qc_project=${QC_PROJECT}
    ...         qc_id=${qc_ids['362_qc_ru_reset']}
    run keyword if  '${TECHNOLOGY}'=='ONLY_4G' or '${TECHNOLOGY}'=='ALL'
    ...         E2E TL RU RESET WITH OAM KPI    ${NODES}    ${ENB1}    ${RMOD_RESET_ITERATION_4G}
    ...         customers_list=@{CUSTOMERS_LIST}
    ...         report=${SHOULD_BE_REPORTED}
    ...         qc_domain=${QC_DOMAIN}
    ...         qc_project=${QC_PROJECT}
    ...         qc_id=${qc_ids['361_qc_ru_reset']}

E2E_TL_Cell_Lock_Unlock_NR_with_OAM_KPI
    [Timeout]   24h
    [Tags]    E2E_TL_Cell_Lock_Unlock_NR_with_OAM_KPI
    run keyword if  '${TECHNOLOGY}'=='ONLY_5G' or '${TECHNOLOGY}'=='ALL' or '${TECHNOLOGY}'=='5G_W_O_UPGRADE'
    ...         E2E TL CELL LOCK UNLOCK NR WITH OAM KPI     ${NODES}    ${GNB1}
    ...         customers_list=@{CUSTOMERS_LIST}
    ...         report=${SHOULD_BE_REPORTED}
    ...         iterations_per_node=${CELL_OPERATION_ITERATION}
    ...         qc_domain=${QC_DOMAIN}
    ...         qc_project=${QC_PROJECT}
    ...         qc_id=${qc_ids['362_qc_cell_lock_nr']}

E2E_TL_Cell_Lock_Unlock_LTE_with_OAM_KPI
    [Timeout]   24h
    [Tags]    E2E_TL_Cell_Lock_Unlock_LTE_with_OAM_KPI
    run keyword if  '${TECHNOLOGY}'=='ONLY_4G' or '${TECHNOLOGY}'=='ALL'
    ...         E2E TL CELL LOCK UNLOCK LTE WITH OAM KPI    ${NODES}    ${ENB1}    ${CELL_OPERATION_ITERATION}
    ...         customers_list=@{CUSTOMERS_LIST}
    ...         report=${SHOULD_BE_REPORTED}
    ...         qc_domain=${QC_DOMAIN}
    ...         qc_project=${QC_PROJECT}
    ...         qc_id=${qc_ids['361_qc_cell_lock_lte']}

E2E_TL_Cell_Block_Unblock_WCDMA_with_OAM_KPI
    [Timeout]   24h
    [Tags]    E2E_TL_Cell_Block_Unblock_WCDMA_with_OAM_KPI
    run keyword if  '${TECHNOLOGY}'=='ONLY_4G' or '${TECHNOLOGY}'=='ALL'
    ...         E2E TL CELL BLOCK UNBLOCK WCDMA WITH OAM KPI    ${NODES}    ${ENB1}    ${CELL_OPERATION_ITERATION}
    ...         customers_list=@{CUSTOMERS_LIST}
    ...         report=${SHOULD_BE_REPORTED}
    ...         qc_domain=${QC_DOMAIN}
    ...         qc_project=${QC_PROJECT}
    ...         qc_id=${qc_ids['361_qc_cell_block_wcdma']}

E2E_TL_Delta_Commissioning_With_Site_Reset_Required
    [Timeout]   24h
    [Tags]    E2E_TL_Delta_Commissioning_With_Site_Reset_Required
    run keyword if  '${TECHNOLOGY}'=='ONLY_5G' or '${TECHNOLOGY}'=='ALL' or '${TECHNOLOGY}'=='5G_W_O_UPGRADE'
    ...         E2E TL DELTA COMMISSIONING WITH SITE RESET REQUIRED     ${NODES}    ${GNB1}    ${DELTA_COMMISSIONING_ITERATION}
    ...         customers_list=@{CUSTOMERS_LIST}
    ...         report=${SHOULD_BE_REPORTED}
    ...         delta=${SITE_RESET_DELTA_5G}
    ...         qc_domain=${QC_DOMAIN}
    ...         qc_project=${QC_PROJECT}
    ...         qc_id=${qc_ids['362_qc_delta_reset']}

E2E_TL_Delta_Commissioning_With_Online_Parameter_Modification
    [Timeout]   24h
    [Tags]    E2E_TL_Delta_Commissioning_With_Online_Parameter_Modification
    run keyword if  '${TECHNOLOGY}'=='ONLY_5G' or '${TECHNOLOGY}'=='ALL' or '${TECHNOLOGY}'=='5G_W_O_UPGRADE'
    ...         E2E TL DELTA COMMISSIONING WITH ONLINE PARAMETER MODIFICATION       ${NODES}    ${GNB1}    ${DELTA_COMMISSIONING_ITERATION}
    ...         customers_list=@{CUSTOMERS_LIST}
    ...         report=${SHOULD_BE_REPORTED}
    ...         delta=${ONLINE_PARAMETER_DELTA_5G}
    ...         qc_domain=${QC_DOMAIN}
    ...         qc_project=${QC_PROJECT}
    ...         qc_id=${qc_ids['362_qc_delta_online']}

E2E_TL_Delta_Commissioning_With_NR_Rat_Reset
    [Timeout]   24h
    [Tags]    E2E_TL_Delta_Commissioning_With_NR_Rat_Reset
    run keyword if  '${TECHNOLOGY}'=='ONLY_5G' or '${TECHNOLOGY}'=='ALL' or '${TECHNOLOGY}'=='5G_W_O_UPGRADE'
    ...         E2E TL DELTA COMMISSIONING WITH ONLINE PARAMETER MODIFICATION       ${NODES}    ${GNB1}    ${DELTA_COMMISSIONING_ITERATION}
    ...         customers_list=@{CUSTOMERS_LIST}
    ...         report=${SHOULD_BE_REPORTED}
    ...         delta=${NR_RAT_RESET_DELTA_5G}
    ...         qc_domain=${QC_DOMAIN}
    ...         qc_project=${QC_PROJECT}
    ...         qc_id=${qc_ids['362_qc_delta_nr']}

E2E_TL_Delta_Commissioning_With_LTE_Rat_Reset
    [Timeout]   24h
    [Tags]    E2E_TL_Delta_Commissioning_With_LTE_Rat_Reset
    run keyword if  '${TECHNOLOGY}'=='ONLY_4G' or '${TECHNOLOGY}'=='ALL'
    ...         E2E TL DELTA COMMISSIONING WITH ONLINE PARAMETER MODIFICATION       ${NODES}    ${ENB1}    ${DELTA_COMMISSIONING_ITERATION}
    ...         customers_list=@{CUSTOMERS_LIST}
    ...         report=${SHOULD_BE_REPORTED}
    ...         delta=${LTE_RAT_RESET_DELTA_4G}
    ...         qc_domain=${QC_DOMAIN}
    ...         qc_project=${QC_PROJECT}
    ...         qc_id=${qc_ids['361_qc_delta_lte']}

E2E_TL_Delta_Commissioning_With_WCDMA_Rat_Reset
    [Timeout]   24h
    [Tags]    E2E_TL_Delta_Commissioning_With_WCDMA_Rat_Reset
    run keyword if  '${TECHNOLOGY}'=='ONLY_4G' or '${TECHNOLOGY}'=='ALL'
    ...         E2E TL DELTA COMMISSIONING WITH ONLINE PARAMETER MODIFICATION       ${NODES}    ${ENB1}    ${DELTA_COMMISSIONING_ITERATION}
    ...         customers_list=@{CUSTOMERS_LIST}
    ...         report=${SHOULD_BE_REPORTED}
    ...         delta=${WCDMA_RAT_RESET_DELTA_4G}
    ...         qc_domain=${QC_DOMAIN}
    ...         qc_project=${QC_PROJECT}
    ...         qc_id=${qc_ids['361_qc_delta_wcdma']}

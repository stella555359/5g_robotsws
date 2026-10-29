*** Settings ***
Documentation   Suite for E2E CRT regression
...             Author: Daniel Grzesik
...             daniel.grzesik@nokia.com
...             Maintainter: Daniel Grzesik
...
...             To start TestCase use flag '-i' and 'L3_CALL' or 'NO_L3_CALL'
...             To add L3 to TestCase add 'attach_test_keyword=attach_test'

Library         taf.sbts.oam.coam.admin  WITH NAME   coam_admin
Library         taf.sw.scout             WITH NAME   scout
Library         taf/rfrl/csv4all/CSV4AllTestCases.py


Resource        taf/rfrl/scrambling_logs_collector/Keywords.robot
Variables       ../common_resources/qc_id_csv/qc_id_functions.py

Force Tags      CA_VRF_WRO3    RAN_5G
...             STATE_SW_UPLOADED
...             CLOUD_5G_CLASSICAL_ASIM_ABIQ_WRO_TRS_369
...             AVG_EXE_TIME=
...             RESPONSIBLE_TESTER=grzesik

*** Variables ***
${RP_CA}   VRF_OAM
${RP_LOCATION}    VRF_WRO3
${RP_ORGANIZATION}    VRF_WRO3_T02
${QC_DOMAIN}=               MN_RAN
${QC_PROJECT}=              RAN_VRF



${UPGRADE_ITERATIONS}=               3
${ACTIVATION_RESET_ITERATION}=       10
${SITE_RESET_ITERATION}=             20
${RMOD_RESET_ITERATION}=             20
${BBMOD_RESET_ITERATION}=            10
${DELTA_COMMISSIONING_ITERATION}=    1
${CELL_OPERATION_ITERATION}=         3
@{CUSTOM_ALARMS}=                    7307  62003  1898  7115  61510  7509  61011  61618  6134  6150  7513  7107  7319  7300  6351  4589
${CRITICAL_ALARMS}=                  10,16,1806,1868,4341,4352,4383
${SOURCE_SW}=                        SBTS25R2_ENB_0000_000382_000008
${TARGET_SW}=                        SBTS00_ENB_9999_250107_000008
${TARGET_SW_PATH}                    ${None}
${RESTORE_TO_TARGET_SW}              ${True}
@{USER_SUSPICIOUS_PRINTS}            @{EMPTY}
${DISABLE_SYSLOG_CHECK}=             ${False}
${ALARM_TIMEOUT}=                    60
${HARDWARE_CHECK_TIMEOUT}=           1000
@{SYSLOG_IGNORED_PRINTS}=            INF
${SHOULD_BE_REPORTED}=               True
@{CUSTOMERS_LIST}=                   VDF Italy
${FINAL_CHECK}=                      True
${PERFORM_UBOOT_DOWNGRADE}           ${False}
${USE_EXTERNAL_STORAGE}=             ${True}
${BTS_ID}                            ${tl.gnbs[0].instance_id}

${SITE_RESET_DELTA}=                ${CURDIR}/../features/CSV/Resources/MRBTS-${BTS_ID}/site_reset_parameter.json
${ONLINE_PARAMETER_DELTA}=          ${CURDIR}/../features/CSV/Resources/MRBTS-${BTS_ID}/online_parameter.json
${NR_RAT_RESET_DELTA}=              ${CURDIR}/../features/CSV/Resources/MRBTS-${BTS_ID}/delta_nr_rat_reset.json
${LTE_RAT_RESET_DELTA}=             ${CURDIR}/../features/CSV/Resources/MRBTS-${BTS_ID}/delta_lte_rat_reset.json
${GSM_RAT_RESET_DELTA}=             ${CURDIR}/../features/CSV/Resources/MRBTS-${BTS_ID}/delta_gsm_rat_reset.json

@{NODES}                            ${GNB1}
@{TEST_NODES}                       ${GNB1}

&{GNB1}     node_alias=5G               testline_object=${tl.gnbs[0]}
...         source_sw=${SOURCE_SW}      target_sw=${TARGET_SW}
...         hw_to_onair_timeout=${HARDWARE_CHECK_TIMEOUT}
...         critical_alarms=${CRITICAL_ALARMS}
...         alarm_timer=${ALARM_TIMEOUT}
...         custom_allowed_alarms=@{CUSTOM_ALARMS}
...         syslog_ignored_prints=@{SYSLOG_IGNORED_PRINTS}


*** Test Cases ***

E2E_TL_SW_upgrade_rollback_with_OAM_KPI
    [Timeout]   72h
    [Tags]    E2E_TL_SW_upgrade_rollback_with_OAM_KPI
    run keyword if  '${TECHNOLOGY}'=='ALL' or '${TECHNOLOGY}'=='TRUNK' or '${TECHNOLOGY}'=='25R3' or '${TECHNOLOGY}'=='25R2'
    ...         E2E TL SW UPGRADE ROLLBACK WITH OAM KPI    ${NODES}    ${GNB1}    ${UPGRADE_ITERATIONS}
    ...         customers_list=@{CUSTOMERS_LIST}
    ...         report=${SHOULD_BE_REPORTED}
    ...         restore_to_target_sw=${RESTORE_TO_TARGET_SW}
    ...         use_external_storage=${USE_EXTERNAL_STORAGE}
    ...         download_path=${TARGET_SW_PATH}
    ...         qc_domain=${QC_DOMAIN}
    ...         qc_project=${QC_PROJECT}
    ...         qc_id=${qc_ids['369_qc_upgrade']}
    [Teardown]      Run keyword and ignore error     Collect and send logs for scrambling verification
    ...                                              team_name=PZ3WRO2
    ...                                              input_logs_dir=${NONE}

E2E_TL_Activation_Reset_with_OAM_KPI
    [Timeout]   72h
    [Tags]    E2E_TL_Activation_Reset_Test
    run keyword if  '${TECHNOLOGY}'=='ALL' or '${TECHNOLOGY}'=='TRUNK' or '${TECHNOLOGY}'=='25R3' or '${TECHNOLOGY}'=='25R2'
    ...         E2E TL ACTIVATION RESET TEST  ${NODES}    ${GNB1}    ${ACTIVATION_RESET_ITERATION}
    ...         customers_list=@{CUSTOMERS_LIST}
    ...         report=${SHOULD_BE_REPORTED}
    ...         qc_domain=${QC_DOMAIN}
    ...         qc_project=${QC_PROJECT}
    ...         qc_id=${qc_ids['369_qc_activation_reset']}
    ...         use_external_storage=${USE_EXTERNAL_STORAGE}

E2E_TL_Site_Reset_with_OAM_KPI
    [Timeout]   72h
    [Tags]    E2E_TL_Site_Reset_with_OAM_KPI
    run keyword if  '${TECHNOLOGY}'=='ALL' or '${TECHNOLOGY}'=='TRUNK' or '${TECHNOLOGY}'=='25R3' or '${TECHNOLOGY}'=='25R2'
    ...         E2E TL SITE RESET WITH OAM KPI  ${NODES}    ${GNB1}    ${SITE_RESET_ITERATION}
    ...         customers_list=@{CUSTOMERS_LIST}
    ...         report=${SHOULD_BE_REPORTED}
    ...         qc_domain=${QC_DOMAIN}
    ...         qc_project=${QC_PROJECT}
    ...         qc_id=${qc_ids['369_qc_site_reset']}

E2E_TL_Capacity_Module_Reset_with_OAM_KPI
    [Timeout]   72h
    [Tags]    E2E_TL_Capacity_Module_Reset_with_OAM_KPI
    run keyword if  '${TECHNOLOGY}'=='ALL' or '${TECHNOLOGY}'=='TRUNK' or '${TECHNOLOGY}'=='25R3' or '${TECHNOLOGY}'=='25R2'
    ...         E2E TL CAPACITY MODULE RESET WITH OAM KPI  ${NODES}    ${GNB1}    ${BBMOD_RESET_ITERATION}
    ...         customers_list=@{CUSTOMERS_LIST}
    ...         report=${SHOULD_BE_REPORTED}
    ...         qc_domain=${QC_DOMAIN}
    ...         qc_project=${QC_PROJECT}
    ...         qc_id=${qc_ids['369_qc_bbmod_reset']}

E2E_TL_RU_Reset_with_OAM_KPI
    [Timeout]   72h
    [Tags]    E2E_TL_RU_Reset_with_OAM_KPI
    run keyword if  '${TECHNOLOGY}'=='ALL' or '${TECHNOLOGY}'=='TRUNK' or '${TECHNOLOGY}'=='25R3' or '${TECHNOLOGY}'=='25R2'
    ...         E2E TL RU RESET WITH OAM KPI    ${NODES}    ${GNB1}    ${RMOD_RESET_ITERATION}
    ...         customers_list=@{CUSTOMERS_LIST}
    ...         report=${SHOULD_BE_REPORTED}
    ...         qc_domain=${QC_DOMAIN}
    ...         qc_project=${QC_PROJECT}
    ...         qc_id=${qc_ids['369_qc_ru_reset']}

E2E_TL_Cell_Lock_Unlock_NR_with_OAM_KPI
    [Timeout]   24h
    [Tags]    E2E_TL_Cell_Lock_Unlock_NR_with_OAM_KPI
    run keyword if  '${TECHNOLOGY}'=='ALL' or '${TECHNOLOGY}'=='TRUNK' or '${TECHNOLOGY}'=='25R3' or '${TECHNOLOGY}'=='25R2'
    ...         E2E TL CELL LOCK UNLOCK NR WITH OAM KPI     ${NODES}    ${GNB1}    ${CELL_OPERATION_ITERATION}
    ...         customers_list=@{CUSTOMERS_LIST}
    ...         report=${SHOULD_BE_REPORTED}
    ...         qc_domain=${QC_DOMAIN}
    ...         qc_project=${QC_PROJECT}
    ...         qc_id=${qc_ids['369_qc_cell_lock_nr']}

E2E_TL_Cell_Lock_Unlock_LTE_with_OAM_KPI
    [Timeout]   24h
    [Tags]    E2E_TL_Cell_Lock_Unlock_LTE_with_OAM_KPI
    run keyword if  '${TECHNOLOGY}'=='ALL' or '${TECHNOLOGY}'=='TRUNK' or '${TECHNOLOGY}'=='25R3' or '${TECHNOLOGY}'=='25R2'
    ...         E2E TL CELL LOCK UNLOCK LTE WITH OAM KPI    ${NODES}    ${GNB1}    ${CELL_OPERATION_ITERATION}
    ...         customers_list=@{CUSTOMERS_LIST}
    ...         report=${SHOULD_BE_REPORTED}
    ...         qc_domain=${QC_DOMAIN}
    ...         qc_project=${QC_PROJECT}
    ...         qc_id=${qc_ids['369_qc_cell_lock_lte']}

E2E_TL_Cell_Block_Unblock_NR_with_OAM_KPI
    [Timeout]   24h
    [Tags]    E2E_TL_Cell_Block_Unblock_NR_with_OAM_KPI
    run keyword if  '${TECHNOLOGY}'=='ALL' or '${TECHNOLOGY}'=='TRUNK' or '${TECHNOLOGY}'=='25R3' or '${TECHNOLOGY}'=='25R2'
    ...         E2E TL CELL BLOCK UNBLOCK NR WITH OAM KPI    ${NODES}    ${GNB1}    ${CELL_OPERATION_ITERATION}
    ...         customers_list=@{CUSTOMERS_LIST}
    ...         report=${SHOULD_BE_REPORTED}
    ...         qc_domain=${QC_DOMAIN}
    ...         qc_project=${QC_PROJECT}
    ...         qc_id=${qc_ids['369_qc_cell_block_nr']}

E2E_TL_Cell_Block_Unblock_GSM_with_OAM_KPI
    [Timeout]   24h
    [Tags]    E2E_TL_Cell_Block_Unblock_GSM_with_OAM_KPI
    run keyword if  '${TECHNOLOGY}'=='ALL' or '${TECHNOLOGY}'=='TRUNK' or '${TECHNOLOGY}'=='25R3' or '${TECHNOLOGY}'=='25R2'
    ...         E2E TL CELL BLOCK UNBLOCK GSM WITH OAM KPI    ${NODES}    ${GNB1}    ${CELL_OPERATION_ITERATION}
    ...         customers_list=@{CUSTOMERS_LIST}
    ...         report=${SHOULD_BE_REPORTED}
    ...         qc_domain=${QC_DOMAIN}
    ...         qc_project=${QC_PROJECT}
    ...         qc_id=${qc_ids['369_qc_cell_block_gsm']}

E2E_TL_Delta_Commissioning_With_Site_Reset_Required
    [Timeout]   24h
    [Tags]    E2E_TL_Delta_Commissioning_With_Site_Reset_Required
    run keyword if  '${TECHNOLOGY}'=='ALL' or '${TECHNOLOGY}'=='TRUNK' or '${TECHNOLOGY}'=='25R2'
    ...         E2E TL DELTA COMMISSIONING WITH SITE RESET REQUIRED     ${NODES}    ${GNB1}    ${DELTA_COMMISSIONING_ITERATION}
    ...         customers_list=@{CUSTOMERS_LIST}
    ...         report=${SHOULD_BE_REPORTED}
    ...         delta=${SITE_RESET_DELTA}
    ...         qc_domain=${QC_DOMAIN}
    ...         qc_project=${QC_PROJECT}
    ...         qc_id=${qc_ids['369_qc_delta_reset']}

E2E_TL_Delta_Commissioning_With_Online_Parameter_Modification
    [Timeout]   24h
    [Tags]    E2E_TL_Delta_Commissioning_With_Online_Parameter_Modification
    run keyword if  '${TECHNOLOGY}'=='ALL' or '${TECHNOLOGY}'=='TRUNK' or '${TECHNOLOGY}'=='25R2'
    ...         E2E TL DELTA COMMISSIONING WITH ONLINE PARAMETER MODIFICATION       ${NODES}    ${GNB1}    ${DELTA_COMMISSIONING_ITERATION}
    ...         customers_list=@{CUSTOMERS_LIST}
    ...         report=${SHOULD_BE_REPORTED}
    ...         delta=${ONLINE_PARAMETER_DELTA}
    ...         qc_domain=${QC_DOMAIN}
    ...         qc_project=${QC_PROJECT}
    ...         qc_id=${qc_ids['369_qc_delta_online']}

E2E_TL_Delta_Commissioning_With_NR_Rat_Reset
    [Timeout]   24h
    [Tags]    E2E_TL_Delta_Commissioning_With_NR_Rat_Reset
    run keyword if  '${TECHNOLOGY}'=='ALL' or '${TECHNOLOGY}'=='TRUNK' or '${TECHNOLOGY}'=='25R2'
    ...         E2E TL DELTA COMMISSIONING WITH ONLINE PARAMETER MODIFICATION       ${NODES}    ${GNB1}    ${DELTA_COMMISSIONING_ITERATION}
    ...         customers_list=@{CUSTOMERS_LIST}
    ...         report=${SHOULD_BE_REPORTED}
    ...         delta=${NR_RAT_RESET_DELTA}
    ...         qc_domain=${QC_DOMAIN}
    ...         qc_project=${QC_PROJECT}
    ...         qc_id=${qc_ids['369_qc_delta_nr']}

E2E_TL_Delta_Commissioning_With_LTE_Rat_Reset
    [Timeout]   24h
    [Tags]    E2E_TL_Delta_Commissioning_With_LTE_Rat_Reset
    run keyword if  '${TECHNOLOGY}'=='ALL' or '${TECHNOLOGY}'=='TRUNK' or '${TECHNOLOGY}'=='25R2'
    ...         E2E TL DELTA COMMISSIONING WITH ONLINE PARAMETER MODIFICATION       ${NODES}    ${GNB1}    ${DELTA_COMMISSIONING_ITERATION}
    ...         customers_list=@{CUSTOMERS_LIST}
    ...         report=${SHOULD_BE_REPORTED}
    ...         delta=${LTE_RAT_RESET_DELTA}
    ...         qc_domain=${QC_DOMAIN}
    ...         qc_project=${QC_PROJECT}
    ...         qc_id=${qc_ids['369_qc_delta_lte']}

E2E_TL_Delta_Commissioning_With_GSM_Rat_Reset
    [Timeout]   24h
    [Tags]    E2E_TL_Delta_Commissioning_With_GSM_Rat_Reset
    run keyword if  '${TECHNOLOGY}'=='ALL' or '${TECHNOLOGY}'=='TRUNK' or '${TECHNOLOGY}'=='25R2'
    ...         E2E TL DELTA COMMISSIONING WITH ONLINE PARAMETER MODIFICATION       ${NODES}    ${GNB1}    ${DELTA_COMMISSIONING_ITERATION}
    ...         customers_list=@{CUSTOMERS_LIST}
    ...         report=${SHOULD_BE_REPORTED}
    ...         delta=${GSM_RAT_RESET_DELTA}
    ...         qc_domain=${QC_DOMAIN}
    ...         qc_project=${QC_PROJECT}
    ...         qc_id=${qc_ids['369_qc_delta_gsm']}


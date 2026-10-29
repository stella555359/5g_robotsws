*** Settings ***
Documentation   Suite for E2E CRT regression
...             Author: Daniel Grzesik
...             daniel.grzesik@nokia.com
...             Maintainter: Daniel Grzesik
...
...             To start TestCase use flag '-i' and 'ONLY_5G' or 'ONLY_LTE'
...             To add L3 to TestCase add 'attach_test_keyword=attach_test'
...             !! to start use flag '-v TECHNOLOGY:{ALL,ONLY_4G,ONLY_5G}' :: example below
...             EXAMPLE :::   robot --timestampoutputs -V /home/ute/testline_configuration/10_16_UTESRAN367/__init__.py -v TECHNOLOGY:ALL
...             -L TRACE -b debug.log -d results /home/ute/robotws/testsuite/Wroclaw/OAM/VRF_WRO3_T02/regression/CSV_VDF_TL_367.robot

Library         taf.sbts.oam.coam.admin  WITH NAME   coam_admin
Library         taf.sw.scout             WITH NAME   scout
Library         ute_ue
Library         taf/rfrl/csv4all/CSV4AllTestCases.py
Library         SSHLibrary

Resource        ../common_resources/scf/scf_sender.robot
Resource        ../common_resources/scout/scout_operations.robot
Resource        taf/rfrl/scrambling_logs_collector/Keywords.robot
Resource        ../features/CB007442/TestCases/CB007442-Suite.robot
Resource        ../common_resources/alarms/alarm.robot
Variables       ../common_resources/qc_id_csv/qc_id_functions.py

Force Tags      CA_VRF_WRO3    RAN_5G
...             STATE_SW_UPLOADED
...             CLOUD_5G_CLASSICAL_ASIL_ABIL_ABIO_WRO_TRS_367
...             AVG_EXE_TIME=
...             RESPONSIBLE_TESTER=grzesik



*** Variables ***
${RP_CA}   VRF_OAM
${RP_LOCATION}    VRF_WRO3
${RP_ORGANIZATION}    VRF_WRO3_T02
${QC_DOMAIN}=               MN_RAN
${QC_PROJECT}=              RAN_VRF


${UPGRADE_ITERATIONS_5G}=            3
${ACTIVATION_RESET_ITERATION_5G}=    20
${SITE_RESET_ITERATION_5G}=          20
${RMOD_RESET_ITERATION_5G}=          10
${BBMOD_RESET_ITERATION_5G}=         10
${CELL_OPERATION_ITERATION}=         5
@{CUSTOM_ALARMS_ALL_5G}=             7307  62003  1898  7115  61510  7509  61011  61618  6134  6150  7513  7107  7319
...                                  7300
@{CUSTOM_ALARMS_ALL_4G}=             7307  62003  1898  7115  61510  7509  61011  61618  6327  6150  6134  6202  6129  7511  4773
@{TEMPORARY_ALARMS_4G}=              10  1815  1898  4220  4773  6134  6327  62003  6129  6202
@{TEMPORARY_ALARMS_5G}=              10  1815  7107  7300  7319  7509  7519  62003  7511
${CRITICAL_ALARMS}=                  10,16,1806,1868,4341,4352,4383
${SOURCE_SW}=                        SBTS24R2_ENB_0000_000580_000026
${SOURCE_SW_4G}=                     SBTS24R2_ENB_0000_000580_000026
${TARGET_SW}=                        SBTS25R1_ENB_0000_000509_000000
${TARGET_SW_PATH}=                   ${None}
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
${BTS_ID_5G}                         ${tl.gnbs[0].instance_id}


${SITE_RESET_DELTA_5G}=                ${CURDIR}/../features/CSV/Resources/MRBTS-${BTS_ID_5G}/site_reset_parameter.json
${ONLINE_PARAMETER_DELTA_5G}=          ${CURDIR}/../features/CSV/Resources/MRBTS-${BTS_ID_5G}/online_parameter.json
${NR_RAT_RESET_DELTA_5G}=              ${CURDIR}/../features/CSV/Resources/MRBTS-${BTS_ID_5G}/delta_nr_rat_reset.json
${LTE_RAT_RESET_DELTA_5G}=             ${CURDIR}/../features/CSV/Resources/MRBTS-${BTS_ID_5G}/delta_lte_rat_reset.json
${GSM_RAT_RESET_DELTA_5G}=             ${CURDIR}/../features/CSV/Resources/MRBTS-${BTS_ID_5G}/delta_gsm_rat_reset.json


@{NODES}                            ${GNB1}    ${ENB1}
@{TEST_NODES}                       ${GNB1}    ${ENB1}

&{GNB1}     node_alias=5G               testline_object=${tl.gnbs[0]}
...         source_sw=${SOURCE_SW}      target_sw=${TARGET_SW}
...         hw_to_onair_timeout=${HARDWARE_CHECK_TIMEOUT}
...         critical_alarms=${CRITICAL_ALARMS}
...         alarm_timer=${ALARM_TIMEOUT}
...         custom_allowed_alarms=@{CUSTOM_ALARMS_ALL_5G}
...         temporary_allowed_alarms==@{TEMPORARY_ALARMS_4G}
...         syslog_ignored_prints=@{SYSLOG_IGNORED_PRINTS}


&{ENB1}     node_alias=4G               node_vm=10.42.53.31
...         source_sw=${SOURCE_SW_4G}      target_sw=${TARGET_SW}
...         hw_to_onair_timeout=${HARDWARE_CHECK_TIMEOUT}
...         critical_alarms=${CRITICAL_ALARMS}
...         alarm_timer=${ALARM_TIMEOUT}
...         custom_allowed_alarms=@{CUSTOM_ALARMS_ALL_4G}
...         temporary_allowed_alarms=@{TEMPORARY_ALARMS_5G}
...         syslog_ignored_prints=@{SYSLOG_IGNORED_PRINTS}



*** Test Cases ***

E2E_TL_SW_Upgrade_Rollback_with_OAM_KPI
    [Timeout]   72h
    [Tags]    E2E_TL_SW_upgrade_rollback_with_OAM_KPI
    run keyword if  '${TECHNOLOGY}'=='ONLY_5G' or '${TECHNOLOGY}'=='TRUNK' or '${TECHNOLOGY}'=='25R3' or '${TECHNOLOGY}'=='25R2'
    ...         E2E TL SW UPGRADE ROLLBACK WITH OAM KPI    ${NODES}    ${GNB1}    ${UPGRADE_ITERATIONS_5G}
    ...         customers_list=@{CUSTOMERS_LIST}
    ...         report=${SHOULD_BE_REPORTED}
    ...         restore_to_target_sw=${RESTORE_TO_TARGET_SW}
    ...         use_external_storage=${USE_EXTERNAL_STORAGE}
    ...         download_path=${TARGET_SW_PATH}
    ...         qc_domain=${QC_DOMAIN}
    ...         qc_project=${QC_PROJECT}
    ...         qc_id=${qc_ids['367_qc_upgrade']}
    [Teardown]      Run keyword and ignore error     Collect and send logs for scrambling verification
    ...                                              team_name=PZ3WRO2
    ...                                              input_logs_dir=${NONE}

E2E_TL_Activation_Reset_with_OAM_KPI
    [Timeout]   72h
    [Tags]    E2E_TL_Activation_Reset_Test
    run keyword if  '${TECHNOLOGY}'=='ONLY_5G' or '${TECHNOLOGY}'=='TRUNK' or '${TECHNOLOGY}'=='25R3' or '${TECHNOLOGY}'=='25R2'
    ...         E2E TL ACTIVATION RESET TEST  ${NODES}    ${GNB1}    ${ACTIVATION_RESET_ITERATION_5G}
    ...         customers_list=@{CUSTOMERS_LIST}
    ...         report=${SHOULD_BE_REPORTED}
    ...         qc_domain=${QC_DOMAIN}
    ...         qc_project=${QC_PROJECT}
    ...         qc_id=${qc_ids['367_qc_activation_reset']}
    ...         use_external_storage=${USE_EXTERNAL_STORAGE}

E2E_TL_Site_Reset_with_OAM_KPI
    [Timeout]   72h
    [Tags]    E2E_TL_Site_Reset_with_OAM_KPI
    run keyword if  '${TECHNOLOGY}'=='ONLY_5G' or '${TECHNOLOGY}'=='TRUNK' or '${TECHNOLOGY}'=='25R3' or '${TECHNOLOGY}'=='25R2'
    ...         E2E TL SITE RESET WITH OAM KPI  ${NODES}    ${GNB1}    ${SITE_RESET_ITERATION_5G}
    ...         customers_list=@{CUSTOMERS_LIST}
    ...         report=${SHOULD_BE_REPORTED}
    ...         qc_domain=${QC_DOMAIN}
    ...         qc_project=${QC_PROJECT}
    ...         qc_id=${qc_ids['367_qc_site_reset']}

E2E_TL_Capacity_Module_Reset_with_OAM_KPI
    [Timeout]   72h
    [Tags]    E2E_TL_Capacity_Module_Reset_with_OAM_KPI
    run keyword if  '${TECHNOLOGY}'=='ONLY_5G' or '${TECHNOLOGY}'=='TRUNK' or '${TECHNOLOGY}'=='25R3' or '${TECHNOLOGY}'=='25R2'
    ...         E2E TL CAPACITY MODULE RESET WITH OAM KPI  ${NODES}    ${GNB1}    ${BBMOD_RESET_ITERATION_5G}
    ...         customers_list=@{CUSTOMERS_LIST}
    ...         report=${SHOULD_BE_REPORTED}
    ...         qc_domain=${QC_DOMAIN}
    ...         qc_project=${QC_PROJECT}
    ...         qc_id=${qc_ids['367_qc_bbmod_reset']}

E2E_TL_RU_Reset_with_OAM_KPI
    [Timeout]   72h
    [Tags]    E2E_TL_RU_Reset_with_OAM_KPI
    run keyword if  '${TECHNOLOGY}'=='ONLY_5G' or '${TECHNOLOGY}'=='TRUNK'
    ...         E2E TL RU RESET WITH OAM KPI    ${NODES}    ${GNB1}    ${RMOD_RESET_ITERATION_5G}
    ...         customers_list=@{CUSTOMERS_LIST}
    ...         report=${SHOULD_BE_REPORTED}
    ...         qc_domain=${QC_DOMAIN}
    ...         qc_project=${QC_PROJECT}
    ...         qc_id=${qc_ids['367_qc_ru_reset']}

E2E_TL_Cell_Lock_Unlock_NR_with_OAM_KPI
    [Timeout]   24h
    [Tags]    E2E_TL_Cell_Lock_Unlock_NR_with_OAM_KPI
    run keyword if  '${TECHNOLOGY}'=='ONLY_5G' or '${TECHNOLOGY}'=='TRUNK'
    ...         E2E TL CELL LOCK UNLOCK NR WITH OAM KPI     ${NODES}    ${GNB1}    ${CELL_OPERATION_ITERATION}
    ...         customers_list=@{CUSTOMERS_LIST}
    ...         report=${SHOULD_BE_REPORTED}
    ...         qc_domain=${QC_DOMAIN}
    ...         qc_project=${QC_PROJECT}
    ...         qc_id=${qc_ids['367_qc_cell_lock_nr']}

[1]Site_Reset_During_Baseband_Card_Reset_ASIL
    [Timeout]   24h
    [Tags]    [1]Site_Reset_During_Baseband_Card_Reset_ASIB
	Add Alarm To Allowed Alarms     62003   Transport layer connection lost in XP interface
	Add Alarm To Allowed Alarms     7509    EN DSS Setup Failure - Max EN DSS Counter Value reached - No answer from CRM
	run keyword if  '${TECHNOLOGY}'=='ONLY_5G' or '${TECHNOLOGY}'=='TRUNK'
    ...         Site_Reset_During_Baseband_Card_Reset

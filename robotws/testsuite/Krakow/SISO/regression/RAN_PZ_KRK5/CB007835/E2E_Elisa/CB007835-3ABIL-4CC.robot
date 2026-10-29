*** Settings ***
Documentation
...   Test suite for regression testing of feature CB007835
...   author: Piotr Bacior, Adam Klekowski
...   contact: piotr.bacior@nokia.com, adam.klekowski@nokia.com

Library      taf.rfrl.bts.devices.du.logs_collecting.btslog_collector.GenericBtslogCollector    WITH NAME    btslog_collector
Library      taf.rfrl.bts.devices.generic_bts.GenericBts                                        WITH NAME    generic_bts
Library      taf.rfrl.bts.devices.du.cell_operations.GenericCellOperations                      WITH NAME    cell_operations
Library      taf.rfrl.bts.devices.du.pm_counters.GnbPmCounter    WITH NAME    gnb_pm_counter
Library      taf.rfrl.utilities.logger.custom_logger  WITH NAME  logger
Library      ute_ue
Library      ./resources/resources.py
Resource     ./resources/keywords.robot
Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource     taf/rfrl/procedures/SISO/General_SiSo_Auto_RF_lock_unlock.robot
Resource     taf/rfrl/procedures/SISO/General_SiSo_Auto_RF_module_reset_from_WebUI.robot
Resource     taf/rfrl/procedures/SISO/General_SiSo_Auto_gNB_Site_Reset_From_WebUI.robot
Resource     taf/rfrl/ue/robot/REAL_UE.robot
Resource     taf/rfrl/uuf4all/uuf4all_test_cases.robot
Resource     taf/rfrl/uuf4all/uuf4all_keywords.robot
Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Variables    ./resources/delta.py
Variables    ./resources/variables.py


Force Tags    STATE_SW_UPLOADED   CLOUD_5G_CLASSICAL_QC_ASIML_ABIOB1B2B3_AWGUC    CDRT    CRT
...     CA_VRF_KRK


Suite Setup       Common Suite Setup With OnAir Test Line Preparation
...               swconfig_from_path=commissionings/Krakow/swconfig/default_swconfig.txt
...               should_LTE_neighbour_be_changed=${False}
...               increase_timeout_for_update_sw=3600
Suite Teardown    Common Suite Teardown

Test Setup        Common Preconditions
Test Teardown     Common Postconditions With Restore Configuration If Test Failed

*** Variables ***
################## Call Processing ####################
${dist_name_template}       MRBTS-{0}/NRBTS-{1}/NRDRB-
${interval}                 15min
${throughput_duration}      10min
${throughput_duration_endc}      17min
${divisor}                  ${900000}

############### OAM and UUF #########################
${runs_time_duration}    ${10}
@{CUSTOMERS_LIST}=      Elisa
@{CRITICAL_FAULTS}=     0010  0016  1806  1868  4341  4352  4383
@{CUSTOM_ALLOWED_ALARMS}    No X2 link available  No X2 link available for a specific LTEENB

${5G_SOURCE_SW}=        ${None}
${5G_TARGET_SW}=        ${None}
${UPDATE_TEST_ITERATION}            5
${SITE_RESET_TEST_ITERATION}        30
*** Test Cases ***
E2E_TL_SW_upgrade_rollback_with_OAM_KPI
    [Timeout]    96h
    Remove Dirs       directory_path=/home/ute/.ute-ca/cache/bts/
    ${5G_SOURCE_SW}=    run keyword if  '${5G_SOURCE_SW}'=='${None}'  Get Source SW
    ...   ELSE  set variable  ${5G_SOURCE_SW}
    ${5G_TARGET_SW}=    run keyword if  '${5G_TARGET_SW}'=='${None}'  Get Target SW
    ...   ELSE  set variable  ${5G_TARGET_SW}
#    Prepare Ue  REAL_UE    REAL_UES
    UUF4ALL_SW_UPGRADE_TEST
    ...          should_be_reported=True
    ...          test_iteration=${UPDATE_TEST_ITERATION}
    ...          customers_list=@{CUSTOMERS_LIST}
    ...          critical_faults=@{CRITICAL_FAULTS}
    ...          5g_source_sw=${5G_SOURCE_SW}
    ...          5g_target_sw=${5G_TARGET_SW}
    ...          restore_to_target_sw=${True}
    ...          use_builds_storage=${False}
    ...          qc_domain=${kpi_qc_ids['qc_domain']}
    ...          qc_id=${kpi_qc_ids['qc_upgrade']}
    ...          qc_project=${kpi_qc_ids['qc_project']}
#    ...          local_node_attach_test_keyword=Simple L3 Call Test
    [Teardown]   Common Test Teardown

[1.0] E2E_TL_Delta_Commissioning_With_NR_Rat_Reset
    [Timeout]   24h
    DELTA_COMMISSIONING_WITH_NR_RAT_RESET
    ...          test_iteration=1
    ...          delta_file=${DELTA_5G}
    ...          customers_list=@{CUSTOMERS_LIST}
    ...          should_be_reported=True
    ...          critical_faults=@{CRITICAL_FAULTS}
    ...          qc_domain=${kpi_qc_ids['qc_domain']}
    ...          qc_id=${kpi_qc_ids['qc_comm_rat_reset']}
    ...          qc_project=${kpi_qc_ids['qc_project']}

[1.0] E2E_TL_Site_reset_without_HWF_with_OAM_KPI
    [Timeout]    96h
#    Prepare Ue  REAL_UE    REAL_UE
    UUF4ALL_SITE_RESET_TEST
    ...          test_iteration=${SITE_RESET_TEST_ITERATION}
    ...          customers_list=@{CUSTOMERS_LIST}
    ...          critical_faults=@{CRITICAL_FAULTS}
    ...          qc_domain=${kpi_qc_ids['qc_domain']}
    ...          qc_id=${kpi_qc_ids['qc_site_reset']}
    ...          qc_project=${kpi_qc_ids['qc_project']}
#    ...          attach_test_keyword=Simple L3 Call Test
    [Teardown]   Common Test Teardown

[1.0] E2E_TL_Capacity_Module_Reset_with_OAM_KPI
#    Prepare Ue  UE_1    UE_1
    OAM_BBMOD_RESET
    ...          test_iteration=10
    ...          customers_list=@{CUSTOMERS_LIST}
    ...          should_be_reported=True
    ...          critical_faults=@{CRITICAL_FAULTS}
    ...          qc_domain=${kpi_qc_ids['qc_domain']}
    ...          qc_id=${kpi_qc_ids['qc_capacity_reset']}
    ...          qc_project=${kpi_qc_ids['qc_project']}
#    ...          attach_test_keyword=Simple L3 Call Test
    [Teardown]   Common Test Teardown

[1.0] E2E_TL_RU_Reset_with_OAM_KPI
#    Prepare Ue  UE_1    UE_1
    OAM_RMOD_RESET
    ...          test_iteration=20
    ...          customers_list=@{CUSTOMERS_LIST}
    ...          should_be_reported=True
    ...          critical_faults=@{CRITICAL_FAULTS}
    ...          qc_domain=${kpi_qc_ids['qc_domain']}
    ...          qc_id=${kpi_qc_ids['qc_ru_reset']}
    ...          qc_project=${kpi_qc_ids['qc_project']}
#    ...          attach_test_keyword=Simple L3 Call Test
    [Teardown]   Common Test Teardown

[1.0] E2E_TL_Cell_Block_Unblock_NR_with_OAM_KPI
#    Prepare Ue  UE_1    UE_1
    OAM_NRCEL_BLOCK
    ...          customers_list=@{CUSTOMERS_LIST}
    ...          should_be_reported=True
    ...          critical_faults=@{CRITICAL_FAULTS}
    ...          qc_domain=${kpi_qc_ids['qc_domain']}
    ...          qc_id=${kpi_qc_ids['qc_cell_block_unblock']}
    ...          qc_project=${kpi_qc_ids['qc_project']}
#    ...          attach_test_keyword=Simple L3 Call Test
    [Teardown]   Common Test Teardown

[1.0] E2E_TL_Cell_Lock_Unlock_NR_with_OAM_KPI
#    Prepare Ue  UE_1    UE_1
    OAM_NRCEL_LOCK
    ...          customers_list=@{CUSTOMERS_LIST}
    ...          should_be_reported=True
    ...          critical_faults=@{CRITICAL_FAULTS}
    ...          qc_domain=${kpi_qc_ids['qc_domain']}
    ...          qc_id=${kpi_qc_ids['qc_cell_lock_unlock']}
    ...          qc_project=${kpi_qc_ids['qc_project']}
    [Teardown]   Common Test Teardown

[1.0] CB007834-5G-11_Commisioning_with_site_reset
    DELTA_COMMISSIONING_WITH_SITE_RESET_REQUIRED
    ...          test_iteration=1
    ...          customers_list=@{CUSTOMERS_LIST}
    ...          should_be_reported=True
    ...          critical_faults=@{CRITICAL_FAULTS}
    ...          qc_domain=${kpi_qc_ids['qc_domain']}
    ...          qc_id=${kpi_qc_ids['qc_comm_reset']}
    ...          qc_project=${kpi_qc_ids['qc_project']}
    [Teardown]   Common Test Teardown

[1.0] CB007834-5G-12_Commisioning_online_change
    DELTA_COMMISSIONING_WITH_ONLINE_PARAMETER_MODIFICATION
    ...          test_iteration=1
    ...          customers_list=@{CUSTOMERS_LIST}
    ...          should_be_reported=True
    ...          critical_faults=@{CRITICAL_FAULTS}
    ...          qc_domain=${kpi_qc_ids['qc_domain']}
    ...          qc_id=${kpi_qc_ids['qc_comm_online_change']}
    ...          qc_project=${kpi_qc_ids['qc_project']}
    [Teardown]   Common Test Teardown


*** Keywords ***
Run Keyword Multiple Times
    [Arguments]    ${runs}    ${keyword_name}
    FOR    ${i}    IN RANGE    1    ${runs}+1
        Log    \nRun: ${i}    console=${True}
        Run Keyword    ${keyword_name}
    END

Prepare Ue
    [Arguments]    ${ue_alias}    ${capability}
    ute_ue.Require Ue    ue_alias=${ue_alias}    capabilities=${capability}
    ute_ue.Detach Ue    ${ue_alias}
    BuiltIn.Sleep    1s
    ute_ue.Attach Ue    ${ue_alias}
    Sleep    3s
    ute_ue.Log Ue Info    ${ue_alias}    ALL

Start Data Traffic on Real UE
    [Arguments]     ${ue_alias}     ${direction}    ${tput_duration}    ${tput_val}     ${dt_name}
    Start Data Transfer on Real UE      ue_alias=${ue_alias}    direction=${direction}      protocol=udp
    ...     duration=${tput_duration}   tput=${tput_val}    size_packet=1400B
    ...     buffer_client=4M        buffer_server=4M        parallel_streams=1
    ...     dt_name=${dt_name}
    logger.log_info_to_console      Performing Data Transfer
    Wait for truput stabilization

Simple L3 Call Test
    [Arguments]     ${cell_used_in_test}    ${remote}
    Start Data Traffic on Real UE   ue_alias=REAL_UE   direction=dl    tput_duration=15s   tput_val=40000 Kbits/sec    dt_name=DT_DL_UE_1

Allow X2 alarms
    Allow Alarm    No X2 link available
    Allow Alarm    No X2 link available for a specific LTEENB

Disallow X2 alarms
    Disallow Alarm    No X2 link available
    Disallow Alarm    No X2 link available for a specific LTEENB

Remove Dirs
    [Arguments]    @{directory_path}
    FOR    ${dir}    IN    @{directory_path}
        ${status}=    Run Keyword And Return Status    Directory Should Exist    ${dir}
        Run Keyword If    ${status}    Remove Directory    ${dir}    force=True
    END

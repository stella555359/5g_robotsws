*** Settings ***
Documentation
...    Author:Yang Liqin
...    contact:liqin.yang@nokia-sbell.com
...    squad group:SG_05
...    Feature CB008680

Library    taf.selenium.sbts     WITH NAME     selenium_coam
Library    taf.sbts.oam.coam.admin    WITH NAME    coam
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/common/selenium.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_Link_Diagnostic_and_Monitoring.robot
Resource    ${BASIC_PATH_COMMON}/General_SiSo_ALD_Configuration_Management_RAE_uploading_beamforming_weight_factor_file.robot
Resource    ${BASIC_PATH_5G}/OAM_KPI_61a_SiSo_Auto_BTS_site_reset.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_Commissioning_BTS_Template_Commissioning.robot
Resource      ${BASIC_PATH_5G}/5GC000399/5GC000399_eCPRI_Basic_configuration_over_RP1.robot
Resource      ${BASIC_PATH_5G}/5GC000561/5GC000561_eCPRI_sync_generic_startup_at_RAU.robot
Resource      ${BASIC_PATH_5G}/Manual_SiSo_STARTUP_Start-up_and_Detection_of_RF_Module.robot
Resource       ${BASIC_PATH_5G}/General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot.robot
Resource      ${BASIC_PATH_5G}/5GC000399/5GC000399_eCPRI_FREERUN_state_handling.robot
Resource             ${BASIC_PATH_5G}/Cell/General_SiSo_Cell_block_and_unblock.robot
Resource             ${BASIC_PATH_5G}/Cell/General_SiSo_Cell_lock_and_unlock.robot
Resource          ${BASIC_PATH_5G}/Manual_SiSo_SM_BTS_Site_Reset.robot
Resource    ${BASIC_PATH_5G}/Manual_SiSo_SM_RF_Module_lock_unlock.robot
Resource    ${BASIC_PATH_5G}/5GC000561/5GC000561_eCPRI_sync_counters.robot
Resource     ${BASIC_PATH_5G}/General_Stability_Test_Case.robot
Resource       ${BASIC_PATH_5G}/General_SiSo_NR-ARFCN_check.robot
Resource       ${BASIC_PATH_5G}/Manual_SiSo_REC_Radio_Module_power_reset.robot
Resource    ${BASIC_PATH_5G}/BTS/General_SiSo_Peak_with_Given_Information.robot
Resource   ${BASIC_PATH_5G}/General_SiSo_Configuration_BPF_and_TargetBD_support_for_RF_module.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/lib/step_keywords.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource   testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB008712/Resource/CB008712_Resource.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/class_monitor.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/robot/bip.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/bts_selenium.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/robot/scf.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/ERR_WRN_Check.robot
Variables   ${CURDIR}/8680_variable.py
Resource    ${CURDIR}/keywords_8680.robot
#Resource    ${CURDIR}/8680_k.robot

Resource  testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/robot/android_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/soap.robot
Library  testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/parse_soap.py
Resource    ${BASIC_PATH_5G}/General_SiSo_RF_Module_Stability_test.robot
# Resource  testsuite/Hangzhou/SISO/RAN_PZ_HAZ_1/resources/bts_common_interface.robot
Resource  testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB007511_AQQL/resource/CB007511_Common_KW.robot
Library         taf.ul.oam_kpi_calculations  WITH NAME  oam_kpi
Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/coam_parameter.py  WITH NAME  coam_parameter
Suite Setup    Run Keywords    CI_interface.Common Suite Setup
...    AND     robot_common_operations.Common Suite Setup
...    AND     Suite Case Setup
...    AND     Generate suite log path

Suite Teardown   Run Keywords    robot_common_operations.Common Suite Teardown  AND  Suite Case Teardown
Test Setup       Run Keywords    robot_common_operations.Common Case Setup  AND  Test Case Setup siso
Test Teardown    Run Keywords    Test Case Teardown  AND  robot_common_operations.Common Case Teardown
...    AND     CI interface.Common Case Teardown

*** Variables ***

${TS_CASE_LOG_PATH}      /home/ute/test_results
${gnb_index}   0
${MAX_LOOP}       3
${mrbtsID}        ${tl.gnbs[0].instance_id}
${nrbtsID}        ${tl.gnbs[0].global_bts_id}
${SCF_PATH}       ${CURDIR}/SCF
@{timezone_list}      (GMT+8) Asia/Shanghai    (GMT+0) Europe/London
${SAVE LOG DIRECTORY}    /home/ute/test_results
${if_pdl_check}       True
${gNb_CuType}         SA
${ue_index}     0
#${ue_type}       huawei
${asik_addr}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${asik_username}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${asik_password}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${du_index}                    0

@{ALLOWED_ALARMS}=
...                                4592
...                                61524
...                                61649
...								   61652
...                                4334
...                                4655
...                                4654
...                                4681
...                                1907
...                                4707
...                                6450



${ENB_PATH}  MRBTS-${tl.enbs[0].instance_id}/LNBTS-${tl.enbs[0].global_bts_id}
${lnrel_dist}  ${ENB_PATH}/LNCEL-1
${lnrel_para1}    administrativeState
${sub_dir}  UnitOAM_SOAP_Startup_LBTS_*
${ald_url}  https://artifactory-hz1.int.net.nokia.com/artifactory/mn5gran_hzlog-local/tools/Pz3SG05/2005.bin

${BBmod_reset_loop}                 10

*** Test Cases ***
#[1.0] Manual_Siso_PM_5G_uDTX
#    # [Tags]      test
#    Test Case Setup    Manual_Siso_PM_5G_uDTX
#    log to console  Manual_Siso_PM_5G_uDTX
#    Manual_Siso_PM_5G_uDTX

General_SiSo_Power_Meter_counter_update_for_energy_consumption
    [Tags]      testOK1913    test1914
    Test Case Setup    General_SiSo_Power_Meter_counter_update_for_energy_consumption
    #[Teardown]  Test Case Teardown
    log to console  General_SiSo_Power_Meter_counter_update_for_energy_consumption
    General_SiSo_Power_Meter_counter_update_for_energy_consumption

[2.0] Manual_SiSo_SM_NR_RAT_reset
    # [Tags]  test
    Run Keyword And Ignore error   Start BTSlogs Collection In Log Server
    ...      Test_PC_IP=${Test_PC_IP}    Test_PC_username=${Test_PC_username}
    ...      Test_PC_password=${Test_PC_password}
    ...      btslog_path=/tmp/btslog2      btslog_launcher=/opt/btslog/btslog_launcher
    ...      btslog_launcher_path=/opt/btslog/btslog
	Connect to gnb coam via ssl
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    coam.rat_reset       rat_type=NR     timeout=300    connection=GNB_OAM
    Sleep    120s
    Wait until keyword succeeds    20min    30s    verify all cells should be onair
    COAM Teardown gnb connections
    Power UE L3 Call
	Run Keyword And Ignore error       Stop BTSlogs Collection And Download Logs To Log Server
	Run Keyword And Ignore error       Check ERR Or WRN From Syslog
    ...      sys_logs_path=${UTE_syslogs_path}      Expected_ERR_WRN_number=10000   Expected_ERR_WRN_diff_number=0
    ...      Expected_ERR_WRN_deviation=0.3    Delete_old_ERR_WRN=3
    ...      base_file=${Base_ERR_WRN_csv_path}       UTE_logs_path=${UTE_logs_path}
    ...      check_diff=${True}
	...      Clear_log=True     Max_used_space_ratio=0.7

#CB008655-A_2_Increased_power_saving_when_microDTXAdvanced_enabled
#    [Tags]   testOK1913      test1914OK
#    CB008655-A_2_Increased_power_saving_when_microDTXAdvanced_enabled



General_SiSo_TEMP_RU_Temperature_counters_activation
    [Tags]      test1911
    General_SiSo_SBTS_RM_TEMP counter - activation


#[1.0] Manual_SiSo_SM_KPI5_capacity_module_reset_downtime
#    [Tags]     NA
#    Manual_SiSo_SM_KPI5_capacity_module_reset_downtime
#
#CB007273-D_12_Scorpio_FrTxOutOfOrder_F1907
#    [Tags]      NA
#    CB007273-D_12_Scorpio_FrTxOutOfOrder_F1907
#
#Manual_SiSo_SM_Climate profile configuration
#    [Tags]     NA
#    8680_k.Manual_SiSo_SM_Climate_profile_configuration
#
#[1][1.0] Manual_SiSo_SM_KPI_54_Power-on_RU_startup_availability
#    [Tags]      NA
#    Manual_SiSo_SM_KPI_54_Power-on_RU_startup_availability
#
#[1][1.0] Manual_SiSo_SM_KPI_51a_b_RU_reset_downtime
#    [Tags]       NA
#    Manual_SiSo_SM_KPI_51a_b_RU_reset_downtime
#
#[1][1.0] Manual_SiSo_SM_KPI_17a_b _Block_unblock_cell_duration
#    [Tags]      NA
#    Manual_SiSo_SM_KPI_17a_b _Block_unblock_cell_duration

#General_SiSo_RF_Power_scaling_CSI-RS_for_Tracking
#    [Tags]     NA
#    [Setup]     Common 8680_J Setup
#    scf commission and wait for on-air
#    General_SiSo_RF_Power_scaling_CSI-RS_for_Tracking


#General_SiSo_EIRP_measurement_of_broadcasted_signals
#    [Tags]     testOK1913   test1914
#    General_SiSo_EIRP_measurement_of_broadcasted_signals
#    [Teardown]    CI_interface.Common Suite Setup


#5GC000399_eCPRI_Basic_configuration_over_RP1
#    [Tags]     testOK1913  NA
#    OperatingSystem.Run    rm -rf ${TS_CASE_LOG_PATH}/UnitOAM_SOAP_Log0.xml
#    Connect to gnb coam via ssl
#    5GC000399_eCPRI_Basic_configuration_over_RP1
#    COAM Teardown gnb connections
#    OperatingSystem.Run    rm -rf ${TS_CASE_LOG_PATH}/UnitOAM_SOAP_Log0.xml

# [2.0] 5GC000399_eCPRI_Carrier_activation
#     [Tags]    test1
#     #scf commission and wait for on-air
#     CI_interface.Common Suite Setup
#     Connect to gnb coam via ssl
#     5GC000399_eCPRI_Carier_activation
#     COAM Teardown gnb connections

#General_SiSo_RU_capabilities_advertisement_towards_OAM
#    [Tags]    testOK1913   NA
#    Perform BTS Site Reset
#    sleep  60s
#    Connect to gnb coam via ssl
#    Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair
#
#    csn.connect_to       hostname=${asik_addr}    username=${asik_username}
#    ...       password=${asik_password}    alias=gNB
#
#    ${result}  csn.execute  command=xz -d /ffs/run/logs/fct-4a_aasyslog/startup_BTSOM.log.xz    connection=gNB
#    ${startup_btsoam}   set variable if  ${result.count("No such file or directory")}>0    /tmp/startup_BTSOM.log
#    ...    /ffs/run/logs/fct-4a_aasyslog/startup_BTSOM.log
#    ${result}  csn.execute  command=cat ${startup_btsoam}|grep "ruSupportsExtType6:"   connection=gNB
#    Should Not Be Empty   ${result}
#    ${result}  csn.execute  command=cat ${startup_btsoam}|grep "ruSupportsExtType6: boolean = true"   connection=gNB
#    Should Not Be Empty   ${result}
#
#    csn.disconnect      connection=gNB
#    COAM Teardown gnb connections

# [2.0] General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
#     [Tags]    testOK1913   test1914
#     Connect to gnb coam via ssl
#     8680_General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
#     COAM Teardown gnb connections

[2.1] General_SiSo_Link_Diagnostic_and_Monitoring
    [Tags]    test
    COAM Create log directory
	Run Keyword And Ignore error   Start BTSlogs Collection In Log Server
    ...      Test_PC_IP=${Test_PC_IP}    Test_PC_username=${Test_PC_username}
    ...      Test_PC_password=${Test_PC_password}
    ...      btslog_path=/tmp/btslog2      btslog_launcher=/opt/btslog/btslog_launcher
    ...      btslog_launcher_path=/opt/btslog/btslog
    Connect to gnb coam via ssl
    Wait until cell is on air status    timeout=1 min
    General_SiSo_Link_Diagnostic_and_Monitoring
    COAM Teardown gnb connections
	Run Keyword And Ignore error       Stop BTSlogs Collection And Download Logs To Log Server
	Run Keyword And Ignore error       Check ERR Or WRN From Syslog
    ...      sys_logs_path=${UTE_syslogs_path}      Expected_ERR_WRN_number=10000   Expected_ERR_WRN_diff_number=0
    ...      Expected_ERR_WRN_deviation=0.3    Delete_old_ERR_WRN=3
    ...      base_file=${Base_ERR_WRN_csv_path}       UTE_logs_path=${UTE_logs_path}
    ...      check_diff=${True}
	...      Clear_log=True     Max_used_space_ratio=0.7


#[1.0] General_SiSo_Configuration_BPF_and_TargetBD_support_for_RF_module
#    [Tags]    testOK1913  NA
#    Connect to gnb coam via ssl
#    General_SiSo_Configuration_BPF_and_TargetBD_support_for_RF_module
#    COAM Teardown gnb connections


# General_SiSo_ALD_Configuration_Management_RAE_uploading_beamforming_weight_factor_file
#     [Tags]       testOK1913   test1914
#     General_SiSo_ALD_Configuration_Management_RAE_uploading_beamforming_weight_factor_file    RAE_upload_path_list=${RAE_path_list}

#[4.0] 5GC000561_eCPRI_sync_generic_startup_at_RAU
#    [Tags]    testOK1913  NA
#    5GC000561_eCPRI_sync_generic_startup_at_RAU


# 5GC000399_eCPRI_FREERUN_state_handling
#     [Tags]    testOK1913   test1914
#     5GC000399_eCPRI_FREERUN_state_handling

# [3.0] General_SiSo_Online_Cell_Addition_Deletion
#     # [Tags]    test
#     General_SiSo_Online_Cell_addition_deletion    addition_deletion_cell=1

#CB008680_General_SiSo_NR-ARFCN_check
#    [Tags]     NA
#    CI_interface.Common Suite Setup
#    Connect to gnb coam via ssl
#    General_SiSo_NR-ARFCN_check
#    COAM Teardown gnb connections


#[2.0] General_SiSo_Commissioning_BTS_Template_Commissioning
#    [Tags]    NA
#    General_SiSo_Commissioning_BTS_Template_Commissioning

Manual_SiSo_SM_BTS_Site_Reset
    [Tags]   testOK1913   test1914
    CI_interface.Common Suite Setup
    Connect to gnb coam via ssl
    Manual_SiSo_SM_BTS_Site_Reset
    COAM Teardown gnb connections

#[1.0] General_SiSo_stability_with_L3Call
#    [Tags]      NA
#    Power UE L3 Call     call_time=1800    log_time=25m    actCarrierAggregation=True

[2.0] Manual_SiSo_SM_RF_Module_lock_unlock
    [Tags]     testOK1913   test1914
    Connect to gnb coam via ssl
    8680_Manual_SiSo_SM_RF_Module_lock_unlock
    COAM Teardown gnb connections

#OAM_KPI_651_SiSo_Auto_RF_reset_success_rate_from_WebUI_with_L3Call
#    [Tags]     testOK1913   test1914
#    Connect to gnb coam via ssl
#    General_SiSo_RF_module_reset_from_GUI_with_L3call
#    COAM Teardown gnb connections

#[1.0] Manual_SiSo_STARTUP_BTS_Power_Reset
#    [Tags]     NA
#    FOR	 ${i}	IN RANGE	3
#        Perform Site Power Off
#        sleep    180s
#        Perform Site Power On
#        sleep    180s
#        Connect to gnb coam via ssl
#        Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair
#        csn.reset_cache
#        Run Keyword And Ignore Error    Power UE L3 Call      actCarrierAggregation=True
#    END

#[1.0] Manual_SiSo_REC_Radio_Module_power_reset
#    [Tags]     NA
#    Connect to gnb coam via ssl
#    Manual_SiSo_REC_Radio_Module_power_reset
#    COAM Teardown gnb connections


[2.0] General_SiSo_RU_module_reset_from_GUI
    # [Tags]     test
	Run Keyword And Ignore error   Start BTSlogs Collection In Log Server
    ...      Test_PC_IP=${Test_PC_IP}    Test_PC_username=${Test_PC_username}
    ...      Test_PC_password=${Test_PC_password}
    ...      btslog_path=/tmp/btslog2      btslog_launcher=/opt/btslog/btslog_launcher
    ...      btslog_launcher_path=/opt/btslog/btslog
    Connect to gnb coam via ssl
    General_SiSo_RF_module_reset_from_GUI_with_L3call
    COAM Teardown gnb connections
	Run Keyword And Ignore error       Stop BTSlogs Collection And Download Logs To Log Server
	Run Keyword And Ignore error       Check ERR Or WRN From Syslog
    ...      sys_logs_path=${UTE_syslogs_path}      Expected_ERR_WRN_number=10000   Expected_ERR_WRN_diff_number=0
    ...      Expected_ERR_WRN_deviation=0.3    Delete_old_ERR_WRN=3
    ...      base_file=${Base_ERR_WRN_csv_path}       UTE_logs_path=${UTE_logs_path}
    ...      check_diff=${True}
	...      Clear_log=True     Max_used_space_ratio=0.7

#[1.0] OAM_KPI_61a_SiSo_Auto_BTS_site_reset
#    [Tags]     testOK1913    test1914
#    Selenium Login And Disable Screen Lock
#    OAM_KPI_61a_SiSo_Auto_BTS_site_reset
#    Selenium Logout And Close Browser

#[2.1] General_SiSo_Cell_block_and_unblock
#    [Tags]   NA
#    CI_interface.Common Suite Setup
#    Connect to gnb coam via ssl
#    General_SiSo_Cell_block_and_unblock
#    COAM Teardown gnb connections

[1.0] General_SiSo_Auto_Cell_lock_and_unlock_with_L3call
    # [Tags]    test
#   CI_interface.Common Suite Setup
    Run Keyword And Ignore error   Start BTSlogs Collection In Log Server
    ...      Test_PC_IP=${Test_PC_IP}    Test_PC_username=${Test_PC_username}
    ...      Test_PC_password=${Test_PC_password}
    ...      btslog_path=/tmp/btslog2      btslog_launcher=/opt/btslog/btslog_launcher
    ...      btslog_launcher_path=/opt/btslog/btslog
	Connect to gnb coam via ssl
    General_SiSo_Cell_lock_and_unlock
    COAM Teardown gnb connections
	Run Keyword And Ignore error       Stop BTSlogs Collection And Download Logs To Log Server
	Run Keyword And Ignore error       Check ERR Or WRN From Syslog
    ...      sys_logs_path=${UTE_syslogs_path}      Expected_ERR_WRN_number=10000   Expected_ERR_WRN_diff_number=0
    ...      Expected_ERR_WRN_deviation=0.3    Delete_old_ERR_WRN=3
    ...      base_file=${Base_ERR_WRN_csv_path}       UTE_logs_path=${UTE_logs_path}
    ...      check_diff=${True}
	...      Clear_log=True     Max_used_space_ratio=0.7

#CB008562_SR_B_5G_AQQL_01_Antenna_Online_Monitoring_using_WebEM_with_break
#    [Tags]   test1914OK     testOK1913
#    CI_interface.Common Suite Setup
#    CB008562_SR_B_5G_AQQL_01_Antenna_Online_Monitoring_using_WebEM_with_break

#[1]CB008017-5G-B_01_beamforing_L3_Call_on_Activation_of_DL_PRB_Muting_on_Loki-based_BBU
#    [Tags]   test1914OK     testOK1913
#    CB008017-5G-B_01_beamforing_L3_Call_on_Activation_of_DL_PRB_Muting_on_Loki-based_BBU

# [1]General_SiSo_custom_beam_set_realization_to_gNB
#     [Tags]    testOK1913      test1914OK
#     8680_General_SiSo_custom_beam_set_realization_to_gNB
#     [teardown]  run keyword if test failed     Commissioning SCF And Check On Air
#     ...    scf_path=${Case_SCF_Path}

[1.0] 5GC000561_eCPRI_sync_counters
    [Tags]    testOK1913   test1914
    CI_interface.Common Suite Setup
    5GC000561_eCPRI_sync_counters

[2.0] General_SiSo_Cell_switch-off_for_Energy_Efficiency_enhancement
    [Tags]      testOK1913    test1914
    power_ue.UE Detach    ue_type=${ue_type}   ue_index=${ue_index}
    General_SiSo_Cell_switch-off_for_Energy_Efficiency_enhancement

# Manual_SiSo_STARTUP_Start-up_and_Detection_of_RF_Module
#     [Tags]     testOK1913    test1914
#     Manual_SiSo_STARTUP_Start-up_and_Detection_of_RF_Module

[1][3.0] General_SiSo_Fault_1900_EFaultId_FrConfiguringFailed
    [Tags]    testOK1913      test1914
    Test Case Setup    General_SiSo_Fault_1900_EFaultId_FrConfiguringFailed
    log to console  General_SiSo_Fault_1900_EFaultId_FrConfiguringFailed
    CI_interface.Common Suite Setup
    Run Keyword And Ignore error   Start BTSlogs Collection In Log Server
    ...      Test_PC_IP=${Test_PC_IP}    Test_PC_username=${Test_PC_username}
    ...      Test_PC_password=${Test_PC_password}
    ...      btslog_path=/tmp/btslog2      btslog_launcher=/opt/btslog/btslog_launcher
    ...      btslog_launcher_path=/opt/btslog/btslog
	AlarmWatchdog.add_allow_alarms    fault_id=1900
	General_SiSo_Fault_1900_EFaultId_FrConfiguringFailed
	AlarmWatchdog.remove_allow_alarms    fault_id=1900
    Run Keyword And Ignore error       Stop BTSlogs Collection And Download Logs To Log Server
	Run Keyword And Ignore error       Check ERR Or WRN From Syslog
    ...      sys_logs_path=${UTE_syslogs_path}      Expected_ERR_WRN_number=10000   Expected_ERR_WRN_diff_number=0
    ...      Expected_ERR_WRN_deviation=0.1
    ...      base_file=${Base_ERR_WRN_csv_path}       UTE_logs_path=${UTE_logs_path}
    ...      check_diff=${True}

CNI96032_General_SiSo_Auto_RF_Module_Factory_FDSW_Upgrade
    [Documentation]  Author: liqin.yang@nokia-sbell.com
    Test Case Setup    ST_SiSo_RF_Factory_SW_update
    log to console  ST_SiSo_RF_Factory_SW_update
	AlarmWatchdog.add_allow_alarms    fault_id=10
	AlarmWatchdog.add_allow_alarms    fault_id=23
    ST SiSo RF Factory SW update
	AlarmWatchdog.remove_allow_alarms    fault_id=10
	AlarmWatchdog.remove_allow_alarms    fault_id=23
    Run Keywords  Run Keyword And Ignore Error  csn.Disconnect  connection=RU
    ...  AND  Run Keyword And Ignore Error  COAM Teardown gnb connections


[1.0] General_SiSo_Auto_RF_Module_Stability_Run
    [Documentation]  Author: liqin.yang@nokia-sbell.com
    [Tags]  RF
    Test Case Setup    General_SiSo_Auto_RF_Module_Stability_Run
    log to console  General_SiSo_Auto_RF_Module_Stability_Run
    ${rf_port_id}  Get rmod port
	AlarmWatchdog.add_allow_alarms    fault_id=10
    AlarmWatchdog.add_allow_alarms    fault_id=49
    General_SiSo_RF_Module_Stability_test   times=${1}  call_keyword=Power UE L3 Call  temperature=${RF_temperature_high_threshold}
    ...  max_temp=${RF_temperature_high_threshold}  rf_port=${rf_port_id}
	AlarmWatchdog.remove_allow_alarms    fault_id=10
    AlarmWatchdog.remove_allow_alarms    fault_id=49
    # [Teardown]  keywords_8680.Test Case Teardown


[1.0] OAM stability BBMOD Reset
    [Documentation]  Author: liqin.yang@nokia-sbell.com
    [Tags]  BB
    Test Case Setup    OAM_stability_BBMOD_Reset
    log to console  OAM stability BBMOD Reset
    ${BB_reset_list}    Create List    kpi5
	Run Keyword And Ignore error   Start BTSlogs Collection In Log Server
    ...      Test_PC_IP=${Test_PC_IP}    Test_PC_username=${Test_PC_username}
    ...      Test_PC_password=${Test_PC_password}
    ...      btslog_path=/tmp/btslog2      btslog_launcher=/opt/btslog/btslog_launcher
    ...      btslog_launcher_path=/opt/btslog/btslog
    FOR   ${index}   IN RANGE   0    ${BBmod_reset_loop}
        log to console  BBMOD Reset ${index} times
        coam.reset_unit
        ...   dist_name=/MRBTS-${mrbtsID}/EQM-1/APEQM-1/CABINET-1/BBMOD-1
        ...    reset_type=Warm  timeout=200s  connection=GNB_OAM
        Sleep    300    reason=wait on air
        Wait until keyword succeeds    15m    1m    Verify all cells should be onair
        # Connect to gnb coam via ssl
        Calculate KPI    kpi_list=${BB_reset_list}
    END
    UE Attach and Start traffic  cell_id=0  physCellId=${physical_0}
	Run Keyword And Ignore error       Stop BTSlogs Collection And Download Logs To Log Server
	Run Keyword And Ignore error       Check ERR Or WRN From Syslog
    ...      sys_logs_path=${UTE_syslogs_path}      Expected_ERR_WRN_number=10000   Expected_ERR_WRN_diff_number=0
    ...      Expected_ERR_WRN_deviation=0.1
    ...      base_file=${Base_ERR_WRN_csv_path}       UTE_logs_path=${UTE_logs_path}
    ...      check_diff=${True}
    # [Teardown]  keywords_8680.Test Case Teardown

E2E_TL_SW_Upgrade_Rollback_with_OAM_KPI
    [Documentation]  Author: liqin.yang@nokia-sbell.com
    [Tags]  rollback
    Test Case Setup    SW_Upgrade_Rollback_with_OAM_KPI
    log to console  SW_Upgrade_Rollback_with_OAM_KPI
    8680_E2E_TL_SW_upgrade_rollback_with_OAM_KPI

UUF_SW_Activation_Reset
    [Documentation]  Author: liqin.yang@nokia-sbell.com
    [Tags]  site
    Test Case Setup  UUF_SW_Activation_Reset
    log to console  UUF_SW_Activation_Reset
    8680_UUF_SW_Activation_Reset

CNI122115_RU_entering_deep_sleep_mode_several_times
  [Documentation]  Author: liqin.yang@nokia-sbell.com
  [Tags]  DSM
  Test Case Setup  CNI122115_RU_entering_deep_sleep_mode_several_times
  Log To Console  CNI122115_RU_entering_deep_sleep_mode_several_times
  RU_entering_deep_sleep_mode_after_the_last_cell_locked   LOOPS=${3}

*** Keywords ***
5GC000561_eCPRI_sync_counters
    [Documentation]
    ...    *****************
    ...    [TEST PURPOSE] The purpose of this test is to verify collecting PM counter data on eCPRI
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 2022.6.22 - - Created
    ...    *******************
    ...    Owner_jiayi.tang@nokia-sbell.com
    Selenium Logout And Close Browser
    Selenium Login And Disable Screen Lock
    ${origin_value}    Change NCPRI PM Interval   interval=5min
    Connect to Common Unit Master    alias=ASIK Master
    Check Sync Counter   change_interval=5
    Change NCPRI PM Interval    interval=15min
    Check Sync Counter   change_interval=15
    [Teardown]    Selenium Logout And Close Browser

Check Sync Counter
    [Documentation]  Author: jiayi.tang@nokia-sbell.com
    [Arguments]    ${change_interval}=5
    log to console  \n***Check Sync Counter***
    Wait Until Next Counter Update 561    counter_period=${change_interval}
    Selenium Logout And Close Browser
    Selenium Login And Disable Screen Lock
    ${SyncMsg_Latest_value}    selenium_coam.get_transport_counters    counter_id=M40102C0
    ${status}    Run Keyword And Ignore Error    Should Be True    4798 <= ${SyncMsg_Latest_value} <= 4802
    run keyword and ignore error    selenium_coam.refresh_page
    ${AnnMsg_Latest_value}    selenium_coam.get_transport_counters    counter_id=M40102C1
    ${status}    Run Keyword And Ignore Error    Should Be True    2398 <= ${AnnMsg_Latest_value} <= 2402
    run keyword and ignore error    selenium_coam.refresh_page
    ${DelayRespMsg_Latest_value}    selenium_coam.get_transport_counters    counter_id=M40102C2
    run keyword and ignore error    selenium_coam.refresh_page
    ${DelayReqMsg_Latest_value}    selenium_coam.get_transport_counters    counter_id=M40102C3
    #Should Be True    ${DelayRespMsg_Latest_value} == ${DelayReqMsg_Latest_value}
    run keyword and ignore error    selenium_coam.refresh_page
    ${SsmMsg_Latest_value}    selenium_coam.get_transport_counters    counter_id=M40102C4
    ${status}    Run Keyword And Ignore Error    Should Be True    298 <= ${SsmMsg_Latest_value} <= 302

Wait Until Next Counter Update 561
    [Documentation]  Author: jiayi.tang@nokia-sbell.com
    [Arguments]    ${counter_period}=5
#    ${period}    Evaluate    ${counter_period}*60
#    ssh.Connect to    hostname=${tl.gnbs[${gnb_index}].dus[${du_index}].f1_m_ip_addr}
#    ...               username=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
#    ...               password=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
#    ...               alias=${gnb_connection}
#    ${current}     ssh.execute    command=date +%s    connection=${gnb_connection}
#    ${current}    Get Line    ${current}    -1
#    ${sleep}    Evaluate    ${period}+${period}-${current}+int(${current}/${period})*${period}
#    Sleep    ${sleep}
#    sleep    30
     sleep    ${counter_period} minutes

5GC000399_eCPRI_Carier_activation
    [Documentation]
    ...    *****************
    ...    - [TEST PURPOSE] The purpose of this test is to verify carrier configuration and activation using eLLF RU over RP1
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 30.9.2020 - - Created
    ...    *******************
    ...    Owner_lanwen.cai@nokia-sbell.com
    Connect to Common Unit Master
    ${ru_index_list}  Get All RU Index
    FOR  ${ru_index}  IN  ${ru_index_list}[0]
        Connect to RU With Allocated IP    ru_index=${ru_index}  ru_alias=RU_${ru_index}
        ${ru_type}    get ru type    ru_index=${ru_index}
        ${PC_soap_path}    Wait Until Keyword Succeeds  3x  10s  parse_soap.getallsoapfiles  subdir=${sub_dir}
        ...  local_dir=${TS_CASE_LOG_PATH}  connection=RU_${ru_index}
        csn.Disconnect    connection=RU_${ru_index}
        check carier activation by soapmsg parvaluechangeind    PC_soap_path=${PC_soap_path}
    END
    Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair
    [Teardown]  csn.Disconnect  connection=ASIK Master

check carier activation by soapmsg parvaluechangeind
    [Documentation]    Author: lanwen.cai@nokia-sbell.com
    [Arguments]    ${PC_soap_path}=${PC_soap_path}
    ${status}    soapp.check_soapmsg_parvaluechangeind    log_path=${PC_soap_path}    class_value=LowLevelTxEndpoints
    ...     parameterName=subscribe    newValue=TRUE
    should be true    ${status}
    ${status}    soapp.check_soapmsg_parvaluechangeind    log_path=${PC_soap_path}    class_value=LowLevelRxEndpoints
    ...     parameterName=subscribe    newValue=TRUE
    should be true    ${status}
    ${status}    soapp.check_soapmsg_parvaluechangeind    log_path=${PC_soap_path}    class_value=LowLevelTxLinks
    ...     parameterName=subscribe    newValue=TRUE
    should be true    ${status}
    ${status}    soapp.check_soapmsg_parvaluechangeind    log_path=${PC_soap_path}    class_value=LowLevelRxLinks
    ...     parameterName=subscribe    newValue=TRUE
    should be true    ${status}
    ${status}    soapp.check_soapmsg_parvaluechangeind    log_path=${PC_soap_path}    class_value=TxArrayCarrier
    ...     parameterName=subscribe    newValue=TRUE
    should be true    ${status}
    ${status}    soapp.check_soapmsg_parvaluechangeind    log_path=${PC_soap_path}    class_value=RxArrayCarrier
    ...     parameterName=subscribe    newValue=TRUE
    should be true    ${status}


CB008655-A_2_Increased_power_saving_when_microDTXAdvanced_enabled
    #MRBTS-1913/MNL-1/MNLENT-1/FEATCADM-1
    ${dist_name}    set variable    MRBTS-${mrbtsID}/MNL-1/MNLENT-1/FEATCADM-1
    scf.Activate Parameter Value    dist_name=${dist_name}    p_name=actPowerMeter    new_value=true
    sleep   300s

    selenium login and disable screen lock
    Power check
    selenium logout and close browser

Power check
    [Arguments]    ${change_interval}=15min
    ${dist_name}    set variable    MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
    scf.Activate Parameter Value    dist_name=${dist_name}    p_name=actMicroDTX    new_value=true
    ${interval_seconds}    Get Interval Seconds    ${change_interval}

    scf.Activate Parameter Value    dist_name=${dist_name}    p_name=actMicroDTXAdvanced    new_value=false
    sleep   180s
    ${RMOD_Power_counter_noDTX}    ${wait_time}    Get real time power measurements via Webem    object_names=RMOD    interval=5min

    scf.Activate Parameter Value    dist_name=${dist_name}    p_name=actMicroDTXAdvanced    new_value=true
    sleep   180
    ${RMOD_Power_counter_DTX}    ${wait_time}    Get real time power measurements via Webem    object_names=RMOD    interval=5min

    ${expression}=                     Run Keyword If      ${RMOD_Power_counter_DTX} < ${RMOD_Power_counter_noDTX}
    ...                                                    Set Variable    True
    ...                                            ELSE    Set Variable    False
    should be equal as strings    ${expression}       True



General_SiSo_Configuration_BPF_and_TargetBD_support_for_RF_module
    [Documentation]
    ...    ****************
    ...    - [TEST PURPOSE] The Purpose of this case is to check RF module support in SW build.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 01.16.2020 - - Created
    ...    *******************
    ...    Owner_zhihao.shi@nokia-sbell.com
    [Arguments]   ${variable_from_CFAM}=${Variables_CFAM}
    ${ru_index_list}  Get All RU Index
    FOR  ${ru_index}  IN  ${ru_index_list}[0]
        ${radio_type}    get ru type  ru_index=${ru_index}
        verify content of TargetBD file   ru_index=${ru_index}    radio_type=${radio_type}
        verify content of BPF file    variable_from_CFAM=${variable_from_CFAM}    ru_index=${ru_index}
    END

verify content of BPF file
    [Arguments]    ${variable_from_CFAM}=${Variables_CFAM}    ${ru_index}=1
    log to console    \n***verify content of BPF file***
    ${radio_type}    get ru type  ru_index=${ru_index}
    ${Variables_CFAM_temp}    get from dictionary  ${variable_from_CFAM}  ${radio_type}
    ${version}    ${uint_gz}    bpf.get bpf gz fileName  ru_index=${ru_index}
    OperatingSystem.Create Directory     ${SAVE LOG DIRECTORY}/bpf/
    connect to common unit master
    ${file}    csn.execute    ls /tmp/bpf | grep ${version} | grep ${uint_gz}   connection=ASIK Master
    @{file_list}=     Split To Lines    ${file}
    FOR    ${f}    IN    @{file_list}
        ${bpf_content}    bpf.get BPF file content    ${f.strip()}
        ${status}    run keyword and return status    bpf.verify BPF params   bpf_content=${bpf_content}   variable_from_CFAM=${Variables_CFAM_temp}
        Return From Keyword If    ${status}    ${bpf_content}
    END
    Fail    Can't get correct BPF content.
    [Teardown]    csn.disconnect    connection=ASIK Master

verify content of TargetBD file
    [Arguments]  ${ru_index}=1  ${radio_type}=${ru_type_init}
    log to console    \n***verify content of TargetBD file***
    ${active_version}     coam.get_sw_version    connection=GNB_OAM
    ${TargetBD_FileName}   ${save_path}    bts_csn.check TargetBD exist and match    active_version=${active_version}
    ${regist_info}    step_keywords.check RU registration info    ${TargetBD_FileName}    ru_index=${ru_index}    radio_type=${radio_type}

Manual_SiSo_REC_Radio_Module_power_reset
    [Arguments]    ${ru_index}=1
    ${ru_index_list}  Get All RU Index
    FOR  ${ru_index}  IN  ${ru_index_list}[0]
        Perform RU Power Off    ru_index=${ru_index}    model=${tl.gnbs[0].dus[0].rus[${ru_index}-1].pdu_port.pdu.vendor}
        Wait Until Keyword Succeeds    10min    1min    RU Should Be Power Off    ru_index=${ru_index}
    END
    Power On RU And Check    ru_index_list=${ru_index_list}

    FOR  ${ru_index}  IN  ${ru_index_list}[0]
        csn.reset_cache
        Power UE L3 Call
    END
    [Teardown]    Selenium Logout And Close Browser


Manual_SiSo_STARTUP_Start-up_and_Detection_of_RF_Module
    [Arguments]    ${loop_times}=1
    Connect to gnb coam via ssl
    ${ru_index_list}  Get All RU Index
    FOR  ${i}  IN RANGE  ${loop_times}
        Perform RU Power Off And On    ru_index_list=${ru_index_list}
    END
    FOR  ${ru_index}  IN  ${ru_index_list}[0]
        Wait Until Keyword Succeeds    10min    1min    RU Should Be Online   ru_index=${ru_index}

        #check RU config    ru_index_list=${ru_index_list}
    END
#    FOR  ${ru_index}  IN  @{ru_index_list}[0]
#        log to console    "get ru ip and ping"
#        Wait until keyword succeeds  6x  5min  Get RU IP AND Check Pingable    ru_index=${ru_index}
#    END
    COAM Teardown gnb connections

Perform RU Power Off And On
    [Arguments]    ${ru_index_list}    ${ru_index}=${1}
    FOR  ${ru_index}  IN  ${ru_index_list}[0]
        Perform RU Power Off    ru_index=${ru_index}    model=${tl.gnbs[0].dus[0].rus[${ru_index}-1].pdu_port.pdu.vendor}
        sleep   100s
        Wait Until Keyword Succeeds    20min    1min    RU Should Be Power Off    ru_index=${ru_index}
    END
    FOR  ${ru_index}  IN  ${ru_index_list}[0]
        Perform RU Power On    ru_index=${ru_index}    model=${tl.gnbs[0].dus[0].rus[${ru_index}-1].pdu_port.pdu.vendor}
        sleep  10s
    END

Get RU IP AND Check Pingable
    [Arguments]    ${ru_index}    ${asik_alias}=ASIK Master
    Connect to Common Unit Master  alias=${asik_alias}
    ${ip}=            ssh.execute    command=lxc-attach -n 0x2018 -- cat /ffs/run/config/FRIps.txt | cut -d";" -f3 | sed -n '${ru_index}p'
    ...                              connection=${asik_alias}
    ${ip}=    Split String    ${ip}    \r\n
    ${output}=    ssh.execute    command=lxc-attach -n 0x2018 -- ping -c 30 -W 10 ${ip[0]}    connection=${asik_alias}
    Should contain    ${output}    30 packets transmitted, 30 received
    ssh.disconnect                   connection=${asik_alias}

check RU config
    [Arguments]    ${ru_index_list}
    FOR  ${ru_index}  IN  ${ru_index_list}[0]
        Connect to all rus with allocated IP
        ${PC_soap_path}    Download soap Log from RU    ru_alias=RU_${ru_index}
        ${productCode_cmd_cat}=    Catenate    cat ${PC_soap_path} | grep productCode
        ...    | sed -n '1p' | awk -F'productCode>' '{print$4}' | awk -F'<' '{print$1}' | tr -d '\r\n'
        ${output_productCode_cmd_catSOAP}    run    command=${productCode_cmd_cat}
        ${serialNum_cmd_cat}=    Catenate    cat ${PC_soap_path} | grep serialNum |
        ...    sed -n '1p' | awk -F'serialNum>' '{print$2}' | awk -F'<' '{print$1}' | tr -d '\r\n'
        ${output_serialNum_cmd_catSOAP}    run    command=${serialNum_cmd_cat}
        ${bldName_cmd_cat}=    Catenate    cat ${PC_soap_path} | grep bldName |
        ...    sed -n '1p' | awk -F'bldName>' '{print$2}' | awk -F'<' '{print$1}' | tr -d '\r\n'
        ${output_bldName_cmd_catSOAP}    run    command=${bldName_cmd_cat}
        log to console    \n***Check RF config from webui***
        Selenium Login And Disable Screen Lock
        ${radio_type}    get ru type  ru_index=${ru_index}
        ${ruSW_expect}=    get RFSW version from TargetBD    radio_type=${radio_type}
        ${pCode_webui}  ${pName_webui}  ${pName_webui}  ${serNum_webui}  ${hwVer_webui}  ${nrBand_webui}
        ...    ${ruSW_webui}  get RF configuration from webui  ru_index=${ru_index}
        Should Be Equal As Strings    ${output_productCode_cmd_catSOAP}    ${pCode_webui}
        Should Be Equal As Strings    ${output_serialNum_cmd_catSOAP}    ${serNum_webui}
        Should Be Equal As Strings    ${output_bldName_cmd_catSOAP}    ${ruSW_expect}
    END
    [Teardown]    Selenium Logout And Close Browser

Connect to all rus with allocated IP
    [Documentation]  Author: Ren Biyao
    ...    This keyword supports all establishment of rus via allocated IP.
    ...    2020-01-21 Ding Binmei: Return all ru alias
    ...    2020-02-18 Liu Zheng: get the ru list from init to cluster
    ...    2020-09-23 Yan Xin: all rus connection with multi-du scenario
    [Arguments]    ${connection}=GNB_OAM    ${du_index}=${0}    ${du_alias}=du_${du_index}
    connection_alias_store.Connect to Common Unit Master    du_index=${du_index}    alias=${du_alias}
    @{list_ru_alias}    Create list
    #${ru_index_list}    Get RU index list    connection=${connection}
    #FOR    ${ru_index}    IN    @{ru_index_list}[0]
    Connect to RU With Allocated IP    ru_index=${1}    ru_alias=RU_1
    ...    asik_alias=${du_alias}    connection=${connection}
    Append to list    ${list_ru_alias}    RU_1
    #END
    [Return]  ${list_ru_alias}

get RFSW version from TargetBD
    [Arguments]   ${radio_type}=${ru_type_init}
    ${Radio_Protocol_Type}  Get Radio Protocol
    ${active_version}     coam.get_sw_version    connection=GNB_OAM
    ${TargetBD_FileName}   ${save_path}    bts_csn.check TargetBD exist and match    active_version=${active_version}
    set test variable    ${resBuild_key}    LTX_${radio_type}
    ${cmd_grep}   set variable   cat '${save_path}/${TargetBD_FileName}'|grep 'hwResource resourceBuildKey="${resBuild_key}'
    ${result}=    Run Process    ${cmd_grep}    shell=True   timeout=30s   alias=myproc
    ${output_resBuildKey}=    Get Process Result     myproc
    @{ru_version}    Get Regexp matches    ${output_resBuildKey.stdout}    resourceSWVersion="(.*)"    1
    ${version_length}    get length    ${ru_version}
    ${ruSW_TargetBD}    set variable if    ${version_length}==${1} or '${Radio_Protocol_Type}'=='CPRI'    ${ru_version}[0]
    ...    ${ru_version}[1]
    [Return]    ${ruSW_TargetBD}

5GC000561_eCPRI_sync_generic_startup_at_RAU
    selenium login and disable screen lock
    Sync Startup is verified
    ${origin_value}    Change NCPRI PM Interval    interval=5min
    connect to common unit master
    Sync data is verified after startup   origin_interval=${origin_value}    change_interval=5min
    Sync status reported to O&M is verified
    Change NCPRI PM Interval    interval=${origin_value}
    csn.Disconnect  connection=ASIK Master
    selenium logout and close browser

Sync data is verified after startup
    [Documentation]  Author: tingting.zhong@nokia-sbell.com
    [Arguments]    ${origin_interval}    ${change_interval}
    log to console  \n***Sync data is verified after startup***
    Wait for New Interval PM measurements Generate    ${origin_interval}
    sleep  ${change_interval}
    sleep  30
    ${interval_seconds}    Get Interval Seconds    ${change_interval}
    ${Sync_messages_counter}    Get PM Counter via Webem    counter_id=M40102C0    interval=${change_interval}    counter_type=Transport
    ${Sync_messages_counter}    convert to integer     ${Sync_messages_counter}
    ${message_rate}    evaluate    ${Sync_messages_counter}*1.0/${interval_seconds}
    ${message_rate}  Evaluate    int(round(${message_rate}))     math
    should be equal as strings     ${message_rate}    16
    ${announce_messages_counter}    Get PM Counter via Webem    counter_id=M40102C1    interval=${change_interval}    counter_type=Transport
    ${announce_messages_counter}    convert to integer     ${announce_messages_counter}
    ${message_rate}    evaluate    ${announce_messages_counter}*1.0/${interval_seconds}
    ${message_rate}  Evaluate    int(round(${message_rate}))     math
    should be equal as strings    ${message_rate}    8

Sync Startup is verified
    [Documentation]  Author: tingting.zhong@nokia-sbell.com
    log to console  \n***Sync Startup is verified***
    ${bts_sync_mode}   Get Parameter Via Webem    dist_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/SYNC-1    filter_param=BTS synchronization mode
    ${bts_sync_mode_1}   Get Parameter Via Webem    dist_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/CLOCK_R-1
    ...    filter_param=Active synchronization mode
    should be equal as strings    ${bts_sync_mode_1}    ${bts_sync_mode}
    ${eCPRI_Master_clock_state}   Get Parameter Via Webem    dist_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/ECPRIMASTERSTATUS_R-1
    ...    filter_param=eCPRI Master clock state
    should be equal as strings    ${eCPRI_Master_clock_state}    MASTER_CLOCK_OK
    Check eCPRI Basic configuration via SOAP message

Check eCPRI Basic configuration via SOAP message
    [Documentation]  Author: tingting.zhong@nokia-sbell.com
    [Arguments]
    ${output}    Check Btsom Log file on ASIK   filter=API    alias=ASIK Master
    Should Contain    ${output}    Sending API_INET_VLAN_SET_REQ_MSG
    Should Contain    ${output}    Sending API_START_PTP_REQ_MSG
    #Should Contain    ${output}    Received API_START_PTP_RESP_MSG with status EeCpriStatus_NoError
    Should Contain    ${output}    Received API_START_PTP_RESP_MSG with status 0

Check Btsom Log file on ASIK
    [Documentation]    Author:jie-jessy.li@nokia-sbell.com
    [Arguments]    ${alias}=asik_conn    ${logfolder}=fct-4a_aasyslog  ${filter}=None
    Connect to Common Unit Master     alias=${alias}
    ${status}    Run Keyword And Return Status    csn.assert file exists    remote_path=/tmp/startup_BTSOM.log    connection=${alias}
    ${command}    Set Variable If    '${status}'=='True'    cat /tmp/startup_BTSOM.log |grep -i '${filter}'
    ...                              '${status}'=='False'    xzcat /ffs/run/logs/${logfolder}/startup_BTSOM.log.xz |grep -i '${filter}'
    ${output}    csn.execute    command=${command}    connection=${alias}
    csn.disconnect    connection=${alias}
    [Return]    ${output}

Wait for New Interval PM measurements Generate
    [Documentation]  Author: tingting.zhong@nokia-sbell.com
    [Arguments]  ${interval}
    log to console  \nWait for New Interval PM measurements Generate
    ${interval_seconds}    Get Interval Seconds    ${interval}
    ${interval_minutes}    evaluate    ${interval_seconds}/60
    ${origin_time}    get time from gnb
    ${origin_time}    convert_date    ${origin_time}   datetime
    ${minutes}    set variable    ${origin_time.minute}
    run keyword and ignore error    selenium_coam.refresh_page
    ${orig_content}    Get PM Counter content via Webem    counter_id=ETHLK-1    counter_type=Transport
    ${orig_len}    get length  ${orig_content}
    ${wait_time}    evaluate    ${interval_minutes}-${minutes}%${interval_minutes}
    sleep    ${wait_time}min
    sleep    30
    FOR  ${i}  IN RANGE  ${3}
        ${new_content}    Get PM Counter content via Webem    counter_id=ETHLK-1    counter_type=Transport
        ${new_len}    get length  ${new_content}
        exit for loop if   ${new_len}>${orig_len}
        sleep    ${interval}
        sleep    30
    END



Test Common Teardown
    Connect to gnb coam via ssl
    Active Alarms List Should Be Empty
    COAM Teardown gnb connections

Active Alarms List Should Be Empty
  ${active_alarms_list}  Run Keyword And Continue On Failure  Get Active Alarms
  ${not_allowed_alarms_number}  Run Keyword And Continue On Failure  Remove Allowed Alarms From Active Alarm List
  ...  ${active_alarms_list}  ${ALLOWED_ALARMS}
  Run Keyword And Continue On Failure  Should Be Equal as Integers  ${not_allowed_alarms_number}  0

Get Active Alarms
  Run Keyword And Continue On Failure    Wait For Fault with Alarm to disappear    FaultID=7319
  Run Keyword And Continue On Failure    Wait For Fault with Alarm to disappear    FaultID=7300
  ${active_alarms_list}  Run Keyword And Continue On Failure   coam.get_active_alarms   connection=GNB_OAM
  ...   timeout=600s
  [Return]  ${active_alarms_list}

Remove Allowed Alarms From Active Alarm List
  [Arguments]  ${active_alarms_list}=none  ${allowed_alarms_list}=none
  ${active_alarms_number}  Run Keyword And Continue On Failure  Get Length  ${active_alarms_list}
  ${not_allowed_alarms_list}  Run Keyword And Continue On Failure  Create List
  FOR  ${alarm_id}  IN RANGE  ${active_alarms_number}
      ${checked_alarm_faultId}  Run Keyword And Continue On Failure  Set Variable
      ...    ${active_alarms_list[${alarm_id}]["faultId"]}
      ${not_on_list}  Check If Alarm Allowed   allowed_alarms_list=${allowed_alarms_list}
      ...   checked_alarm=${checked_alarm_faultId}
      ${alarm}  Run Keyword And Continue On Failure   Get From List  ${active_alarms_list}   ${alarm_id}
      Run Keyword If  ${not_on_list}   Append To List  ${not_allowed_alarms_list}   ${alarm}
  END
  ${not_allowed_alarms_number}  Run Keyword And Continue On Failure  Get Length  ${not_allowed_alarms_list}
  [Return]  ${not_allowed_alarms_number}

Check If Alarm Allowed
  [Arguments]  ${allowed_alarms_list}=none  ${checked_alarm}=none
  ${allowed_alarms_number}  Get Length  ${allowed_alarms_list}
  FOR  ${allowed_alarms_id}  IN RANGE  ${allowed_alarms_number}
    ${status}  Run Keyword And Return Status  Should Not Be Equal as Strings  ${checked_alarm}
    ...   ${allowed_alarms_list[${allowed_alarms_id}]}
    Exit For Loop If  ${status}==${FALSE}
  END
  [Return]  ${status}


Wait For Fault with Alarm to disappear
  [Arguments]  ${FaultID}
  wait until keyword succeeds  1200      5    Fault Should Not Be Present   ${FaultID}


Fault Should Not Be Present
  [Arguments]    ${fault_id}
  ${active_alarms}    coam.get_active_alarms    timeout=600s    connection=GNB_OAM
  ${len}    Get Length    ${active_alarms}
  ${alarm_id_list}    Create List
  FOR    ${i}    IN RANGE    ${len}
      ${tmp_id}    Get From Dictionary    ${active_alarms[${i}]}    faultId
      Append To List    ${alarm_id_list}    ${tmp_id}
  END
  ${list}     convert to string  ${alarm_id_list}
  Should Not Contain     ${list}    ${fault_id}


General_SiSo_NR-ARFCN_check

    [Arguments]  ${cell_id}=1  ${variable_from_CFAM}=${Variables_CFAM}
    Selenium Login And Disable Screen Lock
    Get Parameters From NR_Frequencies_Band
    get nrarfcn boudary values  radio_type=${ru_type_init}  variable_from_CFAM=${variable_from_CFAM}
    ${nrarfcn}  ${gscn}  get origin nraradcn and gscn    cell_id=${cell_id}
    ${origin_params}  generate nrarfcn gscn modify parameters   nrarfcn=${nrarfcn}   gscn=${gscn}    cell_id=${cell_id}
    verify nrarfcn out of band boundary range  cell_id=${cell_id}
    verify nrarfcn out of TX/RX range  cell_id=${cell_id}
    Close Start Up View    timeout=60
    modify parameters on webem  modify_params=${origin_params}    timeout=180
    COAM Wait gnb And Cells ready    timeout=15 min    gnb_type='${gNb_CuType}'
    [Teardown]  Selenium Logout And Close Browser

get nrarfcn boudary values
    [Arguments]  ${variable_from_CFAM}=${Variables_CFAM}
    log to console    \n***get nrarfcn boudary values***
    ${band_minNrarfcn}  ${band_maxNrarfcn}  get nrarfcn range band boundary frequency
    ${minNrarfcn_pbf}  ${maxNrarfcn_pbf}  ${NrarfcnStep_3gpp}  nrarfcn_and_gscn.get nrarfcn range from TX/RX frequency
    ...    band_num=${band_num}  radio_type=${ru_type_init}  variable_from_CFAM=${variable_from_CFAM}
    ${band_minNrarfcn}  ${band_maxNrarfcn}  ${minNrarfcn_validateErr}  ${maxNrarfcn_validateErr}
    ...    nrarfcn_and_gscn.get nrarfcn out of band boundary from 3gpp
    ...    band_minNrarfcn=${band_minNrarfcn}  band_maxNrarfcn=${band_maxNrarfcn}  NrarfcnStep_3gpp=${NrarfcnStep_3gpp}
    ${minNrarfcn_1900}  ${maxNrarfcn_1900}  nrarfcn_and_gscn.get nrarfcn out of TX/RX frequency range
    ...    minNrarfcn_pbf=${minNrarfcn_pbf}  maxNrarfcn_pbf=${maxNrarfcn_pbf}  NrarfcnStep_3gpp=${NrarfcnStep_3gpp}
    set test variable  ${band_minNrarfcn}
    set test variable  ${band_maxNrarfcn}
    set test variable  ${minNrarfcn_validateErr}
    set test variable  ${maxNrarfcn_validateErr}
    set test variable  ${minNrarfcn_1900}
    set test variable  ${maxNrarfcn_1900}
    set test variable  ${NrarfcnStep_3gpp}

verify nrarfcn out of TX/RX range
    [Arguments]  ${cell_id}=1
    log to console    \n***verify nrarfcn out of TX/RX range***
    ######### out of min NRARFCN ##########
    log to console   \nout of min NRARFCN: ${minNrarfcn_1900}
    verify nrarfcn out of TX/RX  Nrarfcn_1900=${minNrarfcn_1900}  min_or_max=min  NrarfcnStep_3gpp=${NrarfcnStep_3gpp}  cell_id=${cell_id}
    ########## out of max NRARFCN ##########
    log to console   \nout of max NRARFCN: ${maxNrarfcn_1900}
    verify nrarfcn out of TX/RX  Nrarfcn_1900=${maxNrarfcn_1900}  min_or_max=max  NrarfcnStep_3gpp=${NrarfcnStep_3gpp}  cell_id=${cell_id}

verify nrarfcn out of TX/RX
    [Arguments]  ${Nrarfcn_1900}  ${min_or_max}=min  ${NrarfcnStep_3gpp}=2  ${cell_id}=1
    ${gscn}  nrarfcn_and_gscn.get gscn align with nrarfcn from 3gpp FR1  nrarfcn=${Nrarfcn_1900}
    ${modify_params}  generate nrarfcn gscn modify parameters  nrarfcn=${Nrarfcn_1900}  gscn=${gscn}  cell_id=${cell_id}
    Modify Parameters In SCF From Webem And Commission  modify_params=${modify_params}
    sleep   60s
    #Check fault 1900 on WebUI
    log to console    \nCheck fault 1900
    Wait Until Keyword Succeeds    5 min    5 sec    Connect to gnb coam via ssl
    Wait For Expect Fault Present  faultId=1900   timeout=1200
    Cell Should Be Disabled
    #recover with right NRARFCN
    ${Nrarfcn_recover}    run keyword if    '${min_or_max}' == 'min'    Evaluate     ${Nrarfcn_1900}+${NrarfcnStep_3gpp}
    ...                             ELSE    Evaluate     ${Nrarfcn_1900}-${NrarfcnStep_3gpp}
    ${Nrarfcn_recover_gscn}     nrarfcn_and_gscn.get gscn align with nrarfcn from 3gpp FR1   nrarfcn=${Nrarfcn_1900}
    log to console    \nrecover with ${min_or_max} NRARFCN: ${Nrarfcn_recover} and gscn: ${Nrarfcn_recover_gscn}
    Close Start Up View    timeout=60
    ${modify_params}  generate nrarfcn gscn modify parameters  nrarfcn=${Nrarfcn_recover}  gscn=${Nrarfcn_recover_gscn}
    modify parameters on webem  modify_params=${modify_params}    timeout=180
    sleep   60s
    Wait Until Keyword Succeeds    5 min    5 sec    Connect to gnb coam via ssl
    Wait For Expect Fault To Disappear  faultId=1900   timeout=1200
    COAM Wait gnb And Cells ready    timeout=15 min    gnb_type='${gNb_CuType}'



verify nrarfcn out of band boundary range
    [Arguments]  ${cell_id}=1
    log to console    \n***verify nrarfcn out of band boundary range***
    ######### out of min Band ##########
    log to console    \n***minNrarfcn_validateErr: ${minNrarfcn_validateErr}
    verify nrarfcn out of band boundary  Nrarfcn_validateErr=${minNrarfcn_validateErr}  band_Nrarfcn=${band_minNrarfcn}  cell_id=${cell_id}
    ######### out of max Band ##########
    log to console    \n***maxNrarfcn_validateErr: ${maxNrarfcn_validateErr}
    verify nrarfcn out of band boundary  Nrarfcn_validateErr=${maxNrarfcn_validateErr}  band_Nrarfcn=${band_maxNrarfcn}  cell_id=${cell_id}

verify nrarfcn out of band boundary
    [Arguments]    ${Nrarfcn_validateErr}    ${band_Nrarfcn}    ${cell_id}=1
    ${gscn}  nrarfcn_and_gscn.get gscn align with nrarfcn from 3gpp FR1  nrarfcn=${Nrarfcn_validateErr}
    ${modify_params}  generate nrarfcn gscn modify parameters  nrarfcn=${Nrarfcn_validateErr}  gscn=${gscn}  cell_id=${cell_id}
    Modify Parameters On Webem  modify_params=${modify_params}  is_activate=${False}
    ${relErrs_dic}    run keyword and continue on failure    selenium_coam.get_relation_errors
    ${relErrs_str}    convert to string    ${relErrs_dic}
    ${nrarfcnRang_list}    Get Regexp matches    ${relErrs_str}    \\d+
    ${band_Nrarfcn}     convert to string  ${band_Nrarfcn}
    List Should Contain Value    ${nrarfcnRang_list}    ${band_Nrarfcn}
    selenium_coam.undo_changes

get origin nraradcn and gscn
    [Arguments]  ${cell_id}=1
    ${gscn}    selenium_coam.Get Parameter Value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_id}
    ...    filter_param=Synchronization channel number
    ${nrarfcn}    selenium_coam.Get Parameter Value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${cell_id}
    ...    filter_param=NR Absolute radio frequency channel number
    [Return]  ${nrarfcn}  ${gscn}

generate nrarfcn gscn modify parameters
    [Arguments]  ${nrarfcn}  ${gscn}  ${cell_id}=1
    ${modify_params}  create list
    ${item}  create dictionary  dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/NRCELL-${cell_id}
    ...    filter_param=NR Absolute radio frequency channel number  p_name=nrarfcn  value=${nrarfcn}
    append to list  ${modify_params}  ${item}
    ${item}  create dictionary  dist_name=MRBTS-${mrbtsId}/NRBTS-${nrbtsId}/NRCELL-${cell_id}
    ...    filter_param=Synchronization channel number  p_name=gscnOrSsPbchArfcn  value=${gscn}
    append to list  ${modify_params}  ${item}
    [Return]  ${modify_params}

General_SiSo_Online_Cell_addition_deletion
    [Arguments]    ${addition_deletion_cell}=${1}
	scf commission and wait for on-air cell-add-delete
    ${addition_deletion_cell_list}  create list  ${addition_deletion_cell}
    Online Cell addition deletion   addition_deletion_cell=${addition_deletion_cell}



Online Cell addition deletion
    [Documentation]  Online last Cell addition deletion via webem
    [Arguments]  ${addition_deletion_cell}=1  ${addition_deletion_cellgrp}=0  ${NRPGRP_ID}=${1}  ${connection}=GNB_OAM
    ${activate_plan_despite_errors}    set variable if    ${if_pdl_check}    ${False}    ${True}
    Connect to gnb coam via ssl    connection=${connection}
    ${cell_grp}  Get All Cell Group Id
    ${scf_path}    Download SCF Download Via Rest Api    scf_dir_path=${SAVE LOG DIRECTORY}
	coam_parameter.perform_single_parameter_update  value=false  parameter=actNrLBmMimoRTXPowerSaving
    ...  dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}  connection=${connection}
    selenium login and disable screen lock
    log to console  delete object
    selenium_coam.remove_object    object_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${addition_deletion_cell}    timeout=15
    selenium_coam.remove_object    object_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${addition_deletion_cell}    timeout=15
    selenium_coam.remove_object    object_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELLGRP-${addition_deletion_cellgrp}    timeout=15
    ${cell_grp_len}    get length    ${cell_grp}
    FOR    ${index}    IN RANGE    ${cell_grp_len}
        ${value}    selenium_coam.get_parameter_value     dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRDU-1
        ...    abbr=refNrCellGroup    filter_param=Reference to cell group
        ...    node_index=${index}
        run keyword if    '${value}'=='${addition_deletion_cellgrp}'    selenium_coam.remove_element
        ...    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRDU-1
        ...    abbr=refNrCellGroup    filter_param=Reference to cell group
        ...    node_index=${index}
    END
    sleep    15s
    Online delete NRPGRP    NRPGRP_ID=${NRPGRP_ID}
    #selenium_coam.validate_plan
    #selenium_coam.activate_plan    activate_plan_despite_errors=${activate_plan_despite_errors}
    COAM Check GNB cell on air
    selenium_coam.load_commissioning_file_and_check_load_status    file_path=${scf_path}

    selenium_coam.get_planned_parameter_value    dist_name=MRBTS-${mrbtsID}  filter_param=BTS name  abbr=btsName
    ...    bts_configuration=Current
    log to console  add object

    selenium_coam.add_object    object_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1
    ...    object_class_name=LCELNR    plan_to_copy_from=CONF-1
    ...    copy_from=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${addition_deletion_cell}
    ...    include_subobject=${True}   id_value=${addition_deletion_cell}    timeout=15
    selenium_coam.add_object    object_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
    ...    object_class_name=NRCELL    plan_to_copy_from=CONF-1
    ...    copy_from=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${addition_deletion_cell}
    ...    include_subobject=${True}   id_value=${addition_deletion_cell}    timeout=15
    selenium_coam.add_object    object_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}
    ...    object_class_name=NRCELLGRP    plan_to_copy_from=CONF-1
    ...    copy_from=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELLGRP-${addition_deletion_cellgrp}
    ...    id_value=${addition_deletion_cellgrp}    timeout=15
    selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${addition_deletion_cell}
    ...    filter_param=Local cell resource ID    abbr=lcrId    new_value=${1}
    # recover NRDU-1 as prev
    selenium_coam.add_element    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRDU-1
    ...    abbr=refNrCellGroup    filter_param=Reference to cell group
    ...    timeout=15
    FOR  ${i}  IN  @{cell_grp}
        selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRDU-1
        ...    filter_param=Reference to cell group     new_value=${i}
        ...    node_index=${i}
    END
    sleep    15S
    Online NRPGRP addition for cell-1  NRPGRP_ID=${NRPGRP_ID}
    #selenium_coam.validate_plan
    #selenium_coam.activate_plan    activate_plan_despite_errors=${activate_plan_despite_errors}
    sleep    60s
    wait until keyword succeeds    3x    5min     verify all cells should be onair
    [Return]  selenium logout and close browser


Online NRPGRP addition for cell-1
    [Arguments]  ${NRPGRP_ID}=${1}
    log to console  \n add NRPGRP-${NRPGRP_ID}
    selenium_coam.add_object    object_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ...    object_class_name=NRPGRP    is_load_default_values=${True}    id_value=${NRPGRP_ID}    timeout=15
    #set basic
    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRPGRP-${NRPGRP_ID}
    ...    filter_param=Load-based power saving last cell switch off enabled    abbr=lbpsLastCellSOEnabled
    ...    new_value=true
    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRPGRP-${NRPGRP_ID}
    ...    filter_param=Load-based power saving maximum load    abbr=lbpsMaxLoad    new_value=${15}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRPGRP-${NRPGRP_ID}
    ...    filter_param=Load-based power saving minimum load    abbr=lbpsMinLoad    new_value=${4}
    #set lbpsCellList
    ${stream}    get stream from version    ${Active_SW_version}
    Run Keyword And Ignore Error    selenium_coam.remove_element    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRPGRP-${NRPGRP_ID}
    ...    filter_param=Load-based power saving cell period list    abbr=lbpsCellPeriodList
    FOR    ${index}    IN RANGE    0    1
        ${lbpsCellSOOrder}   set variable if    '${index}'=='0'    ${60}    ${80}
        ${nrCellId}   set variable if    '${index}'=='0'    ${1}    ${2}
        run keyword if    '${index}'!='0'    selenium_coam.add_element
        ...    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRPGRP-${NRPGRP_ID}
        ...    filter_param=Load-based power saving cell list    abbr=lbpsCellList    timeout=15
        selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRPGRP-${NRPGRP_ID}
        ...    filter_param=Load-based power saving cell switch off order    abbr=lbpsCellSOOrder
        ...    new_value=${lbpsCellSOOrder}    node_index=${index}
        selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRPGRP-${NRPGRP_ID}
        ...    filter_param=NR cell configuration identifier    abbr=nrCellId
        ...    new_value=${nrCellId}    node_index=${index}
        Run Keyword if   '${stream}'!='SBTS23R1' and '${stream}'!='SBTS23R2'
        ...    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRPGRP-${NRPGRP_ID}
        ...    filter_param=Use load-based power saving extended configurations    abbr=lbpsUseExtConfig
        ...    new_value=false    node_index=${index}
    END
    #set lbpsPeriodList
    FOR    ${index}    IN RANGE    0    7
        ${lbpsDayOfWeek}   set variable if
        ...     ${index}==0        Mon
        ...     ${index}==1        Tue
        ...     ${index}==2        Wed
        ...     ${index}==3        Thu
        ...     ${index}==4        Fri
        ...     ${index}==5        Sat
        ...     Sun
        run keyword if    '${index}'!='0'    selenium_coam.add_element
        ...    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRPGRP-${NRPGRP_ID}
        ...    filter_param=Load-based power saving period list    abbr=lbpsPeriodList    timeout=15
        selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRPGRP-${NRPGRP_ID}
        ...    filter_param=Load-based power saving day of week    abbr=lbpsDayOfWeek    new_value=${lbpsDayOfWeek}
        ...    node_index=${index}
        selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRPGRP-${NRPGRP_ID}
        ...    filter_param=Load-based power saving duration    abbr=lbpsDuration    new_value=${1440}
        ...    node_index=${index}
        selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRPGRP-${NRPGRP_ID}
        ...    filter_param=Load-based power saving start time hour    abbr=lbpsStartTimeHour    new_value=${1}
        ...    node_index=${index}
        selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRPGRP-${NRPGRP_ID}
        ...    filter_param=Load-based power saving start time minute    abbr=lbpsStartTimeMinute    new_value=${0}
        ...    node_index=${index}
        selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRPGRP-${NRPGRP_ID}
        ...    filter_param=Load-Based Power Saving Suspended    abbr=lbpsSuspended    new_value=notSuspended
        ...    node_index=${index}
    END
    selenium_coam.validate_plan
    selenium_coam.activate_plan
    sleep    60

General_SiSo_RF_module_reset_from_GUI_with_L3call
  8680_General_SiSo_RF_module_reset_from_GUI_with_L3call


Manual_SiSo_SM_RF_Module_lock_unlock
  8680_Manual_SiSo_SM_RF_Module_lock_unlock

Manual_SiSo_SM_BTS_Site_Reset

    FOR	${i}	IN RANGE	1
        Selenium Logout And Close Browser
        Perform BTS Site Reset
        sleep    60s
		Wait Until Keyword Succeeds    3x    20s    Connect to gnb coam via ssl
        Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair
        csn.reset_cache
        Power UE L3 Call

    END
    [Teardown]    Selenium Logout And Close Browser

General_SiSo_Cell_lock_and_unlock

    [Arguments]  ${with_call}=${True}
    Get X2 link shutdown waiting time
    ${cell_id_list}  Get All Cell Id
    ${cell_num}    get length  ${cell_id_list}
    Lock and Unlock Cells or Groups and L3  lock_list=${cell_id_list}  is_group=${False}  with_call=${with_call}
    Connect to gnb coam via ssl
    ${cellgrp_id_list}  Get All Cell Group Id
    ${cellgrp_num}    get length  ${cellgrp_id_list}
    # AQQQA暂时不支持
    #Lock and Unlock Cells or Groups and L3  lock_list=${cellgrp_id_list}  is_group=${True}  with_call=${with_call}  with_peak=${with_peak}
    #...    4G_check=${4G_check}
    run keyword if  ${cell_num}>1  Lock and Unlock all Cells or Groups  lock_list=${cell_id_list}  is_group=${False}
    run keyword if  ${cellgrp_num}>1  Lock and Unlock all Cells or Groups  lock_list=${cellgrp_id_list}  is_group=${True}


Lock and Unlock Cells or Groups and L3
    [Arguments]  ${lock_list}  ${is_group}=${True}  ${with_call}=${False}
    ${lock_num}    get length  ${lock_list}
    #FOR  ${lock_id}  IN  @{lock_list}
    ${lock_id}    set variable    1

    ${check_alarm}  set variable if  ${lock_num}==1  ${True}  ${False}
    ${other_cells}  Get Other Ids    id_list=${lock_list}    given_id=${lock_id}
    ${check_cell}  create list  ${lock_id}
    ${operate_list}    set variable if  ${lock_num}==1  ${check_cell}  ${other_cells}
    ${cell_list}    run keyword if  ${is_group}    Get Cell From Cell Group  cellgrp_id=${lock_id}
    ...    ELSE   set variable  ${check_cell}
    Lock cells or groups and check status  lock_list=${operate_list}  is_group=${is_group}  check_alarm=${check_alarm}
    ...    gnb_type='${gNb_CuType}'

    run keyword if  ${operate_list}[0]==2 and ${with_call}
    ...    Power UE L3 Call   cell_id=0
    run keyword if  ${operate_list}[0]==1 and ${with_call}
    ...    Power UE L3 Call   cell_id=1

    Unlock cells or groups and check status  lock_list=${operate_list}  is_group=${is_group}  check_alarm=${check_alarm}
    ...    gnb_type='${gNb_CuType}'



General_SiSo_Cell_block_and_unblock
    [Arguments]  ${with_call}=${True}  ${with_peak}=${False}
    Get X2 link shutdown waiting time
    Selenium Login And Disable Screen Lock
    ${cell_id_list}  Get All Cell Id
    ${cell_num}    get length  ${cell_id_list}
    Block and UnBlock Cells and L3call    block_list=${cell_id_list}   with_call=${with_call}  with_peak=${with_peak}

    run keyword if  ${cell_num}>1  Block and UnBlock Cells  block_list=${cell_id_list}
    [Teardown]    Run keywords    Run Keyword And Ignore Error    UnBlock Cells and check status   block_list=${cell_id_list}
    ...    check_alarm=${True}  gnb_type='${gNb_CuType}'    AND   Selenium Logout And Close Browser

Block and UnBlock Cells and L3call
    [Arguments]  ${block_list}   ${with_call}=${True}
    ${block_num}    get length  ${block_list}
    FOR  ${block_id}  IN  @{block_list}
        ${check_alarm}  set variable if  ${block_num}==1  ${True}  ${False}
        ${other_cells}  Get Other Ids    id_list=${block_list}    given_id=${block_id}
        ${check_cell}  create list  ${block_id}
        ${operate_list}    set variable if  ${block_num}==1  ${check_cell}  ${other_cells}

        Block cells and check status   block_list=${operate_list}   check_alarm=${check_alarm}    gnb_type='${gNb_CuType}'
        run keyword if  ${operate_list}[0]==2 and ${with_call}
        ...    Power UE L3 Call   cell_id=0
        run keyword if  ${operate_list}[0]==1 and ${with_call}
        ...    Power UE L3 Call   cell_id=1

        UnBlock Cells and check status   block_list=${operate_list}   check_alarm=${check_alarm}    gnb_type='${gNb_CuType}'

    END



5GC000399_eCPRI_FREERUN_state_handling

    Selenium Login And Disable Screen Lock
    ${modify_params}    Generate Modify Parameters      modify_params=${TOP_DOMAIN_NUMBER_MODIFY}
    ${orig_params}  Generate Origion Parameters  modify_params=${modify_params}
    modify parameters on webem    modify_params=${modify_params}    despite_errors=${True}
    Wait For Expect Fault Present   faultId=${16}     timeout=180
    Wait For Expect Fault Present   faultId=${4298}     timeout=180
    modify parameters on webem    modify_params=${orig_params}
    Wait For Expect Fault To Disappear   faultId=${16}   timeout=180
    Wait For Expect Fault To Disappear   faultId=${4298}     timeout=180
    coam wait gnb and cells ready    timeout=15min    gnb_type='${gNb_CuType}'
    [Teardown]   Selenium Logout And Close Browser

Generate Modify Parameters
    [Arguments]  ${modify_params}
    FOR  ${item}  IN  @{modify_params}
        ${dist_name}    get from dictionary  ${item}  dist_name
        ${mrbtsID}=    convert to string     ${mrbtsID}
        ${dist_name}    Replace String    ${dist_name}     {mrbtsID}    ${mrbtsID}
        #${dist_name}    Replace String    ${dist_name}     {nrbtsID}    ${nrbtsID}
        set to dictionary    ${item}    dist_name=${dist_name}
    END
    [Return]  ${modify_params}

General_SiSo_ALD_Configuration_Management_RAE_uploading_beamforming_weight_factor_file
    [Documentation]
    ...  :author  linjiangjing
    ...  :param  RAE_upload_path_list: E.G
    ...          [
    ...              {
    ...                  'file_path': /xx/xx/xx/xx.bin
    ...              }
    ...          ]
    [Arguments]    ${RAE_upload_path_list}=${None}    ${ALD_num}=${1}
    Run    sudo mkdir /home/ute/Downloads/
    Run    sudo chmod 777 /home/ute/Downloads/
	Run    wget -P /home/ute/Downloads/ ${ald_url}
	COAM Navigate to login page via webUI
    FOR    ${i}    IN RANGE   ${1}    ${ALD_num}+1
        ${RAE_unit}    set variable    ALD_R-${i} (RAEU_R-${i})
        ${result}    Wait Until Keyword Succeeds   10min     10s    selenium_coam.update_weight_factor_file
        ...    file_path=${RAE_upload_path_list[${i}-1]['file_path']}
        #Should Be Equal    ${result[0]}    Factory reset completed
        Should Be Equal    ${result}    Weight factor file updated
    END
    [Teardown]    selenium_coam.logout


Wait until cell is on air status
    [Arguments]  ${timeout}=15 min    ${connection}=GNB_OAM
    log    ${timeout}
    Wait until keyword succeeds    ${timeout}    20 sec    COAM Check GNB RU status    connection=${connection}
    Wait until keyword succeeds    ${timeout}    20 sec    COAM Check GNB cell on air    connection=${connection}
    Wait until keyword succeeds    ${timeout}    20 sec    Verify all cells should be onair

OAM_KPI_61a_SiSo_Auto_BTS_site_reset

    FOR    ${TEST_LOOP}    IN RANGE    0    ${MAX_LOOP}
        Set Global Variable    ${TEST_LOOP}
        ${date}=    Get Current Date        result_format=%Y-%m-%d_%H:%M:%S
        Log To Console    \n GNB Reset Iteration ${TEST_LOOP} in progress at: ${date}
        Perform BTS Site Reset
        Sleep    30s
        COAM Wait gnb And Cells ready    timeout=15min    gnb_type='${gNb_CuType}'

        Power UE L3 Call

    END

Lock nr cell
    [Arguments]  ${cell_idx}=${2}
    Log To Console    Perform cell-${cell_idx} lock
    Wait Until Keyword Succeeds    1 min    3 sec    Connect to gnb coam via ssl
    Perform cell lock via rest api    cell_idx=${cell_idx}
    sleep    5s
    [Teardown]  Run Keyword And Ignore Error  COAM Teardown gnb connections

Unlock nr cell
    [Arguments]  ${cell_idx}=${2}
    Wait Until Keyword Succeeds    1 min    3 sec    Connect to gnb coam via ssl
    Log To Console    Perform cell-${cell_idx} unlock
    Perform cell unlock via rest api    cell_idx=${cell_idx}
    sleep    5s
    [Teardown]  Run Keyword And Ignore Error  COAM Teardown gnb connections



Power UE L3 Call
    [Arguments]  ${call_time}=1200       ${log_time}=3m      ${cell_id}=0    ${actCarrierAggregation}=${False}
    ...   ${tput_UL}=10M      ${tput_DL}=100M
    #power_ue.Prepare UE    ue_type=${ue_type}     ue_index=${ue_index}

    #Lock nr cell
    keywords_8680.Barred nr cell
    run keyword and ignore error    Connect and Modify the parameter on enblte  dist_name=${lnrel_dist}  parameter=${lnrel_para1}   value=locked
    sleep    60s

    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}
    keywords_8680.Reboot UE If no UE IP

    power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}    4G_check=False   ue_index=${ue_index}
    power_ue.Start traffic    ue_index=${ue_index}    direction=ul    throughput=${tput_UL}    duration=${call_time}    ue_type=${ue_type}
  	...   iperf_type=via_command        #iperf_type=via_command                       #iperf_type=via_app   huawei
    ...    protocol=udp
    sleep    1s
    power_ue.Start traffic    ue_index=${ue_index}    direction=dl    throughput=${tput_DL}    duration=${call_time}    ue_type=${ue_type}
  	...    protocol=udp    buffer_size=1400B    process_num=${1}    seg_size=1350    window=16M
    sleep    2s

    ${log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=${log_time}    filter=L2Lo   ue_index=${ue_index}  check_source=aasyslog

    Connect to gnb coam via ssl
    ${list_of_cell_ids}    Get List of NR Cell ID

    ${cell_list}    create list
    Run Keyword If    ${actCarrierAggregation} == ${False}      Run Keywords
    ...        Append To List    ${cell_list}    ${list_of_cell_ids}[${cell_id}]    AND
    ...   set suite variable      ${list_of_cell_ids}       ${cell_list}


    ${all_tp}    power_ue.Check Bi Tput    ue_type=${ue_type}    log=${log}    cells=${list_of_cell_ids}   ue_index=${ue_index}
    ...    ultarget_throughput=0.3    dltarget_throughput=0.3    actCarrierAggregation=${actCarrierAggregation}   min_percent=0
    run keyword and ignore error  Get nrCellIdentity for SA UE  nrCId=${list_of_cell_ids}[0]
    # power_ue.Stop traffic    direction=ul    ue_index=${ue_index}    ue_type=${ue_type}    iperf_type=via_app     #iperf_type=via_command
    # power_ue.Stop traffic    direction=dl    ue_index=${ue_index}    ue_type=${ue_type}

    # power_ue.UE Detach    ue_type=${ue_type}   ue_index=${ue_index}

    #Unlock nr cell
    [Teardown]    Run Keywords  keywords_8680.Unbarred nr cell
    ...  AND  keywords_8680.UE Dettach and Stop traffic
    ...  AND  run keyword and ignore error  Connect and Modify the parameter on enblte  dist_name=${lnrel_dist}  parameter=${lnrel_para1}
    ...  value=unlocked
    ...  AND  sleep    60s
    ...  AND  Connect to gnb coam via ssl


General_SiSo_RF_Power_scaling_CSI-RS_for_Tracking
    [Arguments]  ${call_time}=2000
    #power_ue.Prepare UE    ue_type=${ue_type}     ue_index=${ue_index}
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}
    power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}    4G_check=False   ue_index=${ue_index}

    power_ue.Start traffic    ue_index=${ue_index}    direction=ul    throughput=10M    duration=${call_time}    ue_type=${ue_type}
  	...   iperf_type=via_app  #iperf_type=via_command                       #iperf_type=via_app   huawei
    ...    protocol=udp
    sleep    1s
    power_ue.Start traffic    ue_index=${ue_index}    direction=dl    throughput=100M    duration=${call_time}    ue_type=${ue_type}
  	...    protocol=udp    buffer_size=1400B    process_num=${1}    seg_size=1350    window=16M
    sleep    2s

    Capture BIP Log And Convert To CSV for Trunk
    ...  filter=(DlData_CsiRsResource_t.csiTransmitPower == -260 && DlData_CsiRsResource_t.trsInfo == 1)

    Verify Special Item Value Exist New
    ...    item=DlData_CsiRsResource_t.csiTransmitPower
    ...    item_value=-260

    Verify Special Item Value Exist New
    ...    item=DlData_CsiRsResource_t.trsInfo
    ...    item_value=1

    Capture BIP Log And Convert To CSV for Trunk
    ...  filter=(DlData_CsiRsResource_t.csiTransmitPower == -290 && DlData_CsiRsResource_t.trsInfo == 0)

    Verify Special Item Value Exist New
    ...    item=DlData_CsiRsResource_t.csiTransmitPower
    ...    item_value=-290

    Verify Special Item Value Exist New
    ...    item=DlData_CsiRsResource_t.trsInfo
    ...    item_value=0

    Capture BIP Log And Convert To CSV for Trunk
    ...  filter=(DlData_DciInfo.pdcchDciTransmitPower == -279)

    Verify Special Item Value Exist New
    ...    item=DlData_DciInfo.pdcchDciTransmitPower
    ...    item_value=-279

    Capture BIP Log And Convert To CSV for Trunk
    ...  filter=(DlData_PdschGrant.pdschTbTransmitPower == -279)

    Verify Special Item Value Exist New
    ...    item=DlData_PdschGrant.pdschTbTransmitPower
    ...    item_value=-279

    power_ue.Stop traffic    direction=ul    ue_index=${ue_index}    ue_type=${ue_type}    iperf_type=via_app     #iperf_type=via_command
    power_ue.Stop traffic    direction=dl    ue_index=${ue_index}    ue_type=${ue_type}

    power_ue.UE Detach    ue_type=${ue_type}   ue_index=${ue_index}


Capture BIP Log And Convert To CSV for Trunk
    [Arguments]    ${filter}
    CreateDirectory       /home/ute/BIPlog/l1l2bip
    Clear old log path
    Get physCellId

    Start to collect bip log new     nr_phy_cell_ids=${physical_0}
    sleep  10s
    Stop to collect bip log new     target_dir=/home/ute/BIPlog

    ${bip_files}     Get BIP File List      log_path=/home/ute/BIPlog/l1l2bip    bip_prefix=BTS2005_2011_mirroring_L2L1
    ${csv_file}    Replace String    ${bip_files}    .pcap    .csv

    Set Suite Variable    ${CSV_FILE}    ${csv_file}
    @{csv_title_list}    Create List    DlData_CsiRsResource_t.csiTransmitPower    DlData_CsiRsResource_t.trsInfo
    ...  DlData_DciInfo.pdcchDciTransmitPower        DlData_PdschGrant.pdschTbTransmitPower
    Convert BIP To CSV By MCShark    bip_file=${bip_files}
    ...    output_file=${csv_file}    filter=${filter}    csv_title_list=${csv_title_list}


Clear old log path
    csn.connect to
    ...               hostname=${tl.test_pc.default_ssh_connection_details.addr}
    ...               username=${tl.test_pc.default_ssh_connection_details.username}
    ...               password=${tl.test_pc.default_ssh_connection_details.password}
    ...               alias=test

    csn.send_command    command=sudo rm -rf /home/ute/BIPlog/l1l2bip/*    connection=test
    Sleep    10s
    csn.disconnect    connection=test

Convert BIP To CSV By MCShark
    [Documentation]    jian.1.chen@nokia-sbell.com
    [Arguments]    ${bip_file}    ${output_file}    ${filter}    ${csv_title_list}
    ${csv_title}    Set Variable
    FOR    ${column}   IN    @{csv_title_list}
        ${csv_title}    Set Variable    ${csv_title} -e ${column}
    END
    ${cmd}    Catenate    tshark -r ${bip_file} -Y '${filter}' -T fields -e _ws.col.No. -e _ws.col.Info
    ...    ${csv_title} -E header=y -E separator=, -E quote=d -E occurrence=a > ${output_file}
    OperatingSystem.Run    ${cmd}

Common 8680_J Setup
    Verify Site On Air
    Connect to gnb coam via ssl
    Active Alarms List Should Be Empty
    COAM Teardown gnb connections
    Download MCShark To UTE

    sleep  30s

Verify Special Item Value Exist New
    [Arguments]        ${item}    ${item_value}    ${file_path}=${CSV_FILE}
    ${special_item_value_list}    get_the_special_item_value    ${file_path}    ${item}
    ${status}  Run Keyword And Return Status  List Should Contain Value    ${special_item_value_list}    ${item_value}
    #Run Keyword Unless  ${status}  Should Contain Any  ${special_item_value_list}[0]    ${item_value}  ${item_value}
    run keyword if  not ${status}  Should Contain Any  ${special_item_value_list}[0]    ${item_value}

Verify Site On Air
    Connect to gnb coam via ssl
    Verify all cells should be onair
    COAM Teardown gnb connections

General_SiSo_EIRP_measurement_of_broadcasted_signals
    #scf commission and wait for on-air
    #CI_interface.Common Suite Setup
    scf commission and wait for on-air Eirpcontrol
    selenium login and disable screen lock
    connect to common unit master
    EIRP counters check
    csn.Disconnect  connection=ASIK Master
    selenium logout and close browser

    #scf commission and wait for on-air
    scf commission and wait for on-air numOfSegment0
    Lock and Unlock Cell

    selenium login and disable screen lock
    connect to common unit master
    EIRP counters check
    csn.Disconnect  connection=ASIK Master
    selenium logout and close browser

EIRP counters check
    [Arguments]    ${change_interval}=5min
    log to console  \n***EIRP data is verified ***
    #Wait for New Interval PM measurements Generate    ${origin_interval}
    sleep  ${change_interval}
    sleep  1200
    ${interval_seconds}    Get Interval Seconds    ${change_interval}

    ${EIRP_SAMPLES_counter}    Get PM Counter via Webem New    counter_id=M55324C00000    interval=${change_interval}    counter_type=BTS
    ${EIRP_SAMPLES_counter}    convert to integer     ${EIRP_SAMPLES_counter}
    ${result_max}=                       Evaluate            3200
    ${result_min}=                       Evaluate            2800
    ${expression}=                     Run Keyword If      ${result_min} < ${EIRP_SAMPLES_counter} and ${EIRP_SAMPLES_counter} < ${result_max}
    ...                                                    Set Variable    True
    ...                                            ELSE    Set Variable    False
    should be equal as strings    ${expression}       True


    ${EIRP_SEGMENT_counter}    Get PM Counter via Webem New    counter_id=M55324C00101    interval=${change_interval}    counter_type=BTS
    ${EIRP_SEGMENT_counter}    convert to integer     ${EIRP_SEGMENT_counter}
    ${MAX_EIRP_SEGMENT_counter}    Get PM Counter via Webem New    counter_id=M55324C00201    interval=${change_interval}    counter_type=BTS
    ${MAX_EIRP_SEGMENT_counter}    convert to integer     ${MAX_EIRP_SEGMENT_counter}
    ${message_rate}    evaluate    ${EIRP_SEGMENT_counter}*1.0/3000
    ${message_rate}  Evaluate    int(round(${message_rate}))     math
    should be true    ${MAX_EIRP_SEGMENT_counter} > ${message_rate}


Get PM Counter via Webem New
    [Documentation]  Author: tingting.zhong@nokia-sbell.com
    [Arguments]    ${counter_id}    ${dist_name}=${None}  ${counter_type}=BTS    ${full_path}=${None}
    ${content}    Get PM Counter content via Webem    counter_id=${counter_id}   dist_name=${dist_name}
    ...     counter_type=${counter_type}    full_path=${full_path}
    ${time_list}    get dictionary keys   ${content}
    sort list    ${time_list}
    ${status}    ${last_time}   run keyword and ignore error    set variable    ${time_list[-1]}
    #${current_time}   get time from gnb
    #${end_time}    robot.libraries.DateTime.add_time_to_date    ${last_time}    ${interval}
    #${diff}    robot.libraries.DateTime.subtract_date_from_date    ${current_time}     ${end_time}
    #${diff1}    robot.libraries.DateTime.subtract_time_from_time    ${diff}    ${interval}
    #should be true    ${diff1}<0
    ${value}    get_from_dictionary   ${content}    ${last_time}
    [Return]    ${value}



Lock and Unlock Cell
    [Arguments]    ${connection}=GNB_OAM
    Connect to gnb coam via ssl
    log to console  \n***Lock cell1 and check status***
    perform_cell_lock_via_admin    cell_id=1    connection=${connection}    lock_timeout=120
    Wait Until Keyword Succeeds   5 min  5 sec   Check cell should be locked   cell_id=1  connection=${connection}

    log to console  \n***unLock cell1 and check status***
    perform_cell_unlock_via_admin    cell_id=1    connection=${connection}    lock_timeout=120
    Wait Until Keyword Succeeds   5 min  5 sec   Check cell should be unlocked   cell_id=1    connection=${connection}
    COAM Teardown gnb connections

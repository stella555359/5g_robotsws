*** Settings ***
Documentation
...    squad group: MMW3
...    feature : CB010630

Force Tags    CRT_TRUNK

Suite Setup       Run Keywords    robot_common_operations.Common Suite Setup
...     AND    Run Keyword And Ignore error    CI_interface.Common Suite Setup
Suite Teardown    Run Keywords    robot_common_operations.Common Suite Teardown

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/ERR_WRN_Check.robot
Resource    ./Resources/CB010630_spark_call.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/SFE_TMO_common_keywords.robot
Variables   ./Resources/TLConfigration_CB10630.py



*** Variables ***
${5QI_value}    7
${ue_index}     1
${UTE_syslogs_path}     /home/ute/BTS_logs
${file_path}    /home/ute/KPI/kpi_report_releated_parameters.yml
${report_name}     kpi_report_releated_parameters_report
${excel_kpi_path}    /home/ute/KPI/
${tl_id}    ${tl.gnbs[0].global_bts_id}
@{SCF_IWK}                      SCF_NRcell_2_none_CA_Trunk.xml


*** Test Cases ***
[1]CB010630-D_CB010630-A_01_DL_Air-Interface_delay_for_AM_RLC_FR1_TDD_SA
    [Tags]    HAZ3_T03
    [Setup]     Run Keyword And Ignore Error    robot_common_operations.Common case setup
    ...     allowed_faults_ids=7300    fail_with_alarms=${False}
    CB010630 case Preparation
    Run Keyword And Ignore error   Start BTSlogs Collection In Log Server
    ...      Test_PC_IP=${Test_PC_IP}    Test_PC_username=${Test_PC_username}
    ...      Test_PC_password=${Test_PC_password}
    ...      btslog_path=/tmp/btslog2      btslog_launcher=/opt/btslog/btslog_launcher
    ...      btslog_launcher_path=/opt/btslog/btslog
    #Adjust HBTE ATT Values    ${ATTENUATION_VALUE_update1}
    run keyword and continue on failure      Get record time    label=start
    FOR    ${i}    IN RANGE    1
       run keyword and continue on failure    Test_scenario1_5QI7_no_CA
       ...     ul_tp_list=${ul_traffic_list[0:2]}    process=${2}    log_time=60s
       ...    exp_ul_tp=28   exp_dl_tp=680  ul_list=${T928_all_nr_cell_list}    dl_list=${T928_all_nr_cell_list}
       ...    multiue_config_direction=${TLCommonConfig["MultiUECFG"]}    if_ul=${True}
       sleep      5min
    END
    run keyword and continue on failure       Get record time    label=end
    sleep    15min
	run keyword and continue on failure       Get bts package version
    run keyword and continue on failure       generate new report and get report id    file_path=${file_path}
    ...     report_name=${package_version}_${report_name}
    ...    tl_id=${tl_id}    package_version=${package_version}    start_time=${start_time}    end_time=${end_time}
    run keyword and continue on failure       download_kpi_file    report_id=${report_id}    path=${excel_kpi_path}
    Run Keyword And Ignore error       Stop BTSlogs Collection And Download Logs To Log Server
    Run Keyword And Ignore error     Check ERR Or WRN From Syslog
    ...      sys_logs_path=${UTE_syslogs_path}      UTE_logs_path=${UTE_logs_path}
    ...      base_file=${Base_ERR_WRN_csv_path}
    ...      Expected_ERR_WRN_deviation=0.1      Delete_old_ERR_WRN=15
   ...       Fail_Case=${False}       Clear_log=True
    ...      FilesSystem=/dev/vda2      Max_used_space_ratio=0.85
    [Teardown]    Run Keywords    robot_common_operations.Common Case Teardown
    ...       AND    Run Keyword And Ignore error       CB010630 case Preparation
    ...       scf_name=CB010630_SCF.xml
    ...       AND    Run Keyword And Ignore error       CI_interface.Common Case Teardown

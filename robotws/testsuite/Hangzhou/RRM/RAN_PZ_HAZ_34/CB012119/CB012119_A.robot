*** Settings ***
Suite Setup       Run Keywords    robot_common_operations.Common Suite Setup
Suite Teardown    Run Keywords    robot_common_operations.Common Suite Teardown
Test Setup        Run Keywords    robot_common_operations.Common Case Setup
Test Teardown     Run Keywords    robot_common_operations.Common Case Teardown   AND   CI_interface.Common Case Teardown

Resource    ./Resources/CB012119_common_keywords.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/ERR_WRN_Check.robot
Variables   ./Resources/CB012119_scf_modify.py

Documentation
...    author: yuanyuan liu
...    contact: yuanyuan.liu@nokia-sbell.com
...    squad group: MMW3
...    feature : CB012119

Force Tags    CRT_TRUNK

*** Variables ***
${scf_name}    CB008158_FULL_SCF.xml
${5QI_value}    7
${ue_index}     0

*** Test Cases ***
[1]CB012119-A_01_DL_Air-Interface_delay_for_AM_RLC_FR1_TDD_SA
    [Tags]    HAZ3_T03
    CB012119 SA case Preparation
	run keyword and continue on failure    5QI-7 Big traffic condition      ${ue_index}
	run keyword and continue on failure    5QI-7 small traffic condition      ${ue_index}
    #[Teardown]    robot_common_operations.Common Case Teardown



[1]CB012119-A_06_DL_Air-Interface_delay_for_AM_RLC_PMQAP_interworking_DRX_FR1_TDD_NSA
    [Tags]    HAZ3_T03
    Run Keyword And Ignore error   Start BTSlogs Collection In Log Server
    ...      Test_PC_IP=${Test_PC_IP}    Test_PC_username=${Test_PC_username}
    ...      Test_PC_password=${Test_PC_password}
    ...      btslog_path=/tmp/btslog2      btslog_launcher=/opt/btslog/btslog_launcher
    ...      btslog_launcher_path=/opt/btslog/btslog
    CB012119 NSA case Preparation      list_cell_group_index=0
	${stream}    Get Stream
	run keyword and continue on failure    QCI-7 small traffic condition
    run keyword and continue on failure    QCI-7 big traffic condition
	Run Keyword And Ignore error       Stop BTSlogs Collection And Download Logs To Log Server
    Run Keyword And Continue On Failure     Check ERR Or WRN From Syslog
    ...      sys_logs_path=${UTE_syslogs_path}      UTE_logs_path=${UTE_logs_path}
    ...      base_file=${Base_ERR_WRN_csv_path}
    ...      Expected_ERR_WRN_deviation=0.1      Delete_old_ERR_WRN=15
   ...       Fail_Case=${False}       Clear_log=True
    ...      FilesSystem=/dev/vda2      Max_used_space_ratio=0.85
   # [Teardown]    robot_common_operations.Common Case Teardown

*** Keywords ***
QCI-7 small traffic condition
	UE Prepare
	Attach UE
    UE start traffic    tp_direction=dl    dl_tp=200k   iperf_port_dl=50227
    Wait for one counter period     interval_time=5min
	Log To Console    \n ### QCI 7 small traffic counters ###
	Get all DL counter value for the Corresponding 5QI via admin_cli   5QI_ID=17
	Set DL KPI Calculation formula
    check DL kpi for 5QI-7 small traffic condition
    power_ue.Stop traffic   direction=dl    ue_index=${0}    ue_type=${UE_TYPE}   iperf_port=50227
	[Teardown]    Detach UE

QCI-7 big traffic condition
	UE Prepare
	Attach UE
    UE start traffic    tp_direction=dl    dl_tp=1500M   iperf_port_dl=50227
    Wait for one counter period     interval_time=5min
	Log To Console    \n ### QCI 7 big traffic counters ###
	Get all DL counter value for the Corresponding 5QI via admin_cli   5QI_ID=17
	Set DL KPI Calculation formula
    check DL kpi for 5QI-7 big traffic condition
    power_ue.Stop traffic   direction=dl    ue_index=${0}    ue_type=${UE_TYPE}   iperf_port=50227
	[Teardown]    Detach UE


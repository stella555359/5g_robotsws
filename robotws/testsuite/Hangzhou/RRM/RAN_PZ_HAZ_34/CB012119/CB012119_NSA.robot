*** Settings ***
Suite Setup       Run Keywords    robot_common_operations.Common Suite Setup
Suite Teardown    Run Keywords    robot_common_operations.Common Suite Teardown
Test Setup        Run Keywords    robot_common_operations.Common Case Setup
Test Teardown     Run Keywords    robot_common_operations.Common Case Teardown

Resource    ./Resources/CB012119_common_keywords.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/ERR_WRN_Check.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/SFE_TMO_common_keywords.robot
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
${file_path}    /home/ute/KPI/kpi_report_releated_parameters.yml
${report_name}     kpi_report_releated_parameters_report
${excel_kpi_path}    /home/ute/KPI/
${tl_id}    ${tl.gnbs[0].global_bts_id}

*** Test Cases ***
[1]CB012119-A_06_DL_Air-Interface_delay_for_AM_RLC_PMQAP_interworking_DRX_FR1_TDD_NSA
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
    [Teardown]    Testcase specific teardown

[1]CB012119-C_03_DL_RLC_SDU_delay_for_PMQAP_FR1_TDD_NSA
    Run Keyword And Ignore error   Start BTSlogs Collection In Log Server
    ...      Test_PC_IP=${Test_PC_IP}    Test_PC_username=${Test_PC_username}
    ...      Test_PC_password=${Test_PC_password}
    ...      btslog_path=/tmp/btslog2      btslog_launcher=/opt/btslog/btslog_launcher
    ...      btslog_launcher_path=/opt/btslog/btslog
    CB012119 NSA case Preparation      list_cell_group_index=0
	run keyword and continue on failure    QCI-8 small traffic condition
    run keyword and continue on failure    QCI-6 big traffic condition
	Run Keyword And Ignore error       Stop BTSlogs Collection And Download Logs To Log Server
    Run Keyword And Continue On Failure     Check ERR Or WRN From Syslog
    ...      sys_logs_path=${UTE_syslogs_path}      UTE_logs_path=${UTE_logs_path}
    ...      base_file=${Base_ERR_WRN_csv_path}
    ...      Expected_ERR_WRN_deviation=0.1      Delete_old_ERR_WRN=15
   ...       Fail_Case=${False}       Clear_log=True
    ...      FilesSystem=/dev/vda2      Max_used_space_ratio=0.85
    [Teardown]    Testcase specific teardown

[1]CB012119-D_01_DL_Average_IP_latency_FR1_TDD_NSA
    Run Keyword And Ignore error   Start BTSlogs Collection In Log Server
    ...      Test_PC_IP=${Test_PC_IP}    Test_PC_username=${Test_PC_username}
    ...      Test_PC_password=${Test_PC_password}
    ...      btslog_path=/tmp/btslog2      btslog_launcher=/opt/btslog/btslog_launcher
    ...      btslog_launcher_path=/opt/btslog/btslog
    CB012119 NSA case Preparation      list_cell_group_index=0
	UE Prepare
	Attach UE
    UE start traffic    tp_direction=dl    dl_tp=300k   iperf_port_dl=50226
    Wait for one counter period     interval_time=5min
	Log To Console    \n ### QCI 6 small traffic counters ###
	Get all DL counter value for the Corresponding 5QI via admin_cli   5QI_ID=16
	Set DL KPI Calculation formula
    run keyword and continue on failure     check DL kpi for 5QI-7 small traffic condition
    power_ue.Stop traffic   direction=dl    ue_index=${0}    ue_type=${UE_TYPE}   iperf_port=50216
	Run Keyword And Ignore error       Stop BTSlogs Collection And Download Logs To Log Server
    Run Keyword And Continue On Failure     Check ERR Or WRN From Syslog
    ...      sys_logs_path=${UTE_syslogs_path}      UTE_logs_path=${UTE_logs_path}
    ...      base_file=${Base_ERR_WRN_csv_path}
    ...      Expected_ERR_WRN_deviation=0.1      Delete_old_ERR_WRN=15
   ...       Fail_Case=${False}       Clear_log=True
    ...      FilesSystem=/dev/vda2      Max_used_space_ratio=0.85
    [Teardown]    Testcase specific teardown

[1]CB012119-E_04_Average_UL_over_Air_Interface_delay_for_UL_packet_PMQAP_NSA
    Run Keyword And Ignore error   Start BTSlogs Collection In Log Server
    ...      Test_PC_IP=${Test_PC_IP}    Test_PC_username=${Test_PC_username}
    ...      Test_PC_password=${Test_PC_password}
    ...      btslog_path=/tmp/btslog2      btslog_launcher=/opt/btslog/btslog_launcher
    ...      btslog_launcher_path=/opt/btslog/btslog
    CB012119 NSA case Preparation      list_cell_group_index=0
    UE Prepare
	Attach UE
    UE start traffic    tp_direction=ul    ul_tp=50M    iperf_port_ul=43106    ue_index=${0}
    Wait for one counter period     interval_time=5min
	Log To Console    \n ### get E counters in non-CG mode ###
	run keyword and continue on failure    Get PART-C UL counter value for the Corresponding 5QI via admin_cli   5QI_ID=16
	run keyword and continue on failure    Set Part-C UL KPI Calculation formula
	run keyword and continue on failure    Check E and F counters
    power_ue.Stop traffic   direction=ul    ue_index=${0}    ue_type=${UE_TYPE}   iperf_port=43116
	Run Keyword And Ignore error       Stop BTSlogs Collection And Download Logs To Log Server
    Run Keyword And Continue On Failure     Check ERR Or WRN From Syslog
    ...      sys_logs_path=${UTE_syslogs_path}      UTE_logs_path=${UTE_logs_path}
    ...      base_file=${Base_ERR_WRN_csv_path}
    ...      Expected_ERR_WRN_deviation=0.1      Delete_old_ERR_WRN=15
   ...       Fail_Case=${False}       Clear_log=True
    ...      FilesSystem=/dev/vda2      Max_used_space_ratio=0.85
    [Teardown]    Testcase specific teardown

[1]CB012119-F_04_UL_RLC_packet_delay_PMQAP_FR1_TDD_NSA
    Run Keyword And Ignore error   Start BTSlogs Collection In Log Server
    ...      Test_PC_IP=${Test_PC_IP}    Test_PC_username=${Test_PC_username}
    ...      Test_PC_password=${Test_PC_password}
    ...      btslog_path=/tmp/btslog2      btslog_launcher=/opt/btslog/btslog_launcher
    ...      btslog_launcher_path=/opt/btslog/btslog
    CB012119 NSA case Preparation      list_cell_group_index=0
    UE Prepare
	Attach UE
    UE start traffic    tp_direction=ul    ul_tp=50M    iperf_port_ul=43106    ue_index=${0}
    UE start traffic    tp_direction=ul    ul_tp=300k    iperf_port_ul=43108    ue_index=${0}
    Wait for one counter period     interval_time=5min
	Log To Console    \n ### get E counters in non-CG mode ###
	run keyword and continue on failure    Get PART-C UL counter value for the Corresponding 5QI via admin_cli   5QI_ID=18
	run keyword and continue on failure    Set Part-C UL KPI Calculation formula
	run keyword and continue on failure    Check E and F counters
    power_ue.Stop traffic   direction=ul    ue_index=${0}    ue_type=${UE_TYPE}   iperf_port=43116
	Run Keyword And Ignore error       Stop BTSlogs Collection And Download Logs To Log Server
    Run Keyword And Continue On Failure     Check ERR Or WRN From Syslog
    ...      sys_logs_path=${UTE_syslogs_path}      UTE_logs_path=${UTE_logs_path}
    ...      base_file=${Base_ERR_WRN_csv_path}
    ...      Expected_ERR_WRN_deviation=0.1      Delete_old_ERR_WRN=15
   ...       Fail_Case=${False}       Clear_log=True
    ...      FilesSystem=/dev/vda2      Max_used_space_ratio=0.85
    [Teardown]    Testcase specific teardown

[1]CB012119-KPI_CA_TL2090_robustness
    AlarmWatchdog.add_allow_alarms    fault_id=4655
    AlarmWatchdog.add_allow_alarms    fault_id=4654
    AlarmWatchdog.add_allow_alarms    fault_id=61524
    AlarmWatchdog.add_allow_alarms    fault_id=4297
    CB012119 NSA case Preparation      list_cell_group_index=1
    Run Keyword And Ignore error   Start BTSlogs Collection In Log Server
    ...      Test_PC_IP=${Test_PC_IP}    Test_PC_username=${Test_PC_username}
    ...      Test_PC_password=${Test_PC_password}
    ...      btslog_path=/tmp/btslog2      btslog_launcher=/opt/btslog/btslog_launcher
    ...      btslog_launcher_path=/opt/btslog/btslog
    Adjust HBTE ATT Values for TL2090    ${ATTENUATION_VALUE_update6}
	UE Prepare
	Attach UE
    UE start traffic    tp_direction=dl    dl_tp=1300M   iperf_port_dl=50227
    Wait for one counter period     interval_time=5min
	Log To Console    \n ### QCI 7 small traffic counters ###
	Get all DL counter value for the Corresponding 5QI via admin_cli   5QI_ID=17
	Set DL KPI Calculation formula
	Check Pcell KPI
	#Set Suite Variable    ${CB012119_A_Pcell}   ${CB012119_A}
	Set Suite Variable    ${CB012119_B_Pcell}   ${CB012119_B}
	Set Suite Variable    ${CB012119_C_Pcell}   ${CB012119_C}
	Set Suite Variable    ${CB012119_D_Pcell}   ${CB012119_D}
	Set Suite Variable    ${CB012119_H_Pcell}   ${CB012119_H}
	#Set Suite Variable    ${NR_6096a_Pcell}   ${NR_6096a}
	${MR_NR_CELL_NAME}    set variable      ${MR_NR_BTS_NAME}/NRCELL-2
	Set Suite Variable      ${MR_NR_CELL_NAME}
	Get all DL counter value for the Corresponding 5QI via admin_cli   5QI_ID=17
	Set DL KPI Calculation formula
	Check Scell KPI
	#Set Suite Variable    ${CB012119_A_Scell}   ${CB012119_A}
	Set Suite Variable    ${CB012119_B_Scell}   ${CB012119_B}
	Set Suite Variable    ${CB012119_C_Scell}   ${CB012119_C}
	Set Suite Variable    ${CB012119_D_Scell}   ${CB012119_D}
	Set Suite Variable    ${CB012119_H_Scell}   ${CB012119_H}
	#Set Suite Variable    ${NR_6096a_Scell}   ${NR_6096a}
	Check Pcell and Scell KPI
    Get record time    label=start
    Wait for one counter period     interval_time=15min
	Get record time    label=end
    sleep    15min
	Get bts package version
    generate new report and get report id    file_path=${file_path}   report_name=${package_version}_${report_name}
    ...    tl_id=${tl_id}    package_version=${package_version}    start_time=${start_time}    end_time=${end_time}
    download_kpi_file    report_id=${report_id}    path=${excel_kpi_path}
    power_ue.Stop traffic   direction=dl    ue_index=${0}    ue_type=${UE_TYPE}   iperf_port=50227
	Run Keyword And Ignore error       Stop BTSlogs Collection And Download Logs To Log Server
    Run Keyword And Continue On Failure     Check ERR Or WRN From Syslog
    ...      sys_logs_path=${UTE_syslogs_path}      UTE_logs_path=${UTE_logs_path}
    ...      base_file=${Base_ERR_WRN_csv_path}
    ...      Expected_ERR_WRN_deviation=0.1      Delete_old_ERR_WRN=15
   ...       Fail_Case=${False}       Clear_log=True
    ...      FilesSystem=/dev/vda2      Max_used_space_ratio=0.85
    [Teardown]    Testcase specific teardown



*** Keywords ***
QCI-7 small traffic condition
	UE Prepare
	Attach UE
    UE start traffic    tp_direction=dl    dl_tp=300k   iperf_port_dl=50227
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

QCI-8 small traffic condition
	UE Prepare
	Attach UE
    UE start traffic    tp_direction=dl    dl_tp=300k   iperf_port_dl=50228
    Wait for one counter period     interval_time=5min
	Log To Console    \n ### QCI 8 small traffic counters ###
	Get all DL counter value for the Corresponding 5QI via admin_cli   5QI_ID=18
	Set DL KPI Calculation formula
	check DL kpi for 5QI-8 small traffic condition
    power_ue.Stop traffic   direction=dl    ue_index=${0}    ue_type=${UE_TYPE}   iperf_port=50218
	[Teardown]    Detach UE

QCI-6 big traffic condition
	UE Prepare
	Attach UE
    UE start traffic    tp_direction=dl    dl_tp=1500M   iperf_port_dl=50226
    Wait for one counter period     interval_time=5min
	Log To Console    \n ### QCI 6 big traffic counters ###
	Get all DL counter value for the Corresponding 5QI via admin_cli   5QI_ID=16
	Set DL KPI Calculation formula
    check DL kpi for 5QI-7 big traffic condition
    power_ue.Stop traffic   direction=dl    ue_index=${0}    ue_type=${UE_TYPE}   iperf_port=50216
	[Teardown]    Detach UE

Check E and F counters
	run keyword and continue on failure      should be true     0<${CB012119_E}<100
	run keyword and continue on failure      should be true     0<${CB012119_E_PMQAP}<100
	run keyword and continue on failure      should be true     0<${CB012119_F}<50
	run keyword and continue on failure      should be true     0<${CB012119_F_PMQAP}<50

Check Pcell KPI
	#should be true     0<${CB012119_A}<10
	#should be true     0<${CB012119_A_PMQAP}<10
	should be true     0<${CB012119_C}<10
	should be true     0<${CB012119_C_PMQAP}<10
	should be true     0<${CB012119_D}<10
	should be true     0<${CB012119_D_PMQAP}<10
	should be true     0<${CB012119_H}<10
	should be true     0<${CB012119_H_PMQAP}<10
	should be true     ${CB012119_B}==0
	should be true     ${CB012119_B_PMQAP}==0
	#should be true     ${NR_6096a}<50



Check Scell KPI
	#should be true     0<${CB012119_A}<10
	#should be true     0<${CB012119_A_PMQAP}<10
	should be true     0<${CB012119_C}<10
	should be true     0<${CB012119_C_PMQAP}<10
	should be true     0<${CB012119_D}<10
	should be true     0<${CB012119_D_PMQAP}<10
    Log To Console     EDA04426599 update 5G_PM_1210, only support CB008158-A counters, CB012119-H will reported in Pcell
	should be true     ${CB012119_H}==0
	should be true     ${CB012119_H_PMQAP}==0
	should be true     ${CB012119_B}==0
	should be true     ${CB012119_B_PMQAP}==0
	#should be true     ${NR_6096a}<50


Check Pcell and Scell KPI
    #Should be True      ${CB012119_A_Scell}*0.7<${CB012119_A_Pcell}<${CB012119_A_Scell}*1.5
    Should be True      ${CB012119_C_Pcell}*0.7<${CB012119_C_Scell}<${CB012119_C_Pcell}*1.5
    Should be True      ${CB012119_D_Pcell}*0.7<${CB012119_D_Scell}<${CB012119_D_Pcell}*1.3
    #Should be True      ${NR_6096a_Pcell}*0.9<${NR_6096a_Scell}<${NR_6096a_Pcell}*1.1
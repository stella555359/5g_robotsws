*** Settings ***
Suite Setup       Run Keywords    robot_common_operations.Common Suite Setup
Suite Teardown    Run Keywords    robot_common_operations.Common Suite Teardown
Test Setup        Run Keywords    robot_common_operations.Common Case Setup
#Test Teardown     Run Keywords    robot_common_operations.Common Case Teardown

Resource    ./Resources/CB008158_common_keywords.robot
Variables   ./Resources/CB008158_scf_modify.py

Documentation
...    author: Luo Tina
...    contact: tina.luo@nokia-sbell.com
...    squad group: MMW3
...    feature : CB008158

Force Tags    CRT_TRUNK

*** Variables ***
${scf_name}    CB008158_FULL_SCF.xml
${5QI_value}    7
*** Test Cases ***
[1]CB008158-D_25_Initial_Burst_scheduling_delay_in_DL_for_PMQAP_FR1_TDD_SA
    CB008158 SA case Preparation
	#Run Keyword And Ignore error   Start BTSlogs Collection In Log Server
    #...      Test_PC_IP=${Test_PC_IP}    Test_PC_username=${Test_PC_username}
    #...      Test_PC_password=${Test_PC_password}
    #...      btslog_path=/tmp/btslog2      btslog_launcher=/opt/btslog/btslog_launcher
    #...      btslog_launcher_path=/opt/btslog/btslog
    run keyword and continue on failure    5QI-1 and 5QI-2 and 5QI-5 traffic condition
	#Run Keyword And Ignore error       Stop BTSlogs Collection And Download Logs To Log Server
    #Run Keyword And Continue On Failure     Check ERR Or WRN From Syslog
    #...      sys_logs_path=${UTE_syslogs_path}      UTE_logs_path=${UTE_logs_path}
    #...      base_file=${Base_ERR_WRN_csv_path}
    #...      Expected_ERR_WRN_deviation=0.1      Delete_old_ERR_WRN=15
   #...       Fail_Case=${False}       Clear_log=True
    #...      FilesSystem=/dev/vda2      Max_used_space_ratio=0.85
    [Teardown]    run keywords    robot_common_operations.Common Case Teardown
	...   AND    Run Keyword If Test Failed   Test Case teardown in case failure
	...   AND    CI_interface.Common Case Teardown
	...   AND    CB008158 case recover to golden SCF
[1]CB008158-A_01_DL_Air-Interface_delay_FR1_TDD_SA
    CB008158 SA case Preparation
	#Run Keyword And Ignore error   Start BTSlogs Collection In Log Server
    #...      Test_PC_IP=${Test_PC_IP}    Test_PC_username=${Test_PC_username}
    #...      Test_PC_password=${Test_PC_password}
    #...      btslog_path=/tmp/btslog2      btslog_launcher=/opt/btslog/btslog_launcher
    #...      btslog_launcher_path=/opt/btslog/btslog
	run keyword and continue on failure    5QI-7 Big traffic condition
	run keyword and continue on failure    5QI-7 small traffic condition
	#Run Keyword And Ignore error       Stop BTSlogs Collection And Download Logs To Log Server
    #Run Keyword And Continue On Failure     Check ERR Or WRN From Syslog
    #...      sys_logs_path=${UTE_syslogs_path}      UTE_logs_path=${UTE_logs_path}
    #...      base_file=${Base_ERR_WRN_csv_path}
    #...      Expected_ERR_WRN_deviation=0.1      Delete_old_ERR_WRN=15
   #...       Fail_Case=${False}       Clear_log=True
    #...      FilesSystem=/dev/vda2      Max_used_space_ratio=0.85
    [Teardown]    run keywords    robot_common_operations.Common Case Teardown
	...   AND    Run Keyword If Test Failed   Test Case teardown in case failure
	...   AND    CI_interface.Common Case Teardown
	...   AND    CB008158 case recover to golden SCF
[1]CB008158-B_09_DL_PDCP_SDU_delay_for_PMQAP_FR1_TDD_SA
    CB008158 SA case Preparation
	#Run Keyword And Ignore error   Start BTSlogs Collection In Log Server
    #...      Test_PC_IP=${Test_PC_IP}    Test_PC_username=${Test_PC_username}
    #...      Test_PC_password=${Test_PC_password}
    #...      btslog_path=/tmp/btslog2      btslog_launcher=/opt/btslog/btslog_launcher
    #...      btslog_launcher_path=/opt/btslog/btslog
 	run keyword and continue on failure    5QI-4 Big traffic condition
 	run keyword and continue on failure    5QI-4 small traffic condition
	#Run Keyword And Ignore error       Stop BTSlogs Collection And Download Logs To Log Server
    #Run Keyword And Continue On Failure     Check ERR Or WRN From Syslog
    #...      sys_logs_path=${UTE_syslogs_path}      UTE_logs_path=${UTE_logs_path}
    #...      base_file=${Base_ERR_WRN_csv_path}
    #...      Expected_ERR_WRN_deviation=0.1      Delete_old_ERR_WRN=15
   #...       Fail_Case=${False}       Clear_log=True
    #...      FilesSystem=/dev/vda2      Max_used_space_ratio=0.85
    [Teardown]    run keywords    robot_common_operations.Common Case Teardown
	...   AND    Run Keyword If Test Failed   Test Case teardown in case failure
	...   AND    CI_interface.Common Case Teardown
	...   AND    CB008158 case recover to golden SCF
[1]CB008158-B_07_DL_PDCP_SDU_delay_FR1_TDD_SA
    CB008158 SA case Preparation
	#Run Keyword And Ignore error   Start BTSlogs Collection In Log Server
    #...      Test_PC_IP=${Test_PC_IP}    Test_PC_username=${Test_PC_username}
    #...      Test_PC_password=${Test_PC_password}
    #...      btslog_path=/tmp/btslog2      btslog_launcher=/opt/btslog/btslog_launcher
    #...      btslog_launcher_path=/opt/btslog/btslog
	run keyword and continue on failure    5QI-8 small traffic condition
	#Run Keyword And Ignore error       Stop BTSlogs Collection And Download Logs To Log Server
    #Run Keyword And Continue On Failure     Check ERR Or WRN From Syslog
    #...      sys_logs_path=${UTE_syslogs_path}      UTE_logs_path=${UTE_logs_path}
    #...      base_file=${Base_ERR_WRN_csv_path}
    #...      Expected_ERR_WRN_deviation=0.1      Delete_old_ERR_WRN=15
   #...       Fail_Case=${False}       Clear_log=True
    #...      FilesSystem=/dev/vda2      Max_used_space_ratio=0.85
    [Teardown]    run keywords    robot_common_operations.Common Case Teardown
	...   AND    Run Keyword If Test Failed   Test Case teardown in case failure
	...   AND    CI_interface.Common Case Teardown
	...   AND    CB008158 case recover to golden SCF
[1]CB008158-C_15_PDCP_re-ordering_Delay_UL_for_PMQAP_FR1_TDD_SA
    CB008158 SA case Preparation
	#Run Keyword And Ignore error   Start BTSlogs Collection In Log Server
    #...      Test_PC_IP=${Test_PC_IP}    Test_PC_username=${Test_PC_username}
    #...      Test_PC_password=${Test_PC_password}
    #...      btslog_path=/tmp/btslog2      btslog_launcher=/opt/btslog/btslog_launcher
    #...      btslog_launcher_path=/opt/btslog/btslog
    UE Prepare
	Attach UE
    UE start traffic    tp_direction=ul    ul_tp=100M    iperf_port_ul=43507
	UE start traffic    tp_direction=ul    ul_tp=10M    iperf_port_ul=43504
	Wait for one counter period     interval_time=5min
	run keyword and continue on failure    Get PART-C UL counter value for the Corresponding 5QI via admin_cli   5QI_ID=7
	Get all CB012119 Part counter value for the Corresponding 5QI via admin_cli
	Set CB012119 KPI Calculation formula
	run keyword and continue on failure    Set Part-C UL KPI Calculation formula
	run keyword and continue on failure    check PART-C UL kpi for 5QI-7
	run keyword and continue on failure    Get PART-C UL counter value for the Corresponding 5QI via admin_cli   5QI_ID=4
	run keyword and continue on failure    Set Part-C UL KPI Calculation formula
	run keyword and continue on failure    check PART-C UL kpi for 5QI-4
	Detach UE
	#Run Keyword And Ignore error       Stop BTSlogs Collection And Download Logs To Log Server
    #Run Keyword And Continue On Failure     Check ERR Or WRN From Syslog
    #...      sys_logs_path=${UTE_syslogs_path}      UTE_logs_path=${UTE_logs_path}
    #...      base_file=${Base_ERR_WRN_csv_path}
    #...      Expected_ERR_WRN_deviation=0.1      Delete_old_ERR_WRN=15
   #...       Fail_Case=${False}       Clear_log=True
    #...      FilesSystem=/dev/vda2      Max_used_space_ratio=0.85
    [Teardown]    run keywords    robot_common_operations.Common Case Teardown
	...   AND    Run Keyword If Test Failed   Test Case teardown in case failure
	...   AND    CI_interface.Common Case Teardown
	...   AND    CB008158 case recover to golden SCF
[1]CB008158-E_26_PDCP_Bursts_in_UL_FR1_TDD_SA
    CB008158 SA case Preparation
	#Run Keyword And Ignore error   Start BTSlogs Collection In Log Server
    #...      Test_PC_IP=${Test_PC_IP}    Test_PC_username=${Test_PC_username}
    #...      Test_PC_password=${Test_PC_password}
    #...      btslog_path=/tmp/btslog2      btslog_launcher=/opt/btslog/btslog_launcher
    #...      btslog_launcher_path=/opt/btslog/btslog
    UE Prepare
	Attach UE
    UE start traffic    tp_direction=ul    ul_tp=50M    iperf_port_ul=43507
	UE start traffic    tp_direction=ul    ul_tp=100k    iperf_port_ul=43504
	UE Prepare    ue_index=${1}
	Attach UE     ue_index=${1}
    Make a VoNR call     ue_index=${0}    phone_number=13031398566
	answer VoNR call    ue_index=${1}
    switch ViNR to VoNR call     ue_index=${0}
    answer ViNR call     ue_index=${1}
	Wait for one counter period     interval_time=5min
	Get Part-E UL counter value for the Corresponding 5QI via admin_cli
	Get all CB012119 Part counter value for the Corresponding 5QI via admin_cli
	Set CB012119 KPI Calculation formula
    Set Part-E UL KPI Calculation formula
	check PART-E UL kpi
	hang up VoNR and ViNR call    ue_index=${0}
	power_ue.Stop traffic   direction=ul    ue_index=${0}    ue_type=${UE_TYPE}   iperf_port=43504
	power_ue.Stop traffic   direction=ul    ue_index=${0}    ue_type=${UE_TYPE}   iperf_port=43507
	#Run Keyword And Ignore error       Stop BTSlogs Collection And Download Logs To Log Server
    #Run Keyword And Continue On Failure     Check ERR Or WRN From Syslog
    #...      sys_logs_path=${UTE_syslogs_path}      UTE_logs_path=${UTE_logs_path}
    #...      base_file=${Base_ERR_WRN_csv_path}
    #...      Expected_ERR_WRN_deviation=0.1      Delete_old_ERR_WRN=15
   #...       Fail_Case=${False}       Clear_log=True
    #...      FilesSystem=/dev/vda2      Max_used_space_ratio=0.85
    [Teardown]    run keywords    robot_common_operations.Common Case Teardown
	...   AND    CI_interface.Common Case Teardown
	...   AND    Run Keyword If Test Failed   Test Case teardown in case failure
	...   AND    Detach UE   ue_index=${1}
	...   AND    Detach UE   ue_index=${0}
	...   AND    CB008158 case recover to golden SCF
*** Keywords ***
5QI-7 Big traffic condition
    UE Prepare
	Attach UE
    UE start traffic    tp_direction=dl    dl_tp=1400M    iperf_port_dl=43607
    Wait for one counter period     interval_time=5min
	Log To Console    \n ### 5QI_ID 7 big traffic counters ###
    Get all DL counter value for the Corresponding 5QI via admin_cli    5QI_ID=7
	Get all CB012119 Part counter value for the Corresponding 5QI via admin_cli
	Set DL KPI Calculation formula
	Set CB012119 KPI Calculation formula
    power_ue.Stop traffic   direction=dl    ue_index=${0}    ue_type=${UE_TYPE}   iperf_port=43607
	check DL kpi for 5QI-7 big traffic condition
	[Teardown]    Detach UE

5QI-7 small traffic condition
	UE Prepare
	Attach UE
    UE start traffic    tp_direction=dl    dl_tp=100k   iperf_port_dl=43607
    Wait for one counter period     interval_time=5min
	Log To Console    \n ### 5QI_ID 7 small traffic counters ###
	Get all DL counter value for the Corresponding 5QI via admin_cli   5QI_ID=${5QI_value}
	Get all CB012119 Part counter value for the Corresponding 5QI via admin_cli
	Set DL KPI Calculation formula
	Set CB012119 KPI Calculation formula
    power_ue.Stop traffic   direction=dl    ue_index=${0}    ue_type=${UE_TYPE}   iperf_port=43607
	check DL kpi for 5QI-7 small traffic condition
	[Teardown]    Detach UE

5QI-8 small traffic condition
    UE Prepare    ue_index=${1}
	Attach UE    ue_index=${1}
    UE start traffic    tp_direction=dl    dl_tp=50k   iperf_port_dl=43408   ue_index=${1}
    Wait for one counter period     interval_time=5min
	Log To Console    \n ### 5QI_ID 8 small traffic counters ###
	Get all DL counter value for the Corresponding 5QI via admin_cli   5QI_ID=8
	Get all CB012119 Part counter value for the Corresponding 5QI via admin_cli
	Set DL KPI Calculation formula
	Set CB012119 KPI Calculation formula
    power_ue.Stop traffic   direction=dl    ue_index=${0}    ue_type=${UE_TYPE}   iperf_port=43408
	check DL kpi for 5QI-8 small traffic condition
	[Teardown]    Detach UE    ue_index=${1}

5QI-4 Big traffic condition
    UE Prepare
	Attach UE
	Set Test variable     ${5QI_value}    4
	UE start traffic    tp_direction=dl    dl_tp=50M   iperf_port_dl=43604
    Wait for one counter period     interval_time=5min
	Log To Console    \n ### 5QI_ID 4 traffic counters ###
	Get all DL counter value for the Corresponding 5QI via admin_cli    5QI_ID=${5QI_value}
	Get all CB012119 Part counter value for the Corresponding 5QI via admin_cli
	Set DL KPI Calculation formula
	Set CB012119 KPI Calculation formula
    power_ue.Stop traffic   direction=dl    ue_index=${0}    ue_type=${UE_TYPE}   iperf_port=43604
	check DL kpi for 5QI-4 traffic condition
	[Teardown]    Detach UE
5QI-4 small traffic condition
    UE Prepare
	Attach UE
	Set Test variable     ${5QI_value}    4
	UE start traffic    tp_direction=dl    dl_tp=50K  iperf_port_dl=43604
    Wait for one counter period     interval_time=5min
	Log To Console    \n ### 5QI_ID 4 traffic counters ###
	Get all DL counter value for the Corresponding 5QI via admin_cli    5QI_ID=${5QI_value}
	Get all CB012119 Part counter value for the Corresponding 5QI via admin_cli
	Set DL KPI Calculation formula
	Set CB012119 KPI Calculation formula
    power_ue.Stop traffic   direction=dl    ue_index=${0}    ue_type=${UE_TYPE}   iperf_port=43604
	check DL kpi for 5QI-4 traffic condition
	[Teardown]    Detach UE

5QI-1 and 5QI-2 and 5QI-5 traffic condition
	UE Prepare    ue_index=${0}
	Attach UE     ue_index=${0}
	UE Prepare    ue_index=${1}
	Attach UE     ue_index=${1}
    Make a VoNR call     ue_index=${0}    phone_number=13031398566
	answer VoNR call    ue_index=${1}
	Wait for one counter period     interval_time=5min
	Log To Console    \n ### 5QI_ID 1 traffic counters ###
	Get all DL counter value for the Corresponding 5QI via admin_cli    5QI_ID=1
	Get all CB012119 Part counter value for the Corresponding 5QI via admin_cli
	Set DL KPI Calculation formula
	Set CB012119 KPI Calculation formula
	check DL kpi for 5QI-1 traffic condition
	Log To Console    \n ### 5QI_ID 5 traffic counters ###
	Get all DL counter value for the Corresponding 5QI via admin_cli    5QI_ID=5
	Get all CB012119 Part counter value for the Corresponding 5QI via admin_cli
	Set DL KPI Calculation formula
	Set CB012119 KPI Calculation formula
    switch ViNR to VoNR call     ue_index=${0}
    answer ViNR call     ue_index=${1}
    Wait for one counter period     interval_time=5min
	Log To Console    \n ### 5QI_ID 1 traffic counters ###
	Get all DL counter value for the Corresponding 5QI via admin_cli    5QI_ID=1
	Get all CB012119 Part counter value for the Corresponding 5QI via admin_cli

	Set DL KPI Calculation formula
	Set CB012119 KPI Calculation formula
	check DL kpi for 5QI-1 traffic condition
	Log To Console    \n ### 5QI_ID 2 traffic counters ###
	Get all DL counter value for the Corresponding 5QI via admin_cli    5QI_ID=2
	Get all CB012119 Part counter value for the Corresponding 5QI via admin_cli
	Set DL KPI Calculation formula
	Set CB012119 KPI Calculation formula
	check DL kpi for 5QI-2 traffic condition
	Log To Console    \n ### 5QI_ID 5 traffic counters ###
	Get all DL counter value for the Corresponding 5QI via admin_cli    5QI_ID=5
	Get all CB012119 Part counter value for the Corresponding 5QI via admin_cli
	Set DL KPI Calculation formula
	Set CB012119 KPI Calculation formula
	check DL kpi for 5QI-5 traffic condition
	hang up VoNR and ViNR call    ue_index=${0}
	[Teardown]   Run keywords     Detach UE   ue_index=${0}   AND   Detach UE   ue_index=${1}

Check kpi or counters for F1 related counter
    should be true    ${value_M55350C00025}==0
    should be true    ${value_M55159C00003}==0

check DL kpi for 5QI-7 big traffic condition
    Check kpi or counters for F1 related counter
	should be true     10<${NR_5906a}<80
	should be true     10<${NR_2330a}<80
	should be true     0<${NR_5907a}<250
	should be true     0<${NR_2332a}<250
	should be true     ${NR_2331a}>90
	#should be true     20<${NR_6096a}<50
	should be true     1<${NR_6099a}<8

check DL kpi for 5QI-7 small traffic condition
    Check kpi or counters for F1 related counter
	should be true     9<${NR_5906a}<25
	should be true     0<${NR_5907a}<5
	should be true     ${NR_2331a}>90
	#should be true     0<${NR_6096a}<5
	should be true     1<${NR_6098a}<8
	should be true     1<${NR_6099a}<8

check DL kpi for 5QI-4 traffic condition

	should be true    ${value_M55158C00001}==0
	should be true    ${value_M55158C00002}==0
	should be true    ${value_M55158C00003}==0
    Check kpi or counters for F1 related counter
	#should be true     0<${NR_2332a}<5
	should be true     0<${NR_2334a}<5
	#should be true     0<${NR_2336a}<5
	should be true     0<${NR_6095a}<10
	#should be true     0<${NR_6096a}<10
	should be true     1<${NR_6098a}<6
	should be true     1<${NR_6099a}<10

check DL kpi for 5QI-1 traffic condition
    should be true    ${value_M55158C00001}==0
	should be true    ${value_M55158C00002}==0
	should be true    ${value_M55158C00003}==0
    Check kpi or counters for F1 related counter
	should be true     0<${NR_2332a}<2
	should be true     0<${NR_2334a}<5
	#should be true     5<${NR_6096a}<25
	should be true     5<${NR_6098a}<25
	should be true     0<${NR_6099a}<6
check DL kpi for 5QI-5 traffic condition

    Check kpi or counters for F1 related counter
   	should be true      5<${NR_2330a}<25
   	should be true      0<${NR_2332a}<5
   	should be true      0<${NR_2334a}<2
   	should be true      0<${NR_2336a}<2
	#should be true     5<${NR_6096a}<25
	should be true     10<${NR_6098a}<26
	should be true     0<${NR_6099a}<6
check DL kpi for 5QI-2 traffic condition
    should be true    ${value_M55158C00001}==0
	should be true    ${value_M55158C00002}==0
	should be true    ${value_M55158C00003}==0
    Check kpi or counters for F1 related counter
	should be true     0<${NR_2332a}<100
	should be true     0<${NR_2334a}<25
	should be true     0<${NR_2336a}<25
	#should be true     5<${NR_6096a}<10
	should be true     5<${NR_6098a}<15
	should be true     0<${NR_6099a}<5
check DL kpi for 5QI-8 small traffic condition
    Check kpi or counters for F1 related counter
	should be true     5<${NR_5906a}<25
	should be true     5<${NR_2330a}<25
	should be true     0<${NR_5907a}<1
	should be true     0<${NR_2332a}<1
	should be true     ${NR_2331a}>90
	should be true     0<${NR_5909a}<10
	should be true     0<${NR_2334a}<10
	should be true     50<${NR_59010a}<150
	should be true     50<${NR_2335a}<150
	should be true     0<${NR_59011a}<20
	should be true     0<${NR_2336a}<15
	#should be true     5<${NR_6096a}<130
	should be true     10<${NR_6098a}<150
	should be true     0<${NR_6099a}<5
check PART-C UL kpi for 5QI-7

	should be true     0<${NR_5908a}<2
	should be true     0<${NR_2333a}<2

check PART-C UL kpi for 5QI-4
    should be true     0<${NR_5908a}<2
	should be true     0.00001<${NR_2333a}<0.1
check PART-E UL kpi
	should be true     0<${NR_5912a}<5
		should be true     0<${NR_5913a}<15


*** Settings ***
Documentation
...    author: yuanyuan liu
...    contact: yuanyuan.liu@nokia-sbell.com
...    squad group: MMW3
...    feature : CB012119

Force Tags    CRT_TRUNK

Suite Setup       Run Keywords    robot_common_operations.Common Suite Setup
Suite Teardown    Run Keywords    CB012119 SA keep goldenSCF   AND   robot_common_operations.Common Suite Teardown
Test Setup        robot_common_operations.Common Case Setup    allowed_faults_ids=7300    fail_with_alarms=${False}
Test Teardown     Run Keywords    robot_common_operations.Common Case Teardown

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/ERR_WRN_Check.robot
Resource    ./Resources/CB012119_common_keywords.robot
Variables   ./Resources/CB012119_scf_modify_TMO.py



*** Variables ***
${scf_file_template_path}    ${commissionings_path}/HGZ/${testline_name}
${5QI_value}    7
${MR_NR_CELL_NAME}     ${MR_NR_BTS_NAME}/NRCELL-21
${MR_LTE_CELL_NAME}    MRBTS-2077/LNBTS-2077/LNCEL-11
${ue_index}     1
${UTE_syslogs_path}     /home/ute/BTS_logs

*** Test Cases ***
[1]CB012119-A_01_DL_Air-Interface_delay_for_AM_RLC_FR1_TDD_SA
    [Tags]    HAZ3_T03
    CB012119 SA case Preparation
    Run Keyword And Ignore error   Start BTSlogs Collection In Log Server
    ...      Test_PC_IP=${Test_PC_IP}    Test_PC_username=${Test_PC_username}
    ...      Test_PC_password=${Test_PC_password}
    ...      btslog_path=/tmp/btslog2      btslog_launcher=/opt/btslog/btslog_launcher
    ...      btslog_launcher_path=/opt/btslog/btslog
    Andriod UE adb reboot    ue_index=${1}
    Lock LTE Cell to avoid UE attached to 4G
    Adjust HBTE ATT Values    ${ATTENUATION_VALUE_update1}
    run keyword and continue on failure    5QI-7 Big traffic condition      ${ue_index}
    run keyword and continue on failure    5QI-7 small traffic condition      ${ue_index}
    Run Keyword And Ignore error       Stop BTSlogs Collection And Download Logs To Log Server
    Run Keyword And Continue On Failure     Check ERR Or WRN From Syslog
    ...      sys_logs_path=${UTE_syslogs_path}      UTE_logs_path=${UTE_logs_path}
    ...      base_file=${Base_ERR_WRN_csv_path}
    ...      Expected_ERR_WRN_deviation=0.1      Delete_old_ERR_WRN=15
    ...      Fail_Case=${False}       Clear_log=True
    ...      FilesSystem=/dev/vda2      Max_used_space_ratio=0.85
    [Teardown]    Run Keywords    robot_common_operations.Common Case Teardown
    ...    AND   CI_interface.Common Case Teardown

[1]CB012119-B_03_DL_Air-Interface_delay_for_UM_RLC_PMQAP_SA
    [Tags]    HAZ3_T03
    CB012119 SA case Preparation
    Run Keyword And Ignore error   Start BTSlogs Collection In Log Server
    ...      Test_PC_IP=${Test_PC_IP}    Test_PC_username=${Test_PC_username}
    ...      Test_PC_password=${Test_PC_password}
    ...      btslog_path=/tmp/btslog2      btslog_launcher=/opt/btslog/btslog_launcher
    ...      btslog_launcher_path=/opt/btslog/btslog
    Andriod UE adb reboot    ue_index=${1}
    Lock LTE Cell to avoid UE attached to 4G
    Adjust HBTE ATT Values    ${ATTENUATION_VALUE_update1}
    UE Prepare    ue_index=${ue_index}
	Attach UE     ue_index=${ue_index}
    UE start traffic    tp_direction=dl    dl_tp=195M    iperf_port_dl=43207    ue_index=${ue_index}
    Wait for one counter period     interval_time=5min
	Log To Console    \n ### get B counters when only AM data ###
    Get all DL counter value for the Corresponding 5QI via admin_cli    5QI_ID=${7}
	Set DL KPI Calculation formula
	Check B-AM KPI
    UE start traffic    tp_direction=dl    dl_tp=1M  iperf_port_dl=43204      ue_index=${ue_index}
    Wait for one counter period     interval_time=5min
	Log To Console    \n ### get B counters when UM data ###
    Get all DL counter value for the Corresponding 5QI via admin_cli    5QI_ID=${4}
	Set DL KPI Calculation formula
	Check B-UM KPI
    power_ue.Stop traffic   direction=dl    ue_index=${ue_index}    ue_type=${UE_TYPE}   iperf_port=43207
    power_ue.Stop traffic   direction=dl    ue_index=${ue_index}    ue_type=${UE_TYPE}   iperf_port=43204
    Detach UE   ue_index=${ue_index}
	Run Keyword And Ignore error       Stop BTSlogs Collection And Download Logs To Log Server
    Run Keyword And Continue On Failure     Check ERR Or WRN From Syslog
    ...      sys_logs_path=${UTE_syslogs_path}      UTE_logs_path=${UTE_logs_path}
    ...      base_file=${Base_ERR_WRN_csv_path}
    ...      Expected_ERR_WRN_deviation=0.1      Delete_old_ERR_WRN=15
   ...       Fail_Case=${False}       Clear_log=True
    ...      FilesSystem=/dev/vda2      Max_used_space_ratio=0.85
    [Teardown]    Run Keywords    robot_common_operations.Common Case Teardown
    ...    AND   CI_interface.Common Case Teardown


[1]CB012119-C_01_DL_RLC_SDU_CA_delay_FR1_TDD_SA
    [Tags]    HAZ3_T03
    CB012119 SA case Preparation
    Run Keyword And Ignore error   Start BTSlogs Collection In Log Server
    ...      Test_PC_IP=${Test_PC_IP}    Test_PC_username=${Test_PC_username}
    ...      Test_PC_password=${Test_PC_password}
    ...      btslog_path=/tmp/btslog2      btslog_launcher=/opt/btslog/btslog_launcher
    ...      btslog_launcher_path=/opt/btslog/btslog
    Andriod UE adb reboot    ue_index=${1}
    Lock LTE Cell to avoid UE attached to 4G
    Adjust HBTE ATT Values    ${ATTENUATION_VALUE_update1}
	run keyword and continue on failure    5QI-4 Big traffic condition      ${ue_index}
 	run keyword and continue on failure    5QI-4 small traffic condition      ${ue_index}
	Run Keyword And Ignore error       Stop BTSlogs Collection And Download Logs To Log Server
    Run Keyword And Continue On Failure     Check ERR Or WRN From Syslog
    ...      sys_logs_path=${UTE_syslogs_path}      UTE_logs_path=${UTE_logs_path}
    ...      base_file=${Base_ERR_WRN_csv_path}
    ...      Expected_ERR_WRN_deviation=0.1      Delete_old_ERR_WRN=15
   ...       Fail_Case=${False}       Clear_log=True
    ...      FilesSystem=/dev/vda2      Max_used_space_ratio=0.85
    [Teardown]    Run Keywords    robot_common_operations.Common Case Teardown
    ...    AND   CI_interface.Common Case Teardown


[1]CB012119-D_02_DL_Average_IP_latency_PMQAP_FR1_TDD_SA
    [Tags]    HAZ3_T03
    CB012119 SA case Preparation
    Run Keyword And Ignore error   Start BTSlogs Collection In Log Server
    ...      Test_PC_IP=${Test_PC_IP}    Test_PC_username=${Test_PC_username}
    ...      Test_PC_password=${Test_PC_password}
    ...      btslog_path=/tmp/btslog2      btslog_launcher=/opt/btslog/btslog_launcher
    ...      btslog_launcher_path=/opt/btslog/btslog
    Lock LTE Cell to avoid UE attached to 4G
    Andriod UE adb reboot    ue_index=${0}
    Andriod UE adb reboot    ue_index=${1}
    Adjust HBTE ATT Values    ${ATTENUATION_VALUE_update1}
    run keyword and continue on failure    5QI-1 and 5QI-2 and 5QI-5 traffic condition for TMO
    run keyword and continue on failure    5QI-8 small traffic condition      ${ue_index}
	Run Keyword And Ignore error       Stop BTSlogs Collection And Download Logs To Log Server
    Run Keyword And Continue On Failure     Check ERR Or WRN From Syslog
    ...      sys_logs_path=${UTE_syslogs_path}      UTE_logs_path=${UTE_logs_path}
    ...      base_file=${Base_ERR_WRN_csv_path}
    ...      Expected_ERR_WRN_deviation=0.1      Delete_old_ERR_WRN=15
   ...       Fail_Case=${False}       Clear_log=True
    ...      FilesSystem=/dev/vda2      Max_used_space_ratio=0.85
    [Teardown]    Run Keywords    robot_common_operations.Common Case Teardown
    ...    AND   CI_interface.Common Case Teardown


[1]CB012119-E_05_Average_UL_over_Air_Interface_delay_for_UL_packet_inter-working_CB008124
    [Tags]    HAZ3_T03
    CB012119 SA case Preparation
    Run Keyword And Ignore error   Start BTSlogs Collection In Log Server
    ...      Test_PC_IP=${Test_PC_IP}    Test_PC_username=${Test_PC_username}
    ...      Test_PC_password=${Test_PC_password}
    ...      btslog_path=/tmp/btslog2      btslog_launcher=/opt/btslog/btslog_launcher
    ...      btslog_launcher_path=/opt/btslog/btslog
    Lock LTE Cell to avoid UE attached to 4G
    Adjust HBTE ATT Values    ${ATTENUATION_VALUE_update1}
    Modify NIDD parameter on gnb   parameters_to_update=${Disable_UL256QAM}
	Connect to gnb coam via ssl
    ${Active_SW_version}    Get Active SW Version
    ${stream}    get stream from version    ${Active_SW_version}
	set suite variable     ${stream}
	Andriod UE adb reboot    ue_index=${1}
    UE Prepare            ue_index=${1}
	Attach UE            ue_index=${1}
    UE start traffic    tp_direction=ul    ul_tp=50M    iperf_port_ul=43107    ue_index=${1}
    Wait for one counter period     interval_time=5min
	Log To Console    \n ### get E counters in non-CG mode ###
	run keyword and continue on failure    Get PART-C UL counter value for the Corresponding 5QI via admin_cli   5QI_ID=7
	run keyword and continue on failure    Set Part-C UL KPI Calculation formula
	run keyword and continue on failure    Check E counters in nonCG mode
    power_ue.Stop traffic   direction=ul    ue_index=${1}    ue_type=${UE_TYPE}   iperf_port=43107
    sleep     300s
    UE start traffic    tp_direction=ul    ul_tp=1800k    iperf_port_ul=43107    ue_index=${1}
   	Wait for one counter period     interval_time=5min
	Log To Console    \n ### get E counters in CG mode ###
	run keyword and continue on failure    Get PART-C UL counter value for the Corresponding 5QI via admin_cli   5QI_ID=7
	run keyword and continue on failure    Set Part-C UL KPI Calculation formula
	#run keyword if    '${stream}'=='SBTS00' or '${stream}'=='SBTS25R3'    Check E counters in CG mode impact by CB008600
	#run keyword if    '${stream}'!='SBTS00' and '${stream}'!='SBTS25R3'    Check E counters in CG mode
    Check E counters in CG mode impact by CB008600
    power_ue.Stop traffic   direction=ul    ue_index=${1}    ue_type=${UE_TYPE}   iperf_port=43107
    Detach UE   ue_index=${1}
	Run Keyword And Ignore error       Stop BTSlogs Collection And Download Logs To Log Server
    Run Keyword And Continue On Failure     Check ERR Or WRN From Syslog
    ...      sys_logs_path=${UTE_syslogs_path}      UTE_logs_path=${UTE_logs_path}
    ...      base_file=${Base_ERR_WRN_csv_path}
    ...      Expected_ERR_WRN_deviation=0.1      Delete_old_ERR_WRN=15
   ...       Fail_Case=${False}       Clear_log=True
    ...      FilesSystem=/dev/vda2      Max_used_space_ratio=0.85
    [Teardown]    Run Keywords    robot_common_operations.Common Case Teardown
    ...    AND   CI_interface.Common Case Teardown


[1]CB012119-F_03_UL_RLC_packet_delay_PMQAP_FR1_FDD
    [Tags]    HAZ3_T03
    CB012119 SA case Preparation
    Run Keyword And Ignore error   Start BTSlogs Collection In Log Server
    ...      Test_PC_IP=${Test_PC_IP}    Test_PC_username=${Test_PC_username}
    ...      Test_PC_password=${Test_PC_password}
    ...      btslog_path=/tmp/btslog2      btslog_launcher=/opt/btslog/btslog_launcher
    ...      btslog_launcher_path=/opt/btslog/btslog
    Andriod UE adb reboot    ue_index=${1}
    Lock LTE Cell to avoid UE attached to 4G
    Adjust HBTE ATT Values    ${ATTENUATION_VALUE_update1}
    UE Prepare            ue_index=${ue_index}
	Attach UE            ue_index=${ue_index}
    UE start traffic    tp_direction=ul    ul_tp=100M    iperf_port_ul=43107    ue_index=${ue_index}
	UE start traffic    tp_direction=ul    ul_tp=10M    iperf_port_ul=43104     ue_index=${ue_index}
	Wait for one counter period     interval_time=5min
	run keyword and continue on failure    Get PART-C UL counter value for the Corresponding 5QI via admin_cli   5QI_ID=7
	run keyword and continue on failure    Set Part-C UL KPI Calculation formula
	run keyword and continue on failure    check PART-C UL kpi for 5QI-7
	Wait for one counter period     interval_time=5min
	run keyword and continue on failure    Get PART-C UL counter value for the Corresponding 5QI via admin_cli   5QI_ID=4
	run keyword and continue on failure    Set Part-C UL KPI Calculation formula
	run keyword and continue on failure    check PART-C UL kpi for 5QI-4
	Detach UE    ue_index=${ue_index}
	Run Keyword And Ignore error       Stop BTSlogs Collection And Download Logs To Log Server
    Run Keyword And Continue On Failure     Check ERR Or WRN From Syslog
    ...      sys_logs_path=${UTE_syslogs_path}      UTE_logs_path=${UTE_logs_path}
    ...      base_file=${Base_ERR_WRN_csv_path}
    ...      Expected_ERR_WRN_deviation=0.1      Delete_old_ERR_WRN=15
   ...       Fail_Case=${False}       Clear_log=True
    ...      FilesSystem=/dev/vda2      Max_used_space_ratio=0.85
    [Teardown]    Run Keywords    robot_common_operations.Common Case Teardown
    ...    AND   CI_interface.Common Case Teardown


[1]CB012119-H_03_Modification_of_DL_PDCP_delay_counter_basic_PMQAP_FDD_SA
    CB012119 SA case Preparation
    Run Keyword And Ignore error   Start BTSlogs Collection In Log Server
    ...      Test_PC_IP=${Test_PC_IP}    Test_PC_username=${Test_PC_username}
    ...      Test_PC_password=${Test_PC_password}
    ...      btslog_path=/tmp/btslog2      btslog_launcher=/opt/btslog/btslog_launcher
    ...      btslog_launcher_path=/opt/btslog/btslog
    Adjust HBTE ATT Values    ${ATTENUATION_VALUE_update1}
    UE Prepare    ue_index=${ue_index}
	Attach UE     ue_index=${ue_index}
    UE start traffic    tp_direction=dl    dl_tp=5M   iperf_port_dl=43208   ue_index=${ue_index}
    UE start traffic    tp_direction=dl    dl_tp=30M    iperf_port_dl=43207    ue_index=${ue_index}
    UE start traffic    tp_direction=dl    dl_tp=1M  iperf_port_dl=43204      ue_index=${ue_index}
    Wait for one counter period     interval_time=5min
	Log To Console    \n ### get H counters before handover ###
	Get H counter value for the Corresponding 5QI via admin_cli
	Set H KPI
	Check H KPI
	Set Suite Variable    ${CB012119_H_BFHO}   ${CB012119_H}
	Set Suite Variable    ${CB012119_H_PMQAP7_BFHO}   ${CB012119_H_PMQAP7}
	Set Suite Variable    ${CB012119_H_PMQAP8_BFHO}   ${CB012119_H_PMQAP8}
	Set Suite Variable    ${CB012119_H_PMQAP4_BFHO}   ${CB012119_H_PMQAP4}
    Adjust HBTE ATT Values    ${ATTENUATION_VALUE_update2}
    sleep     10s
    Adjust HBTE ATT Values    ${ATTENUATION_VALUE_update3}
    sleep     10s
    Adjust HBTE ATT Values    ${ATTENUATION_VALUE_update4}
    sleep     10s
    Adjust HBTE ATT Values    ${ATTENUATION_VALUE_update5}
    Wait for one counter period     interval_time=5min
	Log To Console    \n ### get H counters before handover ###
	${MR_NR_CELL_NAME}    set variable      ${MR_NR_BTS_NAME}/NRCELL-22
	Set Suite Variable      ${MR_NR_CELL_NAME}
	Get H counter value for the Corresponding 5QI via admin_cli
	Set H KPI
    Check counters filter by ARP
	Check H KPI
	Set Suite Variable    ${CB012119_H_AFHO}   ${CB012119_H}
	Set Suite Variable    ${CB012119_H_PMQAP7_AFHO}   ${CB012119_H_PMQAP7}
	Set Suite Variable    ${CB012119_H_PMQAP8_AFHO}   ${CB012119_H_PMQAP8}
	Set Suite Variable    ${CB012119_H_PMQAP4_AFHO}   ${CB012119_H_PMQAP4}
	check counter before and after handover
	power_ue.Stop traffic   direction=dl    ue_index=${ue_index}    ue_type=${UE_TYPE}   iperf_port=43208
    power_ue.Stop traffic   direction=dl    ue_index=${ue_index}    ue_type=${UE_TYPE}   iperf_port=43207
    power_ue.Stop traffic   direction=dl    ue_index=${ue_index}    ue_type=${UE_TYPE}   iperf_port=43204
	Run Keyword And Ignore error       Stop BTSlogs Collection And Download Logs To Log Server
    Run Keyword And Continue On Failure     Check ERR Or WRN From Syslog
    ...      sys_logs_path=${UTE_syslogs_path}      UTE_logs_path=${UTE_logs_path}
    ...      base_file=${Base_ERR_WRN_csv_path}
    ...      Expected_ERR_WRN_deviation=0.1      Delete_old_ERR_WRN=15
   ...       Fail_Case=${False}       Clear_log=True
    ...      FilesSystem=/dev/vda2      Max_used_space_ratio=0.85
    [Teardown]    Run Keywords    robot_common_operations.Common Case Teardown   AND    Case teardown    ${ue_index}
    ...    AND   CI_interface.Common Case Teardown



*** Keywords ***
5QI-1 and 5QI-2 and 5QI-5 traffic condition for TMO
	UE Prepare    ue_index=${0}
	Attach UE     ue_index=${0}
	UE Prepare    ue_index=${1}
	Attach UE     ue_index=${1}
    Make a VoNR call     ue_index=${0}    phone_number=+8613032996558
	answer VoNR call    ue_index=${1}
	Wait for one counter period     interval_time=5min
	Log To Console    \n ### 5QI_ID 1 traffic counters ###
	Get all DL counter value for the Corresponding 5QI via admin_cli    5QI_ID=1
	Set DL KPI Calculation formula
	Run Keyword And Continue On Failure    check DL kpi for 5QI-1 VONR traffic condition
	Log To Console    \n ### 5QI_ID 5 traffic counters ###
	Get all DL counter value for the Corresponding 5QI via admin_cli    5QI_ID=5
	Set DL KPI Calculation formula
    switch ViNR to VoNR call     ue_index=${0}
    answer ViNR call     ue_index=${1}
    Wait for one counter period     interval_time=5min
	Log To Console    \n ### 5QI_ID 1 traffic counters ###
	Get all DL counter value for the Corresponding 5QI via admin_cli    5QI_ID=1
	Set DL KPI Calculation formula
	Run Keyword And Continue On Failure    check DL kpi for 5QI-1 VINR traffic condition
	Log To Console    \n ### 5QI_ID 2 traffic counters ###
	Get all DL counter value for the Corresponding 5QI via admin_cli    5QI_ID=2
	Set DL KPI Calculation formula
	Run Keyword And Continue On Failure    check DL kpi for 5QI-2 traffic condition
	Log To Console    \n ### 5QI_ID 5 traffic counters ###
	Get all DL counter value for the Corresponding 5QI via admin_cli    5QI_ID=5
	Set DL KPI Calculation formula
	Run Keyword And Continue On Failure    check DL kpi for 5QI-5 traffic condition
	hang up VoNR and ViNR call    ue_index=${0}
	[Teardown]   Run keywords     Detach UE   ue_index=${0}   AND   Detach UE   ue_index=${1}

Lock LTE Cell to avoid UE attached to 4G
    Modify NIDD parameter on gnb   parameters_to_update=${Lock_LNCEL11}
	Sleep    10

Unlock LTE Cell to Normal
    Modify NIDD parameter on gnb   parameters_to_update=${UnLock_LNCEL11}
	Sleep    10


Get H counter value for the Corresponding 5QI via admin_cli
    Log To Console    Counter is not updated so quickly wait for more than 30s
	sleep    30s
	Connect to gnb coam via ssl
    ${Active_SW_version}    Get Active SW Version
    ${stream}    get stream from version    ${Active_SW_version}
	run keyword if    '${stream}'=='SBTS24R1'    set test variable   ${MR_NR_CELL_NAME}    CELLS/NRCELL-1
	log to console      \n ########CB012119-H Counters####
	${value_M55350C00023}    Get the latest PM Counter via admin_cli for CB012119    counter_id=M55350C00023
	...   dic_path=BTS/${MR_NR_CELL_NAME}/PDCPC
	Set Suite variable    ${value_M55350C00023}
	${value_M55350C00024}    Get the latest PM Counter via admin_cli for CB012119    counter_id=M55350C00024
	...   dic_path=BTS/${MR_NR_CELL_NAME}/PDCPC
	Set Suite variable    ${value_M55350C00024}
 	${value_M55159C00001_5qi7}    Get the latest PM Counter via admin_cli for CB012119    counter_id=M55159C00001
	...   dic_path=BTS/${MR_NR_CELL_NAME}/NRPMQAP-7/PDLTQ
	Set Suite variable    ${value_M55159C00001_5qi7}
	${value_M55159C00002_5qi7}    Get the latest PM Counter via admin_cli for CB012119    counter_id=M55159C00002
	...   dic_path=BTS/${MR_NR_CELL_NAME}/NRPMQAP-7/PDLTQ
	Set Suite variable    ${value_M55159C00002_5qi7}
 	${value_M55159C00001_5qi8}    Get the latest PM Counter via admin_cli for CB012119    counter_id=M55159C00001
	...   dic_path=BTS/${MR_NR_CELL_NAME}/NRPMQAP-8/PDLTQ
	Set Suite variable    ${value_M55159C00001_5qi8}
	${value_M55159C00002_5qi8}    Get the latest PM Counter via admin_cli for CB012119    counter_id=M55159C00002
	...   dic_path=BTS/${MR_NR_CELL_NAME}/NRPMQAP-8/PDLTQ
	Set Suite variable    ${value_M55159C00002_5qi8}
	 ${value_M55159C00001_5qi4}    Get the latest PM Counter via admin_cli for CB012119    counter_id=M55159C00001
	...   dic_path=BTS/${MR_NR_CELL_NAME}/NRPMQAP-4/PDLTQ
	Set Suite variable    ${value_M55159C00001_5qi4}
	${value_M55159C00002_5qi4}    Get the latest PM Counter via admin_cli for CB012119    counter_id=M55159C00002
	...   dic_path=BTS/${MR_NR_CELL_NAME}/NRPMQAP-4/PDLTQ
	Set Suite variable    ${value_M55159C00002_5qi4}
	log to console      \n ########Add counters for 04330708 EDA####
 	${value_M55159C00001_ARP7}    Get the latest PM Counter via admin_cli for CB012119    counter_id=M55159C00001
	...   dic_path=BTS/${MR_NR_CELL_NAME}/NRPMQAP-20/PDLTQ
	Set Suite variable    ${value_M55159C00001_ARP7}
	${value_M55159C00002_ARP7}    Get the latest PM Counter via admin_cli for CB012119    counter_id=M55159C00002
	...   dic_path=BTS/${MR_NR_CELL_NAME}/NRPMQAP-20/PDLTQ
	Set Suite variable    ${value_M55159C00002_ARP7}
	${value_M55159C00001_ARP8}    Get the latest PM Counter via admin_cli for CB012119    counter_id=M55159C00001
	...   dic_path=BTS/${MR_NR_CELL_NAME}/NRPMQAP-21/PDLTQ
	Set Suite variable    ${value_M55159C00001_ARP8}
	${value_M55159C00002_ARP8}    Get the latest PM Counter via admin_cli for CB012119    counter_id=M55159C00002
	...   dic_path=BTS/${MR_NR_CELL_NAME}/NRPMQAP-21/PDLTQ
	Set Suite variable    ${value_M55159C00002_ARP8}

Set H KPI
     Initialize the kpi value to zero
	 ${CB012119_H_tmp}   Run keyword if    ${value_M55350C00024}!=0     evaluate    ${value_M55350C00023}/(${value_M55350C00024}*1000)
	 Run keyword if    ${CB012119_H_tmp}!=0 and ${CB012119_H_tmp}!=None      Set Suite Variable    ${CB012119_H}   ${CB012119_H_tmp}
	 ${CB012119_H_PMQAP7_tmp}   Run keyword if    ${value_M55159C00002_5qi7}!=0
	 ...     evaluate    ${value_M55159C00001_5qi7}/(${value_M55159C00002_5qi7}*1000)
	 Run keyword if    ${CB012119_H_PMQAP7_tmp}!=${0} and ${CB012119_H_PMQAP7_tmp}!=${None}
	 ...     Set Suite Variable    ${CB012119_H_PMQAP7}   ${CB012119_H_PMQAP7_tmp}
	 ${CB012119_H_PMQAP8_tmp}   Run keyword if    ${value_M55159C00002_5qi8}!=0
	 ...     evaluate    ${value_M55159C00001_5qi8}/(${value_M55159C00002_5qi8}*1000)
	 Run keyword if    ${CB012119_H_PMQAP8_tmp}!=${0} and ${CB012119_H_PMQAP8_tmp}!=${None}
	 ...     Set Suite Variable    ${CB012119_H_PMQAP8}   ${CB012119_H_PMQAP8_tmp}
	 ${CB012119_H_PMQAP4_tmp}   Run keyword if    ${value_M55159C00002_5qi4}!=0
	 ...     evaluate    ${value_M55159C00001_5qi4}/(${value_M55159C00002_5qi4}*1000)
	 Run keyword if    ${CB012119_H_PMQAP4_tmp}!=${0} and ${CB012119_H_PMQAP4_tmp}!=${None}
	 ...     Set Suite Variable    ${CB012119_H_PMQAP4}   ${CB012119_H_PMQAP4_tmp}

Check H KPI
	should be true     0<${CB012119_H}<2
	should be true     0<${CB012119_H_PMQAP7}<2
	should be true     0<${CB012119_H_PMQAP8}<2
	should be true     0<${CB012119_H_PMQAP4}<2

Check counters filter by ARP
	should be true     ${value_M55159C00001_ARP7}<${value_M55350C00023}
	should be true     ${value_M55159C00002_ARP7}<${value_M55350C00024}
	should be true     ${value_M55159C00001_ARP8}<${value_M55350C00023}
	should be true     ${value_M55159C00002_ARP8}<${value_M55350C00024}
    Should be True      ${value_M55350C00023}*0.9<${value_M55159C00001_ARP7}+${value_M55159C00001_ARP8}<${value_M55350C00023}*1.1
	Should be True      ${value_M55350C00024}*0.9<${value_M55159C00002_ARP7}+${value_M55159C00002_ARP8}<${value_M55350C00024}*1.1

check counter before and after handover
     Should be True      ${CB012119_H_BFHO}*0.7<${CB012119_H_AFHO}<${CB012119_H_BFHO}*1.3
     Should be True      ${CB012119_H_PMQAP8_BFHO}*0.7<${CB012119_H_PMQAP8_AFHO}<${CB012119_H_PMQAP8_BFHO}*1.3
     Should be True      ${CB012119_H_PMQAP7_BFHO}*0.7<${CB012119_H_PMQAP7_AFHO}<${CB012119_H_PMQAP7_BFHO}*1.3
     Should be True      ${CB012119_H_PMQAP4_BFHO}*0.7<${CB012119_H_PMQAP4_AFHO}<${CB012119_H_PMQAP4_BFHO}*1.3



Case teardown
    [Arguments]    ${ue_index}
    Detach UE     ue_index=${ue_index}
    Adjust HBTE ATT Values    ${ATTENUATION_VALUE_update1}
    Run Keyword If Test Failed    Test Case teardown in case failure
    Run Keyword And Ignore Error      Unlock LTE Cell to Normal

Check B-AM KPI
	should be true     ${CB012119_B}==0
	should be true     ${CB012119_B_PMQAP}==0
	#should be true     0<${CB012119_A}<60
	#should be true     0<${CB012119_A_PMQAP}<60

Check B-UM KPI
	should be true     0<${CB012119_B}<30
	should be true     0<${CB012119_B_PMQAP}<30
	#should be true     0<${CB012119_A}<60
	#should be true     ${CB012119_A_PMQAP}==0

Check E counters in CG mode
	should be true     0<${CB012119_F}<5
	should be true     0<${CB012119_FPMQAP}<5
	log to console      \n #######30000 is the average counter value in nonCG in same TP####
	should be true     ${value_M55310C00013}<30000
	should be true     ${value_M55158C00015}<30000

Check E counters in CG mode impact by CB008600
	should be true     0<${CB012119_F}<5
	should be true     0<${CB012119_FPMQAP}<5

Check E counters in nonCG mode
	should be true     0<${CB012119_E}<10
	should be true     0<${CB012119_E_PMQAP}<10
	should be true     0<${CB012119_F}<5
	should be true     0<${CB012119_F_PMQAP}<5

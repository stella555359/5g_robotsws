*** Settings ***
Documentation
...   author: Partheeban Asokan
...   contact: partheeban.asokan@nokia.com
...   Description: Test Suite for CR-CRT

Library		Process
Library		Collections
Library		OperatingSystem    WITH NAME     os
Library		taf.sw.dcap.rd       WITH NAME     dcap
Library		taf.gnb.oam.coam.vdu    WITH NAME    admindu
Library		taf.gnb.oam.coam.cu    WITH NAME    admincu
Library		DateTime
Library		taf.transport.ssh    WITH NAME    ssh
Library		SSHLibrary
Library		BuiltIn
Library		taf.sw.scout    WITH NAME    scout
Library		ute_fsmaccess
Library		String
Library		taf.file.pack
Library		taf.collectors.simple    WITH NAME    simple
Library		testsuite.Bangalore.ORAN.resources.python.ta_ultracaller    WITH NAME    ta_ultracaller
Resource	./testsuite/Bangalore/ORAN/T04/resources/T04_CIT_common_resource.robot
Resource	./testsuite/Bangalore/ORAN/T04/resources/reportingportal_Keywords.robot
Resource	./testsuite/Bangalore/ORAN/T04/resources/alarm.robot

Force Tags	CB012173	FL00	QCD_MN_RAN	QCP_RAN_VRF
Test Setup    Test setup
Test TearDown    test teardown
Suite Setup		Suite_Setup
Suite Teardown	Suite_Teardown

*** Variables ***

@{Rollback_build}=	SBTS24R2
${BTS_ADDRESS}	10.58.230.179
${ssh_port}           443
${BTS_ID}	30613
${log_alias}    btslog
${bool}=    True
${str}=  SBTS00
${LOGS_PATH}=    /home/ute/logs
${BTS_path}=    /home/ute/results
${VM_HOST_IP}=  10.58.238.71
${VM_username}=  ute
${VM_Password}=  BT5l@bus3rl0g1n
${BTSLOG_Path_for_validation}	/tmp/btslog2
${host_vCU}=  10.58.230.178
${host_vDU}=  10.58.230.179
${PORT}=  443
${USER}=  Nemuadmin
${PWD}=  Nokia@123
${btsremoteip}=    10.58.230.178
${sw_release}=    SBTS24R3
${DCAP_host}                10.41.209.115
${UE_PC_IP}                 10.43.13.195
${Windows_user}             inbabtslabuser
${Windows_pass}             BT5l@bus3rl0g1n
${uepc_Log_path}            C://Users//inbabtslabuser//Documents//Automation_logs
${dcap_log_timeout}=	800s
${ABSTRACT_LIB_CONFIG}=	/home/ute/testline_configuration_5G/Bangalore/1-2-CLOUD963/ta_ue_config.yaml
@{deviation_dl}=        60
@{deviation_ul}=        80
@{throughput_dl}=       250
@{throughput_ul}=       60
@{deviation2_dl}=        60
@{deviation2_ul}=        80
@{throughput2_dl}=       800
@{throughput2_ul}=       80
${wait_for_transfer}	True
@{UE_alias}=	UE3
@{capabilities}=	Legacy_3
${dcapuser_name}    utfuser
${dcap_password}    utfadmin!
${PATH}    /home/ute/Documents/Automation_run_1
${testcase_name}=    CB012173
@{direction_dl}=  dl
@{direction_ul}=  ul
@{duration}=  700s
@{timeout}	180
@{tcpcalltype}=    TCP
@{udpcalltype}=    UDP
${packet_size}=  1400
${tput}=   100Mbits/sec
@{custom_profile}=     controlPlane5gVdu	Snapshot
@{Cell_list1}=    2    3    4    7    8    9
@{Cell_list2}=    1    2    3    4    7    8    9
@{Cell_list3}=    1
@{Cell_list4}=    3
#############
## QC TAGS ##
#############

&{[1]CB008709_001_Slice_aware_uplink_scheduler_Activated}
...    QC_ID_VDU=QC_163923

*** Test Cases ***
[1]CB008709_001_Slice_aware_uplink_scheduler_Activated
	[Setup]    Test Setup
	Start DCAP Trace
	Parameter_recommissioning_actRed
	Attach and Tput Test    ${throughput_dl}    ${throughput_ul}    ${deviation_dl}    ${deviation_ul}
	Lock cells group    ${Cell_list3}
	Unlock cells group    ${Cell_list4}
	Attach and Tput Test    ${throughput_dl}    ${throughput_ul}    ${deviation_dl}    ${deviation_ul}
	Parameter_recommissioning_MFBI_disable				             # EDA scenario for PR829822
	Parameter_recommissioning_MFBI_enable                                        # EDA scenario for PR829822
	[Teardown]	run keywords      test teardown        AND    Set QC_Tag_vdu

*** Keywords ***
Lock cells group
    [Arguments]   ${cell_list}
    Log To Console    \n --Locking Cells -- \n
    ${cell_ope_status}=    admindu.Lock Vdu Cell Groups	cell_groups_id_list=${cell_list}    vdu_connection=vDU
    Sleep     30s
    ${cell_status}=    admindu.get_operation_state_of_locking_vdu_cell_groups    operation_groups_id=${cell_ope_status['id']}
    ...    vdu_connection=vDU
    Run keyword And Continue On Failure    Should Be Equal    ${cell_status['status']}    success
    Log To Console    \n ${cell_status}-- \n
    Log To Console    \n --Locked Cells -- \n

Unlock cells group
    [Arguments]   ${cell_list}
    Log To Console    \n --Unlocking Cells -- \n
    ${cell_ope_status}=    admindu.Unlock Vdu Cell Groups	cell_groups_id_list=${cell_list}    vdu_connection=vDU
    Sleep     30s
    ${cell_status}=    admindu.get_operation_state_of_unlocking_vdu_cell_groups    operation_groups_id=${cell_ope_status['id']}
    ...    vdu_connection=vDU
    Run keyword And Continue On Failure    Should Be Equal    ${cell_status['status']}    success
    Log To Console    \n ${cell_status}-- \n
    Log To Console    \n --Unlocked Cells -- \n

Parameter_recommissioning_actRed
   admincu.Perform Parameter Recommissioning    dist_name=MRBTS-${BTS_ID}/NRBTS-${BTS_ID}
   ...                                          parameter=actRedirect
   ...                                          operation=update
   ...					        value=true
   ...                                          timeout=300	connection=vCU

Parameter_recommissioning_MFBI_disable
   admindu.Perform Parameter Recommissioning    dist_name=MRBTS-${BTS_ID}/NRBTS-${BTS_ID}
   ...                                          parameter=actMfbiNrCaSupportFr1
   ...                                          operation=update
   ...					        value=false
   ...                                          timeout=300	vdu_connection=vDU

Parameter_recommissioning_MFBI_enable
   admindu.Perform Parameter Recommissioning    dist_name=MRBTS-${BTS_ID}/NRBTS-${BTS_ID}
   ...                                          parameter=actMfbiNrCaSupportFr1
   ...                                          operation=update
   ...					      	value=true
   ...                                          timeout=300	vdu_connection=vDU

Attach and Tput Test
    [Arguments]   ${throughput_dl}    ${throughput_ul}    ${deviation_dl}    ${deviation_ul}
        ta_ultracaller.Require UE    ue_alias=${UE_alias}    capabilities=${capabilities}
	ta_ultracaller.Detach UE     ${UE_alias}
	ta_ultracaller.Attach UE     ${UE_alias}
	Sleep     10s
        Log To Console    \nStarting data transfer
	ta_ultracaller.start_data_transfer    ${UE_alias}    ${udpcalltype}    direction=${direction_dl}
	Run Keyword If    '${wait_for_transfer}'=='True'    Run Keywords    ta_ultracaller.await_data_transfer_finish    ${UE_alias}
	...    ${direction_dl}     ${timeout}
	...    AND    Sleep    30
	...    AND    Log to console    \nData transfer completed for DL
	Run Keyword And Continue On Failure    ta_ultracaller.calculate_thrughtput    ue_alias=${UE_alias}
	...    direction=${direction_dl}     thrughtput=${throughput_dl}    deviation=${deviation_dl}
	ta_ultracaller.start_data_transfer  ${UE_alias}   ${udpcalltype}    direction=@{direction_ul}
	Run Keyword If    '${wait_for_transfer}'=='True'    Run Keywords    ta_ultracaller.await_data_transfer_finish    ${UE_alias}
	...    ${direction_ul}     ${timeout}
	...    AND    Sleep    30
	...    AND    Log to console    \nData transfer completed for UL
	Run Keyword And Continue On Failure    ta_ultracaller.calculate_thrughtput    ue_alias=${UE_alias}    direction=${direction_ul}
	...     thrughtput=${throughput_ul}    deviation=${deviation_ul}
	Log to console    \nData transfer Finished
	ta_ultracaller.Detach UE     ${UE_alias}
	Log to console    Detach successful
	Sleep     10s

Get_Pre_Active_alarms
   [Documentation]    Active Alarms
   admin.connect_to
   ${Pre_Active_Alarm}    admin.get_active_alarms

Get_Post_Active_alarms
   [Documentation]    Active Alarms
   ${Post_Active_Alarm}   admin.get_active_alarms

Start DCAP Trace
   LogToConsole   \n-- Starting dcap traces --\n
   dcap.connect_to    host=${DCAP_host}    port=${ssh_port}    username=${dcapuser_name}    password=${dcap_password}
   ...              rd_version=dcapv3    secure=${True}
   &{bts1_info}   create dictionary  host=${host_vDU}    port=${ssh_port}    username=${USER}    password=${PWD}
   Create testcase folder
   ${output}    dcap.start_trace    bts=${bts1_info}    tag=newtrace    duration=-1
   ...    vdu_custom_profile=@{custom_profile}    wait_for_activation=True
   LogToConsole    ${output}
   ${trace_id} =   Get From Dictionary   ${output}   id
   sleep   20s
   LogToConsole    ${trace_id}
   set suite variable   ${trace_id}

Stop DCAP Trace
   sleep    10s
   LogToConsole   \n-- Stopping DCAP --\n
   dcap.stop_trace    trace_id=${trace_id}
   ${dcap_file_name}=    dcap.get_results    result_id=${trace_id}    target_dir=${PATH}/${Folder}/${testcase_name}/DCAP_Logs    timeout=1200
   set suite variable   ${dcap_file_name}

Get Date
   [Documentation]     Get date to create testcase folder
   ${date}    Get Current Date    result_format=%d_%m_%Y_%H%M%S_%f
   ${date}    Convert to String    ${date}
   Set global variable    ${Folder}    ${date}

Create testcase folder
   [Documentation]     Create testcase folder in testpc
   ${val}    Run Keyword And Return Status    LOG    ${PATH}/${Folder}/${testcase_name}
   Run Keyword If    ${val} == False    Get Date
   os.Create Directory    ${PATH}/${Folder}/${testcase_name}/DCAP_Logs

Suite_Setup
   Log to console  --Test Started--\n
   ${CurrentDate}=    Get Current Date    result_format=%d_%m_%Y_%H%M/
   ${CurrentDate}=    Convert to String     ${CurrentDate}
   ${SUITE NAME}    Set Variable    ${SUITE NAME}
   ${SUITE NAME}    Replace String    ${SUITE NAME}    ${SPACE}    _
   os.Create Directory    ${BTS_path}/${SUITE NAME}/${CurrentDate}
   Set global variable    ${Date}    ${CurrentDate}

Suite_Teardown
   log    "Test END"

Require_UE
   ${a}=     ta_ultracaller.Require UE    ue_alias=${UE_alias}    capabilities=${capabilities}
   log	  ${a}

Detach_UE
   ta_ultracaller.Detach UE     ${UE_alias}
   Log to console    Detach successful
   Sleep     10s

UE_attach
   Log to console    Trying Attach
   ta_ultracaller.Attach UE     ${UE_alias}
   Log to console    Attach successful
   Sleep     10s

Test setup
   Log To Console    \n --Connecting vDU-- \n
   admindu.Connect To	host=${host_vDU}	port=${PORT}	connection_name=vDU	username=${USER}
   ...    password=${PWD}	   secure=True	  timeout=300
   Log To Console    \n --Connecting vCU-- \n
   admincu.Connect To	host=${host_vCU}	port=${PORT}	 username=${USER}	password=${PWD}
   ...	  secure=True	alias=vCU	timeout=300
   ${vDU_Cell_status}=	admindu.Get Vdu Cells Status	  vdu_connection=vDU	  timeout=300
   Log To Console	    ${vDU_Cell_status[0]['availability_status']}
   Log	${vDU_Cell_status[0]['availability_status']}
   Log	All cell statuses: ${vDU_Cell_status}
   FOR	${cell}	  IN	@{vDU_Cell_status}
        Should Be Equal As Strings	${cell['availability_status']}	  on line
        Log	    Cell ${cell['id']} procedural state is now: ${cell['availability_status']}
        ${offline_cells}=	Evaluate	[cell for cell in ${vDU_Cell_status} if cell['availability_status'] != 'on line']
        Run Keyword If	  len(${offline_cells})==0	Log	All cells are online
        Log To Console	   Cell ${cell['id']} procedural state is now: ${cell['availability_status']}
   END
   ${vcu_Pre_Active_Alarm}=    admincu.Get Active Alarms	  connection=vCU
   ${vdu_Pre_Active_Alarm}=    admindu.Vdu Get Active Alarms	vdu_connection=vDU
   Log To Console    ${vcu_Pre_Active_Alarm}
   Log To Console    ${vdu_Pre_Active_Alarm}
   ${allowed_alarms}=    Expected_alarm
   Verify Active Alarm Is In List    ${vcu_Pre_Active_Alarm}    ${allowed_alarms}
   Verify Active Alarm Is In List    ${vdu_Pre_Active_Alarm}    ${allowed_alarms}
   Lock cells group    ${Cell_list1}

test teardown
   Log To Console    \n----Teardown.....---\n
   ${vcu_Pre_Active_Alarm}=    admincu.Get Active Alarms	  connection=vCU
   ${vdu_Pre_Active_Alarm}=    admindu.Vdu Get Active Alarms	vdu_connection=vDU
   Log To Console    ${vcu_Pre_Active_Alarm}
   Log To Console    ${vdu_Pre_Active_Alarm}
   ${allowed_alarms}=    Expected_alarm
   Verify Active Alarm Is In List    ${vcu_Pre_Active_Alarm}    ${allowed_alarms}
   Verify Active Alarm Is In List    ${vdu_Pre_Active_Alarm}    ${allowed_alarms}
   Unlock cells group    ${Cell_list2}
   Stop DCAP Trace
   admindu.Disconnect	vdu_connection=vDU
   admincu.Disconnect	connection=vCU
   Log To Console     \n--End of test--\n

Verify Active Alarm Is In List
   [Arguments]    ${alarm}    ${list}
   ${result} =    Run Keyword And Return Status    List Should Not Contain Value    ${list}    ${alarm}
   Should Be True    ${result}

Validate_Parameters
   admincu.get_parameters    dist_name=	 connection=vCU
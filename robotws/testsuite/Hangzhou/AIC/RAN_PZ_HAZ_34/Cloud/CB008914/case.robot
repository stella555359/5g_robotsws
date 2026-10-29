*** Settings ***
Documentation
...    author: Jiang Wenwen
...    contact: wenwen.jiang@nokia-sbell.com
...    squad group: RAN_PZ_3_SG02
...    Feature :  CB008914
...    Deprecated case removed by civen.chen

#Suite Setup
#Suite Teardown

#Test Timeout    80 minutes
#
#Library         OperatingSystem
#Library         Process
#Library         Collections
#Library         String
#Library         DateTime
#Library         testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Resources/python/basic.py    WITH NAME    basic
#Library           taf.hw.fhgw.cli                       WITH NAME    issh
#Library           taf.transport.ssh                     WITH NAME    csn
##Library           testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Resources/py_tool/common.py
#Library           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/bts/vdu_opeartion.py
#Resource        testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/container_log_capturing.robot
#Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
#Resource     testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Resources/cu_oam_cm.robot
#Resource     ../../../../resources/RAN_PZ_HAZ_34/robot/bts/cloud/cloud_cu.robot
#Resource     ../../../../resources/RAN_PZ_HAZ_34/robot/bts/cloud/cloud_state.robot
#Resource     ../../../../resources/RAN_PZ_HAZ_34/robot/bts/cloud/cloud_vdu.robot
#Resource      testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/RRM/Resources/AIC_BTS.robot
#Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/container_log_capturing.robot
#Resource     testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB007608_MM2/resources/common_1732.robot
#Resource        testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/enb_lte.robot
#*** Variables ***
#${MRBTS_ID}         ${tl.gnbs[0].dus[0].instance_id}
#${delta_plan_name}    deltaplan1
##${msg}    Get validation errors from CM validation result
#${msg}    Plan validation failed
#${attach_mode}    5G_SA
#${ui_version}    S21UI4.0
#${filter_name}    nr-rrc.c1 == 6
#${xpath}        .//f1ap.F1AP_PDU//f1ap.DLRRCMessageTransfer_element//f1ap.RRCContainer//nr-rrc.DL_DCCH_Message_element
#...    //nr-rrc.nonCriticalExtension_element//nr-rrc.rrc_SegAllowed_r16
#${xpath2}       .//f1ap.F1AP_PDU//f1ap.DLRRCMessageTransfer_element//f1ap.RRCContainer//nr-rrc.DL_DCCH_Message_element
#...    //nr-rrc.UECapabilityEnquiry_v1560_IEs_element//nr-rrc.capabilityRequestFilterCommon_element
#...    //nr-rrc.type1_SinglePanel_r16
#${pcap_file}    testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Cloud/CB008914/logs/attach.pcap
#${pcap_path}    /tmp
#${host_ip}      ${tl.gnbs[0].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.ip_addr}
#${username}     ${tl.gnbs[0].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.username}
#${password}     ${tl.gnbs[0].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.password}
#${prompt}
#${timeout}
#${alias1}       Link
#${cmd}          kubectl -n ${username} exec -it po-${username}-cpif-0  -c ctr-${username}-nwmgmt  -- bash
#${width}        None
#${cmd2}         tcpdump -i any -w /tmp/attach4.pcap\n
#${alias2}       DLlog
#${info}         tcpdump: data link type LINUX_SLL2
#${cmd3}       kubectl exec -n ${username} po-${username}-cpif-0 -c ctr-${username}-nwmgmt --
#...    /bin/gzip -c /tmp/attach4.pcap |gunzip > /var/home/${username}/attach4.pcap\n
#${remotepath}    /var/home/${username}/attach4.pcap
#${remotepath1}    /var/home
#${localpath}     attach4.pcap
#${cmd4}         rm -rf attach4.pcap\n
#${cmd5}         rm -rf tmp/attach4.pcap\n
#${errormessage}    No change in this plan. : No change in this plan.
##${errormessage1}     No change in this plan.
#${errormessage1}    Plan validation failed
#${failinfo}     failure
#${ongoing}      ongoing
#
#*** Test Cases ***
#[1]General_SiSo_Cell_block_and_unblock
#    case operation for celllock
#    Preconditions
#	Begin Collect Wiresharklog
#	step1: Prepare UE
#	Step2: UE Attach
#	End Collect Wireshark
#	Syc and DL wireshark
#	Analyze log for lock
#	[teardown]    Case Teardown
#
#[1][1.0] Manual_SiSo_SM_RF_Module_lock_unlock
#    Login VCU
#    case operation for RFlock
#    Run Keyword And Ignore Error    Logout To vCU By Rest
#    [Teardown]    Case Teardown
#
#
#*** Keywords ***
#
#step1: Prepare UE
#    [Documentation]    Author: zhao nana
#    ...                This keyword is prepare UE
#    [Arguments]    ${ue_index}=${0}    ${ue_type}=samsung_vran20    ${ui_version}=S21UI3.1
#    log to console      step1: Prepare UE
#
#    power_ue.Prepare UE    ue_index=${ue_index}    ue_type=${ue_type}    ui_version=${ui_version}
#
#Step2: UE Attach
#    [Documentation]    Author: zhao nana
#    ...                This keyword is attach UE
#    [Arguments]    ${ue_index}=${0}    ${ue_type}=samsung_vran20    ${attach_mode}=${attach_mode}
#    log to console      Step2: UE Attach
#    ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${ue_index}    ue_type=${ue_type}    log_type=Aasyslog
#    ...    attach_mode=${attach_mode}
#    #power_ue.Verify attach    ue_type=${ue_type}   5Grach_ed=${5Grach_ed_0}    4G_check=False
#
#Step6: UE Detach
#    [Documentation]    Author: zhao nana
#    ...                This keyword is UE Detach
#    [Arguments]    ${ue_type}    ${ue_index}=${0}
#    log to console    Step6: UE Detach
#    power_ue.UE Detach    ue_index=${ue_index}    ue_type=${ue_type}
#
#DL wireshark
#    wait until keyword succeeds    10 min    10 sec    Connect to eNB   alias=ENB
#    sleep    30
#    csn.send command    command=killall tcpdump     connection=ENB
#    sleep    5
#    csn.download_file   remote_path=/tmp${/}${log_name}    local_path=${pcap_path}${/}${log_name}   connection=ENB
#
#Preconditions
#    ${START_TIME}=    Get time    exclude_millis=yes
#    Set Suite Variable    ${START_TIME}
##    cloud_cu.CU Login     gnb_index=0    cu_version=cuoam_21b
##    ${planlist}    cu.get_delta_plan_list
##    Sleep    3s
##    Run Keyword If     len(${planlist})!=${0}     set suite variable    ${plan33}    @{planlist}[0]
##    Run Keyword If     len(${planlist})!=${0}     cu.delete_delta_plan    plan_id=&{plan33}[plan_id]
##    Run keyword and ignore error    cloud_cu.CU Logout
#    Common Test Setup For AIC 7199
#	${cell_identify0}=    Evaluate     16384*${tl.gnbs[0].dus[0].instance_id}+1
#    ${cell_identify0}   convert to string   ${cell_identify0}
#
#Common Test Setup For AIC 7199
#    basic.Create A Directory    log_path=${pcap_path}    directory_name=${pcap_path}
#
#case operation for RFlock
#    CU create delta plan
#	Set actGeneralConnectivityBronze to False
#    Set actSegUeCapUl to true
#    Valid delta plan
#	Active delta plan with error
#	Set actGeneralConnectivityBronze to True
#	Valid delta plan
#	Active delta plan with succeed
#
#Set actGeneralConnectivityBronze to False
#    #${mo_dn}   Set Suite Variable    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}
#	&{Alloc_param}=    create dictionary    operation_type=replace    parameter_path=/actGeneralConnectivityBronze
#    ...    value=false
#    @{updated_Alloc}    Create List    ${Alloc_param}
#	Set Suite Variable    ${updated_Alloc}
##    CU Online Change Single Mo Parameters via rest valid progress   para_list=${updated_Alloc}   mo_dn=${mo_dn}
#    update parameter     delta_plan_id=${delta_plan_id}
#
#Active delta plan with error
#    ${active_res}=   cu.activate_delta_plan   plan_id=${delta_plan_id}
#	Set Suite Variable    ${active_res}
#	run keyword and continue on failure   Wait until keyword succeeds  3x  30s
#	...  Active Delta Plan Operaion should not be Suc   plan_id=${delta_plan_id}
#	...    operation_id=${active_res['operation_id']}
#
#Set actGeneralConnectivityBronze to True
#    #${mo_dn}   Set Suite Variable    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}
#	&{Alloc_param}=    create dictionary    operation_type=replace    parameter_path=/actGeneralConnectivityBronze
#    ...    value=true
#    @{updated_Alloc}    Create List    ${Alloc_param}
#	Set Suite Variable    ${updated_Alloc}
##    CU Online Change Single Mo Parameters via rest valid progress   para_list=${updated_Alloc}   mo_dn=${mo_dn}
#    update parameter     delta_plan_id=${delta_plan_id}
#
#Active Delta Plan Operaion should not be Suc
#    [Arguments]  ${plan_id}  ${operation_id}
#    ${res}=  cu.get_operation_state_of_activating_delta_plan   ${plan_id}  ${operation_id}
#    log to console    ${res}
#    log to console    ${res['error_message']}
##	should be equal as strings    ${res['error_message']}
#    should contain    ${res['error_message']}    ${msg}
#
#Begin Collect Wiresharklog
#    ${prompt}  Set Variable      \\[tl\\d+@\\S+\\s\\S+\\]\\$
#	${prompt}  Set Variable     ${prompt}|\\$|bash-\\d\\.\\d\\$\\s
#	${prompt}  Set Variable     ${prompt}|\\[tl\\d+@\\S+\\s+\\S+\\]\\$
#	${prompt}  Set Variable     ${prompt}|${info}
##	${alias}    common.get_unique_id
#    ${alias}    vdu_opeartion.get_unique_id
#	Set Suite Variable    ${alias}
#    issh.Connect_To
#    ...   ip=${host_ip}
#    ...   username=${username}
#    ...   password=${password}
#    ...   prompt=${prompt}
#    ...   timeout=${timeout}
#    ...   alias=${alias}
#    ...   width=${width}
#	sleep    2s
#    ${out}    issh.Execute  command=${cmd}   alias=${alias}
#	sleep    5s
#    issh.execute_bare    command=${cmd2}    alias=${alias}
#
#
#End Collect Wireshark
#	Send CTRL_C Interactively    alias=${alias}
#	[Teardown]    issh.Disconnect    alias=${alias}
#
#
#Syc and DL wireshark
#    ${prompt}  Set Variable      \\[tl\\d+@\\S+\\s\\S+\\]\\$
#	${prompt}  Set Variable     ${prompt}|\\$|bash-\\d\\.\\d\\$\\s      ##bash-\\d\\.\\d\\$\\s
#	${prompt}  Set Variable     ${prompt}|\\[tl\\d+@\\S+\\s+\\S+\\]\\$
#	${prompt}  Set Variable     ${prompt}|${info}
#    issh.Connect_To
#    ...   ip=${host_ip}
#    ...   username=${username}
#    ...   password=${password}
#    ...   prompt=${prompt}
#    ...   timeout=${timeout}
#    ...   alias=${alias1}
#    ...   width=${width}
#	Sleep    8s
#    ${out}    issh.Execute_Bare    command=${cmd3}   alias=${alias1}
#	sleep    5s
#    issh.Download_File    remote_path=${remotepath}    local_path=${localpath}    alias=${alias1}
#	[Teardown]    issh.Disconnect    alias=${alias1}
#
#Analyze log for lock
#    ${filtered_packets}=    Load pcap with filter    pcap_file=${localpath}    filter_expression=${filter_name}
#    ${result}=    Get field value by xpath    packets=${filtered_packets}    xpath=${xpath}    attribute_name=showname
#	Should Be True    'rrc-SegAllowed-r16: enabled (0)' in ${result}
#
#Analyze log for noseg
#    ${filtered_packets}=    Load pcap with filter    pcap_file=${localpath}    filter_expression=${filter_name}
#    ${result}=    Get field value by xpath    packets=${filtered_packets}    xpath=${xpath2}    attribute_name=value
#	Should Be True    '00' in ${result}
#
#Send CTRL_C Interactively
#    [Arguments]  ${alias}=default
#    [Documentation]    it sends CTRL+C key to interrupt current running command
#    ...    within current active ssh connection. it should be used
#    ...    under active connection opened via issh library.
#    ...
#    ...    *AUTHOR* chris.l.cao@nokia-sbell.com
#    ...
#    ...    | Input Parameters | Man. | Description |
#    ...    | alias | yes | alias name |
#    ...
#    ...    *RETURN VALUE*
#    ...    No return value.
#    ...
#    ...    Example
#    ...    | Send CTRL_C Interactively | alias=default |
#    ${crtl_c}    Evaluate    chr(int(3))
#    ${out}   issh.Execute_Bare   command=${crtl_c}     alias=${alias}
#    Sleep    3s
#    [Return]  ${out}
#
#Logout To vCU By Rest
#    [Arguments]    ${connection}=${None}
#    cu.disconnect    connection=${connection}
#
#Login VCU
#    [Arguments]    ${gnb_index}=0
#    cloud_cu.CU Login     gnb_index=${gnb_index}    cu_version=cuoam_23r1
#
#case operation for celllock
#    Login VCU
#    CU create delta plan
#    Set actSegUeCapUl to true
#    Valid delta plan
#	Active delta plan with succeed
#	[teardown]    Logout To vCU By Rest
#
#case operation for noseg
#    Login VCU
#    CU create delta plan
#    Set actSegUeCapUl to false
#    Valid delta plan
#	Active delta plan with succeed
#	[teardown]    Logout To vCU By Rest
#
#Set actSegUeCapUl to true
#    #${mo_dn}   Set Suite Variable    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}
#	&{Alloc_param}=    create dictionary    operation_type=replace    parameter_path=/actSegUeCapUl    value=true
#    @{updated_Alloc}    Create List    ${Alloc_param}
#	Set Suite Variable    ${updated_Alloc}
##    CU Online Change Single Mo Parameters via rest valid progress   para_list=${updated_Alloc}   mo_dn=${mo_dn}
#    update parameter     delta_plan_id=${delta_plan_id}
#
#Set actSegUeCapUl to false
#    #${mo_dn}   Set Suite Variable    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}
#	&{Alloc_param}=    create dictionary    operation_type=replace    parameter_path=/actSegUeCapUl    value=false
#    @{updated_Alloc}    Create List    ${Alloc_param}
#	Set Suite Variable    ${updated_Alloc}
##    CU Online Change Single Mo Parameters via rest valid progress   para_list=${updated_Alloc}   mo_dn=${mo_dn}
#    update parameter     delta_plan_id=${delta_plan_id}
#
#CU create delta plan
#    ${delta_plan_list}     cu.get_delta_plan_list
#    Run Keyword If  ${delta_plan_list}  cu.delete_delta_plan  ${delta_plan_list[0]['plan_id']}
#    ${delta_res}=  cu.generate_delta_plan  plan_name=${delta_plan_name}
#    ${delta_plan_id}=  set variable  ${delta_res['plan_id']}
#	Set Suite Variable    ${delta_plan_id}
#	run keyword and continue on failure   Wait until keyword succeeds  3x  2s
#	...  _Generating Delta Plan Operation Should Be Successful  	${delta_res['action_id']}
#
#
#update parameter
#    [Arguments]    ${delta_plan_id}
#    ${uuid}   _Get CU Specifical MO UUID   plan_id=${delta_plan_id}    mo_dn=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}
#	Set Suite Variable    ${uuid}
#    ${update_res}=  cu.update_parameters_of_delta_plan   plan_id=${delta_plan_id}  mo_uuid=${uuid}
#    ...   parameter_change_list=${updated_Alloc}
#	run keyword and continue on failure  Wait until keyword succeeds  5x  5s
#	...    _Update Parameters Operation Should Be Successful	plan_id=${delta_plan_id}
#    ...    action_id=${update_res['action_id']}
#
#Valid delta plan
#	${validate_res}=   cu.validate_delta_plan   plan_id=${delta_plan_id}
#	Set Suite Variable    ${validate_res}
##	run keyword and continue on failure  Wait until keyword succeeds  2x  10s
#	run keyword and continue on failure
#    ...    _Validating Delta Plan Operation Should Be OK	 plan_id=${delta_plan_id}
#	...    action_id=${validate_res['action_id']}
#
#_Validating Delta Plan Operation Should Be OK
#    [Arguments]  ${plan_id}  ${action_id}
#    [Documentation]   _Validating Delta Plan Operation Should Be Successful
#    ...  author: wenwen.jiang@nokia-sbell.com
#    ...    | Input Parameters | Man. | Description |
#    ...    | plan_id | yes | delta plan id |
#    ...    | action_id | yes | Update parameter operation feedback action id |
#    ...    *RETURN VALUE*  None
#    ...    Example
#    ...    | _Validating Delta Plan Operation Should Be Successful  | plan_id=xxx | action_id=xxx |
#    ${res}=    cu.get_action_state_of_validating_delta_plan   ${plan_id}  ${action_id}
#	Set Suite Variable   ${res1}    ${res['status']}
#	Set Suite Variable   ${res}
#	Wait until keyword succeeds  10x  5s    valid Status should not ongoing    plan_id=${plan_id}    action_id=${action_id}
#    Run Keyword If    '${failinfo}'=='${res1}' and '${res['error_message']}'=='${errormessage}'
#    ...    log to console    no need to execution
#	...    ELSE       should be equal as strings  ${res['status']}  success
##	should be equal as strings  ${res['status']}  success
#
#
#Valid Status should not ongoing
#    [Arguments]  ${plan_id}  ${action_id}
#    ${res}=    cu.get_action_state_of_validating_delta_plan   ${plan_id}  ${action_id}
#	Set Suite Variable   ${res1}    ${res['status']}
#	Set Suite Variable   ${res}
#    should not be equal as strings    ${res1}    ${ongoing}
#
#
#Active delta plan with succeed
#    ${active_res}=   cu.activate_delta_plan   plan_id=${delta_plan_id}
#	Set Suite Variable    ${active_res}
##	run keyword and continue on failure   Wait until keyword succeeds  2x  5s
#	run keyword and continue on failure
#	...    _Activating Delta Plan Operation Should Be OK   plan_id=${delta_plan_id}
#    ...    operation_id=${active_res['operation_id']}
#
#_Activating Delta Plan Operation Should Be OK
#    [Arguments]  ${plan_id}  ${operation_id}
#	${res}=  cu.get_operation_state_of_activating_delta_plan   ${plan_id}  ${operation_id}
#    log to console    ${res}
#    log to console    ${res['error_message']}
#	Set Suite Variable    ${res}
#	Set Suite Variable    ${res1}    ${res['status']}
#    Wait until keyword succeeds  10x  5s    Active Status should not ongoing    plan_id=${plan_id}    operation_id=${operation_id}
#    Run Keyword If    '${failinfo}'=='${res1}' and '${res['error_message']}'=='${errormessage1}'
#    ...    log to console    no need to execution
#	...    ELSE       should be equal as strings  ${res['status']}  success
##	should be equal as strings  ${res['status']}  success
#
#Active Status should not ongoing
#    [Arguments]  ${plan_id}  ${operation_id}
#	${res}=  cu.get_operation_state_of_activating_delta_plan   ${plan_id}  ${operation_id}
#	Set Suite Variable    ${res}
#	Set Suite Variable    ${res1}    ${res['status']}
#	should not be equal as strings    ${res1}    ${ongoing}
#
#Execute multiple times
#    FOR    ${i}    IN RANGE    ${4}
#        case operation for seg
#		Sleep    5s
#	    case operation for noseg
#		Sleep    5s
#	END
#	case operation for seg
#
#Case Teardown
#    ${prompt}  Set Variable      \\[tl\\d+@\\S+\\s\\S+\\]\\$
#	${prompt}  Set Variable     ${prompt}|\\$|bash-\\d\\.\\d\\$\\s
#	${prompt}  Set Variable     ${prompt}|\\[tl\\d+@\\S+\\s+\\S+\\]\\$
#	${prompt}  Set Variable     ${prompt}|${info}
#    issh.Connect_To
#    ...   ip=${host_ip}
#    ...   username=${username}
#    ...   password=${password}
#    ...   prompt=${prompt}
#    ...   timeout=${timeout}
#    ...   alias=${alias2}
#    ...   width=${width}
#	sleep    2s
#	issh.execute_bare    command=${cmd4}    alias=${alias2}
#    ${out}    issh.execute_bare    command=${cmd}\n    alias=${alias2}
#	sleep    5s
#	issh.execute_bare    command=${cmd5}    alias=${alias2}
#	sleep    5s
#	issh.execute_bare    command=${cmd5}    alias=${alias2}
#	[teardown]       issh.Disconnect    alias=${alias2}
#
#case operation for ciphering
#    Login VCU
#    CU create delta plan
#    Set ciphering to zero
#    Valid delta plan
#	Active delta plan with succeed
#	[teardown]    Logout To vCU By Rest
#
#
#Set ciphering to zero
#    #${mo_dn}   Set Suite Variable    MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}
#	&{Alloc_param}=    create dictionary    operation_type=replace    parameter_path=/actSegUeCapUl    value=true
#    @{updated_Alloc}    Create List    ${Alloc_param}
#	Set Suite Variable    ${updated_Alloc}
##    CU Online Change Single Mo Parameters via rest valid progress   para_list=${updated_Alloc}   mo_dn=${mo_dn}
#    update parameter     delta_plan_id=${delta_plan_id}
#
#

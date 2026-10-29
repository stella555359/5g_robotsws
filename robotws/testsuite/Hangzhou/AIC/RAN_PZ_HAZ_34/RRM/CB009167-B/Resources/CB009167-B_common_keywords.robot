*** Settings ***
Documentation
...    author: Luo Tina
...    contact: tina.luo@nokia-sbell.com
...    squad group: 5G_PZ_MMW_HZ_3_SG

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/cloud/cloud_cu.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/cloud/cloud_vdu.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/enb_lte.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/cloud/cloud_state.robot
Library     taf.analyzer.pcap     WITH NAME    cap
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/cloud/common_trans.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/cloud/AIC_Counter_KPI.robot
#Resource     ./variables.robot
Resource     testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/RRM/Resources/AIC_BTS.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/cloud/log_cap.robot
Library     taf.gnb.oam.coam.cu    WITH NAME    vcu
Library     taf.gnb.oam.commissioning    WITH NAME    commissioning
Library     taf.hw.rf_attenuator    WITH NAME    att
Library             taf.sw.dcap.rd		                  WITH NAME	   DCAP
Library      ./regexp.py

*** Variables ***
${RIC_ip}    10.70.222.115
${RIC_username}    root
${RIC_password}    nokia123
${RIC_local_file_path}    robotws/testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/RRM/CB009167-B/Resources
${RIC_remote_path}			/root/ric/CB009167
${RIC_file_name}    Scell_Release.json
${SCF_Template_path_CU_TL}    ${commissionings_path}/HGZ/${testline_name}/SCF_0.250_vCU.xml
${SCF_Template_path_DU_TL}      ${commissionings_path}/HGZ/${testline_name}/gnbs_0/dus_0/SCF_0.300.xml
#&{all_tp_0}     average=0.00    peak=0.00   minimum=0.00
${BRANCH}    Trunk
*** Keywords ***

RIC xAPP Policy Setup
	[Documentation]		RIC xapp configuration
	[Arguments]    ${RIC_file_name}    ${xAPP_name}
    Log to console      \nConfiguring RIC
    ${gNB_hex}     hex_to_oct    ${tl.gnbs[0].instance_id}
	ssh.Connect_to    ${RIC_ip}    ${RIC_username}    ${RIC_password}    alias=RIC_vm
	${ip}	ssh.Execute
	...    command=kubectl get svc -A|grep service-ricxapp-${xAPP_name}-sa-tsserver | awk '{print $4}'	connection=RIC_vm	timeout=30s
	${ip}	Strip String    ${ip}    characters=\r\n
	Run Keyword If   "${xAPP_name}"=="imlb"   Set Test Variable    ${xAPP_name}    imlbsa
	FOR    ${i}    IN RANGE    1	7
		LOG		command=curl -L -X DELETE http://${ip}:9091/ric/v1/${xAPP_name}/tsPolicy/${i}
        Run Keyword If     "${xAPP_name}"=="imlbsa"
        ...     ssh.Execute     command=curl -L -X DELETE http://${ip}:9091/ric/v1/${xAPP_name}/tsPolicy/${i}/gNb/${gNB_hex}
        ...     connection=RIC_vm	timeout=30s
        ...     ELSE    ssh.Execute     command=curl -L -X DELETE http://${ip}:9091/ric/v1/${xAPP_name}/tsPolicy/${i}
        ...     connection=RIC_vm	timeout=30s
	END
	${pwd}		RUN		pwd
	ssh.upload_file    local_path=${pwd}/${RIC_local_file_path}/${RIC_file_name}    remote_path=${RIC_remote_path}/${RIC_file_name}	connection=RIC_vm
	${cmd}	Set Variable
	...    curl -L -X POST http://${ip}:9091/ric/v1/${xAPP_name}/tsPolicy -H "Content-Type: application/json" -d @${RIC_remote_path}/${RIC_file_name}
	${output}		ssh.Execute     command=${cmd}      connection=RIC_vm		timeout=30s
	${rc}    Run Keyword And Return Status		Should Be Empty       ${output}
	sleep	5s
	${output}	Run Keyword If    "${rc}"=="False"	ssh.Execute	command=${cmd}	connection=RIC_vm	timeout=30s
	Run Keyword If    "${rc}"=="False"	Should Be Empty		${output}
	ssh.Disconnect		connection=RIC_vm

RIC xAPP Policy delete
	[Documentation]		RIC xapp policy deletion
	[Arguments]      ${xAPP_name}
    Log to console      \nConfiguring RIC
    ${gNB_hex}     hex_to_oct    ${tl.gnbs[0].instance_id}
	ssh.Connect_to    ${RIC_ip}    ${RIC_username}    ${RIC_password}    alias=RIC_vm
	${ip}	ssh.Execute
	...    command=kubectl get svc -A|grep service-ricxapp-${xAPP_name}-sa-tsserver | awk '{print $4}'	connection=RIC_vm	timeout=30s
	${ip}	Strip String    ${ip}    characters=\r\n
	Run Keyword If   "${xAPP_name}"=="imlb"   Set Test Variable    ${xAPP_name}    imlbsa
	FOR    ${i}    IN RANGE    1	7
		LOG		command=curl -L -X DELETE http://${ip}:9091/ric/v1/${xAPP_name}/tsPolicy/${i}
        Run Keyword If     "${xAPP_name}"=="imlbsa"
        ...     ssh.Execute     command=curl -L -X DELETE http://${ip}:9091/ric/v1/${xAPP_name}/tsPolicy/${i}/gNb/${gNB_hex}
        ...     connection=RIC_vm	timeout=30s
        ...     ELSE    ssh.Execute     command=curl -L -X DELETE http://${ip}:9091/ric/v1/${xAPP_name}/tsPolicy/${i}
        ...     connection=RIC_vm	timeout=30s
	END
	ssh.Disconnect		connection=RIC_vm

OAM Precondition Cell Should Be Onair
    [Documentation]    Do some common thing for every precondition of cases
    ...    any case should include it in test case setup
    ...    it will do following actions
    ...    1) check cell should be onair
    ...    2) initial global test varible
    ...
    ...    *AUTHOR* xianbiao.cheng@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...   14.1.2022,chris.l.cao@nokia-sbell.com, remove 'CU Get Cells ID list' to save cell id information
    ...   22.1.2022,chris.l.cao@nokia-sbell.com, remove unused variable ${BACKUP_SCF_PATH_ON_CU} to shorten dryrun time
    ...
    log to console  \n*** OAM Precondition Cell Should Be Onair ... ***
    set_vdu_pod_container_suite_variables
    ${nf_type}  Get VCU NF Type
    Run Keyword If   "${nf_type}"=="VNF"     CU Verify All VMs Are Online
    All DUs Container Status Should Be Normal
    #CU Verify All Cells Status Are Onair
    vDU Verify All Cells Status Should Be Onair For All DUs
    ${ACTIVE_ALARM_LST_PRE_CU}=  run keyword and continue on failure  CU Get Active Alarms
    ${HISTORICAL_ALARM_LST_PRE_CU}   run keyword and ignore error   CU Get Historical Alarms
    set test variable  ${ACTIVE_ALARM_LST_PRE_CU}
    set test variable  ${HISTORICAL_ALARM_LST_PRE_CU}
    set test variable  ${ACTIVE_ALARM_LST_PRE_DU}       tbd
    set test variable  ${ACTIVE_ALARM_LST_PRE_FHGW}     tbd


CU Full Commission Fix Error
    [Arguments]    ${path_of_commission_file}=${SCF_Template_path_CU_TL}    ${gnb_index}=0
    [Documentation]   vCU commission
    log to console   \n*** Start vCU commission ***
    CU Login  ${gnb_index}
    vCU Load And Active SCF   ${path_of_commission_file}
    [Teardown]    run keyword and ignore error   CU Logout

vCU Load And Active SCF
    [Arguments]     ${path_of_commission_file}    ${wait_active}=${True}
    ${upload_operation_info}=   cu.upload_plan_file     ${path_of_commission_file}
    wait until keyword succeeds    60s   5s  CU Check Plan Upload Status Should Be As Expected
    ...    ${upload_operation_info["action_id"]}    success
    ${fix_err_operation}=   cu.fix_plan_validation_errors    ${upload_operation_info['plan_id']}
    ...   add_missing_objects=${True}   fix_mandatory_parameters=${True}
    sleep   60s
    ${validate_operaition_info}=  cu.plan_validation    ${upload_operation_info["plan_id"]}
    wait until keyword succeeds    60s   5s  CU Check Plan Validate Status Should Be As Expected
    ...    ${upload_operation_info["plan_id"]}   ${validate_operaition_info["action_id"]}    success
    ${activate_operaition_info}=  cu.plan_activation   ${upload_operation_info["plan_id"]}
    run keyword if    ${wait_active}==${True}    wait until keyword succeeds    600s   30s  CU Check Plan Activate Status Should Be As Expected
    ...    ${upload_operation_info["plan_id"]}  ${activate_operaition_info["id"]}    success


vDU Full Commission SCF Fix Error
    [Arguments]     ${path_of_commission_file}=${SCF_Template_path_DU_TL}      ${vdu_index}=0
    [Documentation]   vCU commission
    log to console   \n*** Start vDU commission ***
    vDU Rest Login
    Check Maximum Plan Number And Delete One If Reach Maximum Number
    vDU Load And Active SCF   ${path_of_commission_file}
    [Teardown]    run keyword and ignore error   vDU Logout

vDU Load And Active SCF
    [Arguments]     ${path_of_commission_file}   ${retries}=1
    [Documentation]   load SCF and active SCF
    ${upload_plan_response}=  vdu.upload_plan    ${path_of_commission_file}
   Upload Plan Status Should Be Successful  operation_id=${upload_plan_response['action_id']}
    ${fix_err_response}=   vdu.fix_vdu_staged_plan_error    ${upload_plan_response['plan_id']}
    wait until keyword succeeds  30s  10s  Fix vDU SCF Validation Errors Should Be Successful
    ...    ${upload_plan_response['plan_id']}  ${fix_err_response['action_id']}
    ${temp_validation_id}   Validate Plan By REST  plan_id=${upload_plan_response['plan_id']}   retries=${retries}
    ${out}   Activate Staged Plan By REST   plan_id=${upload_plan_response['plan_id']}
Fix vDU SCF Validation Errors Should Be Successful
    [Arguments]  ${plan_id}  ${action_id}
    ${fix_err_response}=   vdu.get_fix_vdu_staged_plan_operation_status  ${plan_id}  ${action_id}
    should be equal as strings  ${fix_err_response['status']}  success
    log to console    Fix SCF Errors Succ
Lock E2 Link And Check E2 Link Status
    CU Delta Commission update    ${E2_LOCK}
    ${admin_status}    Online Get VCU Parameter Value    mo_dn=${NRE2LINK}     parameter_name=administrativeState
    should be equal    ${admin_status}    Locked
    ${E2_status}    Online Get VCU Parameter Value    mo_dn=${NRE2LINK}     parameter_name=e2LinkStatus
    should be equal    ${E2_status}    inactive

Unlock E2 Link And Check E2 Link Status
    CU Delta Commission update    ${E2_UNLOCK}
    ${admin_status}    Online Get VCU Parameter Value    mo_dn=${NRE2LINK}     parameter_name=administrativeState
    should be equal    ${admin_status}   Unlocked
    ${E2_status}    Online Get VCU Parameter Value    mo_dn=${NRE2LINK}     parameter_name=e2LinkStatus
    should be equal    ${E2_status}     active
check E2 link status
    [Arguments]    ${E2_status_expected}==active
    ${E2_status}    Online Get VCU Parameter Value
    ...     mo_dn=${NRE2LINK}  parameter_name=e2LinkStatus    # value=active
    should be equal    ${E2_status}     ${E2_status_expected}

Test Case set up
    ${START_TIME}=    Get time    exclude_millis=yes
    Set Suite Variable    ${START_TIME}
    ${TS_CASE_LOG_PATH}=    Get A Directory
    Set Suite Variable    ${TS_CASE_LOG_PATH}
    set_vdu_pod_container_suite_variables
Prepare UE for ${ue_type}
    log to console      Prepare UE for ${ue_type}
    power_ue.Prepare UE    ue_index=${0}    ue_type=${ue_type}    reset_sol=ue_reboot
	sleep    40s

UE Attach for ${ue_type}
    log to console      UE Attach for ${ue_type}
    ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${0}    ue_type=${ue_type}    log_type=Aasyslog


Start traffic and check result
    [Arguments]    ${dltp_expected}=540  ${data_send_dl}=560M    ${data_send_ul}=70M
	...             ${ultp_expected}=50    ${tp_direction}=both    ${sleep_time}=120s   ${vdu_index}=0    ${gnb_index}=0
    Start traffic according to direction and protocol  data_send_dl=${data_send_dl}    tp_direction=${tp_direction}
    ...            data_send_ul=${data_send_ul}
	#Set Suite Variable   @{all_tp_DL}    ${all_tp_0}
    #Set Suite Variable   @{all_tp_UL}    ${all_tp_0}
    #Set Suite Variable   @{all_tp}    ${all_tp_DL}  ${all_tp_UL}
    ${handle}    vDU Begin K8s Log    ${gnb_index}    ${vdu_index}
    Set test variable    ${handle}
    ${container_prefix}    vDU Get Container Name Prefix
	sleep    ${sleep_time}
	${local_l2rt_file}    vDU End K8s Log      handle=${handle}     pod_abbr=up     container=${container_prefix}l2rt
    ...    gnb_index=${gnb_index}    vdu_index=${vdu_index}
	Set Suite Variable    ${local_l2rt_file}
	${cell_identify}=    Evaluate     16384*${tl.gnbs[0].instance_id}+1
    ${cell_identify}   convert to string   ${cell_identify}
    @{list_of_cell}     Create List         ${cell_identify}
    Set Suite Variable     @{list_of_cell}
    #${all_tput}    Check throughput according to direction and protocol    dltp_expected=${dltp_expected}
    #...    tp_direction=${tp_direction}    ultp_expected=${ultp_expected}     cells=@{list_of_cell}
    Check throughput according to direction and protocol    dltp_expected=${dltp_expected}
    ...    tp_direction=${tp_direction}    ultp_expected=${ultp_expected}     cells=@{list_of_cell}



Start traffic according to direction and protocol
    [Arguments]  ${data_send_dl}    ${data_send_ul}=60M     ${tp_direction}=both
    log to console      Start traffic
    Run keyword if    '${tp_direction}'=='ul' or '${tp_direction}'=='both'    power_ue.Start traffic    ue_index=${0}
    ...    direction=ul    throughput=${data_send_ul}    duration=1400    ue_type=${ue_type}    iperf_type=via_command
    ...    protocol=${protocol}    data_amount=2M
    sleep    1s
    Run keyword if    '${tp_direction}'=='dl' or '${tp_direction}'=='both'   power_ue.Start traffic    ue_index=${0}
    ...    direction=dl    throughput=${data_send_dl}    duration=1400
	...    ue_type=${ue_type}   process_num=1
    sleep    20s

Check throughput according to direction and protocol
    [Arguments]    ${dltp_expected}    ${cells}    ${ultp_expected}=58    ${tp_direction}=both
    log to console      Check throughput
	Set Suite Variable     ${local_l2rt_file}
    Run keyword if    '${tp_direction}'=='dl'    Run keyword and continue on failure    Check throughput for DL-direction
    ...       dltp_expected=${dltp_expected}    tp_direction=${tp_direction}    ultp_expected=${ultp_expected}     cells=${cells}
#    Run keyword if    '${tp_direction}'=='ul'    Run keyword and continue on failure    Check throughput for UL-direction
#    ...       dltp_expected=${dltp_expected}    tp_direction=${tp_direction}    ultp_expected=${ultp_expected}     cells=${cells}
#    [Return]     ${all_tp}

Check throughput for DL-direction
    [Arguments]    ${dltp_expected}    ${cells}    ${ultp_expected}=58    ${tp_direction}=both
	Run keyword and continue on failure    power_ue.Check Tput
    ...    ue_type=${ue_type}    direction=DL    log=${local_l2rt_file}    cells=${cells}
    ...    target_throughput=${dltp_expected}    actCarrierAggregation=${False}
	#Set Test Variable    ${all_tp}    ${all_tp}

Stop traffic according to direction and protocol
    [Arguments]  ${tp_direction}=both
    log to console      Stop traffic
    Run keyword if    '${tp_direction}'=='ul' or '${tp_direction}'=='both'    power_ue.Stop traffic    direction=ul
    ...    ue_index=${0}    ue_type=${ue_type}    iperf_type=via_command    protocol=tcp
    Run keyword if    '${tp_direction}'=='dl' or '${tp_direction}'=='both'      power_ue.Stop traffic    direction=dl
    ...     ue_index=${0}    ue_type=${ue_type}    protocol=tcp

check State of RAN function
    [Arguments]    ${RANfunction_state_expected}==Added    ${dist_mo}=${NRRANFUNCTION_CA}
    ${RANfunction_state}    Online Get VCU Parameter Value    mo_dn=${dist_mo}     parameter_name=state
    should be equal    ${RANfunction_state}     ${RANfunction_state_expected}

Online Get VCU Parameter Value
   [Arguments]       ${gnb_index}=0   ${mo_dn}=null   ${parameter_name}=administrativeState
    Login To vCU By Rest    gnb_index=${gnb_index}
    ${para_result}    cu.search_parameters_of_current_plan    parameter_name=${parameter_name}
    ...                                                        items_per_page=${30}
    ${result_length}          get length    ${para_result['items']}
    ${result_fault_length}    Evaluate      ${result_length} - ${1}
    FOR    ${index}    IN RANGE    ${result_length}
        ${distname}    set variable    ${para_result['items'][${index}]['distname']}
        ${para}        set variable    ${para_result['items'][${index}]['parameter_name']}
        Run Keyword If    "${distname}" == "${mo_dn}" and "${para}" == "${parameter_name}"
        ...                 Set Variable    ${index}    ${index}
        exit for loop if    "${distname}" == "${mo_dn}" and "${para}" == "${parameter_name}"
        Run Keyword If      ${index}==${result_fault_length}    fail    get parameter is failed
    END
    ${para_value}    set variable    ${para_result['items'][${index}]['parameter']['simple_parameter']['value']}
    [Return]   ${para_value}
    [Teardown]    Logout To vCU By Rest

Login To vCU By Rest
   [Arguments]   ${gnb_index}=0   ${alias}=${None}   ${restapi_version}=cuoam_23r1
   [Documentation]  Create rest session to vCU.
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | gnb_index  | No |  gnb index to indicate which gnb will be used  |
    ...    | restapi_version | No | if you use 'get_counter' keyword in CU trunk build, the parameter should be given |
    ...    | ...             |     'cuoam_21b' other senarios should be use default value - cuoam_21b |
    ...    | alias | No. | alias that identifies this connection, if the argument is given, |
    ...    | ...   |      the alias must be given to the Logout To vCU By Rest keyword as connection argumument. |
	...
    ...    | Return Value | Description |
    ...    | ${alias} | return the connection alias |
    ...
    ...    the connection alias
    ...    Example
    ...    | Login To vCU By Rest | gnb_index=0 |
    ...
    ${host}    set variable  ${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.addr}
    run keyword and ignore error    Logout To vCU By Rest
    cu.connect to    host=${host}
    ...    port=${EMPTY}
    ...    username=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...    password=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    ...    cu_version=${restapi_version}
    ...    secure=${True}
    ...    alias=${alias}
    [Return]  ${alias}

Logout To vCU By Rest
    [Arguments]    ${connection}=${None}
    [Documentation]  Teardown rest session to CU.
    ...    Author: Yang Mengli
    ...    Contact: mengli.yang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | connection | No. | the connection alias that used in CU login |
    ...    | Return Value | Description |
    ...    | None | NA |
    ...
    ...    Example
    ...    |  Logout To vCU By Rest | connection=${None} |
    ...
    cu.disconnect    connection=${connection}

VCU Login
    [Arguments]    ${gnb_index}=0    ${alias}=${None}    ${restapi_version}=cuoam_21b    ${delay}=${EMPTY}
    [Documentation]    Create rest session to CU.
    ...    | Input Parameters | Man. | Description |
    ...    |    gnb_index    | No |    gnb index to indicate which gnb will be used    |
    ...    | restapi_version | No | if you use 'get_counter' keyword in CU trunk build, the parameter should be given 'cuoam_21b'
    ...    other senarios should be use default value - cuoam_21b |
    ...    |    alias | No. | alias that identifies this connection, if the argument is given,
    ...    the alias must be given to the CU Logout keyword as connection argumument. |
    ...    |    delay | No |    delay, default is ${EMPTY}    |
    ...
    ...    *RETURN VALUE*
    ...    the connection alias
    ...    Example
    ...    |    CU Rest Login    |    |
    ...    |    CU Rest Login    |    delay=3    |
    Run Keyword And Ignore Error    VCU Logout
    ${password}    Set Variable If    '${BRANCH}'=='Trunk'    Nokia@123    nemuuser
    vcu.Connect To    host=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.addr}
    ...    port=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.port}
    ...    username=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...    password=${password}
    ...    cu_version=${restapi_version}
    ...    secure=${true}
    ...    alias=${alias}
    ...    timeout=120
    Run Keyword If    "${delay}"!="${EMPTY}"    Sleep    ${delay}

VCU Logout
    [Arguments]    ${connection}=${none}
    [Documentation]    Teardown rest session to CU.
    ...    | Input Parameters | Man. | Description |
    ...    | connection | No. | the connection alias that used in CU login |
    ...    Example
    ...    |    CU Rest Logout |    |
    vcu.Disconnect    connection=${connection}

VCU Get PM Counter Value
    [Arguments]    ${counter_id}    ${dimension_dn}    ${measurement_id}=None
    [Documentation]    This keyword is to get the latest value for a vCU counter
    ...
    ...    | Input Parameters | Man. | Description |
    ...    | ${counter_id} | yes | the counter id, e.g.M55115C00002 |
    ...    | ${dimension_dn} | yes | the dimension dist name that the counter belongs to, e.g.MRBTS-1111/NRBTS-1111/NRCELL-1 |
    ...    | ${measurement_id} | No | the measurement id, e.g.55115 ,the default value is None|
    ...
    ...    Examples:
    ...    |  |  |  |
    VCU Login
    # ${counter_info}    vcu.get_counter_info    counter_id=M55112C00002    measurement_id=55112
    ${counter}    vcu.get_counter    measurement_id=${measurement_id}    dimension_dist_name=${dimension_dn}
    ...    counter_id=${counter_id}
    ${counter_values}    Get From Dictionary    ${counter}    values
    Run Keyword If    ${counter_values}==[]    Fail    No counter value right now.
    ${counter_value}    Get From Dictionary    ${counter_values[-1]}    value
    Log To Console    The latest value for counter '${counter_id}': ${counter_value}
    [Teardown]    Run Keyword And Ignore Error    VCU Logout
    [Return]    ${counter_value}

Begin Wireshark Log On CU for Given Pod
    [Arguments]  ${filter}=sctp    ${pod_abbr}=cpe2    ${container}=nwmgmt
    [Documentation]   _Begin Wireshark Log On CU CNF
    #${pod_abbr}   Set Variable   cpe2
    #${container}  Set Variable   nwmgmt
    ${alias}   Connect To CU Node   pod_abbr=${pod_abbr}
    ${tmpfile_pcap}   _Begin Wireshark VCU for Given Pod  interface=any    pod_abbr=${pod_abbr}   container=${container}  alias=${alias}
             ...   filter=${filter}
    ${handle}  set variable  ${alias}_${tmpfile_pcap}
    [Return]    ${handle}


End Wireshark Log On CU for Given Pod
    [Arguments]    ${handle}    ${local_pcap_file_name}   ${index}=0    ${pod_abbr}=cpe2    ${container}=nwmgmt
    [Documentation]    End Wireshark X2 Cplane Log On CU
    Log To Console    End Wireshark ${pod_abbr} Cplane Log On CU
    ${tmp}  Split String   ${handle}  _
    ${alias}   Set Variable   ${tmp[0]}
    ${ns}    Get CU Namespace From Testline   gnb_index=${index}
    ${pcap_tmp}  Split String   ${handle}  /
    ${tmpfile_pcap}   Set Variable   /var/home/${ns}/${pcap_tmp[-1]}
    ${vcu_nf_type}   Get VCU NF Type
    run keyword if   "${vcu_nf_type}"=="CNF"
    ...           _End Wireshark VCUC     log_dst_path=${local_pcap_file_name}   log_src_path=${tmpfile_pcap}    alias=${alias}
    ...   ELSE    _End Wireshark VCU VNF    log_dst_path=${local_pcap_file_name}   log_src_path=${tmpfile_pcap}    alias=${alias}

    [Return]   ${local_pcap_file_name}

_Begin Wireshark VCU for Given Pod
     [Arguments]    ${interface}=eth0    ${filter}=${EMPTY}    ${alias}=default
     ...     ${index}=0      ${pod_abbr}=${EMPTY}   ${container}=${EMPTY}
     [Documentation]    Begin to capture wireshark log, the return value is a temporary file name which exists in target server
    ${host_type}   Set Variable   VCUC
    ${tmpfilefullpath}    _Begin Tcpdump Wireshark VCU for Given Pod  interface=${interface}    filter=${filter}
      ...   pod_abbr=${pod_abbr}   container=${container}  index=${index}   alias=${alias}
    [Return]     ${tmpfilefullpath}

_Begin Tcpdump Wireshark VCU for Given Pod
    [Arguments]    ${interface}    ${filter}   ${alias}  ${pod_abbr}   ${container}  ${index}=0
    [Teardown]  Run Keyword And Ignore Error  disconnect interactive connection   alias=${alias2}
    [Tags]    CLOUD_PLATFORM_SPECFIC
    ${host_type}  Set Variable  VCUC
    Log To Console   VCU CNF index:${index}/${pod_abbr}/${container}
    ${pcap_folder}   set variable    /tmp/tmp_wireshark
    ${ns}    Get CU Namespace From Testline   gnb_index=${index}
    ${alias2}   Connect To CU K8S Master With Admin
    ${full_pod_name}   Get CU Full Pod Name By Pod Abbreviation  pod_abbr=${pod_abbr}   gnb_index=${index}  alias=${alias2}
    ${full_container_name}   Get CU Full Container Name By Container Abbreviation  ctr_abbr=${container}
    ${out}  issh.Execute  command=kubectl exec -it ${full_pod_name} -c ${full_container_name} -n ${ns} -- mkdir -p ${pcap_folder}  alias=${alias2}
    ${out}  issh.Execute  command=kubectl exec -it ${full_pod_name} -c ${full_container_name} -n ${ns} -- ls -l ${pcap_folder}  alias=${alias2}
    ${tmpfilename}    _Get Temp File Name   host_type=${host_type}   fhgw_or_vdu_index=${index}   pod_abbr=${pod_abbr}  container_id=${container}
    ${tmpfilenamefullpath}    Set Variable    ${pcap_folder}/ws_${tmpfilename}.pcap
    ${out_containerid}  issh.Execute
	...   command=kubectl describe pod ${full_pod_name} -n ${ns}|grep -i 'container id' -B 2|grep nwmgmt -A 1 |grep cri  alias=${alias2}
    ${containerid}    regexp_containerid   ${out_containerid}
    ${pid}   Get PID For Given Container In VCU     pod_abbr=${pod_abbr}    ctr_abbr=${container}  containerid=${containerid}  alias=${alias}

    ${cmd}    Set Variable If    '${filter}'==''    tcpdump -ni ${interface} -s 0 -w ${tmpfilenamefullpath}
    ...    tcpdump -ni ${interface} ${filter} -s 0 -w ${tmpfilenamefullpath}
    ${full_cmd}   set variable  sudo nsenter -m -n -t ${pid} ${cmd}
    issh.Execute_Bare   command=${full_cmd}   alias=${alias}
    ${out}   Send ENTER Interactively VCU CNF  alias=${alias}
    Sleep   6s
    ${out}   issh.Execute    command=ps -ef|grep tcpdump   alias=${alias2}
    Log To Console  ${out}
    [Return]    ${tmpfilenamefullpath}

Get PID For Given Container In VCU
    [Arguments]  ${pod_abbr}  ${ctr_abbr}  ${containerid}  ${alias}=${EMPTY}
    [Teardown]  Run Keyword If   "${alias}"=="${EMPTY}"  Run Keyword And Ignore Error   Disconnect Interactive Connection   alias=${real_alias}
    ${real_alias}   Run Keyword If   "${alias}"=="${EMPTY}"   Connect To CU Node  pod_abbr=${pod_abbr}
       ...    ELSE   Set Variable   ${alias}
    ${ssh_command}   Set Variable   sudo crictl inspect --output yaml ${containerid}| grep 'pid:'|awk -F ':' '{print $2}'
    ${out}  issh.Execute  command=${ssh_command}  alias=${real_alias}
    ${out}  Strip Prompt  ${out}
    ${pid}   Set Variable  ${out.strip()}
    [Return]  ${pid}
RIC sctp port get
	[Documentation]		Get current SCTP port in RIC
    Log to console      \n Get current SCTP port in RIC
	ssh.Connect_to    ${RIC_ip}    ${RIC_username}    ${RIC_password}    alias=RIC_vm
	${port}	ssh.Execute
	...    command=kubectl get svc -A |grep -i sctp | awk '{print $6}'	connection=RIC_vm	timeout=30s
	${curr_sctp_port}    Get Substring    ${port}    6    11
	ssh.Disconnect		connection=RIC_vm
	Log To Console    current sctp port is ${curr_sctp_port}
	Set Suite Variable    ${curr_sctp_port}
	[Return]     ${curr_sctp_port}
CU SCF Modification and Commission with E2 interface enable
    RIC sctp port get
    ${E2enble_parameter}=    Create List
    ${sctpport_dict}=    Create Dictionary    dist_name=${NRNEARRTRIC}    p_name=nrNearRTRICSCTPPort	value=${curr_sctp_port}
    ${E2interface_dict}=    Create Dictionary    dist_name=${MR_NR_BTS_NAME}    p_name=actE2Interface	value=true
    Append To List     ${E2enble_parameter}    ${sctpport_dict}    ${E2interface_dict}
	${output_scf_file_path}    COAM Modify scf file    scf_file_path=${SCF_Template_path_CU_TL}    scf_parameters_list=${E2enble_parameter}
	CU Full Commission Fix Error    path_of_commission_file=${output_scf_file_path}
Adjust HBTE ATT Values seperate
    [Arguments]      ${attenuation_values_of_all_ports}     ${pa_index}=${0}
    ...    ${attenuation_port_numbers}=${1}    ${max_attenuation_value}=${127}
    log to console    Adjust HBTE ATT Value
    ${ip_addr}    set variable    ${tl.attenuators[${pa_index}].ip_addr}
    ${api_port}    set variable    ${tl.attenuators[${pa_index}].port}
    ${vendor}      set variable    ${tl.attenuators[${pa_index}].vendor}
    att.setup_attenuator    ip_addr=${ip_addr}    port=${api_port}
    ...    attenuation_port_numbers=${attenuation_port_numbers}   max_attenuation=${max_attenuation_value}    vendor=${vendor}
    FOR  ${port_num}    IN RANGE    0    4
        ${att_value}    set variable    ${attenuation_values_of_all_ports['atten_value_of_port${port_num}']}
        att.set_attenuation    port=${att_port_${pa_index}_${port_num}}    value=${att_value}
        ${value_port}    att.read_attenuation    port=${att_port_${pa_index}_${port_num}}
        should be equal    ${value_port}    ${att_value}
    END

validate RanFunction in wireshark
    [Documentation]  this keyword will validate 4 type msg RanFunction, every log please just catch one type
    ...   E2setupRequest    E2setupResponse
    ...   RICserviceUpdate    RICserviceUpdateAcknowledge
    ...   RICsubscriptionRequest    RICsubscriptionResponse
    ...    RICsubscriptionDeleteRequest     RICsubscriptionDeleteResponse
    [Arguments]   ${pcap_file}    ${msg1}    ${msg2}
    csn.Connect to    hostname=${tl.test_pc.default_ssh_connection_details.addr}
    ...               username=${tl.test_pc.default_ssh_connection_details.username}
    ...               password=${tl.test_pc.default_ssh_connection_details.password}
    ...               alias=ute
    ${output}	  csn.Execute   command=tshark -r ${pcap_file} -Y "e2ap"     connection=ute
    should contain    ${output}   ${msg1}
    should contain   ${output}   ${msg2}
    run keyword if    '${msg1}' in 'RICsubscriptionRequestRICsubscriptionResponseRICsubscriptionDeleteRequestRICsubscriptionDeleteResponse'
    ...     validate ran function ID for B   ${pcap_file}
    ...     ELSE   validate ran function ID for A   ${pcap_file}
    [Return]    ${RANfunctionID}
    [teardown]  csn.disconnect    connection=ute


validate ran function ID for B
    [Arguments]   ${pcap_file}
    ${output}	  csn.Execute   command=tshark -r ${pcap_file} -Y "e2ap" -T fields -e e2ap.RANfunctionID     connection=ute
    ${tmp}  Split String   ${output}  \r\n
    ${len}   get length   ${tmp[:-1]}
    should be true  ${len}==2
    should be true   ${tmp[0]}==${tmp[1]}
    set test variable  ${RANfunctionID}   ${tmp[0]}
    [Return]    ${RANfunctionID}


validate ran function ID for A
    [Arguments]   ${pcap_file}
    ${output}	  csn.Execute   command=tshark -r ${pcap_file} -Y "e2ap" -T fields -e e2ap.ranFunctionID     connection=ute
    ${tmp}  Split String   ${output}  \r\n
    ${len}   get length   ${tmp[:-1]}
    should be true  ${len}==2
    should be true   ${tmp[0]}==${tmp[1]}
    set test variable  ${RANfunctionID}   ${tmp[0]}
    [Return]    ${RANfunctionID}

Get wait value minutes
    [Arguments]    ${interval}
    ${interval_seconds}    Get Interval Seconds    ${interval}
    ${interval_minutes}    evaluate    ${interval_seconds}/60
    ${origin_time}    Get time from vCU
    ${origin_time}    convert_date    ${origin_time}   datetime
    ${minutes}    set variable    ${origin_time.minute}
    ${wait_time}    evaluate    ${interval_minutes}-${minutes}%${interval_minutes}+1
    [Return]    ${wait_time}

Get Interval Seconds
    [Documentation]  Author: tingting.zhong@nokia-sbell.com
    [Arguments]  ${interval}
    ${num}    get substring    ${interval}     0    -3
    ${num}    convert to integer    ${num}
    ${interval_seconds}    evaluate    ${num}*60
    [Return]  ${interval_seconds}

Get time from vCU
    [Arguments]    ${vdu_index}=0    ${gnb_index}=0   ${alias}=default
    ${alias}     Connect To CU K8S Master With Admin
    ${out}   issh.Execute    command=date +%F-%T    alias=${alias}  check_result=${False}
    ${lines}  Split To Lines  ${out}
    ${tmp}   set variable   ${lines}[1]
    ${date_time}    Strip String   ${tmp}
    [Return]    ${date_time}

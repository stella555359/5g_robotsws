*** Settings ***
Documentation    author: wang jiangrong
...              Group: RAN_PZ_HAZ3_SG02
...              contact: jiangrong.wang@nokia-sbell.com


Resource    ./emil.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/recommissioning_and_make_throughput.robot

*** Variables ***
#${dcapuser_addr}    ${tl.test_pcs[0].connection_details.addr}
#${dcapuser_username}    ${tl.test_pcs[0].connection_details.username}
#${dcapuser_password}    ${tl.test_pcs[0].connection_details.password}
${dcapuser_addr}    ${tl.host[0].default_ssh_connection_details.addr}
${dcapuser_username}    ${tl.host[0].default_ssh_connection_details.username}
${dcapuser_password}    ${tl.host[0].default_ssh_connection_details.password}

&{bts}      host=${tl.gnbs[0].dus[0].f1_m_ip_addr}    username=Nemuadmin    password=nemuuser    port=443
${ue_type}    samsung
${if_commissioning}    True

*** Keywords ***
Test Suite Setup
    Run     mkdir ${8523_log_dir}
    #${scf_path}=${CURDIR}/../../../../../commissionings/HGZ/${testline_name}/SCF_${gnb_release}.xml
    #Set Suite Variable    ${scf_path}
    SISO Coam Suite Setup

Test Suite Teardown
    #Restore DU SCF    ${scf_path}
    #Wait until keyword succeeds    10 min    30 sec
	#  ...    Du login page via webUI
    #Wait until keyword succeeds    15 min    30 sec
    #...    Du Check cell on air via WebUI without login
    #Run Keyword And Ignore Error    Close DU start up window
	#  DU COAM selenium logout
    Run   rm -rf ${emil_win_dir}; rm -rf ${downloaded_emil_file_path}
    SISO Coam Suite Teardown   

Create File path
    wait until keyword succeeds  10min   20s   Csn.Connect to   hostname=${cpc_host}
    ...   username=${cpc_user}    password=${cpc_password}
    ...    alias=cpc
    csn.Execute   command=mkdir -p ${emil_log_dir}     connection=cpc
    ${output}    csn.Execute   command=${emil_log_dir}      connection=cpc
    should contain    ${output}    Is a director
    [Teardown]  csn.Disconnect    connection=cpc

Clear temp file content
    log to console    \n  Delete Emil logs
    Csn.Connect to   hostname=${cpc_host}    username=${cpc_user}    password=${cpc_password}
    ...    alias=cpc
    csn.Execute    command=rm -rf ${emil_log_dir}     connection=cpc
    csn.Execute    command=rm -rf ${gnb_log_tool_win_path}/*.zip     connection=cpc
    [Teardown]    csn.Disconnect    connection=cpc

Enable traffic manager
   ${cmd_local} echo -e "[control]\nLoggingSeverity=trace" > /ffs/run/cp_runtime.ini
   ${cmd_enable_TM_config}    echo -e "[control]\n LoggingSeverity=trace \n [rnd]\n "
   ...                        rdEnableTrafficManager = True \n rdEnableUeIdRangeAllocationViaSdl= True \n"
   ...                        >/ffs/run/cp_runtime.ini
   ssh.execute    ${cmd_enable_TM_config}

Start DCAP log
    log to console    \n Start DCAP log
    DCAP.connect_to     host=${dcapuser_addr}    port=443     username=${dcapuser_username}
    ...     password=${dcapuser_password}     rd_version=dcapv3    secure=True
    ${gnb_custom_profile}=     Create List     cp_5g
    ${output}    DCAP.start_trace     bts=${bts}     gnb_custom_profile=${gnb_custom_profile}     wait_for_activation=${True}
    ...     control_plane_interface=${True}
    Log    ${output}[tracer_id]
    set test variable    &{output}

Stop DCAP log and convert to txt type
    log to console    \n Stop DCAP log and convert to txt type
    ${profile_file}    set variable    SourceProfile_PMI_Ticket.ini
    DCAP.stop_trace    trace_id=${output}[tracer_id]
    sleep    25m
    ${downloaded_emil_file_path}    DCAP.get_results    result_id=${output}[tracer_id]    target_dir=${TS_CASE_LOG_PATH}
    Convert emil log at cpc    local_emil_log_path=${downloaded_emil_file_path}    end_file=5gm
    set variable     ${downloaded_emil_file_path}

Validate Emil log is adaption to traffic manager
   log to console    begin to validate emil log
   #${TM_message}=          Grep File    ${output_txt_path}   CpIfReceiveFromDu
   #Should Contain                ${TM_message}      CpIfReceiveFromDu
   ${TM_message}=          Grep File    ${output_txt_path}   CpIfReceiveFromCore
   Should Contain                ${TM_message}      CpIfReceiveFromCore 

UE preparation for L3 call
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${0}
    Set Suite Variable    ${ue_type}
    power_ue.Prepare UE    ue_index=${0}    ue_type=${ue_type}

UE attach verify
    ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${0}    ue_type=${ue_type}    attach_mode=5G_NSA    log_type=Aasyslog
    ${status}    run keyword and return status    power_ue.Verify attach    ue_type=${ue_type}   5Grach_ed=${5Grach_ed_0}    4G_check=False
    run keyword if    ${status}==${False}    Fail    5G attach failed.
    [Return]    ${status}

UE dettach
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${0}
    Set Suite Variable    ${ue_type}
    power_ue.UE Detach    ue_index=${0}    ue_type=${ue_type}

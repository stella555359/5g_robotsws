*** Settings ***
Documentation    author: Deng Xueqin
...              Group: RAN_PZ_HAZ3_SG02
...              contact: xueqin.deng@nokia-sbell.com


Resource    ./emil.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot

*** Variables ***
${dcapuser_addr}    ${tl.test_pcs[0].connection_details.addr}
${dcapuser_username}    ${tl.test_pcs[0].connection_details.username}
${dcapuser_password}    ${tl.test_pcs[0].connection_details.password}
&{bts}      host=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
...    username=Nemuadmin    password=nemuuser    port=443
${ue_index_0}    0

*** Keywords ***
Test Suite setup
    ${stopstatus}    set variable    False

Test Suite Teardown
    run keyword if    '${stopstatus}'!='True'
    ...    run keyword and ignore error    DCAP.stop_trace    trace_id=${output}[tracer_id]
    run keyword and ignore error    Run    rm -rf ${downloaded_emil_file_path}; rm -rf ${output_txt_path}

CPE UE prepare
    log to console    \nPrepare UE
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index_0}
    Set Suite Variable    ${ue_type}
    power_ue.Prepare UE    ue_index=${ue_index_0}    ue_type=${ue_type}     power_reset=true

CPE UE attach and get UE ip
    log to console    \nAttach UE
    ${5Grach_ed_0}    power_ue.UE Attach
    ...    ue_index=${ue_index_0}    ue_type=${ue_type}    log_type=Aasyslog    attach_mode=5G_SA    power_reset=true
    sleep    6s
    spark.send_at_command_on_ue    command=at$qcrmcall=1,1     ue_alias=UE_${ue_index_0}
    power_ue.Verify attach    ue_type=${ue_type}   5Grach_ed=${5Grach_ed_0}    4G_check=False
    ${UE_IP}    spark.get_ue_ip_on_ue    ue_alias=UE_${ue_index_0}    apnaddress=${apn}    ue_mode=SA
    log to console    \nAttach success and UE ip: ${UE_IP}
    [Return]    ${UE_IP}

CPE UE detach
    log to console    \nDetach UE
    Power_ue.UE Detach    ue_index=${ue_index_0}    ue_type=${ue_type}    power_reset=true

Start DCAP log
    log to console    \n Start DCAP log
    DCAP.connect_to     host=${dcapuser_addr}    port=443     username=${dcapuser_username}
    ...     password=${dcapuser_password}     rd_version=dcapv3    secure=True
    ${gnb_custom_profile}=     Create List     cp_5g
    ${output}    DCAP.start_trace     bts=${bts}     gnb_custom_profile=${gnb_custom_profile}
    ...     wait_for_activation=${True}    control_plane_interface=${True}
    Log    ${output}[tracer_id]
    set suite variable    &{output}

Stop DCAP log and convert to txt type
    log to console    \n Stop DCAP log and convert to txt type
    ${profile_file}    set variable    SourceProfile_PMI_Ticket.ini
    ${stopstatus}    run keyword and return status    DCAP.stop_trace    trace_id=${output}[tracer_id]
    set suite variable    ${stopstatus}
    sleep    2m
    ${downloaded_emil_file_path}    DCAP.get_results    result_id=${output}[tracer_id]
    ...    target_dir=${TS_CASE_LOG_PATH}
    Convert emil log at cpc    local_emil_log_path=${downloaded_emil_file_path}    end_file=5gm
    set suite variable     ${downloaded_emil_file_path}

Check pcmd event in PMI ticket
    [Arguments]    ${event_name}
    log to console    begin to validate emil log
    ${pcmd_event}=    Grep File    ${output_txt_path}   ${event_name}
    Should Contain    ${pcmd_event}      ${event_name}

Check PMI ticket DuRrcSetup
    log to console    begin to check in emil log
    ${pcmd_event}=    Grep File    ${output_txt_path}   DuRrcSetup
    Should Contain    ${pcmd_event}      DuRrcSetup

Check PMI ticket DuBearer DRB-ID
    log to console    begin to check in emil log
    ${DrbIdList}=    Run     grep "DuBearer :" -A 20 ${output_txt_path} |grep "DrbId"  
    Should Contain   ${DrbIdList}    DrbId

Check PMI ticket DuCaConfig SCellId
    log to console    begin to check in emil log
    ${scell_list}    Create List    2048022    2048023    2048024    2048025    2048026    2048027    2048028
    ${ScellIdList}=    Run    grep "DuCaConfig :" -A 40 ${output_txt_path} |grep "SCellId"
    FOR   ${sCellId}   IN   @{scell_list}
       Should Contain    ${ScellIdList}      SCellId : ${sCellId}
    END

*** Settings ***
Documentation
...   author: Patryk Seman
...   contact: patryk.seman@nokia.com
...   This is the ROBOT KEYWORDS file for feature 5GC000728

Library     testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.tcpdump.tcpdump_smod.TcpdumpSmod   WITH NAME   TcpdumpSmod
Library     testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.admin_utils.AdminUtils    WITH NAME    AdminUtils
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/logs/btslog.py
Library     taf.epcsim   WITH NAME   epc
Resource    ./common_keywords.robot


*** Variables ***
${ue_deregistration_cmd}                    ue_deregister id=1 by=amf ue_deregister_type=normal
${epcsim_addr}                              ${tl.core.default_ssh_connection_details.addr}
${epcsim_username}                          ${tl.core.default_ssh_connection_details.username}
${epcsim_password}                          ${tl.core.default_ssh_connection_details.password}
${epcsim_directory}                         ${tl.core.dir_path}
${epcsim_egate_port}                        ${tl.core.egate_port}
${epcsim_edaemon_port}                      ${tl.core.edaemon_port}


*** Keywords ***
[1]5GC000728_AF_2_20MHz_FDD_SA_Classical_UE_detach_Network_initiated_without_Traffic
    Setup and check preconditions in scf    params_to_check=${scf_params_AF_2}   bandwidth=20
    Require Ue   UE_1   capabilities=REAL_ANDROID_UE
    Attach Ue    UE_1
    TcpdumpSmod.start_tcpdump_on_smod    smod_master=${true}    smod_slave=${tl.smod_slave}
    BuiltIn.Sleep   10s   reason=Gather logs
    Trigger RRC Idle from AMF
    ${file_path}=   TcpdumpSmod.stop_tcpdump_and_download_logs_from_smod
    Analyze detach from log given log   ${file_path}
    [Teardown]   Detach Ue    UE_1


[1]5GC000728_AF_5_15MHz_FDD_SA_Classical_UE_Reattach_Ue_initiated_without_Traffic
    Setup and check preconditions in scf    params_to_check=${scf_params_AF_5}   bandwidth=15
    Lock all cells except random one
    Require Ue   UE_1   capabilities=REAL_ANDROID_UE
    Attach Ue    UE_1
    TcpdumpSmod.start_tcpdump_on_smod    smod_master=${true}    smod_slave=${tl.smod_slave}
    Collect logs from detach
    Collect logs from attach
    ${file_path}=   TcpdumpSmod.stop_tcpdump_and_download_logs_from_smod
    Analyze reattach from log given log   ${file_path}
    [Teardown]   Run Keywords
    ...          Detach Ue    UE_1     AND
    ...          AdminUtils.unlock_all_cells


[1]5GC000728_B_2_20MHz_FDD_SA_Classical_UE_Activity_not_active_Without_Traffic
    Setup and check preconditions in scf    params_to_check=${scf_params_B_2}   bandwidth=20
    Lock all cells except random one
    Assign inactivity timer
    Require Ue   UE_1   capabilities=REAL_ANDROID_UE

    TcpdumpSmod.start_tcpdump_on_smod    smod_master=${true}    smod_slave=${tl.smod_slave}
    Attach Ue   UE_1
    ${attach_time}=   Get time from ASIK
    Wait till UE will entered IDLE state
    ${file_path}=   TcpdumpSmod.stop_tcpdump_and_download_logs_from_smod

    Check if UE goes to idle at correct time   log_file=${file_path}   inactivity_start_time=${attach_time}
    [Teardown]   Run Keywords
    ...          Detach Ue    UE_1     AND
    ...          AdminUtils.unlock_all_cells


[1]5GC000728_B_3_10MHz_FDD_SA_Classical_UE_Activity_Active_With_Traffic
    Setup and check preconditions in scf    params_to_check=${scf_params_B_3}   bandwidth=10
    Lock all cells except random one
    Assign inactivity timer
    ${traffic_time}=      Evaluate  ${drbInactivityTimerSA} - ${srbInactivityTimerSA} + 20
    Require Ue   UE_1   capabilities=REAL_ANDROID_UE

    TcpdumpSmod.start_tcpdump_on_smod    smod_master=${true}    smod_slave=${tl.smod_slave}
    Attach Ue   UE_1
    Start Data Transfer   dt_name=DT_DL            ue_alias=UE_1
    ...                   direction=dl             duration=10s
    ...                   packet_size=1200         buffer=4M
    ...                   throughput=20Mbits/sec   protocol=tcp
    Await Data Transfer Finish  DT_DL
    BuiltIn.Sleep   ${srbInactivityTimerSA}   reason=Sleep till ue entered between two timers
    Start Data Transfer   dt_name=DT_DL            ue_alias=UE_1
    ...                   direction=dl             duration=${traffic_time}s
    ...                   packet_size=1200         buffer=4M
    ...                   throughput=20Mbits/sec   protocol=tcp
    Await Data Transfer Finish  DT_DL
    ${attach_time}=   Get time from ASIK
    Wait till UE will entered IDLE state
    ${file_path}=   TcpdumpSmod.stop_tcpdump_and_download_logs_from_smod

    Check if UE goes to idle at correct time   log_file=${file_path}   inactivity_start_time=${attach_time}
    [Teardown]   Run Keywords
    ...          Detach Ue    UE_1  AND
    ...          AdminUtils.unlock_all_cells


Trigger RRC Idle from AMF
    Send command from WTS EGATE CLI   command=${ue_deregistration_cmd}
    BuiltIn.Sleep   50s   reason=Logs collecting


Connect to egate telnet
    [Arguments]         ${alias}=egate
    ...                 ${hostname}=${epcsim_addr}
    ...                 ${username}=${epcsim_username}
    ...                 ${password}=${epcsim_password}
    ...                 ${epcsim_directory}=${epcsim_directory}
    ...                 ${egate_port}=${epcsim_egate_port}
    ...                 ${ssh_port}=22
    epc.Setup Egate     ${egate_port}
    ...                 ${hostname}
    ...                 tool_dir=${epcsim_directory}
    ...                 ssh_user=${username}
    ...                 ssh_pass=${password}
    ...                 ssh_port=${ssh_port}
    ...                 ssh_prompt=\$
    ...                 alias=${alias}


Send command from WTS EGATE CLI
    [Arguments]         ${command}
    ...                 ${hostname}=${epcsim_addr}
    ...                 ${username}=${epcsim_username}
    ...                 ${password}=${epcsim_password}
    ...                 ${epcsim_directory}=${epcsim_directory}
    ...                 ${egate_port}=${epcsim_egate_port}
    ...                 ${ssh_port}=22
    ...                 ${epcsim_connection_alias}=egate
    ...                 ${timeout}=500

    epc.Setup Egate     ${egate port}
    ...                 ${hostname}
    ...                 tool_dir=${epcsim directory}
    ...                 ssh_user=${username}
    ...                 ssh_pass=${password}
    ...                 ssh_port=${ssh_port}
    ...                 ssh_prompt=\$
    ...                 alias=${epcsim_connection_alias}

    ${output}=          epc.Execute Egate Command And Wait For Data
    ...                 cmd=${command}
    ...                 timeout=${timeout}
    ...                 alias=${epcsim_connection_alias}
    [Return]            ${output}


Collect logs from detach
    BuiltIn.Sleep   30s   reason=Gather logs
    Detach Ue    UE_1
    BuiltIn.Sleep   30s   reason=Gather logs


Collect logs from attach
    BuiltIn.Sleep   30s   reason=Gather logs
    Attach Ue    UE_1
    BuiltIn.Sleep   30s   reason=Gather logs


Upload epcsim scf
    ${orig_scf}=   AdminUtils.download current scf
    Set suite variable   ${original_scf_file}   ${orig_scf}
    AdminUtils.perform_commissioning   scf_file=${epcsim_scf_config}
    AdminUtils.wait_for_all_cells_on_air_state
    Send command from WTS EGATE CLI    command=re
    Send command from WTS EGATE CLI    command=cfg_sim file=${epcsim_cfg_filename}
    Send command from WTS EGATE CLI    command=start


TC_teardown_728
    TcpdumpSmod.teardown_tcpdump_on_smod
    Run keyword if test failed    AdminUtils.collect_snapshot
    stop_and_collect_btslog

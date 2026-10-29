*** Settings ***
Documentation    Author: tomasz.blaszczyszyn@nokia.com; kacper.halas@nokia.com; filip.radwanski@nokia.com
...              Maintainer: tomasz.blaszczyszyn@nokia.com; kacper.halas@nokia.com; filip.radwanski@nokia.com
Library    ute_wtssim

*** Variables ***
${WTSSIM_EDAEMON1_ALIAS}=               edaemon1
${WTSSIM_EDAEMON2_ALIAS}=               edaemon2
${WTSSIM_EDAEMON_PORT_DL}=              10000
${WTSSIM_EDAEMON_PORT_UL}=              30000
${WTSSIM_EGATE_CONFIG_DIR}=             testsuite/Bangalore/ORAN/resources/BOAM_ET_resources/configurations/lua_scripts
${WTSSIM_EGATE_LUA_DIR}=                /home/ute/test_repository/testsuite/legacy/UTE/configuration/wtssim_config
${WTSSIM_EGATE_PORT}=                   20000
${WTSSIM_CALL_DURATION}=                30
${WTSSIM_MIN_ALLOWED_THROUGHPUT_MBPS}=  1
${WTSSIM_MME_CONNECTION_TIMEOUT}=       600
${WTSSIM_S1_INTERFACE}=                 eth3
${WTSSIM_THROUGHPUT_SIZE_MBPS}=         2
${WTSSIM_TRANSFER_DIRECTION}=           dl
${WTSSIM_TSHARK_ALIAS}=                 tshark_call
${WTSSIM_TSHARK_LOGNAME}=               tshark_call
${WTSSIM_HOST_IP}=                      127.0.0.1


*** Keywords ***
Check Tshark parameters for calls with cell drop
   ${attach_request}=   get_packets_count   packet_filter=nas_eps.emm.eps_att_type == 1   alias=${tshark_alias_name}
   ${attach_complete}=   get_packets_count   packet_filter=nas_eps.nas_msg_emm_type == 0x43   alias=${tshark_alias_name}
   Should be True   '${attach_request}'=='${cells_number}' and '${attach_complete}'=='${cells_number}'
   ${context_release_cmd}=   get_packets_count   packet_filter=s1ap.nas == 2   alias=${tshark_alias_name}
   ${context_release_cmd&comp}=   get_packets_count   packet_filter=s1ap.procedureCode == 23   alias=${tshark_alias_name}
   ${context_release_cmd&comp_from_cells_number}=   evaluate   2 * ${cells_number}
   ${call_reset}=   get_packets_count        packet_filter=s1ap.procedureCode == 14   alias=${tshark_alias_name}
   Should be True   ${call_reset}>${0}
   #original
   Should be True   ${context_release_cmd}>=${cells_number} and ${context_release_cmd&comp}>=${context_release_cmd&comp_from_cells_number}
#   ${call_reset_2}=    evaluate  (${call_reset} / 2)
#   ${context_release_cmd&call_reset_2}=    evaluate   (${context_release_cmd} + ${call_reset_2})
#   ${ue_and_drop_ue}=    evaluate   (${cells_number} + ${cell_drop_by_unit})
#   Should be True   '${context_release_cmd&call_reset_2}'=='${ue_and_drop_ue}'
   Stop capturing  alias=${tshark_alias_name}
   [Teardown]    Teardown tshark  alias=${tshark_alias_name}

Check Tshark parameters for calls with cell drop eNB recovery reset
   ${attach_request}=   get_packets_count   packet_filter=nas_eps.emm.eps_att_type == 1   alias=${tshark_alias_name}
   ${attach_complete}=   get_packets_count   packet_filter=nas_eps.nas_msg_emm_type == 0x43   alias=${tshark_alias_name}
#   Should be True   '${attach_request}'=='${cells_number}' and '${attach_complete}'=='${cells_number}'
   Should be True   '${attach_complete}'=='${cells_number}'
   ${context_release_cmd}=   get_packets_count   packet_filter=s1ap.nas == 2   alias=${tshark_alias_name}
   ${context_release_cmd&comp}=   get_packets_count   packet_filter=s1ap.procedureCode == 23   alias=${tshark_alias_name}
   ${context_release_cmd&comp_from_cells_number}=   evaluate   2 * ${cells_number}
   Should be True   '${context_release_cmd}'<='${cells_number}' and '${context_release_cmd&comp}'<='${context_release_cmd&comp_from_cells_number}'
   ${call_reset}=   get_packets_count        packet_filter=s1ap.procedureCode == 14   alias=${tshark_alias_name}
   Should be True   ${call_reset}>=${0}
   Stop capturing  alias=${tshark_alias_name}
   [Teardown]    Teardown tshark  alias=${tshark_alias_name}

WTSSIM Attach UEs And Start Data Transfer
    [Arguments]    ${UEs_id_list}
    ...            ${throughput_size_Mbps}
    ...            ${cells_number}
    ...            ${direction}
    ...            ${bearer_id}=1
    FOR  ${id}  IN RANGE  ${cells_number}
       Execute Egate Command  cmd=ue_param id=@{UEs_id_list}[${id}] reuse_security_context=false
       Execute Egate Command  cmd=ue_attach id=@{UEs_id_list}[${id}]
       Sleep   10
       Execute Egate Command  cmd=trf_data_start ue=@{UEs_id_list}[${id}] id=${bearer_id} dir=${direction} mbps=${throughput_size_Mbps}
       Sleep   10
    END

WTSSIM Calculate UE Ids
    [Arguments]    ${cells_number}
    @{UEs_id_list}=  Create List
    FOR  ${id}  IN RANGE  ${cells_number}
      ${UE_id}=  Evaluate  ${id} * 20 + 10
      Append To List  ${UEs_id_list}  ${UE_id}
    END
	[Return]    @{UEs_id_list}

WTSSIM Check Call Parameters In Every Cell
    [Arguments]    ${min_allowed_throughput_Mbps}
    ...            ${tshark_alias_name}
    ...            ${UEs_parameters}
    ...            ${cells_number}=${OUT_ADMIN_LNCELS_AMOUNT}
    WTSSIM Check Call Parameters With Tshark  cells_number=${cells_number}  tshark_alias_name=${tshark_alias_name}
    @{UEs_throughputs}=    WTSSIM Get Call Throughput from UEs parameters  cells_number=${cells_number}  UEs_parameters=@{UEs_parameters}
    WTSSIM Compare Call Throughput With Minimum Allowed
    ...  cells_number=${cells_number}  min_allowed_throughput_Mbps=${min_allowed_throughput_Mbps}  UEs_throughputs=@{UEs_throughputs}

WTSSIM Check Call Parameters With Tshark
    [Arguments]    ${tshark_alias_name}
    ...            ${cells_number}
    ${attach_request}=   Get Packets Count   packet_filter=nas_eps.emm.eps_att_type == 1   alias=${tshark_alias_name}
    ${attach_complete}=   Get Packets Count   packet_filter=nas_eps.nas_msg_emm_type == 0x43   alias=${tshark_alias_name}
    Should be True   '${attach_request}'=='${cells_number}' and '${attach_complete}'=='${cells_number}'
    ${context_release_cmd}=   Get Packets Count   packet_filter=s1ap.nas == 2   alias=${tshark_alias_name}
    ${context_release_cmd&comp}=   Get Packets Count   packet_filter=s1ap.procedureCode == 23   alias=${tshark_alias_name}
    ${context_release_cmd&comp_from_cells_number}=   evaluate   2 * ${cells_number}
    Should be True   '${context_release_cmd}'=='${cells_number}' and '${context_release_cmd&comp}'=='${context_release_cmd&comp_from_cells_number}'

WTSSIM Compare Call Throughput With Minimum Allowed
    [Arguments]    ${UEs_throughputs}
    ...            ${cells_number}
    ...            ${min_allowed_throughput_Mbps}
    FOR   ${id}   IN RANGE   ${cells_number}
      ${throughput_unit}=   Fetch From Right  string=@{UEs_throughputs}[${id}]  marker=${SPACE}
      ${throughput_value}=  Fetch From Left   string=@{UEs_throughputs}[${id}]  marker=${SPACE}
      Should be True   '${throughput_unit}'=='M' and '${throughput_value}'>='${min_allowed_throughput_Mbps}'
    END

WTSSIM Detach Every UE
    [Arguments]    ${UEs_id_list}
    ...            ${cells_number}
    FOR  ${id}  IN RANGE  ${cells_number}
      Execute Egate Command    cmd=ue_detach id=@{UEs_id_list}[${id}]
      Sleep   5
    END
WTSSIM Get Call Throughput From UEs Parameters
    [Arguments]    ${UEs_parameters}
    ...            ${cells_number}
    @{UEs_throughputs}=  create_list
    FOR  ${id}  IN RANGE  ${cells_number}
      ${throughput}=  Get Lines Containing String   string=@{UEs_parameters}[${id}]    pattern=Average data rate
      ${throughput}=  Fetch From Right   string=${throughput}   marker=(
      ${throughput}=  Fetch From Left   string=${throughput}   marker=)
      Append To List   ${UEs_throughputs}   ${throughput}
    END
	[Return]    @{UEs_throughputs}

WTSSIM Get UEs Parameters
    [Arguments]    ${UEs_id_list}
    ...            ${cells_number}
    ...            ${direction}
    ...            ${bearer_id}=1
    @{UEs_Parameters}=   create_list
    FOR  ${id}  IN RANGE  ${cells_number}
      ${UE_Parameters}=  Execute Egate Command And Wait For Data  cmd=bearer_stats ue=@{UEs_id_list}[${id}] id=${bearer_id} dir=${direction}
      Append To List  ${UEs_Parameters}  ${UE_Parameters}
    END
	[Return]    @{UEs_parameters}

WTSSIM Kill Edaemon And Egate
    Run Keyword And Ignore Error    WTSSIM Teardown Egate And Edaemons
    Run Keyword And Ignore Error    Run   sudo killall edaemon
    Run Keyword And Ignore Error    Run   killall egate

WTSSIM Make Call In Every Cell And Check Parameters
    [Arguments]    ${interface}=${WTSSIM_S1_INTERFACE}
    ...            ${call_duration}=${WTSSIM_CALL_DURATION}
    ...            ${cells_number}=${OUT_ADMIN_LNCELS_AMOUNT}
    ...            ${direction}=${WTSSIM_TRANSFER_DIRECTION}
    ...            ${min_allowed_throughput_Mbps}=${WTSSIM_MIN_ALLOWED_THROUGHPUT_MBPS}
    ...            ${throughput_size_Mbps}=${WTSSIM_THROUGHPUT_SIZE_MBPS}
    ...            ${tshark_alias_name}=${WTSSIM_TSHARK_ALIAS}
    ...            ${tshark_logname}=${WTSSIM_TSHARK_LOGNAME}
    LOGGING Start Tshark    interface=${interface}  tshark_alias_name=${tshark_alias_name}  tshark_logname=${tshark_logname}
    @{UEs_parameters}=  WTSSIM Make Call In Every Cell
    ...  call_duration=${call_duration}  direction=${direction}  cells_number=${cells_number}  throughput_size_Mbps=${throughput_size_Mbps}
    WTSSIM Check Call Parameters In Every cell
    ...  min_allowed_throughput_Mbps=${min_allowed_throughput_Mbps}  tshark_alias_name=${tshark_alias_name}  UEs_parameters=@{UEs_parameters}
    LOGGING Stop Tshark    tshark_alias_name=${tshark_alias_name}

WTSSIM Make Call In Every Cell
    [Arguments]    ${call_duration}
    ...            ${direction}
    ...            ${throughput_size_Mbps}
    ...            ${cells_number}=${WTSSIM_CELLS_NUMBER}
    @{UEs_id_list}=    WTSSIM Calculate UE ids  cells_number=${cells_number}
    WTSSIM Attach UEs And Start Data Transfer
    ...  cells_number=${cells_number}  direction=${direction}  throughput_size_Mbps=${throughput_size_Mbps}  UEs_id_list=@{UEs_id_list}
    Sleep  ${call_duration}
    @{UEs_parameters}=    WTSSIM Get UEs Parameters  cells_number=${cells_number}  direction=${direction}  UEs_id_list=@{UEs_id_list}
    Sleep    5
    WTSSIM Stop Data Transfer For Every UE  cells_number=${cells_number}  direction=${direction}  UEs_id_list=@{UEs_id_list}
    WTSSIM Detach Every UE  cells_number=${cells_number}  UEs_id_list=@{UEs_id_list}
    Sleep    10
    [Return]    @{UEs_parameters}

WTSSIM S1 Link Establish
    [Arguments]    ${cells_number}=${OUT_ADMIN_LNCELS_AMOUNT}
    ...            ${egate_port}=${WTSSIM_EGATE_PORT}
    ...            ${edaemon_port_dl}=${WTSSIM_EDAEMON_PORT_DL}
    ...            ${edaemon_port_ul}=${WTSSIM_EDAEMON_PORT_UL}
    ...            ${edaemon1_alias}=${WTSSIM_EDAEMON1_ALIAS}
    ...            ${edaemon2_alias}=${WTSSIM_EDAEMON2_ALIAS}
    ...            ${mme_connection_timeout}=${WTSSIM_MME_CONNECTION_TIMEOUT}
    ...            ${egate_config_dir}=${WTSSIM_EGATE_CONFIG_DIR}
    ...            ${egate_lua_dir}=${WTSSIM_EGATE_LUA_DIR}
    WTSSIM Kill Edaemon And Egate
    ${egate_config_path}=    Set Variable    ${egate_config_dir}/${cells_number}_cells_configuration.lua
    Setup Egate             egate_port=${egate_port}
    Setup Edaemon           edaemon_port=${edaemon_port_dl}    host_ip=${WTSSIM_HOST_IP}    alias=${edaemon1_alias}
    Setup Edaemon           edaemon_port=${edaemon_port_ul}    host_ip=${WTSSIM_HOST_IP}    alias=${edaemon2_alias}
    Link Edaemons To Egate  ${edaemon1_alias}    ${edaemon2_alias}
    Add Egate Lua Dirs      ${egate_lua_dir}
    Start Egate Process     cfg_file=${egate_config_path}    timeout=${mme_connection_timeout}
    Start Egate Services    timeout=${mme_connection_timeout}
    Execute Egate Command   cmd=mme_param id=1 full_nas_auth=yes

WTSSIM Start Egate
    [Arguments]    ${mme_connection_timeout}=${WTSSIM_MME_CONNECTION_TIMEOUT}
    Start egate services  timeout=${mme_connection_timeout}

WTSSIM Stop Data Transfer For Every UE
    [Arguments]    ${UEs_id_list}
    ...            ${cells_number}
    ...            ${direction}
    ...            ${bearer_id}=1
    FOR   ${id}   IN RANGE   ${cells_number}
       Execute Egate Command    cmd=trf_data_stop ue=@{UEs_id_list}[${id}] id=${bearer_id} dir=${direction}
       Sleep   5
    END

WTSSIM Teardown Egate And Edaemons
    Teardown All Aliases For Egate
    Teardown All Aliases For Edaemon


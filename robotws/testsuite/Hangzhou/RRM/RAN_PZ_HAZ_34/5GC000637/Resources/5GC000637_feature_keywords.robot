*** Settings ***
Documentation     author: shuiqin.chu & cris.cai
...                 contact: shuiqin.chu@nokia-sbell.com
...                 squad group: SG_03
...                 feature : 5GC000637
Library           OperatingSystem
Library           Collections
Library           taf.transport.ssh    WITH NAME    csn
Library           taf.gnb.entities.bb2    WITH NAME    bb2lib
Library           taf.config.scf    WITH NAME    scf
#Library           ../../../../../resources/python_libs/TestCaseRequirement.py
#Library           ../../../../../resources/python_libs/cells.py    #this file keywords location not case file
#Library           ../../../../../resources/python_libs/systemd.py
#Library           ../../../../../resources/python_libs/verify_rf.py
Resource    taf/rfrl/common_resources/robot/preconditions.robot
Library           taf.pdu    WITH NAME    pdu
#Resource          ../../../../../resources/common/DEPRECATED/bts.robot
Resource    taf/rfrl/common_resources/robot/connections.robot
Resource    taf/rfrl/common_resources/robot/gnb_classical.robot
Resource    taf/rfrl/common_resources/robot/connection_alias_store.robot
Resource          Common_intergration_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot

*** Variables ***
${LOCAL_MASTER_IP}    ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${PEER_MASTER_IP}     ${tl.gnbs[1].cu.oam_http_connection_details.addr}
${WEBUI_NAME}         ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PWD}          ${tl.gnbs[0].cu.oam_http_connection_details.password}
${pdu_gnb_addr}       ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu.addr}
@{pdu_gnb_port}       ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.port_no}
${WEBUI_COAM_LOCAL}    https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_COAM_PEER}     https://${tl.gnbs[1].cu.oam_http_connection_details.addr}
@{tl_scf_file_name}    scf_100.xml    scf_101.xml
${log_dir}            /tmp/node_
${log_name}           /tmp/startup_DEFAULT.log
${tl_scf_dir_path}    /home/ute/projects/xnlog/
${gnb_path}           /tmp/
${epc_log_path}       /home/ute/projects/xnlog/
${xnlogname}          xnap.pcap
@{admin_state}        Unlocked    Locked
@{gNB_ID}             ${tl.gnbs[0].instance_id}    ${tl.gnbs[1].instance_id}
@{xn_ip}     ${tl.gnbs[0].cu.oam_http_connection_details.addr}    ${tl.gnbs[1].cu.oam_http_connection_details.addr}
${distname_id_1}      MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].instance_id}
${distname_id_2}      MRBTS-${tl.gnbs[1].instance_id}/NRBTS-${tl.gnbs[1].instance_id}
${obiect_1}           NRBTS-${tl.gnbs[0].instance_id}
${obiect_2}           NRBTS-${tl.gnbs[1].instance_id}
${xnLinkStatus_dist_name_1}    ${distname_id_1}/XNLINK-1
${xnLinkStatus_dist_name_2}    ${distname_id_2}/XNLINK-1
@{xnstatus}           available    unavailable
@{NGRAN_filter}     xnap.XnAP_PDU == 0 and xnap.procedureCode == 18
...    xnap.XnAP_PDU == 1 and xnap.procedureCode == 18
@{XN_filter}     xnap.XnAP_PDU == 0 and xnap.procedureCode == 17
...    xnap.XnAP_PDU == 1 and xnap.procedureCode == 17
@{XNRESET_filter}     xnap.XnAP_PDU == 0 and xnap.procedureCode == 20
...    xnap.XnAP_PDU == 1 and xnap.procedureCode == 20

*** Keywords ***
Common Suite Setup for COAM
    COAM Create log directory    ${False}
    ${time_stamp}    Get current date    result_format=%Y%m%d%H%M%S
    Set Suite Variable    ${epc_log_path}    ${LOG_PATH}/${time_stamp}/
    Create directory    ${epc_log_path}

Get gnb release
    wait until keyword succeeds    1min    10s    Connect to Common Unit Master    alias=release_info
    ${info}   csn.Execute    ls /ffs/run/TargetBD*xml    connection=release_info
#    ${release_info}     set variable    ${info.split('_')[1]}
    ${release_info}     set variable    ${info.split('_')[1]}_${info.split('_')[2]}_${info.split('_')[3]}
    [Return]    ${release_info}
    [Teardown]   csn.Disconnect   connection=release_info

Modify the administrative state for Local gNB
    [Arguments]    ${admin_state}    ${local_distname}
    Modify new parameter value for gNB    url=${WEBUI_COAM_LOCAL}    dist_name=${local_distname}/NRADJGNB-1
    ...    filter_name=Administrative state    new_value=${admin_state}

Modify the administrative state for Peer gNB
    [Arguments]    ${admin_state}    ${peer_distname}
    Modify new parameter value for gNB    url=${WEBUI_COAM_PEER}    dist_name=${peer_distname}/NRADJGNB-1
    ...    filter_name=Administrative state    new_value=${admin_state}

Login coam webui
    [Arguments]    ${WEBUI_COAM}
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}

Get bts counter
    [Arguments]    ${counter_id}    ${full_path}
    ${res}    selenium_coam.get_bts_counters_info    counter_id=${counter_id}    full_path=${full_path}
    ${values}    get dictionary values   ${res}
    [return]    ${values}

check IE wireshark log for xn setup request message
    [Arguments]    ${xnlogname}    ${plmn}=62f230    ${tac_exp}=0000c8    ${band_log}=0028
    check IE value in tcpdump file for xn setup messages    xnlogname=${xnlogname}    filter=${XN_filter}[0]
    ...    plmn=${plmn}    tac_exp=${tac_exp}    band_log=${band_log}

check IE wireshark log for xn setup response message
    [Arguments]    ${xnlogname}    ${plmn}=62f230    ${tac_exp}=0000c8    ${band_log}=0028
    check IE value in tcpdump file for xn setup response messages    xnlogname=${xnlogname}    filter=${XN_filter}[1]
    ...    plmn=${plmn}    tac_exp=${tac_exp}    band_log=${band_log}

check IE value in tcpdump file for xn setup response messages
    [Arguments]     ${xnlogname}    ${filter}    ${plmn}=62f230    ${tac_exp}=0000c8    ${band_log}=0028
    cap.read_cap      cap_file=${epc_log_path}${xnlogname}    display_filter=xnap
    ${Message_Type} =    Catenate    ${filter}
    cap.Check Expression    condition_expression=${Message_Type}
    ${plmn_id} =    cap.get_element_value    element_expression=xnap.plmn_id
    ...    condition_expression=${filter}    element_idx=${0}
    should be equal    ${plmn_id[0]}    ${plmn}
    ${band} =    cap.get_element_value    element_expression=xnap.nr_frequency_band
    ...    condition_expression=${filter}    element_idx=${0}
    should be equal    ${band[0]}    ${band_log}
    ${tac} =    cap.get_element_value    element_expression=xnap.tac
    ...    condition_expression=${filter}    element_idx=${1}
    should be equal    ${tac[0]}    ${tac_exp}

check IE value in tcpdump file for xn setup messages
    [Arguments]     ${xnlogname}    ${filter}    ${plmn}=62f230    ${tac_exp}=0000c8    ${band_log}=0028
    cap.read_cap      cap_file=${epc_log_path}${xnlogname}    display_filter=xnap.AMF_Region_Information
    ${Message_Type} =    Catenate    ${filter}
    cap.Check Expression    condition_expression=${Message_Type}
    ${plmn_id} =    cap.get_element_value    element_expression=xnap.plmn_id
    ...    condition_expression=${filter}    element_idx=${0}
    should be equal    ${plmn_id[0]}    ${plmn}
    ${band} =    cap.get_element_value    element_expression=xnap.nr_frequency_band
    ...    condition_expression=${filter}    element_idx=${0}
    should be equal    ${band[0]}    ${band_log}
    ${tac} =    cap.get_element_value    element_expression=xnap.tac
    ...    condition_expression=${filter}    element_idx=${1}
    should be equal    ${tac[0]}    ${tac_exp}
    ${amf_region_id} =    cap.get_element_value    element_expression=xnap.amf_region_id
    ...    condition_expression=${filter}    element_idx=${0}
    should be equal    ${amf_region_id[0]}    01

COAM BTS Unlock
    [Arguments]    ${WEBUI_COAM}
    Run Keyword And Ignore Error    selenium_coam.logout
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    selenium_coam.disable_message_box
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    selenium_coam.unlock_bts
    sleep    35s
    selenium_coam.logout

lock and unlock Cell info for gNB
   [Arguments]     ${coam_url}    ${admin_state}
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${coam_url}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    selenium_coam.set_parameter_value    dist_name=${distname_id_1}/NRCELL-1
    ...    filter_param=Administrative state
    ...    new_value=${admin_state}
    sleep    3s
    selenium_coam.validate_plan
    sleep    6s
    selenium_coam.activate_plan    activate_plan_despite_errors=True
    selenium_coam.logout

lock Cell info for gNB
    [Arguments]    ${WEBUI_COAM}    ${cell_id}
    Run Keyword And Ignore Error    selenium_coam.logout
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    selenium_coam.disable_message_box
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    selenium_coam.lock_cell    cell_idx=${cell_id}
    sleep    35s
    selenium_coam.logout

unlock Cell info for gNB
    [Arguments]    ${WEBUI_COAM}    ${cell_id}
    Run Keyword And Ignore Error    selenium_coam.logout
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    selenium_coam.disable_message_box
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    selenium_coam.unlock_cell    cell_idx=${cell_id}
    sleep    35s
    selenium_coam.logout

Reset Gnb
    Restart gNB on webUI    WEBUI_COAM=${WEBUI_COAM_LOCAL}
    Restart gNB on webUI    {WEBUI_COAM=${WEBUI_COAM_PEER}
    sleep    5mins

Restart gNB on webUI
    [Arguments]    ${WEBUI_COAM}
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    selenium_coam.disable_message_box
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    selenium_coam.reset_site
    selenium_coam.logout

Check XNLINK status for both gNB on webUI
    [Arguments]    ${xn_status}
    Check parameter should be correct for gNB    value=${xn_status}    url=${WEBUI_COAM_LOCAL}
    ...    dist_name=${xnLinkStatus_dist_name_1}    filter_param=XnC link status

Modify new parameter value for gNB
    [Arguments]    ${url}    ${dist_name}    ${filter_name}    ${new_value}
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${url}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    #selenium_coam.disable_message_box
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    selenium_coam.set_parameter_value    dist_name=${dist_name}    filter_param=${filter_name}    new_value=${new_value}
    sleep    3s
    selenium_coam.validate_plan
    sleep    5s
    selenium_coam.activate_plan    activate_plan_despite_errors=True
    sleep    5s
    selenium_coam.logout
    selenium_coam.disable_virtual_display

Check parameter should be correct for gNB
    [Arguments]    ${value}    ${url}    ${dist_name}    ${filter_param}
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${url}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    #selenium_coam.disable_message_box
    #${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    #Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    sleep    5s
    ${Para_value}=    selenium_coam.get_parameter_value    dist_name=${dist_name}    filter_param=${filter_param}
    selenium_coam.logout
    Should Be Equal    ${Para_value}    ${value}

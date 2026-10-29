*** Settings ***
Documentation     author: cris.cai
...                 contact: cris.cai@nokia-sbell.com
...                 squad group: SG_03
...                 feature : 5GC000637
Library           OperatingSystem
Library           Collections
Library           taf.transport.ssh    WITH NAME    csn
Library           taf.gnb.entities.bb2    WITH NAME    bb2lib
Library           taf.config.scf    WITH NAME    scf
#Library           ../../../../../resources/python_libs/TestCaseRequirement.py
#Library           ../../../../../resources/python_libs/cells.py
#Library           ../../../../../resources/python_libs/systemd.py
#Library           ../../../../../resources/python_libs/verify_rf.py
Resource          taf/rfrl/common_resources/robot/preconditions.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Library           taf.pdu    WITH NAME    pdu
#Resource          ../../../../../resources/common/DEPRECATED/bts.robot
Resource          taf/rfrl/common_resources/robot/connections.robot
Resource          taf/rfrl/common_resources/robot/gnb_classical.robot
Library           taf.sbts.oam.coam.admin   WITH NAME    coam
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
${distname_id_1}      MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].instance_id}
${distname_id_2}      MRBTS-${tl.gnbs[1].instance_id}/NRBTS-${tl.gnbs[1].instance_id}
@{tl_scf_file_name}    scf_100.xml    scf_101.xml
${log_dir}            /tmp/node_
${log_name}           /tmp/startup_DEFAULT.log
${tl_scf_dir_path}    /opt/workspace/CIT/Master/SCF_file/cris/projects/xnlog/
${gnb_path}           /tmp/
${epc_log_path}       /opt/workspace/CIT/Master/SCF_file/cris/projects/xnlog/
${mcc}               ${tl.core.mcc}
${mnc}               ${tl.core.mnc}
${tac}               ${tl.core.tac}
@{length}            22     32


*** Keywords ***
Delete all NRADJGNB object
    Delete NRADJGNB object on gnb    url=${WEBUI_COAM_PEER}    distname_ID=${distname_id_2}
    Delete NRADJGNB object on gnb    url=${WEBUI_COAM_LOCAL}    distname_ID=${distname_id_1}

Delete NRADJGNB object on gnb
    [Arguments]    ${url}    ${distname_ID}
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${url}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    selenium_coam.disable_message_box
    Run Keyword And Ignore Error    selenium_coam.remove_object    object_name=${distname_ID}/NRADJGNB-0
    sleep    3s
    Run Keyword And Ignore Error    selenium_coam.remove_object    object_name=${distname_ID}/NRADJGNB-1
    sleep    3s
    Run Keyword And Ignore Error    selenium_coam.remove_object    object_name=${distname_ID}/XNLINK-0
    sleep    3s
    Run Keyword And Ignore Error    selenium_coam.remove_object    object_name=${distname_ID}/XNLINK-1
    sleep    3s
    selenium_coam.validate_plan
    sleep    5s
    selenium_coam.activate_plan    activate_plan_despite_errors=True    timeout=120
    sleep    5s
    selenium_coam.logout

set and check value of parameter administrativeState on MO SNSSAI
    [Arguments]    ${value}=Unlocked    ${new_value}=Unlocked    ${despite_errors}=True    ${connect_IP}=${WEBUI_COAM_LOCAL}
    set value of parameter administrativeState on MO SNSSAI    new_value=${new_value}    despite_errors=${despite_errors}    connect_IP=${connect_IP}
#    check value of parameter administrativeState on MO SNSSAI    value=${value}

set value of parameter administrativeState on MO SNSSAI
    [Arguments]    ${new_value}=Unlocked    ${despite_errors}=True    ${connect_IP}=${connect_IP}
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${connect_IP}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    ${bts_id}   selenium_coam.get_bts_id
    Set Suite Variable    ${administrativeState_distname}    MRBTS-${bts_id}/NRBTS-${bts_id}/SNSSAI-1
    selenium_coam.set_parameter_value  dist_name=${administrativeState_distname}
    ...    filter_param=Administrative state
    ...    abbr=administrativeState    new_value=${new_value}
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=${despite_errors}
    sleep    8s
    selenium_coam.logout
    selenium_coam.disable_virtual_display

Plmn exchange to code mode
    [Arguments]    ${mcc}    ${mnc}
    ${len_mnc}    get length    ${mnc}
    ${mnc}    set variable if    ${len_mnc}==2    f${mnc}    ${mnc}
    ${c_plmn}    set variable    ${mcc}${mnc}
    @{l_plmn}    split_string_to_characters    ${c_plmn}
    ${plmn}    set variable    ${l_plmn[1]}${l_plmn[0]}${l_plmn[3]}${l_plmn[2]}${l_plmn[5]}${l_plmn[4]}
    [Return]     ${plmn}

Modify the administrative state for both gNB
    [Arguments]    ${admin_state}
    Modify the administrative state with both gNB    coam_url=${WEBUI_COAM_LOCAL}    dist_id=${distname_id_1}
    ...    admin_state=${admin_state}
    Modify the administrative state with both gNB    coam_url=${WEBUI_COAM_PEER}    dist_id=${distname_id_2}
    ...    admin_state=${admin_state}

Modify the administrative state with both gNB
   [Arguments]     ${coam_url}    ${dist_id}    ${admin_state}
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${coam_url}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    #selenium_coam.disable_message_box
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    ${bts_id}   selenium_coam.get_bts_id
    selenium_coam.set_parameter_value    dist_name=${dist_id}/NRADJGNB-1
    ...    filter_param=Administrative state
    ...    new_value=${admin_state}
    sleep    3s
    selenium_coam.validate_plan
    sleep    6s
    selenium_coam.activate_plan    activate_plan_despite_errors=True
    selenium_coam.logout
    selenium_coam.disable_virtual_display

Add gNB object for both gNB on WebUI for locked
    [Arguments]    ${mcc}=${mcc}    ${mnc}=${mnc}    ${length}=22
    Modify paras on coam webui    coam_url=${WEBUI_COAM_LOCAL}    nrbtsid=${obiect_1}   dist_id=${distname_id_1}
    ...    xn_ip=${xn_ip}[1]    admin_state=${admin_state}[1]    gNB_ID=${gNB_ID}[1]    mcc=${mcc}    mnc=${mnc}
    ...    gnbidlength=${length}
    Modify paras on coam webui    coam_url=${WEBUI_COAM_PEER}    nrbtsid=${obiect_2}   dist_id=${distname_id_2}
    ...    xn_ip=${xn_ip}[0]    admin_state=${admin_state}[1]    gNB_ID=${gNB_ID}[0]    mcc=${mcc}    mnc=${mnc}
    ...    gnbidlength=${length}

Setup Environment for case
    [Arguments]    ${mcc}=${mcc}    ${mnc}=${mnc}    ${length}=22
    Local gNB and peer gNB commission
    #wait until keyword succeeds    15 min    10 sec    Check cell on air for both gNB#if fail will run both two kws
    wait until keyword succeeds    15 min    10 sec    Check cell status on webui
    ...    bts_host=${LOCAL_MASTER_IP}    connection=Local gNB
    wait until keyword succeeds    15 min    10 sec    Check cell status on webui
    ...    bts_host=${PEER_MASTER_IP}    connection=Peer gNB
    Add gNB object for both gNB on WebUI for locked    mcc=${mcc}    mnc=${mnc}    length=${length}
    sleep    10s

Prepare env
    [Arguments]    ${mcc}=${mcc}    ${mnc}=${mnc}    ${length}=22
    ${env_status}    ${env_value} =    Setup Environment for case    mcc=${mcc}    mnc=${mnc}
    ...    length=${length}
    set suite variable    ${env_status}

Check XNLINK status available for both gNB on webUI
    XNLINK is correct on gNB on webUI    status=${xnstatus}[0]    coam_url=${WEBUI_COAM_LOCAL}
    ...    xnLinkStatus_dist_name=${xnLinkStatus_dist_name_1}
    XNLINK is correct on gNB on webUI    status=${xnstatus}[0]    coam_url=${WEBUI_COAM_PEER}
    ...    xnLinkStatus_dist_name=${xnLinkStatus_dist_name_2}

XNLINK is correct on gNB on webUI
    [Arguments]    ${status}    ${coam_url}    ${xnLinkStatus_dist_name}
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${coam_url}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    #selenium_coam.disable_message_box
    #${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    #Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    sleep    5s
    ${xnLinkStatus}=    selenium_coam.get_parameter_value    dist_name=${xnLinkStatus_dist_name}
    ...    filter_param=XnC link status
    ...    abbr=xnLinkStatus
    Should Be Equal    ${xnLinkStatus}    ${status}
    selenium_coam.logout

Modify paras on coam webui
   [Arguments]     ${coam_url}    ${nrbtsid}    ${dist_id}    ${xn_ip}    ${admin_state}    ${gNB_ID}
   ...    ${mcc}=${mcc}    ${mnc}=${mnc}    ${gnbidlength}=22
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${coam_url}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    #selenium_coam.disable_message_box
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    selenium_coam.add_object    object_name=${nrbtsid}    object_class_name=XNLINK    id_value=1
    selenium_coam.set_parameter_value    dist_name=${dist_id}/XNLINK-1
    ...    filter_param=C-Plane IPv4/v6 address
    ...    new_value=${xn_ip}
    selenium_coam.add_object    object_name=${nrbtsid}    object_class_name=NRADJGNB    id_value=1
    selenium_coam.set_parameter_value    dist_name=${dist_id}/NRADJGNB-1
    ...    filter_param=Adjacent gNB Routing Id
    ...    new_value=1
    selenium_coam.set_parameter_value    dist_name=${dist_id}/NRADJGNB-1
    ...    filter_param=Administrative state
    ...    new_value=${admin_state}
    selenium_coam.set_parameter_value    dist_name=${dist_id}/NRADJGNB-1    filter_param=gNB id length
    ...    new_value=${gnbidlength}
    selenium_coam.set_parameter_value    dist_name=${dist_id}/NRADJGNB-1    filter_param=gNodeB Id
    ...    new_value=${gNB_ID}
    selenium_coam.set_parameter_value    dist_name=${dist_id}/NRADJGNB-1    filter_param=Xn link reference
    ...    new_value=1
    selenium_coam.add_element    dist_name=${dist_id}/NRADJGNB-1    filter_param=PLMN of Global gNB Id
    selenium_coam.set_parameter_value    dist_name=${dist_id}/NRADJGNB-1
    ...    filter_param=MCC of PLMN ID in Global gNB ID
    ...    new_value=${mcc}
    selenium_coam.set_parameter_value    dist_name=${dist_id}/NRADJGNB-1
    ...    filter_param=MNC of PLMN ID in Global gNB ID
    ...    new_value=${mnc}
    selenium_coam.set_parameter_value    dist_name=${dist_id}/NRADJGNB-1
    ...    filter_param=MNC length of PLMN ID in Global gNB ID
    ...    new_value=2
    sleep    3s
    selenium_coam.validate_plan
    sleep    3s
    selenium_coam.activate_plan    activate_plan_despite_errors=True
    selenium_coam.logout
    selenium_coam.disable_virtual_display
    sleep    5s

click site reset
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM_LOCAL}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    selenium_coam.disable_message_box
    selenium_coam.reset_site
    sleep    5mins

Check cell status on webui
    [Arguments]     ${bts_host}    ${connection}
    Connect to gnb coam via ssl    connection=${connection}    bts_host=${bts_host}
    Run Keyword And Ignore Error    Verify all cells should be onair    connection=${connection}
    [Teardown]    coam.teardown    connection=${connection}

Get info status check
    [Arguments]    ${info_status}    ${conncet_2}    ${alias_2}
    ${Status} =   get from dictionary    ${info_status}    Status
    ${opr_state} =   get from dictionary    ${Status}    Operational state
    should be equal    ${opr_state}    Enabled
    ${avi_state} =   get from dictionary    ${Status}   Availability status
    should be equal    ${avi_state}    Online
    ${length}    Get Length    ${avi_state}
    Run Keyword If    ${length}>6    click site reset
    Run Keyword If    ${length}>6    click site reset
    ${adm_state} =   get from dictionary    ${Status}    Administrative state
    should be equal    ${adm_state}    Unlocked

Local gNB and peer gNB commission
    Do commission for each gNB    coam_url=${WEBUI_COAM_LOCAL}   scf_name=${tl_scf_dir_path}${tl_scf_file_name}[0]
    Do commission for each gNB    coam_url=${WEBUI_COAM_PEER}    scf_name=${tl_scf_dir_path}${tl_scf_file_name}[1]
    #sleep    4mins

Do commission for each gNB
    [Arguments]     ${coam_url}    ${scf_name}
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${coam_url}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    selenium_coam.disable_message_box
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    selenium_coam.load_commissioning_file_and_check_load_status    ${scf_name}
    sleep    5s
    selenium_coam.validate_plan
    sleep    5s
    selenium_coam.activate_plan    activate_plan_despite_errors=True    timeout=120
    Run Keyword And Ignore Error    selenium_coam.logout

Start To Capture Logs
    [Arguments]     ${xnlogname}    ${interface}=fp0
    wait until keyword succeeds    10 min    10 sec    Connect to local master    alias=Local gNB
    Start To Capture Wireshark Logs    filename=${xnlogname}    connection=Local gNB    interface=${interface}

Start To Capture Wireshark Logs
    [Arguments]     ${filename}    ${connection}    ${interface}
    csn.send command    command=tcpdump sctp -i ${interface} -w ${gnb_path}${filename} -vv    connection=${connection}

Stop and Save Logs
    [Arguments]    ${xnlogname}
    Connect to local master    alias=Local gNB
    Stop and download Logs    logname=${xnlogname}    connection=Local gNB

Stop and download Logs
    [Arguments]    ${logname}    ${connection}
    csn.send command    command=killall tcpdump     connection=${connection}
    sleep    3
    csn.download_file   remote_path=${gnb_path}${logname}   local_path=${epc_log_path}${logname}   connection=${connection}
    sleep    3

Connect to local master
    [Arguments]    ${alias}=Local gNB
    csn.Connect to    hostname=${LOCAL_MASTER_IP}
    ...    username=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
    ...    password=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
    ...    alias=${alias}

Connect to AMF
    [Arguments]    ${alias}=AMF
    csn.Connect to    hostname=${tl.core.default_ssh_connection_details.addr}
    ...    username=${tl.core.default_ssh_connection_details.username}
    ...    password=${tl.core.default_ssh_connection_details.password}
    ...    alias=${alias}

Disconnect all connections
    Run Keyword And Ignore Error    csn.Disconnect    connection=Local gNB
    Run Keyword And Ignore Error    csn.Disconnect    connection=Peer gNB
    Run Keyword And Ignore Error    selenium_coam.logout

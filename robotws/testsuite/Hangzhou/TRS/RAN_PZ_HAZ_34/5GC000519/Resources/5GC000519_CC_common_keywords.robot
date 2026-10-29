*** Settings ***
Documentation
...    author: Rebecca.Liu & criscai
...    contact:jia-rebecca.liu@nokia-sbell.com
...    squad group: SG_03
...    feature : 5GC000470-O 5GC000519

*** Settings ***
Library    OperatingSystem
Library    Collections
Library    String
Library    BuiltIn
Library    taf.transport.ssh    WITH NAME    csn
Library    taf.sbts.oam.coam.admin   WITH NAME    wmplte
Library    taf.transport.ssh                 WITH NAME       ssh
Library    taf.config.scf    WITH NAME    scf
Library    taf.selenium.gnb.oam.coam.classical     WITH NAME     selenium_coam
Resource    ./iperf_common_keywords.robot
Resource    ./5GC000519_coam_common_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/enb_lte.robot
Resource    taf/rfrl/common_resources/robot/gnb_classical.robot



*** Variables ***
${WEBUI_COAM}    https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_NAME}    ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PWD}    ${tl.gnbs[0].cu.oam_http_connection_details.password}
${ENB_ADDRESS}    ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
${asik_addr}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${gnb_BTS_host}     ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${asik_username}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${asik_password}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${TestPC_addr}    ${tl.test_pc.default_ssh_connection_details.addr}
${TestPC_username}    ${tl.test_pc.default_ssh_connection_details.username}
${TestPC_password}    ${tl.test_pc.default_ssh_connection_details.password}
${dis_name}           MRBTS-${tl.gnbs[0].instance_id}/TNLSVC-1/TNL-1/ETHSVC-1/
${gNB_dist_l2sw}      MRBTS-${tl.gnbs[0].instance_id}/TNLSVC-1/TNL-1/ETHSVC-1/L2SWI-1
${gNB_dist_l2sw_brg}      MRBTS-${tl.gnbs[0].instance_id}/TNLSVC-1/TNL-1/ETHSVC-1/L2SWI-1/BRGPRT-2

*** Keywords ***
set and check value of parameter administrativeState on MO SNSSAI
    [Arguments]    ${value}=Unlocked    ${new_value}=Unlocked    ${despite_errors}=True
    set value of parameter administrativeState on MO SNSSAI    new_value=${new_value}    despite_errors=${despite_errors}
#    check value of parameter administrativeState on MO SNSSAI    value=${value}

set value of parameter administrativeState on MO SNSSAI
    [Arguments]    ${new_value}=Unlocked    ${despite_errors}=True
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
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

Get parameter value
    [Arguments]    ${dis_name}    ${filter_name}
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    ${value}=    selenium_coam.get_parameter_value    dist_name=${dis_name}
    ...    filter_param=${filter_name}
    sleep    8s
    selenium_coam.logout
    [return]    ${value}

set new tag value
    [Arguments]    ${dis_name}    ${filter_name}    ${new_value}
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    selenium_coam.set_parameter_value    dist_name=${dis_name}    filter_param=${filter_name}    new_value=${new_value}
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=True
    sleep    30s
    selenium_coam.logout

active chaining feature tag
    set new tag value    ${gNB_dist}/L2SWI-1    Enable layer 2 switching between physical ports    true

disable Qos awareness tag
    [Arguments]    ${dist_name}
    set new tag value    dis_name=${dist_name}    filter_name=VLAN aware switching enable    new_value=false

active Qos awareness tag
    [Arguments]    ${dist_name}
    set new tag value    dis_name=${dist_name}    filter_name=VLAN aware switching enable    new_value=true

set acceptable frame type tag
    [Arguments]     ${dist_name}    ${tag_value}
    set new tag value    dis_name=${dist_name}    filter_name=Switch port acceptable frame types    new_value=${tag_value}

change portDefaultVlanId with new vlan id
    [arguments]    ${new_vlan}
    set new tag value    ${gNB_dist}/L2SWI-1/BRGPRT-2    Default VLAN identifier for layer 2 switching    ${new_vlan}

get Qos awareness tag
    [Arguments]    ${dist_name}
    ${value}=    Get parameter value    dis_name=${dist_name}    filter_name=VLAN aware switching enable
    [Return]    ${value}

Add L2VlanIdlist for EIF2 port for all vlan range
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    selenium_coam.add_element    dist_name=${gNB_dist}/L2SWI-1/BRGPRT-2
    ...                                  filter_param=Layer 2 switch member VLAN identifier list
    selenium_coam.set_parameter_value    dist_name=${gNB_dist}/L2SWI-1/BRGPRT-2
    ...                                  filter_param=Upper value of VLAN identifier range
    ...                                  new_value=4094
    selenium_coam.set_parameter_value    dist_name=${gNB_dist}/L2SWI-1/BRGPRT-2
    ...                                  filter_param=Low value of VLAN identifier range
    ...                                  new_value=2
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=True
    sleep    65s
    selenium_coam.logout

change vlan list with low to high value
    [arguments]    ${high_value}    ${low_value}
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    selenium_coam.set_parameter_value    dist_name=${gNB_dist}/L2SWI-1/BRGPRT-2
    ...                                  filter_param=Upper value of VLAN identifier range
    ...                                  new_value=${high_value}
    selenium_coam.set_parameter_value    dist_name=${gNB_dist}/L2SWI-1/BRGPRT-2
    ...                                  filter_param=Low value of VLAN identifier range
    ...                                  new_value=${low_value}
    selenium_coam.validate_plan
    selenium_coam.activate_plan     activate_plan_despite_errors=True
    sleep    65s
    selenium_coam.logout

ping eNB with vlan ID interface should be success
    [arguments]    ${VLAN_ID}    ${ip_address}
    Comment    ping ${VLAN_ID} should be success
    gNB connections
    ssh.sendCommand    command=ping ${ip_address} -c 2    connection=gnb
    sleep    3s
    ${sctp_status} =    ssh.read_output    connection=gnb
    should contain     ${sctp_status}     2 received, 0% packet loss
    ssh.disconnect     connection=gnb

ping eNB with vlan ID interface should not be success
    [Arguments]    ${VLAN_ID}    ${ip_address}
    Comment    ping ${VLAN_ID} should not be success
    gNB connections
    ssh.sendCommand    command=ping ${ip_address} -c 2    connection=gnb
    sleep    3s
    ${sctp_status} =    ssh.read_output    connection=gnb
    should contain     ${sctp_status}     100% packet loss
    ssh.disconnect     connection=gnb

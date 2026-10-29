# *** Settings ***
# Force Tags    PY36
# Suite Setup      TRANS Common Setup
# Suite Teardown   TRANS Common Teardown
# 
# Resource   ../5GC002236_FA/resources/trans_comm.robot
# 
# 
# *** Variables ***
# ${oam_ssh_addr}=            ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
# ${oam_ssh_username}=        ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
# ${oam_ssh_password}=        ${tl.gnbs[0].cu.oam_ssh_connection_details.password}
# ${WEBUI_URL}      https://${tl.gnbs[0].cu.oam_http_connection_details.addr}/
# ${webui_ip}       ${tl.gnbs[0].cu.oam_http_connection_details.addr}
# ${webui_username}    ${tl.gnbs[0].cu.oam_http_connection_details.username}
# ${webui_password}    ${tl.gnbs[0].cu.oam_http_connection_details.password}
# ${Interface}    fp0
# 
# *** Test Cases ***
# [1]TRS_5GC000307_IPv6_stack_configuration
# 
#     [Documentation]  This case is to validate the basic ipv6 stack configuration
#      ...  can be supported on WebElement manager. This case also shall validate
#      ...  linux kernel support the configuration IPv6 behavior of the 5G-NB
# 
#     [Tags]   IPv6
#     [Setup]
#     [Teardown]    Case teardown
# 
#     Step1: check configuration failed with invalid prefix length
#     Step2: check configuration failed with invalid IPv6 addr
#     Step3: check ethertype value is 86DD
# *** Keywords ***
# 
# Step1: check configuration failed with invalid prefix length
# 
#     Log to console  change the IPv6 address netmask to invalid value
# 
#     selenium_coam.enable_virtual_display
#     wait until keyword succeeds  3x   3s    selenium_coam.login    url=${WEBUI_URL}    username=${webui_username}   password=${webui_password}
# 
#     sleep    3s
#     ${mrbtsId}    selenium_coam.get_bts_id
#     selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsId}/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-1  abbr=localIpPrefixLength
#     ...    filter_param=Local IPv6 prefix length    new_value=129
# 
#     selenium_coam.validate_plan
#     sleep    5s
#     ${error}    selenium_coam.get_definition_errors
#     Log to console   ${error}
#     Should Not Be Empty   ${error}
#     Should contain    ${error[0]["Object name"]}   MRBTS-${mrbtsId}/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-1
#     selenium_coam.undo_changes
#     sleep    5s
#     Run Keyword And Ignore Error     selenium_coam.logout
#     Run Keyword And Ignore Error     selenium_coam.disable_virtual_display
# 
# Step2: check configuration failed with invalid IPv6 addr
# 
#     Log to console  change the IPv6 address to invalid value
# 
#     selenium_coam.enable_virtual_display
#     wait until keyword succeeds  3x   3s    selenium_coam.login    url=${WEBUI_URL}    username=${webui_username}   password=${webui_password}
# 
#     selenium_coam.disable_screen_lock
#     sleep    3s
#     ${mrbtsId}    selenium_coam.get_bts_id
#     selenium_coam.set_parameter_value    dist_name=MRBTS-${mrbtsId}/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-1  abbr=localIpAddr
#     ...    filter_param=Local IPv6 address    new_value=FE80::0007
# 
#     selenium_coam.validate_plan
#     sleep    5s
#     ${error}    selenium_coam.get_relation_errors
#     Log to console   ${error}
# 
#     Should Not Be Empty   ${error}
#     Should contain    ${error}   MRBTS-${mrbtsId}/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-1
# 
#     selenium_coam.undo_changes
#     sleep    5s
#     Run Keyword And Ignore Error    selenium_coam.logout
#     Run Keyword And Ignore Error    selenium_coam.disable_virtual_display
# 
# Step3: check ethertype value is 86DD
# 
#     ${ssh_oam}=  Create Dictionary
#                      ...  host=${oam_ssh_addr}
#                      ...  user=${oam_ssh_username}
#                      ...  password=${oam_ssh_password}
#     tcpdump.create_tcpdump_collector
#     ...     name=oam_dump
#     ...     options=-i ${Interface}
#     ...     executor=${ssh_oam}
#     core.setup_collectors    names=oam_dump
#     core.start_collectors    names=oam_dump
#     sleep   10s
# 
#     core.stop_collectors    names=oam_dump
#     core.collect_collectors    names=oam_dump
#     core.teardown_collectors    names=oam_dump
# 
#     ${fullfilename}   set variable   ${OUTPUT_DIR}/${SUITE_NAME}/${TEST_NAME}/oam_dump/oam_dump.pcap
# 
#     ${xml_file}   Get A File   wireshark  icmp.xml
#     ${filter}   Set Variable   ip.src == ${oam_ssh_addr}
#     Analyze Pcap2xml  src=${fullfilename}    dest=${xml_file}  filter=${filter}
# 
#     ${entries}  Cpdml.Get_Pdml_Entries   file_name=${xml_file}  field_name=eth.type   attrib_name=value   attrib_value=0800
#     ${show}   Cpdml.Get_Attrib_Value_From_Pdml_Entries  pdml_entries=${entries}   field_name=eth.type   attrib_name=value
#     Log To Console    ${show}
#     Should be equal     ${show[0]}    0800
# 
# Case teardown
#     Run Keyword And Ignore Error     selenium_coam.logout
#     Run Keyword And Ignore Error     selenium_coam.disable_virtual_display
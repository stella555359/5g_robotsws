# *** Settings ***
# Force Tags    PY36
# Suite Setup      TRANS Common Setup
# Suite Teardown   TRANS Common Teardown
# 
# Resource   ../5GC002236_FA/resources/trans_comm.robot
# 
# *** Variables ***
# ${oam_ssh_addr}=            ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
# ${oam_ssh_username}=        ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
# ${oam_ssh_password}=        ${tl.gnbs[0].cu.oam_ssh_connection_details.password}
# ${WEBUI_URL}      https://${tl.gnbs[0].cu.oam_http_connection_details.addr}/
# ${webui_ip}       ${tl.gnbs[0].cu.oam_http_connection_details.addr}
# ${webui_username}    ${tl.gnbs[0].cu.oam_http_connection_details.username}
# ${webui_password}    ${tl.gnbs[0].cu.oam_http_connection_details.password}
# ${LOCAL_IP}     10.108.227.129
# 
# ${scop}            User-defined address
# ${default_dscp_value}    10
# ${dscp_value2}    63
# ${default_payload_value}   16
# ${payload_value2}    1000
# ${payload_value3}    2000
# ${Interface}    fp0
# ${ICMP_NUM}   5
# 
# *** Test Cases ***
# [1]TRS_5GC000307_Verification_of_IPv4_ping_application
# 
#     [Documentation]    The purpose for this case is to verification the basic ping operation for ipv4 stack
#     ...    on the WebElement manager can be supported in this feature
#     [Tags]  CR1
# 
#     [Setup]
#     [Teardown]
# 
# #    Step1:verify ping application with default payload and dscp
# #    Step2:verify ping application with second payload and dscp
#     Step3:verify fragment
# 
# *** Keywords ***
# Step1:verify ping application with default payload and dscp
#     Log To Console    verify ping application with default payload and dscp
# 
#     ${ssh_oam}=  Create Dictionary
#                      ...  host=${oam_ssh_addr}
#                      ...  user=${oam_ssh_username}
#                      ...  password=${oam_ssh_password}
#     tcpdump.create_tcpdump_collector
#     ...     name=oam_dump
#     ...     options=-i ${Interface} icmp
#     ...     executor=${ssh_oam}
#     core.setup_collectors    names=oam_dump
#     core.start_collectors    names=oam_dump
#     sleep   5s
#     Run Keyword And Ignore Error    Start ping via webui   dest_ip=${LOCAL_IP}
#     ...    payload_value=${default_payload_value}     dscp=${default_dscp_value}
#     sleep   5s
#     core.stop_collectors    names=oam_dump
#     core.collect_collectors    names=oam_dump
#     core.teardown_collectors    names=oam_dump
# 
#     ${fullfilename}   set variable   ${OUTPUT_DIR}/${SUITE_NAME}/${TEST_NAME}/oam_dump/oam_dump.pcap
#     Set Test Variable    ${fullfilename}
#     Validate ICMP package Is Correct    payload_value=${default_payload_value}     dscp=${DSCP_value_Hex}
# 
# Step2:verify ping application with second payload and dscp
#     Log To Console    verify ping application with second payload and dscp
#     sleep   120s
#     ${ssh_oam2}=  Create Dictionary
#                      ...  host=${oam_ssh_addr}
#                      ...  user=${oam_ssh_username}
#                      ...  password=${oam_ssh_password}
#     tcpdump.create_tcpdump_collector
#     ...     name=oam_dump2
#     ...     options=-i ${Interface} icmp
#     ...     executor=${ssh_oam2}
#     core.setup_collectors    names=oam_dump2
#     core.start_collectors    names=oam_dump2
#     sleep   5s
#     Run Keyword And Ignore Error    Start ping via webui  dest_ip=${LOCAL_IP}
#     ...    payload_value=${payload_value2}    dscp=${dscp_value2}
#     sleep   5s
#     core.stop_collectors    names=oam_dump2
#     core.collect_collectors    names=oam_dump2
#     core.teardown_collectors    names=oam_dump2
#     ${fullfilename}   set variable   ${OUTPUT_DIR}/${SUITE_NAME}/${TEST_NAME}/oam_dump2/oam_dump2.pcap
#     Set Test Variable    ${fullfilename}
# 
#     Validate ICMP package Is Correct    payload_value=${payload_value2}    dscp=${DSCP_value_Hex}
# 
# Step3:verify fragment
# 
#     Log To Console  verify fragmentation
# 
#     tcpdump.create_tcpdump_collector
#     ...    name=tcpdump
#     ...    options=-i eth0
#     ...    sudo_password=ute
#     core.setup_collectors    names=tcpdump
#     core.start_collectors    names=tcpdump
#     sleep    5s
# 
#     Start ping via webui   dest_ip=${LOCAL_IP}    payload_value=${payload_value3}    dscp=${default_dscp_value}
#     sleep   5s
#     core.stop_collectors    names=tcpdump
#     core.collect_collectors    names=tcpdump
#     core.teardown_collectors    names=tcpdump
# 
# 
#     ${ssh_ute}=  Create Dictionary
#                      ...  host=${LOCAL_IP}
#                      ...  user=${UTE_USERNAME}
#                      ...  password=${UTE_PASSWORD}
# 
#     ${fullfilename}   set variable   ${OUTPUT_DIR}/${SUITE_NAME}/${TEST_NAME}/tcpdump/tcpdump.pcap
#     Set Test Variable    ${fullfilename}
# 
#     Validate the icmp package is fragmented
# 
# Start ping via webui
#     [Arguments]  ${dest_ip}   ${payload_value}    ${dscp}
#     selenium_coam.enable_virtual_display
#     wait until keyword succeeds  3x   3s    selenium_coam.login    url=${WEBUI_URL}    username=${webui_username}   password=${webui_password}
# 
#     sleep    3s
#     ${DSCP_value_Hex}    convert to hex    ${dscp}
#     set suite variable   ${DSCP_value_Hex}
# 
#     selenium_coam.start_ip_connectivity_test  scope=${scop}  address=${dest_ip}
#     ...    source_address=${oam_ssh_addr}  payload_size=${payload_value}  dscp=${dscp}  timeout=30
#     sleep    3s
# 
#     Run Keyword And Ignore Error    selenium_coam.logout
#     Run Keyword And Ignore Error    selenium_coam.disable_virtual_display
# 
# Validate ICMP package Is Correct
#     [Arguments]    ${payload_value}    ${dscp}
#     Log To Console    verify 5 consecutive echo request packets captured
#     ${xml_file}   Get A File   wireshark  icmp.xml
#     ${filter}   Set Variable   ip.addr==${LOCAL_IP}
#     Analyze Pcap2xml   src=${fullfilename}    dest=${xml_file}  filter=${filter}
#     ${entries}  Cpdml.Get_Pdml_Entries   file_name=${xml_file}  field_name=icmp.type   attrib_name=show   attrib_value=8
#     ${showname}   Cpdml.Get_Attrib_Value_From_Pdml_Entries  pdml_entries=${entries}   field_name=icmp.type    attrib_name=showname
#     Log To Console    ${showname}
#     ${length}  Get Length    ${showname}
#     Should Be True   ${length}==${ICMP_NUM}
# 
#     ${entries}  Cpdml.Get_Pdml_Entries   file_name=${xml_file}  field_name=icmp.type   attrib_name=show   attrib_value=0
#     ${showname}   Cpdml.Get_Attrib_Value_From_Pdml_Entries  pdml_entries=${entries}   field_name=icmp.type    attrib_name=showname
#     Log To Console    ${showname}
#     ${length}  Get Length    ${showname}
#     Should Be True   ${length}==${ICMP_NUM}
# 
#     Log To Console    verify the DSCP value is correct
#     ${entries}  Cpdml.Get_Pdml_Entries   file_name=${xml_file}   field_name=icmp.type   attrib_name=show   attrib_value=8
#     @{dscp_value_list_out}   Cpdml.Get_Attrib_Value_From_Pdml_Entries  pdml_entries=${entries}   field_name=ip.dsfield.dscp   attrib_name=value
# 	sleep    3s
# 
#    : FOR    ${dscp_value}    IN    @{dscp_value_list_out}
#     \    Should be equal     ${dscp}    ${dscp_value}
# 
#     Log To Console    verify the payload value is correct
# 
#     ${entries}  Cpdml.Get_Pdml_Entries   file_name=${xml_file}  field_name=icmp.type   attrib_name=show   attrib_value=8
#     @{payload_list_out}   Cpdml.Get_Attrib_Value_From_Pdml_Entries  pdml_entries=${entries}   field_name=data.data   attrib_name=value
# 	sleep    3s
# 
#    : FOR    ${payload}    IN   @{payload_list_out}
#     \    ${tmp}    Get length  ${payload}
#     \    ${tmp_1}==  Evaluate   ${tmp}/2
#     \    ${tmp_2}==  Evaluate   ${tmp_1}+8
#     \    ${payload_value_1}    Convert To String     ${tmp_2}
#     \    Should be equal     ${payload_value}   ${payload_value_1}
# 
# 
# Connect to OAM
#     [Arguments]    ${myalias}
#     ssh.connect_to   hostname=${oam_ssh_addr}    username=${oam_ssh_username}    password=${oam_ssh_password}    alias=${myalias}
# 
# Validate the icmp package is fragmented
#     ${xml_file}   Get A File   wireshark  icmp.xml
#     ${filter}   Set Variable   icmp
#     Analyze Pcap2xml   src=${fullfilename}    dest=${xml_file}  filter=${filter}
# 
#     ${entries}  Cpdml.Get_Pdml_Entries   file_name=${xml_file}  field_name=icmp.type   attrib_name=show   attrib_value=8
#     ${showname}   Cpdml.Get_Attrib_Value_From_Pdml_Entries   pdml_entries=${entries}   field_name=ip.fragments    attrib_name=showname
#     Log To Console    ${showname}
#     should contain    ${showname[0]}    IPv4 Fragments
# 
# 

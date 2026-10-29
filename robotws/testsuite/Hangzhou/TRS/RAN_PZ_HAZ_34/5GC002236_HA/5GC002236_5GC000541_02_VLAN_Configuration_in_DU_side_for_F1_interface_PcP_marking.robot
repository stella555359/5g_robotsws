# #*** Settings ***
# #Force Tags    PY36
# #Documentation
# #...   author: zheyuan.chen@nokia-sbell.com
# #...   contact: zheyuan.chen@nokia-sbell.com
# #...   Ethernet termination
# #
# #Suite Setup       Suite Setup
# #Suite Teardown    Suite Teardown
# #
# #Resource            resources/trans_comm.robot
# #Library             resources/HAkeywords.py
# #Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
# #Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# #
# #*** Variable ***
# #${File_Name}    541_02login.tcl
# #
# #*** Test Cases ***
# #[1]5GC002236_5GC000541_02_VLAN_Configuration_in_DU_side_for_F1_interface_PcP_marking
# #    [Documentation]
# #    ...    Test will check possibility to verify traffic priority marking for non Default DSCP to PCP mapping
# #    ...    for both data traffic and ARP packets
# #    ...    -20.10.2020,zheyuan.chen@nokia-sbell.com,case draft
# #    [Tags]    CRT_20B    5GC002236_541
# #    [Setup]    case setup
# #    Check BTS Should Be Normal
# #    Check add IPADDRESS4 Success
# #    Check add DSCP2PCPMAP Success    BTS_ID=${BTS_ID}
# #    Send data packets and capture wireshark log
# #    ${Pri_value1}    ${newdscp_value}    Check and Modify DSCP value    pacp_filename=testcase4.pcap    txt_filename=testcase4.txt
# #    Resend data packets and capture wireshark log
# #    Check New Vlan_priority Vlaue Success    Pri_value=${Pri_value1}    newdscp_value=${newdscp_value}
# #    [Teardown]    run keywords     case teardown_delete     AND    CI_interface.Common Case Teardown
# #
# #
# #*** Keywords ***
# #Check add IPADDRESS4 Success
# #    Add new IPIF success    BTS_ID=${BTS_ID}    VLANIF_ID=${VLANIF_ID}    IP_Mtu=${IP_Mtu}
# #    Add IPADDRESS4 success    BTS_ID=${BTS_ID}    VLAN_ID=${VLAN_ID}    IPIF_ID=${IPIF_ID}    VLANIP_PRELENGTH=${VLANIP_PRELENGTH}
# #
# #Send data packets and capture wireshark log
# #    Log To Console    Capture Wireshark Log And Download
# #    Capture Wireshark Vlan Log And Download    filename=testcase4.pcap    time=8s    listen_port=${Ethernet}
# #
# #Check and Modify DSCP value
# #    [Arguments]    ${pacp_filename}    ${txt_filename}
# #    Log To Console    Convert pcap to text And Get Vlan_priority DSCP Value
# #    ${vlanpri_list1}    ${DSCP_list1}    Convert pcap to text And Get Vlan_priority DSCP Value   pacp_filename=${pacp_filename}
# #    ...    txt_filename=${txt_filename}
# #    Log To Console    Modify Vlan priority value
# #    ${Pri_value1}    set variable    @{vlanpri_list1}[0]
# #    ${newdscp_value}    Modify Vlan priority value    Pri_value=${Pri_value1}    DSCP_list=${DSCP_list1}
# #    [Return]   ${Pri_value1}    ${newdscp_value}
# #
# #Resend data packets and capture wireshark log
# #    Log To Console    Resend data packets and capture wireshark log
# #    Capture Wireshark Vlan Log And Download     filename=testcase5.pcap    time=8s    listen_port=${Ethernet}
# #
# #Check New Vlan_priority Vlaue Success
# #    [Arguments]    ${Pri_value}    ${newdscp_value}
# #    ${Pri_value2}    Get New Vlan_priority Vlaue    pacp_filename=testcase5.pcap    txt_filename=testcase5.txt
# #    ${Pri_value2_num}    convert to number    ${Pri_value2}
# #    should not be equal    ${Pri_value}    ${Pri_value2_num}
# #    should be equal    ${Pri_value2_num}    ${newdscp_value}
# #
# #case setup
# #    Log To Console    case setup
# #    Login Testcenter    File_Name=${File_Name}
# #    Rest Login DU
# #    Delete IPIF    BTS_ID=${BTS_ID}    IPIF_ID=${IPIF_ID}
# #    [Teardown]    Rest Logout DU
# #
# #case teardown_delete
# #    ${empty_list}    create list
# #    Log To Console    case teardown_delete
# #    Logout Testcenter
# #    Rest Login DU
# #    run keyword and ignore error    coam.perform_object_recommissioning
# #    ...    dist_name=MRBTS-${BTS_ID}/TNLSVC-1/TNL-1/IPNO-1/QOS-1/DSCP2PCPMAP-1
# #    ...    parameter=${empty_list}    operation=delete     skip_parameter_relation_errors=${True}    should_activate=${True}
# #    [Teardown]    Rest Logout DU
# #
# #Suite Setup
# #    TRANS Common Setup
# #
# #Suite Teardown
# #    TRANS Common Teardown
# #*** Settings ***
# #Force Tags    PY36
# #Suite Setup       Suite Setup
# #Suite Teardown    Suite Teardown
# #Resource     resources/trans_comm.robot
# #Resource     resources/trans_genmo.robot
# #Resource     resources/trans_pm.robot
# #Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# #
# #*** Variables ***
# #${DU_IP}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
# #${WEBEM_USERNAME}    ${tl.gnbs[0].cu.oam_http_connection_details.username}
# #${WEBEM_PASSWORD}    ${tl.gnbs[0].cu.oam_http_connection_details.password}
# #${DU_SSH_USERNAME}     ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
# #${DU_OAM_SSH_PASSWORD}     ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
# #${UTE_IP}      ${tl.test_pc.default_ssh_connection_details.addr}
# #${UTE_username}   ${tl.test_pc.default_ssh_connection_details.username}
# #${UTE_password}    ${tl.test_pc.default_ssh_connection_details.password}
# #${filename}      349_05_case.tcl
# #${container_alias}     ute_conn
# #${connection}    du_con
# #@{LIST_COUNTER_INFO_M51302}
# #...    TNLSVC-1/TNL-TNLOAM/ETHSVC-1/ETHIF-1/VLANIF-1;M51302C0
# #...    TNLSVC-1/TNL-TNLOAM/ETHSVC-1/ETHIF-1/VLANIF-1;M51302C1
# #...    TNLSVC-1/TNL-TNLOAM/ETHSVC-1/ETHIF-1/VLANIF-1;M51302C2
# #...    TNLSVC-1/TNL-TNLOAM/ETHSVC-1/ETHIF-1/VLANIF-1;M51302C3
# #...    TNLSVC-1/TNL-TNLOAM/ETHSVC-1/ETHIF-1/VLANIF-1;M51302C4
# #
# #*** Test Cases ***
# #[1]5GC002236_5GC000349_05_VLAN_Statistics_Measurement_Data
# #    [Documentation]
# #    ...   This test case is used to test product shall support TCP_UDP statistics
# #    [Tags]   5GC002236     CRT_20B
# #    [Setup]
# #    Step1: Check BTS Should Be Normal
# #    Change Counter Generation to 5min
# #    Send testcenter packet   filename=${filename}   container_alias=${container_alias}
# #    [Teardown]    CI_interface.Common Case Teardown
# #
# #*** Keywords ***
# #Send testcenter packet
# #    [Arguments]    ${filename}    ${container_alias}
# #    ssh.connect_to
# #    ...    hostname=${UTE_IP}
# #    ...    username=${UTE_username}
# #    ...    password=${UTE_password}
# #    ...    alias=${container_alias}
# #    ssh.Send Command  command=sudo tclsh ${CURDIR}/resources/${filename}
# #    ...    connection=${container_alias}
# #    log to console  send Testcenter packet successful
# #    Log To Console    check counters
# #    WEBUI Login
# #    wait until keyword succeeds    2x   5min    check counters
# #    WEBUI Logout
# #    [Teardown]  ssh.disconnect   connection=${container_alias}
# #
# #check counters
# #    ${counter_dict}    selenium_coam.get_transport_counters    counter_id=M51302C0
# #    ...                                   full_path=TNL-1/VLANIF/VLANIF-204/VLAN_stats/EthVlanIfInEthTypeMismatch
# #    ${M51302C0_value}    get dictionary values    ${counter_dict}
# #    should be true       int(${M51302C0_value}[-1]) > 0
# #    log to console      succseful
# #    ${counter_dict}    selenium_coam.get_transport_counters    counter_id=M51302C1
# #    ...                                     full_path=TNL-1/VLANIF/VLANIF-204/VLAN_stats/VlanEthIfInFrames
# #    ${M51302C1_value}    get dictionary values    ${counter_dict}
# #    should be true       int(${M51302C1_value}[-1]) > 0
# #
# #    ${counter_dict}    selenium_coam.get_transport_counters    counter_id=M51302C2
# #    ...                                    full_path=TNL-1/VLANIF/VLANIF-204/VLAN_stats/VlanEthIfInOctets
# #    ${M51302C2_value}    get dictionary values    ${counter_dict}
# #    should be true       int(${M51302C2_value}[-1]) > 0
# #    ${counter_dict}    selenium_coam.get_transport_counters    counter_id=M51302C3
# #    ...                                    full_path=TNL-1/VLANIF/VLANIF-204/VLAN_stats/VlanEthIfOutFrames
# #    ${M51302C3_value}    get dictionary values    ${counter_dict}
# #    should be true       int(${M51302C3_value}[-1]) > 0
# #    ${counter_dict}    selenium_coam.get_transport_counters    counter_id=M51302C4
# #    ...                                    full_path=TNL-1/VLANIF/VLANIF-204/VLAN_stats/VlanEthIfOutOctets
# #    ${M51302C4_value}    get dictionary values    ${counter_dict}
# #    should be true       int(${M51302C4_value}[-1]) > 0
# #
# #Suite Setup
# #    TRANS Common Setup
# #    ${PM_FILE_LOCATION}   Set Variable  ${DU_PM_FILE_LOCATION}
# #    Set Suite Variable  ${PM_FILE_LOCATION}
# #    ${PM_FILE_PATTERN}   Set Variable  ${DU_PM_FILE_PATTERN}
# #    Set Suite Variable  ${PM_FILE_PATTERN}
# #
# #Suite Teardown
# #    TRANS Common Teardown
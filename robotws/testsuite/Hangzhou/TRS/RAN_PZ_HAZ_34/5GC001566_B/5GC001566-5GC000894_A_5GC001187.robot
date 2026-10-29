# *** Settings ***
# Documentation     author: fengyi Liu
# ...               contact: feng.y.liu@nokia-sbell.com
# ...               squad group: mmw_SG_04
# 
# Library    String
# Library    OperatingSystem
# Library    ./resources/1566_2238_common_keyword.py
# Resource   ./resources/1566_2238_common_keyword.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# 
# 
# Force Tags              5G_RAN_TDD    STATE_GNB_NOT_COMMISSIONED    CLOUD_5G_ANDROID_ASOD_AEWE_ENB    master_pDU    CRT_UTE   5G_RAN
# ...    PY36
# ...    RAN_5G_TDD    RAN_5G
# 
# 
# Suite Setup       CI_interface.Common Suite Setup
# 
# 
# *** Variables ***
# ${IPADDRESS_ID}             2
# ${gateway}                  192.85.1.17
# ${destIpAddr}               192.85.1.16
# ${dest_leng}                24
# ${DEST_IPV4}                20.1.1.0
# ${ip_flag}                  -4
# ${MRBTS}                    MRBTS-${tl.gnbs[0].instance_id}
# ${NRBTS}                    ${tl.gnbs[0].global_bts_id}
# ${IPRT}                     /TNLSVC-1/TNL-1/IPNO-1/IPRT-1
# ${DU_IP}                    ${tl.gnbs[0].dus[0].f1_m_ip_addr}
# ${WEBEM_USERNAME}           ${tl.gnbs[0].cu.oam_http_connection_details.username}
# ${WEBEM_PASSWORD}           ${tl.gnbs[0].cu.oam_http_connection_details.password}
# ${ASIK_USERNAME}            ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
# ${ASIK_PASSWORD}            ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
# ${errorMsg1}                It is required that there exist MOs IPADDRESSV4
# ${errorMsg2}                IPADDRESSV4.localIpPrefixLength
# ${1566_default_scf}         ${CURDIR}/../../../commissionings/HGZ/7_5_UTE5G401T721/SCF_0.400_DU.xml
# ${DSCP_CASE_LOG_PATH}       ${OUTPUT DIR}
# ${DST_FOR_FRM}              ${MRBTS}/NRBTS-${NRBTS}/NRDRB-7
# ${dscp_value}               ${10}
# ${CU_OAM_IP}                ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
# ${CU_SSH_USERNAME}          ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
# ${CU_OAM_SSH_PASSWORD}      ${tl.gnbs[0].cu.oam_ssh_connection_details.password}
# ${tl_name}                  tl${tl.gnbs[0].instance_id}
# ${test_ute}                 ${tl.test_pc.default_ssh_connection_details.addr}
# ${ute_name}                 ${tl.test_pc.default_ssh_connection_details.username}
# ${test_password}            ${tl.test_pc.default_ssh_connection_details.password}
# ${luashark_path}            /opt/luashark/luashark.lua
# ${F1_U}                     ${tl.gnbs[0].cu.f1u.v4}
# ${ul_throughput}            5M
# ${listen_port}              fronthaul
# ${ue_power_port}            ${tl.ues[0].iperf_details.port}
# 
# 
# 
# 
# *** Test Cases ***
# [1]5GC001566-5GC000894_A_005_Solo IP routing table creation for IPv4
#     [Tags]    5G_TRS    5GC001566    CRT_20B    CRT_TRUNK
#     [Setup]
#     Check cell on air
#     ${GATE_IPV4}    Get gateway
#     Add elements to list for ipv4
#     log    ${GATE_IPV4}
#     Check IPV4 route    dst_ip=${DEST_IPV4}    ip_flag=${ip_flag}    DU_IP=${DU_IP}    gateway=${GATE_IPV4}
#     [Teardown]    Run Keyword And Ignore error   Recover the test ENV      AND     CI_interface.Common Case Teardown
# 
# [1]5GC001566-5GC000894_A_007_IP main routing table update failure (Interface route) for IPv4
#     [Documentation]    Add a direct route to the main table for IPv4 and validation and activation should be failed
#     [Tags]    5G_TRS    5GC001566    CRT_20B    CRT_TRUNK
#     [Setup]
#     Check cell on air
#     Create IPADDRESSV4-2 Table   gateway=${gateway}    dest_leng=${dest_leng}    IPADDRESS_ID=${IPADDRESS_ID}
#     [Teardown]    run keywords   Disconnect from DU     AND     CI_interface.Common Case Teardown
# 
# [1]5GC001566-5GC000894_A_015_IP_rule_IP_routing_table_deletion_IPv4
#     [Documentation]    IPV4 routing table deletion
#     [Tags]    5G_TRS    5GC001566    CRT_20B    CRT_TRUNK
#     [Setup]
#     Check cell on air
#     ${GATE_IPV4}    Get gateway
#     Add elements to list for ipv4
#     Check IPV4 route    dst_ip=${DEST_IPV4}    ip_flag=${ip_flag}    DU_IP=${DU_IP}    gateway=${GATE_IPV4}
#     Delete elements to list for ipv4
#     Check IPV4 not route    dst_ip=${DEST_IPV4}    ip_flag=${ip_flag}    DU_IP=${DU_IP}    gateway=${GATE_IPV4}
#     Recover the test ENV    if_commission=${False}
#     Check IPV4 not route    dst_ip=${DEST_IPV4}    ip_flag=${ip_flag}    DU_IP=${DU_IP}    gateway=${GATE_IPV4}
#     [Teardown]    run keywords   Disconnect from DU     AND     CI_interface.Common Case Teardown
# 
# [1]5GC001187_A_5GC000309_B_1_GTP PDU sending in UL over IPv4
#     [Tags]    5GC002238   CRT_TRUNK    CRT_20B
#     [Setup]
#     Step1: Case Setup ready
#     Step2: attach multi power ue    ue_num=${1}
#     Step3: Start to Capture wireshark Log     listen_port=${listen_port}     log_dir=/tmp    filename=attach_tcp.pcap
#     Convert pcap to text And Get txt Content    pacp_filename=attach_tcp.pcap   txt_filename=attach_tcp.txt
#      ...    except_ver_value=4    except_DU_URL=${DU_IP}    except_F1_U=${F1_U}
#     [Teardown]   Run Keyword And Ignore error    Case Teardown
# 
# 
# 
# 
# 
# 
# 
# 
# 

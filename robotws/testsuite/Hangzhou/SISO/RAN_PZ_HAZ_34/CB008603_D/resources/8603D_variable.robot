*** Settings ***
Documentation
...   author: zheyuan.chen@nokia-sbell.com
...   contact: zheyuan.chen@nokia-sbell.com
...   common variables for CB007876-5G-A and CB006615

*** Variables ***
${DU_OAM_IP}    ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${eNB1_OAM_IP}    ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
${eNB2_OAM_IP}    ${tl.enbs[1].airscale.common_units[0].lmp_connection.addr}
${DU_OAM_SSH_USERNAME}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${DU_OAM_SSH_PASSWORD}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${DU_OAM_WEBUI_URL}    https://${tl.gnbs[0].dus[0].f1_m_ip_addr}/
${DU_OAM_WEBUI_USER}    ${tl.gnbs[0].cu.oam_http_connection_details.username}
${DU_OAM_WEBUI_PASSWORD}    ${tl.gnbs[0].cu.oam_http_connection_details.password}
${UTE_ADDRESS}    ${tl.test_pc.default_ssh_connection_details.addr}
${UTE_USERNAME}    ${tl.test_pc.default_ssh_connection_details.username}
${UTE_PASSWORD}    ${tl.test_pc.default_ssh_connection_details.password}
${BTS_ID}    ${tl.gnbs[0].instance_id}
${NRBTS_ID}    ${tl.gnbs[0].global_bts_id}
${ue_type}    ${tl.ues[0].capabilities[1]}
${IPERF_ADDR}    ${tl.appserver.iperf_details.network_interface_address}
${IPERF_portlist}    ${tl.appserver.iperf_details.ports}
${appserver_addr}    ${tl.ues[0].iperf_details.ssh_connection_details.addr}
${AWHHF_nrcell_id1}    16385
${AWHHF_nrcell_id4}    16388
${AWHQV_nrcell_id1}    182534145
${AWHQV_nrcell_id2}    182534146
${AWHQV_nrcell_id3}    182534147
${AWHQV_nrcell_id4}    182534148
${AWHHF1_PDU_IP}    ${tl.gnbs[0].dus[0].rus[0].pdu_port.pdu.addr}
${AWHHF1_PDU_PORT}    ${tl.gnbs[0].dus[0].rus[0].pdu_port.port_no}
${AWHQV1_PDU_IP}    ${tl.gnbs[0].dus[0].rus[0].pdu_port.pdu.addr}
${AWHQV1_PDU_PORT}    ${tl.gnbs[0].dus[0].rus[0].pdu_port.port_no}
@{ignore_history_fault}    ${7319}    ${7300}    ${9000}    ${61524}    ${61652}    ${61649}
...    ${61074}    ${61618}    ${4592}    ${1932}    ${4420}    ${4340}
${control_pc_addr}    ${tl.ues[0].ssh_connection_details.addr}
${control_pc_username}    ${tl.ues[0].ssh_connection_details.username}
${control_pc_password}    ${tl.ues[0].ssh_connection_details.password}
${UE0_SN}    ${tl.ues[0].serial_number}
${UE1_SN}    ${tl.ues[1].serial_number}
${home}    3
${airplane}    932 1633
${close_task}    710 2766
${Home_button}    3
${swipe}    1300 2700 1300 2700
${open_iperf_location}    500 2050
${iperf_button}    730 300
${iperf_space}    800 550
${5G}    900 960
${brand}     lge

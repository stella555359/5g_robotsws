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
${eNB1_BTS_ID}    ${tl.enbs[0].instance_id}
${eNB1_NRBTS_ID}    ${tl.enbs[0].global_bts_id}
${eNB2_BTS_ID}    ${tl.enbs[1].instance_id}
${eNB2_NRBTS_ID}    ${tl.enbs[1].global_bts_id}
@{all_cell_info}    ${0}    ${1}    ${2}    ${3}    ${4}    ${5}    ${6}    ${7}    ${8}    ${9}    ${10}    ${11}    ${12}
...    ${13}    ${14}    ${15}    ${16}    ${17}    ${18}    ${19}
@{all_cell_info_6615}    ${0}    ${1}    ${2}    ${3}    ${4}    ${5}    ${6}    ${7}
@{all_cell_info_7876}    ${8}    ${9}    ${10}    ${11}    ${12}    ${13}    ${14}    ${15}    ${16}    ${17}    ${18}    ${19}
@{AEWD1_cell_info}    ${1}    ${2}    ${3}    ${4}
@{AWEUA1_cell_info}    ${5}    ${6}    ${7}    ${8}
@{AEWD2_cell_info}    ${9}    ${10}    ${11}    ${12}
@{AWEUA2_cell_info}    ${13}    ${14}    ${15}    ${16}
@{AWEUA3_cell_info}    ${17}    ${18}    ${19}    ${20}
@{AEWD1_nrcell_list}    11583489    11583490
@{AWEUA1_nrcell_list}    11583493    11583494
@{AEWD2_nrcell_list}    11583497   11583498   11583499   11583500
@{AWEUA2_nrcell_list}    11583501    11583502
@{AWEUA3_nrcell_list}    11583505    11583506
${AEWD1_PDU_IP}    ${tl.gnbs[0].dus[0].rus[0].pdu_port.pdu.addr}
${AEWD1_PDU_PORT}    ${tl.gnbs[0].dus[0].rus[0].pdu_port.port_no}
${AWEUA1_PDU_IP}    ${tl.gnbs[0].dus[0].rus[1].pdu_port.pdu.addr}
${AWEUA1_PDU_PORT}    ${tl.gnbs[0].dus[0].rus[1].pdu_port.port_no}
${AEWD2_PDU_IP}    ${tl.gnbs[0].dus[0].rus[2].pdu_port.pdu.addr}
${AEWD2_PDU_PORT}    ${tl.gnbs[0].dus[0].rus[2].pdu_port.port_no}
${AWEUA2_PDU_IP}    ${tl.gnbs[0].dus[0].rus[3].pdu_port.pdu.addr}
${AWEUA2_PDU_PORT}    ${tl.gnbs[0].dus[0].rus[3].pdu_port.port_no}
${AWEUA3_PDU_IP}    ${tl.gnbs[0].dus[0].rus[4].pdu_port.pdu.addr}
${AWEUA3_PDU_PORT}    ${tl.gnbs[0].dus[0].rus[4].pdu_port.port_no}
${ue_type}    ${tl.ues[0].capabilities[1]}
${IPERF_ADDR}    ${tl.appserver.iperf_details.network_interface_address}
${IPERF_portlist}    ${tl.appserver.iperf_details.ports}
${appserver_addr}    ${tl.ues[0].iperf_details.ssh_connection_details.addr}
@{ignore_history_fault}    ${7319}    ${7300}    ${9000}    ${61524}    ${61652}    ${61649}
...    ${61074}    ${61618}    ${4592}    ${1932}    ${4420}    ${4340}
${PC_addr}         ${tl.ues[1].ssh_connection_details.addr}
${PC_username}     ${tl.ues[1].ssh_connection_details.username}
${PC_password}     ${tl.ues[1].ssh_connection_details.password}
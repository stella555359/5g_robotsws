*** Settings ***
Documentation
...   author: ruizzhan.zhang@nokia-sbell.com
...   contact: ruizzhan.zhang@nokia-sbell.com
...   common variables for CB007424-5G-DB

*** Variables ***
${eNB_OAM_IP}    ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
${DU_OAM_IP}                ${tl.gnbs[0].dus[0].f1_m_ip_addr}
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
@{all_cell_info}    ${0}    ${1}
${nrcell_id}    11878401
${AWHQE1_PDU_IP}    ${tl.gnbs[0].dus[0].rus[0].pdu_port.pdu.addr}
${AWHQE1_PDU_PORT}    ${tl.gnbs[0].dus[0].rus[0].pdu_port.port_no}
#${AWHQE2_PDU_IP}    ${tl.gnbs[0].dus[0].rus[1].pdu_port.pdu.addr}
#${AWHQE2_PDU_PORT}    ${tl.gnbs[0].dus[0].rus[1].pdu_port.port_no}
${ue_type}    ${tl.ues[0].capabilities[1]}
${IPERF_ADDR}    ${tl.appserver.iperf_details.network_interface_address}
${IPERF_portlist}    ${tl.appserver.iperf_details.ports}
${appserver_addr}    ${tl.ues[0].iperf_details.ssh_connection_details.addr}
@{ignore_history_fault}    ${7319}    ${7300}    ${9000}    ${61524}    ${61652}    ${61649}
...    ${61074}    ${61618}    ${4592}    ${1932}    ${4420}    ${4340}    ${4655}

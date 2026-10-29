*** Variables ***
${DU_OAM_IP}    ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${DU2_OAM_IP}    ${tl.gnbs[1].dus[0].f1_m_ip_addr}
${DU_OAM_SSH_USERNAME}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${DU_OAM_SSH_PASSWORD}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${DU_OAM_WEBUI_URL}    https://${tl.gnbs[0].dus[0].f1_m_ip_addr}/
${DU2_OAM_WEBUI_URL}    https://${tl.gnbs[1].dus[0].f1_m_ip_addr}/
${DU_OAM_WEBUI_USER}    ${tl.gnbs[0].cu.oam_http_connection_details.username}
${DU_OAM_WEBUI_PASSWORD}    ${tl.gnbs[0].cu.oam_http_connection_details.password}
${UTE_ADDRESS}    ${tl.test_pc.default_ssh_connection_details.addr}
${UTE_USERNAME}    ${tl.test_pc.default_ssh_connection_details.username}
${UTE_PASSWORD}    ${tl.test_pc.default_ssh_connection_details.password}
${BTS_ID}    ${tl.gnbs[0].instance_id}
${NRBTS_ID}    ${tl.gnbs[0].global_bts_id}
${BTS2_ID}    ${tl.gnbs[1].instance_id}
${NRBTS2_ID}    ${tl.gnbs[1].global_bts_id}
${default_scf_path}     ${CURDIR}/../../../../../../commissionings/HGZ/${testline_name}/
${LOG_PATH}    ${output_dir}
${luashark_path}    /opt/ute/luashark/generated_luashark
${ue_type}    ${tl.ues[0].capabilities[1]}
${IPERF_ADDR}    ${tl.appserver.iperf_details.network_interface_address}
${IPERF_portlist}    ${tl.appserver.iperf_details.ports}
${appserver_addr}    ${tl.ues[0].iperf_details.ssh_connection_details.addr}
${att_ipaddr}    ${tl.attenuator.ip_addr}
${att_api_port}    ${tl.attenuator.port}
${att_port_1}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}
${att_port_2}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[1].port_no}
${att_port_5}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[4].port_no}
${att_port_6}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[5].port_no}
${att_port_9}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[8].port_no}
${att_port_10}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[9].port_no}
${vendor}    HBTE
${max_attenuation_value}    ${127}
@{ignore_history_fault}    ${7319}    ${7300}    ${9000}    ${61524}    ${61652}    ${61649}
...    ${61074}    ${61618}    ${4592}    ${1932}    ${4420}    ${4340}    ${4655}
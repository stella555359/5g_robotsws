*** Settings ***
Documentation
...  Common variables

*** Variables ***
${X2C}=             ${tl.gnbs[0].cu.x2c.v4}
${X2C_V6}=          ${tl.gnbs[0].cu.x2c.v6}
${X2C_VLAN}=        ${tl.gnbs[0].cu.x2c.vlan_id}
${X2U}=             ${tl.gnbs[0].cu.x2u.v4}
${X2U_V6}=          ${tl.gnbs[0].cu.x2u.v6}
${X2U_VLAN}=        ${tl.gnbs[0].cu.x2u.vlan_id}
${S1U}=             ${tl.gnbs[0].cu.s1u.v4}
${S1U_V6}=          ${tl.gnbs[0].cu.s1u.v6}
${S1U_VLAN}=        ${tl.gnbs[0].cu.s1u.vlan_id}
${NGU}=             ${tl.gnbs[0].cu.ngu.v4}
${NGU_V6}=          ${tl.gnbs[0].cu.ngu.v6}
${NGU_VLAN}=        ${tl.gnbs[0].cu.ngu.vlan_id}
${NGC}=             ${tl.gnbs[0].cu.ngc.v4}
${NGC_V6}=          ${tl.gnbs[0].cu.ngc.v6}
${NGC_VLAN}=        ${tl.gnbs[0].cu.ngc.vlan_id}
${XNC}=             ${tl.gnbs[0].cu.xnc.v4}
${XNC_V6}=          ${tl.gnbs[0].cu.xnc.v6}
${XNC_VLAN}=        ${tl.gnbs[0].cu.xnc.vlan_id}
${XNU}=             ${tl.gnbs[0].cu.xnu.v4}
${XNU_V6}=          ${tl.gnbs[0].cu.xnu.v6}
${XNU_VLAN}=        ${tl.gnbs[0].cu.xnu.vlan_id}

${MPLANE_IPV4}=         ${tl.gnbs[0].cu.backhaul_site_oam_ip.v4}
${MPLANE_IPV6}=         ${tl.gnbs[0].cu.backhaul_site_oam_ip.v6}
${SSH_IP}=              ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${SSH_USERNAME}=        ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
${SSH_PASSWORD}=        ${tl.gnbs[0].cu.oam_ssh_connection_details.password}
${LMP_IP}=              ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${DEFAULT_PORT}=        ${tl.gnbs[0].cu.oam_http_connection_details.port}
${WEBEM_USERNAME}=      ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBEM_PASSWORD}=      ${tl.gnbs[0].cu.oam_http_connection_details.password}
${VLAN_ID}=             ${tl.gnbs[0].cu.backhaul_site_oam_ip.vlan_id}
${TOPOLOGY}=            ${tl.enbs[0].system_module.common_units[0].hardware_type}
${BTS_ID}=              ${tl.gnbs[0].global_bts_id}
${SEC_MRBTS}=           ${tl.enbs[0].instance_id}

${VM_IP}=               ${tl.test_pc.default_ssh_connection_details.addr}
${VM_USERNAME}=         ${tl.test_pc.default_ssh_connection_details.username}    #Sprawdzic jak to lepiej nazwac

${LMPDUIPv4}=           ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${SERIAL_NR}            ${tl.gnbs[0].dus[0].airscale.common_units[0].serial_number}
#${F1-CDUIPv4}=          ${tl.gnbs[0].dus[0].f1_c_ip_addr.v4}
#${F1-MDUIPv4}=          ${tl.gnbs[0].dus[0].f1_m_ip_addr.v4}
#${F1-UDUIPv4}=          ${tl.gnbs[0].dus[0].f1_u_ip_addr.v4}

${pdu_ip}                     ${tl.pdus[0].addr}
${pdu_port}                   ${tl.pdus[0].port_numbers[0]}
${pdu_model}                  ${tl.pdus[0].model}
${pdu_version}                ${tl.pdus[0].version}

${testline_object}=           ${tl.enbs[0]}
${bts_config}=                ${tl.gnbs[0]}

${LSS_USERNAME}             ${tl.test_pcs[0].default_ssh_connection_details.username}
${LSS_PASSWORD}             ${tl.test_pcs[0].default_ssh_connection_details.password}

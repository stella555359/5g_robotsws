*** Settings ***
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_Common.robot

*** Variables ***
#ssh sbts
${sbts_addr}         ${tl.enbs[0].oam_ip.v4}
${ssh_username}      ${tl.enbs[0].system_module[0].lmp_connection.username}
${ssh_password}      ${tl.enbs[0].system_module[0].lmp_connection.password}

${http_username}      Nemuadmin
${http_password}      nemuuser

#bts id
${MRBTS_ID}           ${tl.enbs[0].instance_id}
${NRBTS_ID}           ${tl.enbs[0].global_bts_id}

#RU info
${ru_addr}            ${tl.enbs[0].rms[0].default_ssh_connection_details.addr}
${ru_username}        ${tl.enbs[0].rms[0].default_ssh_connection_details.username}
${ru_password}        ${tl.enbs[0].rms[0].default_ssh_connection_details.password}
${ru_type_init}       ${tl.enbs[0].rms[0].radio_type.value}

#RU PDU info
${ru_pdu_vendor}       ${tl.enbs[0].rms[0].pdu_port.pdu.vendor}
${ru_pdu_addr}         ${tl.enbs[0].rms[0].pdu_port.pdu.addr}
${ru_pdu_port}         ${tl.enbs[0].rms[0].pdu_port.port_no}
${ru_serial_number}    ${tl.enbs[0].rms[0].serial_number}

#SMOD PDU info
${smod_pdu_vendor}       ${tl.enbs[0].system_module[0].pdu_port.pdu.vendor}
${smod_pdu_addr}         ${tl.enbs[0].system_module[0].pdu_port.pdu.addr}
${smod_pdu_port}         ${tl.enbs[0].system_module[0].pdu_port.port_no}

${cell_type}   lte

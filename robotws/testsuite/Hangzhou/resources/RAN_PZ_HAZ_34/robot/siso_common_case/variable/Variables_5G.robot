*** Settings ***
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_Common.robot

*** Variables ***
#ssh gNB
${asik_addr}          ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${asik_username}      ${tl.gnbs[0].cu.oam_ssh_connection_details.username}      #toor4nsn
${asik_password}      ${tl.gnbs[0].cu.oam_ssh_connection_details.password}      #oZPS0POrRieRtu

#ssh sbts
${sbts_addr}         ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${ssh_username}      ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
${ssh_password}      ${tl.gnbs[0].cu.oam_ssh_connection_details.password}

${http_username}      ${tl.gnbs[0].cu.oam_http_connection_details.username}
${http_password}      ${tl.gnbs[0].cu.oam_http_connection_details.password}

#bts id
${MRBTS_ID}           ${tl.gnbs[0].instance_id}
${NRBTS_ID}           ${tl.gnbs[0].global_bts_id}

#RU info
${ru_addr}            ${tl.gnbs[0].dus[0].rus[0].default_ssh_connection_details.addr}
${ru_username}        ${tl.gnbs[0].dus[0].rus[0].default_ssh_connection_details.username}
${ru_password}        ${tl.gnbs[0].dus[0].rus[0].default_ssh_connection_details.password}
${ru_type_init}       ${tl.gnbs[0].dus[0].rus[0].radio_type.value}  # the 1st RU by default if mulitiple RUs used
${ru_type}       ${tl.gnbs[0].dus[0].rus[0].radio_type}
${ru_serial_number}   ${tl.gnbs[0].dus[0].rus[0].serial_number}

#RU PDU info
${ru_pdu_vendor}       ${tl.gnbs[0].dus[0].rus[0].pdu_port.pdu.vendor}
${ru_pdu_addr}         ${tl.gnbs[0].dus[0].rus[0].pdu_port.pdu.addr}
${ru_pdu_port}         ${tl.gnbs[0].dus[0].rus[0].pdu_port.port_no}

#SMOD PDU info
${smod_pdu_vendor}       ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu.vendor}
${smod_pdu_addr}         ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu.addr}
${smod_pdu_port}         ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.port_no}

${cell_type}   nr
${syncStatus_path}    MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/CLOCK_R-1
${lockState_path}    MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1/TOPP-1/TOPP_R-1
${acceptedClock_path}    MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/SYNC-2/CLOCK-1/TOP-1/TOPP-1
${syncInputType_RAU_path}    MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1
@{accept_clock_value_modify}    6
${syncInputType_new}    2.048MHz input
@{syncstate_ru_error}    HOLDOVER    FREERUN
@{syncstate_ru_ok}    FREERUN    LOCKED

@{compliance_Code_list}  0  SFF_8472_REV_9_3  SFF_8472_REV_9_5  SFF_8472_REV_10_2  SFF_8472_REV_10_4  SFF_8472_REV_11_0
...    SFF_8472_REV_11_3  SFF_8472_REV_11_4  SFF_8472_REV_12_3    SFF_8636_REV_2_7    UNKNOWN    N/A
@{vendor_list}    FINISAR CORP    FINISAR CORP.    FINISARCORP.    SOURCEPHOTONICS    WTD    NOKIA
@{txPower_list}    None    N/A    4    3    2    1    -8    ${None}    -

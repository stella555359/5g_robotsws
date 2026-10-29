***Settings***
Documentation   This file contains variables for test script from Maxime's Project
...            Todo: Find a name for this project and update the documentation

***Variables***


# exec paths
${tshark_path}=             /usr/bin/tshark
${sw_build_path}            ~/Downloads/
${lua_script_path}=         ${sw_build_path}/generated_luashark/luashark.lua
${PATH_STORAGE}             ${OUTPUT DIR}
${wget_link}                https://artifactory-espoo1.int.net.nokia.com/artifactory/mnp5g-central-public/System_Release
${proxy_url}                https_proxy=https://10.144.1.10:8080
${host_address}             ${tl.test_pc.default_ssh_connection_details.addr}
${host_username}            ${tl.test_pc.default_ssh_connection_details.username}
${host_password}            ${tl.test_pc.default_ssh_connection_details.password}


# pcap files storage paths
${local_dir_path}=          ${OUTPUT DIR}
${remote_dir_path}=         /tmp
${capture_port}              etha01
${airframe} =                ${false}

# SCF
${BTS_Path}=            ${custom['BTS_Path']}
${cell_index}=          1
${dist_name}=           ${BTS_Path}/NRCELL-${cell_index}
${SCF_filename}=            current_SCF.xml

# BIP capture
${BIP_ADDR}                 10.14.62.229
${BIP_USERNAME}             root
${BIP_PASSWORD}             ute
${BIP_CAPTURE_ALIAS}        BIP-conn
${capture_port}             etha01
${log_prefix}=              bip_log.pcap
${capture_duration}=        10 s

# OAM
${OAM_IP}=                  ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${OAM_username}=            ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
${OAM_password}=            ${tl.gnbs[0].cu.oam_ssh_connection_details.password}
${OAM_alias}=           OAM-conn

${COAM_ADMIN_IP}            ${tl.gnbs[0].cu.backhaul_site_oam_ip.v4}
${COAM_ADMIN_PORT}          443
# ${COAM_ADMIN_PORT}          ${tl.gnbs[0].cu.oam_http_connection_details.port}
${COAM_ADMIN_username}      ${tl.gnbs[0].cu.oam_http_connection_details.username}
${COAM_ADMIN_password}      ${tl.gnbs[0].cu.oam_http_connection_details.password}

# OAM webUI
${WEBUI_URL}=               https://${OAM_IP}
${web_ui_username}          Nemuadmin
${web_ui_password}          nemuuser

# ASIK
${ASIK_IP}=                 ${tl.gnbs[0].dus[0].f1_m_ip_addr}
# ${ASIK_IP_2}=               ${custom['ASIK_IP_2']}
${ASIK_USER}=               ${OAM_username}
${ASIK_PWD}=                ${OAM_password}
${ASIK_alias}=              ASIK-conn

# Loner
${LONER_ADDR}=              192.168.253.38
${LONER_USERNAME}=          ${OAM_username}
${LONER_PASSWORD}=          ${OAM_password}

# Wireshark filters
${DL_MCS_MSG}=              dldata_pdschsendreq
${UL_MCS_MSG}=              uldata_puschreceivereq
${DL_MCS_VALUE_EXP}=        DlData_PdschSendReq.PdschSendReq.mcs
${UL_MCS_VALUE_EXP}=        UlData_PuschReceiveReq.grants_item_7.mcs
&{MCS_MSG_FILTER}=          UL=${UL_MCS_MSG}            DL=${DL_MCS_MSG}
&{MCS_VALUE_EXP}=           UL=${UL_MCS_VALUE_EXP}   DL=${DL_MCS_VALUE_EXP}

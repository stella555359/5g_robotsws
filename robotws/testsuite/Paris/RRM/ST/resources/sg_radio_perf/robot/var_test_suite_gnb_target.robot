*** Settings ***
Documentation
...     Test Suite Purpose:
...         Variable file for test suite
...
...         last update: 19.03.2021


*** Variables ***
${ORIG_SCF_FILE_NAME[1]}=          orig_scf_gNB1.xml
${ORIG_SCF[1]}=                    ${LOCAL_SCF_DIR_PATH}/${ORIG_SCF_FILE_NAME[1]}
${ORIG_SWCONFIG_FILE_NAME[1]}=     orig_swconfig_gNB1.txt
${ORIG_SWCONFIG[1]}=               ${LOCAL_TEMPLATE_DIR_PATH}/${ORIG_SWCONFIG_FILE_NAME[1]}

# 1070 QCT :
${BACKUP_SCF_FULLNAME[1]}      ${OUTPUT DIR}/SCF_Backup_gNB1.xml
${BACKUP_SWC_FULLNAME[1]}      ${OUTPUT DIR}/swconfig_Backup_gNB1.txt
#${REF_SCF_FULL_NAME[1]}        ${custom['ref_scf']}
#${REF_SCF_FULL_NAME4X4[0]}     ${custom['ref_scf_4x4']}
#${REF_SCF_FULL_NAME[1]}        ${custom['ref_scf_gnb1']}

#About the second gNB:
${MRBTS_NB[1]}=                ${tl.gnbs[1].instance_id}
${NRBTS_NB[1]}=                ${tl.gnbs[1].global_bts_id}

${GNB_AIRSCALE_IP[1]}=            ${tl.gnbs[1].dus[0].airscale.common_units[0].lmp_connection.addr}
${GNB_AIRSCALE_USERNAME[1]}=      ${tl.gnbs[1].dus[0].airscale.common_units[0].lmp_connection.username}
${GNB_AIRSCALE_PASSWORD[1]}=      ${tl.gnbs[1].dus[0].airscale.common_units[0].lmp_connection.password}
${GNB_ABIL0_IP[1]}=               ${tl.gnbs[1].dus[0].airscale.common_units[0].capacity_units[2].addr}
${GNB_ABIL0_xeonA[1]}=            ${tl.gnbs[1].dus[0].airscale.common_units[0].capacity_units[3].addr}
${GNB_ABIL0_xeonB[1]}=            ${tl.gnbs[1].dus[0].airscale.common_units[0].capacity_units[4].addr}

# 1070 QCT :
${ASIK_ADDR[1]}=               ${tl.gnbs[1].dus[0].airscale.common_units[0].lmp_connection.addr}
${ASIK_USERNAME[1]}=           ${tl.gnbs[1].dus[0].airscale.common_units[0].lmp_connection.username}
${ASIK_PASSWORD[1]}=           ${tl.gnbs[1].dus[0].airscale.common_units[0].lmp_connection.password}
${RU_ADDR[1]}=                 ${tl.gnbs[1].dus[0].rus[0].default_ssh_connection_details.addr}
${RU_USERNAME[1]}=             ${tl.gnbs[1].dus[0].rus[0].default_ssh_connection_details.username}
${RU_PASSWORD[1]}=             ${tl.gnbs[1].dus[0].rus[0].default_ssh_connection_details.password}

# 1070 QCT :
${GN_WEBUI[1]}=                ${tl.gnbs[1].cu.oam_http_connection_details.addr}
${GN_WEBUI_USER[1]}=           ${tl.gnbs[1].cu.oam_http_connection_details.username}
${GN_WEBUI_PWD[1]}=            ${tl.gnbs[1].cu.oam_http_connection_details.password}
${GN_WEBUI_PORT[1]}=           ${tl.gnbs[1].cu.oam_http_connection_details.port}

${GNB_OAM_ADDR[1]}=            ${tl.gnbs[1].cu.oam_ssh_connection_details.addr}
${GNB_OAM_USERNAME[1]}=        ${tl.gnbs[1].cu.oam_ssh_connection_details.username}
${GNB_OAM_PASSWORD[1]}=        ${tl.gnbs[1].cu.oam_ssh_connection_details.password}

##1070 QCT
##About eNB configuration
#${ASIA_ADDR}=                  ${custom['eNB LMP IP Address']}
#${ASIA_USERNAME}=              ${custom['eNB Username']}
#${ASIA_PASSWORD}=              ${custom['eNB Password']}
#About weight matrix csv files
#${LOCAL_WEIGHT_MATRIX}         ${custom['local_weight_matrix']}
${CORE_VLAN[1]}                ${custom['core_vlan_gNB1']}
# About X2 IP addresses
#${X2_IP_ADDR[0]}               ${custom['x2_ip_address']}
#${X2_IP_ADDR[1]}               ${custom['x2_ip_address_gNB1']}
# About Packet Sender
#${PSEND_PATH}                  ${custom['psend_path']}

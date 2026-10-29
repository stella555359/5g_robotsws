# only used by robotws5g/testsuite/RRM/NPS_IV/5GC000517/TestCases/5GC000517_B_coam_qualcomm.robot

*** Variables ***

# About SCF files
${LOCAL_SCF_PATH}              ${OUTPUT DIR}/
${LOCAL_SCF_NAME}              scf.xml
${LOCAL_SCF_FULLNAME}          ${local_scf_path}${local_scf_name}
${LOCAL_SCF_DIR_PATH}=         ${CURDIR}/Backups/scf
${LOCAL_LOG_DIR_PATH}=         ${CURDIR}/Backups/log
${ORIG_SCF_FILE_NAME}=         orig_scf.xml
${ORIG_SCF}=                   ${LOCAL_SCF_DIR_PATH}/${ORIG_SCF_FILE_NAME}
${MODIFIED_SCF_FILE_NAME}=     modified_scf.xml
${MODIFIED_SCF}=               ${LOCAL_SCF_DIR_PATH}/${MODIFIED_SCF_FILE_NAME}

${BACKUP_SCF_FULLNAME[0]}      ${OUTPUT DIR}/SCF_Backup_gNB0.xml
${BACKUP_SCF_FULLNAME[1]}      ${OUTPUT DIR}/SCF_Backup_gNB1.xml
${BACKUP_SWC_FULLNAME[0]}      ${OUTPUT DIR}/swconfig_Backup_gNB0.txt
${BACKUP_SWC_FULLNAME[1]}      ${OUTPUT DIR}/swconfig_Backup_gNB1.txt
${REF_SCF_FULL_NAME[0]}        ${custom['ref_scf']}
${REF_SCF_FULL_NAME4X4[0]}     ${custom['ref_scf_4x4']}
${REF_SCF_FULL_NAME[1]}        ${custom['ref_scf_gnb1']}

# About swconfig.txt files
${REF_SWC}                     ${custom['ref_swc']}
${REF_SWC_UL_2_2_RANK1}        ${custom['ref_swc_ul_2_2_rank1']}
${REF_SWC_UL_2_2_RANK2}        ${custom['ref_swc_ul_2_2_rank2']}

#About gNB0 configuration
# ${MRBTS_NB[0]}=                ${custom['MRBTS']}
# ${NRBTS_NB[0]}=                ${custom['GNB_nr_bts']}
${MRBTS_NB[0]}=                ${tl.gnbs[0].instance_id}
${NRBTS_NB[0]}=                ${tl.gnbs[0].global_bts_id}

${ASIK_ADDR[0]}=               ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${ASIK_USERNAME[0]}=           ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${ASIK_PASSWORD[0]}=           ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${GNB_ABIL0_IP}=               ${tl.gnbs[0].dus[0].airscale.common_units[0].capacity_units[0].addr}
${RU_ADDR[0]}=                 ${tl.gnbs[0].dus[0].rus[0].default_ssh_connection_details.addr}
${RU_USERNAME[0]}=             ${tl.gnbs[0].dus[0].rus[0].default_ssh_connection_details.username}
${RU_PASSWORD[0]}=             ${tl.gnbs[0].dus[0].rus[0].default_ssh_connection_details.password}
${GN_WEBUI[0]}=                ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${GN_WEBUI_USER[0]}=           ${tl.gnbs[0].cu.oam_http_connection_details.username}
${GN_WEBUI_PWD[0]}=            ${tl.gnbs[0].cu.oam_http_connection_details.password}
${GN_WEBUI_PORT[0]}=           ${tl.gnbs[0].cu.oam_http_connection_details.port}

#About gNB1 configuration
# ${MRBTS_NB[1]}=                ${custom['MRBTS_gNB1']}
# ${NRBTS_NB[1]}=                ${custom['NRBTS_gNB1']}
${MRBTS_NB[1]}=                ${tl.gnbs[1].instance_id}
${NRBTS_NB[1]}=                ${tl.gnbs[1].global_bts_id}

${ASIK_ADDR[1]}=               ${tl.gnbs[1].dus[0].airscale.common_units[0].lmp_connection.addr}
${ASIK_USERNAME[1]}=           ${tl.gnbs[1].dus[0].airscale.common_units[0].lmp_connection.username}
${ASIK_PASSWORD[1]}=           ${tl.gnbs[1].dus[0].airscale.common_units[0].lmp_connection.password}
${GN_WEBUI[1]}=                ${tl.gnbs[1].cu.oam_http_connection_details.addr}
${GN_WEBUI_USER[1]}=           ${tl.gnbs[1].cu.oam_http_connection_details.username}
${GN_WEBUI_PWD[1]}=            ${tl.gnbs[1].cu.oam_http_connection_details.password}

#About eNB configuration
${ASIA_ADDR}=                  ${custom['eNB LMP IP Address']}
${ASIA_USERNAME}=              ${custom['eNB Username']}
${ASIA_PASSWORD}=              ${custom['eNB Password']}

#About Attenuators configuration
${TA_ATTENUATOR_CONFIG}=       ${custom['attenuator_config']}

#About scripts to enable the L1L2 mirroring
${ASIK_SCRIPT_MIRROR}=         ${custom['asik_mirroring_script']}
${LONER_SCRIPT_MIRROR}=        ${custom['loner_mirroring_script']}

#About weight matrix csv files
${LOCAL_WEIGHT_MATRIX}         ${custom['local_weight_matrix']}

#About Blade configured to capture L1L2 traces
${L1L2_AIRFRAME_IPADDRESS}=    ${custom['l1l2_airframe_ipaddress']}
${L1L2_AIRFRAME_USERNAME}=     ${custom['l1l2_airframe_login']}
${L1L2_AIRFRAME_PASSWORD}=     ${custom['l1l2_airframe_passwd']}
${L1L2_AIRFRAME_INTERFACE}=    ${custom['l1l2_airframe_interface']}

#About Traffic server at UE side
# ${IPERF_VM_UL_IPADDRESS}=	   ${custom['iPerf_VM_UL_ipaddress']}
# ${IPERF_VM_UL_LOGIN}=		   ${custom['iPerf_VM_UL_login']}
# ${IPERF_VM_UL_PASSWD}=		   ${custom['iPerf_VM_UL_passwd']}
# ${IPERF_VM_UL_IPERF_PATH}=	   ${custom['iPerf_VM_UL_iPerf_Path']}
${ULserver_ip}=            ${tl.ues[0].ssh_connection_details.addr}
${ULserver_login}=         ${tl.ues[0].ssh_connection_details.username}
${ULserver_pwd}=           ${tl.ues[0].ssh_connection_details.password}

#About Traffic server at Core side
# ${IPERF_VM_DL_IPADDRESS}=	   ${custom['iPerf_VM_DL_ipaddress']}
# ${IPERF_VM_DL_LOGIN}=		   ${custom['iPerf_VM_DL_login']}
# ${IPERF_VM_DL_PASSWD}=		   ${custom['iPerf_VM_DL_passwd']}
# ${COREIPTRAFFICSERVER}=        ${custom['iPerf_VM_DL_Network_Interface_Address']}

# this only match with QCT/Android, not Prisma
# ${DLserver_ip}=            ${tl.ues[0].iperf_details.ssh_connection_details.addr}
# ${DLserver_login}=         ${tl.ues[0].iperf_details.ssh_connection_details.username}
# ${DLserver_pwd}=           ${tl.ues[0].iperf_details.ssh_connection_details.password}
# ${DLserver_uplane_ip}=     ${tl.ues[0].iperf_details.network_interface_address}
# match with all UE types
${DLserver_ip}              ${tl.appserver.iperf_details.ssh_connection_details.addr}
${{DLserver_login}          ${tl.appserver.iperf_details.ssh_connection_details.username}
${DLserver_pwd}             ${tl.appserver.iperf_details.ssh_connection_details.password}
${DLserver_uplane_ip}       ${tl.appserver.iperf_details.network_interface_address}





# About traffic duration in seconds for feature 1070 tests
# ${TRAFFIC_DURATION}            460

# About X2 IP addresses
${X2_IP_ADDR[0]}               ${custom['x2_ip_address']}
${X2_IP_ADDR[1]}               ${custom['x2_ip_address_gNB1']}

# About LUA shark
${LUA_PATH}                    ${custom['lua_path']}

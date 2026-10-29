*** Settings ***
Documentation
...     Test Suite Purpose:
...         Variable file for test suite
...
...         last update: 19.03.2021


*** Variables ***
${DEBUG_MODE_CONSOLE}=           ${True}

${LOCAL_TEMPLATE_DIR_PATH}=      ${OUTPUTDIR}/Backup/template
${LOCAL_SCF_DIR_PATH}=           ${LOCAL_TEMPLATE_DIR_PATH}
${LOCAL_LOG_DIR_PATH}=           ${OUTPUTDIR}/Backup/log
#${LOCAL_LOG_DIR_PATH}=           ${OUTPUTDIR}/log
#${LOCAL_SCF_DIR_PATH}=           ${OUTPUTDIR}/Backup/template

${MRBTS}                       ${tl.gnbs[0].instance_id}
${NRBTS}                       ${tl.gnbs[0].global_bts_id}

#removed use of GNB_Friendly_TL_Name from custom.yaml
${ORIG_SCF_FILE_NAME}=         CV${MRBTS}_orig_scf.xml
${ORIG_SCF}=                   ${LOCAL_SCF_DIR_PATH}/${ORIG_SCF_FILE_NAME}
${MODIFIED_SCF_FILE_NAME}=     CV${MRBTS}_modified_scf.xml
${MODIFIED_SCF}=               ${LOCAL_SCF_DIR_PATH}/${MODIFIED_SCF_FILE_NAME}
${ORIG_SWCONFIG_FILE_NAME}=    CV${MRBTS}_orig_swconfig.txt
${ORIG_SWCONFIG}=              ${LOCAL_TEMPLATE_DIR_PATH}/${ORIG_SWCONFIG_FILE_NAME}

${ORIG_SCF_FILE_NAME[0]}=          orig_scf_gNB0.xml
${ORIG_SCF[0]}=                    ${LOCAL_SCF_DIR_PATH}/${ORIG_SCF_FILE_NAME[0]}
${ORIG_SWCONFIG_FILE_NAME[0]}=     orig_swconfig_gNB0.txt
${ORIG_SWCONFIG[0]}=               ${LOCAL_TEMPLATE_DIR_PATH}/${ORIG_SWCONFIG_FILE_NAME[0]}

# working local SCF file
${LOCAL_SCF_PATH}              ${OUTPUT DIR}/
${LOCAL_SCF_NAME}              scf.xml
${LOCAL_SCF_FULLNAME}          ${local_scf_path}${local_scf_name}

${BACKUP_SCF_FULLNAME[0]}      ${OUTPUT DIR}/SCF_Backup_gNB0.xml
${BACKUP_SWC_FULLNAME[0]}      ${OUTPUT DIR}/swconfig_Backup_gNB0.txt
#${REF_SCF_FULL_NAME[0]}        ${custom['ref_scf']}
#${REF_SCF_FULL_NAME4X4[0]}     ${custom['ref_scf_4x4']}
#${REF_SCF_FULL_NAME[1]}        ${custom['ref_scf_gnb1']}
# About swconfig.txt files
#${REF_SWC}                     ${custom['ref_swc']}
#${REF_SWC_UL_2_2_RANK1}        ${custom['ref_swc_ul_2_2_rank1']}
#${REF_SWC_UL_2_2_RANK2}        ${custom['ref_swc_ul_2_2_rank2']}

# prisma case:
#${ORIG_SDRCFG_FILE_NAME}=      CV${MRBTS}_orig_sdrcfg.txt
#${ORIG_SDRCFG}=                ${LOCAL_TEMPLATE_DIR_PATH}/${ORIG_SDRCFG_FILE_NAME}

#${PM_STORAGE}=              ${custom['eclat']['PM_STORAGE']}
##${PATH_Storage}=             ${custom['PATH_Storage']}
##${PATH_TL_Config}=           ${custom['PATH_TL_Config']}

#About gNB0 configuration
${MRBTS_NB[0]}=                ${tl.gnbs[0].instance_id}
${NRBTS_NB[0]}=                ${tl.gnbs[0].global_bts_id}

${myTL}=                        CV${MRBTS}
#${gNB_Architecture}=           ${custom['GNB_Architecture']}
#${UE_Architecture}=            ${custom['UE_Architecture']}
${cellId}=                     ${custom['GNB_First_CellID']}

${BB1_IP_LOCAL}=               ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${BB1_LOGIN}=                  ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${BB1_PASSWORD}=               ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${GNB_AIRSCALE_IP}=            ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${GNB_AIRSCALE_USERNAME}=      ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${GNB_AIRSCALE_PASSWORD}=      ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${GNB_ABIL0_IP}=               ${tl.gnbs[0].dus[0].airscale.common_units[0].capacity_units[2].addr}
${GNB_ABIL0_xeonA}=            ${tl.gnbs[0].dus[0].airscale.common_units[0].capacity_units[3].addr}
${GNB_ABIL0_xeonB}=            ${tl.gnbs[0].dus[0].airscale.common_units[0].capacity_units[4].addr}

${GNB_AIRSCALE_IP[0]}=            ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${GNB_AIRSCALE_USERNAME[0]}=      ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${GNB_AIRSCALE_PASSWORD[0]}=      ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${GNB_ABIL0_IP[0]}=               ${tl.gnbs[0].dus[0].airscale.common_units[0].capacity_units[2].addr}
${GNB_ABIL0_xeonA[0]}=            ${tl.gnbs[0].dus[0].airscale.common_units[0].capacity_units[3].addr}
${GNB_ABIL0_xeonB[0]}=            ${tl.gnbs[0].dus[0].airscale.common_units[0].capacity_units[4].addr}

# 1070 QCT :
${ASIK_ADDR[0]}=               ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${ASIK_USERNAME[0]}=           ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${ASIK_PASSWORD[0]}=           ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${RU_ADDR[0]}=                 ${tl.gnbs[0].dus[0].rus[0].default_ssh_connection_details.addr}
${RU_USERNAME[0]}=             ${tl.gnbs[0].dus[0].rus[0].default_ssh_connection_details.username}
${RU_PASSWORD[0]}=             ${tl.gnbs[0].dus[0].rus[0].default_ssh_connection_details.password}

#${SimulatedeNB_flag}=         False
#${Classicalenv_flag}=         True

#${GN_WEBUI}=                  https://${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${GN_WEBUI}=                   https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
# 1070 QCT :
${GN_WEBUI[0]}=                ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${GN_WEBUI_USER[0]}=           ${tl.gnbs[0].cu.oam_http_connection_details.username}
${GN_WEBUI_PWD[0]}=            ${tl.gnbs[0].cu.oam_http_connection_details.password}
${GN_WEBUI_PORT[0]}=           ${tl.gnbs[0].cu.oam_http_connection_details.port}

${GNB_OAM_ADDR[0]}=            ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${GNB_OAM_USERNAME[0]}=        ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
${GNB_OAM_PASSWORD[0]}=        ${tl.gnbs[0].cu.oam_ssh_connection_details.password}


#1070 QCT
#About eNB configuration
${ASIA_ADDR}=                  ${custom['eNB LMP IP Address']}
${ASIA_USERNAME}=              ${custom['eNB Username']}
${ASIA_PASSWORD}=              ${custom['eNB Password']}
#About weight matrix csv files
${LOCAL_WEIGHT_MATRIX}         ${custom['local_weight_matrix']}
# Core Vlan
${CORE_VLAN[0]}                ${custom['core_vlan']}
# About X2 IP addresses
${X2_IP_ADDR[0]}               ${custom['x2_ip_address']}
#${X2_IP_ADDR[1]}               ${custom['x2_ip_address_gNB1']}
# About Packet Sender
${PSEND_PATH}                  ${custom['psend_path']}


# Variable used for iPerf manipulation
# ====================================
# ${DLserver_ip}=          ${custom['iPerf_VM_DL_ipaddress']}
# ${DLserver_login}=       ${custom['iPerf_VM_DL_login']}
# ${DLserver_pwd}=         ${custom['iPerf_VM_DL_passwd']}
# ${DLserver_uplane_ip}=   ${custom['iPerf_VM_DL_Network_Interface_Address']}

# Only match with QCT/Anrdoid, not prisma
# ${DLserver_ip}=            ${tl.ues[0].iperf_details.ssh_connection_details.addr}
# ${DLserver_login}=         ${tl.ues[0].iperf_details.ssh_connection_details.username}
# ${DLserver_pwd}=           ${tl.ues[0].iperf_details.ssh_connection_details.password}
# ${DLserver_uplane_ip}=     ${tl.ues[0].iperf_details.network_interface_address}
# Match with all UE types
${DLserver_ip}           ${tl.appserver.iperf_details.ssh_connection_details.addr}
${DLserver_login}        ${tl.appserver.iperf_details.ssh_connection_details.username}
${DLserver_pwd}          ${tl.appserver.iperf_details.ssh_connection_details.password}
${DLserver_uplane_ip}    ${tl.appserver.iperf_details.network_interface_address}

# UL part is moved to var_test_suite_qct_iperf_ul.robot or vart_test_suite_prisma.robot :
# ${ULserver_ip}=          ${custom['iPerf_VM_UL_ipaddress']}
# ${ULserver_login}=       ${custom['iPerf_VM_UL_login']}
# ${ULserver_pwd}=         ${custom['iPerf_VM_UL_passwd']}
# ue ip should be retrieved dyn when Ue is QCT
# UE_ip is used for case Prisma UE : "iPerf_VM_UL_Network_Interface_Address" from custom.yaml
# ${UE_ip}=                ${custom['iPerf_VM_UL_Network_Interface_Address']} (moved to var_test_suite_prisma.robot

#for 1070 QCT : About Traffic server at UE side
# ${IPERF_VM_UL_IPADDRESS}=	   ${custom['iPerf_VM_UL_ipaddress']}
# ${IPERF_VM_UL_LOGIN}=		   ${custom['iPerf_VM_UL_login']}
# ${IPERF_VM_UL_PASSWD}=	   ${custom['iPerf_VM_UL_passwd']}
# ${IPERF_VM_UL_IPERF_PATH}=   ${custom['iPerf_VM_UL_iPerf_Path']}
#for 1070 QCT : About Traffic server at Core side
# ${IPERF_VM_DL_IPADDRESS}=	   ${custom['iPerf_VM_DL_ipaddress']}
# ${IPERF_VM_DL_LOGIN}=		   ${custom['iPerf_VM_DL_login']}
# ${IPERF_VM_DL_PASSWD}=	   ${custom['iPerf_VM_DL_passwd']}
# ${COREIPTRAFFICSERVER}=        ${custom['iPerf_VM_DL_Network_Interface_Address']}
# About traffic duration in seconds for feature 1070 tests
# removal as the variable affects various testcases !
# ${TRAFFIC_DURATION}=            460

#${IPERF_VERSION_PREFERENCE}=            ${custom['iPerf_version_preference']}

# Variables used for L1/L2 mirroring
# ==================================
#About Blade configured to capture L1L2 traces
${L1L2_AIRFRAME_IPADDRESS}=         ${custom['l1l2_airframe_ipaddress']}
${L1L2_AIRFRAME_USERNAME}=          ${custom['l1l2_airframe_login']}
${L1L2_AIRFRAME_PASSWORD}=          ${custom['l1l2_airframe_passwd']}
${L1L2_AIRFRAME_INTERFACE}=         ${custom['l1l2_airframe_interface']}
#${l1l2_airframe_ipaddress}=         ${custom['l1l2_airframe_ipaddress']}
#${l1l2_airframe_login}=             ${custom['l1l2_airframe_login']}
#${l1l2_airframe_passwd}=            ${custom['l1l2_airframe_passwd']}


#About scripts to enable the L1L2 mirroring
${ASIK_SCRIPT_MIRROR}=         ${custom['asik_mirroring_script']}
${LONER_SCRIPT_MIRROR}=        ${custom['loner_mirroring_script']}
#${asik_script_mirror}=              /ffs/run/logs/gnbMirroringV9.sh
#${loner_script_mirror}=             /ffs/run/config/scripts/loner_mirroring_L1R51_moded.sh


# About LUA shark
${LUA_PATH}=                    ${custom['lua_path']}
#${Lua_Path}                             /home/localuser/generated_luashark/

#${HW_Configuration}=             ${custom['HW_Configuration'][0]}

# since 5GC000706
${reference_gnb_for_time}=       0


#EDA added to check resources in suite setup/teardown
${check_eda}=    	${False}
${resources_before}=    ${EMPTY}
${resources_after}=     ${EMPTY}

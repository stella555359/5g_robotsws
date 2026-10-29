*** Settings ***
Documentation
...     Test Suite Purpose:
...         Variable file for L3 call NSA test suite
...
...     AUTHOR (I&V-1):
...         Philippe Vignerte   philippe.vignerte @nokia.com
...         Annie Wong
...         last update: 28.05.2021   error on variable ${MODIFIED_SCF}

Variables       ../../../../../resources/sites/NPS/PROD/python/custom.py


*** Variables ***
${LOCAL_TEMPLATE_DIR_PATH}=      ${OUTPUTDIR}/template
${LOCAL_LOG_DIR_PATH}=      ${OUTPUTDIR}/log

${MRBTS}=               ${tl.gnbs[0].instance_id}
${NRBTS}=               ${tl.gnbs[0].global_bts_id}

${ORIG_SCF_FILE_NAME}=         CV${MRBTS}_orig_scf.xml
${ORIG_SCF}=                   ${LOCAL_TEMPLATE_DIR_PATH}/${ORIG_SCF_FILE_NAME}
${MODIFIED_SCF_FILE_NAME}=     CV${MRBTS}_modified_scf.xml
${MODIFIED_SCF}=               ${LOCAL_TEMPLATE_DIR_PATH}/${MODIFIED_SCF_FILE_NAME}

${ORIG_SWCONFIG_FILE_NAME}=    CV${MRBTS}_orig_swconfig.txt
${ORIG_SWCONFIG}=              ${LOCAL_TEMPLATE_DIR_PATH}/${ORIG_SWCONFIG_FILE_NAME}

${ORIG_SDRCFG_FILE_NAME}=      CV${MRBTS}_orig_sdrcfg.txt
${ORIG_SDRCFG}=                ${LOCAL_TEMPLATE_DIR_PATH}/${ORIG_SDRCFG_FILE_NAME}

${BB1_IP_LOCAL}=            ${tl.gnbs[0].du.airscale.common_units[0].lmp_connection.addr}
${BB1_LOGIN}=               ${tl.gnbs[0].du.airscale.common_units[0].lmp_connection.username}
${BB1_PASSWORD}=            ${tl.gnbs[0].du.airscale.common_units[0].lmp_connection.password}

#${BB1_IP_LOCAL}=           ${tl.gnbs[0].du.airscale.common_units[0].lmp_connection.addr} // commenté par ECT pour ajout ligne suivante
${GNB_AIRSCALE_IP}=                     ${tl.gnbs[0].du.airscale.common_units[0].lmp_connection.addr}
${GNB_AIRSCALE_USERNAME}=               ${tl.gnbs[0].du.airscale.common_units[0].lmp_connection.username}
${GNB_AIRSCALE_PASSWORD}=               ${tl.gnbs[0].du.airscale.common_units[0].lmp_connection.password}
${GNB_ABIL0_IP}=                        ${tl.gnbs[0].dus[0].airscale.common_units[0].capacity_units[0].addr}
${line}=                                0
${throughoutput}=                       0
${sum}=                                 0
${TraceAnalysisAssemement}=             0
#${GN_WEBUI}=                           https://${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${GN_WEBUI}=                            https://${tl.gnbs[0].cu.oam_http_connection_details.addr}

${myTL}=                        CV${MRBTS}
#${gNB_Architecture}=                    ${custom['GNB_Architecture']}
${cellId}=                              ${custom['GNB_First_CellID']}
${Lua_Path}                             /home/localuser/generated_luashark/

# Variable used for Prisma manipulation
# =====================================
${AP_LSU_UU_ip}=                        ${tl.ues[0].lsu_uu_ssh_connection_details.addr}
${AP_TSTM_UU_ip}=                       ${tl.ues[0].tstm_uu_ssh_connection_details.addr}
#${AP_LSU_CORE_ip}=                      ${tl.core.lsu_s1_ssh_connection_details.addr}
${sdrDLGain}=                           ${custom['Dl_gain']}
${sdrULGain}=                           ${custom['Ul_gain']}
${am_host}=                             ${tl.ues[0].airmosaic_harness_connection_details.addr}
${am_port}=                             ${tl.ues[0].airmosaic_harness_connection_details.port}
${AM_PATH}=                             ${custom['prisma_cli_path']}
${airmosaic_config_files_path_name}=    ${custom['airmosaic_cfg_path']}
${sid_file_name}=                       ${custom['sid_filename']}
${zip_path_name}=                       /tmp
${zip_file_name}=                       my_zip.zip
#${scenario_prisma_file_full_name}=      ${CURDIR}/${scenario_prisma_file_name}
${scenario_prisma_file_full_name}=      ${airmosaic_config_files_path_name}/${scenario_prisma_file_name}
${am_zip_package}=                      ${zip_path_name}/${zip_file_name}
#${generated_scenario_prisma_file_full_name}=      ${airmosaic_config_files_path_name}/${generated_scenario_prisma_file_name}
${AP_PRISMA_TAF_YAML_PATH}=             ${custom['yaml_prisma_filename_path']}
${AP_PRISMA_TAF_YAML_FILENAME}=         ${custom['yaml_prisma_filename']}
${AP_PRISMA_TAF_YAML_FULLPATH}=         ${custom['yaml_prisma_filename_path']}/${custom['yaml_prisma_filename']}
${lsu_s1_node}=                         lsu_s1
${lsu_x2uu_node}=                       lsu_uu
${lsu_tstmx2}=                          tstm_x2
${lsu_tstmuu}=                          tstm_uu
${airmosaic}=                           airmosaic
${SimulatedeNB_flag}=                   False
${Classicalenv_flag}=                   True

# Variable used for iPerf manipulation
# ====================================
# ${DLserver_ip}=                         ${custom['iPerf_VM_DL_ipaddress']}
# ${DLserver_login}=                      ${custom['iPerf_VM_DL_login']}
# ${DLserver_pwd}=                        ${custom['iPerf_VM_DL_passwd']}
# ${DLserver_uplane_ip}=                  ${custom['iPerf_VM_DL_Network_Interface_Address']}
${DLserver_ip}              ${tl.appserver.iperf_details.ssh_connection_details.addr}
${{DLserver_login}          ${tl.appserver.iperf_details.ssh_connection_details.username}
${DLserver_pwd}             ${tl.appserver.iperf_details.ssh_connection_details.password}
${DLserver_uplane_ip}       ${tl.appserver.iperf_details.network_interface_address}

# ${ULserver_ip}=                         ${custom['iPerf_VM_UL_ipaddress']}
# ${ULserver_login}=                      ${custom['iPerf_VM_UL_login']}
# ${ULserver_pwd}=                        ${custom['iPerf_VM_UL_passwd']}
# ${UE_ip}=                               ${custom['iPerf_VM_UL_Network_Interface_Address']}
${ULserver_ip}=            ${tl.ues[0].iperf_details.ssh_connection_details.addr}
${ULserver_login}=         ${tl.ues[0].iperf_details.ssh_connection_details.username}
${ULserver_pwd}=           ${tl.ues[0].iperf_details.ssh_connection_details.password}
${UE_ip}=                  ${tl.ues[0].iperf_details.network_interface_address}

# Variables used for L1/L2 mirroring
# ==================================
${l1l2_airframe_ipaddress}=         ${custom['l1l2_airframe_ipaddress']}
${l1l2_airframe_login}=             ${custom['l1l2_airframe_login']}
${l1l2_airframe_passwd}=            ${custom['l1l2_airframe_passwd']}
${asik_script_mirror}=              /ffs/run/logs/gnbMirroringV9.sh
${loner_script_mirror}=             /ffs/run/config/scripts/loner_mirroring_L1R51_moded.sh

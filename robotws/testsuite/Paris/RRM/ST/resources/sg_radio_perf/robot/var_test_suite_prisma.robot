*** Settings ***
Documentation
...     Test Suite Purpose:
...         Variable file for Prisma manipulation
...
...         last update: 10.06.2020

*** Variables ***
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
${scenario_prisma_file_full_name}=      ${airmosaic_config_files_path_name}/${scenario_prisma_file_name}
${am_zip_package}=                      ${zip_path_name}/${zip_file_name}
${AP_PRISMA_TAF_YAML_PATH}=             ${custom['yaml_prisma_filename_path']}
${AP_PRISMA_TAF_YAML_FILENAME}=         ${custom['yaml_prisma_filename']}
${AP_PRISMA_TAF_YAML_FULLPATH}=         ${custom['yaml_prisma_filename_path']}/${custom['yaml_prisma_filename']}
${lsu_s1_node}=                         lsu_s1
${lsu_x2uu_node}=                       lsu_uu
${lsu_tstmx2}=                          tstm_x2
${lsu_tstmuu}=                          tstm_uu
${airmosaic}=                           airmosaic

# ${ULserver_ip}=          ${custom['iPerf_VM_UL_ipaddress']}
# ${ULserver_login}=       ${custom['iPerf_VM_UL_login']}
# ${ULserver_pwd}=         ${custom['iPerf_VM_UL_passwd']}
# UE_ip is used for case Prisma UE : "iPerf_VM_UL_Network_Interface_Address" from custom.yaml
# ${UE_ip}=                ${custom['iPerf_VM_UL_Network_Interface_Address']}
${ULserver_ip}=            ${tl.ues[0].iperf_details.ssh_connection_details.addr}
${ULserver_login}=         ${tl.ues[0].iperf_details.ssh_connection_details.username}
${ULserver_pwd}=           ${tl.ues[0].iperf_details.ssh_connection_details.password}
# UE_ip (soon be removed) only dedicated to UE_0 ! in multi ue case, the ip is retrieved in keywords through ue_index
${UE_ip}=                  ${tl.ues[0].iperf_details.network_interface_address}
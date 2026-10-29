*** Settings ***
Documentation
...     Test Suite Purpose:
...         Test Suite variables
...
...     AUTHOR (mmW&SC Pz NPS 4 SG):
...         I_MNP_5G_NPS_IVU_SISO_MOBILITY@nokia.com

*** Variables ***
# Test execution flags, range: False, True
${DEBUG}            False
${NO_ENB}           True
${SIM_UE}           True
${DO_RESTORE_ENB}   False
${DO_RESTORE_GNB}   True

# Ute Vm infos   probably to be suppress
${vm_ip}                             ${tl.test_pc.default_ssh_connection_details.addr}
${vm_user}                           ${tl.test_pc.default_ssh_connection_details.username}
${vm_password}                       ${tl.test_pc.default_ssh_connection_details.password}

# Traffic mapping:
## ----------------
#${buffer_length}=               1350
#${dl_ul_time}=                  300
#${throughput_DL}=               1M
#${throughput_UL}=               1M

# Variable used for Prisma:
# -------------------------
${AP_LSU_UU_ip}=                        ${tl.ues[0].lsu_uu_ssh_connection_details.addr}
${AP_LSU_UU_login}=                     ${tl.ues[0].lsu_uu_ssh_connection_details.username}
${AP_LSU_UU_passwd}=                    ${tl.ues[0].lsu_uu_ssh_connection_details.password}
${AP_TSTM_UU_ip}=                       ${tl.ues[0].tstm_uu_ssh_connection_details.addr}
${sdrDLGain}=                           ${custom['Dl_gain']}
${sdrULGain}=                           ${custom['Ul_gain']}
${am_host}=                             ${tl.ues[0].airmosaic_harness_connection_details.addr}
${am_port}=                             ${tl.ues[0].airmosaic_harness_connection_details.port}
${AM_PATH}=                             ${custom['prisma_cli_path']}
${scenario_prisma_folder}=              ${custom['airmosaic_cfg_path']}
#${scenario_prisma_file_name}=           ${custom['sid_filename']}
#${scenario_prisma_file_full_name}=      ${scenario_prisma_folder}/${scenario_prisma_file_name}
# ${am_zip_package}=                    ${zip_path_name}/${zip_file_name}
${dedicated_scenario}                   ${scenario_prisma_file_name}
#${specific_scenario}=                  5GC002240_EA.sce
${default_sid_file}                     ${custom['sid_filename']}

${AP_PRISMA_TAF_YAML_PATH}=             ${custom['yaml_prisma_filename_path']}
${AP_PRISMA_TAF_YAML_FILENAME}=         ${custom['yaml_prisma_filename']}
${AP_PRISMA_TAF_YAML_FULLPATH}=         ${AP_PRISMA_TAF_YAML_PATH}/${AP_PRISMA_TAF_YAML_FILENAME}
${lsu_s1_node}=                         lsu_s1
${lsu_x2uu_node}=                       lsu_uu
${lsu_tstmx2}=                          tstm_x2
${lsu_tstmuu}=                          tstm_uu
${airmosaic}=                           airmosaic
${SimulatedeNB_flag}=                   True
${Classicalenv_flag}=                   False
#${prisma_ppu_cell_4G}=                  ${custom['prisma_ppu_cell_4G']}
${prisma_ppu_cell_5G}=                  ${custom['prisma_ppu_cell_5G']}
${mrbts}                                MRBTS-${tl.gnbs[0].instance_id}
${dn}                                   ${mrbts}/NRBTS-${tl.gnbs[0].global_bts_id}


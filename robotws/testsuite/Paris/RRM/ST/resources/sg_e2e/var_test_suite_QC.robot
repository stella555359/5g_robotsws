*** Settings ***
Documentation
...	    Test Suite Purpose:
...	        Variable file for ...

*** Variables ***
#${PATH_Storage}=                    ${custom['PATH_Storage']}
#${PATH_TL_Config}=                  ${custom['PATH_TL_Config']}
#${HOME_DIR}=                        Evaluate os.environ.get("HOME", "")
${PATH_Storage}=                    %{HOME}/test_results/robot_temporary

${oam_vm}=                          ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${oamVMLogin}=                      ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
${oamVMPassword}=                   ${tl.gnbs[0].cu.oam_ssh_connection_details.password}
${oamVMMzLogin}=                    ${tl.gnbs[0].cu.oam_http_connection_details.username}
${oamVMMzPassword}=                 ${tl.gnbs[0].cu.oam_http_connection_details.password}

# fronthaul access to ASIK when in cloud MZOAM
${asik_fh}=                         192.168.2.60

# ASIK ABIL addresses
${oam_asik}=                        ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${asikFHLogin}=                     ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${asikFHPassword}=                  ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${asik_slave}=                      fctlb
${abil_loner}=                      fsp1_c
${abil_xeonA}=                      fsp1_a
${abil_xeonB}=                      fsp1_b

# ASOD addresses
${oam_asod}=                        ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${asodFHLogin}=                     ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${asodFHPassword}=                  ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${asod_slave}=                      192.168.253.17
${asod_loner}=                      192.168.253.18


${GNB_Topology}=                    ${tl.tl_cloud_topology}
${add_ip_route}=                    None

@{asik_master_containers}=          0xe002  0xe003  0xe004  0xe00a  0xe00c  0xe00d  0xe00f  0xe01b
@{asik_slave_containers}=           0x102a  0xe005  0xe007  0xe008  0xe01c

${init_scf_oam_vm_path}=            /ffs/run/config/node_0xe000/siteoam/config
${init_scf_file_name}=              SBTS_SCF.xml
${updated_scf_file_name}=          scf_under_test.xml

# keep for compatibility with previous scripts
${GNB_Friendly_TL_Name}=            TL
${GNB_nr_bts}=                      ${tl.gnbs[0].global_bts_id}
${mr_bts}=                          ${tl.gnbs[0].instance_id}
${GNB_nr_bts_cu}=                   ${tl.gnbs[0].cu.global_bts_id}
${mr_bts_cu}=                       ${tl.gnbs[0].cu.instance_id}
${GNB_nr_bts_du}=                   ${tl.gnbs[0].dus[0].global_bts_id}
${mr_bts_du}=                       ${tl.gnbs[0].dus[0].instance_id}

# MIRRORING used for Cloud configuration, performed on controller board
${mirroring}=                       ${tl.gnbs[0].cloud_deployment.cloud_hosting.control_nodes[0].open_stack_connection_details.ip_addr}
${mirroring_login}=                 ${tl.gnbs[0].cloud_deployment.cloud_hosting.control_nodes[0].open_stack_connection_details.username}
${mirroring_password}=              ${tl.gnbs[0].cloud_deployment.cloud_hosting.control_nodes[0].open_stack_connection_details.password}
# tester en enlevant cette ligne
${L1L2_itf}=                        ${custom['L1L2_itf']}
# tester en enlevant cette ligne
${L1L2_FILTER_MSG}=                 ${custom['L1L2_filter_msg']}
# Syscom tcpdump interface (without mirroring). Valid for ASIK and ASOD
${syscom_itf}=                      etha01

# Mirroring for X2. Performed on eNB board
${mirroring2}=                      ${tl.enbs[0].oam_ip.v4}
${mirroring2_login}=                ${tl.enbs[0].airscale.common_units[0].lmp_connection.username}
${mirroring2_password}=             ${tl.enbs[0].airscale.common_units[0].lmp_connection.password}
${S1X2_itf}=                        br1
${S1X2_FILTER_MSG}=                 ${EMPTY}
${S1X2_FILTER_HOST}=                ${EMPTY}


# Sudo command used on different boards
# tester en remplacant la commande
#${sudoCommand1}=                    ${custom['sudo_command_1']}
${sudoCommand1}=                    'echo uteadmin | sudo -S'
${sudoCommand2}=                    ${EMPTY}




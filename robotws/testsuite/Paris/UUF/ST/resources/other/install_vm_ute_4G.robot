*** Settings ***
Library    taf.transport.ssh   WITH NAME   ssh
Resource       taf/rfrl/uuf4all/uuf4all_test_cases.robot


*** Variables ***
${UTE_VM_4G_IP}=    ${tl.test_pcs[0].default_ssh_connection_details.addr}
${UTE_VM_5G_IP}=    ${tl.test_pc[0].default_ssh_connection_details.addr}

*** Keywords ***
Clean And Prepare UTE VM 4G
    [Teardown]  Run Keyword and Ignore Error  ssh.disconnect  connection=vm_ute_4G
#    Run keyword if   "${UTE_VM_4G_IP}" == ""   RETURN
#    Run keyword if   "${UTE_VM_4G_IP}" == "None"   RETURN
#    Run keyword if   "${UTE_VM_4G_IP}" == "${UTE_VM_5G_IP}"   RETURN
#    Run Keyword and Ignore Error   if   "${USE_REMOTE_NODE}" == False   RETURN
#    Run Keyword and Ignore Error   if   "${REMOTE_NODE_UPDATE}" == False   RETURN
#    Run Keyword and Ignore Error   if   "${with4G}" == False   RETURN

    ssh.Connect To  ${tl.test_pcs[0].default_ssh_connection_details.addr}
    ...             ${tl.test_pcs[0].default_ssh_connection_details.username}
    ...             ${tl.test_pcs[0].default_ssh_connection_details.password}
    ...             timeout=60  alias=vm_ute_4G
    Run keywords  ssh.Upload file  local_path=${CURDIR}/install_vm_ute_4G.sh
    ...                            remote_path=/home/ute/install_vm_ute_4G.sh
    ...                            connection=vm_ute_4G                   AND
    ...           ssh.Execute      chmod 777 /home/ute/install_vm_ute_4G.sh
    ...                            connection=vm_ute_4G

#    Run keywords  ssh.Upload file  local_path=/opt/ute/node/node
#    ...                            remote_path=/opt/ute/node/node
#    ...                            connection=vm_ute_4G                   AND
#    ...           ssh.Execute      chmod 777 /opt/ute/node/node
#    ...                            connection=vm_ute_4G

#    Run keywords  ssh.Upload file  local_path=/home/ute/test_repository/requirements.cfg
#    ...                            remote_path=/home/ute/test_repository/requirements.cfg
#    ...                            connection=vm_ute_4G

    Log               ************** Start UTE VM 4G Preparation ************
    ssh.Execute  sh cd /home/ute; ./install_vm_ute_4G.sh   connection=vm_ute_4G
    Log               ************** End UTE VM 4G Preparation ************
    Log               Check Installation_ute_env.log for details
                                                                                 

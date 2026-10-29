*** Settings ***
Documentation
...   contact: Monika Ceglarek

Library     create_init_file.py


*** Variables ***
${VDU_SSH_IP}                                                          # IP of vDU used for SSH connection.
${VDU_SSH_USER}                                                        # Username for SSH connection with vDU.
${VDU_SSH_PASSWORD}                                                    # Password for SSH connection with vDU.
${VDU_OAM_IP}                                                          # OAM IP address for connecting with vDU (M-plane).
${VDU_OAM_USER}                                                        # OAM username for connecting with vDU.
${VDU_OAM_PASSWORD}                                                    # OAM password for connecting with vDU.
${VDU_NAMESPACE}                                                       # Namespace for vDU.
${VCU_SSH_IP}                                                          # IP of vCU used for ssh connection.
${VCU_SSH_USER}                                                        # Username for SSH connection with vCU.
${VCU_SSH_PASSWORD}                                                    # Password for SSH connection with vCU.
${VCU_OAM_IP}                                                          # OAM IP address for connecting with vCU (M-plane).
${VCU_OAM_USER}                                                        # OAM username for connecting with vCU.
${VCU_OAM_PASSWORD}                                                    # OAM password for connecting with vCU.
${VCU_NAMESPACE}                                                       # Namespace for vCU.
${VM_IP}                                                               # IP of VM where tests are being run.
${VM_USER}                                                             # Username for VM where tests are being run.
${VM_PASSWORD}                                                         # Password for VM where tests are being run.
${MAINTAINER}                                                          # Name of maintainer.
${TEAM}                                                                # Team of maintainer.
${MAINTAINER_EMAIL}                                                    # Email of maintainer.
${OWNER_EMAIL}                                                         # Email of configuration owner.
${DESTINATION_DIR_PATH}    /home/ute/Downloads                         # Absolute path to directory in which file will be saved.

*** Test Cases ***
Create Init File
    [Timeout]  100h
    Create Init File
    ...  vdu_ssh_ip=${VDU_SSH_IP}
    ...  vdu_ssh_user=${VDU_SSH_USER}
    ...  vdu_ssh_password=${VDU_SSH_PASSWORD}
    ...  vdu_oam_ip=${VDU_OAM_IP}
    ...  vdu_oam_user=${VDU_OAM_USER}
    ...  vdu_oam_password=${VDU_OAM_PASSWORD}
    ...  vdu_namespace=${VDU_NAMESPACE}
    ...  vcu_ssh_ip=${VCU_SSH_IP}
    ...  vcu_ssh_user=${VCU_SSH_USER}
    ...  vcu_ssh_password=${VCU_SSH_PASSWORD}
    ...  vcu_oam_ip=${VCU_OAM_IP}
    ...  vcu_oam_user=${VCU_OAM_USER}
    ...  vcu_oam_password=${VCU_OAM_PASSWORD}
    ...  vcu_namespace=${VCU_NAMESPACE}
    ...  vm_ip=${VM_IP}
    ...  vm_user=${VM_USER}
    ...  vm_password=${VM_PASSWORD}
    ...  maintainer=${MAINTAINER}
    ...  team=${TEAM}
    ...  maintainer_email=${MAINTAINER_EMAIL}
    ...  owner_email=${OWNER_EMAIL}
    ...  destination_dir_path=${DESTINATION_DIR_PATH}



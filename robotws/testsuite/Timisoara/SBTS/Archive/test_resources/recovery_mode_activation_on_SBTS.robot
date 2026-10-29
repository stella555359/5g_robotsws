*** Settings ***
Library  SSHLibrary
Library  Process
Library  Collections
Library  OperatingSystem

*** Variables ***
#@{IP_LIST_SBTS}=  192.168.255.129
#@{IP_LIST_VM}=  10.5.29.241  10.5.60.78
${IP_VM}=  10.5.29.41
${IP_SBTS}=  192.168.255.129
${SBTS_USER}=  toor4nsn
${SBTS_PASS}=  oZPS0POrRieRtu
${VM_USER}=  ute
${VM_PASS}=  ute
${DC_SC_config}=  DC
${recovery_mode_Airscale_activated}=  no
${FSMF_Airscale}=  Airscale

#*** Test Cases ***
#Commands
#    Recovery_mode

*** Keywords ***
TC__recovery_mode_activation_on_SBTS
    Open Connection  ${IP_SBTS}
    Login  ${SBTS_USER}  ${SBTS_PASS}
    Recovery_mode_Check_Airscale
    Run Keyword If  '${recovery_mode_Airscale_activated}' == 'yes'   Recovery_mode_Airscale_Activated
    Run Keyword If  '${recovery_mode_Airscale_activated}' == 'no'   Recovery_mode_Airscale_Deactivated
    Recovery_mode_Check_Airscale
    close connection

Recovery_mode_Check_Airscale
    ${output1}=  Execute Command  uboot_env get netboot
    ${output2}=  Execute Command  uboot_env get netboot_interface
    ${output3}=  Execute Command  uboot_env get macspeed
    ${output4}=  Execute Command  uboot_env get bootpretries
    ${output5}=  Execute Command  uboot_env get tftpretries
    ${output6}=  Execute Command  uboot_env get bootptimeout
    #Recovery_mode_LOG
    log  \n==== ${output1}  console=true
    log  ==== ${output2}  console=true
    log  ==== ${output3}  console=true
    log  ==== ${output4}  console=true
    log  ==== ${output5}  console=true
    log  ==== ${output6}  console=true
    log  *****************************************************  console= true
Recovery_mode_Airscale_Activated
    ${output1}=  Execute Command  uboot_env set netboot=netboot_first
    ${output2}=  Execute Command  uboot_env set netboot_interface=lmp
    ${output3}=  Execute Command  uboot_env set macspeed=1G
    ${output4}=  Execute Command  uboot_env set bootpretries=2
    ${output5}=  Execute Command  uboot_env set tftpretries=2
    ${output6}=  Execute Command  uboot_env set bootptimeout=3000
    #Recovery_mode_LOG
    log  ==== ${output1}  console=true
    log  ==== ${output2}  console=true
    log  ==== ${output3}  console=true
    log  ==== ${output4}  console=true
    log  ==== ${output5}  console=true
    log  ==== ${output6}  console=true
    log  *****************************************************  console= true
Recovery_mode_Airscale_Deactivated
    ${output1}=  Execute Command  uboot_env del netboot
    ${output2}=  Execute Command  uboot_env del netboot_interface
    ${output3}=  Execute Command  uboot_env del macspeed
    ${output4}=  Execute Command  uboot_env del bootpretries
    ${output5}=  Execute Command  uboot_env del tftpretries
    ${output6}=  Execute Command  uboot_env del bootptimeout
    ${output7}=  Execute Command  uboot_env del netboot_domain_id
    #Recovery_mode_LOG
    log  ==== ${output1}  console=true
    log  ==== ${output2}  console=true
    log  ==== ${output3}  console=true
    log  ==== ${output4}  console=true
    log  ==== ${output5}  console=true
    log  ==== ${output6}  console=true
	log  ==== ${output7}  console=true
    log  *****************************************************  console= true
Recovery_mode_LOG
    log  ==== ${output1}  console=true
    log  ==== ${output2}  console=true
    log  ==== ${output3}  console=true
    log  ==== ${output4}  console=true
    log  ==== ${output5}  console=true
    log  ==== ${output6}  console=true
    log  ==== ${output7}  console=true
    log  *****************************************************  console= true

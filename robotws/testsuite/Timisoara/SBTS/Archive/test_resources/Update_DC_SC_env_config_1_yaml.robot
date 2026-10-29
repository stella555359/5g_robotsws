*** Settings ***
Library  SSHLibrary
Library  Process
Library  Collections
Library  OperatingSystem

*** Variables ***
${IP_VM_1}=  10.5.29.241
${IP_VM_2}=  10.5.29.241
${VM_USER}=  ute
${VM_PASS}=  ute
${DC_SC_config}=  DC
${YAML_PATH}=  /home/ute/btsauto/hran_ta/config/Timisoara/SBTS_COMPA_10002/env_config_1.yaml

*** Test Cases ***
Update_DC_SC_env_config_1_yaml
    Open VM
    #Set SBTS test confgi DC or SC
*** Keywords ***
Open VM
    Open Connection  ${IP_VM}
    Login  ${VM_PASS}  ${VM_PASS}
    Execute Command  rm  /home/ute/btsauto/hran_ta/config/Timisoara/SBTS_COMPA_10002/env_config_1.yaml
    Run Keyword If  '${DC_SC_config}' == 'DC'   Set SBTS test confgi DC
    Run Keyword If  '${DC_SC_config}' == 'SC'   Set SBTS test confgi SC
    ${output}=  Execute Command  ls -l /home/ute/btsauto/hran_ta/config/Timisoara/SBTS_COMPA_10002/env_config*
    log  == ls -l ==\n ${output}  console=true

Set SBTS test confgi DC
    ${output}=  Execute Command  cp /home/ute/btsauto/hran_ta/config/Timisoara/SBTS_COMPA_10002/env_config_1_DC.yaml ${YAML_PATH}
    log  == DC config ==\n ${output}  console=true
Set SBTS test confgi SC
    ${output}=  Execute Command  cp /home/ute/btsauto/hran_ta/config/Timisoara/SBTS_COMPA_10002/env_config_1_SC.yaml ${YAML_PATH}
    log  == SC config ==\n ${output}  console=true



*** Settings ***
Documentation  RU operations keywords.
...  Author: slawomir.jastrzebski@nokia.com
...  Maintainer: slawomir.jastrzebski@nokia.com

Library    BuiltIn
Library    String
Library    taf.hw.fhgw.cli    WITH NAME    issh

Resource    ./vdu_oam_operations.robot

*** Keywords ***
Get Radio Modules Ip Address List
    [Arguments]  ${gnb_index}=0  ${vdu_index}=0  ${alias}=default
    Connect To vDU K8s Master Node With Tenant  gnb_index=${gnb_index}  vdu_index=${vdu_index}  alias=${alias}
    ${vdu_ns}=  Get vDU Namespace From Init File  gnb_index=${gnb_index}  vdu_index=${vdu_index}
    ${pod_name}=  Set Variable  po-${vdu_ns}-oamfh-0
    ${container_name}=  Set Variable  ctr-${vdu_ns}-oamfh
    ${cli_command}=  Set Variable
    ...  bash -c "{ echo \\"aasyscomgw -r\\";sleep 1;echo \\"quit\\"; } | nc 127.0.0.1 15067;" | grep UDPCP | awk '{print$7}'
    ${kubectl_command}=  Set Variable  kubectl exec -it -n ${vdu_ns} ${pod_name} -c ${container_name} -- ${cli_command}
    ${cmd_result}=  issh.Execute  command=${kubectl_command}
    ${rmod_ip_addr_list}=  Get Regexp Matches  string=${cmd_result}  pattern=\\d+.\\d+.\\d+.\\d+
    [Return]  ${rmod_ip_addr_list}
    [Teardown]  Run Keyword And Ignore Error  Disconnect Interactive Connection

Get Radio Module Serial Number
    [Arguments]  ${rmod_ip_addr}  ${gnb_index}=0  ${vdu_index}=0  ${alias}=default
    Connect To vDU K8s Master Node With Tenant  gnb_index=${gnb_index}  vdu_index=${vdu_index}  alias=${alias}
    ${vdu_ns}=  Get vDU Namespace From Init File  gnb_index=${gnb_index}  vdu_index=${vdu_index}
    ${pod_name}=  Set Variable  po-${vdu_ns}-oamfh-0
    ${container_name}=  Set Variable  ctr-${vdu_ns}-dhcp
    ${cli_command}=  Set Variable
    ...  cat /var/log/kea-leasesdb/kea-leases4.csv | grep ${rmod_ip_addr} | cut -d, -f3 | rev | cut -d: -f1-11 | rev
    ${kubectl_command}=  Set Variable  kubectl exec -it -n ${vdu_ns} ${pod_name} -c ${container_name} -- ${cli_command}
    ${cmd_result}=  issh.Execute  command=${kubectl_command}
    ${cmd_result}=  Get Regexp Matches  string=${cmd_result}  pattern=\\S+:\\S+
    ${cmd_result}=  Remove Duplicates  ${cmd_result}
    ${hex_rmod_serial_number}=  Remove String  ${cmd_result[0]}  :
    ${rmod_serial_number}=  Evaluate  bytes.fromhex('${hex_rmod_serial_number}')
    [Return]  ${rmod_serial_number}
    [Teardown]  Run Keyword And Ignore Error  Disconnect Interactive Connection

Check Radio Module Connection
    [Arguments]  ${ip_addr}  ${rmod_login_name}=root  ${rmod_prompt}=${RU_PROMPT_ROOT}
    Connect Interactively To vDU Container  pod_abbr=oamfh  ctr_abbr=oamfh
    ${command}=  Set Variable
    ...  ssh -q -oHostKeyAlgorithms=+ssh-rsa -o StrictHostKeyChecking=no -oPubkeyAcceptedKeyTypes=+ssh-rsa ${rmod_login_name}@${ip_addr}
    issh.set prompt  prompt_str=password:|${rmod_prompt}
    ${cmd_result}=  issh.Execute  command=${command}  check_result=${False}
    ${cmd_result}=  Get Regexp Matches  string=${cmd_result}  pattern=password
    [Return]  ${cmd_result}
    [Teardown]  Run Keyword And Ignore Error  Disconnect Interactive Connection

Connect Interactively To vDU Container
    [Arguments]  ${pod_abbr}  ${ctr_abbr}  ${gnb_index}=0  ${vdu_index}=0  ${pod_index}=0  ${alias}=default
    ${login_container_flag}   Set Variable   0
    Connect To vDU K8s Master Node With Tenant  gnb_index=${gnb_index}  vdu_index=${vdu_index}  alias=${alias}
    ${vdu_ns}=  Get vDU Namespace From Init File  gnb_index=${gnb_index}  vdu_index=${vdu_index}
    ${pod_name}=  Set Variable  po-${vdu_ns}-${pod_abbr}-${pod_index}
    ${container_name}=  Set Variable  ctr-${vdu_ns}-${ctr_abbr}
    ${kubectl_command}=  Set Variable  kubectl exec -it -n ${vdu_ns} ${pod_name} -c ${container_name} -- bash
    ${cmd_result}=  issh.Execute  command=${kubectl_command}  check_result=${False}
    ${prompt}=  Set Variable  ${VDU_CONTAINER_PROMPT}
    Should Match Regexp  string=${cmd_result}  pattern=${prompt}
    Sleep  1
    ${login_container_flag}   Set Variable   1
    [Teardown]  Run Keyword And Ignore Error  Run Keyword If  "${login_container_flag}"=="0"
    ...  Disconnect Interactive Connection

Connect To Radio Module
    [Arguments]  ${ip_addr}  ${rmod_login_name}=root  ${rmod_password}=${EMPTY}  ${rmod_prompt}=${RU_PROMPT_ROOT}
    ...  ${gnb_index}=0  ${vdu_index}=0  ${pod_index}=0  ${alias}=default
    Connect Interactively To vDU Container  pod_abbr=oamfh  ctr_abbr=oamfh
    ...  gnb_index=${gnb_index}  vdu_index=${vdu_index}  pod_index=${pod_index}  alias=${alias}
    ${command}=  Set Variable
    ...  ssh -q -oHostKeyAlgorithms=+ssh-rsa -o StrictHostKeyChecking=no -oPubkeyAcceptedKeyTypes=+ssh-rsa ${rmod_login_name}@${ip_addr}
    ${old_prompt}=  issh.get prompt
    issh.set prompt  prompt_str=password:|${rmod_prompt}
    ${cmd_result}=  issh.Execute  command=${command}  check_result=${False}
    issh.set prompt   prompt_str=${old_prompt}|\\$|${rmod_prompt}
    issh.Execute  command=${rmod_password}  check_result=${False}
    sleep   3

Get Radio Module Power
    [Arguments]   ${rmod_ip_addr}  ${rmod_login_name}=root  ${rmod_password}=${EMPTY}  ${rmod_prompt}=${RU_PROMPT_ROOT}
    ...  ${gnb_index}=0  ${vdu_index}=0  ${pod_index}=0  ${alias}=default  ${log_prefix}=${EMPTY}  ${log_to_console}=True
    ${rmod_command}=  Set Variable  cat /mnt/factory/configs/unit/core_assembly_serial_number.txt
    ${frmon_command_1}=  Set Variable  / action create PsuMeasurements /CI/PsuMeasurements /module
    ${frmon_command_2}=  Set Variable  /CI/PsuMeasurements action measure
    ${frmon_command_3}=  Set Variable  /CI/PsuMeasurements action terminate
    Connect To Radio Module  ip_addr=${rmod_ip_addr}  rmod_login_name=${rmod_login_name}  rmod_password=${rmod_password}
    ...  rmod_prompt=${rmod_prompt}  gnb_index=${gnb_index}  vdu_index=${vdu_index}  pod_index=${pod_index}  alias=${alias}
    ${cmd_result}=  issh.Execute  command=${rmod_command}  check_result=${False}
    ${rmod_serial_number}=  Split To Lines  string=${cmd_result}  start=1  end=-1
    issh.set_prompt  prompt_str=\\$
    issh.Execute  command=frmonShellClient localhost 2000  check_result=${False}
    sleep  1
    ${cmd_result}=  issh.Execute  command=${frmon_command_1}  check_result=${False}
    ${power}=  Set Variable  ${0}
    ${actual_power_list}=  Create List
    FOR  ${i}  IN RANGE  ${3}
      Sleep  3
      ${actual_power}=  Wait Until Keyword Succeeds  60  20
      ...  Check Radio Module Power  command=${frmon_command_2}
      Append to List  ${actual_power_list}  ${actual_power}
      ${power}=  Evaluate  expression=${power}+${actual_power}
    END
    Log  ${log_prefix}Radio module (sn: ${rmod_serial_number[0]}) power - three measurements: ${actual_power_list}
    ...  console=${log_to_console}
    ${rmod_power}=  Evaluate  expression=${power}/${3}
    ${rmod_power}=  Evaluate  expression=int(${rmod_power})
    [Return]  ${rmod_serial_number[0]}  ${rmod_power}
    [Teardown]  Run Keywords  issh.Execute  command=${frmon_command_3}  check_result=${False}
      ...   AND  issh.Disconnect

Check Radio Module Power
    [Arguments]    ${command}
    ${cmd_result}  issh.Execute   command=${command}  check_result=${False}
    ${rmod_power}=  Get Regexp Matches  ${cmd_result}  POWER\\s+(\\d+)  1
    Run Keyword If  ${rmod_power}==@{EMPTY}  Run Keyword And Continue On Failure
    ...  Fail  msg=Power was not read from the radio module !
    Run Keyword If   '''failed''' in '''${rmod_power}'''
    ...  Fail  msg=Check power on ru fail !
    [Return]  ${rmod_power[0]}

Get All Radio Module Power
    [Arguments]  ${rmod_ip_addr_list}  ${rmod_serial_number_list}=@{EMPTY}  ${log_prefix}=${EMPTY}
    ${rmod_power_dict}=  Create Dictionary
    FOR  ${rmod_ip_addr}  IN  @{rmod_ip_addr_list}
      ${rmod_serial_number}=  Get Radio Module Serial Number  rmod_ip_addr=${rmod_ip_addr}
      Continue For Loop If  '${rmod_serial_number}' in ${rmod_serial_number_list}
      ${rmod_product_name}=  vDU RMOD Get Parameter Value Based On Serial Number  rmod_sn=${rmod_serial_number}  rmod_param=product_name
      ${rmod_dict_keys}=  Get Dictionary Keys  dictionary=${RU_PASSWORDS}
      ${rmod_creds_list}=  Run Keyword If  '${rmod_product_name}' in ${rmod_dict_keys}
      ...  Get From Dictionary  dictionary=${RU_PASSWORDS}  key=${rmod_product_name}
      ${rmod_login_name}=  Set Variable If  '${rmod_product_name}' in ${rmod_dict_keys}  ${rmod_creds_list[0]}  root
      ${rmod_password}=  Set Variable If  '${rmod_product_name}' in ${rmod_dict_keys}  ${rmod_creds_list[1]}  ${EMPTY}
      ${rmod_serial_number}  ${rmod_power}=  Get Radio Module Power  rmod_ip_addr=${rmod_ip_addr}
      ...  rmod_login_name=${rmod_login_name}  rmod_password=${rmod_password}  log_prefix=${log_prefix}
      Set To Dictionary  ${rmod_power_dict}  ${rmod_serial_number}=${rmod_power}
    END
    [Return]  ${rmod_power_dict}

#NOT USED KWs
Get Radio Unit Power
    [Arguments]  ${vdu_ns}  ${rmod_ip_addr}  ${user_name}=root
    Connect To vDU K8s Master Node With Tenant
    ${pod_name}=  Set Variable  po-${vdu_ns}-oamfh-0
    ${container_name}=  Set Variable  ctr-${vdu_ns}-oamfh
    ${frmon_command}=  Set Variable
    ...  echo -e "/ action create PsuMeasurements /CI/PsuMeasurements /module\n/CI/PsuMeasurements action measure" | frmonShellClient localhost 2000
    ${ssh_command}=  Set Variable
    ...  ssh -q -oHostKeyAlgorithms=+ssh-rsa -o StrictHostKeyChecking=no -oPubkeyAcceptedKeyTypes=+ssh-rsa ${user_name}@${rmod_ip_addr}
    ${cli_command}=  Set Variable  ${ssh_command} '${frmon_command}'
    ${kubectl_command}=  Set Variable  kubectl exec -it -n ${vdu_ns} ${pod_name} -c ${container_name} -- ${cli_command}
    ${cmd_result}=  issh.Execute  command=${kubectl_command}
    Log  \ncmd result: \n${cmd_result}\n  console=true
    ${rmod_power}=  Get Regexp Matches  ${cmd_result}  POWER\\s+(\\d+)  1
    Run Keyword If  ${rmod_power}==@{EMPTY}  Run Keyword And Continue On Failure
      ...  Fail  msg=Power was not read from the radio module (IP: ${rmod_ip_addr}) !
    [Return]  ${rmod_power[0]}
    [Teardown]  Run Keyword And Ignore Error  Disconnect Interactive Connection

Get Radio Unit Serial Number
    [Arguments]  ${rmod_ip_addr}  ${rmod_user_name}=root  ${gnb_index}=0  ${vdu_index}=0  ${alias}=default
    Connect To vDU K8s Master Node With Tenant  gnb_index=${gnb_index}  vdu_index=${vdu_index}  alias=${alias}
    ${vdu_ns}=  Get vDU Namespace From Init File  gnb_index=${gnb_index}  vdu_index=${vdu_index}
    ${pod_name}=  Set Variable  po-${vdu_ns}-oamfh-0
    ${container_name}=  Set Variable  ctr-${vdu_ns}-oamfh
    ${rmod_command}=  Set Variable  cat /mnt/factory/configs/unit/core_assembly_serial_number.txt
    ${ssh_command}=  Set Variable
    ...  ssh -q -oHostKeyAlgorithms=+ssh-rsa -o StrictHostKeyChecking=no -oPubkeyAcceptedKeyTypes=+ssh-rsa ${rmod_user_name}@${rmod_ip_addr}
    ${cli_command}=  Set Variable  ${ssh_command} '${rmod_command}'
    ${kubectl_command}=  Set Variable  kubectl exec -it -n ${vdu_ns} ${pod_name} -c ${container_name} -- ${cli_command}
    ${cmd_result}=  issh.Execute  command=${kubectl_command}
    ${rmod_serial_number}=  Split To Lines  string=${cmd_result}  start=1  end=-1
    [Return]  ${rmod_serial_number[0]}
    [Teardown]  Run Keyword And Ignore Error  Disconnect Interactive Connection

#Get Radio Module Serial Number
#    [Arguments]   ${rmod_ip_addr}
#    ${rmod_command}=  Set Variable  cat /mnt/factory/configs/unit/core_assembly_serial_number.txt
#    Connect To Radio Module  ip_addr=${rmod_ip_addr}
#    issh.set_prompt  prompt_str=\\$
#    ${rmod_serial_number}=  issh.Execute  command=${rmod_command}  check_result=${False}
#    sleep  1
#    [Return]  ${rmod_serial_number}
#    [Teardown]  issh.Disconnect

#Test Connect To Radio Module
#    [Arguments]  ${ip_addr}  ${rmod_login_name}=root  ${rmod_password}=${EMPTY}  ${rmod_prompt}=${RU_PROMPT_ROOT}
#    ...  ${gnb_index}=0  ${vdu_index}=0
#    Connect Interactively To vDU Container  pod_abbr=oamfh  ctr_abbr=oamfh
#    ${command}=  Set Variable
#    ...  ssh -q -oHostKeyAlgorithms=+ssh-rsa -o StrictHostKeyChecking=no -oPubkeyAcceptedKeyTypes=+ssh-rsa ${rmod_login_name}@${ip_addr}
#    ${old_prompt}=  issh.get prompt
#    issh.set prompt  prompt_str=password:|${rmod_prompt}
#    ${cmd_result}=  issh.Execute  command=${command}  check_result=${False}
#    issh.set prompt   prompt_str=${old_prompt}|\\$|${rmod_prompt}
#    ${cmd_result}=  issh.Execute  command=${rmod_password}  check_result=${False}
#    sleep   3
#    ${cmd_result}=  issh.Execute  command=pwd
#    [Return]  ${cmd_result}
#    [Teardown]  Disconnect Interactive Connection

#Connect To Radio Module
#    [Arguments]  ${ip_addr}  ${rmod_login_name}=root  ${rmod_password}=${EMPTY}  ${rmod_prompt}=${RU_PROMPT_ROOT}
#    ...  ${gnb_index}=0  ${vdu_index}=0
#    Connect Interactively To vDU Container  pod_abbr=oamfh  ctr_abbr=oamfh
#    ${command}=  Set Variable
#    ...  ssh -q -oHostKeyAlgorithms=+ssh-rsa -o StrictHostKeyChecking=no -oPubkeyAcceptedKeyTypes=+ssh-rsa ${rmod_login_name}@${ip_addr}
#    issh.set prompt  prompt_str=${RU_PROMPT_ROOT}
#    ${old_prompt}=  issh.get prompt
##    issh.set prompt  prompt_str=password:
#    ${cmd_result}=  issh.Execute  command=${command}  check_result=${False}
##    issh.set prompt   prompt_str=${old_prompt}|\\$|${rmod_prompt}
##    issh.Execute  command=${rmod_password}  check_result=${False}
#    sleep   3

#Check Radio Modules
#    [Arguments]  ${gnb_index}=0  ${vdu_index}=0  ${alias}=default
#    [Documentation]
#    ...  Description:
#    ...  Keyword checks if IP address is pingable.
#    ...  Arguments:
#    ...  +========================+======+============================================================================+
#    ...  | Argument               | Man. | Description                                                                |
#    ...  +========================+======+============================================================================+
#    ...  | vdu_ns                 | Yes  | vDU namespace.                                                             |
#    ...  +------------------------+------+----------------------------------------------------------------------------+
#    ...  | ip_addr                | Yes  | IP address of radio module unit.                                           |
#    ...  +------------------------+------+----------------------------------------------------------------------------+
#    ...  | user_name              | Yes  | Username to log in to the radio module unit.                               |
#    ...  +------------------------+------+----------------------------------------------------------------------------+
#    ...
#    ...  Author: slawomir.jastrzebski@nokia.com
#    ...  Maintainer: slawomir.jastrzebski@nokia.com
#
#    Connect To vDU K8s Master Node With Tenant  gnb_index=${gnb_index}  vdu_index=${vdu_index}  alias=default
#    ${vdu_ns}=  Get vDU Namespace From Init File  gnb_index=${gnb_index}  vdu_index=${vdu_index}
#    ${pod_name}=  Set Variable  po-${vdu_ns}-oamfh-0
#    ${container_name}=  Set Variable  ctr-${vdu_ns}-oamfh
#    ${ssh_command}=  Set Variable
##    ...  ssh -q -oHostKeyAlgorithms=+ssh-rsa -o StrictHostKeyChecking=no -oPubkeyAcceptedKeyTypes=+ssh-rsa root@192.168.254.34 ls
##    ${kubectl_command}=  Set Variable  kubectl exec -it -n ${vdu_ns} ${pod_name} -c ${container_name} -- ${ssh_command}
#    ...  ssh -q -oHostKeyAlgorithms=+ssh-rsa -o StrictHostKeyChecking=no -oPubkeyAcceptedKeyTypes=+ssh-rsa core@10.42.126.14 ls
#    ${kubectl_command}=  Set Variable  ${ssh_command}
#    ${cmd_result}=  issh.Execute  command=${kubectl_command}
##    ${cmd_result}=  Split To Lines  string=${cmd_result}  start=1  end=-1
#    [Return]  ${cmd_result}
#    [Teardown]  Run Keyword And Ignore Error  Disconnect Interactive Connection


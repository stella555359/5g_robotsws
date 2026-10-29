*** Settings ***
Documentation    Author: tomasz.blaszczyszyn@nokia.com; kacper.halas@nokia.com; filip.radwanski@nokia.com; michal.laski@nokia.com
...              Maintainer: tomasz.blaszczyszyn@nokia.com; kacper.halas@nokia.com; filip.radwanski@nokia.com; michal.laski@nokia.com
...              Description: These keywords handles actions performed with system under test using system commands
...              FT in charge: name + mailing list
...              Confluence link:
...              References: (documentation link(e.g. doors or sphinx))
...              QualityCenter: (test set url to QC)
...              Sample execution:

Library          OperatingSystem
Library          SSHLibrary
Library          XML  lxml=True
Library          ute_fsmaccess
Library          Telnet

*** Variables ***
${SYSTEM_ENB_PORT_12345}=      12345
${SYSTEM_ENB_PORT_443}=        443
${SYSTEM_ENB_LOCAL_IP}=        192.168.255.1
${SYSTEM_ENB_TRANSPORT_IP}=    192.168.255.129
${SYSTEM_IPHY_LOCAL_IP}=       192.168.200.1
${SYSTEM_ENB_SSH_USERNAME}=    toor4nsn
${SYSTEM_ENB_SSH_PASSWORD}=    oZPS0POrRieRtu
${SYSTEM_ENB_SSH_ALIAS}=       system_enb_ssh
${SYSTEM_ENB_SSH_PROMPT}=      :~ >


*** Keywords ***
#TO DO: DO WYRZUCENIA, ZASTAPIONE SYSTEM Check If Host Is Pingable i SYSTEM Check If Host Is Not Pingable
SYSTEM Check If Host Is Reachable With Ping
    [Arguments]    ${host_ip_address}
    ${rc}    Run And Return Rc     ping -c 1 ${host_ip_address}
    Should Be Equal As Integers     ${rc}    0

#END TO DO:
SYSTEM Wait For Device Reboot And Then For Startup
    [Arguments]    ${reboot_timeout}
    ...            ${start_timeout}
    ...            ${ip_address}=${SYSTEM_ENB_LOCAL_IP}
    ...            ${port}=${SYSTEM_ENB_PORT_443}
    Log    \nWait for Device reboot ...    console=yes
    SYSTEM Check If Device Stops Responding To Nmap  timeout=${reboot_timeout}
    ...                                              ip_address=${ip_address}
    ...                                              port=${port}
    Log    Device stops responding to Nmap    console=yes
    SYSTEM Check If Device Is Responding To Nmap  timeout=${start_timeout}
    ...                                           ip_address=${ip_address}
    ...                                           port=${port}
    Log    Device starts responding to Nmap    console=yes

SYSTEM Check If Device Is Responding To Nmap
    [Arguments]    ${timeout}
    ...            ${ip_address}=${SYSTEM_ENB_LOCAL_IP}
    ...            ${port}=${SYSTEM_ENB_PORT_443}
    :FOR    ${time_index}    IN RANGE   ${timeout}
    \    sleep  1
    \    ${result}=    Run Keyword And Return Status    SYSTEM Nmap port on IP address and expect success  ip_address=${ip_address}  port=${port}
    \    Exit For Loop If    ${result}
    Run Keyword Unless    ${result}    Fail    Device with IP ${ip_address} not respond to nmap in ${timeout} seconds

SYSTEM Check If Device Stops Responding To Nmap
    [Arguments]    ${timeout}
    ...            ${ip_address}=${SYSTEM_ENB_LOCAL_IP}
    ...            ${port}=${SYSTEM_ENB_PORT_443}
    :FOR    ${time_index}    IN RANGE   ${timeout}
    \    sleep  1
    \    ${result}=    Run Keyword And Return Status    SYSTEM Nmap port on IP address and expect fail  ip_address=${ip_address}  port=${port}
    \    Exit For Loop If    ${result}
    Run Keyword Unless    ${result}    Fail    Device with IP ${ip_address} still responded to nmap and it should not after ${timeout} seconds

SYSTEM Nmap Port On IP Address And Expect Fail
    [Arguments]    ${ip_address}=${SYSTEM_ENB_LOCAL_IP}
    ...            ${port}=${SYSTEM_ENB_PORT_443}
    ${output}=     Run       nmap -p ${port} ${ip_address}
    ${status_1}=   Run Keyword And Return Status    Should contain      ${output}   ${port}/tcp closed
    ${status_2}=   Run Keyword And Return Status    Should contain      ${output}   Host seems down
    Should Be True    ${status_1} or ${status_2}

SYSTEM Nmap Port On IP Address And Expect success
    [Arguments]    ${ip_address}=${SYSTEM_ENB_LOCAL_IP}
    ...            ${port}=${SYSTEM_ENB_PORT_443}
    ${output}=        Run    nmap -p ${port} ${ip_address}
    Should contain    ${output}    ${port}/tcp open

SYSTEM Wait For Host Is Reachable With Ping
    [Arguments]    ${host_ip_address}
    ...            ${timeout}=300
    ...            ${checking_interval}=10s
    Wait Until Keyword Succeeds    ${timeout}    ${checking_interval}    SYSTEM Check If Host Is Reachable With Ping
    ...                                                                             host_ip_address=${host_ip_address}


SYSTEM Check If Host Is Reachable Over Ssh
    [Arguments]    ${host_ip_address}
    ...            ${host_ssh_username}
    ...            ${host_ssh_password}
    ${rc}=    Run And Return Rc    sshpass -p ${host_ssh_password} ssh ${host_ssh_username}@${host_ip_address} 'uname -a'
	Should Be Equal As Integers     ${rc}    0

SYSTEM Wait For Host Is Reachable With Ssh
    [Arguments]    ${host_ip_address}
    ...            ${host_ssh_username}
    ...            ${host_ssh_password}
    ...            ${timeout}=300
    ...            ${checking_interval}=10s
    Wait Until Keyword Succeeds    ${timeout}    ${checking_interval}    SYSTEM Check If Host Is Reachable Over Ssh
    ...                                                                              host_ip_address=${host_ip_address}
    ...                                                                              host_ssh_username=${host_ssh_username}
    ...                                                                              host_ssh_password=${host_ssh_password}

SYSTEM Wait For Host Is Reachable With Ping And Ssh
    [Arguments]    ${host_ip_address}
    ...            ${host_ssh_username}
    ...            ${host_ssh_password}
    ...            ${timeout}=300
    ...            ${checking_interval}=10s
    SYSTEM Wait For Host Is Reachable With Ping    host_ip_address=${host_ip_address}
    ...                                            timeout=${timeout}
    ...                                            checking_interval=${checking_interval}
    SYSTEM Wait For Host Is Reachable With Ssh    host_ip_address=${host_ip_address}
    ...                                           host_ssh_username=${host_ssh_username}
    ...                                           host_ssh_password=${host_ssh_password}
    ...                                           timeout=${timeout}
    ...                                           checking_interval=${checking_interval}

SYSTEM Wait For eNB Is Reachable With Ping And Ssh
    [Arguments]    ${host_ip_address}=${SYSTEM_ENB_LOCAL_IP}
    ...            ${host_ssh_username}=${SYSTEM_ENB_SSH_USERNAME}
    ...            ${host_ssh_password}=${SYSTEM_ENB_SSH_PASSWORD}

    SYSTEM Wait For Host Is Reachable With Ping And Ssh    host_ip_address=${host_ip_address}
    ...                                                    host_ssh_username=${host_ssh_username}
    ...                                                    host_ssh_password=${host_ssh_password}

SYSTEM Check If Host Is Pingable
    [Arguments]    ${host_ip_address}
	${out_ping_result}=    Run    ping -c 1 -W 10 ${host_ip_address}
    Should Contain    ${out_ping_result}    1 packets transmitted, 1 received    timeout=5
    [Return]    ${out_ping_result}

SYSTEM Check If Host Is Not Pingable
    [Arguments]    ${host_ip_address}
	${out_ping_result}=    Run    ping -c 1 -W 10 ${host_ip_address}
    Should Contain    ${out_ping_result}    1 packets transmitted, 0 received    timeout=5
    [Return]    ${out_ping_result}

SYSTEM Check If Enb Is Pingable
	SYSTEM Check If Host Is Pingable    host_ip_address=${SYSTEM_ENB_LOCAL_IP}

SYSTEM Check If Iphy Is Pingable
	SYSTEM Check If Host Is Pingable    host_ip_address=${SYSTEM_IPHY_LOCAL_IP}

SYSTEM Check If Transport Is Pingable
	SYSTEM Check If Host Is Pingable    host_ip_address=${SYSTEM_ENB_TRANSPORT_IP}

SYSTEM Check If Enb Is Not Pingable
    SYSTEM Check If Host Is Not Pingable    host_ip_address=${SYSTEM_ENB_LOCAL_IP}

SYSTEM Check If Iphy Is Not Pingable
    SYSTEM Check If Host Is Not Pingable    host_ip_address=${SYSTEM_IPHY_LOCAL_IP}

SYSTEM Check If Transport Is Not Pingable
    SYSTEM Check If Host Is Not Pingable    host_ip_address=${SYSTEM_ENB_TRANSPORT_IP}

SYSTEM Check If Enb And Iphy Are Pingable
    SYSTEM Check If Enb Is Pingable
    SYSTEM Check If Iphy Is Pingable

SYSTEM Check If Enb And Iphy Are Not Pingable
    SYSTEM Check If Enb Is Not Pingable
    SYSTEM Check If Iphy Is Not Pingable

SYSTEM Wait Till Enb Will Be Pingable For A Given Period
    [Arguments]    ${waiting_time}=305
    ...            ${waiting_interval}=5s
    Wait Until Keyword Succeeds    ${waiting_time}    ${waiting_interval}    SYSTEM Check If Enb Is Pingable

SYSTEM Wait Till Iphy Will Be Pingable For A Given Period
    [Arguments]    ${waiting_time}=305
    ...            ${waiting_interval}=5s
    Wait Until Keyword Succeeds    ${waiting_time}    ${waiting_interval}    SYSTEM Check If Iphy Is Pingable

SYSTEM Wait Till Transport Will Be Pingable For A Given Period
    [Arguments]    ${waiting_time}=305
    ...            ${waiting_interval}=5s
    Wait Until Keyword Succeeds    ${waiting_time}    ${waiting_interval}    SYSTEM Check If Transport Is Pingable

SYSTEM Wait Till Enb Will Not Be Pingable For A Given Period
    [Arguments]    ${waiting_time}=305
    ...            ${waiting_interval}=5s
    Wait Until Keyword Succeeds    ${waiting_time}    ${waiting_interval}    SYSTEM Check If Enb Is Not Pingable

SYSTEM Wait Till Iphy Will Not Be Pingable For A Given Period
    [Arguments]    ${waiting_time}=305
    ...            ${waiting_interval}=5s
    Wait Until Keyword Succeeds    ${waiting_time}    ${waiting_interval}    SYSTEM Check If Iphy Is Not Pingable

SYSTEM Wait Till Transport Will Not Be Pingable For A Given Period
    [Arguments]    ${waiting_time}=305
    ...            ${waiting_interval}=5s
    Wait Until Keyword Succeeds    ${waiting_time}    ${waiting_interval}    SYSTEM Check If Transport Is Not Pingable

SYSTEM Wait Till Enb And Iphy Are Pingable
    [Arguments]    ${waiting_time}=305
    ...            ${waiting_interval}=5s
    SYSTEM Wait Till Enb Will Be Pingable For A Given Period    waiting_time=${waiting_time}
    ...                                                         waiting_interval=${waiting_interval}
    SYSTEM Wait Till Iphy Will Be Pingable For A Given Period    waiting_time=${waiting_time}
    ...                                                          waiting_interval=${waiting_interval}

SYSTEM Wait Till Enb And Transport Are Pingable
    [Arguments]    ${waiting_time}=305
    ...            ${waiting_interval}=5s
    SYSTEM Wait Till Enb Will Be Pingable For A Given Period    waiting_time=${waiting_time}
    ...                                                         waiting_interval=${waiting_interval}
    SYSTEM Wait Till Transport Will Be Pingable For A Given Period    waiting_time=${waiting_time}
    ...                                                               waiting_interval=${waiting_interval}

SYSTEM Wait Till Enb And Iphy And Transport Are Pingable
    [Arguments]    ${waiting_time}=305
    ...            ${waiting_interval}=5s
    SYSTEM Wait Till Enb Will Be Pingable For A Given Period    waiting_time=${waiting_time}
    ...                                                         waiting_interval=${waiting_interval}
    SYSTEM Wait Till Iphy Will Be Pingable For A Given Period    waiting_time=${waiting_time}
    ...                                                          waiting_interval=${waiting_interval}
    SYSTEM Wait Till Transport Will Be Pingable For A Given Period    waiting_time=${waiting_time}
    ...                                                               waiting_interval=${waiting_interval}

SYSTEM Wait Till Enb And Iphy Are Not Pingable
    [Arguments]    ${waiting_time}=305
    ...            ${waiting_interval}=5s
    SYSTEM Wait Till Enb Will Not Be Pingable For A Given Period    waiting_time=${waiting_time}
    ...                                                             waiting_interval=${waiting_interval}
    SYSTEM Wait Till Iphy Will Not Be Pingable For A Given Period    waiting_time=${waiting_time}
    ...                                                              waiting_interval=${waiting_interval}

SYSTEM Wait Till Enb And Transport Are Not Pingable
    [Arguments]    ${waiting_time}=305
    ...            ${waiting_interval}=5s
    SYSTEM Wait Till Enb Will Not Be Pingable For A Given Period    waiting_time=${waiting_time}
    ...                                                             waiting_interval=${waiting_interval}
    SYSTEM Wait Till Transport Will Not Be Pingable For A Given Period    waiting_time=${waiting_time}
    ...                                                                   waiting_interval=${waiting_interval}

SYSTEM Wait Till Enb And Iphy And Transport Are Not Pingable
    [Arguments]    ${waiting_time}=305
    ...            ${waiting_interval}=5s
    SYSTEM Wait Till Enb Will Not Be Pingable For A Given Period    waiting_time=${waiting_time}
    ...                                                             waiting_interval=${waiting_interval}
    SYSTEM Wait Till Iphy Will Not Be Pingable For A Given Period    waiting_time=${waiting_time}
    ...                                                              waiting_interval=${waiting_interval}
    SYSTEM Wait Till Transport Will Not Be Pingable For A Given Period    waiting_time=${waiting_time}
    ...                                                                   waiting_interval=${waiting_interval}

SYSTEM Open SSH Connection
    [Arguments]    ${host}    ${port}    ${username}    ${password}    ${alias}
    SSHLibrary.Open Connection    host=${host}    port=${port}    timeout=60    alias=${alias}
    SSHLibrary.Login    username=${username}    password=${password}    delay=1s

SYSTEM Close SSH Connection
    [Arguments]    ${alias}
    SSHLibrary.Switch Connection    index_or_alias=${alias}
    SSHLibrary.Close Connection

SYSTEM Open SSH Connection To Enb
    SYSTEM Open SSH Connection    host=${SYSTEM_ENB_TRANSPORT_IP}
    ...                           port=22
    ...                           username=${SYSTEM_ENB_SSH_USERNAME}
    ...                           password=${SYSTEM_ENB_SSH_PASSWORD}
    ...                           alias=ssh_enb
    SSHLibrary.Switch Connection    index_or_alias=ssh_enb
    SSHLibrary.Write   echo "connection established"

SYSTEM Open SSH Connection To Iphy
    Setup Wts Fsm Access
    SYSTEM Open SSH Connection    host=${SYSTEM_IPHY_LOCAL_IP}
    ...                           port=22
    ...                           username=${SYSTEM_ENB_SSH_USERNAME}
    ...                           password=${SYSTEM_ENB_SSH_PASSWORD}
    ...                           alias=ssh_iphy

SYSTEM Close SSH Connection To Enb
    SSHLibrary.Switch Connection    index_or_alias=ssh_enb
    SSHLibrary.Close Connection

SYSTEM Close SSH Connection To Iphy
    SSHLibrary.Switch Connection    index_or_alias=ssh_iphy
    SSHLibrary.Close Connection
    Teardown Wts Fsm Access

SYSTEM Get File From Enb Over Ssh
    [Arguments]    ${source_file}    ${destination_file}
    SSHLibrary.Switch Connection    index_or_alias=ssh_enb
    SSHLibrary.Get File    source=${source_file}    destination=${destination_file}

SYSTEM Get File From Iphy Over Ssh
    [Arguments]    ${source_file}    ${destination_file}
    SSHLibrary.Switch Connection    index_or_alias=ssh_iphy
    SSHLibrary.Get File    source=${source_file}    destination=${destination_file}

SYSTEM Put File To Enb Over Ssh
    [Arguments]    ${source_file}    ${destination_file}=/user/${SYSTEM_ENB_SSH_USERNAME}/    ${mode}=0744
    SSHLibrary.Switch Connection    index_or_alias=ssh_enb
    SSHLibrary.Put File    source=${source_file}    destination=${destination_file}    mode=${mode}

SYSTEM Put File To Iphy Over Ssh
    [Arguments]    ${source_file}    ${destination_file}=/user/${SYSTEM_ENB_SSH_USERNAME}/    ${mode}=0744
    SSHLibrary.Switch Connection    index_or_alias=ssh_iphy
    SSHLibrary.Put File       source=${source_file}    destination=${destination_file}    mode=${mode}

SYSTEM Put Iphy Configuration File On Iphy
    [Arguments]    ${source_file}
    SYSTEM Put File To Iphy Over Ssh   source_file=${source_file}
    ...                                destination_file=/ffs/run/simmode/uploaded_iphy.xml

SYSTEM Backup Iphy Configuration File
    [Arguments]    ${destination_file}
    SYSTEM Get File From Iphy Over Ssh    source_file=/ffs/run/simmode/uploaded_iphy.xml
    ...                                   destination_file=${destination_file}

SYSTEM Iphy Change Radios
    [Documentation]
    ...    Author: Piotr Sewerynek
    [Arguments]    ${source_file}
    SYSTEM Open SSH Connection To Enb
    SYSTEM Open SSH Connection To Iphy
    ${targetBD_file}=   set variable  /tmp/targetBD.xml
    SYSTEM TargetBD Download    destination_file=${targetBD_file}
    ${updated_iphy}    set variable   /tmp/uploaded_iphy.xml
    ${xml_tmp}=        Parse XML       source=${source_file}       keep_clark_notation=True
    ${radio_num}=      Evaluate Xpath  ${xml_tmp}    count(.//identity/buildname)
    :FOR   ${index}    IN RANGE    ${radio_num}
    \     ${xml}=          Parse XML       source=${source_file}       keep_clark_notation=True
    \     ${rf_type}       Get element text   ${xml}    .//RRH[${index+1}]/identity/productname
    \     ${xml}=          Parse XML       source=${targetBD_file}        keep_clark_notation=True
    \     ${rf_version}=  Get element attribute   source=${xml}   name=resourceSWVersion   xpath=.//hwResource[@resourceBuildKey="LTX_${rf_type}"]
    \     Set element text    source=${xml_tmp}    text=${rf_version}    xpath=.//RRH[${index+1}]/identity/buildname
    \     Set element text    source=${xml_tmp}    text=${rf_version}    xpath=.//RRH[${index+1}]/identity/buildversion
    Save xml            source=${xml_tmp}    path=${updated_iphy}
    SYSTEM Put Iphy Configuration File On Iphy  source_file=${updated_iphy}
    SYSTEM Remove HWF File From Enb
    SYSTEM Close SSH Connection To Iphy
    SYSTEM Close SSH Connection To Enb

SYSTEM Swconfig Backup
    SSHLibrary.Switch Connection    index_or_alias=ssh_enb
    SSHLibrary.Execute Command    cp /ffs/run/swconfig.txt    /ffs/run/swconfig_backup.txt

SYSTEM Swconfig Restore
    SSHLibrary.Switch Connection    index_or_alias=ssh_enb
    SSHLibrary.Execute Command    cp /ffs/run/swconfig_backup.txt    /ffs/run/swconfig.txt

SYSTEM Swconfig Download
    [Arguments]    ${destination_file}
    SYSTEM Get File From Enb Over Ssh    source_file=/ffs/run/swconfig.txt    destination_file=${destination_file}

SYSTEM Swconfig Upload
    [Arguments]    ${source_file}
    SYSTEM Put File To Enb Over Ssh    source_file=${source_file}   destination_file=/ffs/run/swconfig.txt

SYSTEM Swconfig Add Flag
    [Arguments]    ${flag}    ${value}
    SSHLibrary.Switch Connection    index_or_alias=ssh_enb
    SSHLibrary.Execute Command    echo -e "\n${flag}=${value}\n" >> /ffs/run/swconfig.txt

SYSTEM Swconfig Remove Flag
    [Arguments]    ${flag}
    SSHLibrary.Switch Connection    index_or_alias=ssh_enb
    SSHLibrary.Execute Command    sed -i '/${flag}/d' /ffs/run/swconfig.txt

SYSTEM Remove File From Enb
    [Arguments]    ${file_path}
    SSHLibrary.Switch Connection    index_or_alias=ssh_enb
    SSHLibrary.Execute Command    rm -rf ${file_path}

SYSTEM Remove HWF File From Enb
    SSHLibrary.Switch Connection    index_or_alias=ssh_enb
    SSHLibrary.Execute Command    rm -rf /ffs/run/config/hwf.bin.gz

SYSTEM Remove Vendor Files From Enb
    SSHLibrary.Switch Connection    index_or_alias=ssh_enb
    SSHLibrary.Execute Command    rm -rf /ffs/run/swpool/OAM/vendor*

SYSTEM Swconfig File Remove
    SYSTEM Remove File From Enb    file_path=/ffs/run/swconfig.txt

SYSTEM HashContainer Remove
    SYSTEM Remove File From Enb    file_path=/ffs/run/HashContainer*

SYSTEM HashContainer Backup
    SSHLibrary.Switch Connection    index_or_alias=ssh_enb
    SSHLibrary.Execute Command    mkdir -p /ffs/run/HashContainers_Backup/
    SSHLibrary.Execute Command    cp /ffs/run/HashContainer*    /ffs/run/HashContainers_Backup/

SYSTEM Vendor Files Backup
    SSHLibrary.Switch Connection    index_or_alias=ssh_enb
    SSHLibrary.Execute Command    mkdir -p /ffs/run/swpool/OAM/Backup_vendor/
    SSHLibrary.Execute Command    cp /ffs/run/swpool/OAM/vendor* /ffs/run/swpool/OAM/Backup_vendor

SYSTEM Hashcontainer Download
    [Arguments]    ${destination_file}
    SYSTEM Get File From Enb Over Ssh    source_file=/ffs/run/HashContainer*    destination_file=${destination_file}

SYSTEM TargetBD Remove
    SYSTEM Remove File From Enb    file_path=/ffs/run/TargetBD*.xml

SYSTEM TargetBD Backup
    SSHLibrary.Switch Connection    index_or_alias=ssh_enb
    SSHLibrary.Execute Command    cp /ffs/run/TargetBD*.xml    /ffs/run/targetbd_backup.txt

SYSTEM TargetBD Download
    [Arguments]    ${destination_file}
    SYSTEM Get File From Enb Over Ssh    source_file=/ffs/run/TargetBD*.xml    destination_file=${destination_file}

SYSTEM Swconfig Check If Flag With Value Exists In File
    [Arguments]    ${flag}    ${value}
    SSHLibrary.Switch Connection    index_or_alias=ssh_enb
    ${out}=    SSHLibrary.Execute Command    cat /ffs/run/swconfig.txt | egrep -i '${flag}=${value}' | wc -l
    Run Keyword If    '${out}'=='${1}'    Log    Flag ${flag} with value ${value} exists in swconfig.txt    ELSE
    ...                                   Log    Flag ${flag} with value ${value} exists in swconfig.txt
    [Return]    ${out}

SYSTEM Kill Local Process
    [Arguments]    ${process}
    OperatingSystem.Run    for i in `ps -ef | grep ${process} | awk '{print $2}'` ; do sudo kill -9 $i; done

SYSTEM Kill Remote Process
    [Arguments]    ${process}    ${alias}
    SSHLibrary.Switch Connection    index_or_alias=${alias}
    SSHLibrary.Execute Command    for i in `ps -ef | grep ${process} | awk '{print $2}'` ; do sudo kill -9 $i; done

SYSTEM Kill Process On SMOD
    [Arguments]    ${process}
    SYSTEM Kill Remote Process    process=${process}    index_or_alias=ssh_enb

SYSTEM Reboot Remote Cpu
    [Arguments]    ${alias}
    SSHLibrary.Switch Connection    index_or_alias=${alias}
    SSHLibrary.Execute Command    reboot

SYSTEM Reboot SMOD
    SYSTEM Reboot Remote Cpu    index_or_alias=ssh_enb

SYSTEM Check Enb Uptime
    SSHLibrary.Switch Connection    index_or_alias=ssh_enb
    ${out_uptime}=    SSHLibrary.Execute Command    uptime | awk '{print $3}'
    [Return]    ${out_uptime}

SYSTEM Get Software Version
    [Arguments]    ${partition}
    Setup Enb Fsm Access  alias=sw_version
    ${SOFTWARE_VERSION}=  get enb sw version  partition=${partition}  alias=sw_version
    Teardown Enb Fsm Access  alias=sw_version
    [Return]  ${SOFTWARE_VERSION}

SYSTEM Get Active Software Version
    ${ACTIVE_SOFTWARE}=  SYSTEM Get Software Version  partition=active
    [Return]  ${ACTIVE_SOFTWARE}

SYSTEM Get Passive Software Version
    ${PASSIVE_SOFTWARE}=  SYSTEM Get Software Version  partition=passive
    [Return]  ${PASSIVE_SOFTWARE}

SYSTEM Get Planned Software Version
    ${status}=  Run Keyword And Return Status  SYSTEM Get Software Version  partition=planned
    Run Keyword if  ${status}==False    Teardown Enb Fsm Access    alias=sw_version
    ${PLANNED_SOFTWARE}=  Run keyword if  ${status}==True    SYSTEM Get Software Version  partition=planned
    ...                                   ELSE               Set Variable  ${EMPTY}
    [Return]  ${PLANNED_SOFTWARE}

SYSTEM Ececute Command On BTS Via Ssh
    [Arguments]
    ...    ${command}
    ...    ${alias}=default
    ...    ${delay}=5s
    SYSTEM Open SSH Connection
    ...    host=${ADMIN_BTS_HOST}
    ...    port=22
    ...    username=${SYSTEM_ENB_SSH_USERNAME}
    ...    password=${SYSTEM_ENB_SSH_PASSWORD}
    ...    alias=${alias}
    SSHLibrary.Switch Connection
    ...    index_or_alias=${alias}
    SSHLibrary.Write
    ...    text=sshpass -p ${SYSTEM_ENB_SSH_PASSWORD} ssh ${SYSTEM_ENB_SSH_USERNAME}@${ADMIN_BTS_HOST}
    SSHLibrary.Read Until
    ...    expected=${PROMPT_ENB}
    SSHLibrary.Write
    ...    text=${command}
    ${return}    SSHLibrary.Read
    ...    delay=${delay}
    [Return]  ${return}

SYSTEM Execute Command On Enb
    [Arguments]    ${command}
    ...            ${return_rc}=true
    Setup Enb Fsm Access  alias=enb_comm
    ${return}=  Execute Command On Enb  ${command}  ${return_rc}  alias=enb_comm
    Teardown Enb Fsm Access  alias=enb_comm
    [Return]  ${return}

SYSTEM Execute Command On Wts
    [Arguments]    ${command}
    ...            ${return_rc}=true
    Setup Enb Fsm Access  alias=wts_comm
    ${return}=  Execute Command On Wts  ${command}  ${return_rc}  alias=wts_comm
    Teardown Enb Fsm Access  alias=wts_comm
    [Return]  ${return}

SYSTEM Open FSM SSH Tunnel
    [Arguments]    ${local_ip_address}=${SYSTEM_ENB_TRANSPORT_IP}
    ...            ${alias}=${SYSTEM_ENB_SSH_ALIAS}
    ...            ${enb_prompt}=${SYSTEM_ENB_SSH_PROMPT}
    SSHLibrary.Open Connection    ${local_ip_address}    alias=${alias}    prompt=${enb_prompt}
    SSHLibrary.Login              ${SYSTEM_ENB_SSH_USERNAME}    ${SYSTEM_ENB_SSH_PASSWORD}

SYSTEM Close FSM SSH Tunnel
    SYSTEM Close SSH Connection    alias=${SYSTEM_ENB_SSH_ALIAS}

SYSTEM Scp Via FSM SSH Tunnel
    [Arguments]    ${fsp_ip_address}
    ...            ${file}
    ...            ${file_dir}=/user/${SYSTEM_ENB_SSH_USERNAME}/
    ...            ${remote_dir}=/user/${SYSTEM_ENB_SSH_USERNAME}/
    ...            ${alias}=${SYSTEM_ENB_SSH_ALIAS}
    SSHLibrary.Switch Connection    ${alias}
    SSHLibrary.Write    scp -o StrictHostKeyChecking=no -r ${file_dir}/${file} ${SYSTEM_ENB_SSH_USERNAME}@${fsp_ip_address}:${remote_dir}
    SSHLibrary.Read Until    Password:
    SSHLibrary.Write    ${SYSTEM_ENB_SSH_PASSWORD}
    ${out_result}=    SSHLibrary.Read Until Prompt

SYSTEM Command Via FSM SSH Tunnel
    [Arguments]    ${fsp_ip_address}
    ...            ${remote_command}
    ...            ${alias}=${SYSTEM_ENB_SSH_ALIAS}
    SSHLibrary.Switch Connection    ${alias}
    SSHLibrary.Write    yes | ssh ${SYSTEM_ENB_SSH_USERNAME}@${fsp_ip_address} '${remote_command}'
    SSHLibrary.Read Until    Password:
    SSHLibrary.Write    ${SYSTEM_ENB_SSH_PASSWORD}
    ${out_result}=    SSHLibrary.Read Until Prompt

SYSTEM Telnet Open Connection
    [Arguments]    ${host_ip}=192.168.255.1
    ...            ${host_port}=23
    Telnet.Open Connection    host=${host_ip}
    ...                       port=${host_port}

SYSTEM Telnet Close Connection
    Telnet.Close Connection

SYSTEM Read Telnet Until Regexp
    [Arguments]    ${expected_first}
    ...            ${expected_second}
    Telnet.Set Timeout  20 minute 5 seconds
    Telnet.Read Until Regexp    ${expected_first}    ${expected_second}

##########general.robot######################
Get DSP mapped to any cell
    ${mapped_cells}=    Query infomodel  query=get list /MRBTS-1//LAYOUT_MAP-1/BBPOOL_L-* is [assignedLCellsDNs!=empty]    timeout=70
    ${BBU} =    fetch from left    ${mapped_cells[0].dspsDNs[0]}   /DSP_L
    log to console   ${BBU}
    ${DSP} =    Set Variable    ${BBU}/DSP_L-1
    [Return]    ${BBU}   ${DSP}

Get DSP which is not mapped to any cell
    ${mapped_cells}=    Query infomodel  query=get list /MRBTS-1//LAYOUT_MAP-1/BBPOOL_L-* is [assignedLCellsDNs==empty]    timeout=70
    ${BBU} =    fetch from left    ${mapped_cells[0].dspsDNs[0]}   /DSP_L
    log to console   ${BBU}
    ${DSP} =    Set Variable    ${BBU}/DSP_L-1
    [Return]    ${BBU}   ${DSP}

Wait until BBU and DSP are up and running '${BBU}'
    ${DSP_All}=    Set Variable    ${BBU}//SOC_L-*/DSP_L-1
    Query infomodel  query=${BBU} is ${operationalStateUp}  timeout=300
    Query infomodel  query=${BBU} is ${avabilityStatusUp}  timeout=300
    Query infomodel  query=every ${DSP_All} is ${operationalStateUp}  timeout=450
    Query infomodel  query=every ${DSP_All} is ${avabilityStatusUp}  timeout=400

Check the avaliable BBU '${BBU}' '${DSP}'
    ${bbmods_in_IM}=  Query Infomodel  query=get list ${BBU}
    ${cpu_bbus_in_IM}=  Query Infomodel  query=get list ${DSP}/CORE_L-1
    @{units_with_addresses}=    get_units_2  ${bbmods_in_IM}  ${cpu_bbus_in_IM}

    :FOR    ${unit}  IN    @{units_with_addresses}
    \    ${dsp_address}=  Get From List  ${unit}  0
    \    ${board_address}=  Get From List  ${unit}  1
    \    Log To Console     Address ${dsp_address} ${board_address}

    ${sender}      set variable     ${${dsp_address}0240}
    ${receiver}     set variable     ${${dsp_address}1202}
    Set Test Variable       ${sender}
    Set Test Variable       ${receiver}
    Set Test Variable       ${board_address}
    Set Test Variable       ${dsp_address}
    [Return]    ${sender}   ${receiver}   ${board_address}   ${dsp_address}

Check the address CPU
    ${smod_in_IM}=  Query Infomodel  query=get list ${SMOD}/CCU_L-1
    ${cpu_bbus_in_IM}=  Query Infomodel  query=get list ${SMOD}/CCU_L-1/SOC_L-1/CPU_L-1
    @{units_with_addresses}=    get_units_2  ${smod_in_IM}  ${cpu_bbus_in_IM}

    :FOR    ${unit}  IN    @{units_with_addresses}
    \    ${cpu_address}=  Get From List  ${unit}  0
    \    ${board_address}=  Get From List  ${unit}  1
    \    Log To Console     Address ${cpu_address} ${board_address}

    ${sender}      set variable     ${${cpu_address}0240}
    ${receiver}     set variable     ${${cpu_address}1202}
    [Return]    ${sender}   ${receiver}   ${board_address}

Check the address CPU from BBMOD '${BBU}'
    ${smod_in_IM}=  Query Infomodel  query=get list ${BBU}
    ${cpu_bbus_in_IM}=  Query Infomodel  query=get list ${BBU}/POWER_GROUP_L-1/SOC_L-1/CPU_L-1
    @{units_with_addresses}=    get_units_2  ${smod_in_IM}  ${cpu_bbus_in_IM}

    :FOR    ${unit}  IN    @{units_with_addresses}
    \    ${cpu_address}=  Get From List  ${unit}  0
    \    ${board_address}=  Get From List  ${unit}  1
    \    Log To Console     Address ${cpu_address} ${board_address}

    ${sender}      set variable     ${${cpu_address}0240}
    ${receiver}     set variable     ${${cpu_address}1202}
    [Return]    ${sender}   ${receiver}   ${board_address}

Check the avaliable BBU or CPU board ID '${path_to_object}'
    ${bbmods_in_IM}=  Query Infomodel  query=get list ${path_to_object}
    @{units_with_addresses}=    get_units  ${bbmods_in_IM}

    :FOR    ${unit}  IN    @{units_with_addresses}
    \    ${board_address}=  Get From List  ${unit}  1
    \    Log To Console     Address ${board_address}

Get DSP mapped to any cell for all BBU
    ${mapped_cells_count}=    Query infomodel
    ...   query=get count /MRBTS-1/RAT-*//BBTOP_L-1/LAYOUT_MAP-1/LAYOUT_L-1/BBPOOL_L-* is [assignedLCellsDNs!=empty]    timeout=70
    ${mapped_cells}=    Query infomodel
    ...   query=get list /MRBTS-1/RAT-*//BBTOP_L-1/LAYOUT_MAP-1/LAYOUT_L-1/BBPOOL_L-* is [assignedLCellsDNs!=empty]    timeout=70

    :For   ${INDEX}    IN RANGE    0   ${mapped_cells_count}
    \    ${BBU} =    fetch from left    ${mapped_cells[${INDEX}].dspsDNs[0]}   /DSP_L
    \    ${DSP} =    Set variable    ${BBU}/DSP_L-1
    \    log to console  BBU path ${BBU} and DSP path ${DSP}
    \    Check the BBU and DSP address for mapped cell '${BBU}' '${DSP}'

Get DSP which is not mapped to any cell for all BBU
    ${not_mapped_cells_count}=    Query infomodel
    ...   query=get count /MRBTS-1/RAT-*//BBTOP_L-1/LAYOUT_MAP-1/LAYOUT_L-1/BBPOOL_L-* is [assignedLCellsDNs=empty]    timeout=70
    ${not_mapped_cells}=    Query infomodel
    ...   query=get list /MRBTS-1/RAT-*//BBTOP_L-1/LAYOUT_MAP-1/LAYOUT_L-1/BBPOOL_L-* is [assignedLCellsDNs=empty]    timeout=70

    :For   ${INDEX}    IN RANGE    0   ${not_mapped_cells_count}
    \    ${BBU} =    fetch from left    ${not_mapped_cells[${INDEX}].dspsDNs[0]}   /DSP_L
    \    ${DSP} =    Set variable    ${BBU}/DSP_L-1
    \    log to console  BBU path ${BBU} and DSP path ${DSP}
    \    Check the BBU and DSP address for not mapped cell '${BBU}' '${DSP}'

Get DSP mapped to any cell for all BBU and create list
    ${mapped_cells_count}=    Query infomodel
    ...   query=get count /MRBTS-1/RAT-*//BBTOP_L-1/LAYOUT_MAP-1/LAYOUT_L-1/BBPOOL_L-* is [assignedLCellsDNs!=empty]    timeout=70
    ${mapped_cells}=    Query infomodel
    ...   query=get list /MRBTS-1/RAT-*//BBTOP_L-1/LAYOUT_MAP-1/LAYOUT_L-1/BBPOOL_L-* is [assignedLCellsDNs!=empty]    timeout=70

    @{unit_list_BBU}=    Create list
    @{unit_list_DSP}=    Create list

        :For   ${INDEX}    IN RANGE    0   ${mapped_cells_count}
    \    ${BBU} =    fetch from left    ${mapped_cells[${INDEX}].dspsDNs[0]}   /DSP_L
    \    ${DSP} =    Set variable    ${BBU}/DSP_L-1
    \    insert into list     ${unit_list_BBU}    ${INDEX}     ${BBU}
    \    insert into list     ${unit_list_DSP}    ${INDEX}     ${DSP}
    Sort List    ${unit_list_DSP}
    Sort List    ${unit_list_BBU}
    Reverse List    ${unit_list_DSP}
    Reverse List    ${unit_list_BBU}
    [Return]     ${unit_list_BBU}    ${unit_list_DSP}

Get the path to BBU "${BBU_from_list}"
    ${BBU}=     Get from List    ${unit_list_BBU}     ${BBU_from_list}
    ${DSP}=     Get from List    ${unit_list_DSP}     ${BBU_from_list}
    [Return]     ${BBU}

Get the path to BBU and DSP for SMOD and generate fault
    ${BBU}=     Get from List    ${unit_list_BBU}     0
    ${DSP}=     Get from List    ${unit_list_DSP}     0
    [Return]     ${BBU}
    Check the BBU and DSP address for mapped cell '${BBU}' '${DSP}'

Get the path to BBU and DSP for FBB and generate fault
    ${BBU}=     Get from List    ${unit_list_BBU}     1
    ${DSP}=     Get from List    ${unit_list_DSP}     1
    [Return]     ${BBU}
    Check the BBU and DSP address for mapped cell '${BBU}' '${DSP}'

Get DSP which is not mapped to any cell for all BBU and create list
    ${not_mapped_cells_count}=    Query infomodel
    ...   query=get count /MRBTS-1/RAT-*//BBTOP_L-1/LAYOUT_MAP-1/LAYOUT_L-1/BBPOOL_L-* is [assignedLCellsDNs=empty]    timeout=70
    ${not_mapped_cells}=    Query infomodel
    ...   query=get list /MRBTS-1/RAT-*//BBTOP_L-1/LAYOUT_MAP-1/LAYOUT_L-1/BBPOOL_L-* is [assignedLCellsDNs=empty]    timeout=70
    @{unit_list_BBU}=    Create list
    @{unit_list_DSP}=    Create list

    :For   ${INDEX}    IN RANGE    0   ${not_mapped_cells_count}
    \    ${BBU} =    fetch from left    ${not_mapped_cells[${INDEX}].dspsDNs[0]}   /DSP_L
    \    ${DSP} =    Set variable    ${BBU}/DSP_L-1
    \    insert into list     ${unit_list_BBU}    ${INDEX}     ${BBU}
    \    insert into list     ${unit_list_DSP}    ${INDEX}     ${DSP}
    [Return]     ${unit_list_BBU}    ${unit_list_DSP}

Get the path to BBU and DSP for alarm ID 7651 and generate fault '${unit_list_BBU}' '${unit_list_DSP}'
    ${BBU}=     Get from List    ${unit_list_BBU}     0
    ${DSP}=     Get from List    ${unit_list_DSP}     0
    [Return]     ${BBU}    ${DSP}
    Check the BBU and DSP address for not mapped cell '${BBU}' '${DSP}'

Get the path to BBU and DSP for alarm ID 7650 and generate fault '${unit_list_BBU}' '${unit_list_DSP}'
    ${BBU}=     Get from List    ${unit_list_BBU}     1
    ${DSP}=     Get from List    ${unit_list_DSP}     1
    [Return]     ${BBU}    ${DSP}
    Check the BBU and DSP address for not mapped cell '${BBU}' '${DSP}'

Check the BBU and DSP address for mapped cell '${BBU}' '${DSP}'
    ${bbmods_in_IM}=  Query Infomodel  query=get list ${BBU}
    ${cpu_bbus_in_IM}=  Query Infomodel  query=get list ${DSP}/CORE_L-1
    @{units_with_addresses}=    get_units_2  ${bbmods_in_IM}  ${cpu_bbus_in_IM}

    :FOR    ${unit}  IN    @{units_with_addresses}
    \    ${dsp_address}=  Get From List  ${unit}  0
    \    ${board_address}=  Get From List  ${unit}  1
    \    Log To Console     Address ${dsp_address} ${board_address}
    \    ${sender}      set variable     ${${dsp_address}0240}
    \    ${receiver}     set variable     ${${dsp_address}1202}
    \    Generate fault '${fault_id}' for mapped cell '${sender}' '${receiver}' '${board_address}' '${BBU}' '${DSP}'

Check the BBU and DSP address for not mapped cell '${BBU}' '${DSP}'
    ${bbmods_in_IM}=  Query Infomodel  query=get list ${BBU}
    ${cpu_bbus_in_IM}=  Query Infomodel  query=get list ${DSP}/CORE_L-1
    @{units_with_addresses}=    get_units_2  ${bbmods_in_IM}  ${cpu_bbus_in_IM}

    :FOR    ${unit}  IN    @{units_with_addresses}
    \    ${dsp_address}=  Get From List  ${unit}  0
    \    ${board_address}=  Get From List  ${unit}  1
    \    Log To Console     Address ${dsp_address} ${board_address}
    \    ${sender}      set variable     ${${dsp_address}0240}
    \    ${receiver}     set variable     ${${dsp_address}1202}
    \    Generate fault '${fault_id}' for not mapped cell '${sender}' '${receiver}' '${board_address}' '${dsp_address}'


Get fbb module variants
   ${objects_list}=  Query infomodel  query=get list ${BBMOD}
   ${fbb_modules}=    get_product_name    q_rmod=${objects_list}
   Log               ${fbb_modules}
   [Return]   ${fbb_modules}

Get BBMOD mapped to cell
    ${mapped_cells}=    Query infomodel  query=get list /MRBTS-1/RAT-*//BBTOP_L-1/LAYOUT_MAP-1/LAYOUT_L-1/BBPOOL_L-* is [assignedLCellsDNs!=empty]
    ...    timeout=350
    ${BBMOD} =    fetch from left    ${mapped_cells[0].dspsDNs[0]}   /BBU_L-1
    log to console   ${BBMOD}
    [Return]    ${BBMOD}

Get BBMOD which is not mapped to cell
    ${mapped_cells}=    Query infomodel  query=get list /MRBTS-1/RAT-*//BBTOP_L-1/LAYOUT_MAP-1/LAYOUT_L-1/BBPOOL_L-* is [assignedLCellsDNs=empty]
    ...     timeout=350
    ${BBMOD} =    fetch from left    ${mapped_cells[0].dspsDNs[0]}   /BBU_L-1
    log to console   ${BBMOD}
    [Return]    ${BBMOD}

Info Model history read from ims2 file '${ims_path_file}'
    @{alarm_change_sets}=    Get change sets    ${ims_path_file}    /MRBTS-1/RAT-1/BTS_L-1/LNBTS-1//ALARM_L-*
    @{fault_list}=    Create List
    ${index}=    Set Variable    0
    : FOR  ${alarm_change_set}  IN  @{alarm_change_sets}
    \    ${fault}=  Run keyword if  '${alarm_change_set.action}' == 'Update'  Set Variable  ${alarm_change_set.object.alarmInformation.faultId}
    \    Run keyword if  '${fault}' != 'None'  Insert Into List  ${fault_list}    ${index}    ${fault}
    \    ${index}=    evaluate    (${index}+1)
#    log to console   ${\n} ${fault_list}  ${\n}
    [Return]    ${fault_list}

Check if BTS was rebooted '${max_time_after_startup}'
     Should be True   ${total_minutes} < ${max_time_after_startup}

Get FSP mapped to cell
    ${pool_mapping}=   Query infomodel
    ...   query=get list /MRBTS-1/RAT-1/MCTRL-1/BBTOP_M-1/LAYOUT_MAP-1/CELL_TO_POOL_MAPPING_L-* is [cellSlots[0].poolDN!=empty]    timeout=60
    ${pool_map_total}=   Query infomodel
    ...   query=get count /MRBTS-1/RAT-1/MCTRL-1/BBTOP_M-1/LAYOUT_MAP-1/CELL_TO_POOL_MAPPING_L-* is [cellSlots[0].poolDN!=empty]    timeout=60
    @{unit_list_BBU}=    Create list
    @{unit_list_DSP}=    Create list
    :For   ${INDEX}    IN RANGE    0   ${pool_map_total}
    \   ${cell_pool}=   Get from dictionary  ${pool_mapping[${INDEX}].cellSlots[0]}   poolDN
    \   ${core_pool}=   Query infomodel  query=get list ${cell_pool}
    \   ${bbu}=    Get from dictionary     ${core_pool[0].cores[0]}   coreDN
    \   ${bbu}=    fetch from left   ${bbu}   /POWER_GROUP_L-
#    \   ${dsp} =    Set variable    ${bbu}/DSP_L-1
    \   insert into list     ${unit_list_BBU}    ${INDEX}     ${bbu}
#    \   insert into list     ${unit_list_DSP}    ${INDEX}     ${dsp}
##    Sort List    ${unit_list_DSP}
    Sort List    ${unit_list_BBU}
##    Reverse List    ${unit_list_DSP}
    Reverse List    ${unit_list_BBU}
    [Return]    ${unit_list_BBU}

Available FSP on BTS '${FSP_SMOD_BBU}' '${FSP_BBMOD_BBU}' '${path_BBMOD}'
    ${SMOD_FSP}=    Query infomodel  query=get count ${FSP_SMOD_BBU} is [stateInfo.availabilityStatus="Online"]    timeout=10
    ${BBMOD_FSP}=    Query infomodel  query=get count ${FSP_BBMOD_BBU} is [stateInfo.availabilityStatus="Online"]    timeout=10
    ${Number_of_FSP}=     evaluate    (${SMOD_FSP}+${BBMOD_FSP})

    Run Keyword If    '${Number_of_FSP}' == '2'      FSP on BTS are available '${BBMOD_FSP}' '${path_BBMOD}' '${SMOD_FSP}' '${FSP_SMOD_BBU}'
    Run Keyword If    '${Number_of_FSP}' == '3'      FSP on BTS are available '${BBMOD_FSP}' '${path_BBMOD}' '${SMOD_FSP}' '${FSP_SMOD_BBU}'
    Run Keyword If    '${Number_of_FSP}' == '1'      FSP on BTS are available '${BBMOD_FSP}' '${path_BBMOD}' '${SMOD_FSP}' '${FSP_SMOD_BBU}'
    Run Keyword If    '${Number_of_FSP}' == '0'      Log to console     Error pleas check if BTS is working correctly

FSP on BTS are available '${BBMOD_FSP}' '${path_BBMOD}' '${SMOD_FSP}' '${FSP_SMOD_BBU}'
    @{list_of_FSP_BBU}=    Create list    @{EMPTY}
    :For  ${INDEX}    IN RANGE   0   ${BBMOD_FSP}
    \     ${counter}=   Run Keyword If   '${BBMOD_FSP}'=='2'   evaluate   (${INDEX}+1)   ELSE   Set Variable   *
    \     ${BBMOD_FSP_list}=    Query infomodel  query=get list ${path_BBMOD}${counter} is [stateInfo.operationalState="Enabled"]    timeout=10
    \     ${bbu_FSP}=    Set Variable     ${BBMOD_FSP_list[0].dist_name}
    \     ${bbu_FSP}=    Set Variable    ${bbu_FSP}/BBU_L-1
#    \     ${counter}=   Run Keyword If   '${BBMOD_FSP}'=='1'   Set Variable   0   ELSE   Log to console   ${counter}
    \     ${tmp}=  Run Keyword And Return Status   Query infomodel  query=${bbu_FSP} is [stateInfo.availabilityStatus="Online"]    timeout=10
    \     Run Keyword If    ${tmp}==True   insert into list   ${list_of_FSP_BBU}   ${INDEX}   ${bbu_FSP}   ELSE    Log to console   FSP is Offline

    ${lenght_list_of_FSP_BBU}=   get length   ${list_of_FSP_BBU}
    Run Keyword If   '${SMOD_FSP}'=='1'   insert into list   ${list_of_FSP_BBU}   ${lenght_list_of_FSP_BBU}   ${FSP_SMOD_BBU}
    ...     ELSE      Log to console    FSP on SMOD is not working correctly

    Sort List    ${list_of_FSP_BBU}
    Reverse List    ${list_of_FSP_BBU}
    Set Test variable    ${list_of_FSP_BBU}

List is empty for FSP where cell are not mapped
    ${FSP_not_mapped_cell}=    Set Variable   0
    Log To Console    ${\n} FSP not mapped to cells: ${FSP_not_mapped_cell} ${\n}

List is empty for FSP where cell are mapped
    ${FSP_mapped_cell}=    Set Variable   0
    Log To Console    ${\n} FSP mapped to cells: ${FSP_mapped_cell} ${\n}
    Log To Console    Check the configuration on BTS or test

Check the FSP on BTS and mapping of cells '${FSP_SMOD_BBU}' '${FSP_BBMOD_BBU}' '${path_BBMOD}'
    @{FSP_mapped_cell}=    Create List    ${EMPTY}
    @{FSP_not_mapped_cell}=    Create List    ${EMPTY}

    ${unit_list_BBU}=    Get FSP mapped to cell
    Available FSP on BTS '${FSP_SMOD_BBU}' '${FSP_BBMOD_BBU}' '${path_BBMOD}'
    log to console    ${\n} Available FSP on BTS: ${list_of_FSP_BBU} ${\n}

    ${FSP_mapped_cell}=    compare_lists_and_return_duplicates    ${unit_list_BBU}   ${list_of_FSP_BBU}
    ${length_FSP_mapped_cell}=     get length    ${FSP_mapped_cell}
    Run Keyword If    '${length_FSP_mapped_cell}'=='0'   List is empty for FSP where cell are mapped   ELSE
    ...    Log To Console    ${\n} FSP mapped to cells: ${FSP_mapped_cell} ${\n}

    ${FSP_sort_mapped_cell_1}=    compare_lists_and_return_non_duplicates    ${FSP_mapped_cell}   ${list_of_FSP_BBU}
    ${FSP_not_mapped_cell}=    compare_lists_and_return_duplicates    ${FSP_sort_mapped_cell_1}   ${list_of_FSP_BBU}
    ${length_FSP_not_mapped_cell}=     get length    ${FSP_not_mapped_cell}
    Run Keyword If    '${length_FSP_not_mapped_cell}'=='0'   List is empty for FSP where cell are not mapped    ELSE
    ...    Log To Console    ${\n} FSP not mapped to cells: ${FSP_not_mapped_cell} ${\n}
    Set Test Variable    ${FSP_mapped_cell}
    Set Test Variable    ${FSP_not_mapped_cell}
    Set Test Variable    ${FSP_sort_mapped_cell_1}
#    Set Test Variable    ${unit_list_DSP}
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

############################## Cell mapping Common CELL
Get cell mapping to BBUs
    ${cells_no}=   Query infomodel  query=get count /MRBTS-1/RAT-1/MCTRL-1/BBTOP_M-1/MRBTS_M-1/LNBTS_M-1/CELL_M-* is [stateInfo=regex".*"]
    ${pool_mapping}=   Query infomodel
    ...     query=get list /MRBTS-1/RAT-1/MCTRL-1/BBTOP_M-1/LAYOUT_MAP-1/CELL_TO_POOL_MAPPING_L-* is [cellSlots[0].poolDN!=empty]    timeout=60
    ${pool_map_total}=   Query infomodel
    ...     query=get count /MRBTS-1/RAT-1/MCTRL-1/BBTOP_M-1/LAYOUT_MAP-1/CELL_TO_POOL_MAPPING_L-* is [cellSlots[0].poolDN!=empty]    timeout=60
    @{smod_lcells}=    Create list
    @{bbmod1_lcells}=    Create list
    @{bbmod2_lcells}=    Create list
    Set Test Variable     ${pool_mapping}
    Set Test Variable     ${pool_map_total}
    Set Test Variable     @{smod_lcells}
    Set Test Variable     @{bbmod1_lcells}
    Set Test Variable     @{bbmod2_lcells}
    ${smod_bbu_cells}=    Set Variable   0
    ${bbmod1_bbu_cells}=    Set Variable   0
    ${bbmod2_bbu_cells}=    Set Variable   0
    Set Test Variable     ${smod_bbu_cells}
    Set Test Variable     ${bbmod1_bbu_cells}
    Set Test Variable     ${bbmod2_bbu_cells}
    :For   ${INDEX}    IN RANGE    0   ${pool_map_total}
    \   ${cell_pool}=   Get from dictionary  ${pool_mapping[${INDEX}].cellSlots[0]}   poolDN
    \   ${core_pool}=   Query infomodel  query=get list ${cell_pool}
    \   ${bbu}=    Get from dictionary     ${core_pool[0].cores[0]}   coreDN
    \   ${bbu}=         fetch from left    ${bbu}   /DSP_L
    \   ${bbu}=         fetch from right    ${bbu}   EQM_L-1/
    \   Check list of BBUs '${bbu}' '${INDEX}'
    ${smod_lcells}=  evaluate  [str(x)[60::] for x in ${smod_lcells}]
    ${smod_lcells}=  evaluate  [int(x) for x in ${smod_lcells}]
    ${bbmod1_lcells}=  evaluate  [str(x)[60::] for x in ${bbmod1_lcells}]
    ${bbmod1_lcells}=  evaluate  [int(x) for x in ${bbmod1_lcells}]
    ${bbmod2_lcells}=  evaluate  [str(x)[60::] for x in ${bbmod2_lcells}]
    ${bbmod2_lcells}=  evaluate  [int(x) for x in ${bbmod2_lcells}]
    ${smod_bbu_cells}=  get length  ${smod_lcells}
    ${bbmod1_bbu_cells}=  get length  ${bbmod1_lcells}
    ${bbmod2_bbu_cells}=  get length  ${bbmod2_lcells}
    log to console  LCELLs on SMOD BBU = ${smod_lcells}
    log to console  LCELLs on BBMOD1 BBU = ${bbmod1_lcells}
    log to console  LCELLs on BBMOD2 BBU = ${bbmod2_lcells}
    log to console  Number of cell(s) on SMOD BBU = ${smod_bbu_cells}
    log to console  Number of cell(s) on BBMOD1 BBU = ${bbmod1_bbu_cells}
    log to console  Number of cell(s) on BBMOD2 BBU = ${bbmod2_bbu_cells}
    Set Test Variable     ${smod_bbu_cells}
    Set Test Variable     ${bbmod1_bbu_cells}
    Set Test Variable     ${bbmod2_bbu_cells}
    Set Test Variable     ${smod_lcells}
    Set Test Variable     ${bbmod1_lcells}
    Set Test Variable     ${bbmod2_lcells}

Check list of BBUs '${bbu}' '${INDEX}'
    ${tmp}=  Run Keyword And Return Status  Should contain  ${bbu}  SMOD_L-1/BBU_L-1
    Run Keyword If    ${tmp}==True  Cells on SMOD BBU '${INDEX}'
    ${tmp}=  Run Keyword And Return Status  Should contain  ${bbu}  BBMOD_L-1/BBU_L-1
    Run Keyword If    ${tmp}==True  Cells on BBMOD1 BBU '${INDEX}'
    ${tmp}=  Run Keyword And Return Status  Should contain  ${bbu}  BBMOD_L-2/BBU_L-1
    Run Keyword If    ${tmp}==True  Cells on BBMOD2 BBU '${INDEX}'

Cells on SMOD BBU '${INDEX}'
    insert into list     ${smod_lcells}    ${smod_bbu_cells}     ${out_pool_mapping[${INDEX}].cellDN}
    ${smod_bbu_cells}=    Evaluate    (${smod_bbu_cells}+1)

Cells on BBMOD1 BBU '${INDEX}'
    insert into list     ${bbmod1_lcells}    ${bbmod1_bbu_cells}     ${out_pool_mapping[${INDEX}].cellDN}
    ${bbmod1_bbu_cells}=    Evaluate    (${bbmod1_bbu_cells}+1)

Cells on BBMOD2 BBU '${INDEX}'
    insert into list     ${bbmod2_lcells}    ${bbmod2_bbu_cells}     ${out_pool_mapping[${INDEX}].cellDN}
    ${bbmod2_bbu_cells}=    Evaluate    (${bbmod2_bbu_cells}+1)

Set QC_Tag
    Setup Enb Fsm Access    alias=enb1
    ${enb_sw_version}    Get Enb Sw Version    alias=enb1
    Log    \nActive SW: ${enb_sw_version}    console=yes
    @{release}    split_string    ${enb_sw_version}    _
    Set Test Variable  @{release}
    Set Test Variable   ${release_name}     @{release}[0]_@{release}[1]_@{release}[2]
    Set Test Variable   ${smod_fcm}     ${OUT_ADMIN_SMOD_PARAMETERS[0].fcmVariant}
    Set Test Variable   ${bbmod_pn}     ${OUT_ADMIN_BBMODS_PARAMETERS[0].productName}
    ${QC_ID}    Set Variable If    "@{release}[0]_@{release}[1]"=="5G19_FSMK"    &{${TEST_NAME}}[QC_ID_5GTRUNK]
    ...                            "@{release}[0]_@{release}[1]"=="5G19B_FSMK"    &{${TEST_NAME}}[QC_ID_5GTRUNK]
    ...                            "@{release}[0]_@{release}[1]"=="5G21A_GNB"    &{${TEST_NAME}}[QC_ID_5G21A]
    ...                            "@{release}[0]_@{release}[1]"=="5G21B_GNB"    &{${TEST_NAME}}[QC_ID_5GTRUNK]
    ...  "${release_name}"=="SBTS21B_ENB_9999" and "${smod_fcm}"!="ASI B"    &{${TEST_NAME}}[QC_ID_TRUNK]
    ...  "${release_name}"=="SBTS22R1_ENB_9999" and "${smod_fcm}"!="ASI B"    &{${TEST_NAME}}[QC_ID_TRUNK]
    ...  "${release_name}"=="SBTS22R2_ENB_9999" and "${smod_fcm}"!="ASI B"    &{${TEST_NAME}}[QC_ID_TRUNK]
    ...  "${release_name}"=="SBTS22R3_ENB_9999" and "${smod_fcm}"!="ASI B"    &{${TEST_NAME}}[QC_ID_TRUNK]
    ...  "${release_name}"=="SBTS22R4_ENB_9999" and "${smod_fcm}"!="ASI B"    &{${TEST_NAME}}[QC_ID_TRUNK]
    ...  "${release_name}"=="SBTS23R1_ENB_9999" and "${smod_fcm}"!="ASI B"    &{${TEST_NAME}}[QC_ID_TRUNK]
	...  "${release_name}"=="SBTS23R2_ENB_9999" and "${smod_fcm}"!="ASI B"    &{${TEST_NAME}}[QC_ID_TRUNK]
    ...  "${release_name}"=="SBTS21A_ENB_0000" and "${smod_fcm}"!="ASI B"    &{${TEST_NAME}}[QC_ID_SBTS21A]
    ...  "${release_name}"=="SBTS21B_ENB_0000" and "${smod_fcm}"!="ASI B"    &{${TEST_NAME}}[QC_ID_SBTS21B]
    ...  "${release_name}"=="SBTS22R1_ENB_0000" and "${smod_fcm}"!="ASI B"    &{${TEST_NAME}}[QC_ID_SBTS22R1]
    ...  "${release_name}"=="SBTS22R2_ENB_0000" and "${smod_fcm}"!="ASI B"    &{${TEST_NAME}}[QC_ID_SBTS22R2]
    ...  "${release_name}"=="SBTS22R3_ENB_0000" and "${smod_fcm}"!="ASI B"    &{${TEST_NAME}}[QC_ID_SBTS22R3]
    ...  "${release_name}"=="SBTS22R4_ENB_0000" and "${smod_fcm}"!="ASI B"    &{${TEST_NAME}}[QC_ID_SBTS22R4]
	...  "${release_name}"=="SBTS23R1_ENB_0000" and "${smod_fcm}"!="ASI B"    &{${TEST_NAME}}[QC_ID_SBTS23R1]
    ...  "${release_name}"=="SBTS22R1_ENB_9999" and "${smod_fcm}"=="ASI B" and "${bbmod_pn}"!="ABIC AirScale"    &{${TEST_NAME}}[QC_ID_TRUNK_ASIB]
    ...  "${release_name}"=="SBTS22R1_ENB_9999" and "${smod_fcm}"=="ASI B" and "${bbmod_pn}"=="ABIC AirScale"    &{${TEST_NAME}}[QC_ID_TRUNK_ABIC]
    ...  "${release_name}"=="SBTS22R2_ENB_9999" and "${smod_fcm}"=="ASI B" and "${bbmod_pn}"!="ABIC AirScale"    &{${TEST_NAME}}[QC_ID_TRUNK_ASIB]
    ...  "${release_name}"=="SBTS22R2_ENB_9999" and "${smod_fcm}"=="ASI B" and "${bbmod_pn}"=="ABIC AirScale"    &{${TEST_NAME}}[QC_ID_TRUNK_ABIC]
    ...  "${release_name}"=="SBTS22R3_ENB_9999" and "${smod_fcm}"=="ASI B" and "${bbmod_pn}"!="ABIC AirScale"    &{${TEST_NAME}}[QC_ID_TRUNK_ASIB]
    ...  "${release_name}"=="SBTS22R3_ENB_9999" and "${smod_fcm}"=="ASI B" and "${bbmod_pn}"=="ABIC AirScale"    &{${TEST_NAME}}[QC_ID_TRUNK_ABIC]
    ...  "${release_name}"=="SBTS22R4_ENB_9999" and "${smod_fcm}"=="ASI B" and "${bbmod_pn}"!="ABIC AirScale"    &{${TEST_NAME}}[QC_ID_TRUNK_ASIB]
    ...  "${release_name}"=="SBTS22R4_ENB_9999" and "${smod_fcm}"=="ASI B" and "${bbmod_pn}"=="ABIC AirScale"    &{${TEST_NAME}}[QC_ID_TRUNK_ABIC]
    ...  "${release_name}"=="SBTS23R1_ENB_9999" and "${smod_fcm}"=="ASI B" and "${bbmod_pn}"!="ABIC AirScale"    &{${TEST_NAME}}[QC_ID_TRUNK_ASIB]
    ...  "${release_name}"=="SBTS23R1_ENB_9999" and "${smod_fcm}"=="ASI B" and "${bbmod_pn}"=="ABIC AirScale"    &{${TEST_NAME}}[QC_ID_TRUNK_ABIC]
	...  "${release_name}"=="SBTS23R2_ENB_9999" and "${smod_fcm}"=="ASI B" and "${bbmod_pn}"!="ABIC AirScale"    &{${TEST_NAME}}[QC_ID_TRUNK_ASIB]
    ...  "${release_name}"=="SBTS23R2_ENB_9999" and "${smod_fcm}"=="ASI B" and "${bbmod_pn}"=="ABIC AirScale"    &{${TEST_NAME}}[QC_ID_TRUNK_ABIC]
    ...  "${release_name}"=="SBTS21B_ENB_0000" and "${smod_fcm}"=="ASI B" and "${bbmod_pn}"!="ABIC AirScale"    &{${TEST_NAME}}[QC_ID_SBTS21B_ASIB]
    ...  "${release_name}"=="SBTS21B_ENB_0000" and "${smod_fcm}"=="ASI B" and "${bbmod_pn}"=="ABIC AirScale"    &{${TEST_NAME}}[QC_ID_SBTS21B_ABIC]
    ...  "${release_name}"=="SBTS22R1_ENB_0000" and "${smod_fcm}"=="ASI B" and "${bbmod_pn}"=="ABIC AirScale"    &{${TEST_NAME}}[QC_ID_SBTS22R1_ABIC]
    ...  "${release_name}"=="SBTS22R1_ENB_0000" and "${smod_fcm}"=="ASI B" and "${bbmod_pn}"!="ABIC AirScale"    &{${TEST_NAME}}[QC_ID_SBTS22R1_ASIB]
    ...  "${release_name}"=="SBTS22R2_ENB_0000" and "${smod_fcm}"=="ASI B" and "${bbmod_pn}"=="ABIC AirScale"    &{${TEST_NAME}}[QC_ID_SBTS22R2_ABIC]
    ...  "${release_name}"=="SBTS22R2_ENB_0000" and "${smod_fcm}"=="ASI B" and "${bbmod_pn}"!="ABIC AirScale"    &{${TEST_NAME}}[QC_ID_SBTS22R2_ASIB]
    ...  "${release_name}"=="SBTS22R3_ENB_0000" and "${smod_fcm}"=="ASI B" and "${bbmod_pn}"=="ABIC AirScale"    &{${TEST_NAME}}[QC_ID_SBTS22R3_ABIC]
    ...  "${release_name}"=="SBTS22R3_ENB_0000" and "${smod_fcm}"=="ASI B" and "${bbmod_pn}"!="ABIC AirScale"    &{${TEST_NAME}}[QC_ID_SBTS22R3_ASIB]
    ...  "${release_name}"=="SBTS22R4_ENB_0000" and "${smod_fcm}"=="ASI B" and "${bbmod_pn}"=="ABIC AirScale"    &{${TEST_NAME}}[QC_ID_SBTS22R4_ABIC]
    ...  "${release_name}"=="SBTS22R4_ENB_0000" and "${smod_fcm}"=="ASI B" and "${bbmod_pn}"!="ABIC AirScale"    &{${TEST_NAME}}[QC_ID_SBTS22R4_ASIB]
	...  "${release_name}"=="SBTS23R1_ENB_0000" and "${smod_fcm}"=="ASI B" and "${bbmod_pn}"=="ABIC AirScale"    &{${TEST_NAME}}[QC_ID_SBTS23R1_ABIC]
    ...  "${release_name}"=="SBTS23R1_ENB_0000" and "${smod_fcm}"=="ASI B" and "${bbmod_pn}"!="ABIC AirScale"    &{${TEST_NAME}}[QC_ID_SBTS23R1_ASIB]
    Log    ${QC_ID}    console=yes
    Set Tags    ${QC_ID}
    Teardown Enb Fsm Access    alias=enb1

Set QC_Tag New
    Setup Enb Fsm Access    alias=enb1
    ${enb_sw_version}    Get Enb Sw Version    alias=enb1
    Log    ${enb_sw_version}    console=yes
    @{release}    split_string    ${enb_sw_version}    _
    Log    "@{release}[0]_@{release}[1]"    console=yes
    Set Test Variable  @{release}
    ${QC_ID}    Set Variable If    "@{release}[0]_@{release}[1]"=="SBTS18SP_ENB"    &{${TEST_NAME}}[QC_ID_SBTS18SP]
    ...                            "@{release}[0]_@{release}[1]"=="SBTS18A_FSM3"    &{${TEST_NAME}}[QC_ID_TRUNK]
    ...                            "@{release}[0]_@{release}[1]"=="SBTS18A_FSM4"    &{${TEST_NAME}}[QC_ID_TRUNK]
    Log    ${QC_ID}    console=yes
    Set Tags    ${QC_ID}
    Teardown Enb Fsm Access    alias=enb1

Check systemAcctPermEnable Parameter
    [Documentation]
    ...    Author: Piotr Sewerynek
    ...    Use this keyword in Suite Preconditions
    ADMIN Setup Admin    alias=parameter
    ADMIN INFOMODEL Start Logging    alias=parameter
    ${status}=  Run Keyword And Return Status  ADMIN INFOMODEL Query Infomodel And Expect Parameter Value
    ...    dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-${BTS_side}/MRBTS_R-${BTS_side}/MNL_CONF_M-1/MNLENT_CONF_M-1/FEATCADM_CONF_M-1
    ...    parameter=systemAcctPermEnable
    ...    value=true
    ...    timeout=5
    ...    alias=parameter
    Run Keyword if  ${status}==False    ADMIN Perform Parameter Recommissioning
    ...    dist_name=MRBTS-1/MNL-1/MNLENT-1/FEATCADM-1
    ...    parameter=systemAcctPermEnable
    ...    operation=update
    ...    value=false
    ...    timeout=300
    ...    connection=parameter
    Run Keyword if  ${status}==False    ADMIN INFOMODEL Query Infomodel And Expect Parameter Value
    ...    dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-${BTS_side}/MRBTS_R-${BTS_side}/MNL_CONF_M-1/MNLENT_CONF_M-1/FEATCADM_CONF_M-1
    ...    parameter=systemAcctPermEnable
    ...    value=false
    ...    timeout=120
    ...    alias=parameter
    ADMIN Teardown Admin    alias=parameter
    ADMIN INFOMODEL Stop Logging    alias=parameter

SYSTEM Change Btsname In Testline SCFC
    ${SCFCfile}    Set Variable    /home/ute/testline_init_results/config_files/SCFC_1.xml
    ${Output}    Set Variable    /home/ute/testline_init_results/config_files/CONF.xml
    ${btsName}    Run    hostname
    Run    sed -i -e 's/${btsName}/MRBTS-1/g' ${SCFCfile}
    Run    cp ${SCFCfile} ${Output}

SYSTEM Install RNCMock Library
    ${rc}    Run And Return Rc     sudo apt-get install ute-rncmock=1.1
    Should Be Equal As Integers     ${rc}    0

Set New Project
    Add New Project Tags
#    Setup Enb Fsm Access    alias=enb1
#    ${enb_sw_version}    Get Enb Sw Version    alias=enb1
#    Log    \nActive SW: ${enb_sw_version}    console=yes
#    @{release}    split_string    ${enb_sw_version}    _
#    Set Test Variable  @{release}
#    Run Keyword If    "@{release}[0]" == "SBTS22R1"    Add New Project Tags
#    Run Keyword If    "@{release}[0]" == "SBTS22R2"    Add New Project Tags
#    Teardown Enb Fsm Access    alias=enb1

Add New Project Tags
    Remove Tags    QCP_BTS_OAM    QCD_MN_BTS_OAM
    Remove Tags    QCP_SRAN_SBTS    QCD_MN_SRAN
    Set Tags    QCD_MN_RAN    QCP_RAN_ST
    Remove Tags    CA_BTS_OAM_PDZ
    Set Tags    CA_RAN_PZ_BLR


*** Settings ***
Documentation
...    Author: Elena Sabau
...    Maintainer: elena.sabau@nokia.com
...    Group in charge: MANO_SOAM3
...    References: doors
...    Feature Description:
...    Sample execution: /opt/ute/python/bin/pybot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log
...    -d results/ /home/ute/robotws5g/testsuite/OAM/ET/BTS_OAM_FMRECOV/5GC001542-RA/general.robot
...    Sample execution: /opt/ute/python/bin/pybot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log
...    -d results/ /home/ute/robotws5g/testsuite/OAM/ET/BTS_OAM_FMRECOV/5GC001542-RA/general_1.robot

Library     String
Library     Telnet
Library     Process
Library     taf.transport.ssh   WITH NAME   csn
Library     SeleniumLibrary
Library     SSHLibrary
Library     OperatingSystem
Library     DateTime
Library     pcapFiltering.py
Library     taf.transport.ssh  WITH NAME  transport_ssh

Resource       ../../resources/admin.robot
Resource       ../../resources/pretest_posttest.robot
Resource       ../../resources/fault_trigger.robot
Resource       ../../resources/system.robot
Resource    ../../resources/selenium.robot
Resource    ../../resources/selenium_oru.robot
#Resource    ./keywords.robot
#Resource    ./selenium.robot
Resource    ../../resources/orusim.robot
#Resource    ./admin.robot

*** Variables ***
${command}
${GNB_addr}=                192.168.255.129
${GNB_username}=            toor4nsn
${GNB_password}=            oZPS0POrRieRtu
${result}
${SYSTEM_ALIAS_GNB}=        gnb
${SYSTEM_ALIAS_ORU}=        oru
${reply}
${USERNAME}     Nemuadmin
${PASSWORD}     nemuuser
${scf_loopback}=                ${CURDIR}/Configuration_loopback_mrbts_10617.xml
${scf_loopback_branch}=                ${CURDIR}/Configuration_loopback_mrbts_10617_branch.xml
${SYSTEM_gnb_TRANSPORT_IP}=     192.168.255.1
${SYSTEM_gnb_SSH_USERNAME}=     toor4nsn
${SYSTEM_gnb_SSH_PASSWORD}=     oZPS0POrRieRtu
${output}
${Key_to_find}=         02:42:ac:11:00:02
${outputPathPcap}=      /tmp/rfoe0.pcap
#${comanda_netconf}      edit-config --target running  --config=/opt/dev/xml/v1/o-ran-lbm-config-change-KO.xml
${SerwerConnectionAlias}        SerwerConnection
${save_pcap_in_TC}      O-DU_xNB_shall_support_Ethernet_Connectivity_Monitoring_for_C-U_sessions_with_O-RU
${location_rfoe0.pcap}      results/O-DU_xNB_shall_support_Ethernet_Connectivity_Monitoring_for_C-U_sessions_with_O-RU
${alias}=  ${ADMIN_ALIAS}
${O-RU_username}=                oru
${O-RU_password}=                orusim12
${oru1}=                    10.5.53.235
*** Keywords ***
O-DU_xNB_shall_support_Ethernet_Connectivity_Monitoring_for_C-U_sessions_with_O-RU
    Log to console   start test
## *** load scf with parameters for loopback
    @{status}   Run Keyword and Ignore Error    ADMIN Perform Commissioning trunk and 22r2
    Run Keyword If  '@{status}[0]' == 'FAIL'   Run Keyword    ADMIN Perform Commissioning branch
    ...     ELSE    Log To Console  --- scf already ---
#    Wait Until Keyword Succeeds  300  20    ADMIN Check BTS onair
    Sleep  360
    SYSTEM Open SSH Connection To gnb for BBMOD
## *** connect to container on abio
    SSHLibrary.Write    bsh 1:1
## *** wait for command to finish
    SSHLibrary.Read Until       :~#
## *** collect 500 packets from rfoe0 interface and save them in rfoe0.pcap
    SSHLibrary.Write    ip netns exec radions tcpdump -i rfoe0 -XX -c 1000 -w /ffs/run/logs/rfoe0.pcap -e -nn |grep CFM
    Sleep  20
    SSHLibrary.Read Until       :~#
    SSHLibrary.Close Connection
    Run  command=ssh-keygen -f "/home/ute/.ssh/known_hosts" -R "192.168.255.1"
    Run  command=rm ${EXECDIR}/results/${save_pcap_in_TC}/rfoe0.pcap
## *** copy file rfoe0.pcap from BTS in /tmp from virtual machine
    Run And Return Rc And Output  sshpass -p 'oZPS0POrRieRtu' scp toor4nsn@192.168.255.1:/ffs/run/logs/* /tmp
     ${filtered_output}    check if pcap contains logs with filter
     ...    eth.addr ==${Key_to_find} and cfm  ${outputPathPcap}

Test 2. O-RU rejects the configuration request from gNB (O-DU) Fault ID 1900
    Log to console   start test
    Wait Until Keyword Succeeds  420  25    ADMIN Check BTS onair
    Change o-ran-lbm-config-change-KO to oru    ${oru1}
#    Wait Until Keyword Succeeds  240  20    ADMIN Check BTS Configured
    Wait Until Keyword Succeeds  240  20    ADMIN Check If Alarm Is Active  fault_id=1900
    Wait Until Keyword Succeeds  240  20    ADMIN Check If Alarm Is Active  fault_id=61009
    Check_and_Stop_O-RU_container  ${oru1}
    Check_and_Start_O-RU_container  ${oru1}
    Wait Until Keyword Succeeds  300  20    ADMIN Check BTS onair


check if pcap contains logs with filter
## *** filter the file received from ${capturePath} aplying the filter ${filter}
    [Arguments]   ${filter}      ${capturePath}
## *** save packets which fulfill the filter condition
    ${return_code}   ${logs} =    Run And Return Rc And Output    tshark -r ${capturePath} -F pcap ${filter}
## *** check if any packets have been found, otherwisw return error
    should be equal as integers    0    ${return_code}     Some error ocurred during running tshark: ${logs}
## *** convert them to lines which can be parsed
    ${lines}     get packets from string  ${logs}
## *** show them in log
    log  filtered logs: ${lines}
## *** get the number of packets received
    ${number_of_captured_packages}  get length  ${lines}
## *** if at least 1 packet has been received, return TRUE, othervise FALSE
    return from keyword if  ${number_of_captured_packages} > 0   ${True}
    [Return]  ${False}

SYSTEM Open SSH Connection To gnb for BBMOD
## *** open ssh connection between GNB and BBMOD
    SYSTEM Open SSH Connection    host=${SYSTEM_gnb_TRANSPORT_IP}
    ...                           port=22
    ...                           username=${SYSTEM_gnb_SSH_USERNAME}
    ...                           password=${SYSTEM_gnb_SSH_PASSWORD}
    ...                           alias=gnb

ADMIN Perform Commissioning trunk and 22r2
    ADMIN Perform Commissioning
    ...     scf_file=${scf_loopback}
    ...     skip_parameter_relation_errors=True

ADMIN Perform Commissioning branch
    ADMIN Perform Commissioning
    ...     scf_file=${scf_loopback_branch}
    ...     skip_parameter_relation_errors=True

Change o-ran-lbm-config-change-KO to oru
    [Arguments]    ${oru1}
     SYSTEM Open SSH Connection To o-ru  ${oru1}

     log to console      Change o-ran-lbm-config-change-KO

     SSHLibrary.Write            cd docker_share/orusim
     SSHLibrary.Read Until       orusim]$
     SSHLibrary.Write            sudo docker exec -it orusim /bin/bash
     SSHLibrary.Read Until       password for ${O-RU_username}:
     SSHLibrary.Write            ${O-RU_password}
     SSHLibrary.Read Until       /opt/dev#
     SSHLibrary.Write            supervisorctl stop all
     SSHLibrary.Read Until       /opt/dev#
     SSHLibrary.Write            sysrepocfg --verbosity 3 --edit=/opt/dev/xml/o-ran-lbm-config-change-KO.xml --datastore=startup --format=xml
     ${reply}  SSHLibrary.Read Until       /opt/dev#
     Run Keyword And Return Status  Should not contain  ${reply}  ERROR
     SSHLibrary.Write            sysrepocfg --verbosity 3 --edit=/opt/dev/xml/o-ran-lbm-config-change-KO.xml --datastore=startup --format=xml
     ${reply}  SSHLibrary.Read Until       /opt/dev#
     Run Keyword And Return Status  Should not contain  ${reply}  ERROR
     SSHLibrary.Write            supervisorctl start all
     SSHLibrary.Read Until       /opt/dev#

     log to console   ORU config changed successfully.

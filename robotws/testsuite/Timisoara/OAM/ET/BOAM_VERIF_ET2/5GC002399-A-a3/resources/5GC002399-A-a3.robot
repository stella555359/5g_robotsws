*** Settings ***
Documentation
...    Author: Sergiu Alecu (sergiu.alecu@nokia.com)
...    Maintainer: Sergiu Alecu (sergiu.alecu@nokia.com)
...    Group in charge: MANO_SOAM3
...    References: doors
...    Feature Description:5GC002399-A-a3
...    Sample execution: /opt/ute/python/bin/pybot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log
...    -d results/ /home/ute/robotws5g/testsuite/OAM/ET/BTS_OAM_FMRECOV/5GC001525-SA-TA/general.robot

Library        String
Library        Telnet
Library        OperatingSystem
Library        Process
Library        taf.transport.ssh   WITH NAME   csn
Library        SSHLibrary

Resource    ../../resources/admin.robot
Resource    ../../resources/pretest_posttest.robot
Resource    ../../resources/system.robot


*** Variables ***
${LOGGING_ENB_SYSLOG}=           True
${LOGGING_IPHY_SYSLOG}=          True
${LOGGING_ADMIN_LOG}=            True
${LOGGING_ADMIN_INFOMODEL_LOG}=  True
${LOGGING_EMSSIM_LOG}=           True

${asik_addr}                     192.168.255.1
${asik_username}                 toor4nsn
${asik_password}                 oZPS0POrRieRtu
${SYSTEM_ENB_TRANSPORT_IP}       192.168.255.129

${reasoning_path}=            /MRBTS-1/RAT-1/BTS_L-1/EQM_L-1/RMOD_L-1/RU_L-1

${scf_path}             /tmp/
${scf_name}             scf_file.xml

*** Keywords ***
BTS_Site_reset_L2RT
    log to console  Start test BTS Site reset L2RT
#    SYSTEM Add Flag In Swconfig File  0x420028=0
#    wait until keyword succeeds  900s  100s   Check If BTS Configured
    Comment flag EnableL2RTInSystemd=1 if exists
    log to console   Perform Reset Site
    ADMIN Reset Site
    Sleep  30
    SYSTEM Wait Till Gnb Will Be Pingable For A Given Period
    wait until keyword succeeds  900s  100s   Check If BTS Configured
    Run Keyword If  '${OUT_ADMIN_SMOD_POSITION}' == 'left'
    ...     Wait Until Keyword Succeeds  120s  5s  Check that L2RT is in RUNNING state left
    Run Keyword If  '${OUT_ADMIN_SMOD_POSITION}' == 'right'
    ...     Wait Until Keyword Succeeds  120s  5s  Check that L2RT is in RUNNING state right
    Run Keyword If  '${OUT_ADMIN_SMOD_POSITION}' == 'left'
    ...     Verify L2RT container is reachable left
    Run Keyword If  '${OUT_ADMIN_SMOD_POSITION}' == 'right'
    ...     Verify L2RT container is reachable right
    log to console  L2RT container is up and running

BTS_commissioning_L2RT
    log to console  Start test BTS commissioning L2RT
#    SYSTEM Add Flag In Swconfig File  0x420028=0
    Comment flag EnableL2RTInSystemd=1 with reboot
    wait until keyword succeeds  900s  100s   Check If BTS Configured
    ADMIN Collect Scf    local_dir_path=${scf_path}    file_name=${scf_name}
    ${commission_file}    set variable    ${scf_path}${scf_name}
    log to console  perform commissioning  on BTS
    ADMIN Perform Commissioning   scf_file=${commission_file}   skip_parameter_relation_errors=True
    wait until keyword succeeds  900s  100s   Check If BTS Configured
    Run Keyword If  '${OUT_ADMIN_SMOD_POSITION}' == 'left'
    ...     Check that L2RT is in RUNNING state left
    Run Keyword If  '${OUT_ADMIN_SMOD_POSITION}' == 'right'
    ...     Check that L2RT is in RUNNING state right
    Run Keyword If  '${OUT_ADMIN_SMOD_POSITION}' == 'left'
    ...     Verify L2RT container is reachable left
    Run Keyword If  '${OUT_ADMIN_SMOD_POSITION}' == 'right'
    ...     Verify L2RT container is reachable right
    log to console  L2RT container is up and running

Check_L2RT_not_running_with_EnableL2RTInSystemd!=0
    log to console  Start test Check L2RT is up and not running with EnableL2RTInSystemd!=0
    SYSTEM Add Flag In Swconfig File  0x420028=0
    wait until keyword succeeds  900s  100s   Check If BTS Configured
    Resolve flag EnableL2RTInSystemd=1
    Uncomment flag EnableL2RTInSystemd=1 if commented
    log to console   Perform Reset Site
    ADMIN Reset Site
    Sleep  30
    SYSTEM Wait Till Gnb Will Be Pingable For A Given Period
    wait until keyword succeeds  900s  100s   Check If BTS Configured
    Verify L2RT container is not reachable
    Check that L2RT is not in RUNNING state
    log to console  L2RT container is not running
    Resolve flag EnableL2RTInSystemd=0
    log to console  End test


Check If BTS Configured
    ${bts_statuses_response}=    taf.sbts.oam.coam.admin.Get Bts Info
    ${actual_value}=    Get From Dictionary
    ...    dictionary=${bts_statuses_response['status']}
    ...    key=proceduralState
    Should Be Equal
    ...    first=${actual_value}
    ...    second=Configured

Comment flag EnableL2RTInSystemd=1 if exists
    SYSTEM Execute Command On gNB
    ...    command=sed -i 's/0x420028=1/#0x420028=1/' /rom/swconfig.txt
    SYSTEM Execute Command On gNB
    ...    command=crasign /rom/swconfig.txt

Uncomment flag EnableL2RTInSystemd=1 if commented
    SYSTEM Execute Command On gNB
    ...    command=sed -i 's/#0x420028=1/0x420028=1/' /rom/swconfig.txt
    SYSTEM Execute Command On gNB
    ...    command=sed -i 's/#0x420028=1/0x420028=1/' /rom/swconfig.txt
    SYSTEM Execute Command On gNB
    ...    command=sed -i 's/#0x420028=1/0x420028=1/' /rom/swconfig.txt
    SYSTEM Execute Command On gNB
    ...    command=sed -i 's/#0x420028=1/0x420028=1/' /rom/swconfig.txt
    SYSTEM Execute Command On gNB
    ...    command=sed -i 's/#0x420028=1/0x420028=1/' /rom/swconfig.txt
    SYSTEM Execute Command On gNB
    ...    command=crasign /rom/swconfig.txt

Comment flag EnableL2RTInSystemd=1 with reboot
    SYSTEM Execute Command On gNB
    ...    command=sed -i 's/0x420028=1/#0x420028=1/' /rom/swconfig.txt
    SYSTEM Execute Command On gNB
    ...    command=crasign /rom/swconfig.txt
    SYSTEM Execute Command On gNB
    ...    command=reboot
    sleep  10s

Resolve flag EnableL2RTInSystemd=1
    SYSTEM Execute Command On gNB
    ...    command=sed -i 's/0x420028=0/0x420028=1/' /rom/swconfig.txt

Resolve flag EnableL2RTInSystemd=0
    SYSTEM Execute Command On gNB
    ...    command=sed -i 's/'0x420028=1'/'0x420028=0'/' /rom/swconfig.txt

Verify L2RT container is reachable left
    SYSTEM Open SSH Connection To Enb
    SSHLibrary.Write  bsh 1:1 lxc-ls
    SSHLibrary.Read Until  expected=0x1740
    SSHLibrary.Close Connection
#    csn.connect to    ${asik_addr}    ${asik_username}    ${asik_password}    alias=ASIK
#    sleep    5s
#    csn.connect to        192.168.253.21       ${asik_username}    ${asik_password}    proxy=ASIK  alias=lxcls
#    csn.send_command    command=lxc-ls    connection=lxcls
#    ${virtual_node}    csn.read output     connection=lxcls
#    Should contain  ${virtual_node}   0x1740
#    csn.disconnect    connection=lxcls
#    csn.disconnect    connection=ASIK

Verify L2RT container is reachable right
    SYSTEM Open SSH Connection To Enb
    SSHLibrary.Write  bsh 1:1 lxc-ls
    SSHLibrary.Read Until  expected=0x2740
    SSHLibrary.Close Connection
#    csn.connect to    ${asik_addr}    ${asik_username}    ${asik_password}    alias=ASIK
#    sleep    5s
#    csn.connect to        192.168.253.37       ${asik_username}    ${asik_password}    proxy=ASIK  alias=lxcls
#    csn.send_command    command=lxc-ls    connection=lxcls
#    ${virtual_node}    csn.read output     connection=lxcls
#    Should contain  ${virtual_node}   0x2740
#    csn.disconnect    connection=lxcls
#    csn.disconnect    connection=ASIK

Verify L2RT container is not reachable
    SYSTEM Open SSH Connection To Enb
    SSHLibrary.Write  bsh 1:1 lxc-ls
    SSHLibrary.Read Until  expected=0x1740
    SSHLibrary.Close Connection
#    csn.connect to    ${asik_addr}    ${asik_username}    ${asik_password}    alias=ASIK
#    sleep    5s
#    csn.connect to        192.168.253.21       ${asik_username}    ${asik_password}    proxy=ASIK  alias=lxcls
#    csn.send_command    command=lxc-ls    connection=lxcls
#    ${virtual_node}    csn.read output     connection=lxcls
#    Should not contain  ${virtual_node}   0x1740
#    csn.disconnect    connection=lxcls
#    csn.disconnect    connection=ASIK

Check that L2RT is in RUNNING state left
    ${result}=  Run  cat /tmp/btslog2/SYSLOG_*.LOG | grep "VirtualNode 0x1740 state changed to RUNNING(3)"
    Should contain  ${result}   VirtualNode 0x1740 state changed to RUNNING(3)

Check that L2RT is in RUNNING state right
    ${result}=  Run  cat /tmp/btslog2/SYSLOG_*.LOG | grep "VirtualNode 0x2740 state changed to RUNNING(3)"
    Should contain  ${result}   VirtualNode 0x2740 state changed to RUNNING(3)

Check that L2RT is not in RUNNING state
    ${result}=  Run  cat /tmp/btslog2/SYSLOG_2.LOG | grep "VirtualNode 0x1740 state changed to RUNNING(3)"
    Should not contain  ${result}   VirtualNode 0x1740 state changed to RUNNING(3)

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

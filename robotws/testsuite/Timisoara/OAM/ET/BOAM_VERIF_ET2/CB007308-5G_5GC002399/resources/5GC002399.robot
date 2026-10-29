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
Library      taf.transport.ssh   WITH NAME   csn

Resource    ../../resources/admin.robot
Resource    ../../resources/pretest_posttest.robot
Resource    ../../resources/system.robot


*** Variables ***
${LOGGING_ENB_SYSLOG}=           True
${LOGGING_IPHY_SYSLOG}=          True
${LOGGING_ADMIN_LOG}=            True
${LOGGING_ADMIN_INFOMODEL_LOG}=  True
${LOGGING_EMSSIM_LOG}=           True

${asoe_addr}                     192.168.255.1
${asoe_username}                 toor4nsn
${asoe_password}                 oZPS0POrRieRtu

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
    Check that L2RT is in RUNNING state
    Verify L2RT container is reachable
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
    Check that L2RT is in RUNNING state
    Verify L2RT container is reachable
    log to console  L2RT container is up and running


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

Comment flag EnableL2RTInSystemd=1 with reboot
    SYSTEM Execute Command On gNB
    ...    command=sed -i 's/0x420028=1/#0x420028=1/' /rom/swconfig.txt
    SYSTEM Execute Command On gNB
    ...    command=crasign /rom/swconfig.txt
    SYSTEM Execute Command On gNB
    ...    command=reboot
    sleep  10s

Verify L2RT container is reachable
    csn.connect to    ${asoe_addr}    ${asoe_username}    ${asoe_password}     alias=lxcls
    sleep    5s
    csn.send_command    command=lxc-ls     connection=lxcls
    ${virtual_node}    csn.read output     connection=lxcls
    Should contain  ${virtual_node}   0x151c
    Should contain  ${virtual_node}   0x151d
    csn.disconnect    connection=lxcls


Check that L2RT is in RUNNING state
    Wait Until Keyword Succeeds  600s  5s  Run  cat /tmp/btslog2/SYSLOG_*.LOG | grep "VirtualNode 0x151c state changed to RUNNING(3)"
    ${result}=  Run  cat /tmp/btslog2/SYSLOG_*.LOG | grep "VirtualNode 0x151c state changed to RUNNING(3)"
    Should contain  ${result}   VirtualNode 0x151c state changed to RUNNING(3)
    Wait Until Keyword Succeeds  600s  5s  Run  cat /tmp/btslog2/SYSLOG_*.LOG | grep "VirtualNode 0x151d state changed to RUNNING(3)"
    ${result}=  Run  cat /tmp/btslog2/SYSLOG_*.LOG | grep "VirtualNode 0x151d state changed to RUNNING(3)"
    Should contain  ${result}   VirtualNode 0x151d state changed to RUNNING(3)



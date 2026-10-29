*** Settings ***
Documentation
...    Author: David Brinzei (david.brinzei@nokia.com)
...    Maintainer: David Brinzei (david.brinzei@nokia.com)
...    Group in charge: MANO_SOAM3
...    References: doors
...    Feature Description: CB007273

Library        SSHLibrary   WITH NAME   ssh
Library        String
Library        Telnet
Library        OperatingSystem
Library        Process
Library        taf.sbts.oam.coam.admin
Library        taf.transport.ssh
Library        taf.sbts.oam.coam.admin.interface.admin   WITH NAME   taf_admin
Library        taf.selenium.gnb.oam.coam.classical      WITH NAME   taf_selenium
Library        taf.pdu    WITH NAME    pdu

Resource    ../../resources/admin.robot
Resource    ../../resources/pretest_posttest.robot
Resource    ../../resources/system.robot
Resource    ../../resources/fault_trigger.robot
Resource    ../../resources/selenium.robot

*** Variables ***
${LOGGING_ENB_SYSLOG}=             True
${LOGGING_IPHY_SYSLOG}=            True
${LOGGING_ADMIN_LOG}=              True
${LOGGING_ADMIN_INFOMODEL_LOG}=    True
${LOGGING_EMSSIM_LOG}=             True

${reasoningStatus_2080}=           stateInfo.reasoningStatus[?]="SrioHostLinkDown"
${reasoning_path_2080_left}=       /MRBTS-1/RAT-1/BTS_L-1/EQM_L-1/CABINET_L-1/SMOD_L-1/CCU_L-1
${reasoning_path_2080_right}=      /MRBTS-1/RAT-1/BTS_L-4/EQM_L-1/CABINET_L-1/SMOD_L-1/CCU_L-1

${date1}=        //*[@id="main-view"]/div/div[1]/div[2]/details-panel/div/wf-panel/wf-panel-section
${date2}=        /div/div/details-panel-content/div/alarms-details/div/div[2]/table/tbody[4]/tr[2]/td[2]/span
${cat1}=         //*[@id="main-view"]/div/div[1]/div[2]/details-panel/div/wf-panel/wf-panel-section
${cat2}=         /div/div/details-panel-content/div/alarms-details/div/div[2]/table/tbody[4]/tr[4]/td[2]/span
${load1}=        //*[@id="main-view"]/div/div[1]/div[2]/details-panel/div/wf-panel/wf-panel-section
${load2}=        /div/div/details-panel-content/div/alarms-details/div/div[2]/table/tbody[4]/tr[5]/td[2]/span
${comp1}=        //*[@id="main-view"]/div/div[1]/div[2]/details-panel/div/wf-panel/wf-panel-section
${comp2}=        /div/div/details-panel-content/div/alarms-details/div/div[2]/table/tbody[4]/tr[7]/td[2]/span

${scf_path}             /tmp/
${scf_name}             scf_file.xml
${SW_DESTINATION}       /home/ute

&{FAULT_4589}    fault_id=4589
...              alarm_id=7115
...              alarm_severity=Warning
...              alarm_description="Unit Power Reset"
...              alarm_resource=MRBTS-10797/EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-2

&{FAULT_4590}    fault_id=4589
...              alarm_id=7115
...              alarm_severity=Warning
...              alarm_description="Fault signature for crash or failure"
...              alarm_resource=MRBTS-10797/EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-2


${enb_hostname}                                          192.168.255.1
${enb_username}                                          toor4nsn
${enb_password}                                          oZPS0POrRieRtu
${SYSTEM_ENB_TRANSPORT_IP}                               192.168.255.129

*** Keywords ***
Check_Fault_4590
    SELENIUM Prepare Enviroment
    SELENIUM Login To Web Element Manager
    Sleep   10
    Wait Until Page Contains Element   locator=//div[@aria-describedby="admin.navigationBar.alarms.TITLE"]
    Sleep  3s
    Click Element                      locator=//div[@aria-describedby="admin.navigationBar.alarms.TITLE"]
    Mouse Over                         locator=//span[text()="Alarm Management"]
    Click Element                      locator=//span[text()="Active Alarms"]
    log to console   Start 3_Faults_4590_EFaultId_CrashOrFailureSignatureAl
    Kill RMOD process
    run keyword and continue on failure    ADMIN Check If Alarm Is Active With Timeout  fault_id=4590  timeout=300
    log to console  Alarm 4590 is active
    log to console  Get Fault Signature from WebEM
    Click Button        locator=//*[@id="main-view"]/div/div[1]/div[2]/details-panel/div/ui-button/button
    Click Element       locator=//td[text()="4590"]
    #Date
    Element Text Should Not Be
    ...    locator=${date1}${date2}
    ...    not_expected=-
    #Category
    Element Text Should Not Be
    ...    locator=${cat1}${cat2}
    ...    not_expected=-
    #Load Name
    Element Text Should Not Be
    ...    locator=${load1}${load2}
    ...    not_expected=-
    #Component
    Element Text Should Not Be
    ...    locator=${comp1}${comp2}
    ...    not_expected=-
    SeleniumLibrary.Close Browser
    SELENIUM Teardown Enviroment
    run keyword and continue on failure    ADMIN Check If Alarm Is Not Active With Timeout  fault_id=4590  timeout=300
    log to console  Alarm 4590 cleared
    Reboot BTS
    Sleep  300
    ADMIN INFOMODEL Check If BTS Is OnAir
    Sleep  120

Check_Fault_4589
    SELENIUM Prepare Enviroment
    SELENIUM Login To Web Element Manager
    Sleep   10
    Wait Until Page Contains Element   locator=//div[@aria-describedby="admin.navigationBar.alarms.TITLE"]
    Sleep  3s
    Click Element                      locator=//div[@aria-describedby="admin.navigationBar.alarms.TITLE"]
    Mouse Over                         locator=//span[text()="Alarm Management"]
    Click Element                      locator=//span[text()="Active Alarms"]
    log to console   Start 2_Faults_4589_ EFaultID_UnitPowerResetAl
    ADMIN INFOMODEL Check If BTS Is OnAir
    RMOD eCPRI Disconnection via PDU   10.255.3.74   3
    Sleep  60
    RMOD eCPRI Connection via PDU   10.255.3.74   3
    run keyword and continue on failure    ADMIN Check If Alarm Is Active With Timeout  fault_id=4589  timeout=300
    Click Element     locator=//td[text()="4589"]
    log to console  Alarm 4589 is active
    log to console  Get Fault Signature from WebEM
    Click Button    locator=//*[@id="main-view"]/div/div[1]/div[2]/details-panel/div/ui-button/button
    #Date
    Element Text Should Not Be
    ...    locator=${date1}${date2}
    ...    not_expected=-
    #Category
    Element Text Should Not Be
    ...    locator=${cat1}${cat2}
    ...    not_expected=-
    #Load Name
    Element Text Should Not Be
    ...    locator=${load1}${load2}
    ...    not_expected=-
    #Component
    Element Text Should Not Be
    ...    locator=${comp1}${comp2}
    ...    not_expected=-
    SeleniumLibrary.Close Browser
    SELENIUM Teardown Enviroment
    run keyword and continue on failure   ADMIN Check If Alarm Is Not Active With Timeout  fault_id=4589  timeout=300
    log to console  Alarm 4589 cleared
    Sleep  60
    ADMIN INFOMODEL Check If BTS Is OnAir
    Sleep  120

RMOD eCPRI Disconnection via PDU
     [Arguments]  ${host}   ${port}
    pdu.setup_pdu     host=${host}    model=EPC
    ${port_status}=   pdu.get_port_status    port=${port}
    should be equal    ${port_status}    off
    pdu.power_on     port=${port}

RMOD eCPRI Connection via PDU
    [Arguments]  ${host}   ${port}
    pdu.setup_pdu     host=${host}    model=EPC
    ${port_status}=   pdu.get_port_status    port=${port}
    should be equal    ${port_status}    on
    pdu.power_off     port=${port}

Kill RMOD process
    ssh.Open Connection    host=192.168.255.1    port=22    timeout=60
    ssh.Login    username=toor4nsn    password=oZPS0POrRieRtu    delay=1s
    ssh.Write    cat /ffs/run/config/FRIps.txt
    ${FRIps}=    ssh.Read Until    expected=>
    ${splitFRIps}=    Split string       ${FRIps}    separator=\;
    ${ip_rmod}=     Get from list       ${splitFRIps}     10
    ssh.Write    lxc-ls
    ${virtual_nodes}    ssh.Read Until    expected=>
    ${split_VN}=    Split string       ${virtual_nodes}    separator=\
    ${fhnet_container}=     Get from list       ${split_VN}     0
    ssh.Write    lxc-attach -n ${fhnet_container}
    ssh.Read Until    expected=>
    ssh.Write    rm /user/toor4nsn/.ssh/known_hosts
    ssh.Read Until    expected=>
    ssh.Write    ssh serviceuser@${ip_rmod}
    ssh.Read Until    expected=?
    ssh.Write    yes
    ssh.Read Until    expected=password:
    ssh.Write    Pl(FzaYj5~c5;q
    ssh.Read Until    expected=$
    ssh.Write    ps aux |grep eventcollector
    ${process_pid}=   ssh.Read Until    expected=$
    ${split_pid}=    Split string       ${process_pid}    separator=\
    ${pid}=       Get from list       ${split_pid}     0
    ssh.Write    sudo kill -11 ${pid}
    ssh.Read Until    expected=$
    ssh.Close Connection

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

Reboot BTS
    SYSTEM Open SSH Connection To Enb
    SSHLibrary.Write  reboot
    SSHLibrary.Close Connection


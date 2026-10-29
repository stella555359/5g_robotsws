*** Settings ***
Documentation
...    Author: Monika Szlovak (monika.szlovak@nokia.com)
...    Maintainer: Monika Szlovak (monika.szlovak@nokia.com)
...    Group in charge: MANO_SOAM3
...    References: doors
...    Feature Description: CB005750_5G_EB_ET_5GC000371
...    Sample execution: /opt/ute/python/bin/robot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log
...    -d results/ /home/ute/robotws5g/testsuite/OAM/ET/BTS_OAM_FMRECOV/CB005750_5G_EB_ET_5GC000371/general.robot

Library     SSHLibrary   WITH NAME   ssh
Library        String
Library        Telnet
Library        OperatingSystem
Library        Process
Library      taf.transport.ssh   WITH NAME   csn
Library      taf.sbts.oam.coam.admin.admin   WITH NAME   admin_cli

Resource    ../resources/keywords.robot
Resource    ../../resources/admin.robot
Resource    ../../resources/selenium.robot
Resource    ../../resources/pretest_posttest.robot
Resource    ../../resources/system.robot
Resource    ../../resources/AirPhone/resources/ute/coam.robot
Resource    ../../resources/fault_trigger.robot

*** Variables ***
${LOGGING_ENB_SYSLOG}=           True
${LOGGING_IPHY_SYSLOG}=          True
${LOGGING_ADMIN_LOG}=            True
${LOGGING_ADMIN_INFOMODEL_LOG}=  True
${LOGGING_EMSSIM_LOG}=           True

${LSS_addr}                     10.5.25.105
${LSS_username}                 coam
${LSS_password}                 zO&n1W*ktp7

${reasoning_path}=            /MRBTS-1/RAT-1/BTS_L-1/EQM_L-1/RMOD_L-1/RU_L-1

${scf_path}             /tmp/
${scf_name}             scf_file.xml

${delta_LSS_10_onFaultDet_activate}=        ${CURDIR}/../resources/Delta_LSS_10_onFaultDet_activate.json
${delta_LSS_10_onAlarmSend_activate}=       ${CURDIR}/../resources/Delta_LSS_10_onAlarmSend_activate.json
${delta_LSS_6450_onFaultDet_activate}=      ${CURDIR}/../resources/Delta_LSS_6450_onFaultDet_activate.json
${delta_LSS_deactivate}=                    ${CURDIR}/../resources/Delta_LSS_deactivate.json

${critical_process} =           HWRClimateSExe
${BTS_metadata}=                BTS1_*_metadata.txt

${host}=                192.168.200.1
${port}=                22
${username_ute}=        toor4nsn
${password_ute}=        oZPS0POrRieRtu

${LSS_USERNAME_INPUT}=                  //*[@id="username"]
${LSS_PASS_INPUT}=                      //*[@id="newPassword"]
${LSS_CONFIRM_PASS_INPUT}=              //*[@id="confirmPassword"]

*** Keywords ***
CB005750-5G-EB-ET_5GC000371-Snapshot_collection_is_triggered_by_radio_recovery
    wait until keyword succeeds  300  60  Verify Coam BTS is at least Configured
    wait until keyword succeeds  300  60  Verify Coam Radio is Online
    wait until keyword succeeds  300  60  Verify Coam Cell is Configured
    Remove Snapshot from LSS server
    ADMIN Perform Delta Recommissioning                 delta_file=${delta_LSS_10_onFaultDet_activate}
    ...                                                 skip_parameter_relation_errors=True
    Sleep  30s
    log to console  trigger fault 10
    Restart IPHY
    wait until keyword succeeds  360  60  Check if fault is in active raw alarm  0010   EFaultId_NoConnectionToUnitAl
    SYSTEM Wait For Host Is Reachable With Ping  192.168.200.1
    wait until keyword succeeds  360  60  Check if fault is not in active raw alarm  0010   EFaultId_NoConnectionToUnitAl
    ADMIN Check If Alarm Is Not Active  fault_id=10
    Check If Snapshot Exist On LSS
    ADMIN Perform Delta Recommissioning                 delta_file=${delta_LSS_deactivate}
    ...                                                 skip_parameter_relation_errors=True
    [Teardown]    run keyword and ignore error  Remove Snapshot from LSS server

CB005750-5G-EB-ET_5GC000371-Snapshot_collection_is_triggered_by_autonomous_radio_recovery
    wait until keyword succeeds  300  60  Verify Coam BTS is at least Configured
    wait until keyword succeeds  300  60  Verify Coam Radio is Online
    wait until keyword succeeds  300  60  Verify Coam Cell is Configured
    Configure LSS in WebEM
    Remove Snapshot from LSS server
    ADMIN Perform Delta Recommissioning                 delta_file=${delta_LSS_10_onAlarmSend_activate}
    ...                                                 skip_parameter_relation_errors=True
    Sleep  30s
    log to console  trigger fault 10
    Restart IPHY
    wait until keyword succeeds  360  60  Check if fault is in active raw alarm  0010   EFaultId_NoConnectionToUnitAl
    SYSTEM Wait For Host Is Reachable With Ping  192.168.200.1
    wait until keyword succeeds  360  60  Check if fault is not in active raw alarm  0010   EFaultId_NoConnectionToUnitAl
    ADMIN Check If Alarm Is Not Active  fault_id=10
    Check If Snapshot Exist On LSS
    ADMIN Perform Delta Recommissioning                 delta_file=${delta_LSS_deactivate}
    ...                                                 skip_parameter_relation_errors=True
    [Teardown]    run keyword and ignore error  Remove Snapshot from LSS server

CB005750-5G-EB-ET_5GC000371-Collect_logs_after_FCT_Critical_Process_Crash
    wait until keyword succeeds  300  60  Verify Coam BTS is at least Configured
    wait until keyword succeeds  300  60  Verify Coam Radio is Online
    wait until keyword succeeds  300  60  Verify Coam Cell is Configured
    Configure LSS in WebEM
    Remove Snapshot from LSS server
    ADMIN Perform Delta Recommissioning                 delta_file=${delta_LSS_6450_onFaultDet_activate}
    ...                                                 skip_parameter_relation_errors=True
    Sleep  30s
    log to console  trigger fault 6450
    Kill process '${critical_process}' on FCT
    SYSTEM Wait Till Iphy Will Not Be Pingable For A Given Period
    SYSTEM Wait For Host Is Reachable With Ping  192.168.200.1
    wait until keyword succeeds  360  60  Verify Coam BTS is at least Configured
    Check if Snapshot is collected on LSS
    ADMIN Perform Delta Recommissioning                 delta_file=${delta_LSS_deactivate}
    ...                                                 skip_parameter_relation_errors=True
    [Teardown]    run keyword and ignore error  Remove Snapshot from LSS server

CB005750-5G-EB-ET_5GC000371-Fault_4527_RF_crash_logs_in_technical_log_collection
    log to console  Start test fault 4527
    Wait Until Keyword Succeeds
    ...    600
    ...    60
    ...    ADMIN INFOMODEL Check If BTS Is OnAir
    Perform activate service account synchronization to RU devices
    ADMIN Check If Alarm Is Not Active  fault_id=4527
    Remove Snapshot from LSS server
    Perform 4527 to LSS activation
    Sleep  3s
    log to console  trigger fault 4527
    Trigger fault 4527
    ADMIN Check If Alarm Is Active With Timeout  fault_id=4527   timeout=300
    Check if Snapshot is collected on LSS
    Sleep   120
    [Teardown]    run keyword and ignore error  Remove Snapshot from LSS server

#---------------------------------------------------------------------
Restart IPHY
    SSHLibrary.Open Connection    host=${host}    port=${port}    timeout=60
    SSHLibrary.Login    username=${username_ute}    password=${password_ute}    delay=1s
    SSHLibrary.Write    ddal -s ddal_reboot_graceful
    SSHLibrary.Read Until    expected=>
    SSHLibrary.Close Connection

Check if fault is not in active raw alarm
      [Arguments]    ${fault_id}
    ...              ${EFaultId}
    ${RawAlarms}=   taf.sbts.oam.coam.admin.get raw alarm history file
    ${RawAlamrsActive}=  fetch from left  ${RawAlarms}  Inactive faults
    Should not contain  ${RawAlamrsActive}  (${fault_id})
    Should not contain  ${RawAlamrsActive}  ${EFaultId}

Check if fault is in active raw alarm
      [Arguments]    ${fault_id}
    ...              ${EFaultId}
    ${RawAlarms}=   taf.sbts.oam.coam.admin.get raw alarm history file
    ${RawAlamrsActive}=  fetch from left  ${RawAlarms}  Inactive faults
    Should contain  ${RawAlamrsActive}  (${fault_id})
    Should contain  ${RawAlamrsActive}  ${EFaultId}

Remove Snapshot from LSS server
    Set Suite Variable    ${snapshot_path_LSS}    /opt/coam/Snapshot_MRBTS-1_${OUT_ADMIN_BTS_NAME}*
    csn.connect to    ${LSS_addr}    ${LSS_username}    ${LSS_password}    alias=LSS
    sleep    2s
    csn.send_command    command=rm -rf ${snapshot_path_LSS}  connection=LSS
    csn.disconnect    connection=LSS

Check if Snapshot is collected on LSS
    Set Suite Variable    ${snapshot_LSS}    Snapshot_MRBTS-1_${OUT_ADMIN_BTS_NAME}
    csn.connect to    ${LSS_addr}    ${LSS_username}    ${LSS_password}    alias=LSS
    sleep    2s
    csn.send_command    command=ls -l /opt/coam/   connection=LSS
    ${snap_exists}    csn.read output    connection=LSS
    Should contain  ${snap_exists}  ${snapshot_LSS}  connection=LSS
    csn.send_command    command=find ${snapshot_LSS}* | wc -l   connection=LSS
    ${snap_list}    csn.read output    connection=LSS
    ${snap_list}    convert to integer  ${snap_list}
    should be true      ${snap_list}>=1
    csn.disconnect    connection=LSS

Check if Snapshot is not collected on LSS
    Set Suite Variable    ${snapshot_LSS}    Snapshot_MRBTS-1_${OUT_ADMIN_BTS_NAME}
    csn.connect to    ${LSS_addr}    ${LSS_username}    ${LSS_password}    alias=LSS
    sleep    2s
    csn.send_command    command=ls -l /opt/coam/   connection=LSS
    ${snap_exists}    csn.read output    connection=LSS
    Should not contain  ${snap_exists}  ${snapshot_LSS}  connection=LSS
    csn.disconnect    connection=LSS

Wait until BTS_metadata.txt exists
    wait until keyword succeeds  300  30  Check if BTS_metadata.txt exists

Check if BTS_metadata.txt exists
    Set Suite Variable    ${snapshot_LSS}    Snapshot_MRBTS-1_${OUT_ADMIN_BTS_NAME}
    csn.connect to    ${LSS_addr}    ${LSS_username}    ${LSS_password}    alias=LSS
    sleep    2s
    csn.send_command    command=find ${snapshot_LSS}*/*metadata.txt   connection=LSS
    ${snap_list}    csn.read output    connection=LSS
    Set Suite Variable    ${BTS_metadata}    metadata.txt
    should contain  ${snap_list}  ${BTS_metadata}
    csn.disconnect    connection=LSS

Check If Snapshot Collection Is Ongoing
    Sleep   20
    run keyword and expect error  *Request rejected as another snapshot collection is ongoing*  ADMIN Collect Snapshot

Check If Snapshot Exist On LSS
    log to console  check if snapshot exist on LSS
    Check if Snapshot is collected on LSS
    Wait until BTS_metadata.txt exists

5GC000371-Test Postconditions
    Log    \n+ Common 5GC001542-RA Test Postconditions With Reset Site started    console=yes
    run keyword and ignore error  Remove Snapshot from LSS server
    admin.ADMIN Reset Site
    LOGGING Stop Logging
    Log Variables
    Log    \n+ Common Test Postconditions With Reset Site finished    console=yes

Kill process '${process_name}' on FCT
    ${process_pid}=   SYSTEM Execute Command On gNB
    ...    command=ps -ef | grep -i "${process_name}" | egrep -v "grep|bash" | awk '{print $2}'
    @{list_process_pid}=  split to lines  ${process_pid}
    SYSTEM Execute Command On gNB
#    ...    command=kill -11 ${process_pid}
    ...    command=kill -11 @{list_process_pid}[0]

Trigger fault 4527
    ssh.Open Connection    host=192.168.255.1    port=22    timeout=60
    ssh.Login    username=toor4nsn    password=oZPS0POrRieRtu    delay=1s
    ssh.Write    cat /ffs/run/config/FRIps.txt
    ${FRIps}=    ssh.Read Until    expected=>
    ${splitFRIps}=    Split string       ${FRIps}    separator=\;
    ${ip_rmod}=     Get from list       ${splitFRIps}     2
    ssh.Write    lxc-ls
    ${virtual_nodes}    ssh.Read Until    expected=>
    ${split_VN}=    Split string       ${virtual_nodes}    separator=\
    ${fhnet_container}=     Get from list       ${split_VN}     0
    ssh.Write    lxc-attach -n ${fhnet_container}
    ssh.Read Until    expected=>
#    ssh.Write    ssh root@${ip_rmod}
    ssh.Write    ssh serviceuser@${ip_rmod}
    ssh.Read Until    expected=?
    ssh.Write    yes
    ssh.Read Until    expected=password:
#    ssh.Write    w@=EIj7P6R0bVy85OjCVa^ho&8
    ssh.Write    Pl(FzaYj5~c5;q
#    ssh.Read Until    expected=#
    ssh.Read Until    expected=$
    ssh.Write    ps -ef | grep -i "CCSDaemonExe" | egrep -v "grep|bash" | awk '{print $1}'
#    ${process_pid}=   ssh.Read Until    expected=#
    ${process_pid}=   ssh.Read Until    expected=$
    ssh.Write    sudo kill -11 ${process_pid}
#    ssh.Read Until    expected=#
    ssh.Read Until    expected=$
    ssh.Close Connection

Perform 4527 to LSS activation
    admin_cli.perform_parameter_recommissioning    dist_name=MRBTS-${OUT_MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    ...                                            parameter=diagSnapDestination
    ...                                            operation=update
    ...                                            value=lss
    ...                                            skip_parameter_relation_errors=True
    ${list_param_fault}=    Create Dictionary   faultNumber=4527
    ...                                         triggerType=onFaultDetection
    @{list_fault}=    create list    ${list_param_fault}
    admin_cli.perform_parameter_recommissioning    dist_name=MRBTS-${OUT_MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    ...                                            parameter=faultSnapshotTriggers
    ...                                            operation=update
    ...                                            value=@{list_fault}
    ...                                            skip_parameter_relation_errors=True
    ${list_param_lss}=    Create Dictionary   lssIPaddress=10.5.25.105
    ...                                       lssPortNo=22
    @{list_lss}=    create list    ${list_param_lss}
    admin_cli.perform_parameter_recommissioning    dist_name=MRBTS-${OUT_MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    ...                                            parameter=lssConfig
    ...                                            operation=update
    ...                                            value=@{list_lss}
    ...                                            skip_parameter_relation_errors=True

    Restart admin connection

Perform activate service account synchronization to RU devices
    admin_cli.perform_parameter_recommissioning    dist_name=MRBTS-${OUT_MRBTS_ID}/MNL-1/MNLENT-1/SECADM-1
    ...                                            parameter=actSyncToRU
    ...                                            operation=update
    ...                                            value=true
    ...                                            skip_parameter_relation_errors=True

Restart admin connection
    ADMIN Teardown Admin
    ADMIN Setup Admin

Configure LSS in WebEM
    SELENIUM Prepare Enviroment
    SELENIUM Login To Web Element Manager
    Sleep   10
    Wait Until Page Contains Element    locator=//div[@aria-describedby="admin.navigationBar.diagnostic.TITLE"]
    Sleep  3s
    Click Element    locator=//div[@aria-describedby="admin.navigationBar.diagnostic.TITLE"]
    Mouse Over       locator=//span[text()="Snapshot"]
    Click Element    locator=//span[text()="LSS User Configuration"]
    SELENIUM Input Text in Visible Element
    ...    locator=//*[@id="username"]
    ...    text=${LSS_username}
    SELENIUM Input Text in Visible Element
    ...    locator=//*[@id="newPassword"]
    ...    text=${LSS_password}
    SELENIUM Input Text in Visible Element
    ...    locator=//*[@id="confirmPassword"]
    ...    text=${LSS_password}
    Sleep   3s
    Click Button    locator=//*[@id="p-tabpanel-2"]/lss-user-configuration/execution-bar/div/save-lss-button/div/p-button/button
    Wait Until Element Is Visible
    ...    locator=//span[contains(text(),"Save succeeded")]
    Close Browser
    SELENIUM Teardown Enviroment

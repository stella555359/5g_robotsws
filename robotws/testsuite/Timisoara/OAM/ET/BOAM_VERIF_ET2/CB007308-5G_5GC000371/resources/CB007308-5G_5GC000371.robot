*** Settings ***
Documentation
...    Author: Monika Szlovak (monika.szlovak@nokia.com)
...    Maintainer: Monika Szlovak (monika.szlovak@nokia.com)
...    Group in charge: MANO_SOAM3
...    References: doors
...    Feature Description: CB007308_5G_5GC000371

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

${scf_2_11_UTESRAN201}        /home/ute/MN/UTE/robotws/custom-config/2_11_UTESRAN201/SCFC.xml

*** Keywords ***
CB007308-5G_5GC000371-Snapshot_collection_is_triggered_by_radio_recovery
    wait until keyword succeeds  300  60  Verify Coam BTS is at least Configured
#    wait until keyword succeeds  300  60  Verify Coam Radio is Online
#    wait until keyword succeeds  300  60  Verify Coam Cell is Configured
    run keyword and ignore error  Remove Snapshot from LSS server
    ADMIN Perform Delta Recommissioning                 delta_file=${delta_LSS_10_onFaultDet_activate}
    ...                                                 skip_parameter_relation_errors=True
    Sleep  30s

    log to console  trigger fault 10
    SYSTEM Execute Command On IPHY  ddal -s ddal_reboot_graceful
    SYSTEM Wait Till Iphy Will Not Be Pingable For A Given Period
    wait until keyword succeeds  360  60  Check if fault is in active raw alarm  0010   EFaultId_NoConnectionToUnitAl
    SYSTEM Wait For Host Is Reachable With Ping  192.168.200.1

    wait until keyword succeeds  360  60  Check if fault is not in active raw alarm  0010   EFaultId_NoConnectionToUnitAl
    ADMIN Check If Alarm Is Not Active  fault_id=10


    log to console  check if snapshot exist on LSS
    Check if Snapshot is collected on LSS
    Wait until BTS_metadata.txt exists
    Check if BTS_metadata.txt exists
    ADMIN Perform Delta Recommissioning                 delta_file=${delta_LSS_deactivate}
    ...                                                 skip_parameter_relation_errors=True
    run keyword and ignore error  Remove Snapshot from LSS server

CB007308-5G_5GC000371-Snapshot_collection_is_triggered_by_autonomous_radio_recovery
    wait until keyword succeeds  300  60  Verify Coam BTS is at least Configured
#    wait until keyword succeeds  300  60  Verify Coam Radio is Online
#    wait until keyword succeeds  300  60  Verify Coam Cell is Configured
    run keyword and ignore error  Remove Snapshot from LSS server
    ADMIN Perform Delta Recommissioning                 delta_file=${delta_LSS_10_onAlarmSend_activate}
    ...                                                 skip_parameter_relation_errors=True
    Sleep  30s

    log to console  trigger fault 10
    SYSTEM Execute Command On IPHY  ddal -s ddal_reboot_graceful
    SYSTEM Wait Till Iphy Will Not Be Pingable For A Given Period
    wait until keyword succeeds  360  60  Check if fault is in active raw alarm  0010   EFaultId_NoConnectionToUnitAl
    SYSTEM Wait For Host Is Reachable With Ping  192.168.200.1

    wait until keyword succeeds  360  60  Check if fault is not in active raw alarm  0010   EFaultId_NoConnectionToUnitAl
    ADMIN Check If Alarm Is Not Active  fault_id=10


    log to console  check if snapshot exist on LSS
    Check if Snapshot is collected on LSS
    Wait until BTS_metadata.txt exists
    Check if BTS_metadata.txt exists
    ADMIN Perform Delta Recommissioning                 delta_file=${delta_LSS_deactivate}
    ...                                                 skip_parameter_relation_errors=True
    run keyword and ignore error  Remove Snapshot from LSS server

CB007308-5G_5GC000371-Collect_logs_after_FCT_Critical_Process_Crash
    wait until keyword succeeds  300  60  Verify Coam BTS is at least Configured
#    wait until keyword succeeds  300  60  Verify Coam Radio is Online
#    wait until keyword succeeds  300  60  Verify Coam Cell is Configured
    run keyword and ignore error  Remove Snapshot from LSS server
    ADMIN Perform Delta Recommissioning                 delta_file=${delta_LSS_6450_onFaultDet_activate}
    ...                                                 skip_parameter_relation_errors=True
    Sleep  30s

    log to console  trigger fault 6450
    Kill process '${critical_process}' on FCT
    SYSTEM Wait Till Iphy Will Not Be Pingable For A Given Period
    SYSTEM Wait For Host Is Reachable With Ping  192.168.200.1
    wait until keyword succeeds  360  60  Verify Coam BTS is at least Configured
    log to console  check if snapshot exist on LSS
    Check if Snapshot is collected on LSS
    ADMIN Perform Delta Recommissioning                 delta_file=${delta_LSS_deactivate}
    ...                                                 skip_parameter_relation_errors=True
    run keyword and ignore error  Remove Snapshot from LSS server

CB007308-5G_5GC000371-Fault_4527_RF_crash_logs_in_technical_log_collection
    log to console  Start test fault 4527
    ${onair}    Run Keyword And Return Status    Wait Until Keyword Succeeds
    ...    600
    ...    60
    ...    ADMIN INFOMODEL Check If BTS Is OnAir
    Run Keyword Unless   ${onair}   Wait Until Keyword Succeeds  300  60  ADMIN INFOMODEL Check If BTS Is Configured
    Get Version Of Active SW
    Configure LSS in WebEM
    Perform activate service account synchronization to RU devices
    ADMIN Check If Alarm Is Not Active  fault_id=4527
    run keyword and ignore error  Remove Snapshot from LSS server
    Perform 4527 to LSS activation
    Sleep  3s
    log to console  trigger fault 4527
    Trigger fault 4527
    ADMIN Check If Alarm Is Active With Timeout  fault_id=4527   timeout=910
    ADMIN Check If Alarm Is Not Active With Timeout  fault_id=4527   timeout=910
    Perform 4527 to LSS deactivation
    log to console  check if snapshot exist on LSS
    Check if Snapshot is collected on LSS
    Wait until BTS_metadata.txt exists
    [Teardown]    run keyword and ignore error  Remove Snapshot from LSS server

#---------------------------------------------------------------------
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
    Sleep   10
    run keyword and expect error  *Request rejected as another snapshot collection is ongoing*  ADMIN Collect Snapshot

Check If Snapshot Exist On LSS
    log to console  check if snapshot exist on LSS
    Check if Snapshot is collected on LSS
    Wait until BTS_metadata.txt exists
    Check if BTS_metadata.txt exists

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
    ssh.Write    rm /user/toor4nsn/.ssh/known_hosts
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
#    ssh.Write    ps -ef | grep -i "CCSDaemonExe" | egrep -v "grep|bash" | awk '{print $1}'
    ssh.Write    ps -ef | grep -i "/usr/bin/syscon" | egrep -v "grep|bash" | awk '{print $1}'
#    ${process_pid}=   ssh.Read Until    expected=#
    ${process_pids}=   ssh.Read Until    expected=$
    ${split_pid}=    Split string       ${process_pids}    separator=\r\r\n
    ${process_pid}=     Get from list       ${split_pid}     0
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

Perform 4527 to LSS deactivation
    admin_cli.perform_parameter_recommissioning    dist_name=MRBTS-${OUT_MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    ...                                            parameter=diagSnapDestination
    ...                                            operation=update
    ...                                            value=netact
    ...                                            skip_parameter_relation_errors=True
    Restart admin connection
#    admin.ADMIN Reset Site
#    wait until keyword succeeds  900  60  Verify Coam BTS is at least Configured

Restart admin connection
    ADMIN Teardown Admin
    ADMIN Setup Admin

Perform activate service account synchronization to RU devices
    admin_cli.perform_parameter_recommissioning    dist_name=MRBTS-${OUT_MRBTS_ID}/MNL-1/MNLENT-1/SECADM-1
    ...                                            parameter=actSyncToRU
    ...                                            operation=update
    ...                                            value=true
    ...                                            skip_parameter_relation_errors=True

2_11_UTESRAN201 TL Preparation
    PREPOST Setup Admin
    ADMIN Perform Commissioning
    ...     scf_file=${scf_2_11_UTESRAN201}   skip_parameter_relation_errors=${True}
    Wait Until Keyword Succeeds  600  10   ADMIN Check BTS Configured
    Sleep   30
    Log To Console  Fault ID23 Checking...
    ${result}   Run Keyword and Return Status    ADMIN Check If Alarm Is Active  fault_id=23
    BuiltIn.Run Keyword If  '${result}' == 'True'   Run Keywords   Log To Console  Fault ID23 found. Start RF Software Update
    ...     AND     ADMIN Download And Update Current Software
    ...     ELSE    Log To Console  Fault ID23 not found. Wait for onAir State
    ADMIN Teardown Admin

UTE TL Preparation
    [Documentation]  Keyword used for setting up local 5G TLs to onAir state, as UTE reserve it only to sw_upload state
    PREPOST Setup Admin
    ADMIN Change R&D Port Status    status=True
    @{status}   Run Keyword and Ignore Error    ADMIN Check BTS onair
    Run Keyword If  '@{status}[0]' == 'FAIL'   Run Keyword  CB007308-5G_5GC000371.Configured_SwDownload_SwUpdate_OnAir
    ...     ELSE    Log To Console  --- BTS already onAir ---
    PREPOST Teardown Admin

Configured_SwDownload_SwUpdate_OnAir
    ADMIN Check BTS Not Commisioned
    Get TL Hostname
    Get Software Release
    ADMIN Perform Commissioning
    ...   scf_file=/home/ute/MN/UTE/robotws/custom-config/Timisoara/${tl_hostname}/${sw_release}/${tl_hostname}_SCF.xml
    ...   skip_parameter_relation_errors=${True}
    ${configured}   Run Keyword and Return Status
    ...    BuiltIn.Wait Until Keyword Succeeds  600  30   ADMIN Check BTS Configured
    Run Keyword If  '${configured}' == 'True'  Sleep  180
    Run Keyword Unless   ${configured}   Run Keywords   admin.ADMIN Reset Site
    ...    AND     BuiltIn.Wait Until Keyword Succeeds  600  30   ADMIN Check BTS Configured
    ...    AND     Sleep  180
    Log To Console  Fault ID23 Checking...
    ${result}   Run Keyword and Return Status    ADMIN Check If Alarm Is Active  fault_id=23
    BuiltIn.Run Keyword If  '${result}' == 'True'   Run Keywords
    ...    Log To Console  Fault ID23 found. Start RF Software Update
    ...     AND     ADMIN Download And Update Current Software
    ...     ELSE    Log To Console  Fault ID23 not found.
    ${onair}   Run Keyword and Return Status
    ...    BuiltIn.Wait Until Keyword Succeeds  600  30   ADMIN Wait Until BTS OnAir
    Run Keyword Unless   ${onair}   Run Keywords   admin.ADMIN Reset Site
    ...    AND     BuiltIn.Wait Until Keyword Succeeds  600  30   ADMIN Wait Until BTS OnAir

Get Version Of Active SW
    ${split_build}=    Split string       ${OUT_ACTIVE_SW}    separator=\_
    ${version}=       Get from list    ${split_build}    0
    Set Suite Variable   ${version}

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
    ...    locator=//span[contains(text(),"Save succeeded")]   timeout=20
    Close Browser
    SELENIUM Teardown Enviroment

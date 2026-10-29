*** Settings ***
Documentation
...    Author: Monika Szlovak (monika.szlovak@nokia.com)
...    Maintainer: Monika Szlovak (monika.szlovak@nokia.com)
...    Group in charge: MANO_SOAM3
...    References: doors
...    Feature Description: CB007308_5G_5GC000371

Library        String
Library        Telnet
Library        OperatingSystem
Library        Process
Library        taf.transport.ssh   WITH NAME   csn
Library        SSHLibrary   WITH NAME   ssh

Resource    ../resources/keywords.robot
Resource    ../../../resources/admin.robot
Resource    ../../../resources/pretest_posttest.robot
Resource    ../../../resources/system.robot
Resource    ../../../resources/AirPhone/resources/ute/coam.robot
Resource    ../../../resources/fault_trigger.robot
Resource    ../../../resources/selenium.robot

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
CB007308-5G_5GC000371-Snapshot_collection_is_triggered_by_radio_recovery
    wait until keyword succeeds  300  60  Verify Coam BTS is at least Configured
#    wait until keyword succeeds  300  60  Verify Coam Radio is Online
#    wait until keyword succeeds  300  60  Verify Coam Cell is Configured
    Configure LSS in WebEM
    run keyword and ignore error  Remove Snapshot from LSS server
    ADMIN Perform Delta Recommissioning                 delta_file=${delta_LSS_10_onFaultDet_activate}
    ...                                                 skip_parameter_relation_errors=True
    Sleep  30s

    log to console  trigger fault 10
    Restart IPHY
#   SYSTEM Execute Command On IPHY  ddal -s ddal_reboot_graceful
#   SYSTEM Wait Till Iphy Will Not Be Pingable For A Given Period
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
    Configure LSS in WebEM
    run keyword and ignore error  Remove Snapshot from LSS server
    ADMIN Perform Delta Recommissioning                 delta_file=${delta_LSS_10_onAlarmSend_activate}
    ...                                                 skip_parameter_relation_errors=True
    Sleep  30s

    log to console  trigger fault 10
    Restart IPHY
#   SYSTEM Execute Command On IPHY  ddal -s ddal_reboot_graceful
#   SYSTEM Wait Till Iphy Will Not Be Pingable For A Given Period
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
    Configure LSS in WebEM
    run keyword and ignore error  Remove Snapshot from LSS server
    ADMIN Perform Delta Recommissioning                 delta_file=${delta_LSS_6450_onFaultDet_activate}
    ...                                                 skip_parameter_relation_errors=True
    Sleep  30s

    log to console  trigger fault 6450
    Kill process '${critical_process}' on FCT
#    SYSTEM Wait Till Iphy Will Not Be Pingable For A Given Period
#    SYSTEM Wait For Host Is Reachable With Ping  192.168.200.1
    wait until keyword succeeds  600  60  Verify Coam BTS is at least Configured
    log to console  check if snapshot exist on LSS
    wait until keyword succeeds  600  60  Check if Snapshot is collected on LSS
#    ADMIN Perform Delta Recommissioning                 delta_file=${delta_LSS_deactivate}
#    ...                                                 skip_parameter_relation_errors=True
    run keyword and ignore error  Remove Snapshot from LSS server
   

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
    Sleep  10s

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
    SeleniumLibrary.Close Browser
    SELENIUM Teardown Enviroment

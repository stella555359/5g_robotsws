*** Settings ***
Documentation
...    Author: Andreea-Oana Zaharia
...    Maintainer: Andreea-Oana Zaharia
...    Test Description: The purpose of this test case is to check if technical logs are automatically triggered after an
...                         unexpected loss of comunication between the baseband module and the RF module.

Library     SSHLibrary   WITH NAME   ssh
Library        String
Library        Telnet
Library        OperatingSystem
Library        Process
Library      taf.transport.ssh   WITH NAME   csn
Library      taf.sbts.oam.coam.admin.admin   WITH NAME   admin_cli

Resource    ../../resources/admin.robot
Resource   ../../resources/admin_infomodel.robot
Resource    ../../resources/pretest_posttest.robot
Resource    ../../resources/system.robot
Resource    ../../resources/selenium.robot
Resource    ../../resources/fault_trigger.robot
#Resource    ../resources/keyword.robot

*** Variables ***
${LSS_addr}                     10.5.25.105
${LSS_username}                 coam
${LSS_password}                 zO&n1W*ktp7

${delta_LSS_activate}=                    ${CURDIR}/../resources/delta_lss_radio_loss_connection.json
${delta_LSS_deactivate}=                  ${CURDIR}/../resources/delta_lss_deactivate.json

${SW_DESTINATION}             /home/ute
*** Keywords ***
[1.0] 2. Snapshot collection is triggered by radio recovery after unexpected loss of comunication
    run keyword and ignore error   Wait Until Keyword Succeeds  600  60  ADMIN INFOMODEL Check If BTS Is OnAir
    log to console    Snapshot collection is triggered by radio recovery after unexpected loss of comunication
    run keyword and ignore error  Remove Snapshot from LSS server
    # !!! this test no need lss config in webem !!!
    ADMIN Perform Delta Recommissioning                 delta_file=${delta_LSS_activate}
    ...                                                 skip_parameter_relation_errors=True
    Sleep  30s
    log to console   trigger radio recovery
    Trigger unexpected radio recovery
    log to console   check fault 10
    wait until keyword succeeds  60  5  system.SYSTEM Check if fault is in active raw alarm  0010   EFaultId_NoConnectionToUnitAl
    admin.ADMIN Check If Alarm Is Active  fault_id=10
    wait until keyword succeeds  180  10  system.SYSTEM Check if fault is not in active raw alarm  0010   EFaultId_NoConnectionToUnitAl
    admin.ADMIN Check If Alarm Is Not Active  fault_id=10
    Sleep    70s
    log to console   check snapshot to LSS server
    Check if Snapshot is collected on LSS
    Wait until BTS_metadata.txt exists
    ADMIN Perform Delta Recommissioning                 delta_file=${delta_LSS_deactivate}
    ...                                                 skip_parameter_relation_errors=True
    run keyword and ignore error  Wait Until Keyword Succeeds  600  60  ADMIN INFOMODEL Check If BTS Is OnAir
    [Teardown]    run keyword and ignore error  Remove Snapshot from LSS server

#....................................................................................
Trigger unexpected radio recovery
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
    ssh.Write    ssh root@${ip_rmod}
    ssh.Read Until    expected=?
    ssh.Write    yes
    ssh.Read Until    expected=password:
#    ssh.Write    w@=EIj7P6R0bVy85OjCVa^ho&8
#    ssh.Write    Pl(FzaYj5~c5;q
    ssh.Write    root
    ssh.Read Until    expected=#
    ssh.Write    reboot
    ssh.Close Connection

Remove Snapshot from LSS server
    Set Suite Variable    ${snapshot_path_LSS}    /opt/coam/Snapshot_MRBTS-10658_${OUT_ADMIN_BTS_NAME}*
    csn.connect to    ${LSS_addr}    ${LSS_username}    ${LSS_password}    alias=LSS
    sleep    2s
    csn.send_command    command=rm -rf ${snapshot_path_LSS}  connection=LSS
    csn.disconnect    connection=LSS

Check if Snapshot is collected on LSS
    Set Suite Variable    ${snapshot_LSS}    Snapshot_MRBTS-10658_${OUT_ADMIN_BTS_NAME}
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

Wait until BTS_metadata.txt exists
    wait until keyword succeeds  300  30  Check if BTS_metadata.txt exists

Check if BTS_metadata.txt exists
    Set Suite Variable    ${snapshot_LSS}    Snapshot_MRBTS-10658_${OUT_ADMIN_BTS_NAME}
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





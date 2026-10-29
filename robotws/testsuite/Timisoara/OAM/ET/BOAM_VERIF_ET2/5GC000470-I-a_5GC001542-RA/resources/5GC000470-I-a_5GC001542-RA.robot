*** Settings ***
Documentation
...    Author: Ioana-Andreea Sandu-Andrei (ioana.sandu-andrei@nokia.com)
...    Maintainer: Ioana-Andreea Sandu-Andrei (ioana.sandu-andrei@nokia.com)
...    Group in charge: MANO_SOAM3
...    References: doors
...    Feature Description:5GC000470-I-a_5GC001542-RA
...    Sample execution: /opt/ute/python/bin/pybot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log
...    -d results/ /home/ute/robotws5g/testsuite/OAM/ET/BTS_OAM_FMRECOV/5GC000470-I-a_5GC001542-RA/general.robot


Library        String
Library        Telnet
Library        OperatingSystem
Library        Process
Library      taf.transport.ssh   WITH NAME   csn

Resource    ../resources/keywords.robot
Resource    ../../resources/admin.robot
Resource    ../../resources/pretest_posttest.robot
Resource    ../../resources/system.robot
Resource    ../../resources/AirPhone/resources/ute/coam.robot


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

${delta_LSS_10_onFaultDet_activate}=          ${CURDIR}/../resources/Delta_LSS_10_onFaultDet_activate.json
${delta_LSS_61652_onFaultDet_activate}=       ${CURDIR}/../resources/Delta_LSS_61652_onFaultDet_activate.json
${delta_LSS_onFaultDet_deactivate}=         ${CURDIR}/../resources/Delta_LSS_onFaultDet_deactivate.json

${BTS_metadata}=                BTS1_*_metadata.txt

*** Keywords ***
5GC001542_RA_Fault_trigger_automatic_to_LSS_viaSFTP_when_fault_is_detected

    log to console  Start 1st test
    wait until keyword succeeds  300  60  Verify Coam BTS is at least Configured
    wait until keyword succeeds  300  60  Verify Coam Radio is Online
    wait until keyword succeeds  300  60  Verify Coam Cell is Configured
    run keyword and ignore error  Remove Snapshot from LSS server
    ADMIN Change R&D Port Status  False
    ADMIN Perform Delta Recommissioning                 delta_file=${delta_LSS_61652_onFaultDet_activate}
    ...                                                 skip_parameter_relation_errors=True
    ADMIN Change R&D Port Status  True
    wait until keyword succeeds  600  60  Check if Snapshot is collected on LSS
    Wait until BTS_metadata.txt exists
    ADMIN Perform Delta Recommissioning                 delta_file=${delta_LSS_onFaultDet_deactivate}
    ...                                                 skip_parameter_relation_errors=True
    Remove Snapshot from LSS server
    log to console  End 1st test

5GC001542_RA_Fault trigger_automatic_to_LSS_but_not_performed_when_fault_is_detected

    log to console  Start 2nd test
    wait until keyword succeeds  300  60  Verify Coam BTS is at least Configured
    wait until keyword succeeds  300  60  Verify Coam Radio is Online
    wait until keyword succeeds  300  60  Verify Coam Cell is Configured
    run keyword and ignore error  Remove Snapshot from LSS server
    ADMIN Perform Delta Recommissioning                 delta_file=${delta_LSS_10_onFaultDet_activate}
    ...                                                 skip_parameter_relation_errors=True
    Sleep  30s
    Collect manual snapshot in background

    log to console  trigger fault 10
    SYSTEM Execute Command On IPHY  reboot --reboot
    SYSTEM Wait Till Iphy Will Not Be Pingable For A Given Period
    wait until keyword succeeds  360  60  Check if fault is in active raw alarm  0010   EFaultId_NoConnectionToUnitAl
    SYSTEM Wait For Host Is Reachable With Ping  192.168.200.1

    wait until keyword succeeds  360  60  Check if fault is not in active raw alarm  0010   EFaultId_NoConnectionToUnitAl
    ADMIN Check If Alarm Is Not Active  fault_id=10


    log to console  check if snapshot does not exist on LSS
    Check if Snapshot is not collected on LSS
    ADMIN Perform Delta Recommissioning                 delta_file=${delta_LSS_onFaultDet_deactivate}
    ...                                                 skip_parameter_relation_errors=True
    run keyword and ignore error  Remove Snapshot from LSS server
    ADMIN Teardown    admin_alias=ADMIN_Collect_Snapshot_in_background
    log to console  End 2nd test


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

Collect manual snapshot in background
    [Timeout]    6 min
    log to console  Collect snapshot manual
    ${CLI_INTERFACE}                                    Get Library Instance                 taf.sbts.oam.coam.admin
    ADMIN Connect To                                    admin_alias=ADMIN_Collect_Snapshot_in_background
    ${background}   taf.sbts.oam.coam.admin.run_keyword_in_background    interface=${CLI_INTERFACE}
    ...                                                                 name=Collect Snapshot
    ...                                                                 target_file_name=snapshot.zip
    ...                                                                 coverage=Full
    ...                                                                 force=${TRUE}
    ...                                                                 timeout=360
    ...                                                                 connection=ADMIN_Collect_Snapshot_in_background
#    [Teardown]    ADMIN Teardown    admin_alias=ADMIN_Collect_Snapshot_in_background



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
    should be true      ${snap_list}>=7
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

5GC001542-RA-Test Postconditions
    Log    \n+ Common 5GC001542-RA Test Postconditions With Reset Site started    console=yes
    run keyword and ignore error  Remove Snapshot from LSS server
    admin.ADMIN Reset Site
    LOGGING Stop Logging
    Log Variables
    Log    \n+ Common Test Postconditions With Reset Site finished    console=yes

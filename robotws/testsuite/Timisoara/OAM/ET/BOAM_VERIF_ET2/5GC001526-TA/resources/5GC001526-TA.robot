*** Settings ***
Documentation
...    Author: Irina Tanasoiu (irina.tanasoiu@nokia.com)
...    Maintainer: Irina Tanasoiu (irina.tanasoiu@nokia.com)
...    Group in charge: MANO_SOAM3
...    References: doors
...    Feature Description:5GC001542-RA
...    Sample execution: /opt/ute/python/bin/pybot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log
...    -d results/ /home/ute/robotws5g/testsuite/OAM/ET/BTS_OAM_FMRECOV/5GC001526-TA/general.robot

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

${LSS_addr}                     10.5.25.105
${LSS_username}                 coam
${LSS_password}                 zO&n1W*ktp7

${reasoning_path}=            /MRBTS-1/RAT-1/BTS_L-1/EQM_L-1/RMOD_L-1/RU_L-1

${scf_path}             /tmp/
${scf_name}             scf_file.xml

${delta_LSS_61652_onFaultDet_activate}=          ${CURDIR}/../resources/Delta_LSS_61652_onFaultDet_activate.json
${delta_LSS_61652_onFaultDet_deactivate}=         ${CURDIR}/../resources/Delta_LSS_61652_onFaultDet_deactivate.json
${delta_LSS_61652_onAlarmSend_activate}=          ${CURDIR}/../resources/Delta_LSS_61652_onAlarmSend_activate.json
${delta_LSS_61652_onAlarmSend_deactivate}=         ${CURDIR}/../resources/Delta_LSS_61652_onAlarmSend_deactivate.json

${BTS_metadata}=                BTS1_*_metadata.txt


*** Keywords ***
5G1526_TA_Snapshot_collection_is_triggered_by_autonomous_radio_recovery

    log to console  Start test
    run keyword and ignore error  Remove Snapshot from LSS server
    ADMIN Change R&D Port Status  False
    ADMIN Perform Delta Recommissioning                 delta_file=${delta_LSS_61652_onFaultDet_activate}
    ...                                                 skip_parameter_relation_errors=True
    ADMIN Change R&D Port Status  True
    wait until keyword succeeds  600  60  Check if Snapshot is collected on LSS
    Wait until BTS_metadata.txt exists
    ADMIN Perform Delta Recommissioning                 delta_file=${delta_LSS_61652_onFaultDet_deactivate}
    ...                                                 skip_parameter_relation_errors=True
    Remove Snapshot from LSS server
    log to console  End test

5G1526_TA_Snapshot_collection_is_triggered_by_radio_recovery

    log to console  Start test
    run keyword and ignore error  Remove Snapshot from LSS server
    #ADMIN Wait Until BTS OnAir
    sleep  180s
    ADMIN Change R&D Port Status  False
    ADMIN Perform Delta Recommissioning                 delta_file=${delta_LSS_61652_onAlarmSend_activate}
    ...                                                 skip_parameter_relation_errors=True
    ADMIN Change R&D Port Status  True
    wait until keyword succeeds  600  60  Check if Snapshot is collected on LSS
    Wait until BTS_metadata.txt exists
    ADMIN Perform Delta Recommissioning                 delta_file=${delta_LSS_61652_onAlarmSend_deactivate}
    ...                                                 skip_parameter_relation_errors=True
    Remove Snapshot from LSS server
    log to console  End test

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


Wait until BTS_metadata.txt exists
    wait until keyword succeeds  500  30  Check if BTS_metadata.txt exists

Check if BTS_metadata.txt exists
    Set Suite Variable    ${snapshot_LSS}    Snapshot_MRBTS-1_${OUT_ADMIN_BTS_NAME}
    csn.connect to    ${LSS_addr}    ${LSS_username}    ${LSS_password}    alias=LSS
    sleep    2s
    csn.send_command    command=find ${snapshot_LSS}*/*metadata.txt   connection=LSS
    ${snap_list}    csn.read output    connection=LSS
    Set Suite Variable    ${BTS_metadata}    metadata.txt
    should contain  ${snap_list}  ${BTS_metadata}
    csn.disconnect    connection=LSS

5GC001526-TA-Test Postconditions
    Log    \n+ Common Test Postconditions With Reset Site started    console=yes
    run keyword and ignore error  Remove Snapshot from LSS server
    ADMIN Reset Site
    LOGGING Stop Logging
    Log Variables
    Log    \n+ Common Test Postconditions With Reset Site finished    console=yes

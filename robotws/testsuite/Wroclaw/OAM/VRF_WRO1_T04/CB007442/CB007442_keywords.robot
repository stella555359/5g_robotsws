*** Settings ***
Documentation
...    Author: marek.gudalewicz@nokia.com & pawel.gorczynski@nokia.com
...    Maintainer: pawel.gorczynski@nokia.com
...    Description:
...    Team in charge: 5G_IV_7_WRO_6_SG
...    QualityCenter:

Resource    ../CommonKeywords/Component_states/Component_states_resources/component_states_checker.robot
Library    taf.sbts.oam.coam.admin   WITH NAME   admin_cli
Library    taf.transport.ssh    WITH NAME    csn
Library    taf.config.scf       WITH NAME    scf
Library    Collections
Library    OperatingSystem
Library    XML  lxml=True

*** Variables ***
${ue_pc}                  ${tl.ues[0].ssh_connection_details.addr}
${ue_pc_user}             ${tl.ues[0].ssh_connection_details.username}
${ue_pc_password}         ${tl.ues[0].ssh_connection_details.password}
${appserver_ip}           ${tl.appserver.iperf_details.ssh_connection_details.addr}
${appserver_user}         ${tl.appserver.iperf_details.ssh_connection_details.username}
${appserver_pass}         ${tl.appserver.iperf_details.ssh_connection_details.password}
${appserver_interface}    ${tl.appserver.iperf_details.network_interface_address}
*** Keywords ***
Recover UPUE
    set test variable    ${waiting_interval}      200
    set test variable    ${FaultID}      4383
    set test variable    ${AlarmID}      7101
    Check specific status on selected component  NRCELL-All            ${expected_statuses}
    Trigger UPUE crash
    wait until keyword succeeds   ${waiting_interval}   2   Wait For Fault with Alarm to appear   ${FaultID}    ${AlarmID}
    Wait For Fault with Alarm to disappear   ${FaultID}      ${AlarmID}
    Wait Until Keyword Succeeds    500    20    Check specific status on selected component  NRCELL-All            ${expected_statuses}

Trigger UPUE crash
    Open connection         ${HOST}
    Login                   ${USERNAME}         ${PASSWORD}
    SSHLibrary.Write     bsh 1:0
    SSHLibrary.Write     pkill -11 -f '/opt/CCS_RT/CCSRTDaemonExe --startup=nid=0x1731'

Recover L3SW
    set test variable    ${waiting_interval}      200
    set test variable    ${FaultID}      4383
    set test variable    ${AlarmID}      7101
    Check specific status on selected component  NRCELL-All            ${expected_statuses}
    Trigger L3SW crash
    wait until keyword succeeds   ${waiting_interval}   2   Wait For Fault with Alarm to appear   ${FaultID}    ${AlarmID}
    Wait For Fault with Alarm to disappear   ${FaultID}      ${AlarmID}
    Wait Until Keyword Succeeds    500    20    Check specific status on selected component  NRCELL-All            ${expected_statuses}

Trigger L3SW crash
    Open connection         ${HOST}
    Login                   ${USERNAME}         ${PASSWORD}
    SSHLibrary.Write     bsh 1:0
    SSHLibrary.Write     pkill -11 -f '/opt/CCS/CCSDaemonExe --startup=nid=0x1734'

Recover L2RT
    set test variable    ${waiting_interval}      200
    set test variable    ${FaultID}      4383
    set test variable    ${AlarmID}      7101
    Check specific status on selected component  NRCELL-All            ${expected_statuses}
    Trigger L2RT crash
    wait until keyword succeeds   ${waiting_interval}   2   Wait For Fault with Alarm to appear   ${FaultID}    ${AlarmID}
    Wait For Fault with Alarm to disappear   ${FaultID}      ${AlarmID}
    Wait Until Keyword Succeeds    500    20    Check specific status on selected component  NRCELL-All            ${expected_statuses}

Trigger L2RT crash
    Open connection         ${HOST}
    Login                   ${USERNAME}         ${PASSWORD}
    SSHLibrary.Write     bsh 1:0
    SSHLibrary.Write     pkill -11 -f '/opt/CCS_RT/CCSRTDaemonExe --startup=nid=0x1730'

#Trigger LokiA recovery and check 2087 fault
#    set test variable    ${FaultID}      2087
#    set test variable    ${AlarmID}      7101
#    set test variable    ${waiting_interval_for_fault}      120
#    Check specific status on selected component  NRCELL-All            ${expected_statuses}
#    Trigger LokiA recovery
#    wait until keyword succeeds   ${waiting_interval_for_fault}   2   Wait For Fault with Alarm to appear   ${FaultID}    ${AlarmID}
#    Wait For Fault with Alarm to disappear   ${FaultID}      ${AlarmID}
#    Wait Until Keyword Succeeds    500    20    Check specific status on selected component  NRCELL-All            ${expected_statuses}

Trigger L3SW escalation
    [Arguments]   ${bbmodId}
    &{precondition_statuses}   Create Dictionary   operationalState=Enabled  availabilityStatus=Online  administrativeState=Unlocked
    #&{BBMODResetStatuses}  Create Dictionary   availabilityStatus=degraded
    set test variable    ${FaultID}      4383
    set test variable    ${AlarmID}      7101
    Check specific status on selected component  NRCELL-All            ${precondition_statuses}
    Trigger L3SW crash
    Log to console    'Waiting for the BBMOD reset'
    Wait until keyword succeeds   ${waiting_interval}   2   Wait For Fault with Alarm to appear   ${FaultID}    ${AlarmID}
    #Wait Until Keyword Succeeds    600    10    Check specific status on selected component   BBMOD-1            ${BBMODResetStatuses}
    Log to console    'Waiting for the BBMOD onAir'
    Wait For Fault with Alarm to disappear   ${FaultID}      ${AlarmID}
    Wait Until Keyword Succeeds    600    20    Check specific status on selected component  NRCELL-All            ${expected_statuses}

Trigger L2RT escalation
    [Arguments]   ${bbmodId}    ${Fault_name}=None
    &{precondition_statuses}   Create Dictionary   operationalState=Enabled  availabilityStatus=Online  administrativeState=Unlocked
    set test variable    ${FaultID}      4383
    set test variable    ${AlarmID}      7101
    #&{BBMODResetStatuses}  Create Dictionary   availabilityStatus=Degraded
    Check specific status on selected component  NRCELL-All            ${precondition_statuses}
    Trigger L2RT crash
    Log to console    'Waiting for the BBMOD reset'
    Wait until keyword succeeds   ${waiting_interval}   2   Wait For Fault with Alarm to appear   ${FaultID}    ${AlarmID}
    ...    ${Fault_name}
    #Wait Until Keyword Succeeds    600    10    Check specific status on selected component   BBMOD-1            ${BBMODResetStatuses}
    Log to console    'Waiting for the BBMOD onAir'
    Wait For Fault with Alarm to disappear   ${FaultID}      ${AlarmID}
    Wait Until Keyword Succeeds    600    20    Check specific status on selected component  NRCELL-All            ${expected_statuses}

Trigger LokiA escalation
    [Arguments]   ${bbmodId}
    &{precondition_statuses}   Create Dictionary   operationalState=Enabled  availabilityStatus=Online  administrativeState=Unlocked
    &{BBMODResetStatuses}  Create Dictionary   availabilityStatus=degraded
    Check specific status on selected component  NRCELL-All            ${precondition_statuses}
    Trigger LokiA recovery
    Log to console    'Waiting for the BBMOD reset'
    Wait Until Keyword Succeeds    600    10    Check specific status on selected component   BBMOD-1            ${BBMODResetStatuses}
    Log to console    'Waiting for the BBMOD onAir'
    Wait Until Keyword Succeeds    600    20    Check specific status on selected component  NRCELL-All            ${expected_statuses}

#Trigger LokiA recovery
#    Open connection         ${HOST}
#    Login                   ${USERNAME}         ${PASSWORD}
#    SSHLibrary.Write     bsh 1:1
#    SSHLibrary.Write     ps aux | grep l1_application > /tmp/ps_l1_result.txt
#    SSHLibrary.Write     head -2 /tmp/ps_l1_result.txt
#    SSHLibrary.Write     clear
#    ${ps_aux}=  SSHLibrary.Read   delay=1s
#    @{trash_list}=     Split String  ${ps_aux}
#    ${application_nrt_index_in_trash}=   Get Index From List   ${trash_list}    /usr/bin/l1_application_nrt
#    ${pidIndex}=        Evaluate     ${application_nrt_index_in_trash} - 9
#    ${pidToKill}=      Get from list   ${trash_list}     ${pidIndex}
#    log to console     --- Killing process PID: ${pidToKill}
#    SSHLibrary.Write    kill -11 ${pidToKill}

Loki recovery triggered by OAM
    ${expected_BBMOD_status}    create dictionary
    ...    administrativeState=unlocked
    ...    availabilityStatus=degraded
    ...    operationalState=enabled
    set test variable    ${FaultID}      10
    set test variable    ${AlarmID}      7116
    set test variable    ${waiting_interval_for_fault}      600
    Check specific status on selected component  NRCELL-All            ${expected_statuses}
    Trigger SoC reset by OAM
#   Wait For BBMOD Reset
    Wait Until Keyword Succeeds    600    2    Check Specific Status On Selected Component    BBMOD-1    ${expected_BBMOD_status}
#   Wait For onAir
    Wait Until Keyword Succeeds    500    20    Check Specific Status On Selected Component    NRCELL-All    ${expected_statuses}
#    wait until keyword succeeds   ${waiting_interval_for_fault}   2   Wait For Fault with Alarm to appear   ${FaultID}    ${AlarmID}
#    Wait For Fault with Alarm to disappear   ${FaultID}      ${AlarmID}
#    Wait Until Keyword Succeeds    500    20    Check specific status on selected component  NRCELL-All            ${expected_statuses}

Trigger SoC reset by OAM
    Open connection         ${HOST}
    Login                   ${USERNAME}         ${PASSWORD}
    SSHLibrary.Write     bsh 1:1
    SSHLibrary.Write     syscomctl routing list
    ${routes}=  SSHLibrary.Read   delay=1s
    @{lines}=    Split To Lines     ${routes}
    ${nrOfLines}=    Get length     ${lines}
    ${linesMinus2}=    Evaluate    ${nrOfLines} - 2

    FOR   ${route}    IN RANGE  3  ${linesMinus2}
        ${singleLine}=   Get From List     ${lines}      ${route}
        ${singleLine}=   Split String    ${singleLine}    separator=|
        ${routeToKill}=   Get From List    ${singleLine}    0
        log to console     Removing route ${routeToKill}
        SSHLibrary.Write     syscomctl routing remove ${routeToKill}
        BuiltIn.Sleep     2
    END

#Wait For Fault with Alarm to appear
#    [Arguments]  ${FaultID}     ${AlarmID}
#    Fault Should Be Present   ${FaultID}
#    Alarm Should Be Present   ${AlarmID}

#Wait For Fault with Alarm to disappear
#    [Arguments]  ${FaultID}     ${AlarmID}
#    wait until keyword succeeds  300      20    Fault Should Not Be Present   ${FaultID}

#Fault Should Be Present
#    [Documentation]
#    ...  ___
#    [Arguments]    ${fault_id}
#    Log To Console    KW - Fault Should Not Be Present fault_id=${fault_id}
#    ${active_alarms}    admin_cli.get_active_alarms    timeout=60
#    ${len}    Get Length    ${active_alarms}
#    ${alarm_id_list}    Create List
#    :FOR    ${i}    In Range    ${len}
#    \    ${tmp_id}    Get From Dictionary    ${active_alarms[${i}]}    faultId
#    \    Append To List    ${alarm_id_list}    ${tmp_id}
#    Log To Console    Active alarms: alarm_id_list=${alarm_id_list}
#    ${list}     convert to string  ${alarm_id_list}
#    Should Contain    ${list}    ${fault_id}

#Fault Should Not Be Present
#    [Documentation]
#    ...  ___
#    [Arguments]    ${fault_id}
#    Log To Console    KW - Fault Should Not Be Present fault_id=${fault_id}
#    ${active_alarms}    admin_cli.get_active_alarms    timeout=60
#    ${len}    Get Length    ${active_alarms}
#    ${alarm_id_list}    Create List
#    :FOR    ${i}    In Range    ${len}
#    \    ${tmp_id}    Get From Dictionary    ${active_alarms[${i}]}    faultId
#    \    Append To List    ${alarm_id_list}    ${tmp_id}
#    Log To Console    Active alarms: alarm_id_list=${alarm_id_list}
#    ${list}     convert to string  ${alarm_id_list}
#    Should Not Contain    ${list}    ${fault_id}

#Alarm Should Be Present
#    [Documentation]
#    ...  ___
#    [Arguments]    ${alarm_id}
#    Log To Console    KW - Alarm Should Be Present alarm_id=${alarm_id}
#    ${active_alarms}    admin_cli.get_active_alarms    timeout=60
#    ${len}    Get Length    ${active_alarms}
#    ${alarm_id_list}    Create List
#    :FOR    ${i}    In Range    ${len}
#    \    ${tmp_id}    Get From Dictionary    ${active_alarms[${i}]}    alarmId
#    \    Append To List    ${alarm_id_list}    ${tmp_id}
#    Log To Console    Active alarms: alarm_id_list=${alarm_id_list}
#    ${list}     convert to string  ${alarm_id_list}
#    Should Contain    ${list}    ${alarm_id}

#Alarm Should Not Be Present
#    [Documentation]
#    ...  ___
#    [Arguments]    ${alarm_id}
#    ${active_alarms}    admin_cli.get_active_alarms    timeout=60
#    ${len}    Get Length    ${active_alarms}
#    ${alarm_id_list}    Create List
#    :FOR    ${i}    In Range    ${len}
#    \    ${tmp_id}    Get From Dictionary    ${active_alarms[${i}]}    alarmId
#    \    Append To List    ${alarm_id_list}    ${tmp_id}
#    ${list}     convert to string  ${alarm_id_list}
#    Should Not Contain    ${list}    ${alarm_id}

#Reset Site and wait for onAir
#    log to console      performing Site Reset
#    admin_cli.reset_site
#    Wait Until Keyword Succeeds    500    20    Check specific status on selected component  NRCELL-All            ${expected_statuses}

#UE ADB check keywords###############################################################################################
Get timestamp
    @{time}             Get time    year month day hour min sec
    ${time_stamp}       Set Variable    ${EMPTY}
    : FOR    ${item}    IN    @{time}
    \    ${time_stamp}    Catenate    SEPARATOR=${EMPTY}    ${time_stamp}    ${item}
    [Return]    ${time_stamp}

Check attach to 5G in ADB
    [Arguments]     ${UE_SN}
    Go UE adb shell    ${UE_SN}
    Catch ADB logs    ${UE_SN}
    Sleep    10s
    Stop ADB logs    ${UE_SN}
    Verify ADB logs

Go UE adb shell
    [Arguments]     ${UE_SN}
    csn.send_command    adb -s ${UE_SN} root   connection=cpc
    Sleep               5s

Catch ADB logs
    [Arguments]          ${UE_SN}
    csn.send_command     rm /tmp/*.*    connection=cpc
    Sleep                2s
    ${timestamp}         Get timestamp
    Set Suite Variable   ${adbtimestamp}    ${timestamp}
    csn.send_command     adb -s ${UE_SN} logcat -b all > /tmp/ADB_${adbtimestamp}.log    connection=cpc
    Log To Console       --> INFO: start to catch UE ADB logs [1 min]

Stop ADB logs
    [Arguments]     ${UE_SN}
    csn.send_command     adb -s ${UE_SN} kill-server logcat    connection=cpc
    Sleep                2s
    csn.download file    /tmp/ADB_${adbtimestamp}.log    ${OUTPUT_DIR}/adb.log    connection=cpc

Verify ADB logs
    csn.send_command    cat /tmp/ADB_${adbtimestamp}.log | grep isMobileConnected > /tmp/adb_grep_5G.log  connection=cpc
    Sleep                2s
    csn.send_command     tail -n 1 /tmp/adb_grep_5G.log    connection=cpc
    ${result}            csn.read_output    connection=cpc
    Should Contain       ${result}    isMobileConnected true
    Log To Console       --> INFO: 5G UE setup successfully

Connect to UE PC1
    [Arguments]     ${UE_control_pc}  ${UE_control_pc_user}     ${UE_control_pc_password}  ${alias}=cpc
    Log To Console    \n--> INFO: connecting to UE PC
    Wait Until Keyword Succeeds    1min    20s    csn.Connect to
    ...             hostname=${UE_control_pc}
    ...             username=${UE_control_pc_user}
    ...             password=${UE_control_pc_password}
    ...             alias=${alias}

Connect to appserver1
    [Arguments]         ${APPSERVER_IP}     ${APPS_USERNAME}    ${APPS_PASSWORD}    ${session}=appserver
    Log To Console    \n--> INFO: connecting to appserver
    csn.Connect To      hostname=${APPSERVER_IP}
    ...                 username=${APPS_USERNAME}
    ...                 password=${APPS_PASSWORD}
    ...                 alias=${session}

Check attach
    [Arguments]     ${UE_SERIAL_NR}
    Connect to appserver and control pc
    Check UE attach    ${UE_SERIAL_NR}
    Check attach to 5G in ADB    ${UE_SERIAL_NR}
    Kill Iperf and Remove files

Connect to appserver and control pc
    Connect to UE PC1    ${ue_pc}  ${ue_pc_user}    ${ue_pc_password}    cpc
    Connect to appserver1    ${appserver_ip}     ${appserver_user}    ${appserver_pass}    appserver

Kill Iperf and Remove files
    Kill Iperf on UEPC    cpc    iperf3
    Remove files    5551    appserver    5552    cpc

Check UE attach
    [Arguments]     ${UE_SN}
    ${UE1_IP}=    Reboot UE and wait for attach    cpc    ${UE_SN}

Get UE IP once
    [Arguments]     ${alias}    ${UE_SN}
    csn.send_command    adb -s ${UE_SN} root   connection=cpc
    sleep    3s
    csn.Send Command    adb -s ${UE_SN} shell "ip a | grep 192"
    ...                 connection=cpc
    ...                 timeout=5
    sleep    3s
    ${ue_ip1}=      csn.read_output    connection=cpc
    ${ue_ip}=      Remove String    ${ue_ip1}    ${SPACE}
    ${ue_ip}=      Fetch From left    ${ue_ip}   /
    ${ue_ip}=      Fetch From Right   ${ue_ip}    t
    [Return]          ${ue_ip}

#Get UE IP
#    [Arguments]     ${alias}     ${UE_SN}
#    wait until keyword succeeds  1 min   10 s   Check if IP is nice   ${alias}     ${UE_SN}
#    ${ip}     Get UE IP once      ${alias}    ${UE_SN}
#    [Return]     ${ip}

Check if IP is nice
    [Arguments]     ${alias}     ${UE_SN}
    ${ip}=   Get UE IP once      ${alias}     ${UE_SN}
    ${ipLen}=   Get length  ${ip}
    Run Keyword Unless     ${ipLen} > ${6}     Fail


Kill Iperf on UEPC
    [Arguments]       ${ue_pc}    ${iperf}
    ${pid}=        csn.execute     ps | grep ${iperf} | awk '{print $1}'    connection=${ue_pc}
    ${pid}=        Fetch From Left    ${pid}  \r
    ${kill}=       Catenate     kill -9 ${pid}
    csn.Execute    ${kill}    connection=${uepc}

Remove files
    [Arguments]    ${ul_port}    ${appsrv}    ${dl_port}    ${ue_pc}
    ${dl_file}=    Catenate    rm -rf /tmp/iperf_DL${dl_port}.txt
    ${ul_file}=    Catenate    rm -rf /tmp/iperf_UL${ul_port}.txt
    csn.Send command    ${ul_file}    connection=${appsrv}
    csn.Send command    ${dl_file}    connection=${ue_pc}

Is UE IP correct
    [Arguments]      ${ue_pc}    ${pattern}    ${UE_SN}
    ${ip192}=     Get UE IP once    ${ue_pc}    ${UE_SN}
    ${UE_IP}=     Set Variable If
    ...    ${pattern}==192.168    ${ip192}
    Should Contain     ${UE_IP}    ${pattern}
    [Return]    ${UE_IP}

Reboot UE and wait for attach
    [Arguments]         ${ue_pc}    ${UE_SN}
    ${command}=       Catenate    adb -s ${UE_SN} reboot
    csn.send command     ${command}    connection=${ue_pc}
    sleep    30s
    ${UE_IP}=    Wait Until Keyword Succeeds     2 min    1 sec    Is UE IP correct    ${ue_pc}    192.168    ${UE_SN}

Set Parameters To Allow Reset
    Get SCF File From BTS
    ${actFaultSignature}=  Get Value From SCF  dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1    param_name=actFaultSignature
    ${actFaultSignature}=    Convert To Lower Case    ${actFaultSignature}
    ${actForceAutoReset}=  Get Value From SCF  dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FMCADM-1    param_name=actForceAutoReset
    ${actForceAutoReset}=    Convert To Lower Case    ${actForceAutoReset}
    ${actForceUnitAutoReset}=  Get Value From SCF  dist_name=MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FMCADM-1    param_name=actForceUnitAutoReset
    ${actForceUnitAutoReset}=    Convert To Lower Case    ${actForceUnitAutoReset}
    Run Keyword If   '${actFaultSignature}'=='false' and '${actForceAutoReset}'=='false' and '${actForceUnitAutoReset}'=='false'
    ...    Set Rest Parameters To True

Set Rest Parameters To True
    ${scf_old}    ${scf_new}    Start Delta preparation
    Modify Element in string    MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1    actFaultSignature    true
    Modify Element in string    MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FMCADM-1    actForceAutoReset    true
    Modify Element in string    MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/FMCADM-1    actForceUnitAutoReset    true
    Create and upload Delta    ${scf_old}    ${scf_new}

*** Settings ***
Documentation
...    Author: Monika Szlovak (monika.szlovak@nokia.com)
...    Maintainer: Monika Szlovak (monika.szlovak@nokia.com)
...    Group in charge: MANO_SOAM3
...    References: doors
...    Feature Description: 5GC002056-AZ_5GC000506  Remote Syslog for continous log storage
...    AC/REQ: LTE_OPR_AC_4546 / LTE_OPR_REQ_7994

Library        String
Library        Telnet
Library        OperatingSystem
Library        Process
Library     taf.sbts.oam.coam.admin
Library     taf.transport.ssh
Library      ./server.py
Library        SSHLibrary

Resource    ./keywords.robot
Resource    ../../../resources/admin.robot
Resource    ../../../resources/pretest_posttest.robot
Resource    ../../../resources/system.robot
Resource    ../../../resources/fault_trigger.robot
Resource    ../../../resources/AirPhone/resources/ute/ute_wts_runner.robot

*** Variables ***
${REMOTE_SYSLOG_UDP_NSN_ON_3}=     ${CURDIR}/Remote_syslog_UDP_NSN_on_3.json
${REMOTE_SYSLOG_UDP_RFC_ON_3}=     ${CURDIR}/Remote_syslog_UDP_RFC_on_3.json
${REMOTE_SYSLOG_OFF}=              ${CURDIR}/Remote_syslog_off.json
${DURATION_3}=                   3 minutes

${host}=                10.5.25.106
${port}=                22
${username_ute}=        ute
${password_ute}=        ute

*** Keywords ***
Remote_syslog_transmission_using_UDP_with_remoteSyslogFormat=NSN
# part 1
    log to console   delta commissioning remote syslog off
    ADMIN Perform Delta Recommissioning        delta_file=${REMOTE_SYSLOG_OFF}
    ...                                        skip_parameter_relation_errors=True
    Sleep   20
    log to console   restart Rsyslog service
    Configure Rsyslog Service
    Restart Rsyslog Service
    log to console   UDP NSN remote syslog on 3 min
    ADMIN Perform Delta Recommissioning        delta_file=${REMOTE_SYSLOG_UDP_NSN_ON_3}
    ...                                        skip_parameter_relation_errors=True
    ${Start_time}=  Get Current Date
    ${Duration_end_time}=  Add Time To Date  ${Start_time}  ${DURATION_3}  result_format=%Y-%m-%d %H:%M:%S.%f
#    ${Remote_started}=  Run    ls -l &{rsyslog_config}[udp_file]
#    ${Split}=   Split string      ${Remote_started}   separator=\
#    ${Remote_start_time}=   Get from list     ${Split}    7
#    log to console   remote started at: ${Remote_start_time}
    log to console   wait busy
    Wait Syslog Busy
    Wait until '${Duration_end_time}' reached
    Sleep   10
#    ${Remote_ended}=  Run    ls -l &{rsyslog_config}[udp_file]
#    ${Split}=   Split string      ${Remote_ended}   separator=\
#    ${Remote_end_time}=   Get from list     ${Split}    7
#    log to console   remote ended at: ${Remote_end_time}
    Get BTS Syslog file for Proprietary from lss and remove from there
    Check BTS Syslog file for Proprietary
    log to console   remote syslog off
    ADMIN Perform Delta Recommissioning        delta_file=${REMOTE_SYSLOG_OFF}
    ...                                        skip_parameter_relation_errors=True
    log to console   wait idle
    Wait Syslog Idle

# part 2
    log to console   restart Rsyslog service
    Configure Rsyslog Service
    Restart Rsyslog Service
    log to console   UDP NSN remote syslog on 3 min
    ADMIN Perform Delta Recommissioning        delta_file=${REMOTE_SYSLOG_UDP_NSN_ON_3}
    ...                                        skip_parameter_relation_errors=True
    ${Start_time}=  Get Current Date
    ${Duration_end_time}=  Add Time To Date  ${Start_time}  ${DURATION_3}  result_format=%Y-%m-%d %H:%M:%S.%f
#    ${Remote_started}=  Run    ls -l &{rsyslog_config}[udp_file]
#    ${Split}=   Split string      ${Remote_started}   separator=\
#    ${Remote_start_time}=   Get from list     ${Split}    7
#    log to console   remote started at: ${Remote_start_time}
    log to console   wait busy
    Wait Syslog Busy
    log to console   Reset site
    admin.ADMIN Reset Site
    Wait Until Keyword Succeeds
    ...    900
    ...    30
    ...    ADMIN INFOMODEL Check If BTS Is Configured
    log to console   wait busy
    Wait Syslog Busy
    Wait until '${Duration_end_time}' reached
    Sleep   10
#    ${Remote_ended}=  Run    ls -l &{rsyslog_config}[udp_file]
#    ${Split}=   Split string      ${Remote_ended}   separator=\
#    ${Remote_end_time}=   Get from list     ${Split}    7
#    log to console   after reset remote was ended at: ${Remote_end_time}
    Get BTS Syslog file for Proprietary after reset from lss and remove from there
    Check BTS Syslog file for Proprietary after reset
    Wait Until Keyword Succeeds
    ...    600
    ...    30
    ...    ADMIN INFOMODEL Check If BTS Is Onair
    log to console   remote syslog off
    ADMIN Perform Delta Recommissioning        delta_file=${REMOTE_SYSLOG_OFF}
    ...                                        skip_parameter_relation_errors=True
    log to console   wait idle
    Wait Syslog Idle
    Sleep   60

#...............................................
Restart Rsyslog Service
    SSHLibrary.Open Connection    host=${host}    port=${port}    timeout=60
    SSHLibrary.Login    username=${username_ute}    password=${password_ute}    delay=1s
    SSHLibrary.Write    sudo systemctl restart rsyslog.service
    SSHLibrary.Read Until    expected=$
    SSHLibrary.Write    systemctl --no-pager status rsyslog.service
    SSHLibrary.Read Until    expected=$
    SSHLibrary.Close Connection

Get BTS Syslog file for Proprietary from lss and remove from there
    SSHLibrary.Open Connection    host=${host}    port=${port}    timeout=60
    SSHLibrary.Login    username=${username_ute}    password=${password_ute}    delay=1s
    SSHLibrary.Get File           /var/log/btslog-udp.json  /opt/ute/logs/btslog-udp_Proprietary.json
    SSHLibrary.Write    sudo rm /var/log/btslog-udp.json
    SSHLibrary.Read Until    expected=$
    SSHLibrary.Close Connection

Get BTS Syslog file for Proprietary after reset from lss and remove from there
    SSHLibrary.Open Connection    host=${host}    port=${port}    timeout=60
    SSHLibrary.Login    username=${username_ute}    password=${password_ute}    delay=1s
    SSHLibrary.Get File           /var/log/btslog-udp.json  /opt/ute/logs/btslog-udp_Proprietary_reset.json
    SSHLibrary.Write    sudo rm /var/log/btslog-udp.json
    SSHLibrary.Read Until    expected=$
    SSHLibrary.Close Connection

Check BTS Syslog file for Proprietary
	OperatingSystem.File Should Exist    /opt/ute/logs/btslog-udp_Proprietary.json
	OperatingSystem.File Should Not Be Empty   /opt/ute/logs/btslog-udp_Proprietary.json

Check BTS Syslog file for Proprietary after reset
	OperatingSystem.File Should Exist    /opt/ute/logs/btslog-udp_Proprietary_reset.json
	OperatingSystem.File Should Not Be Empty   /opt/ute/logs/btslog-udp_Proprietary_reset.json

BTS Syslog shall be redirected to remote server
    OperatingSystem.File Should Exist  &{rsyslog_config}[udp_file]
    OperatingSystem.File Should Not Be Empty  &{rsyslog_config}[udp_file]
    Run    sudo rm &{rsyslog_config}[udp_file]

BTS Syslog shall be redirected to remote server and save file
    OperatingSystem.File Should Exist  &{rsyslog_config}[udp_file]
    OperatingSystem.File Should Not Be Empty  &{rsyslog_config}[udp_file]
    Run    cp &{rsyslog_config}[udp_file] ${OUTPUT_DIR}/btslog-udp.json
    Run    sudo rm &{rsyslog_config}[udp_file]

Wait until '${time}' reached
    ${epochdate} = 	Convert Date 	${time} 	epoch
    FOR  ${INDEX}  IN RANGE  1  142
      ${currenttime}=  Get Current Date
      ${epochcurrent}=  Convert Date 	${currenttime} 	epoch
      Exit For Loop If  ${epochdate}<${epochcurrent}
      Sleep  10
    END

Wait Syslog Busy
    ${syslog_distname}    Get Object Distname From Class Name
    ...    class_name=SYSLOG_L
    ${dict_SWM}    taf.sbts.oam.coam.admin.get_parameters    ${syslog_distname}    usageState
    ${dict_SWM_state_info}    collections.Get From Dictionary          ${dict_SWM}               stateInfo
    ${SWM_usage_state}        collections.Get From Dictionary          ${dict_SWM_state_info}    usageState
    Log To Console            \SWM_usage_state=${SWM_usage_state}
    should contain  ${SWM_usage_state}  	Busy

Wait Syslog Idle
    ${syslog_distname}    Get Object Distname From Class Name
    ...    class_name=SYSLOG_L
    ${dict_SWM}    taf.sbts.oam.coam.admin.get_parameters    ${syslog_distname}    usageState
    ${dict_SWM_state_info}    collections.Get From Dictionary          ${dict_SWM}               stateInfo
    ${SWM_usage_state}        collections.Get From Dictionary          ${dict_SWM_state_info}    usageState
    Log To Console            \SWM_usage_state=${SWM_usage_state}
    should contain  ${SWM_usage_state}  	Idle

Get Object Distname From Class Name
    [Arguments]    ${class_name}
    ...            ${timeout}=60
    ...            ${alias}=${ADMIN_ALIAS}
    ${out_list_of_objects_parameters_dict}    taf.sbts.oam.coam.admin.Get Managed Objects
    ...    class_name=${class_name}
    ...    timeout=${timeout}
    ...    connection=${alias}
    FOR    ${element}    IN    @{out_list_of_objects_parameters_dict}
        ${distName}    Get From Dictionary    ${element}    distName
    END
    [Return]    ${distName}

UTE TL Preparation
    [Documentation]     Keyword used for setting up local 5G TLs to onAir state, as UTE reserve it only to sw_upload state
    #TO DO:             Add Check for onAir State. For cases when the Suite is run more than one time
    PREPOST Setup Admin
    ADMIN Change R&D Port Status    status=True
    @{status}   Run Keyword and Ignore Error    ADMIN Check BTS onair
    Run Keyword If  '@{status}[0]' == 'FAIL'   Run Keyword  5GC001525-OA.Configured_SwDownload_SwUpdate_OnAir
    ...     ELSE    Log To Console  --- BTS already onAir ---
    ADMIN Teardown Admin

Configured_SwDownload_SwUpdate_OnAir
    ADMIN Check BTS Not Commisioned
    Get TL Hostname
    Get Software Release
    ADMIN Perform Commissioning
    ...     scf_file=/home/ute/MN/UTE/robotws/custom-config/Timisoara/${tl_hostname}/${sw_release}/${tl_hostname}_SCF.xml
    ${configured}   Run Keyword and Return Status    BuiltIn.Wait Until Keyword Succeeds  600  30   ADMIN Check BTS Configured
    Run Keyword If  '${configured}' == 'True'  Sleep  180
    Run Keyword Unless   ${configured}   Run Keywords   admin.ADMIN Reset Site
    ...    AND     BuiltIn.Wait Until Keyword Succeeds  600  30   ADMIN Check BTS Configured
    ...    AND     Sleep  180
    Log To Console  Fault ID23 Checking...
    ${result}   Run Keyword and Return Status    ADMIN Check If Alarm Is Active  fault_id=23
    BuiltIn.Run Keyword If  '${result}' == 'True'   Run Keywords   Log To Console  Fault ID23 found. Start RF Software Update
    ...     AND     ADMIN Download And Update Current Software
    ...     ELSE    Log To Console  Fault ID23 not found.
    ${onair}   Run Keyword and Return Status    BuiltIn.Wait Until Keyword Succeeds  600  30   ADMIN Wait Until BTS OnAir
    Run Keyword Unless   ${onair}   Run Keywords   admin.ADMIN Reset Site
    ...    AND     BuiltIn.Wait Until Keyword Succeeds  600  30   ADMIN Wait Until BTS OnAir




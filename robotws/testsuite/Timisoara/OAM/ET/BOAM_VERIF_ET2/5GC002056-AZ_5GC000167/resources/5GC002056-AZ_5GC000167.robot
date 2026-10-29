*** Settings ***
Documentation
...    Author: Monika Szlovak (monika.szlovak@nokia.com)
...    Maintainer: Monika Szlovak (monika.szlovak@nokia.com)
...    Group in charge: MANO_SOAM3
...    References: doors
...    Feature Description: 5GC002056-AZ_5GC000167
...    Sample execution: /opt/ute/python/bin/robot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log
...    -d results/ /home/ute/robotws/testsuite/Timisoara/OAM/ET/BOAM_VERIF_ET2/5GC002056-AZ_5GC000167/general.robot

Library    SSHLibrary   WITH NAME   ssh
Library        String
Library        Telnet
Library        OperatingSystem
Library        Process
Library     taf.sbts.oam.coam.admin
Library     taf.transport.ssh

Resource    ./keywords.robot
Resource    ../../resources/admin.robot
Resource    ../../resources/pretest_posttest.robot
Resource    ../../resources/system.robot
Resource    ../../resources/fault_trigger.robot
Resource    ../../resources/AirPhone/resources/ute/ute_wts_runner.robot

*** Variables ***
${LOGGING_ENB_SYSLOG}=           True
${LOGGING_IPHY_SYSLOG}=          True
${LOGGING_ADMIN_LOG}=            True
${LOGGING_ADMIN_INFOMODEL_LOG}=  True
${LOGGING_EMSSIM_LOG}=           True

${reasoning_path_1937_left}=       /MRBTS-1/RAT-1/BTS_L-1/EQM_L-1/RMOD_L-1/RU_L-1
${reasoning_path_1937_right}=      /MRBTS-1/RAT-1/BTS_L-4/EQM_L-1/RMOD_L-1/RU_L-1

${reasoningStatus_7100}=           stateInfo.reasoningStatus[?]="GnbCellActivationFailedX2Degraded"
${reasoning_path_7100_left}=       /MRBTS-1/RAT-1/NRTS-1/NRBTS_L-1/NRCELL_L-1
${reasoning_path_7100_right}=      /MRBTS-1/RAT-1/NRTS-4/NRBTS_L-1/NRCELL_L-1

${reasoningStatus_7101}=           stateInfo.reasoningStatus[?]="GnbCpCellUpdateFailedNSA"
${reasoning_path_7101_left}=       /MRBTS-1/RAT-1/NRTS-1/NRBTS_L-1/NRCELL_L-1
${reasoning_path_7101_right}=      /MRBTS-1/RAT-1/NRTS-4/NRBTS_L-1/NRCELL_L-1

${RNCELL_path_left}=		       /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-1/NRCELL_R-1
${RNCELL_path_right}=		       /MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/NRBTS_R-1/NRCELL_R-1

${X2LinkLock}=                        ${CURDIR}/X2LinkLock_locked.json
${X2LinkUnlock}=                      ${CURDIR}/X2LinkLock_unlocked.json
${nsaCellActivationAlarmTimer_240}=   ${CURDIR}/nsaCellActivationAlarmTimer_240.json
${nsaCellActivationAlarmTimer_600}=   ${CURDIR}/nsaCellActivationAlarmTimer_600.json
${fPdcchMonOccsnPo_378}=              ${CURDIR}/fPdcchMonOccsnPo_378.json
${fPdcchMonOccsnPo_154}=              ${CURDIR}/fPdcchMonOccsnPo_154.json

${TRUNK_VERSION}=                 SBTS22R3

&{FAULT_4655}    fault_id=4655
...              alarm_id=7220
...              alarm_severity=Minor
...              alarm_description="Service account root access is enabled"
...              alarm_resource=MRBTS-1/MNL-1/MNLENT-1/SECADM-1

&{FAULT_61649}    fault_id=61649
...              alarm_id=7220
...              alarm_severity=Minor
...              alarm_description="LMP access via port 443"
...              alarm_resource=MRBTS-1/EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-1

&{FAULT_4654}    fault_id=4654
...              alarm_id=7220
...              alarm_severity=Minor
...              alarm_description="Ethernet port security is disabled"
...              alarm_resource=MRBTS-1/EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-1

&{FAULT_4681}    fault_id=4681
...              alarm_id=7111
...              alarm_severity=Major
...              alarm_description="Sanity Check Error"
...              alarm_resource=MRBTS-1/EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-1

&{FAULT_4687}    fault_id=4687
...              alarm_id=7115
...              alarm_severity=Minor
...              alarm_description="CPRI RU Migration to eCPRI Mode Required"
...              alarm_resource=MRBTS-1/EQM_R-1/APEQM_R-1/RMOD_R-1

&{FAULT_4298}    fault_id=4298
...              alarm_id=7115
...              alarm_severity=Minor
...              alarm_description="ToP reference missing"
...              alarm_resource=MRBTS-1/EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-1

&{FAULT_4334}    fault_id=4334
...              alarm_id=7116
...              alarm_severity=Major
...              alarm_description="Serial console activated"
...              alarm_resource=MRBTS-1/EQM_R-1/APEQM_R-1/CABINET_R-1/BBMOD_R-1

&{FAULT_61524}    fault_id=61524
...              alarm_id=7220
...              alarm_severity=Minor
...              alarm_description="SSH enabled"
...              alarm_resource=MRBTS-1/EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-1

&{FAULT_61652}    fault_id=61652
...              alarm_id=7220
...              alarm_severity=Minor
...              alarm_description="R&D Service Port enabled"
...              alarm_resource=MRBTS-1/EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-1

&{FAULT_7305}    fault_id=7305
...              alarm_id=7107
...              alarm_severity=Critical
...              alarm_description="NG SCTP setup fail"
...              alarm_resource=MRBTS-1/NRBTS-1/SERVEDAMF-1

&{FAULT_7300}    fault_id=7300
...              alarm_id=7107
...              alarm_severity=Major
...              alarm_description="No X2 link available"
...              alarm_resource=MRBTS-1/NRBTS-1

&{FAULT_7319}    fault_id=7319
...              alarm_id=7107
...              alarm_severity=Major
...              alarm_description="No X2 link available for a specific LTEENB"
...              alarm_resource=MRBTS-1/NRBTS-1/LTEENB-0

&{FAULT_7100}    fault_id=7100
...              alarm_id=7114
...              alarm_severity=Major
...              alarm_description="F1 Cell activation failed due to link unavailable"
...              alarm_resource=MRBTS-1/NRBTS-1/NRCELL-1

&{FAULT_7103}    fault_id=7103
...              alarm_id=7114
...              alarm_severity=Major
...              alarm_description="SA cell activation failed"
...              alarm_resource=MRBTS-1/NRBTS-1/NRCELL-1

&{FAULT_7516}    fault_id=7516
...              alarm_id=7114
...              alarm_severity=Critical
...              alarm_description="Incorrect cell parameter configuration"
...              alarm_resource=MRBTS-1/NRBTS-1/NRCELL-1

&{FAULT_7523}    fault_id=7523
...              alarm_id=7115
...              alarm_severity=Minor
...              alarm_description="Cell Activation timeout at gNB-DU"
...              alarm_resource=MRBTS-1/NRBTS-1/NRCELL-1

&{FAULT_6450}    fault_id=6450
...              alarm_id=7115
...              alarm_severity=Minor
...              alarm_description="Diagnostic Files collected"
...              alarm_resource=MRBTS-1/EQM-1/APEQM-1/CABINET-1/SMOD-1

@{ALLOWED_ALARMS}    &{FAULT_4654}   &{FAULT_4655}   &{FAULT_4681}   &{FAULT_61649}   &{FAULT_61524}   &{FAULT_61652}
...    &{FAULT_7305}   &{FAULT_7300}   &{FAULT_7319}   &{FAULT_7100}   &{FAULT_7103}   &{FAULT_7516}   &{FAULT_7523}
...    &{FAULT_4298}   &{FAULT_4334}   &{FAULT_6450}

*** Keywords ***
ABION_Activation_and_cancellation_of_the_fault_1937_EFaultId_FrDangerouslyOverheat
    log to console  Start test fault 1937
    Get reasoning path for 1937
    Wait Until Keyword Succeeds   600    60    ADMIN INFOMODEL Check If BTS Is OnAir
    Run Keyword And Ignore Error    ADMIN Assert No Unexpected Active Alarms    alowed_alarms_list=@{ALLOWED_ALARMS}
    SYSTEM Check if fault is not in active raw alarm  1937  EFaultId_FrDangerouslyOverheat
    Check ReasoningStatus Empty for 1937
    ADMIN Check If Alarm Is Not Active  fault_id=1937

    Generate fault 1937 on RMOD

    Check ReasoningStatus for 1937
    Sleep   10
    SYSTEM Check if fault is in active raw alarm  1937  EFaultId_FrDangerouslyOverheat
    ADMIN Check If Alarm Is Active  fault_id=1937
    Check not uncommissioned state
    Sleep  10
    Disable fault 1937 on RMOD
    Sleep  10
    ADMIN Check If Alarm Is Not Active  fault_id=1937
    ADMIN Check If Alarm Is In Historical Alarms  fault_id=1937
    Check ReasoningStatus Empty for 1937
    Wait Until Keyword Succeeds   900   30   ADMIN INFOMODEL Check If BTS Is OnAir
    ADMIN Assert No Unexpected Active Alarms    alowed_alarms_list=@{ALLOWED_ALARMS}
    Sleep  10s
    Reset and on configured
    [Teardown]    Run Keyword And Ignore Error    Disable fault 1937 on RMOD

ABION_Activation_and_cancellation_of_the_fault_4383_EFaultId_VirtualNodeNotRespondingAl
    log to console  Start test fault 4383
    Wait Until Keyword Succeeds    600    60    ADMIN INFOMODEL Check If BTS Is OnAir
    Run Keyword And Ignore Error    ADMIN Assert No Unexpected Active Alarms    alowed_alarms_list=@{ALLOWED_ALARMS}
    SYSTEM Check if fault is not in active raw alarm  4383   EFaultId_VirtualNodeNotRespondingAl
    ADMIN Check If Alarm Is Not Active  fault_id=4383

    Get Version Of Active SW
    Run Keyword If  '${version}' == '${TRUNK_VERSION}'   Trigger Fault 4383 And Check Active Fault
    Run Keyword If  '${version}' == 'SBTS22R2'   Trigger Fault 4383 And Should Have Been Raised

    Sleep  180
    SYSTEM Check if fault is not in active raw alarm  4383   EFaultId_VirtualNodeNotRespondingAl
    ADMIN Check If Alarm Is Not Active  fault_id=4383
    ${configured}   Run Keyword And Return Status   Wait Until Keyword Succeeds   900   30   ADMIN INFOMODEL Check If BTS Is Configured
    Run Keyword Unless   ${configured}    Wait Until Keyword Succeeds   900   30   ADMIN INFOMODEL Check If BTS Is Onair
    ADMIN Assert No Unexpected Active Alarms    alowed_alarms_list=@{ALLOWED_ALARMS}

ABION_Activation_and_cancellation_of_the_fault_7100_EFaultId_GnbCellActivationFailedX2Al
    log to console  Start test fault 7100
    Wait Until Keyword Succeeds    600    60    ADMIN INFOMODEL Check If BTS Is OnAir
    Run Keyword And Ignore Error    ADMIN Assert No Unexpected Active Alarms    alowed_alarms_list=@{ALLOWED_ALARMS}
    Get reasoning path for 710x
    SYSTEM Check if fault is not in active raw alarm  7100   EFaultId_GnbCellActivationFailedX2Al
    ADMIN Check If Alarm Is Not Active  fault_id=7100
    ADMIN Check If Alarm Is Not Active  fault_id=7300
    ADMIN Perform Delta Recommissioning                 delta_file=${X2LinkLock}
    ...                                                 skip_parameter_relation_errors=True
    log to console   wait fault 7300
    ADMIN Check If Alarm Is Active With Timeout  fault_id=7300  timeout=180
    log to console  restart iphy
#    SYSTEM Execute Command On IPHY  ddal -s ddal_reboot_graceful
    SYSTEM Execute Command On IPHY  reboot --reboot
    SYSTEM Wait Till Iphy Will Not Be Pingable For A Given Period
    SYSTEM Wait For Host Is Reachable With Ping  192.168.200.1
    log to console   wait fault 7100
    ADMIN Check If Alarm Is Active With Timeout  fault_id=7100  timeout=1800
    Check ReasoningStatus for 7100

    ADMIN Perform Delta Recommissioning                 delta_file=${X2LinkUnlock}
    ...                                                 skip_parameter_relation_errors=True
    Sleep  10s
    Reset and on configured
    SYSTEM Check if fault is not in active raw alarm  7100   EFaultId_GnbCellActivationFailedX2Al
    ADMIN Check If Alarm Is Not Active  fault_id=7100
    Check ReasoningStatus Empty for 710x
    Wait Until Keyword Succeeds   900   30   ADMIN INFOMODEL Check If BTS Is Configured
    ADMIN Assert No Unexpected Active Alarms    alowed_alarms_list=@{ALLOWED_ALARMS}

ABION_Activation_and_cancellation_of_the_fault_7101_EFaultId_GnbCpCellUpdateFailedAl
    log to console  Start test fault 7101
    Wait Until Keyword Succeeds    600    60    ADMIN INFOMODEL Check If BTS Is OnAir
    Run Keyword And Ignore Error    ADMIN Assert No Unexpected Active Alarms    alowed_alarms_list=@{ALLOWED_ALARMS}
    Get reasoning path for 710x
    SYSTEM Check if fault is not in active raw alarm  7101   EFaultId_GnbCpCellUpdateFailedAl
    ADMIN Check If Alarm Is Not Active  fault_id=7101
    ADMIN Perform Delta Recommissioning                 delta_file=${fPdcchMonOccsnPo_378}
    ...                                                 skip_parameter_relation_errors=True
    ADMIN Perform Delta Recommissioning                 delta_file=${nsaCellActivationAlarmTimer_240}
    ...                                                 skip_parameter_relation_errors=True

    Blocking cell
    ADMIN Check If Alarm Is Active With Timeout  fault_id=49  timeout=180
    SYSTEM Execute Command On gNB
#     ...    command=iptables -I INPUT 1 -s 10.0.1.121 -p sctp --chunk-types any DATA -j REJECT
     ...    command=iptables -I INPUT 1 -s 10.0.1.137 -p sctp --chunk-types any DATA -j REJECT
    sleep   10
    Unblocking cell

    log to console   Wait fault 7101
    ADMIN Check If Alarm Is Active With Timeout  fault_id=7101  timeout=180
    Check ReasoningStatus for 7101

    ADMIN Perform Delta Recommissioning                 delta_file=${nsaCellActivationAlarmTimer_600}
    ...                                                 skip_parameter_relation_errors=True
    ADMIN Perform Delta Recommissioning                 delta_file=${fPdcchMonOccsnPo_154}
    ...                                                 skip_parameter_relation_errors=True

    Reset and on configured
    SYSTEM Check if fault is not in active raw alarm  7101   EFaultId_GnbCpCellUpdateFailedAl
    ADMIN Check If Alarm Is Not Active  fault_id=7101
    Check ReasoningStatus Empty for 710x
    Wait Until Keyword Succeeds   900   30   ADMIN INFOMODEL Check If BTS Is Configured
    ADMIN Assert No Unexpected Active Alarms    alowed_alarms_list=@{ALLOWED_ALARMS}

#---------------------------------------------------------------------
Test Preconditions
    Log
    ...    message=\n+ Stated Test PREconditions ${TEST_NAME}
    ...    console=yes
    LOGGING Start Logging
    ${out_mrbts_id}=    taf.sbts.oam.coam.admin.Get Bts Info
    Set Test Variable    ${OUT_MRBTS_ID}    ${out_mrbts_id['mrbtsID']}
    Log Variables
    Log
    ...    message=\n+ Finished Test PREconditions: ${TEST_NAME}
    ...    console=yes

Blocking cell
    Get NRCELL_R path
    taf.sbts.oam.coam.admin.Block    dist_name=${NRCELL_R_path_1}

Unblocking cell
	taf.sbts.oam.coam.admin.Unblock   dist_name=${NRCELL_R_path_1}

Get NRCELL_R path
    ${NRCELL_R_distname}    Get Object Distname From Class Name if List
    ...    class_name=NRCELL_R
    ${NRCELL_R_distname_1}=   get from list   ${NRCELL_R_distname}   0
    ${NRCELL_R_distname_2}=   get from list   ${NRCELL_R_distname}   1
    ${NRCELL_R_path_1}=   Set variable   ${NRCELL_R_distname_1}
    ${NRCELL_R_path_2}=   Set variable   ${NRCELL_R_distname_2}
    Set test variable   ${NRCELL_R_path_1}
    Set test variable   ${NRCELL_R_path_2}

#Check not uncommissioned state
#    Run Keyword If     '${OUT_ADMIN_SMOD_POSITION}' == 'left'
#    ...       Check If BTS Is Not In Uncommissioned State
#    Run Keyword If     '${OUT_ADMIN_SMOD_POSITION}' == 'right'
#    ...       Check If BTS Isn't In Uncommissioned State

Check ReasoningStatus Empty for 1937
    ADMIN INFOMODEL Check ReasoningStatus Value is Empty
    ...    dist_name=${reasoning_path_1937_1}
    ADMIN INFOMODEL Check ReasoningStatus Value is Empty
    ...    dist_name=${reasoning_path_1937_2}

Get reasoning path for 1937
    ${RMOD_distname}    Get Object Distname From Class Name if List
    ...    class_name=RMOD_L
    ${RMOD_distname_1}=   get from list   ${RMOD_distname}   0
    ${RMOD_distname_2}=   get from list   ${RMOD_distname}   1
    ${reasoning_path_1937_1}=   Set variable   ${RMOD_distname_1}/RU_L-1
    ${reasoning_path_1937_2}=   Set variable   ${RMOD_distname_2}/RU_L-1
    Set test variable   ${reasoning_path_1937_1}
    Set test variable   ${reasoning_path_1937_2}

Check ReasoningStatus for 1937
    ${is_present}    Run Keyword And Return Status    Wait Until Keyword Succeeds
    ...    300  60  ADMIN INFOMODEL Check ReasoningStatus Value
    ...    dist_name=${reasoning_path_1937_1}
    ...    value=DangerouslyOverheated
    Run Keyword Unless    ${is_present}    Wait Until Keyword Succeeds
    ...    300  60  ADMIN INFOMODEL Check ReasoningStatus Value
    ...    dist_name=${reasoning_path_1937_2}
    ...    value=DangerouslyOverheated

Check ReasoningStatus Empty for 710x
    ADMIN INFOMODEL Check ReasoningStatus Value is Empty
    ...    dist_name=${reasoning_path_710x_1}
    ADMIN INFOMODEL Check ReasoningStatus Value is Empty
    ...    dist_name=${reasoning_path_710x_2}

Get reasoning path for 710x
    ${NRCELL_distname}    Get Object Distname From Class Name if List
    ...    class_name=NRCELL_L
    ${NRCELL_distname_1}=   get from list   ${NRCELL_distname}   0
    ${NRCELL_distname_2}=   get from list   ${NRCELL_distname}   1
    ${reasoning_path_710x_1}=   Set variable   ${NRCELL_distname_1}
    ${reasoning_path_710x_2}=   Set variable   ${NRCELL_distname_2}
    Set test variable   ${reasoning_path_710x_1}
    Set test variable   ${reasoning_path_710x_2}

Check ReasoningStatus for 7100
    ${is_present}    Run Keyword And Return Status    Wait Until Keyword Succeeds
    ...    300  60  ADMIN INFOMODEL Check ReasoningStatus Value
    ...    dist_name=${reasoning_path_710x_1}
    ...    value=GnbCellActivationFailedX2Degraded
    Run Keyword Unless    ${is_present}    Wait Until Keyword Succeeds
    ...    300  60  ADMIN INFOMODEL Check ReasoningStatus Value
    ...    dist_name=${reasoning_path_710x_2}
    ...    value=GnbCellActivationFailedX2Degraded

Check ReasoningStatus for 7101
    ${is_present}    Run Keyword And Return Status    Wait Until Keyword Succeeds
    ...    300  60  ADMIN INFOMODEL Check ReasoningStatus Value
    ...    dist_name=${reasoning_path_710x_1}
    ...    value=GnbCpCellUpdateFailedNSA
    Run Keyword Unless    ${is_present}    Wait Until Keyword Succeeds
    ...    300  60  ADMIN INFOMODEL Check ReasoningStatus Value
    ...    dist_name=${reasoning_path_710x_2}
    ...    value=GnbCpCellUpdateFailedNSA

Check if fault is not in active raw alarm
      [Arguments]    ${fault_id}
    ...              ${EFaultId}
    ${RawAlarms}=   taf.sbts.oam.coam.admin.get raw alarm history file
    ${RawAlamrsActive}=  fetch from left  ${RawAlarms}  Inactive faults
    Should not contain  ${RawAlamrsActive}  (${fault_id})
    Should not contain  ${RawAlamrsActive}  ${EFaultId}

Generate fault ${fault_id} on RMOD
    Telnet.Open Connection  192.168.200.1  port=8023  prompt=>  newline=LF
    Telnet.Execute Command  trigger_rf_fault 0 ${fault_id} module MAJ
    Sleep	5s
    Telnet.Close All Connections

Disable fault ${fault_id} on RMOD
    Telnet.Open Connection  192.168.200.1  port=8023  prompt=>  newline=LF
    Telnet.Execute Command  cancel_rf_fault 0 ${fault_id} module
    Sleep	5s
    Telnet.Close All Connections

Reset and on configured
    admin.ADMIN Reset Site
    Wait Until Keyword Succeeds
    ...    900
    ...    30
    ...    ADMIN INFOMODEL Check If BTS Is Configured

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

Get Object Distname From Class Name if List
    [Arguments]    ${class_name}
    ...            ${timeout}=60
    ...            ${alias}=${ADMIN_ALIAS}
    ${out_list_of_objects_parameters_dict}    taf.sbts.oam.coam.admin.Get Managed Objects
    ...    class_name=${class_name}
    ...    timeout=${timeout}
    ...    connection=${alias}
    @{distname_list}   create list
    FOR    ${element}    IN    @{out_list_of_objects_parameters_dict}
        ${distName}    Get From Dictionary    ${element}    distName
        append to list   ${distname_list}   ${distName}
    END
    [Return]    ${distName_list}

Trigger Fault 4383 And Check Active Fault
    Log To Console    Fault 4383 Trigger And Should Be Raised
    ssh.Open Connection    host=192.168.255.1    port=22    timeout=60
    ssh.Login    username=toor4nsn    password=oZPS0POrRieRtu    delay=1s
    ssh.Write    pkill -11 -f '/ffs/run/devicecfg/containers/FHNETNODE'
    ssh.Close Connection
    Wait Until Keyword Succeeds
    ...               60 sec
    ...               10 sec
    ...               ADMIN Is alarm active   fault_id=4383
    fault_trigger.Check If Recovery Action Is Performed
    Wait Until Keyword Succeeds
    ...               5 min
    ...               5 sec
    ...               keywords.Check not uncommissioned state

Get Version Of Active SW
    ${split_build}=    Split string       ${OUT_ACTIVE_SW}    separator=\_
    ${version}=       Get from list    ${split_build}    0
    Set Suite Variable   ${version}

*** Settings ***
Documentation
...    Author: Vlad Ichim (vlad.ichim@nokia.com)
...    Maintainer: Vlad Ichim (vlad.ichim@nokia.com)
...    Group in charge: MANO_SOAM3
...    References: doors
...    Feature Description: CB008423-5G_5GC000167
...    Sample execution: /opt/ute/python/bin/robot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log
...    -d results/ /home/ute/robotws/testsuite/Timisoara/OAM/ET/BOAM_VERIF_ET2/CB008423-5G_5GC000167/general.robot

Library        String
Library        Telnet
Library        OperatingSystem
Library        Process
Library     taf.sbts.oam.coam.admin
Library     taf.transport.ssh
Library     SSHLibrary

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
${reasoning_path_1937_right}=      /MRBTS-1/RAT-1/BTS_L-4/EQM_L-1/RMOD_L-2/RU_L-1

${skip_parameter_relation_errors}=      True
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
${SW_DESTINATION}     /home/ute

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

&{FAULT_7516}    fault_id=7516
...              alarm_id=7114
...              alarm_severity=Major
...              alarm_description="Incorrect cell parameter configuration"
...              alarm_resource=MRBTS-1/NRBTS-1/NRCELL-1

@{ALLOWED_ALARMS}    &{FAULT_4654}   &{FAULT_4655}   &{FAULT_4681}   &{FAULT_61649}   &{FAULT_61524}   &{FAULT_61652}
...    &{FAULT_7305}   &{FAULT_7300}   &{FAULT_7100}   &{FAULT_7103}    &{FAULT_7523}
...    &{FAULT_4298}   &{FAULT_4334}   &{FAULT_6450}   &{FAULT_7516}

${host}                      							 192.168.200.1
${port}                      							 8023
${emss_port}                                             ${4001}
${emss_host}                                             10.0.0.10
${rf_id}            									 1
${load_t0}      										 T0
${load_t1}    	   										 T1
${load_t2}    	   										 T2
${enb_hostname}                                          192.168.255.1
${enb_username}                                          toor4nsn
${enb_password}                                          oZPS0POrRieRtu
${SYSTEM_ENB_TRANSPORT_IP}                               192.168.255.129
${frmon}=                   frmonShellClient 127.0.0.1 2000
${tempest_file}=            /ram/tempest_inst1_default.json\\

*** Keywords ***
ABION_Activation_and_cancellation_of_the_fault_1937_EFaultId_FrDangerouslyOverheat
    log to console  Start test fault 1937
    Get reasoning path for 1937
    Wait Until Keyword Succeeds   600    60    ADMIN INFOMODEL Check If BTS Is OnAir
    Run Keyword And Ignore Error    ADMIN Assert No Unexpected Active Alarms    alowed_alarms_list=@{ALLOWED_ALARMS}
    SYSTEM Check if fault is not in active raw alarm  1937  EFaultId_FrDangerouslyOverheat
    Check ReasoningStatus Empty for 1937
    ADMIN Check If Alarm Is Not Active  fault_id=1937
    Run Keyword and Ignore Error    Prepare RMOD for SSH connection
    Generate fault 1937 on RMOD

    Check ReasoningStatus for 1937
    Sleep   10
    SYSTEM Check if fault is in active raw alarm  1937  EFaultId_FrDangerouslyOverheat
    ADMIN Check If Alarm Is Active  fault_id=1937
    Check not uncommissioned state
    Sleep  10
    Disable fault 1937 on RMOD
    Wait Until Keyword Succeeds  480   30    ADMIN Check If Alarm Is Not Active  fault_id=1937
    ADMIN Check If Alarm Is In Historical Alarms  fault_id=1937
    Check ReasoningStatus Empty for 1937
    Wait Until Keyword Succeeds   900   30   ADMIN INFOMODEL Check If BTS Is OnAir
    ADMIN Assert No Unexpected Active Alarms    alowed_alarms_list=@{ALLOWED_ALARMS}
    [Teardown]    Run Keyword And Ignore Error    Disable fault 1937 on RMOD

ABION_Activation_and_cancellation_of_the_fault_4383_EFaultId_VirtualNodeNotRespondingAl
    log to console  Start test fault 4383
    Wait Until Keyword Succeeds    600    60    ADMIN INFOMODEL Check If BTS Is OnAir
    Run Keyword And Ignore Error    ADMIN Assert No Unexpected Active Alarms    alowed_alarms_list=@{ALLOWED_ALARMS}
    SYSTEM Check if fault is not in active raw alarm  4383   EFaultId_VirtualNodeNotRespondingAl
    ADMIN Check If Alarm Is Not Active  fault_id=4383

    Trigger Fault 4383 And Should Have Been Raised

    Sleep  180
    SYSTEM Check if fault is not in active raw alarm  4383   EFaultId_VirtualNodeNotRespondingAl
    ADMIN Check If Alarm Is Not Active  fault_id=4383
    Wait Until Keyword Succeeds   900   30   ADMIN INFOMODEL Check If BTS Is OnAir
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
#    Wait Until Keyword Succeeds   900   30   ADMIN INFOMODEL Check If BTS Is Configured
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
     ...    command=iptables -I INPUT 1 -s 10.0.1.121 -p sctp --chunk-types any DATA -j REJECT
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

Generate fault 1937 on RMOD
    log to console      generate fault 1937
    SYSTEM Open SSH Connection To Enb
    SSHLibrary.Write    lxc-attach -n 0x2018
    SSHLibrary.Read Until    expected=>
    Sleep  3
    SSHLibrary.Write    ssh 172.16.77.129
#    SSHLibrary.Read Until    expected=?
#    SSHLibrary.Write    yes
#    SSHLibrary.Read Until    expected=password:
#
#    #SSHLibrary.Write    w@=EIj7P6R0bVy85OjCVa^ho&8
#    SSHLibrary.Write    Pl(FzaYj5~c5;q
#    SSHLibrary.Read Until     expected=$
#    SSHLibrary.Write    sudo -i
    SSHLibrary.Read Until     expected=#
    SSHLibrary.Write    echo /CI/ConfigAccess_Module action terminate |${frmon}
    SSHLibrary.Read Until     expected=#
   # SSHLibrary.Write    echo /trx1 action terminate |${frmon}
    #SSHLibrary.Read Until     expected=#
  #  SSHLibrary.Write    echo / action create ThermometerDevice /trx1 /module/ASC0_internal_BMR |${frmon}
    #SSHLibrary.Read Until     expected=#
## SSHLibrary.Write   / action create ConfigAccess /ca /module
    SSHLibrary.Write    echo / action create ConfigAccess /CI/ConfigAccess_Module /module |${frmon}
    SSHLibrary.Read Until     expected=#
## SSHLibrary.Write   /ca action fetch DECODED "type/tempest_inst1.bin" "/var/tmp/tempest_inst1.json"
    SSHLibrary.Write    echo /CI/ConfigAccess_Module action fetch DECODED \\"tempest_inst1.bin\\" \\"${tempest_file}" |${frmon}
    SSHLibrary.Read Until     expected=#
## SSHLibrary.Write   /ca action fetch DECODED "type/tcs.bin" "/var/tmp/tcs.json"
#    SSHLibrary.Write    echo /ca action fetch DECODED \\"tcs.bin\\" \\"/var/tmp/tcs_default.json\\" |${frmon}
#    SSHLibrary.Read Until     expected=#
## SSHLibrary.Write    cp /var/tmp/tempest_inst1.json /var/tmp/tempest_inst1_default.json
## ${list_tempOffset_default}=   SSHLibrary.Write   cat /var/tmp/tempest_inst1.json | grep tempOffset
    SSHLibrary.Write     cat /ram/tempest_inst1_default.json|grep tempOffset
    SSHLibrary.Read Until     expected=#
## SSHLibrary.Write   sed -i 's/"tempOffset": 0,/"tempOffset": 65,/g' /var/tmp/tempest_inst1.json
     SSHLibrary.Write   sed -i 's/"tempOffset": -57.0,/"tempOffset": 65,/g' /ram/tempest_inst1_default.json
     SSHLibrary.Read Until     expected=#
## SSHLibrary.Write   sed -i 's/"tempOffset": 5.0,/"tempOffset": 65,/g' /var/tmp/tempest_inst1.json
## SSHLibrary.Write   sed -i 's/"tempOffset": 23.0,/"tempOffset": 65,/g' /var/tmp/tempest_inst1.json
## ${list_tempOffset_65}=   SSHLibrary.Write   cat /var/tmp/tempest_inst1.json | grep tempOffset
    SSHLibrary.Write     cat /ram/tempest_inst1_default.json|grep tempOffset
    SSHLibrary.Read Until     expected=#
## SSHLibrary.Write   /ca action store TEMPORARY DECODED "type/tempest_inst1.bin" "/var/tmp/tempest_inst1.json"
    SSHLibrary.Write    echo /CI/ConfigAccess_Module action store TEMPORARY DECODED \\"tempest_inst1.bin\\" \\"${tempest_file}" |${frmon}
    SSHLibrary.Read Until     expected=#
## SSHLibrary.Write   /ca action update
    SSHLibrary.Write    echo /CI/ConfigAccess_Module action update|${frmon}
    SSHLibrary.Read Until     expected=#
## SSHLibrary.Write   / action create ThermometerDevice /trx1 /module/ASC0_internal_BMR
#    SSHLibrary.Write    echo / action create ThermometerDevice /trx1 /module/ASC0_internal_BMR |frmonShellClient 127.0.0.1 2000
#    SSHLibrary.Read Until     expected=#
## SSHLibrary.Write   /trx1 action override TEMPERATURE 65
  #  SSHLibrary.Write    echo /trx1 action override TEMPERATURE 65 |${frmon}
   # SSHLibrary.Read Until     expected=#
    SSHLibrary.Close Connection
#    Sleep         400s

Disable fault 1937 on RMOD
    log to console      disable fault 1937
    SYSTEM Open SSH Connection To Enb
    SSHLibrary.Write    lxc-attach -n 0x2018
    SSHLibrary.Read Until    expected=>
    Sleep  3
    SSHLibrary.Write    ssh 172.16.77.129
#    SSHLibrary.Read Until    expected=?
#    SSHLibrary.Write    yes
#    SSHLibrary.Read Until    expected=password:
#    #SSHLibrary.Write    w@=EIj7P6R0bVy85OjCVa^ho&8
#     SSHLibrary.Write    Pl(FzaYj5~c5;q


    SSHLibrary.Read Until     expected=#
# SSHLibrary.Write   /ca action store TEMPORARY DECODED "type/tempest_inst1.bin" "/var/tmp/tempest_inst1_default.json"
    SSHLibrary.Write   sed -i 's/"tempOffset": 65,/"tempOffset": -57.0,/g' /ram/tempest_inst1_default.json
    SSHLibrary.Read Until     expected=#
    SSHLibrary.Write     cat /ram/tempest_inst1_default.json|grep tempOffset
    SSHLibrary.Read Until     expected=#
    SSHLibrary.Write    echo /CI/ConfigAccess_Module action store TEMPORARY DECODED \\"tempest_inst1.bin\\" \\"${tempest_file}" |${frmon}
    SSHLibrary.Read Until     expected=#
# SSHLibrary.Write   /ca action update
    SSHLibrary.Write    echo /CI/ConfigAccess_Module action update |${frmon}
    SSHLibrary.Read Until     expected=#
# SSHLibrary.Write   /trx1 action override TEMPERATURE 51
    SSHLibrary.Write    echo /trx1 action override OFF |${frmon}
    SSHLibrary.Read Until     expected=#
    SSHLibrary.Write    echo /CI/ConfigAccess_Module action terminate |${frmon}
    SSHLibrary.Read Until     expected=#
    SSHLibrary.Write    echo /trx1 action terminate |${frmon}
    SSHLibrary.Read Until     expected=#
    SSHLibrary.Close Connection
#    Sleep         400s
# SSHLibrary.Write   /ca action terminate
# SSHLibrary.Write   /trx1 action terminate

Reset and on configured
    admin.ADMIN Reset Site
    Wait Until Keyword Succeeds
    ...    900
    ...    10
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

Prepare RMOD for SSH connection
     SYSTEM Open SSH Connection To Enb
    SSHLibrary.Write    lxc-attach -n 0x2018
    SSHLibrary.Read Until    expected=>
    SSHLibrary.Write    ssh 172.16.77.129
    SSHLibrary.Read Until    expected=?
    SSHLibrary.Write    yes
    SSHLibrary.Read Until     expected=#
    SSHLibrary.Close Connection

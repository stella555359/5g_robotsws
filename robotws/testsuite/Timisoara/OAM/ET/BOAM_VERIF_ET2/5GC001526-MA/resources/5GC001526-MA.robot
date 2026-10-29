*** Settings ***
Documentation
...    Author: Izabela Muntean (izabela.muntean@nokia.com)
...    Maintainer: Izabela Muntean (izabela.muntean@nokia.com)
...    Group in charge: MANO_SOAM3
...    References: doors
...    Feature Description:5GC0001526-MA


Library        SSHLibrary
Library        String
Library        Telnet
Library        OperatingSystem
Library        Process
Library        taf.transport.ssh   WITH NAME   csn
Library        taf.pdu    WITH NAME    pdu
Library         ute_admin_infomodel

Resource    ../../resources/admin.robot
Resource   ../../resources/admin_infomodel.robot
Resource    ../../resources/pretest_posttest.robot
Resource    ../../resources/system.robot



*** Variables ***
${LOGGING_ENB_SYSLOG}=           True
${LOGGING_IPHY_SYSLOG}=          True
${LOGGING_ADMIN_LOG}=            True
${LOGGING_ADMIN_INFOMODEL_LOG}=  True
${LOGGING_EMSSIM_LOG}=           True

${SW_DESTINATION}     /home/ute
${SYSTEM_ENB_TRANSPORT_IP}=    192.168.255.129
${SYSTEM_ENB_SSH_USERNAME}=    toor4nsn
${SYSTEM_ENB_SSH_PASSWORD}=    oZPS0POrRieRtu
${LSS_addr}                     10.5.25.106
${LSS_username}                 coam
${LSS_password}                 zO&n1W*ktp7

${reasoning_path}=            /MRBTS-1/RAT-1/BTS_L-1/EQM_L-1/RMOD_L-1/RU_L-1
${gnsseR}=                    /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-1/GNSSE_R-1
${scf_path}             /tmp/
${scf_name}             scf_file.xml

${BTS_metadata}=                BTS1_*_metadata.txt
${host}=                        10.255.3.26
${port}=                        4

${FAULT_2080}    fault_id=2080
...              alarm_id=7101
...              alarm_severity=Warning
...              alarm_description="BTS secondary core autonomous reset as recovery action"
...              alarm_resource=MRBTS-1/EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-1

&{FAULT_4592}    fault_id=4592
...              alarm_id=7115
...              alarm_severity=Warning
...              alarm_description="BTS Reset Cause"
...              alarm_resource=MRBTS-1/EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-2

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

&{FAULT_4352_Warning}    fault_id=4352
...              alarm_id=7101
...              alarm_severity=Warning
...              alarm_description="BTS secondary core autonomous reset as recovery action"
...              alarm_resource=MRBTS-1/EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-1

&{FAULT_4352_Critical}    fault_id=4352
...              alarm_id=7116
...              alarm_severity=Minor
...              alarm_description="No connection between primary and BTS extension system module"
...              alarm_resource=MRBTS-1/EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-1

&{FAULT_7308}    fault_id=7308
...              alarm_id=7107
...              alarm_severity=Major
...              alarm_description="Transfer layer connection failure in X2 interface"
...              alarm_resource=MRBTS-1/RAT-1/NRTS-1/NRBTS_L-1/LTEENB_L-1

&{FAULT_7220}    fault_id=61510
...              alarm_id=7220
...              alarm_severity=Major
...              alarm_description="Automatic BTS Operator Certificate retrieval unsuccessful"
...              alarm_resource=MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/MNL_CONF_M-1/MNLENT_CONF_M-1/CERTHENT_CONF_M-1/CMP_R-1

&{FAULT_7319}    fault_id=7319
...              alarm_id=7107
...              alarm_severity=Major
...              alarm_description="No X2 link available for a specific LTEENB"
...              alarm_resource=MRBTS-1/RAT-1/NRTS-1/NRBTS_L-1/LTEENB_L-1

&{FAULT_4452}    fault_id=4452
...              alarm_id=7114
...              alarm_severity=Major
...              alarm_description="Phase error exceeds the interference limit"
...              alarm_resource=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-1


&{FAULT_7300}    fault_id=7300
...              alarm_id=7107
...              alarm_severity=Major
...              alarm_description="Transfer layer connection failure in X2 interface"
...              alarm_resource=MRBTS-1/RAT-1/NRTS-1/NRBTS_L-1/LTEENB_L-1





@{ALLOWED_ALARMS_1}    &{FAULT_61649}   &{FAULT_4681}


@{ALLOWED_ALARMS_2}    &{FAULT_4592}   &{FAULT_4654}   &{FAULT_4655}   &{FAULT_4681}   &{FAULT_4687}
...    &{FAULT_61524}   &{FAULT_61652}   &{FAULT_4352_Warning}   &{FAULT_4352_Critical}   &{FAULT_7308}
...       &{FAULT_7319}    &{FAULT_7220}    &{FAULT_61649}    #&{FAULT_7300}

@{ALLOWED_ALARMS}    &{FAULT_4592}   &{FAULT_4654}   &{FAULT_4655}   &{FAULT_4681}   &{FAULT_4687}
...    &{FAULT_61524}   &{FAULT_61652}   &{FAULT_7308}   &{FAULT_7319}    &{FAULT_61649}


*** Keywords ***

BTS_shall_raise_Fault_1898_EFaultId_PpsRefMissAl_with_severity_Major_when_BTS_does_not_receive_PPS_signal_from_any_of_the_configured_source
     ${selfSurvey}  Run Keyword and Return Status
     ...    ute_admin_infomodel.Query infomodel  query=every ${gnsseR} is [availabilityStatus=degraded,operationalState=disabled]  timeout=30
     BuiltIn.Run Keyword If  '${selfSurvey}' == 'True'      Run Keyword
     ...            Fail     msg=GPS Survey Ongoing
     Run Keyword Unless   ${selfSurvey}
     ...     BTS_shall_raise_Fault_1898_AfterSurvey


BTS_shall_raise_Fault_1898_AfterSurvey
    #BuiltIn.Wait Until Keyword Succeeds  600  30   ADMIN Wait Until BTS OnAir
    ADMIN Assert No Unexpected Active Alarms    alowed_alarms_list=@{ALLOWED_ALARMS_2}
    RMOD Disconnection via PDU   host=${host}   port=${port}
    Sleep  300
    run keyword and continue on failure    ADMIN Check If Alarm Is Active With Timeout  fault_id=1898  timeout=120
    RMOD Connection via PDU  host=${host}   port=${port}
    Sleep  400
    ADMIN Assert No Unexpected Active Alarms    alowed_alarms_list=@{ALLOWED_ALARMS_2}
    #BuiltIn.Wait Until Keyword Succeeds  600  30   ADMIN Wait Until BTS OnAir

Bts_shall_raise_fault_4452_EFaultId_PhaseErrorExceedsTheInterferenceLimitAl_with_severity_Critical_at_startup_when_initial_sync_is_not_reached
   ${selfSurvey}  Run Keyword and Return Status
    ...    ute_admin_infomodel.Query infomodel  query=every ${gnsseR} is [availabilityStatus=degraded,operationalState=disabled]  timeout=30
    BuiltIn.Run Keyword If  '${selfSurvey}' == 'True'      Run Keyword
    ...            Fail     msg=GPS Survey Ongoing
    Run Keyword Unless   ${selfSurvey}
    ...     BTS_shall_raise_Fault_4452_AfterSurvey

BTS_shall_raise_Fault_4452_AfterSurvey
    #BuiltIn.Wait Until Keyword Succeeds  600  30   ADMIN Wait Until BTS OnAir
    ADMIN Assert No Unexpected Active Alarms    alowed_alarms_list=@{ALLOWED_ALARMS_2}
    RMOD Disconnection via PDU   host=${host}   port=${port}
    admin.ADMIN Reset Site
    Sleep  300
    run keyword and continue on failure    ADMIN Check If Alarm Is Active With Timeout  fault_id=4452  timeout=120
    RMOD Connection via PDU  host=${host}   port=${port}
    Sleep  400
    ADMIN Assert No Unexpected Active Alarms    alowed_alarms_list=@{ALLOWED_ALARMS_2}
    #BuiltIn.Wait Until Keyword Succeeds  600  30   ADMIN Wait Until BTS OnAir

RMOD Connection via PDU
    [Arguments]  ${host}   ${port}
    pdu.setup_pdu     host=${host}    model=Gude     version=8221-1
    ${port_status}=   pdu.get_port_status    port=${port}
    should be equal    ${port_status}    off
    pdu.power_on     port=${port}

RMOD Disconnection via PDU
    [Arguments]  ${host}   ${port}
    pdu.setup_pdu     host=${host}    model=Gude     version=8221-1
    ${port_status}=   pdu.get_port_status    port=${port}
    should be equal    ${port_status}    on
    pdu.power_off     port=${port}

Wait for Site is pingable
	Wait Until Host Is Available    192.168.255.1      timeout=300
	Log To Console		The site is pingable

UTE TL Preparation
    [Documentation]  Keyword used for setting up local 5G TLs to onAir state, as UTE reserve it only to sw_upload state
    #TO DO:             Add Check for onAir State. For cases when the Suite is run more than one time
    PREPOST Setup Admin
    ADMIN Change R&D Port Status    status=True
    @{status}   Run Keyword and Ignore Error    ADMIN Check BTS onair
    Run Keyword If  '@{status}[0]' == 'FAIL'   Run Keyword  5GC001526-MA.Configured_SwDownload_SwUpdate_OnAir
    ...     ELSE    Log To Console  --- BTS already onAir ---
    ADMIN Teardown Admin

Configured_SwDownload_SwUpdate_OnAir
    ADMIN Check BTS Not Commisioned
    Get TL Hostname
    Get Software Release
    ${selfSurvey}  Run Keyword and Return Status
    ...    ute_admin_infomodel.Query infomodel  query=every ${gnsseR} is [availabilityStatus=degraded,operationalState=disabled]  timeout=30
    BuiltIn.Run Keyword If  '${selfSurvey}' == 'True'      Run Keyword
    ...            Fail     msg=GPS Survey Ongoing
    Run Keyword Unless   ${selfSurvey}   Configured_SwDownload_SwUpdate_OnAir_AfterSurvey

Configured_SwDownload_SwUpdate_OnAir_AfterSurvey
    ADMIN Perform Commissioning
    ...   scf_file=/home/ute/MN/UTE/robotws/custom-config/Timisoara/${tl_hostname}/${sw_release}/${tl_hostname}_SCF.xml
    ${configured}   Run Keyword and Return Status
    ...    BuiltIn.Wait Until Keyword Succeeds  1200  30   ADMIN Check BTS Configured
#    Run Keyword If  '${configured}' == 'True'  Sleep  180
#    Run Keyword Unless   ${configured}   Run Keywords   admin.ADMIN Reset Site
#    ...    AND     BuiltIn.Wait Until Keyword Succeeds  600  30   ADMIN Check BTS Configured
#    ...    AND     Sleep  180
    Log To Console  Fault ID23 Checking...
    ${result}   Run Keyword and Return Status    ADMIN Check If Alarm Is Active  fault_id=23
    BuiltIn.Run Keyword If  '${result}' == 'True'   Run Keywords
    ...    Log To Console  Fault ID23 found. Start RF Software Update
    ...     AND     ADMIN Download And Update Current Software
    ...     ELSE    Log To Console  Fault ID23 not found.
    ${onair}   Run Keyword and Return Status
    ...    BuiltIn.Wait Until Keyword Succeeds  1200  30   ADMIN Wait Until BTS OnAir
    Run Keyword Unless   ${onair}   Run Keywords   admin.ADMIN Reset Site
    ...    AND     BuiltIn.Wait Until Keyword Succeeds  600  30   ADMIN Wait Until BTS OnAir

SYSTEM Open SSH Connection
    [Arguments]    ${host}    ${port}    ${username}    ${password}
    SSHLibrary.Open Connection    host=${host}    port=${port}    timeout=60
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

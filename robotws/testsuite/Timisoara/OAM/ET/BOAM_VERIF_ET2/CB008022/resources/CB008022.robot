*** Settings ***
Documentation
...    Author: Monika Szlovak (monika.szlovak@nokia.com)
...    Maintainer: Monika Szlovak (monika.szlovak@nokia.com)
...    Group in charge: BOAM_VERIF_ET2
...    REQ: LTE_OPR_REQ_5771, LTE_OPR_REQ_32448, LTE_OPR_REQ_32451

Library        String
Library        Telnet
Library        OperatingSystem
Library        Process
Library     taf.sbts.oam.coam.admin
Library     taf.transport.ssh
Library        SSHLibrary
Library     taf.pdu    WITH NAME    pdu

Resource    ../../resources/admin.robot
Resource    ../../resources/pretest_posttest.robot
Resource    ../../resources/system.robot
Resource    ../../resources/fault_trigger.robot

*** Variables ***
${RMOD_Reduction}=           ${CURDIR}/RMOD_Reduction.json
${RMOD_Reduction_eCPRI}=     ${CURDIR}/RMOD_Reduction_eCPRI.json

${SW_DESTINATION}     /home/ute
${dist_name}          /MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/EQM_R-4/APEQM_R-1/RMOD_R-2
${dist_name_eCPRI}    /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/RMOD_R-1

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

@{ALLOWED_ALARMS}    &{FAULT_4654}   &{FAULT_4655}   &{FAULT_61649}   &{FAULT_61524}   &{FAULT_61652}   &{FAULT_4681}

*** Keywords ***
1_CPRI_RMOD_Reduction_Without_Service_Impact
    Run Keyword And Ignore Error    ADMIN Assert No Unexpected Active Alarms    alowed_alarms_list=@{ALLOWED_ALARMS}
    ${restartCounter_before}    ADMIN INFOMODEL Get Parameter Value
        ...    dist_name=/MRBTS-1/RAT-1/BTS_L-4/EQM_L-1/CABINET_L-1/SMOD_L-1
        ...    dict_param=restartCounter
    Get Version Of Active SW
    Get RMOD_R and NRCELL_R path before reduction
    log to console   RMOD Lock
    Lock RU via admin   ${dist_name}
    log to console   Check RMOD Adminstrative State is Locked
    ADMIN INFOMODEL Check AdministrativeState Value   ${dist_name}   Locked

    log to console   RMOD Disconnection via PDU
    RMOD Disconnection via PDU   10.255.3.24   10
    Wait Until Keyword Succeeds     30   5    Check availabilityStatus for RMOD   ${dist_name}   not installed
    Wait Until Keyword Succeeds     30   5    Check operationalState for RMOD   ${dist_name}   disabled
    wait until keyword succeeds  360  60  Check if fault is in active raw alarm  0010   EFaultId_NoConnectionToUnitAl
    ADMIN Check If Alarm Is Active With Timeout   fault_id=10    timeout=60

    log to console   delta commissioning for RMOD reduction
    ADMIN Perform Delta Recommissioning        delta_file=${RMOD_Reduction}
    ...                                        skip_parameter_relation_errors=True

    log to console   Check Fault 10 is cleared and BTS is OnAir
    wait until keyword succeeds  360  60  Check if fault is not in active raw alarm  0010   EFaultId_NoConnectionToUnitAl
    ADMIN Check If Alarm Is Not Active With Timeout   fault_id=10    timeout=60
    BuiltIn.Wait Until Keyword Succeeds  600  30   ADMIN Wait Until BTS OnAir
    Check if RMOD_R and corresponding cell are not visible in WebEM anymore
    ${restartCounter_after}    ADMIN INFOMODEL Get Parameter Value
        ...    dist_name=/MRBTS-1/RAT-1/BTS_L-4/EQM_L-1/CABINET_L-1/SMOD_L-1
        ...    dict_param=restartCounter
    Should Be Equal       ${restartCounter_after}    ${restartCounter_before}
    ADMIN Assert No Unexpected Active Alarms    alowed_alarms_list=@{ALLOWED_ALARMS}
    log to console   RMOD connection via PDU
    RMOD Connection via PDU   10.255.3.24   10
    Sleep   30
    Perform Recommissioning and wait BTS OnAir

5_eCPRI_RMOD_Reduction_Without_Service_Impact
    Run Keyword And Ignore Error    ADMIN Assert No Unexpected Active Alarms    alowed_alarms_list=@{ALLOWED_ALARMS}
    ${restartCounter_before}    ADMIN INFOMODEL Get Parameter Value
        ...    dist_name=/MRBTS-1/RAT-1/BTS_L-1/EQM_L-1/CABINET_L-1/SMOD_L-1
        ...    dict_param=restartCounter
    Get Version Of Active SW
    Get RMOD_R and NRCELL_R path before reduction
    log to console   RMOD Lock
    Lock RU via admin   ${dist_name_eCPRI}
    log to console   Check RMOD Adminstrative State is Locked
    ADMIN INFOMODEL Check AdministrativeState Value   ${dist_name_eCPRI}   Locked

    log to console   RMOD Disconnection via PDU
    RMOD eCPRI Disconnection via PDU   10.255.3.74   12
    Wait Until Keyword Succeeds     30   5    Check availabilityStatus for RMOD   ${dist_name_eCPRI}   not installed
    Wait Until Keyword Succeeds     30   5    Check operationalState for RMOD   ${dist_name_eCPRI}   disabled
    wait until keyword succeeds  360  60  Check if fault is in active raw alarm  0010   EFaultId_NoConnectionToUnitAl
    ADMIN Check If Alarm Is Active With Timeout   fault_id=10    timeout=60
    Sleep   30
    log to console   delta commissioning for RMOD reduction
    ADMIN Perform Delta Recommissioning        delta_file=${RMOD_Reduction_eCPRI}
    ...                                        skip_parameter_relation_errors=True

    log to console   Check Fault 10 is cleared and BTS is OnAir
    wait until keyword succeeds  360  60  Check if fault is not in active raw alarm  0010   EFaultId_NoConnectionToUnitAl
    ADMIN Check If Alarm Is Not Active With Timeout   fault_id=10    timeout=60
    BuiltIn.Wait Until Keyword Succeeds  600  30   ADMIN Wait Until BTS OnAir
    Check if RMOD_R and corresponding cell are not visible in WebEM anymore
    ${restartCounter_after}    ADMIN INFOMODEL Get Parameter Value
        ...    dist_name=/MRBTS-1/RAT-1/BTS_L-1/EQM_L-1/CABINET_L-1/SMOD_L-1
        ...    dict_param=restartCounter
    Should Be Equal       ${restartCounter_after}    ${restartCounter_before}
    ADMIN Assert No Unexpected Active Alarms    alowed_alarms_list=@{ALLOWED_ALARMS}
    log to console   RMOD connection via PDU
    RMOD eCPRI Connection via PDU   10.255.3.74   12
    Sleep   30
    Perform Recommissioning eCPRI and wait BTS OnAir

6_eCPRI_RMOD_Replacement_Without_Service_Impact
    Run Keyword And Ignore Error    ADMIN Assert No Unexpected Active Alarms    alowed_alarms_list=@{ALLOWED_ALARMS}
    ${restartCounter_before}    ADMIN INFOMODEL Get Parameter Value
        ...    dist_name=/MRBTS-1/RAT-1/BTS_L-1/EQM_L-1/CABINET_L-1/SMOD_L-1
        ...    dict_param=restartCounter
    log to console   RMOD Lock
    Lock RU via admin   ${dist_name_eCPRI}
    log to console   Check RMOD Adminstrative State is Locked
    ADMIN INFOMODEL Check AdministrativeState Value   ${dist_name_eCPRI}   Locked

    log to console   Wait 30s for disconnection RMOD
#    Sleep   30
    Wait Until Keyword Succeeds     60   5    Check availabilityStatus for RMOD   ${dist_name_eCPRI}   not installed
    Wait Until Keyword Succeeds     30   5    Check operationalState for RMOD   ${dist_name_eCPRI}   disabled
    wait until keyword succeeds  360  60  Check if fault is in active raw alarm  0010   EFaultId_NoConnectionToUnitAl
    ADMIN Check If Alarm Is Active With Timeout   fault_id=10    timeout=60

    log to console   Wait 30s for connection new RMOD
    Sleep   30
    wait until keyword succeeds  600  30  Check if fault is not in active raw alarm  0010   EFaultId_NoConnectionToUnitAl
    ADMIN Check If Alarm Is Not Active With Timeout   fault_id=10    timeout=60
    BuiltIn.Wait Until Keyword Succeeds  600  30   ADMIN Wait Until BTS OnAir
    log to console   RMOD Unlock
    Unlock RU via admin   ${dist_name_eCPRI}
    ${restartCounter_after}    ADMIN INFOMODEL Get Parameter Value
        ...    dist_name=/MRBTS-1/RAT-1/BTS_L-1/EQM_L-1/CABINET_L-1/SMOD_L-1
        ...    dict_param=restartCounter
    Should Be Equal       ${restartCounter_after}    ${restartCounter_before}
    ADMIN Assert No Unexpected Active Alarms    alowed_alarms_list=@{ALLOWED_ALARMS}

#...............................................
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

UTE TL Preparation
    [Documentation]     Keyword used for setting up local 5G TLs to onAir state, as UTE reserve it only to sw_upload state
    #TO DO:             Add Check for onAir State. For cases when the Suite is run more than one time
    PREPOST Setup Admin
    ADMIN Change R&D Port Status    status=True
    @{status}   Run Keyword and Ignore Error    ADMIN Check BTS onair
    Run Keyword If  '@{status}[0]' == 'FAIL'   Run Keyword  CB008022.Configured_SwDownload_SwUpdate_OnAir
    ...     ELSE    Log To Console  --- BTS already onAir ---
    ADMIN Teardown Admin

Configured_SwDownload_SwUpdate_OnAir
    ADMIN Check BTS Not Commisioned
    Get TL Hostname
    Get Software Release
    ADMIN Perform Commissioning
    ...     scf_file=/home/ute/MN/UTE/robotws/custom-config/Timisoara/${tl_hostname}/${sw_release}/${tl_hostname}_SCF.xml
    ...     skip_parameter_relation_errors=${True}
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

Get Version Of Active SW
    ${split_build}=    Split string       ${OUT_ACTIVE_SW}    separator=\_
    ${version}=       Get from list    ${split_build}    0
    Set Suite Variable   ${version}

Lock RU via admin
    [Arguments]  ${dist_name}
    Run Keyword If  '${version}' == 'SBTS22R3'    taf.sbts.oam.coam.admin.lock_RU   dist_name=${dist_name}   timeout=60
    ...    ELSE     taf.sbts.oam.coam.admin._lock    dist_name=${dist_name}   timeout=60

Unlock RU via admin
    [Arguments]  ${dist_name}
    Run Keyword If  '${version}' == 'SBTS22R3'    taf.sbts.oam.coam.admin.unlock_RU   dist_name=${dist_name}   timeout=60
    ...    ELSE     taf.sbts.oam.coam.admin._unlock   dist_name=${dist_name}   timeout=60

RMOD Disconnection via PDU
    [Arguments]  ${host}   ${port}
    pdu.setup_pdu     host=${host}    model=Gude     version=8221-1
    ${port_status}=   pdu.get_port_status    port=${port}
    should be equal    ${port_status}    on
    pdu.power_off     port=${port}

RMOD Connection via PDU
    [Arguments]  ${host}   ${port}
    pdu.setup_pdu     host=${host}    model=Gude     version=8221-1
    ${port_status}=   pdu.get_port_status    port=${port}
    should be equal    ${port_status}    off
    pdu.power_on     port=${port}

RMOD eCPRI Disconnection via PDU
     [Arguments]  ${host}   ${port}
    pdu.setup_pdu     host=${host}    model=EPC
    ${port_status}=   pdu.get_port_status    port=${port}
    should be equal    ${port_status}    off
    pdu.power_on     port=${port}

RMOD eCPRI Connection via PDU
    [Arguments]  ${host}   ${port}
    pdu.setup_pdu     host=${host}    model=EPC
    ${port_status}=   pdu.get_port_status    port=${port}
    should be equal    ${port_status}    on
    pdu.power_off     port=${port}

Get RMOD_R and NRCELL_R path before reduction
    ${RMOD_R_distname}    Get Object Distname From Class Name if List
    ...    class_name=RMOD_R
    ${RMOD_R_distname_1}=   get from list   ${RMOD_R_distname}   0
    ${RMOD_R_distname_2}=   get from list   ${RMOD_R_distname}   1
    log to console   RMOD before reduction ${RMOD_R_distname_1}
    log to console   RMOD before reduction ${RMOD_R_distname_2}
    ${NRCELL_R_distname}    Get Object Distname From Class Name if List
    ...    class_name=NRCELL_R
    ${NRCELL_R_distname_1}=   get from list   ${NRCELL_R_distname}   0
    ${NRCELL_R_distname_2}=   get from list   ${NRCELL_R_distname}   1
    ${NRCELL_R_path_1}=   Set variable   ${NRCELL_R_distname_1}
    ${NRCELL_R_path_2}=   Set variable   ${NRCELL_R_distname_2}
    log to console   NRCELL before reduction ${NRCELL_R_path_1}
    log to console   NRCELL before reduction ${NRCELL_R_path_2}

Check if RMOD_R and corresponding cell are not visible in WebEM anymore
    ${RMOD_R_distname}    Get Object Distname From Class Name if List
    ...    class_name=RMOD_R
    ${RMOD_R_distname_1}=   get from list   ${RMOD_R_distname}   0
    log to console   RMOD after reduction ${RMOD_R_distname_1}
    run keyword and expect error   IndexError: Given index 1 is out of the range 0-0.   get from list   ${RMOD_R_distname}   1
    ${NRCELL_R_distname}    Get Object Distname From Class Name if List
    ...    class_name=NRCELL_R
    ${NRCELL_R_distname_1}=   get from list   ${NRCELL_R_distname}   0
    log to console   NRCELL after reduction ${NRCELL_R_distname}
    run keyword and expect error   IndexError: Given index 1 is out of the range 0-0.   get from list   ${NRCELL_R_distname}   1

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

Restart admin connection
    ADMIN Teardown Admin
    ADMIN Setup Admin

Perform Recommissioning and wait BTS OnAir
    log to console   Perform commissioning
    Get TL Hostname
    Get Software Release
    ADMIN Perform Commissioning
    ...    scf_file=/home/ute/MN/UTE/robotws/custom-config/Timisoara/${tl_hostname}/${sw_release}/${tl_hostname}_SCF.xml
    ...    skip_parameter_relation_errors=True
    log to console   Check BTS is OnAir
    BuiltIn.Wait Until Keyword Succeeds  600  30   ADMIN Wait Until BTS OnAir
    Sleep   1000
    Restart admin connection

Perform Recommissioning eCPRI and wait BTS OnAir
    log to console   Perform commissioning
    ADMIN Perform Commissioning
    ...    scf_file=/home/ute/scf_MRBTS-10002_SBTS_5G_CRT2-auto.xml
    ...    skip_parameter_relation_errors=True
    log to console   Check BTS is OnAir
    BuiltIn.Wait Until Keyword Succeeds  660  30   ADMIN Wait Until BTS OnAir

Check AvailabilityStatus for RMOD
    [Arguments]      ${dist_name}   ${value}   #${timeout}=30s
    Check AvailabilityStatus Value
    ...      dist_name=${dist_name}
    ...      value=${value}

Check OperationalState for RMOD
    [Arguments]      ${dist_name}   ${value}   #${timeout}=30s
    Check OperationalState Value
    ...      dist_name=${dist_name}
    ...      value=${value}

Check AvailabilityStatus Value
    [Arguments]
    ...    ${dist_name}
    ...    ${value}
    ${dict_value}    taf.sbts.oam.coam.admin.get_parameters
    ...    dist_name=${dist_name}
    ...    pattern=

    ${dict_value}    Get From Dictionary   dictionary=${dict_value}   key=availabilityStatus
    should be equal as strings  ${dict_value}  ${value}   ignore_case=true

Check OperationalState Value
    [Arguments]
    ...    ${dist_name}
    ...    ${value}
    ${dict_value}    taf.sbts.oam.coam.admin.get_parameters
    ...    dist_name=${dist_name}
    ...    pattern=

    ${dict_value}    Get From Dictionary   dictionary=${dict_value}   key=operationalState
    should be equal as strings  ${dict_value}  ${value}   ignore_case=true



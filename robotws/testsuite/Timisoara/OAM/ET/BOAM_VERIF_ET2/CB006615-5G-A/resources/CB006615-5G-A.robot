*** Settings ***
Documentation
...    Author: Monika Szlovak (monika.szlovak@nokia.com)
...    Maintainer: Monika Szlovak (monika.szlovak@nokia.com)
...    Group in charge: MANO_SOAM3
...    References: doors
...    Feature Description: CB006615-5G-A

Library        String
Library        Telnet
Library        OperatingSystem
Library        Process
Library        taf.sbts.oam.coam.admin
Library        taf.transport.ssh
Library        taf.sbts.oam.coam.admin.interface.admin   WITH NAME   taf_admin
Library        taf.selenium.gnb.oam.coam.classical      WITH NAME   taf_selenium
Library        taf.pdu    WITH NAME    pdu

Resource    ./keywords.robot
Resource    ../../resources/admin.robot
Resource    ../../resources/pretest_posttest.robot
Resource    ../../resources/system.robot
Resource    ../../resources/fault_trigger.robot
Resource    ../../resources/selenium.robot

*** Variables ***
${LOGGING_ENB_SYSLOG}=           True
${LOGGING_IPHY_SYSLOG}=          True
${LOGGING_ADMIN_LOG}=            True
${LOGGING_ADMIN_INFOMODEL_LOG}=  True
${LOGGING_EMSSIM_LOG}=           True

${reasoningStatus_2080}=           stateInfo.reasoningStatus[?]="SrioHostLinkDown"
${reasoning_path_2080_left}=       /MRBTS-1/RAT-1/BTS_L-1/EQM_L-1/CABINET_L-1/SMOD_L-1/CCU_L-1
${reasoning_path_2080_right}=      /MRBTS-1/RAT-1/BTS_L-4/EQM_L-1/CABINET_L-1/SMOD_L-1/CCU_L-1

${scf_path}             /tmp/
${scf_name}             scf_file.xml
${SW_DESTINATION}       /home/ute

&{FAULT_2080}    fault_id=2080
...              alarm_id=7101
...              alarm_severity=Warning
...              alarm_description="BTS secondary core autonomous reset as recovery action"
...              alarm_resource=MRBTS-10797/EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-1

&{FAULT_4592}    fault_id=4592
...              alarm_id=7115
...              alarm_severity=Warning
...              alarm_description="BTS Reset Cause"
...              alarm_resource=MRBTS-10797/EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-2

&{FAULT_4655}    fault_id=4655
...              alarm_id=7220
...              alarm_severity=Minor
...              alarm_description="Service account root access is enabled"
...              alarm_resource=MRBTS-10797/MNL-1/MNLENT-1/SECADM-1

&{FAULT_61649}    fault_id=61649
...              alarm_id=7220
...              alarm_severity=Minor
...              alarm_description="LMP access via port 443"
...              alarm_resource=MRBTS-10797/EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-1

&{FAULT_4654}    fault_id=4654
...              alarm_id=7220
...              alarm_severity=Minor
...              alarm_description="Ethernet port security is disabled"
...              alarm_resource=MRBTS-10797/EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-1

&{FAULT_4681}    fault_id=4681
...              alarm_id=7111
...              alarm_severity=Major
...              alarm_description="Sanity Check Error"
...              alarm_resource=MRBTS-10797/EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-1

&{FAULT_4687}    fault_id=4687
...              alarm_id=7115
...              alarm_severity=Minor
...              alarm_description="CPRI RU Migration to eCPRI Mode Required"
...              alarm_resource=MRBTS-10797/EQM_R-1/APEQM_R-1/RMOD_R-1

&{FAULT_61524}    fault_id=61524
...              alarm_id=7220
...              alarm_severity=Minor
...              alarm_description="SSH enabled"
...              alarm_resource=MRBTS-10797/EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-1

&{FAULT_61652}    fault_id=61652
...              alarm_id=7220
...              alarm_severity=Minor
...              alarm_description="R&D Service Port enabled"
...              alarm_resource=MRBTS-10797/EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-1

&{FAULT_1850}    fault_id=1850
...              alarm_id=7111
...              alarm_severity=Critical
...              alarm_description="SW corrupted"
...              alarm_resource=MRBTS-10797/EQM_R-1/APEQM_R-1/RMOD_R-2

&{FAULT_4352_Warning}    fault_id=4352
...              alarm_id=7101
...              alarm_severity=Warning
...              alarm_description="BTS secondary core autonomous reset as recovery action"
...              alarm_resource=MRBTS-10797/EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-1

&{FAULT_4352_Critical}    fault_id=4352
...              alarm_id=7116
...              alarm_severity=Minor
...              alarm_description="No connection between primary and BTS extension system module"
...              alarm_resource=MRBTS-10797/EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-1

&{FAULT_7308}    fault_id=7308
...              alarm_id=7107
...              alarm_severity=Major
...              alarm_description="Transfer layer connection failure in X2 interface"
...              alarm_resource=MRBTS-1/RAT-1/NRTS-1/NRBTS_L-1/LTEENB_L-1

&{FAULT_7319}    fault_id=7319
...              alarm_id=7107
...              alarm_severity=Major
...              alarm_description="No X2 link available for a specific LTEENB"
...              alarm_resource=MRBTS-1/RAT-1/NRTS-1/NRBTS_L-1/LTEENB_L-1


@{ALLOWED_ALARMS_1}    &{FAULT_61649}   &{FAULT_4681}
@{ALLOWED_ALARMS_2}    &{FAULT_4592}   &{FAULT_4654}   &{FAULT_4655}   &{FAULT_4681}   &{FAULT_4687}   &{FAULT_61649}
...    &{FAULT_61524}   &{FAULT_61652}   &{FAULT_4352_Warning}   &{FAULT_4352_Critical}   &{FAULT_7308}   &{FAULT_7319}
@{ALLOWED_ALARMS}    &{FAULT_4592}   &{FAULT_4654}   &{FAULT_4655}   &{FAULT_4681}   &{FAULT_4687}   &{FAULT_61649}
...    &{FAULT_61524}   &{FAULT_61652}   &{FAULT_7308}   &{FAULT_7319}   &{FAULT_1850}


*** Keywords ***
SC_Autonomous_Recovery_Action_After_SysCom_Connection_Lost
    log to console   Start test2
    Wait Until Keyword Succeeds  300  10  ADMIN INFOMODEL Check If BTS Is OnAir
    ADMIN Assert No Unexpected Active Alarms    alowed_alarms_list=@{ALLOWED_ALARMS}
    Reboot dual ASIB Primary via PDU
    fault_trigger.Check If Recovery Action Is Performed
    Wait Until Keyword Succeeds    900    30    ADMIN INFOMODEL Check If BTS Is Configured
    Wait Until Keyword Succeeds    900    60    ADMIN INFOMODEL Check If BTS Is OnAir
    ADMIN Assert No Unexpected Active Alarms    alowed_alarms_list=@{ALLOWED_ALARMS}
#    Sleep   60
#    Reset and on configured
#    log to console   wait for BTS OnAir
#    Wait Until Keyword Succeeds    900    60    ADMIN INFOMODEL Check If BTS Is OnAir

Secondary_Core_hot_swap_hot_insert
    log to console   Start test3
    ADMIN INFOMODEL Check If BTS Is OnAir
    ADMIN Check If Alarm Is Not Active  fault_id=4352
    Hot Remove dual ASIB Secondary
    run keyword and continue on failure    ADMIN Check If Alarm Is Active With Timeout  fault_id=4352  timeout=60
    ADMIN Assert No Unexpected Active Alarms    alowed_alarms_list=@{ALLOWED_ALARMS_2}
    Hot Insert dual ASIB Secondary
    Wait Until Keyword Succeeds    900    30    ADMIN INFOMODEL Check If BTS Is Configured
    Wait Until Keyword Succeeds    900    60    ADMIN INFOMODEL Check If BTS Is OnAir
    ADMIN Check If Alarm Is Not Active  fault_id=4352
    ADMIN Assert No Unexpected Active Alarms    alowed_alarms_list=@{ALLOWED_ALARMS}
#    Reset and on configured
#    log to console   wait for BTS OnAir
#    Wait Until Keyword Succeeds    900    60    ADMIN INFOMODEL Check If BTS Is OnAir

Fault_handling_not_commissioned
    log to console   Start test5
    Check If BTS Is Not In Uncommissioned State
    ADMIN INFOMODEL Check If BTS Is OnAir
    ADMIN Collect Scf    local_dir_path=${scf_path}    file_name=${scf_name}
    ${commission_file}    set variable    ${scf_path}${scf_name}
    log to console   Perform reset configuration
    taf_admin.Reset Configuration
    Wait Until Keyword Succeeds    900    30    ADMIN Check BTS Not Commisioned
    Wait Until Keyword Succeeds    180    30    ADMIN Check If Alarm Is Active    fault_id=61649
    ADMIN Assert No Unexpected Active Alarms    alowed_alarms_list=@{ALLOWED_ALARMS_1}
    Sleep    60
    log to console   Perform commissioning
    ADMIN Perform Commissioning   ${scf_path}${scf_name}
    Wait Until Keyword Succeeds    600    60    ADMIN INFOMODEL Check If BTS Is Commissioned
    Wait Until Keyword Succeeds    900    60    ADMIN INFOMODEL Check If BTS Is OnAir
    ADMIN Check If Alarm Is Active    fault_id=61649
    ADMIN Assert No Unexpected Active Alarms    alowed_alarms_list=@{ALLOWED_ALARMS}

Robustness_Testing_SC_Autonomous_Reset_on_fault_detection
    log to console   Start test7
    Wait Until Keyword Succeeds  300  10  ADMIN INFOMODEL Check If BTS Is OnAir
    ADMIN Check If Alarm Is Not Active  fault_id=2080
    log to console   Trigger fault 2080 for first time
    Trigger fault 2080 and wait recovery
    Sleep   30
    ADMIN Check If Alarm Is Not Active  fault_id=2080
    log to console   Trigger fault 2080 for second time
    Trigger fault 2080 and wait recovery
    Sleep   30
    ADMIN Check If Alarm Is Not Active  fault_id=2080
    log to console   Trigger fault 2080 for the third time
    Trigger fault 2080 and wait recovery
    Sleep   30
    ADMIN Check If Alarm Is Not Active  fault_id=2080
    log to console   Trigger fault 2080 for the fourth time
    Trigger fault for fourth time and perform site reset

#...............................................................................................
Trigger fault 2080 and wait recovery
    Trigger fault 2080 in RD models
    Check ReasoningStatus for 2080
    fault_trigger.Check If Recovery Action Is Performed
    Wait Until Keyword Succeeds    900    30    ADMIN INFOMODEL Check If BTS Is Configured
    ADMIN Check If Alarm Is Not Active  fault_id=2080
    log to console   wait for BTS OnAir
    Wait Until Keyword Succeeds    1200    60    ADMIN INFOMODEL Check If BTS Is OnAir

Trigger fault for fourth time and perform site reset
    Trigger fault 2080 in RD models
    Check ReasoningStatus for 2080
    ADMIN Check If Alarm Is Active With Timeout  fault_id=2080  timeout=300
    #run keyword and continue on failure    SYSTEM Check if fault is in active raw alarm  2080  EFaultId_SrioHostLinkDownAl
    Sleep   10
    admin.ADMIN Reset Site
    Sleep   60
    Wait Until Keyword Succeeds    900    30    ADMIN INFOMODEL Check If BTS Is Configured
    ADMIN Check If Alarm Is Not Active  fault_id=2080
    SYSTEM Check if fault is not in active raw alarm  2080   EFaultId_SrioHostLinkDownAl
    log to console   wait for BTS OnAir
    Wait Until Keyword Succeeds    1800    60    ADMIN INFOMODEL Check If BTS Is OnAir

Trigger fault 2080 in RD models
    CoamAdmin.Send Hwapi Api2 Alarm Msg      sender=537985600    receiver=537989634    fault_state=1    fault_id=2080    unit_id=32
#    Send Hwapi Api2 Alarm Msg  ${537985600}  ${537989634}  ${1}  ${2080}  ${32}  ${4}  ${1}  alias=admin_1

Check ReasoningStatus Empty for 2080
    Run Keyword If   '${OUT_ADMIN_SMOD_POSITION}' == 'left'
    ...    ADMIN INFOMODEL Check ReasoningStatus Value is Empty
    ...    dist_name=${reasoning_path_2080_left}
    Run Keyword If   '${OUT_ADMIN_SMOD_POSITION}' == 'right'
    ...    ADMIN INFOMODEL Check ReasoningStatus Value is Empty
    ...    dist_name=${reasoning_path_2080_right}

Check ReasoningStatus for 2080
#    Run Keyword If   '${OUT_ADMIN_SMOD_POSITION}' == 'left'
#    ...    Wait Until Keyword Succeeds  300  30  ADMIN INFOMODEL Check ReasoningStatus Value
#    ...    dist_name=${reasoning_path_2080_left}
#    ...    value=SrioHostLinkDown
#    Run Keyword If   '${OUT_ADMIN_SMOD_POSITION}' == 'right'
#    ...    Wait Until Keyword Succeeds  300  30  ADMIN INFOMODEL Check ReasoningStatus Value
#    ...    dist_name=${reasoning_path_2080_right}
#    ...    value=SrioHostLinkDown
    Wait Until Keyword Succeeds  300  30  ADMIN INFOMODEL Check ReasoningStatus Value
    ...    dist_name=${reasoning_path_2080_right}
    ...    value=SrioHostLinkDown

Hot Remove dual ASIB Primary
    log to console    hot remove Primary
    pdu.setup_pdu     host=10.255.3.26    model=Gude     version=8221-1
    ${port_status}=   pdu.get_port_status    port=7
    should be equal    ${port_status}    on
    pdu.power_off     port=7

Hot Insert dual ASIB Primary
    log to console   hot insert Primary
    pdu.setup_pdu     host=10.255.3.26    model=Gude     version=8221-1
    ${port_status}=   pdu.get_port_status    port=7
    should be equal    ${port_status}    off
    pdu.power_on     port=7

Reboot dual ASIB Primary via PDU
    Hot Remove dual ASIB Primary
    Sleep   30s
    Hot Insert dual ASIB Primary

Hot Remove dual ASIB Secondary
    log to console    hot remove Secondary
    pdu.setup_pdu     host=10.255.3.26    model=Gude     version=8221-1
    ${port_status}=   pdu.get_port_status    port=8
    should be equal    ${port_status}    on
    pdu.power_off     port=8

Hot Insert dual ASIB Secondary
    log to console   hot insert Secondary
    pdu.setup_pdu     host=10.255.3.26    model=Gude     version=8221-1
    ${port_status}=   pdu.get_port_status    port=8
    should be equal    ${port_status}    off
    pdu.power_on     port=8

Reboot dual ASIB Secondary via PDU
    Hot Remove dual ASIB Secondary
    Sleep   30s
    Hot Insert dual ASIB Secondary

Configuration Reset on Dual Core
    SELENIUM Prepare Enviroment
    SELENIUM Login To Web Element Manager
    SELENIUM Go to Configuration Reset
    Execute Configuration Reset
    SeleniumLibrary.Close Browser
    SELENIUM Teardown Enviroment
    Wait Until Keyword Succeeds  600  30   ADMIN Check BTS Not Commisioned

Execute Configuration Reset
    ${execute_reset_button}=   Get WebElement      //div[@class="execution-bar"]//ui-button[@a-text="Execute Reset"]
    Click Element   locator=${execute_reset_button}
    SELENIUM Click Visible Element   locator=${POP_EXECUTE_BTN}
    ${plug}=    Run Keyword And Return Status    Element Should Be Visible    locator=//h4[@title="Plug and Play"]   timeout=600
    Run Keyword If    '${plug}' == 'True'    Run Keyword    Click Element    locator=//button[contains(text(),'Cancel')]
    ${sync}=    Run Keyword And Return Status    Element Should Be Visible    locator=//h4[@title="Additional hardware detected"]
    Run Keyword If    '${plug}' == 'True'    Run Keyword    Click Element    locator=//button[contains(text(),'Start sync')]
    Sleep  10
    Run Keyword If    '${plug}' == 'True'    Run Keyword    Click Element    locator=//button[contains(text(),'Close')]
    Sleep  10

Check not uncommissioned state
    Run Keyword If     '${OUT_ADMIN_SMOD_POSITION}' == 'left'
    ...       Check If BTS Is Not In Uncommissioned State
    Run Keyword If     '${OUT_ADMIN_SMOD_POSITION}' == 'right'
    ...       Check If BTS Isn't In Uncommissioned State

ADMIN INFOMODEL Check If BTS Is Commissioned
    ${bts_statuses_response}=    taf.sbts.oam.coam.admin.Get Bts Info
    ${actual_value}=    Get From Dictionary
    ...    dictionary=${bts_statuses_response['status']}
    ...    key=proceduralState
    Should Be Equal
    ...    first=${actual_value}
    ...    second=Commissioned

Check if fault is not in active raw alarm
      [Arguments]    ${fault_id}
    ...              ${EFaultId}
    ${RawAlarms}=   taf.sbts.oam.coam.admin.get raw alarm history file
    ${RawAlamrsActive}=  fetch from left  ${RawAlarms}  Inactive faults
    Should not contain  ${RawAlamrsActive}  (${fault_id})
    Should not contain  ${RawAlamrsActive}  ${EFaultId}

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
    :FOR    ${element}    IN    @{out_list_of_objects_parameters_dict}
    \    ${distName}    Get From Dictionary    ${element}    distName
    [Return]    ${distName}

Get Object Distname From Class Name if List
    [Arguments]    ${class_name}
    ...            ${timeout}=60
    ...            ${alias}=${ADMIN_ALIAS}
    ${out_list_of_objects_parameters_dict}    taf.sbts.oam.coam.admin.Get Managed Objects
    ...    class_name=${class_name}
    ...    timeout=${timeout}
    ...    connection=${alias}
    @{distName_list}   create list
    :FOR    ${element}    IN    @{out_list_of_objects_parameters_dict}
    \    ${distName}    Get From Dictionary    ${element}    distName
    \    append to list   ${distName_list}   ${distName}
    [Return]    ${distName_list}

Get Active Alarms distName list
    [Arguments]    ${class_name}=ALARM
    ...            ${timeout}=60
    ...            ${alias}=${ADMIN_ALIAS}
    @{out_alarms_object_dict}    taf.sbts.oam.coam.admin.Get Managed Objects
    ...    class_name=${class_name}
    ...    timeout=${timeout}
    ...    connection=${alias}
    @{alarm_distName_list}   create list
    :FOR    ${element}    IN    @{out_alarms_object_dict}
    \    ${distname}    Get From Dictionary    ${element}    distName
    \    append to list   ${alarm_distName_list}   ${distName}
    set test variable        @{alarm_distName_list}
#    @{query_result}=  ute_admin_infomodel.Query Infomodel  get list /MRBTS-1/RAT-1/FRI-*/ALARM-*
#    @{alarm_list}=  Set Variable  @{query_result}
#    set test variable        @{alarm_list}
#    :FOR  ${alarm}  IN  @{alarm_list}

Check If Alarm Is Active on Secondary
    [Arguments]    ${fault_id}
    ${is_active}    Is alarm active on Secondary   ${fault_id}
    Should Be True   ${is_active}

Is alarm active on Secondary
    [Arguments]    ${fault_id}
    ...            ${dist_name}=/MRBTS-1/RAT-1/FRI-4/ALARM-".*"
    ...            ${timeout}=60
    ...            ${alias}=${ADMIN_ALIAS}
    @{out_alarms_objects_dict}    taf.sbts.oam.coam.admin.Get Parameters
    ...    dist_name=${dist_name}
    ...    timeout=${timeout}
    ...    connection=${alias}
    :FOR    ${alarm}    IN    @{out_alarms_objects_dict}
    \    ${dict_fault_id}    Get From Dictionary    ${alarm}    faultId
    \    Run Keyword If    '${dict_fault_id}' == '${fault_id}'
    ...    return from keyword    ${TRUE}
    return from keyword    ${FALSE}

UTE TL Preparation
    [Documentation]  Keyword used for setting up local 5G TLs to onAir state, as UTE reserve it only to sw_upload state
    #TO DO:             Add Check for onAir State. For cases when the Suite is run more than one time
    PREPOST Setup Admin
    ADMIN Change R&D Port Status    status=True
    @{status}   Run Keyword and Ignore Error    ADMIN Check BTS onair
    Run Keyword If  '@{status}[0]' == 'FAIL'   Run Keyword  CB006615-5G-A.Configured_SwDownload_SwUpdate_OnAir
    ...     ELSE    Log To Console  --- BTS already onAir ---
    ADMIN Teardown Admin

Configured_SwDownload_SwUpdate_OnAir
    ADMIN Check BTS Not Commisioned
    Get TL Hostname
    Get Software Release
    ADMIN Perform Commissioning
    ...   scf_file=/home/ute/MN/UTE/robotws/custom-config/Timisoara/${tl_hostname}/${sw_release}/${tl_hostname}_SCF.xml
    ${configured}   Run Keyword and Return Status
    ...    BuiltIn.Wait Until Keyword Succeeds  600  30   ADMIN Check BTS Configured
    Run Keyword If  '${configured}' == 'True'  Sleep  180
    Run Keyword Unless   ${configured}   Run Keywords   admin.ADMIN Reset Site
    ...    AND     BuiltIn.Wait Until Keyword Succeeds  600  30   ADMIN Check BTS Configured
    ...    AND     Sleep  180
    Log To Console  Fault ID23 Checking...
    ${result}   Run Keyword and Return Status    ADMIN Check If Alarm Is Active  fault_id=23
    BuiltIn.Run Keyword If  '${result}' == 'True'   Run Keywords
    ...    Log To Console  Fault ID23 found. Start RF Software Update
    ...     AND     ADMIN Download And Update Current Software
    ...     ELSE    Log To Console  Fault ID23 not found.
    ${onair}   Run Keyword and Return Status
    ...    BuiltIn.Wait Until Keyword Succeeds  600  30   ADMIN Wait Until BTS OnAir
    Run Keyword Unless   ${onair}   Run Keywords   admin.ADMIN Reset Site
    ...    AND     BuiltIn.Wait Until Keyword Succeeds  600  30   ADMIN Wait Until BTS OnAir

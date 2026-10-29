*** Settings ***
Documentation       Test case for
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
# Test Timeout    3h
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
${PDU_Model}      HBTE    # pdu device to create. If it is a string, it is assumed to represent a vendor.
${PDU_IP}         10.106.245.166    #ip address or hostname of pdu device
${PDU_Ports}      3    #e.g.1,2,3,4,5
@{IGNORE_ALARM_FILTER_STRING}    {'faultId':61649}    {'faultId':61524}    {'faultId':61652}    {'faultId':4654}
...    {'faultId':4655}    {'faultId':6323}    {'faultId':4592}    {'faultId':61074}    {'faultId':4657}
...    {'faultId':6322}    {'faultId':6327}    {'faultId':4124}    {'faultId':4123}    {'faultId':4125}
...    {'faultId':1898}    {'faultId':4298}    {'faultId':61644}    {'faultId':61510}

*** Keywords ***
CM__Reset_Secondary_Core_Via_PDU_Top50
    [Documentation]
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  The main steps performed for the test are:
    ...    Power Off Secondary Core
    ...    Check Secondary Core Is Disconnected
    ...    Power On Secondary Core
    ...    Check SBTS Is Onair And Alarms
    ...  Pass criteria: reset secondary core success. Site is OK with no any unexpected alarm.
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 13.04.2023 - new case

    Set Tags    CA-CM    AUTHOR-yuyan.xu@nokia-sbell.com    OWNER-II_NSB_MN_RAN_PZ_1_HAZ_11@internal.nsn.com    API
    LOG    ${TEST_NAME} start.    console=${True}
    Step 1: Power Off Secondary Core
    Step 2: Check Secondary Core Is Disconnected
    Step 3: Power On Secondary Core
    Step 4: Check SBTS Is Onair And Alarms

Step ${index}: Power Off Secondary Core
    Log    Step ${index}: Power Off Secondary Core    console=True
    ${btsinfo_list}    coam.Get Bts Info
    ${smod_list}    set variable    ${btsinfo_list['systemModules']}
    FOR    ${smod}    IN    @{smod_list}
        ${SMOD_ID}    set variable if    "${smod['positionInSubrack']}" == "RightSide"    ${smod['id']}
        exit for loop if    "${smod['positionInSubrack']}" == "RightSide"
    END
    run keyword if    ${SMOD_ID}==${None}    Fail    Cannot find RightSide SMOD on this Site!
    Set Test Variable    ${SMOD_ID}
    ${active_alarm}    coam.Get Alarms    alias=default
    Set Test Variable    ${ALARMS_BEFORE_TEST}    ${active_alarm}
    ${filter_list}    Create List
    FOR    ${str}    IN    @{IGNORE_ALARM_FILTER_STRING}
        &{filter}    Evaluate    ${str}
        Append To List    ${filter_list}    ${filter}
    END
    Set Test Variable    ${IGNORE_ALARM_FILTER}    ${filter_list}
    ${PDU_Ports_list}    Create List
    ${PDU_Ports_list}    Split String    ${PDU_Ports}    ,
    Set Test Variable    ${PDU_Ports_list}
    pdu.setup_pdu    model=${PDU_Model}    host=${PDU_IP}    alias=reset_pdu
    Log    PDU Off started    console=True
    FOR    ${port}    IN    @{PDU_Ports_list}
        pdu.power_off    ${port}    pdu_device=reset_pdu
    END
    sleep    10s
    FOR    ${port}    IN    @{PDU_Ports_list}
        ${PDU_status}    PDU.get_port_status    port=${port}    pdu_device=reset_pdu
        Should Be Equal    ${PDU_status}    off
    END

Step ${index}: Check Secondary Core Is Disconnected
    LOG    Step ${index}: Check Secondary Core Is Disconnected    console=${True}
    ${smod_offline_state}    Set Variable
    ...    administrativeState=Unlocked, operationalState=disabled, availabilityStatus=not installed, usageState=Active
    Wait Until Keyword Succeeds    1 min    15 sec    coam.Assert   class_name=SMOD    id=${SMOD_ID['internal']}
    ...    parameters=operationalState=disabled    timeout=20s
    #${smod_offline_state}

Step ${index}: Power On Secondary Core
    LOG    Step ${index}: Power On    console=${True}
    FOR    ${port}    IN    @{PDU_Ports_list}
        pdu.power_on    ${port}    pdu_device=reset_pdu
    END
    sleep    10s
    FOR    ${port}    IN    @{PDU_Ports_list}
        ${PDU_status}    PDU.get_port_status    port=${port}    pdu_device=reset_pdu
        Should Be Equal    ${PDU_status}    on
    END


Step ${index}: Check SBTS Is Onair And Alarms
    LOG    Step ${index}: Check SBTS Is Onair And Alarms    console=${True}
    Check IP Is Pingable    192.168.255.129    expect_pingable=${True}
    Wait Until Keyword Succeeds    30 min    60 sec    Check_SBTS_SMOD_RMOD_Cells_Alarms
    Log    Compare Alarm    console=${True}
    ${active_alarm}    coam.Get Alarms    alias=default
    Set Test Variable    ${ALARMS_AFTER_TEST}    ${active_alarm}
    ${alarms_cleared}    ${alarms_raised}    Compare Alarm List
    ...    ${ALARMS_BEFORE_TEST}    ${ALARMS_AFTER_TEST}    ${IGNORE_ALARM_FILTER}
    ${count}    Get Length    ${alarms_raised}
    Should Be Equal As Integers    ${count}    ${0}


Recovery SBTS
    Log    Recovery SBTS    console=True
    FOR    ${port}    IN    @{PDU_Ports_list}
        pdu.power_on    ${port}    pdu_device=reset_pdu
    END

TC SetUp
    Log    TC SetUp    console=True
    Common Test Setup SBTS    scf_check=${FALSE}

TC TearDown
    Log    TC TearDown    console=True
    run keyword if test failed      Recovery SBTS
    Wait Until Keyword Succeeds    20 min    15 sec    Check_SBTS_SMOD_RMOD_Cells_Alarms
    Common Test Teardown SBTS    never
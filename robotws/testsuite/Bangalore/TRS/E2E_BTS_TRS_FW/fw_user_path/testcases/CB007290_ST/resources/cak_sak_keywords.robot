*** Settings ***
Documentation     [Procedure] "Verification_of_CB007290E_E2E_MacSec_SAK_and_CAK_Rekeying"

*** Keywords ***
Verify Macsec
    Configuration Manage
    ...    config_device=netact2005
    ...    config=${macsec_disable}
    ...    plan_name=macsec_disable
    ...    delete_plan=${True}
    ...    operation=edit
    ...    alias=lab2005
    Sleep    300

    Configuration Manage
    ...    config_device=netact2005
    ...    config=${macsec_enable}
    ...    plan_name=macsec_enable
    ...    delete_plan=${True}
    ...    operation=edit
    ...    alias=lab2005
    Sleep    300

    ${macsec_flag}=    Get Parameter
    ...    param_path=MRBTS-3603/MNL-1/MNLENT-1/FEATCADM-1:actEcpriMacSecTraffic
    Should Contain    ${macsec_flag}    MACSecWithPSK

    Setup Remote Access    remote_device=vm    alias=vm9

    ${stdout}=    Execute Interactive Remote Command
    ...    command=cat ${CURDIR}/execution_logs/background* | grep -i smacsec
    ...    alias=vm9
    Should Contain    ${stdout}    "SMACSECCONNSTATUS_SETUPSUCCESS"


try cell attach
    [Arguments]    ${session}

    Execute Interactive Remote Command    command=${ap_on}    alias=${session}
    Sleep    60
    Execute Interactive Remote Command    command=${ap_off}    alias=${session}
    Sleep    30

    ${stdout}=    Execute Interactive Remote Command
    ...    command=${cell_cmd}
    ...    alias=pi

    ${str}    ${cell}=    Should Match Regexp
    ...    ${stdout}
    ...    mNci\\s*=\\s*(.*\\d+)\\s*m

    ${bool}=    Run Keyword And Return Status
    ...    Should Contain
    ...    ${cell}
    ...    ${cell_digit}

    [Return]    ${bool}


call preconditions
    Setup Remote Access    remote_device=pi_cit    alias=pi
    try cell attach    pi
    Wait Until Keyword Succeeds    3x    60    try cell attach    pi


Create fault id List
    [Arguments]    ${list}
    ${length}=    Get Length    ${list}
    ${list1}=     Create List

    FOR    ${i}    IN RANGE    ${length}
        Append To List    ${list1}    ${list[${i}]['faultId']}
    END

    [return]    ${list1}


Fault list after reset
    [Arguments]    ${pre_alarm_faultids}    ${post_alarm_faultids}

    ${list}=    Create List

    FOR    ${i}    IN    @{post_alarm_faultids}
        Run Keyword If    ${i} in ${pre_alarm_faultids}    Continue For Loop
        Append To List    ${list}    ${i}
    END

    [return]    ${list}


Get Current Alarm List
    ${alarms}=    Verify Alarm    alarm_type=active
    ${alarm_faultids_list}=    Create List
    ${alarm_faultids_list}=    Create fault id List    ${alarms}
    [return]    ${alarm_faultids_list}


Make 5G Call
    Call Setup    5g=device_1:data    parallel=${False}    verify_attach=${False}

    Call Start    5g=device_1:data
    ...    profile=udp_10K_dl
    ...    iperf_section=device1

    Call Start    5g=device_1:data
    ...    profile=udp_10K_ul
    ...    iperf_section=device1

    Sleep    ${sak_time}

    Call Stop    5g=device_1:data    profile=udp_10K_ul
    Call Stop    5g=device_1:data    profile=udp_10K_dl

    Call Teardown    5g=device_1:data


SAK Verification
    ${output}=    Execute Interactive Remote Command
    ...    command=cat ${CURDIR}/execution_logs/background* | grep -i ${sak_verification_check}
    ...    alias=vm9
    Should Contain    ${output}    ${sak_verification_check}


SAK TC teardown
    Call Stop    5g=device_1:data    profile=udp_10K_ul
    Call Stop    5g=device_1:data    profile=udp_10K_dl
    Call Teardown    5g=device_1:data

    ${post_execution_alarms}=    Get Current Alarm List
    ${alarms_post_execution}=    Fault list after reset
    ...    ${pre_execution_alarms}
    ...    ${post_execution_alarms}

    Should Not Contain    ${alarms_post_execution}    ${macsec_connection_setup_failure_alarm}
    Should Not Contain    ${alarms_post_execution}    ${macsec_connection_lost_alarm}


CAK_Rekeying
    ${pre_execution_alarms}=    Get Current Alarm List

    Setup Remote Access    remote_device=vm    alias=vm9

    Configuration Manage
    ...    config_device=netact2005
    ...    config=${cak_timer}
    ...    plan_name=macsec_disable
    ...    delete_plan=${True}
    ...    operation=edit
    ...    alias=lab2005

    Sleep    300

    ${date}=    Get Current Date
    ${date}    ${time}=    Split String    ${date}    ${SPACE}

    ${time_left}=    Subtract Time From Time    23:59:60    ${time}
    ${wait_time}=    Evaluate    ${time_left}+362
    Log    ${wait_time}

    Sleep    ${wait_time}

    ${output}=    Execute Interactive Remote Command
    ...    command=cat ${CURDIR}/execution_logs/background* | egrep -i "CakRekey|connectionstatusind"
    ...    alias=vm9

    Should Contain    ${output}    ${cak_verification_check}
    Should Contain    ${output}    ${macsec_status_check}

    ${post_execution_alarms}=    Get Current Alarm List

    ${alarms_post_execution}=    Fault list after reset
    ...    ${pre_execution_alarms}
    ...    ${post_execution_alarms}

    Should Not Contain    ${alarms_post_execution}    ${macsec_connection_setup_failure_alarm}
    Should Not Contain    ${alarms_post_execution}    ${macsec_connection_lost_alarm}


SAK_Rekeying
    Setup Remote Access    remote_device=vm    alias=vm9
    call preconditions

    Call Setup    lte=device_1:data    parallel=${False}    verify_attach=${False}

    Call Start    lte=device_1:data
    ...    profile=udp_10K_dl
    ...    iperf_section=device1

    Sleep    10200

    Call Stop    lte=device_1:data    profile=udp_10K_dl
    Call Teardown    lte=device_1:data

    SAK Verification

    [Teardown]    sak teardown


sak teardown
    Teardown Remote Access    alias=vm9

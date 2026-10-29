*** Settings ***
Documentation
...   Author: yuyan.xu@nokia-sbell.com
#Force Tags        CA_RAN_PZ_HAZ_1    RAN_PZ_HAZ1_SG011_ST_OAM
#Test Timeout      180 minutes
#Resource          ../../../../../RRM/RAN_PZ_HAZ_1/Resources/Classical/RRM_Common_Resource.robot
Resource          ../../Resources/Classical/RRM_Common_Resource.robot
Library           taf.sbts.oam.coam.admin    WITH NAME    coam

*** Variables ***
#${TA_UE_CONFIG}    /home/ute/btsauto/hran_ta/testsuite/SBTS/SyVe/ute_ue_config.yml
${Expect_Tput_DL}    1
${Expect_Tput_UL}    1
${SBTS1880_VM_IP}    10.56.111.117
${SBTS1907_VM_IP}    10.56.111.85


*** Keywords ***
Top50_TA_Call
    [Arguments]    ${SBTS_ID}=1880    ${UE_UI_Version}=default
    Log To Console    Top50_TA_Call
    Set Test Variable    ${SBTS_ID}
    Set Test Variable    ${UE_UI_Version}
    ${CALL_RESULT}    Create List    failed
    Set Test Variable    ${CALL_RESULT}
    Case Setup
    Make Call For Every PA    0
    [Teardown]    Case Teardown

Make Call For Every PA
    [Arguments]    ${ru_id}
    Set Test Variable    ${ru_id}
    ${attenuation_channels}    Get Attenuation port    RU_id=${ru_id}    #du_id=0
    ${initial_att_values}    Get Initial Attenuation Values    RU_id=${ru_id}    vendor=TOPYOUNG    #du_id=0
    ${length}    Get Length    ${attenuation_channels}
    &{channels_to_init}    create dictionary
    FOR    ${index}    IN RANGE    0    ${length}
        Set To Dictionary    ${channels_to_init}    ${attenuation_channels[${index}]}    120
    END
    Set Test Variable    ${channels_to_init}
    Prepare My UE
    FOR    ${index}    IN RANGE    0    ${length}
        &{channels_to_modify}    copy dictionary    ${channels_to_init}
        Set To Dictionary    ${channels_to_modify}    ${attenuation_channels[${index}]}    0
        Log To Console    Modify Attenuation Value: ${channels_to_modify}
        Modify Attenuation Value    ${channels_to_modify}    RU_id=${ru_id}    #du_id=0
        sleep    15s
        Run Keyword If    "${SBTS_ID}"== "1880" or "${SBTS_ID}"== "1907"    Check L3 Call For LTE    ELSE    Check L3 Call
    END
    [Teardown]    Step Teardown

Check L3 Call
    Log To Console    \n*** Checking L3 call start ***
    FOR    ${index}    IN RANGE    0    1
        Log To Console    *** Attach UE ***
        ${attach_status}    run keyword and return status    UE Attach    ${ue_type}    ue_index=${0}    verify_attach=True
        ${serial_number}    set variable    ${tl.ues[0].serial_number}
        Connect to control pc via cygwin    ue_index=${0}   #Need add this connection after UE proxy
        ${UE_IP}    Commercial.Get UE IP address    ${serial_number}
        Log To Console    UE IP:${UE_IP}
        Continue For Loop If    "${attach_status}"!="${True}"
        sleep    10s
        Log To Console    *** Checking Downlink Call ***
        Make Call With UE    dl    20M    300
        ${dl_status}    ${dl_output}    run keyword and ignore error
        ...    Check throughput    direction=dl    dl_expect=${Expect_Tput_DL}
        Stop TPUT    dl
        Exit For Loop If    "${dl_status}"=="PASS"
    END
    Log To Console    \nCheck DL status is: ${dl_status}; ${dl_output}
    ${call_result_tmp}    set variable if    "${dl_status}"=="PASS"    pass    failed
    Set List Value    ${CALL_RESULT}    0    ${call_result_tmp}
    run keyword if    '${dl_status}'=='FAIL'    FAIL    DL throughput are less than expect
    Comment    run keyword if    '${dl_status}'=='FAIL'    Log    DL throughput are less than expect    level=ERROR
    Log To Console    *** Checking Downlink Call done! ***
    Log To Console    *** Checking L3 call done! ***

Check L3 Call For LTE
    Log To Console    \n*** Checking L3 Call For LTE start ***
    ${ping_status}    Set Variable    ${False}
    FOR    ${index}    IN RANGE    0    2
        Log To Console    *** Attach UE ***
        ${attach_status}    run keyword and return status    UE Attach    ${ue_type}    ue_index=${0}    verify_attach=True
        ${serial_number}    set variable    ${tl.ues[0].serial_number}
        Connect to control pc via cygwin    ue_index=${0}   #Need add this connection after UE proxy
        ${UE_IP}    Commercial.Get UE IP address    ${serial_number}
        Log To Console    UE IP:${UE_IP}
        Continue For Loop If    "${attach_status}"!="${True}"
        sleep    10s
        Log To Console    *** Checking Ping ***
        ${rc}    ${result}    OperatingSystem.Run And Return Rc And Output    ping -c 3 -w 5 ${UE_IP}
        ${ping_status}    Evaluate    ${rc}==${0}
        Exit For Loop If    "${ping_status}"=="${True}"
    END
    ${call_result_tmp}    set variable if    "${ping_status}"=="${True}"    pass    failed
    Set List Value    ${CALL_RESULT}    0    ${call_result_tmp}
    run keyword if    "${ping_status}"=="${False}"    FAIL    L3 call failed
    Log To Console    *** Checking Ping done! ***
    Log To Console    *** Checking L3 Call For LTE done! ***



Make Call With UE
    [Arguments]    ${direction}    ${tp}=100M    ${duration}=300
    sleep    30s
    Start TPUT    ${direction}    ${tp}    ${duration}
    sleep    10s

Prepare My UE
    log to console    \nPreparing UE...
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${0}
    set test variable    ${ue_type}
    Prepare UE    ${ue_type}    ue_index=${0}    ui_version=${UE_UI_Version}

Attach UE
    log to console    \nAttaching UE...
    UE Attach    ${ue_type}    ue_index=${0}    verify_attach=True

Start TPUT
    [Arguments]    ${direction}    ${tp}=100M    ${duration}=300
    log to console    Starting ${direction} TPUT...
    Start traffic    ue_type=${ue_type}    ue_index=${0}    direction=${direction}    dt_index=${0}
    ...    throughput=${tp}    duration=${duration}

Stop TPUT
    [Arguments]    ${direction}
    Log To Console    Stoping ${direction} TPUT...
    Stop traffic    ${ue_type}    ue_index=${0}    direction=${direction}

Attach UE With Right UE_IP
    ${Att_Res}    Set Variable    FALSE
    FOR    ${index}    IN RANGE    0    2
        ${attach_status}    ${attach_output}    run keyword and ignore error    Attach UE
        sleep    15s
        Get Commercial UE IP    ue_index=${0}
        Log To Console    \nUE_IP is: ${UE_IP}
        ${passed}    Run Keyword And Return Status    Run Keywords    Should Not Be Empty    ${UE_IP}
        ...    AND    Should Not Contain    ${UE_IP}    127.0.0
        Continue For Loop If    '${passed}'!='True'
        ${Att_Res}    Set Variable If    '${passed}'=='True'    TRUE    FALSE
        Return From Keyword    ${Att_Res}
    END
    [Return]    ${Att_Res}

Step Teardown
    Log To Console    \n*** Step Teardown***
    Modify Attenuation Value    ${channels_to_init}    RU_id=${ru_id}    #du_id=0
    Teardown UE    ${ue_type}

Case Setup
    Log To Console    \n*** Case Setup***
    Return From Keyword If    "${SBTS_ID}"=="1880" or "${SBTS_ID}"=="1907"
    ${testtimestamp}=    OperatingSystem.Run    date +%F_%H-%M-%S
    ${testresultspath}=    OperatingSystem.Join Path    ${OUTPUT DIR}    ${testtimestamp}_TEST-${TEST NAME}
    Create Directory    ${testresultspath}
    Set Test Variable    ${Test Results Dir}    ${testresultspath}
    ${remote_vm_ip}    Set Variable If    "${SBTS_ID}"== "1881"    ${SBTS1880_VM_IP}    ${EMPTY}
    ${remote_vm_ip}    Set Variable If    "${SBTS_ID}"== "1906"    ${SBTS1907_VM_IP}    ${EMPTY}
    coam.setup admin    alias=Slave    remote_host=${remote_vm_ip}    bts_host=192.168.255.129    bts_port=443
    ...    admin_api_log_dir=${Test Results Dir}    timeout=120s
    ${Cells_DN_List_1880}    Create List    MRBTS-1880/LNBTS-3516/LNCEL-9/SIB-0    MRBTS-1880/LNBTS-3516/LNCEL-10/SIB-0
    ...    MRBTS-1880/LNBTS-3516/LNCEL-11/SIB-0    MRBTS-1880/LNBTS-3516/LNCEL-65/SIB-0
    ...    MRBTS-1880/LNBTS-3516/LNCEL-66/SIB-0    MRBTS-1880/LNBTS-3516/LNCEL-67/SIB-0
    ${Cells_DN_List_1907}    Create List    MRBTS-1907/LNBTS-11018/LNCEL-0/SIB-0    MRBTS-1907/LNBTS-11018/LNCEL-1/SIB-0
    ...    MRBTS-1907/LNBTS-11018/LNCEL-2/SIB-0    MRBTS-1907/LNBTS-11018/LNCEL-3/SIB-0
    ...    MRBTS-1907/LNBTS-11018/LNCEL-11/SIB-0    MRBTS-1907/LNBTS-11018/LNCEL-12/SIB-0
    ${Cells_DN_List}    Create List
    ${Cells_DN_List}    Set Variable If    "${SBTS_ID}"== "1881"    ${Cells_DN_List_1880}    ${Cells_DN_List}
    ${Cells_DN_List}    Set Variable If    "${SBTS_ID}"== "1906"    ${Cells_DN_List_1907}    ${Cells_DN_List}
    Set Test Variable    ${Cells_DN_List}
    coam.create_delta
    FOR    ${cell}    IN    @{Cells_DN_list}
        coam.append_parameter_update_to_delta    dist_name=${cell}    parameter=cellBarred    value=barred
    END
    ${json}    coam.get_delta
    log    ${json}
    coam.Perform Delta Recommissioning    delta_file=${json}    alias=Slave
    sleep    5s

Case Teardown
    Log To Console    \n*** Case Teardown***
    Return From Keyword If    "${SBTS_ID}"=="1880" or "${SBTS_ID}"=="1907"
    coam.create_delta
    FOR    ${cell}    IN    @{Cells_DN_list}
        coam.append_parameter_update_to_delta    dist_name=${cell}    parameter=cellBarred    value=notBarred
    END
    ${json}    coam.get_delta
    log    ${json}
    coam.Perform Delta Recommissioning    delta_file=${json}    alias=Slave


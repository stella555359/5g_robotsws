*** Settings ***
Documentation       Test case for
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
# Test Timeout    3h
#Resource          ../../../../../resources/RAN_PZ_HAZ_1/Module/Traffic_UE_Operation.robot
Library           ../../../../../resources/RAN_PZ_HAZ_1/Module/Commercial_UE_Operation.py
Library           taf.sbts.oam.coam.admin    WITH NAME    coam
Library           OperatingSystem
Library           taf.sw.scout    WITH NAME    scout
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/PA.robot

*** Variables ***
${SBTS1880_VM_IP}    10.106.245.26
${SBTS1907_VM_IP}    10.56.111.85
${DLUL_Call_NoNeeded}    ${True}


*** Keywords ***
Top50_TA_Call-moduledebug
    [Arguments]    ${SBTS_ID}=1880
    Log To Console    Top50_TA_Call
    Log   ${SBTS_ID}
    ${CALL_RESULT}    Create List    failed
    Commercial UE Operation    attach    ue_index=0    forced=${True}
    ${ueip}=    Commercial UE Operation    get    ue_index=0   item=ueip
    Log To Console    UE IP:${ueip}
    Commercial UE Operation    start call    ue_index=0    dial_number=6688    #serialno=H4K5T21108009488
    Sleep    10s
    Commercial UE Operation    stop call    ue_index=0    #serialno=H4K5T21108009488
    Commercial UE Operation    start traffic    ue_index=0  IperfOptions=-u -i 1 -t 60 -b 100M -p 50001 -l 1024B  direction=dl
    Sleep    15s
    ${dltput}=    Commercial UE Operation    get    ue_index=0  item=dltput
    #Should Be True     ${dltput}>0
    Log To Console    DL:${dltput}
    Sleep    15s
    Commercial UE Operation    stop traffic    ue_index=0  IperfOptions=-u -i 1 -t 60 -b 100M -p 50001 -l 1024B  direction=dl
    Commercial UE Operation    start traffic    ue_index=0  IperfOptions=-u -i 1 -t 60 -b 100M -p 50001  direction=ul
    Sleep    15s
    ${ultput}=    Commercial UE Operation    get    ue_index=0  item=ultput
    Log To Console    UL:${dltput}
    #Should Be True     ${ultput}>0
    Sleep    15s
    Commercial UE Operation    stop traffic    ue_index=0  IperfOptions=-u -i 1 -t 30 -b 100M -p 50001    direction=ul
    return from keyword
    Traffic UE Operation    attach
    ${ue_ipv4}      Traffic UE Operation    get    item=ipv4
    Log To Console    UE IP:${ue_ipv4}
    Log To Console    udp_dl
    Traffic UE Operation    start traffic    option=udp_dl      bandwidth=100M    port=5000    duration=30s
    Sleep    30s
    Traffic UE Operation    stop traffic     option=udp_dl    port=5000
    sleep    30s
    ${dl_avg}    ${ul_avg}    Traffic UE Operation     check average tput
    Should Be True     ${dl_avg}>0
    Log To Console    start voice call
    Traffic UE Operation    start voice call    dial=004488    duration=10s
    Traffic UE Operation    stop voice call
    Traffic UE Operation    detach


Top50_TA_Call
    [Arguments]    ${SBTS_ID}=1880    ${scout_name}=${TESTLINE_NAME}
    Log To Console    Top50_TA_Call
    #Set Test Variable    ${CALL_RESULT}    Failed
    Set Test Variable    ${SBTS_ID}
    Case Setup    scout_name=${scout_name}
    Make Call For Every PA
    [Teardown]    Case Teardown

Make Call For Every PA
    [Arguments]    ${ru_id}=0
    Set Test Variable    ${ru_id}
    ${attenuation_channels}    Get Attenuation port    RU_id=${ru_id}
    ${initial_att_values}    Get Initial Attenuation Values    RU_id=${ru_id}    vendor=TOPYOUNG
    ${length}    Get Length    ${attenuation_channels}
    &{channels_to_init}    create dictionary
    FOR    ${index}    IN RANGE    0    ${length}
        Set To Dictionary    ${channels_to_init}    ${attenuation_channels[${index}]}    120
    END
    Set Test Variable    ${channels_to_init}
    FOR    ${index}    IN RANGE    0    ${length}
        &{channels_to_modify}    copy dictionary    ${channels_to_init}
        Set To Dictionary    ${channels_to_modify}    ${attenuation_channels[${index}]}    0
        Log To Console    Modify Attenuation Value: ${channels_to_modify}
        Modify Attenuation Value    ${channels_to_modify}    RU_id=${ru_id}    #du_id=0
        sleep    15s
        Check L3 Call
        #Run Keyword If    "${SBTS_ID}"== "1880" or "${SBTS_ID}"== "1907"    Check L3 Call For LTE    ELSE    Check L3 Call For NR
    END
    [Teardown]    Step Teardown

Check L3 Call
    Log To Console    \n*** Checking L3 call start ***
    FOR    ${index}    IN RANGE    0    2
        ${call_res}    Run Keyword And Return Status    Check L3 Call One Time
        Log To Console    Call_Result_${index}:${call_res}
        Exit For Loop If    ${call_res}
    END
    #${CALL_RESULT}    Set Variable If    ${call_res}    Passed    Failed
    Should Be True    ${call_res}
    Log To Console    \n*** Checking L3 call end ***


Check L3 Call One Time
    Log To Console    *** Check L3 Call One Time ***
    Run Keyword And Ignore Error    Commercial UE Operation    ui_operation    ue_index=0   item=kill_naa
    Run Keyword And Ignore Error    Commercial UE Operation    ui_operation    ue_index=0   item=launch_naa
    Run Keyword And Ignore Error    Commercial UE Operation    stop_uc_all    ue_index=0
	Sleep    5s
    Log To Console    *** Attach UE ***
    Commercial UE Operation    attach    ue_index=0    forced=${True}
    Sleep    2s
    ${ue_ipv4}=    Commercial UE Operation    get    ue_index=0   item=ueip
    Log To Console    UE IP:${ue_ipv4}
    Should Not Be True      "${ue_ipv4}"==""
    Sleep    10s
    Log To Console    *** Checking Ping ***
    ${rc}    ${result}    OperatingSystem.Run And Return Rc And Output    ping -c 3 -w 5 ${ue_ipv4}
    ${ping_status}    Evaluate    ${rc}==${0}
    Should Be True    "${ping_status}"=="${True}"
#    Log To Console    *** Checking Voice Call ***
#    Commercial UE Operation    start call    ue_index=0    dial_number=6688
#    Sleep    10s
#    Commercial UE Operation    stop call    ue_index=0
    Return From Keyword If    ${DLUL_Call_NoNeeded}
    Log To Console    *** Checking Uplink Call ***
    Commercial UE Operation    start traffic    ue_index=0  IperfOptions=-u -i 1 -t 60 -b 100M -p 50001  direction=ul
    Sleep    15s
    ${ultput}=    Commercial UE Operation    get    ue_index=0  item=ultput
    Log To Console    ultput:${ultput}
    Sleep    15s
    Commercial UE Operation    stop traffic    ue_index=0  IperfOptions=-u -i 1 -t 30 -b 100M -p 50001    direction=ul
    Log To Console    *** Checking Downlink Call ***
    Commercial UE Operation    start traffic    ue_index=0  IperfOptions=-u -i 1 -t 60 -b 100M -p 50001 -l 1024B  direction=dl
    Sleep    15s
    ${dltput}=    Commercial UE Operation    get    ue_index=0  item=dltput
    Log To Console    dltput:${dltput}
    Sleep    15s
    Commercial UE Operation    stop traffic    ue_index=0  IperfOptions=-u -i 1 -t 60 -b 100M -p 50001 -l 1024B  direction=dl
    Should Be True     ${ultput}>0
    Should Be True     ${dltput}>0

Check L3 Call For NR
    Log To Console    \n*** Checking L3 call start ***
    FOR    ${index}    IN RANGE    0    2
        Log To Console    *** Attach UE ***
        Traffic UE Operation    attach
        ${ue_ipv4}      Traffic UE Operation    get    item=ipv4
        Log To Console    UE IP:${ue_ipv4}
        Continue For Loop If    "${ue_ipv4}"==""
        sleep    10s
        Log To Console    *** Checking Uplink Call ***
        Traffic UE Operation    start traffic    option=udp_ul      bandwidth=100M    port=5000    duration=300s
        ${ul_status}    Run Keyword And Return Status    Traffic UE Operation     check average tput
        Traffic UE Operation    stop traffic     option=udp_ul    port=5000
        Log To Console    \nCheck UL status is: ${ul_status};
        Exit For Loop If    ${ul_status}
    END
    Log To Console    \nFinally check UL status is: ${ul_status};
#    Run Keyword Unless    ${ul_status}    FAIL    UL throughput are less than expect
    Run Keyword If    not ${ul_status}    FAIL    UL throughput are less than expect
    Log To Console    *** Checking Uplink Call done! ***
    Log To Console    *** Checking L3 call done! ***

Check L3 Call For LTE
    Log To Console    \n*** Checking L3 Call For LTE start ***
    ${ping_status}    Set Variable    ${False}
    FOR    ${index}    IN RANGE    0    2
        Log To Console    *** Attach UE ***
        Traffic UE Operation    attach
        ${ue_ipv4}      Traffic UE Operation    get    item=ipv4
        Log To Console    UE IP:${ue_ipv4}
        Continue For Loop If    "${ue_ipv4}"==""
        sleep    10s
        Log To Console    *** Checking Ping ***
        ${rc}    ${result}    OperatingSystem.Run And Return Rc And Output    ping -c 3 -w 5 ${ue_ipv4}
        ${ping_status}    Evaluate    ${rc}==${0}
        Exit For Loop If    "${ping_status}"=="${True}"
    END
    ${call_result_tmp}    set variable if    "${ping_status}"=="${True}"    pass    failed
    Set List Value    ${CALL_RESULT}    0    ${call_result_tmp}
    run keyword if    "${ping_status}"=="${False}"    FAIL    L3 call failed
    Log To Console    *** Checking Ping done! ***
    Log To Console    *** Checking L3 Call For LTE done! ***

Step Teardown
    Log To Console    \n*** Step Teardown***
    Modify Attenuation Value    ${channels_to_init}    RU_id=${ru_id}    #du_id=0
    #Teardown UE    ${ue_type}

Case Setup
    [Arguments]    ${scout_name}
    Log To Console    \n*** Case Setup***
    Run Keyword And Ignore Error    Wait Until Keyword Succeeds    3x    30s
    ...    Get SCF Internal Id By Scout    bts_id=${scout_name}    no_ute=${False}
    Return From Keyword If    "${SBTS_ID}"=="1880" or "${SBTS_ID}"=="1907"
    ${testtimestamp}=    OperatingSystem.Run    date +%F_%H-%M-%S
    ${testresultspath}=    OperatingSystem.Join Path    ${OUTPUT DIR}    ${testtimestamp}_TEST-${TEST NAME}
    Create Directory    ${testresultspath}
    Set Test Variable    ${Test Results Dir}    ${testresultspath}
    ${remote_vm_ip}    Set Variable If    "${SBTS_ID}"== "1881"    ${SBTS1880_VM_IP}    ${EMPTY}
    ${remote_vm_ip}    Set Variable If    "${SBTS_ID}"== "1906"    ${SBTS1907_VM_IP}    ${remote_vm_ip}
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
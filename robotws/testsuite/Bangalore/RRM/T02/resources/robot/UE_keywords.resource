*** Settings ***
Documentation   Author: Arunkumar A
...    Contact: arunkumar.a@nokia.com
...    robot file contains UE keywords with supported taf.ue
Library       Collections
Library       String
Library       taf.ue  WITH NAME  ue
Resource      variables/Common_variables_RJIO.robot


*** Keywords ***
Require UE
    [Documentation]    Require UE Function
    ...    |Params: uecapability
    ${items}  Get Dictionary Items   ${UEaliasandCapabilitiesdict}
    FOR  ${key}  ${value}  IN  @{items}
        Set Suite Variable    ${ue_alias}    ${key}
        Set Suite Variable    ${ue_capabilities}   ${value}
        Log To Console  \n[ INFO ]: UE taf.ue.require is started
        ue.Require Ue  ue_alias=${ue_alias}   capabilities=${ue_capabilities}
        Log To Console   \n[ INFO ]: UE Alias ${ue_alias}\n[ INFO ]: UE cabapilits ${ue_capabilities}\n[ INFO ]: UE IS RESERVED
    END

Require_Ues_morethen_one
    [Documentation]    Require Multi UE functionality
    [Arguments]   ${aliasdict}    ${ue_alias_1}=${None}   ${ue_alias_2}=${None}    ${ue_alias_3}=${None}
    ${values}  Get Dictionary Values  ${aliasdict}
    Run Keyword If    "${ue_alias_1}" != "${None}"     Run Keywords   ue.Require Ue  ue_alias=${ue_alias_1}   capabilities=${values}[0]
    ...    AND    Set Test Variable    ${first_ue_alias}    ${ue_alias_1}
    ...    AND    BuiltIn.Log To Console   [ INFO ]: First UE Alias is ${first_ue_alias}
    Run Keyword If    "${ue_alias_2}" != "${None}"    Run Keywords   ue.Require Ue  ue_alias=${ue_alias_2}   capabilities=${values}[1]
    ...    AND    Set Test Variable    ${second_ue_alias}    ${ue_alias_2}
    ...    AND    BuiltIn.Log To Console   [ INFO ]: Second UE Alias is ${second_ue_alias}
    Run Keyword If    "${ue_alias_3}" != "${None}"    Run Keywords   ue.Require Ue  ue_alias=${ue_alias_3}   capabilities=${values}[2]
    ...    AND    Set Test Variable    ${third_ue_alias}    ${ue_alias_3}
    ...    AND    BuiltIn.Log To Console   [ INFO ]: Third UE Alias is ${third_ue_alias}

Attach Ue via taf ue
    [Documentation]  taf.ue.at helps to perform ue attach
    ...    more details:https://confluence.ext.net.nokia.com/display/AbstractLibs/taf.ue%3A+__init__.py+configuration+file
    [Arguments]   ${ue_alias}
    ue.Attach Ue  ue_alias=${ue_alias}
    Log To Console   \n[ INFO ]: UE Alias ${ue_alias}:UE is Attached to Network

Detach Ue via taf ue
    [Documentation]  taf.ue.at helps to perform ue Detach
    ...    more details:https://confluence.ext.net.nokia.com/display/AbstractLibs/taf.ue%3A+__init__.py+configuration+file
    [Arguments]   ${ue_alias}
    ue.Detach Ue  ue_alias=${ue_alias}
    BuiltIn.Log To Console    message=[ INFO ]: UE Detached from Network completed.

Start DL traffic and chech data transfer status
    [Arguments]   ${ue_alias}  ${dl_time}=120s   ${dl_throughput}=1MBytes/sec   ${dt_index}=${0}    ${packet_size}=8
    ...    ${protocol}=udp
    BuiltIn.Set Test Variable    ${dt_name_dl}    DT_${dt_index}
    ue.Start Data Transfer   dt_name=${dt_name_dl}   ue_alias=${ue_alias}  direction=dl   
    ...    throughput=${dl_throughput}   packet_size=${packet_size}    protocol=${protocol}    apn=srancptupf0
    Run Keyword And Ignore Error    ue.check_data_transfer_is_alive  ${dt_name_dl}
    # Run Keyword And Ignore Error    ue.await_data_transfer_finish   ${dt_name_dl}
    RETURN    ${dt_name_dl}

Start UL traffic and chech data transfer status
    [Arguments]   ${ue_alias}  ${dl_time}=120s   ${dl_throughput}=40MBytes/sec   ${dt_index}=${1}    ${packet_size}=8    
    ...    ${protocol}=udp
    BuiltIn.Set Test Variable   ${dt_name_ul}    DT_${dt_index}
    ue.Start Data Transfer   dt_name=${dt_name_ul}  ue_alias=${ue_alias}  direction=ul   
    ...    throughput=${dl_throughput}   packet_size=${packet_size}    protocol=${protocol}    apn=srancptupf0
    Run Keyword And Ignore Error    ue.check_data_transfer_is_alive   ${dt_name_ul}
    # Run Keyword And Ignore Error    ue.await_data_transfer_finish   ${dt_name_ul}
    RETURN    ${dt_name_ul}

start_UL_UDP_traffic_for_ever
    [Arguments]    ${ue_alias}    ${dt_name}=${1}    ${direction}=ul    ${throughput}=40MBytes/sec    ${protocol}=udp
    Set Test Variable     ${dt_name_ul}       DT_${dt_name}
    ue.start_data_transfer    dt_name=${dt_name_ul}     ue_alias=${ue_alias}
    ...    direction=${direction}     throughput=${throughput}    protocol=${protocol}    apn=srancptupf0
    RETURN    ${dt_name_ul}

check_data_transfer_is_alive_taf
    [Arguments]    ${dt_name}
    IF    ${True}
        ue.check_data_transfer_is_alive    dt_name=${dt_name}
        RETURN   ${True}
    END
    RETURN   ${False}

stop_data_transfer_taf
    [Arguments]    ${dt_name}
    ue.stop_data_transfer    dt_name=${dt_name}
    RETURN   ${True}

Get UE info
    [Arguments]   ${ue_alias}
    ue.log_ue_info  ue_alias=${ue_alias}

Start voice call
    [Arguments]   ${ue_alias} 
    BuiltIn.Set Test Variable    ${vc_alias}    internal_call
    ue.start_voice_call  vc_alias=${vc_alias}  ue_alias=${ue_alias}    to=+123456    

Stop voice call
    ue.stop_voice_call   vc_alias=${vc_alias}

Attach_voice_data_transfer_L3Call
    [Documentation]    L3 Call Methodology
    [Arguments]    ${Cell_moc}
    BuiltIn.Log To Console    ${Cell_moc}
    Attach Ue via taf ue    ue_alias=${ue_alias}
    Log To Console   \n[ INFO ]: UE Alias ${ue_alias}:UE is Attached to Network
    Start voice call    ue_alias=${ue_alias}
    Log To Console  \n[ INFO ]: Voice call is started
    Log To Console  \n[ INFO ]: UDP Data transfer is started
    Start DL traffic and chech data transfer status    ue_alias=${ue_alias}
    Log To Console  \n[ INFO ]: UDP DL Data transfer is completed
    Start UL traffic and chech data transfer status    ue_alias=${ue_alias}
    Log To Console  \n[ INFO ]: UDP UL Data transfer is completed
    Stop voice call
    Log To Console  \n[ INFO ]: voice call stopped
    Detach Ue via taf ue    ue_alias=${ue_alias}
    Log To Console  \n[ INFO ]: UE Detached from Network

Attach_UDP_traffic
    [Documentation]    Used purpose of ANR Test cases.
    Attach Ue via taf ue    ue_alias=${ue_alias}
    Log To Console   \n[ INFO ]: UE Alias ${ue_alias}:UE is Attached to Network
    Log To Console  \n[ INFO ]: UDP Data transfer is started
    Start DL traffic and chech data transfer status    ue_alias=${ue_alias}
    Log To Console  \n[ INFO ]: UDP DL Data transfer is completed
    Start UL traffic and chech data transfer status    ue_alias=${ue_alias}
    Log To Console  \n[ INFO ]: UDP UL Data transfer is completed

Reserve_Attach_voice_data_transfer_L3Call
    [Documentation]  taf.ue.at helps to perform ue Require
    ...    more details:https://confluence.ext.net.nokia.com/display/AbstractLibs/taf.ue%3A+__init__.py+configuration+file
    [Arguments]    ${cell_used_in_test}   ${remote}
    ${items}  Get Dictionary Items   ${UEaliasandCapabilitiesdict_465}
    BuiltIn.Log To Console    ${cell_used_in_test}    ${remote}
    FOR  ${key}  ${value}  IN  @{items}
        Set Suite Variable    ${ue_alias}    ${key}
        Set Suite Variable    ${ue_capabilities}   ${value}
        Log To Console  \n[ INFO ]: UE taf.ue.require is started
        ue.Require Ue  ue_alias=${ue_alias}   capabilities=${ue_capabilities}
        Log To Console   \n[ INFO ]: UE Alias ${ue_alias}\n[ INFO ]: UE cabapilits ${ue_capabilities}\n[ INFO ]: UE IS RESERVED
        Attach Ue via taf ue    alias=${ue_alias}
        Log To Console   \n[ INFO ]: UE Alias ${ue_alias}:UE is Attached to Network
        Start voice call  alias=${ue_alias}
        Log To Console  \n[ INFO ]: Voice call is started
        Log To Console  \n[ INFO ]: UDP Data transfer is started
        Start DL traffic and chech data transfer status    alias=${ue_alias}
        Log To Console  \n[ INFO ]: UDP DL Data transfer is completed
        Start UL traffic and chech data transfer status    alias=${ue_alias}
        Log To Console  \n[ INFO ]: UDP UL Data transfer is completed
        Stop voice call
        Log To Console  \n[ INFO ]: voice call stopped
        Detach Ue via taf ue     alias=${ue_alias}
        Log To Console  \n[ INFO ]: UE Detached from Network
    END

L3 Methodoly With Simcom
    [Documentation]    The KW does L3 Attach/detach on All Cells in BTS. eg.7_2_RJIO1061
    [Arguments]    ${Cell_moc}=test    ${rest_t}=10
    BuiltIn.Log To Console    ${Cell_moc}
    # Require Ue    ue_alias=${ue_alias}    capabilities=Simcom_UE_1
    ue.Log Ue Info    ${ue_alias}    ALL
    ue.Detach Ue     ue_alias=${ue_alias}
    ue.set_earfcn_lock    ${ue_alias}    network_mode=5G    earfcn=634080    scs=30    band=78    pci=24
    ue.Attach Ue     ue_alias=${ue_alias}
    ue.Turn Volte On    ue_alias=${ue_alias}
    BuiltIn.Sleep    ${rest_t}
    ue.Turn Volte Off    ue_alias=${ue_alias}
    ue.Detach Ue     ue_alias=${ue_alias}
    BuiltIn.Sleep    ${rest_t}
    ue.set_earfcn_lock    ${ue_alias}    network_mode=5G    earfcn=634080    scs=30    band=78    pci=25
    ue.Attach Ue     ue_alias=${ue_alias}
    ue.Turn Volte On    ue_alias=${ue_alias}
    BuiltIn.Sleep    ${rest_t}
    ue.Turn Volte Off    ue_alias=${ue_alias}
    ue.Detach Ue     ue_alias=${ue_alias}
    BuiltIn.Sleep    ${rest_t}
    ue.set_earfcn_lock    ${ue_alias}    network_mode=5G    earfcn=634080    scs=30    band=78    pci=26
    ue.Attach Ue     ue_alias=${ue_alias}
    ue.Turn Volte On    ue_alias=${ue_alias}
    BuiltIn.Sleep    ${rest_t}
    ue.Turn Volte Off    ue_alias=${ue_alias}
    ue.Detach Ue     ue_alias=${ue_alias}
    BuiltIn.Sleep    ${rest_t}
    ue.set_earfcn_lock    ${ue_alias}    network_mode=5G    earfcn=156510    scs=30    band=28    pci=24
    ue.Attach Ue     ue_alias=${ue_alias}
    ue.Turn Volte On    ue_alias=${ue_alias}
    BuiltIn.Sleep    ${rest_t}
    ue.Turn Volte Off    ue_alias=${ue_alias}
    ue.Detach Ue     ue_alias=${ue_alias}
    BuiltIn.Sleep    ${rest_t}
    ue.set_earfcn_lock    ${ue_alias}    network_mode=5G    earfcn=156510    scs=30    band=28    pci=25
    ue.Attach Ue     ue_alias=${ue_alias}
    ue.Turn Volte On    ue_alias=${ue_alias}
    BuiltIn.Sleep    ${rest_t}
    ue.Turn Volte Off    ue_alias=${ue_alias}
    ue.Detach Ue     ue_alias=${ue_alias}
    BuiltIn.Sleep    ${rest_t}
    ue.set_earfcn_lock    ${ue_alias}    network_mode=5G    earfcn=156510    scs=30    band=28    pci=26
    ue.Attach Ue     ue_alias=${ue_alias}
    ue.Turn Volte On    ue_alias=${ue_alias}
    BuiltIn.Sleep    ${rest_t}
    ue.Turn Volte Off    ue_alias=${ue_alias}
    ue.Detach Ue     ue_alias=${ue_alias}

Simcom Attach DT Detach
    [Documentation]    simcom functionallity
    ue.Require Ue    ue_alias=${ue_alias}    capabilities=Simcom_UE_1
    ue.Log Ue Info    UE_1    ALL
    ue.Detach Ue     ue_alias=${ue_alias}
    ue.set_earfcn_lock    UE_1    network_mode=NR    earfcn=634080    scs=30    band=78    pci=786  # earfcn== ssbfrequency
    ue.Attach Ue     ue_alias=${ue_alias}
    ue.Log Ue Info    UE_1    ALL
    ue.Start Data Transfer     DT_1    UE_1    DL    protocol=udp    packet=1024B    throughput=60Mbits/sec
    Sleep    10
    Run Keyword And Continue On Failure    ue.Verify Average Throughput With Deviation    DT_1    6000Kbits/sec    50%
    ue.Stop Data Transfer    DT_1
    ue.Detach Ue     ue_alias=${ue_alias}

Additional test for simcom
    [Documentation]    simcom functionallity
    set_earfcn_lock    UE_1    network_mode=NR    earfcn=156510    scs=15    band=28    pci=24
    Attach Ue     ue_alias=${ue_alias}
    Log Ue Info    UE_1    ALL
    Start Data Transfer     DT_1    UE_1    DL    protocol=tcp    packet=1024B    throughput=60Mbits/sec
    Sleep    40
    Stop Data Transfer    DT_1
    Run Keyword And Continue On Failure    Verify Average Throughput With Deviation    DT_1    25991Kbits/sec    100%
    Start Data Transfer     DT_2    UE_1    UL    protocol=tcp    packet=1024B    throughput=60Mbits/sec
    Sleep    30
    Stop Data Transfer    DT_2
    Run Keyword And Continue On Failure    Verify Average Throughput With Deviation    DT_2    1006Kbits/sec    100%
    Detach Ue     ue_alias=${ue_alias}
    set_earfcn_lock    UE_1    network_mode=NR    earfcn=156510    scs=15    band=28    pci=25
    Attach Ue     ue_alias=${ue_alias}
    Log Ue Info    UE_1    ALL
    Start Data Transfer     DT_1    UE_1    DL    protocol=tcp    packet=1024B    throughput=60Mbits/sec
    Sleep    40
    Stop Data Transfer    DT_1
    Run Keyword And Continue On Failure    Verify Average Throughput With Deviation    DT_1    25991Kbits/sec    100%
    Start Data Transfer     DT_2    UE_1    UL    protocol=tcp    packet=1024B    throughput=60Mbits/sec
    Sleep    30
    Stop Data Transfer    DT_2
    Run Keyword And Continue On Failure    Verify Average Throughput With Deviation    DT_2    1066Kbits/sec    100%
    Detach Ue     ue_alias=${ue_alias}
    set_earfcn_lock    UE_1    network_mode=NR    earfcn=156510    scs=15    band=28    pci=26
    Attach Ue     ue_alias=${ue_alias}
    Log Ue Info    UE_1    ALL
    Start Data Transfer     DT_1    UE_1    DL    protocol=tcp    packet=1024B    throughput=60Mbits/sec
    Sleep    40
    Stop Data Transfer    DT_1
    Run Keyword And Continue On Failure    Verify Average Throughput With Deviation    DT_1    25559Kbits/sec    100%
    Start Data Transfer     DT_2    UE_1    UL    protocol=tcp    packet=1024B    throughput=60Mbits/sec
    Sleep    30
    Stop Data Transfer    DT_2
    Run Keyword And Continue On Failure    Verify Average Throughput With Deviation    DT_2    1066Kbits/sec    100%
    Detach Ue     ue_alias=${ue_alias}
    set_earfcn_lock    UE_1    network_mode=NR    earfcn=634080    scs=30    band=78    pci=24
    Attach Ue     ue_alias=${ue_alias}
    Log Ue Info    UE_1    ALL
    Start Data Transfer     DT_1    UE_1    DL    protocol=tcp    packet=1024B    throughput=60Mbits/sec
    Sleep    40
    Stop Data Transfer    DT_1
    Run Keyword And Continue On Failure    Verify Average Throughput With Deviation    DT_1    259918Kbits/sec    30%
    Start Data Transfer     DT_2    UE_1    UL    protocol=tcp    packet=1024B    throughput=60Mbits/sec
    Sleep    30
    Stop Data Transfer    DT_2
    Run Keyword And Continue On Failure    Verify Average Throughput With Deviation    DT_2    120066Kbits/sec    50%
    Detach Ue     ue_alias=${ue_alias}
    set_earfcn_lock    UE_1    network_mode=NR    earfcn=634080    scs=30    band=78    pci=25
    Attach Ue     ue_alias=${ue_alias}
    Log Ue Info    UE_1    ALL
    Start Data Transfer     DT_1    UE_1    DL    protocol=tcp    packet=1024B    throughput=60Mbits/sec
    Sleep    40
    Stop Data Transfer    DT_1
    Run Keyword And Continue On Failure    Verify Average Throughput With Deviation    DT_1    259918Kbits/sec    30%
    Start Data Transfer     DT_2    UE_1    UL    protocol=tcp    packet=1024B    throughput=60Mbits/sec
    Sleep    30
    Stop Data Transfer    DT_2
    Run Keyword And Continue On Failure    Verify Average Throughput With Deviation    DT_2    120066Kbits/sec    50%
    Detach Ue     ue_alias=${ue_alias}

VONR With UL DT For 30Minutes And ReCommission Keyword
    [Documentation]   VONR test case with UL DT for 30 minutes
    [Arguments]    ${Keyword}=${None}   ${Call_duration}=120 seconds
    Attach Ue via taf ue    ue_alias=${ue_alias}
    Log To Console   \n[ INFO ]: UE Alias ${ue_alias}:UE is Attached to Network
    Start voice call    ue_alias=${ue_alias}  
    Log To Console  \n[ INFO ]: Voice call is started
    BuiltIn.Log To Console  \n[ INFO ]: TCP UL Data transfer is started
    BuiltIn.Log To Console  \n[ INFO ]: TCP DL Data transfer is started
    Start UL traffic and chech data transfer status    ue_alias=${ue_alias}    protocol=tcp
    Start DL traffic and chech data transfer status    ue_alias=${ue_alias}    protocol=tcp
    Log To Console  \n[ INFO ]: []UDP UL Data transfer is Onging.
    BuiltIn.Log To Console    [ INFO ]: Checking the UE Voice call status
    ue.check_voice_call_state    vc_alias=${vc_alias}
    BuiltIn.Log To Console    [ INFO ]: Voice call is still active
    BuiltIn.Log To Console    [ INFO ]: Checking data transfer status
    Restart Data Transfer If DT is not active
    BuiltIn.Sleep    ${Call_duration}
    BuiltIn.Log To Console    [ INFO ]: Checking the UE Voice call status
    ue.check_voice_call_state    vc_alias=${vc_alias}
    BuiltIn.Log To Console    [ INFO ]: Voice call is still active
    BuiltIn.Log To Console    [ INFO ]: Checking data transfer status
    Restart Data Transfer If DT is not active
    BuiltIn.Log To Console    [ INFO ]: Data transfer is still active
    IF   "${Keyword}" != "${None}"
            Run Keyword    ${Keyword}
    END
    stop_data_transfer_taf    ${dt_name_ul}
    stop_data_transfer_taf    ${dt_name_dl}
    Stop voice call
    Detach Ue via taf ue    ue_alias=${ue_alias}


Restart Data Transfer If DT is not active
    [Documentation]   Restart Data Transfer
    ...    Arguments: dt_name, ue_alias are in Test level variables. Not required to pass.
    WHILE    ${True}
        ${ul_status}   Run Keyword And Ignore Error   
        ...    check_data_transfer_is_alive_taf    dt_name=${dt_name_ul}
        IF    "${ul_status}" == "${False}"
            BuiltIn.Log To Console    [ INFO ]: UL Data transfer is not active, Restarting UL TCP Traffic
            Start UL traffic and chech data transfer status    ue_alias=${ue_alias}    protocol=tcp
        END
        ${dl_status}    Run Keyword And Ignore Error    
        ...    check_data_transfer_is_alive_taf    dt_name=${dt_name_dl}
        IF    "${dl_status}" == "${False}"
            BuiltIn.Log To Console    [ INFO ]: DL Data transfer is not active, stopping the test
            Start DL traffic and chech data transfer status    ue_alias=${ue_alias}    protocol=tcp
        END
        BREAK
    END

*** Settings ***
Documentation   Author: Arunkumar A
...    Contact: arunkumar.a@nokia.com
...    robot file contains UE keywords with supported taf.ue

Library       String
Library       Collections
Library       taf.ue  WITH NAME  ue
Resource      ../variables/Common_variables_RJIO.robot

*** Variables ***

*** Keywords ***
Require UE
    ${items}  Get Dictionary Items   ${UEaliasandCapabilitiesdict_465}
    FOR  ${key}  ${value}  IN  @{items}
        Set Suite Variable    ${ue_alias}    ${key}
        Set Suite Variable    ${ue_capabilities}   ${value} 
        Log To Console  \n[ INFO ]: UE taf.ue.require is started
        ue.Require Ue  ue_alias=${ue_alias}   capabilities=${ue_capabilities}
        Log To Console   \n[ INFO ]: UE Alias ${ue_alias}\n[ INFO ]: UE cabapilits ${ue_capabilities}\n[ INFO ]: UE IS RESERVED
    END

Attach Ue via taf ue 
    [Documentation]  taf.ue.at helps to perform ue attach  
    ...    more details:https://confluence.ext.net.nokia.com/display/AbstractLibs/taf.ue%3A+__init__.py+configuration+file
    [Arguments]   ${alias}
    ue.Attach Ue  ue_alias=${alias}  

Detach Ue via taf ue 
    [Documentation]  taf.ue.at helps to perform ue Detach  
    ...    more details:https://confluence.ext.net.nokia.com/display/AbstractLibs/taf.ue%3A+__init__.py+configuration+file
    [Arguments]   ${alias}
    ue.Detach Ue  ue_alias=${alias}  

Start DL traffic and chech data transfer status
    [Arguments]   ${alias}  ${dl_time}=120s   ${dl_throughput}=1MBytes/sec   ${dt_index}=${0}    ${packet_size}=8
    ${dt_name_dl}    Set Variable    DT_${dt_index}
    ue.Start Data Transfer   dt_name=${dt_name_dl}   ue_alias=${alias}  direction=dl   duration=${dl_time}   
    ...    throughput=${dl_throughput}   packet_size=${packet_size}  
    ue.check_data_transfer_is_alive  ${dt_name_dl}
    ue.await_data_transfer_finish   ${dt_name_dl}

Start UL traffic and chech data transfer status
    [Arguments]   ${alias}  ${dl_time}=120s   ${dl_throughput}=1MBytes/sec   ${dt_index}=${1}    ${packet_size}=8
    ${dt_name_ul}    Set Variable    DT_${dt_index}
    ue.Start Data Transfer   dt_name=${dt_name_ul}  ue_alias=${alias}  direction=ul   duration=${dl_time}   
    ...    throughput=${dl_throughput}   packet_size=${packet_size} 
    ue.check_data_transfer_is_alive   ${dt_name_ul}        
    ue.await_data_transfer_finish   ${dt_name_ul}

Get UE info 
    [Arguments]   ${alias}
    ue.log_ue_info  ue_alias=${alias}  

Start voice call
    [Arguments]   ${alias}
    ue.start_voice_call  vc_alias=internal_call  ue_alias=${alias}    to=+123456     

Stop voice call 
    ue.stop_voice_call   vc_alias=internal_call

Attach_voice_data_transfer_L3Call
    [Documentation]  taf.ue.at helps to perform ue Require  
    ...    more details:https://confluence.ext.net.nokia.com/display/AbstractLibs/taf.ue%3A+__init__.py+configuration+file
    [Arguments]    ${cell_used_in_test}   ${remote}
    ${items}  Get Dictionary Items   ${UEaliasandCapabilitiesdict_465}
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

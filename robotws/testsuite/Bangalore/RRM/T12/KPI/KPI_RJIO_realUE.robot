*** Settings ***
Documentation       :copyright: Nokia
...                 :author   : Anandapriya Mani
...                 :contact  : anandapriya.mani@nokia.com
...                 KPI Script.

Library    DateTime
Library    BuiltIn
Library    OperatingSystem
Library    taf.sbts.oam.coam.admin     WITH NAME    admin
Library    taf.collectors.btslog  WITH NAME   btslog
Library    taf.collectors.core   WITH NAME   core
Library    ute_admin_infomodel
Library    Collections
Library     String
Library     ta_attenuator
Library     ./../../../ORAN/resources/python/ta_ultracaller/     WITH NAME     ta_ultracaller

*** Variables ***
@{UE_alias1}=    UE1
@{capabilities1}=    VIVO
@{UE_alias2}=    UE2
@{capabilities2}=    HUAWEI
@{UE_alias3}=    UE3
@{capabilities3}=    ONEPLUS
#*******DL_UDP*************
@{direction_dl}=    dl
#@{deviation_dl}=    20
#@{throughput_dl}=    100
@{direction_ul}=    ul
#@{deviation_ul}=    10
#@{throughput_ul}=    100
#**********TCP**************
#@{throughput_dl_tcp}=    50
#@{direction_ul_tcp}=    ul
#@{deviation_ul_tcp}=    10
#@{throughput_ul_tcp}=    40
#${Acceptable_Peak_tp_DL_tcp}=     25
#${Acceptable_Peak_tp_UL_tcp}=     30
#****************************
#@{packet_size}=    1024B
#@{bandwidth}=     200Mbits/sec
@{data_transfer_protocol1}=    UDP
#@{data_transfer_protocol2}=    TCP
#${Acceptable_Peak_tp_DL}=     25
#${Acceptable_Peak_tp_UL}=     30

${conf}=    /home/ute/testline_configuration/7_2_CLOUD483/ta_ue_config.yaml
${BTSLOG}      btslog
@{Protocol_Type}                            FTP
@{Protocol_Type_UDP}                        UDP
@{Protocol_Type_TCP}                        TCP
@{DIRECTION}                                dl
@{deviation_dl}                            10
@{throughput_dl}                           110

*** Keywords ***
Connect calls on realUE
    Start Btslogs from Local machine      ${BTSLOG}
    Validate_BTS_State_ONAIR
    Run call on UE   ${UE_alias1}    ${capabilities1}    ${DIRECTION}
    Sleep   30s
    Run call on UE   ${UE_alias2}    ${capabilities2}    ${DIRECTION}
    Sleep   30s
    Run call on UE   ${UE_alias3}    ${capabilities3}    ${DIRECTION}
    Sleep   90s

Check throughput for realUE
    Finish_data_transfer_and_check_throughput    ${UE_alias1}    ${DIRECTION}
    Sleep   30s
    Finish_data_transfer_and_check_throughput    ${UE_alias2}    ${DIRECTION}
    Sleep   30s
    Finish_data_transfer_and_check_throughput    ${UE_alias3}    ${DIRECTION}
    Log to console    \nDONE
    Stops Btslogs from Local machine    ${BTSLOG}

Validate_BTS_State_ONAIR
    OperatingSystem.Set Environment Variable    ABSTRACT_LIB_CONFIG    ${conf}
    admin.setup admin
    ${bts_status}   admin.get_bts_statuses
    admin.teardown admin
    Should Be Equal As Strings   ${bts_status["proceduralState"]}    OnAir
    Run Keyword If  '${bts_status["proceduralState"]}'=='OnAir'
    ...    Log To Console    \nBTS procedural state is now: ${bts_status["proceduralState"]}
    ...    ELSE    fail

Dl_data_transfer
    [Arguments]    ${UE_alias}    ${Protocol_Type_UDP}    ${DIRECTION}
    ta_ultracaller.start_datatransfer    ue_alias=${UE_alias}   protocoltype=${Protocol_Type_UDP}   direction=${DIRECTION}

Finish_data_transfer_and_check_throughput
    [Arguments]    ${ue_alias}    ${DIRECTION}
    ta_ultracaller.await_data_transfer_finish    ue_alias=${ue_alias}    direction=${DIRECTION}
    ${Dowlink_Throughput}=    Run keyword and Continue on Failure     ta_ultracaller.calculate_thrughtput
		...    ue_alias=${ue_alias}    direction=${DIRECTION}
    	...     thrughtput=${throughput_dl}    deviation=${deviation_dl}
    Log To Console  ${Dowlink_Throughput}

Run call on UE
    [Arguments]    ${UE_alias}   ${capabilities}   ${DIRECTION}
    ta_ultracaller.Require UE    ue_alias=${UE_alias}    capabilities=${capabilities}
    ta_ultracaller.Detach UE    ue_alias=${UE_alias}     #UE detach step
    Log to console    \nSwitching Aeroplane Mode On/OFF
    ta_ultracaller.Attach UE    ue_alias=${UE_alias}     #UE attach step
    Log to console    \nattach is success for ${UE_alias}
    Dl_data_transfer    ${UE_alias}    ${Protocol_Type_UDP}    ${DIRECTION}

Start Btslogs From Local Machine
    [Documentation]    path from where to get btslog files default value: "/tmp/btslog2"
    [Arguments]    ${log_alias}
    btslog.create_btslog_collector    ${log_alias}
    core.setup_collectors     ${log_alias}
    core.start_collectors     ${log_alias}
    core.Set Suite Alias    ${log_alias}

Stops Btslogs From Local Machine
    [Documentation]    path from where to get btslog files default value: "/tmp/btslog2"
    [Arguments]    ${log_alias}
    Run Keyword And Continue On Failure     core.stop_collectors      names=${log_alias}
    Run Keyword And Continue On Failure     core.collect_collectors      names=${log_alias}
    Run Keyword And Continue On Failure    core.teardown_collectors      names=${log_alias}


*** Settings ***
Documentation
...    Author:yin zhang
...    contact:yin.zhang@nokia-sbell.com
...    squad group:VRF3_8
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG8/resources/DevHZ5_resource_ST.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG8/resources/ST_robot/L3_call/DevHZ5_spark_ue.robot

*** Variables ***
${ERR_WARN_ANALYSE_FLAG}    ${False}
# @{FAULTS_EXCLUDED_CHECKING}
# ...    8000  # Failure in connection between BTS and 3rd party tool
# ...    7307  # Xn SCTP setup fail
# ...    7311  # No Xn link available
# ...    62001  # Transport layer connection establishment failure in XP interface
# ...    62003  # Transport layer connection lost in XP interface

*** Keywords ***
Prepare and attach UE with CGACT
    [Documentation]    this keyword includes prepare ue and attach ue. For single UE with 2 APN, suggest to use this keyword.
    [Arguments]    ${ue_id}=1    ${attach_mode}=5G_SA    ${get_spark_license}=${true}    ${apn}=mdrb.nokia.com
    Prepare UEs    ue_ids=${ue_id}    get_spark_license=${get_spark_license}
    run keyword and ignore error    start to capture gnb bip log    attach_ue${ue_id}
    Attach UE with CGACT    ${ue_id}    ${attach_mode}     ${apn}
    [Teardown]    run keyword and ignore error    stop to capture gnb bip log    attach_ue${ue_id}

Attach UE with CGACT
    [Arguments]    ${ue_id}=1    ${attach_mode}=5G_SA    ${apn}=mdrb.nokia.com    ${retry_times}=6
    # fix AT command stuck issue,AT+QRNRU must be set to 1 after firmware update
    run keyword and ignore error    Execute AT Command    AT+QRNRU=1    ${ue_id}
    # set APN
    Execute AT Command    AT+CGDCONT=1,"IPV4V6","${apn}"    ${ue_id}
    # set attach mode
     Run Keyword If    '${attach_mode}' == '5G_SA'     Run Keywords
    ...                        Execute AT Command    AT+QNWPREFCFG="nr5g_disable_mode",0    ue_id=${ue_id}    AND
    ...                        Execute AT Command    AT+QNWPREFCFG="nr5g_disable_mode",2    ue_id=${ue_id}    AND
    ...                        Execute AT Command    AT+QNWPREFCFG="mode_pref",NR5G    ue_id=${ue_id}
    ...    ELSE IF    '${attach_mode}' == '5G_NSA'    Run Keywords
    ...                        Execute AT Command    AT+QNWPREFCFG="nr5g_disable_mode",0    ue_id=${ue_id}    AND
    ...                        Execute AT Command    AT+QNWPREFCFG="nr5g_disable_mode",1    ue_id=${ue_id}    AND
    ...                        Execute AT Command    AT+QNWPREFCFG="mode_pref",auto    ue_id=${ue_id}
    ...    ELSE IF    '${attach_mode}' == '4G'       Execute AT Command    AT+QNWPREFCFG="mode_pref",LTE    ue_id=${ue_id}
    ...    ELSE    Fail    not support attach_mode=${attach_mode}
    wait until keyword succeeds    ${retry_times}x    10s    _Attach For Once with CGACT    ${ue_id}    ${attach_mode}    ${apn}

_Attach For Once with CGACT
    [Arguments]    ${ue_id}    ${attach_mode}    ${apn}
#    run keyword and ignore error    power_ue.UE Detach    ue_type=${UE_TYPE}    ue_index=${${ue_id}-1}
#    ${attach_rc}    power_ue.UE Attach      ue_type=${UE_TYPE}
#    ...                                     ue_index=${${ue_id}-1}
#    ...                                     attach_mode=${attach_mode}
#    run keyword if  "${attach_rc}" != "0"    Execute AT Command    AT+CFUN=1,1   ${ue_id}
#    run keyword if  "${attach_rc}" != "0"    Sleep    30s
    Execute AT Command    AT+CFUN=1,1   ${ue_id}
    Sleep    60s
    ${ue_mode}    set variable if    '${attach_mode}' == '5G_SA'    SA    ${attach_mode}
    run keyword and ignore error    Execute AT Command    at+cgact=1,1    ue_id=${ue_id}
    Sleep    2s
    run keyword and ignore error    Execute AT Command    at+cgpaddr    ue_id=${ue_id}
    ${apn}    Remove String    ${apn}    .
    spark.get_ue_ip_on_ue    ue_alias=UE_${${ue_id}-1}
    ...                      apnaddress=${apn}
    ...                      ue_mode=${ue_mode}
    ...                      timeout=60
    Get UE RNTI    ${ue_id}
    [Teardown]    _Print Events    ${ue_id}

Attach UE with CGACT without Prepare
    [Documentation]    this keyword includes prepare ue and attach ue. For single UE with 2 APN, suggest to use this keyword.
    [Arguments]    ${ue_id}=1    ${attach_mode}=5G_SA    ${apn}=mdrb.nokia.com
    run keyword and ignore error    start to capture gnb bip log    attach_ue${ue_id}
    Attach UE with CGACT    ${ue_id}    ${attach_mode}     ${apn}
    [Teardown]    run keyword and ignore error    stop to capture gnb bip log    attach_ue${ue_id}

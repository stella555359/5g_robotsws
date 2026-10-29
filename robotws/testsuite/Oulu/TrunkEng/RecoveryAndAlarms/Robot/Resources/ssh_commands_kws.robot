*** Settings ***
Documentation
...   Author:   Terhi Talvitie
...   Contact:  I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com


*** Keywords ***
Ssh to bts and unit and kill application
    [Documentation]  This KW takes ssh connection to SMOD and from there ssh connection to SOC of BBMOD and finds and kills
    ...              user given application. NOTE with this KW, application cannot be started on virtual node.
    ...              Arguments can be for example:
    ...              ABIA1    K2A    FaultServiceExe    1    Kill application from soc of abia
    [Arguments]    ${bbmod_name}  ${SOC}    ${APPLICATION}    ${STEP}    ${STEP_TEXT}
    Run Keyword And Continue On Failure    Make SSH Log
    ${unit_ip}=                            Get IP Of Selected FSP  ${bbmod_name}  ${SOC}
    Run Keyword And Continue On Failure    Make BTS SSH Connection
    Run Keyword And Continue On Failure    Take SSH Connection  ${unit_ip}  UNIT  proxy=SMOD
    ${pid}=                                Find Real Application PID  ${APPLICATION}  alias=UNIT
    Print Step Text    ${STEP}  ${STEP_TEXT}
    Run Keyword And Continue On Failure    Kill Application  ${pid}  ${APPLICATION}  alias=UNIT
#    ${output}=    send_command_to_ip_return_output   grep . /proc/${pid}/task/*/stack   alias=UNIT
#    print_text_to_eventlog    ${output}
#    Sleep     10 seconds
#    ${output}=    send_command_to_ip_return_output   grep . /proc/${pid}/task/*/stack   alias=UNIT
#    print_text_to_eventlog    ${output}
#    Sleep     10 seconds
#    ${output}=    send_command_to_ip_return_output   grep . /proc/${pid}/task/*/stack   alias=UNIT
#    print_text_to_eventlog    ${output}
    Run Keyword And Continue On Failure    Close SSH Connection  alias=UNIT
    Run Keyword And Continue On Failure    Close BTS SSH Connection
    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}    ${False}

Ssh to bts and kill application
    [Documentation]  This KW takes ssh connection to SMOD and finds and kills user given application.
    ...              NOTE with this KW, application cannot be started on virtual node.
    ...              Arguments can be for example:
    ...              LTS    1
    [Arguments]    ${APPLICATION}    ${STEP}
    Run Keyword And Continue On Failure    Make SSH Log
    Run Keyword And Continue On Failure    Make BTS SSH Connection
    Print Step Text    ${STEP}  Get pid of ${APPLICATION}
    ${pid}=   Find Real Application Pid    ${APPLICATION}
    ${STEP}=    Addition  ${STEP}  1
    Print Step Text    ${STEP}  Kill ${APPLICATION} -application
    Run Keyword And Continue On Failure    Kill Application      ${pid}    ${APPLICATION}
    Run Keyword And Continue On Failure    Close BTS SSH Connection
    [Teardown]    Run Keyword If  '${KEYWORD STATUS}' == 'FAIL'  Set Suite Variable  ${KW_SUCCESS}    ${False}

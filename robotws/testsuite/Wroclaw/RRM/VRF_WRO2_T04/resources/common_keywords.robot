*** Settings ***
Documentation    VRF_WRO2_T04 Common Keywords

Library    DateTime
Library    taf.sbts.oam.coam.admin    WITH NAME    taf_admin

*** Variables ***
${WHITE}        "\\033[7m"
${RED}          "\\033[31m"
${BLUE}         "\\033[34m"
${GREEN}        "\\033[32m"
# backgroung colours
${REDBG}        "\\033[41m"
${BLUEBG}       "\\033[44m"


*** Keywords ***
Show Text on Console
    [Documentation]   Add colour and/or timestamp to 'Log To Console' keyword
    [Arguments]   ${text_to_display}
    ...           ${colour}=${WHITE}
    ...           ${show_timestamp}=yes
    ${timestamp}   DateTime.Get Current Date   result_format=%H:%M:%S
    ${time_info}   Set Variable If   '${show_timestamp}' == 'yes'  [ INFO ] ${timestamp} -${SPACE}  ${EMPTY}
    ${text}   Evaluate  ${colour} "\\n${time_info}${text_to_display}\\033[0m\\n"
    Log To Console   ${text}

Update Parameter
    [Arguments]    ${param}    ${value}    ${distname}=MRBTS-${mrbts_id}/NRBTS-${nrbts_id}
    Log To Console    Updating param ${param} value to: ${value}
    taf_admin.Setup Admin    alias=param_change
    taf_admin.Perform Parameter Recommissioning     parameter=${param}    value=${value}    dist_name=${distname}
    ...    skip_parameter_relation_errors=${FALSE}    operation=update    alias=param_change
    [Teardown]    taf_admin.Teardown Admin    param_change

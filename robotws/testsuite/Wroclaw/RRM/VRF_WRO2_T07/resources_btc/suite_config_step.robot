*** Settings ***
Documentation
...    :copyright: Nokia
...    :contact: I_EXT_MN_RAN_VRF_WRO2_7_T03@internal.nsn.com

Library     OperatingSystem
Library     Process

*** Keywords ***

Config Step Start '${message}'
    Log     ${message}...   console=yes

Config Step Stop '${sleep}'
    Run Keyword If  '${sleep}' != '0'   Sleep   ${sleep}
    Log     [DONE]  console=yes

Run Command Using Process '${command}'
    ${process_output}=    Run Process    ${command}    shell=True
    ${result}    Set Variable    ${process_output.rc}
    ${output}    Set Variable    ${process_output.stdout}
    [Return]    ${result}    ${output}

Config Step '${command}' '${message}' '${sleep}'
    Config Step Start '${message}'
    ${result}   ${output} =     Run Command Using Process '${command}'
    Run Keyword If  ${result} != 0  Fail    [ERROR]\n${output}
    Config Step Stop '${sleep}'

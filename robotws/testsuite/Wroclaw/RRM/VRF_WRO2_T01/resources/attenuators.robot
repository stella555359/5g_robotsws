*** Settings ***
Documentation  This contains keywords imported from testtsuite\Wroclaw\RRM\VRF_WRO2_T01\resources\legacy\common_kw.robot
...            Attenuators keywords helps to manipulate an attenuator. Importing from origin resource provides to multiple keywords name conflicts

Library    taf.hw.rf_attenuator    WITH NAME    att
Library    SeleniumLibrary

*** Keywords ***
Setup attenuators
    [Arguments]    ${atten_ip}=${tl.attenuator.ip_addr}
    ...            ${att_api_port}=${tl.attenuator.port}
    ...            ${atten_ports}=${tl.attenuator.attenuator_ports}
    ...            ${max_attenuation_value}=${90}
    ...            ${atten_vendor}=TopYoung
    ...            ${atten_model}=${tl.attenuator.model}
    ${status}   Run Keyword And Return Status    att.Setup attenuator
    ...    ip_addr=${atten_ip}
    ...    port=${att_api_port}
    ...    attenuation_port_numbers=${atten_ports}
    ...    max_attenuation=${max_attenuation_value}
    ...    vendor=${atten_vendor}
    ...    model=${atten_model}
    Run Keyword If    '${status}' == 'False'      Run Keywords
    ...    Reset Attenuator    AND
    ...    att.Setup attenuator
    ...    ip_addr=${atten_ip}
    ...    port=${att_api_port}
    ...    attenuation_port_numbers=${atten_ports}
    ...    max_attenuation=${max_attenuation_value}
    ...    vendor=${atten_vendor}
    ...    model=${atten_model}


Set attenuation and check
    [Arguments]      ${lines}    ${value}
    FOR    ${line}    IN    @{lines}
        att.Set attenuation     port=${${line}}     value=${${value}}
        ${value_port}    att.Read attenuation    port=${${line}}
        Should be equal    ${value_port}    ${${value}}
    END

Turn off attenuation
    ${lines}    Get dictionary keys     ${tl.attenuator.attenuator_ports}
    ${status}   Run Keyword And Return Status    Set attenuation and check    lines=${lines}    value=${0}
    Run Keyword If    '${status}' == 'False'      Run Keywords
    ...    Reset Attenuator     AND
    ...    Setup attenuators    AND
    ...    Set attenuation and check    lines=${lines}    value=${0}

Turn on attenuation
    ${lines}    Get dictionary keys     ${tl.attenuator.attenuator_ports}
    Set attenuation and check    lines=${lines}    value=${90}

Reset Attenuator
    log to console    __Something went wrong, attenuator reset ongoing...
    Open Browser      http://${tl.attenuator.ip_addr}/    headlesschrome
    BuiltIn.sleep  5s
    Click Element    xpath=/html/body/p[8]/font/input[3]
    BuiltIn.sleep  30s
    [Teardown]  Close Browser
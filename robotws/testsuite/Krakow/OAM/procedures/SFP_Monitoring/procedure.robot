*** Settings ***
Library    ./sfpmonitoring.py
Variables  ./variables.py

*** Keywords ***
Initiate Smod Sfp Monitoring
    [Arguments]        ${devices_list}=${smod_test_devices_list}    ${boundaries}=${smod_test_boundaries}
    Wait Until Keyword Succeeds    3x    180s     Initiate Sfp Monitoring
    ...                            devices_list=${devices_list}
    ...                            device_to_verify=SMOD
    ...                            connection_state=notConnected
    ...                            boundaries=${boundaries}

Initiate Bbmod Sfp Monitoring
    [Arguments]        ${devices_list}=${bbmod_test_devices_list}    ${boundaries}=${bbmod_test_boundaries}
    ...                ${bbmod_device}=BBMOD_R-1
    Wait Until Keyword Succeeds    3x    180s     Initiate Sfp Monitoring
    ...                            devices_list=${devices_list}
    ...                            device_to_verify=${bbmod_device}
    ...                            connection_state=connected
    ...                            boundaries=${boundaries}

Initiate Ru Sfp Monitoring
    [Arguments]        ${devices_list}=${rmod_test_devices_list}    ${rmod_device}=RMOD_R-1
    ...                ${boundaries}=${rmod_test_boundaries}
    Wait Until Keyword Succeeds    3x    180s     Initiate Sfp Monitoring
    ...                            devices_list=${devices_list}
    ...                            device_to_verify=${rmod_device}
    ...                            connection_state=connected
    ...                            boundaries=${boundaries}

Check Dynamic SFP Parameters Saved Into PM Counters For ABIL
    [Arguments]    ${boundaries}=${xml_boundaries}
    Wait Until Keyword Succeeds    40x   120s     Check Quantity Of Rd Files
    ${parsed_files}    Get Parsed Rd Files    path=${OUTPUT_DIR}/ABIL
    Check Counters From Sfp File Monitoring
    ...                            parsed_files=${parsed_files}
    ...                            device=bbmod
    ...                            boundaries=${boundaries}

Check Dynamic SFP Parameters Saved Into PM Counters For Ru
    [Arguments]    ${boundaries}=${xml_boundaries}
    Wait Until Keyword Succeeds    40x   120s     Check Quantity Of Rd Files
    ${parsed_files}    Get Parsed Rd Files    path=${OUTPUT_DIR}/RU
    Check Counters From Sfp File Monitoring
    ...                            parsed_files=${parsed_files}
    ...                            device=rmod
    ...                            boundaries=${boundaries}

Initiate Smod Sfp Monitoring For Static Parameters
    [Arguments]        ${devices_list}=${smod_test_devices_list}    ${boundaries}=${temperature_static_boundaries}
    Verify Static Data From Sfp Monitoring
    ...        devices_list=${devices_list}
    ...        device_to_verify=SMOD
    ...        connection_state=notConnected
    ...        boundaries=${boundaries}

*** Settings ***
Documentation
...    Provides CB007442 specific keywords.
...    Author: Wlosek Michal
...    Contact: bartosz.rutkowski@nokia.com

Library          DateTime
Library          taf.sbts.oam.coam.admin    WITH NAME   coam_admin

Resource         ../../../common_resources/admin/admin.robot
Resource         ../../../common_resources/logs/common_unit_logs.robot


*** Keywords ***
Reset BBMOD In Background Process
    [Arguments]    ${BBMOD_path}    ${BBMOD_nr}
    Connect to ADMIN    ip_address=192.168.255.129    alias=BBMOD_reset_${BBMOD_nr}
    ${background_reset}=    coam_admin.run_keyword_in_background
    ...                                interface=admin
    ...                                name=reset_unit
    ...                                dist_name=${BBMOD_path}
    ...                                reset_type=Warm
    ...                                connection=BBMOD_reset_${BBMOD_nr}
    Log    \nReset In Background info: ${background_reset}    console=True
    Wait Until Keyword Succeeds  5x  5sec    Check If Unit Reset Successful    ${BBMOD_path}
    [Teardown]    Disconnect from ADMIN    connection=BBMOD_reset_${BBMOD_nr}


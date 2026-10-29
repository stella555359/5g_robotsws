*** Settings ***

Documentation
...   This is a test suite used in KW resourceCI running against real AP TL.
...   It verifies proper function of KWs in /MCSharkDissectors.py.


Resource   ../testline.robot
Library    ../python/MCSharkDissectors.py

*** Test Cases ***

Test Update of mcshark
    [TAGS]            MCSHARK
    ${gnb_version}=   Get GNB SW Version    gnb_id=${0}
    Log To Console    \nfor gNodeb Version ${gnb_version}

    Update MCshark Dissector      ${gnb_version}   force=${True}

    ${installed_dissector}=    Get Mcshark Dissector Name
    Log To Console    \nMCshark Dissector: ${installed_dissector}

    Should Contain    ${installed_dissector}    ${gnb_version}
    ...     MCShark was not installed succesfully for ${gnb_version}

Test Get latest plugin versions
    ${plugin_versions}   Get Latest Available Versions Of Wireshark Plugins
    Should Contain    ${plugin_versions}   nsetap
    Should Contain    ${plugin_versions}   nsetapx
    Should Contain    ${plugin_versions}   nokiaf1
    Should Contain    ${plugin_versions}   nokiaxn

Test Install latest plugin Versions
    ${gnb_version}=   Get GNB SW Version    gnb_id=${0}
    Install Wireshark Plugins     gnb_sw_version=${gnb_version}
